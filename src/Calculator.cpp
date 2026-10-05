#include "Calculator.h"
#include "SliperModel.h"
#include <QtMath>
#include <algorithm>
#include <cmath>

// Stroke zamanlama sabitleri SliperModel bölüm 4'ten gelir
using SliperModel::KONUM_TOLERANSI_MM;
using SliperModel::UST_YAKALAMA_TOLERANSI_MM;
using SliperModel::ALT_YAKALAMA_TOLERANSI_MM;
using SliperModel::DURGUN_TOLERANS_MM;
using SliperModel::DURMA_TOLERANSI_MM;
using SliperModel::DURMA_ONAYI_S;
using SliperModel::MIN_INIS_YOLU_MM;
using SliperModel::MIN_INIS_SURESI_S;
using SliperModel::KALDIRMA_ESIGI_MM;
using SliperModel::ONCESI_PENCERE_S;
using SliperModel::SONRASI_PENCERE_S;
using SliperModel::HAREKET_PAYI_S;
using SliperModel::P0R_OTURMA_S;
using SliperModel::UST_TAMPON_S;

Calculator::Calculator(QObject *parent)
    : QObject(parent)
{
}

QString Calculator::durum() const { return m_durum; }
int Calculator::strokeSayisi() const { return m_strokeSayisi; }
bool Calculator::duraklatildi() const { return m_duraklatildi; }
bool Calculator::sonStrokeGecerli() const { return m_sonStrokeGecerli; }
QVariantMap Calculator::sonStroke() const { return m_sonStroke; }
double Calculator::ustKonumMm() const { return m_ustKonumMm; }
double Calculator::altKonumMm() const { return m_altKonumMm; }

void Calculator::setUstKonumMm(double deger)
{
    if (qFuzzyCompare(m_ustKonumMm, deger)) return;
    m_ustKonumMm = deger;
    emit konumSinirlariChanged();
}

void Calculator::setAltKonumMm(double deger)
{
    if (qFuzzyCompare(m_altKonumMm, deger)) return;
    m_altKonumMm = deger;
    emit konumSinirlariChanged();
}

// Boru bu yüksekliğin üstündeyse "üstte", altEsik'in altındaysa "altta" sayılır
double Calculator::ustEsik() const { return yon() * m_ustKonumMm - UST_YAKALAMA_TOLERANSI_MM; }

double Calculator::ustYakalamaToleransiMm() const { return UST_YAKALAMA_TOLERANSI_MM; }
double Calculator::minInisYoluMm() const { return MIN_INIS_YOLU_MM; }
double Calculator::altEsik() const { return yon() * m_altKonumMm + ALT_YAKALAMA_TOLERANSI_MM; }

void Calculator::durumAyarla(const QString &yeniDurum)
{
    if (yeniDurum != m_durum) {
        m_durum = yeniDurum;
        emit durumChanged();
    }
}

// Durumlar:  YUKARIDA -> INIYOR -> TAMAMLANDI (-> bitiş sonrası 2 s veri) -> YUKARIDA ...
void Calculator::konumGuncelle(double zamanS, double konumMm, double basincMbar)
{
    if (m_duraklatildi) {
        return;
    }

    const double yukseklikMm = yon() * konumMm;      // yukarı = büyük
    const Ornek yeniOrnek { zamanS, yukseklikMm, basincMbar };

    // Bitiş sonrası 2 s: P0r ve eğrinin sönümlenen kısmı için veri toplanır.
    // Boru bu sürede tekrar kaldırılırsa stroke erken kapatılır.
    if (m_bitisSonrasiToplaniyor) {
        // Ölçüt stroke'un bittiği yüksekliğe göredir: iniş alt referansa
        // varmadan da (boru betonun üstünde durur) kapanabildiği için sabit bir
        // eşik kullanılamaz, yoksa kısa strokelarda P0r penceresi hiç toplanmaz.
        const bool boruTekrarKaldirildi = yukseklikMm > m_bitisYuksekligiMm + KALDIRMA_ESIGI_MM;
        if (boruTekrarKaldirildi) {
            strokuBitir();
        } else {
            m_strokeOrnekleri.append(yeniOrnek);
            if (zamanS - m_bitisZamaniS >= SONRASI_PENCERE_S) {
                strokuBitir();
            }
            return;
        }
    }

    // --- Boru üstte ---
    if (yukseklikMm > ustEsik()) {
        // Yarım kalmış bir iniş varsa (boru geri kaldırıldı) atılır;
        // son UST_TAMPON_S saniyelik örnekler saklanır (P0l bunlardan seçilecek).
        m_strokeOrnekleri.clear();
        m_ustteBekleyenOrnekler.append(yeniOrnek);
        while (!m_ustteBekleyenOrnekler.isEmpty()
               && zamanS - m_ustteBekleyenOrnekler.first().zamanS > UST_TAMPON_S) {
            m_ustteBekleyenOrnekler.removeFirst();
        }
        durumAyarla("YUKARIDA");
        return;
    }

    // --- Boru iniyor (üst ve alt eşik arasında) ---
    if (yukseklikMm > altEsik()) {
        if (m_durum == "YUKARIDA") {
            strokuBaslat(zamanS);
            m_inisBaslangicYuksekligiMm = yukseklikMm;
        }
        if (m_durum == "YUKARIDA" || m_durum == "INIYOR") {
            m_strokeOrnekleri.append(yeniOrnek);
            durumAyarla("INIYOR");
            // Alt referansa hiç varılmasa bile (beton yüksekte kalır, alt
            // kalibrasyon noktası erişilmez olur) boru durduğunda stroke biter.
            // İniş, onay süresinin sonunda değil borunun gerçekten durduğu
            // örnekte kapatılır.
            const int durmaIndeksi = durmaBaslangicIndeksi(zamanS);
            if (durmaIndeksi >= 0) {
                inisiKapat(m_strokeOrnekleri[durmaIndeksi].zamanS, durmaIndeksi);
            }
        }
        return;
    }

    // --- Boru alt referansa vardı ---
    if (m_durum == "INIYOR") {
        m_strokeOrnekleri.append(yeniOrnek);
        inisiKapat(zamanS);
        return;
    }
    // Devam eden iniş yoktu (ölçüme boru altta başlandı ya da stroke çoktan
    // kapanmıştı): burada TAMAMLANDI yazılmaz. Aksi halde hiç var olmayan bir
    // stroke "bitti" görünür ve durum bir daha YUKARIDA'ya dönene kadar
    // sonraki inişler işlenmezdi.
    if (m_durum != "TAMAMLANDI") {
        durumAyarla("BEKLENIYOR");
    }
}

// Boru durdu mu? Zamanda geriye gidilerek borunun kıpırdamadan durduğu kesintisiz
// bölümün nerede başladığı aranır: son örnekten geriye doğru yükseklik salınımı
// DURMA_TOLERANSI_MM'i aşana kadar ilerlenir. Bu bölüm DURMA_ONAYI_S saniyeyi
// dolduruyorsa boru durmuştur ve dönüş değeri durmanın BAŞLADIĞI örneğin
// indeksidir; durmadıysa -1 döner.
//
// Durmanın başladığı an ayrıca döndürülür ki stroke, onay süresinin sonunda
// değil gerçekten durduğu anda kapansın: aksi halde süreye ve iniş örneklerine
// her stroke'ta bir saniyelik hareketsiz kuyruk eklenirdi.
//
// Ölçüt ancak boru MIN_INIS_YOLU_MM kadar yol indikten ve iniş MIN_INIS_SURESI_S
// kadar sürdükten sonra işler: inişin baştaki hızlanma/yavaşlama dalgalanması
// "durdu" sayılmasın.
int Calculator::durmaBaslangicIndeksi(double zamanS) const
{
    if (m_strokeOrnekleri.isEmpty()) return -1;

    // 1) İniş erken evresindeyse hiç bakılmaz.
    const double inilenYolMm = m_inisBaslangicYuksekligiMm - m_strokeOrnekleri.last().yukseklikMm;
    if (inilenYolMm < MIN_INIS_YOLU_MM) return -1;
    if (zamanS - m_baslangicZamaniS < MIN_INIS_SURESI_S) return -1;

    // 2) Sondan geriye: salınım toleransı aşana kadar git, en geriye gidilen
    //    örnek durmanın başlangıcıdır.
    double enAzMm = m_strokeOrnekleri.last().yukseklikMm;
    double enCokMm = enAzMm;
    int durmaBasiIndeksi = m_strokeOrnekleri.size() - 1;
    for (int i = m_strokeOrnekleri.size() - 1; i >= 0; --i) {
        const double adayEnAzMm = std::min(enAzMm, m_strokeOrnekleri[i].yukseklikMm);
        const double adayEnCokMm = std::max(enCokMm, m_strokeOrnekleri[i].yukseklikMm);
        if (adayEnCokMm - adayEnAzMm >= DURMA_TOLERANSI_MM) break;
        enAzMm = adayEnAzMm;
        enCokMm = adayEnCokMm;
        durmaBasiIndeksi = i;
    }

    // 3) Hareketsiz bölüm onay süresini doldurdu mu?
    const double durmaSuresiS = zamanS - m_strokeOrnekleri[durmaBasiIndeksi].zamanS;
    if (durmaSuresiS < DURMA_ONAYI_S) return -1;

    return durmaBasiIndeksi;
}

// İniş bitti: bitiş anı işaretlenir, bundan sonraki SONRASI_PENCERE_S saniye
// P0r için toplanır. bitisIndeksi, inişin son örneğidir (-1 = elde olan son
// örnek); durma ölçütüyle kapanan stroke'larda onay süresi boyunca biriken
// hareketsiz örnekler böylece inişe değil P0r penceresine sayılır.
void Calculator::inisiKapat(double zamanS, int bitisIndeksi)
{
    m_altaVarisIndeksi = bitisIndeksi >= 0 ? bitisIndeksi : m_strokeOrnekleri.size() - 1;
    m_bitisYuksekligiMm = m_strokeOrnekleri[m_altaVarisIndeksi].yukseklikMm;
    m_bitisZamaniS = zamanS;
    m_bitisTarihi = QDateTime::currentDateTime();
    m_bitisSonrasiToplaniyor = true;
    durumAyarla("TAMAMLANDI");
}

// Boru üst eşiğin altına indi: üstte bekleyen örnekler ikiye ayrılır.
//   durgun örnekler  -> m_durgunOrnekler (P0l bunların ortalaması)
//   hareket başladıktan sonrakiler -> m_strokeOrnekleri
//
// Boru üst eşiğe inmeden önce kıpırdamaya ve basınç yükselmeye başlamıştır;
// bu örnekler P0l'e karışmamalı. Bu yüzden zamanda geriye gidilir:
//
//   zaman ──►  [ durgun (P0l) ][ HAREKET_PAYI_S ][ hareket ][ eşik geçildi ]
void Calculator::strokuBaslat(double zamanS)
{
    m_baslangicZamaniS = zamanS;
    m_strokeOrnekleri.clear();
    m_durgunOrnekler.clear();

    const QVector<Ornek> &ustte = m_ustteBekleyenOrnekler;

    // 1) Hareketin başladığı örnek: üstteki en yüksek noktadan
    //    DURGUN_TOLERANS_MM'den fazla aşağıda olan ilk örnek (sondan geriye bakılır).
    int hareketBaslangicIndeksi = ustte.size();
    if (!ustte.isEmpty()) {
        double enYuksekMm = ustte.first().yukseklikMm;
        for (const Ornek &ornek : ustte) enYuksekMm = std::max(enYuksekMm, ornek.yukseklikMm);
        while (hareketBaslangicIndeksi > 0
               && ustte[hareketBaslangicIndeksi - 1].yukseklikMm < enYuksekMm - DURGUN_TOLERANS_MM) {
            --hareketBaslangicIndeksi;
        }
    }
    const double hareketZamaniS = hareketBaslangicIndeksi < ustte.size()
        ? ustte[hareketBaslangicIndeksi].zamanS : zamanS;

    // 2) Hareketten önceki son HAREKET_PAYI_S saniye de P0l'e katılmaz
    //    (konum 5 mm düşmeden önce de boru kıpırdamaya başlar).
    int durgunBitisIndeksi = hareketBaslangicIndeksi;
    while (durgunBitisIndeksi > 0
           && hareketZamaniS - ustte[durgunBitisIndeksi - 1].zamanS < HAREKET_PAYI_S) {
        --durgunBitisIndeksi;
    }
    if (durgunBitisIndeksi == 0) durgunBitisIndeksi = hareketBaslangicIndeksi;   // pay için yeterli örnek yoksa

    // 3) Örnekleri dağıt. Hareketten en fazla ONCESI_PENCERE_S (+pay) öncesine kadar gidilir.
    for (int i = 0; i < hareketBaslangicIndeksi; ++i) {
        const bool pencereIcinde = hareketZamaniS - ustte[i].zamanS <= ONCESI_PENCERE_S + HAREKET_PAYI_S;
        if (!pencereIcinde) continue;
        if (i < durgunBitisIndeksi) m_durgunOrnekler.append(ustte[i]);
        else m_strokeOrnekleri.append(ustte[i]);
    }
    for (int i = hareketBaslangicIndeksi; i < ustte.size(); ++i) {
        m_strokeOrnekleri.append(ustte[i]);
    }
    m_ustteBekleyenOrnekler.clear();
}

// Stroke bitti (bitiş sonrası 2 s toplandı veya boru tekrar kaldırıldı):
// örnekler seçilir, formüller SliperModel'den çağrılır, sonuç yayınlanır.
void Calculator::strokuBitir()
{
    m_bitisSonrasiToplaniyor = false;
    const QVector<Ornek> &ornekler = m_strokeOrnekleri;
    if (m_altaVarisIndeksi < 1 || m_altaVarisIndeksi >= ornekler.size()) {
        m_strokeOrnekleri.clear();
        return;
    }
    // ornekler[0 .. sonInisIndeksi]    = iniş
    // ornekler[sonInisIndeksi+1 .. ]   = bitiş sonrası (boru altta duruyor)
    const int sonInisIndeksi = m_altaVarisIndeksi;

    // --- P0l: hareket öncesi durağan basınç ---
    QVector<double> durgunBasinclar;
    for (const Ornek &ornek : m_durgunOrnekler) durgunBasinclar.append(ornek.basincMbar);
    const double p0l = durgunBasinclar.isEmpty()
        ? ornekler.first().basincMbar
        : SliperModel::durgunBasincMbar(durgunBasinclar);

    // --- P0r: bitiş sonrası durağan basınç (ilk P0R_OTURMA_S saniye sönümlenme, atlanır) ---
    QVector<double> bitisSonrasiBasinclar;
    for (int i = sonInisIndeksi + 1; i < ornekler.size(); ++i) {
        if (ornekler[i].zamanS - m_bitisZamaniS >= P0R_OTURMA_S) {
            bitisSonrasiBasinclar.append(ornekler[i].basincMbar);
        }
    }
    if (bitisSonrasiBasinclar.isEmpty()) {   // stroke erken kapandıysa: ne varsa
        for (int i = sonInisIndeksi + 1; i < ornekler.size(); ++i) {
            bitisSonrasiBasinclar.append(ornekler[i].basincMbar);
        }
    }
    const double p0r = bitisSonrasiBasinclar.isEmpty()
        ? p0l
        : SliperModel::durgunBasincMbar(bitisSonrasiBasinclar);

    // --- İniş örnekleri: v, Q, Pmax, p ---
    QVector<double> inisZamanlari, inisYukseklikleri, inisBasinclari;
    for (int i = 0; i <= sonInisIndeksi; ++i) {
        inisZamanlari.append(ornekler[i].zamanS);
        inisYukseklikleri.append(ornekler[i].yukseklikMm);
        inisBasinclari.append(ornekler[i].basincMbar);
    }
    const double hizMs = SliperModel::strokeHiziMs(inisZamanlari, inisYukseklikleri);
    const double debiM3h = SliperModel::hizdanDebiM3h(hizMs);
    const double pMaks = SliperModel::filtreliMaksimum(inisBasinclari);
    const double basincMbar = SliperModel::strokeBasinciMbar(pMaks, p0l);

    const int inisOrnekSayisi = sonInisIndeksi + 1;
    const QString gecersizNedeni =
        SliperModel::strokeGecersizNedeni(inisOrnekSayisi, hizMs, basincMbar);

    // --- Ham veri (grafik ve Excel için): başlangıçtan 2 s önce - bitişten 2 s sonra ---
    // Zaman ekseni ilk örnekten başlar (0 s); konum ekrandaki gibi ham konumdur.
    const double ilkZamanS = m_durgunOrnekler.isEmpty()
        ? ornekler.first().zamanS
        : m_durgunOrnekler.first().zamanS;
    QVariantList zamanListesi, konumListesi, basincListesi;
    auto hamVeriyeEkle = [&](const Ornek &ornek) {
        zamanListesi.append(std::round((ornek.zamanS - ilkZamanS) * 1000.0) / 1000.0);
        konumListesi.append(std::round(yon() * ornek.yukseklikMm * 10.0) / 10.0);
        basincListesi.append(std::round(ornek.basincMbar * 100.0) / 100.0);
    };
    for (const Ornek &ornek : m_durgunOrnekler) hamVeriyeEkle(ornek);
    for (const Ornek &ornek : ornekler) hamVeriyeEkle(ornek);

    QVariantMap hamVeri;
    hamVeri["t"] = zamanListesi;
    hamVeri["x"] = konumListesi;
    hamVeri["p"] = basincListesi;
    hamVeri["tBaslangic"] = m_baslangicZamaniS - ilkZamanS;
    hamVeri["tBitis"] = m_bitisZamaniS - ilkZamanS;
    hamVeri["yon"] = yon();

    QVariantMap stroke;
    stroke["tarih"] = m_bitisTarihi.toString(Qt::ISODate);
    stroke["sure"] = m_bitisZamaniS - m_baslangicZamaniS;
    stroke["pMaks"] = pMaks;
    stroke["p0l"] = p0l;
    stroke["p0r"] = p0r;
    stroke["basinc"] = basincMbar;
    stroke["debi"] = debiM3h;
    stroke["hiz"] = hizMs;
    stroke["konum"] = yon() * ornekler[sonInisIndeksi].yukseklikMm;
    stroke["gecerli"] = gecersizNedeni.isEmpty();
    stroke["gecersizNedeni"] = gecersizNedeni;
    stroke["hamVeri"] = hamVeri;

    m_strokeOrnekleri.clear();
    m_durgunOrnekler.clear();
    m_altaVarisIndeksi = -1;

    m_sonStrokeGecerli = gecersizNedeni.isEmpty();
    emit sonStrokeGecerliChanged();
    m_strokeSayisi++;
    emit strokeSayisiChanged();
    stroke["no"] = m_strokeSayisi;
    m_sonStroke = stroke;
    emit sonStrokeChanged();

    emit strokeTamamlandi(stroke);
}

void Calculator::duraklat()
{
    if (m_duraklatildi) {
        return;
    }

    // Bitmiş ama sonrası toplanmakta olan stroke kaybolmasın.
    if (m_bitisSonrasiToplaniyor) {
        strokuBitir();
    }
    m_duraklatildi = true;
    // Duraklatma sırasında yarım kalan iniş analiz edilmez.
    m_strokeOrnekleri.clear();
    m_ustteBekleyenOrnekler.clear();
    m_durgunOrnekler.clear();
    // Örnekler atıldığı için inişin bitiş indeksi de geçersizdir; kalırsa
    // devam edildikten sonraki ilk stroke eski indeksle değerlendirilebilir.
    m_altaVarisIndeksi = -1;
    emit duraklatildiChanged();
}

void Calculator::devamEt()
{
    if (!m_duraklatildi) {
        return;
    }

    m_duraklatildi = false;
    // Durum "YUKARIDA" değil "BEKLENIYOR" olur: yeni stroke, boru üst eşiğin
    // içine tekrar girip YUKARIDA'ya geçtikten sonra başlar. Duraklatmada P0l
    // için gereken üst tampon atıldığından, boru üste alınmadan başlayan bir
    // iniş zaten ölçülemez.
    durumAyarla("BEKLENIYOR");
    emit duraklatildiChanged();
}

void Calculator::sifirla()
{
    m_strokeSayisi = 0;
    m_durum = "BEKLENIYOR";
    m_duraklatildi = false;
    m_sonStrokeGecerli = true;
    m_sonStroke.clear();
    m_strokeOrnekleri.clear();
    m_ustteBekleyenOrnekler.clear();
    m_durgunOrnekler.clear();
    m_altaVarisIndeksi = -1;
    m_inisBaslangicYuksekligiMm = 0.0;
    m_bitisYuksekligiMm = 0.0;
    m_bitisSonrasiToplaniyor = false;
    emit strokeSayisiChanged();
    emit durumChanged();
    emit duraklatildiChanged();
    emit sonStrokeGecerliChanged();
    emit sonStrokeChanged();
}

QVariantMap Calculator::boruHattiTahminHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                                double debiM3h, double boruCapiMm,
                                                double boruUzunluguM,
                                                double pompalamaYuksekligiM,
                                                double yogunlukKgM3,
                                                double hataPayiYuzde) const
{
    return SliperModel::basincTahmini(aKesisimMbar, bEgimMbarHm3, debiM3h, boruCapiMm,
                                      boruUzunluguM, pompalamaYuksekligiM, yogunlukKgM3,
                                      hataPayiYuzde);
}

QVariantList Calculator::tahminTablosuHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                               const QVariantMap &ayarlar) const
{
    return SliperModel::tahminTablosu(aKesisimMbar, bEgimMbarHm3, ayarlar);
}

QVariantMap Calculator::varsayilanTahminAyarlari() const
{
    return SliperModel::varsayilanTahminAyarlari();
}

double Calculator::schleibingerA(double kesisimA) const { return SliperModel::schleibingerA(kesisimA); }
double Calculator::schleibingerB(double egimB) const { return SliperModel::schleibingerB(egimB); }
double Calculator::sliperBoruCapiMm() const { return SliperModel::BORU_CAPI_M * 1000.0; }
double Calculator::sliperBoruUzunluguMm() const { return SliperModel::BORU_UZUNLUGU_M * 1000.0; }

QVariantList Calculator::hizEgrisiHesapla(const QVariantList &zamanS, const QVariantList &konumMm,
                                          double konumYonu) const
{
    QVector<double> zamanlar, konumlar;
    for (const QVariant &zaman : zamanS) zamanlar.append(zaman.toDouble());
    for (const QVariant &konum : konumMm) konumlar.append(konum.toDouble());

    QVariantList egri;
    for (double hiz : SliperModel::hizEgrisiMs(zamanlar, konumlar, konumYonu)) egri.append(hiz);
    return egri;
}

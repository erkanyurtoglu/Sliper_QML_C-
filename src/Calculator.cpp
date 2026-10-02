#include "Calculator.h"
#include "SliperModel.h"
#include <QtMath>
#include <algorithm>
#include <cmath>

// Stroke zamanlama sabitleri SliperModel bölüm 4'ten gelir
using SliperModel::KONUM_TOLERANSI_MM;
using SliperModel::UST_YAKALAMA_TOLERANSI_MM;
using SliperModel::DURGUN_TOLERANS_MM;
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
double Calculator::altEsik() const { return yon() * m_altKonumMm + KONUM_TOLERANSI_MM; }

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
        const bool boruTekrarKaldirildi = yukseklikMm > altEsik() + DURGUN_TOLERANS_MM;
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
        }
        if (m_durum == "YUKARIDA" || m_durum == "INIYOR") {
            m_strokeOrnekleri.append(yeniOrnek);
            durumAyarla("INIYOR");
        }
        return;
    }

    // --- Boru alta vardı ---
    if (m_durum == "INIYOR") {
        m_strokeOrnekleri.append(yeniOrnek);
        m_altaVarisIndeksi = m_strokeOrnekleri.size() - 1;
        m_bitisZamaniS = zamanS;
        m_bitisTarihi = QDateTime::currentDateTime();
        m_bitisSonrasiToplaniyor = true;
    }
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
    emit duraklatildiChanged();
}

void Calculator::devamEt()
{
    if (!m_duraklatildi) {
        return;
    }

    m_duraklatildi = false;
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

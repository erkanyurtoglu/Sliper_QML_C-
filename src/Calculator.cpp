#include "Calculator.h"
#include "SliperModel.h"
#include <QtMath>
#include <algorithm>
#include <cmath>

using SliperModel::KONUM_TOLERANSI_MM;
using SliperModel::UST_YAKALAMA_TOLERANSI_MM;
using SliperModel::ALT_YAKALAMA_TOLERANSI_MM;
using SliperModel::DURGUN_TOLERANS_MM;
using SliperModel::DURMA_TOLERANSI_MM;
using SliperModel::INISTE_KALDIRMA_ESIGI_MM;
using SliperModel::DURMA_ONAYI_S;
using SliperModel::MIN_INIS_YOLU_MM;
using SliperModel::MIN_INIS_SURESI_S;
using SliperModel::KALDIRMA_ESIGI_MM;
using SliperModel::ONCESI_PENCERE_S;
using SliperModel::SONRASI_PENCERE_S;
using SliperModel::HAREKET_PAYI_S;
using SliperModel::P0R_OTURMA_S;
using SliperModel::UST_TAMPON_S;
using SliperModel::HAZIRLAMA_SURESI_S;
using SliperModel::HAZIRLAMA_BASINC_TOLERANSI_MBAR;

Calculator::Calculator(QObject *parent)
    : QObject(parent)
{
}

QString Calculator::durum() const { return m_durum; }
int Calculator::strokeSayisi() const { return m_strokeSayisi; }
bool Calculator::duraklatildi() const { return m_duraklatildi; }
bool Calculator::hazirlaniyor() const { return m_hazirlaniyor; }
bool Calculator::hazir() const { return m_hazir; }
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

void Calculator::konumGuncelle(double zamanS, double konumMm, double basincMbar)
{
    if (m_duraklatildi) {
        return;
    }

    const double yukseklikMm = yon() * konumMm;
    const Ornek yeniOrnek { zamanS, yukseklikMm, basincMbar };

    if (m_hazirlaniyor) {
        hazirlamaOrnegiIsle(yeniOrnek);
    }

    if (m_bitisSonrasiToplaniyor) {
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

    if (m_durum == "INIYOR" && kaldirilanInisiKapat(yukseklikMm)) {
        strokuBitir();
    }

    if (yukseklikMm > ustEsik()) {
        m_strokeOrnekleri.clear();
        m_ustteBekleyenOrnekler.append(yeniOrnek);
        while (!m_ustteBekleyenOrnekler.isEmpty()
               && zamanS - m_ustteBekleyenOrnekler.first().zamanS > UST_TAMPON_S) {
            m_ustteBekleyenOrnekler.removeFirst();
        }
        durumAyarla("YUKARIDA");
        return;
    }

    if (yukseklikMm > altEsik()) {
        if (m_durum == "YUKARIDA") {
            if (!m_hazir) {
                return;
            }
            strokuBaslat(zamanS);
            m_inisBaslangicYuksekligiMm = yukseklikMm;
        }
        if (m_durum == "YUKARIDA" || m_durum == "INIYOR") {
            m_strokeOrnekleri.append(yeniOrnek);
            durumAyarla("INIYOR");
            const int durmaIndeksi = durmaBaslangicIndeksi(zamanS);
            if (durmaIndeksi >= 0) {
                inisiKapat(m_strokeOrnekleri[durmaIndeksi].zamanS, durmaIndeksi);
            }
        }
        return;
    }

    if (m_durum == "INIYOR") {
        m_strokeOrnekleri.append(yeniOrnek);
        inisiKapat(zamanS);
        return;
    }
    if (m_durum != "TAMAMLANDI") {
        durumAyarla("BEKLENIYOR");
    }
}

int Calculator::durmaBaslangicIndeksi(double zamanS) const
{
    if (m_strokeOrnekleri.isEmpty()) return -1;

    const double inilenYolMm = m_inisBaslangicYuksekligiMm - m_strokeOrnekleri.last().yukseklikMm;
    if (inilenYolMm < MIN_INIS_YOLU_MM) return -1;
    if (zamanS - m_baslangicZamaniS < MIN_INIS_SURESI_S) return -1;

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

    const double durmaSuresiS = zamanS - m_strokeOrnekleri[durmaBasiIndeksi].zamanS;
    if (durmaSuresiS < DURMA_ONAYI_S) return -1;

    return durmaBasiIndeksi;
}

bool Calculator::kaldirilanInisiKapat(double yeniYukseklikMm)
{
    if (m_strokeOrnekleri.isEmpty()) return false;

    int enAltIndeks = 0;
    for (int i = 1; i < m_strokeOrnekleri.size(); ++i) {
        if (m_strokeOrnekleri[i].yukseklikMm < m_strokeOrnekleri[enAltIndeks].yukseklikMm) {
            enAltIndeks = i;
        }
    }
    const double enAltYukseklikMm = m_strokeOrnekleri[enAltIndeks].yukseklikMm;

    const bool boruKaldirildi = yeniYukseklikMm > enAltYukseklikMm + INISTE_KALDIRMA_ESIGI_MM;
    if (!boruKaldirildi) return false;
    if (m_inisBaslangicYuksekligiMm - enAltYukseklikMm < MIN_INIS_YOLU_MM) return false;

    const double durgunUstSiniriMm = enAltYukseklikMm + DURMA_TOLERANSI_MM;
    int altaVarisIndeksi = 0;
    while (altaVarisIndeksi < enAltIndeks
           && m_strokeOrnekleri[altaVarisIndeksi].yukseklikMm > durgunUstSiniriMm) {
        ++altaVarisIndeksi;
    }
    int sonDurgunIndeks = m_strokeOrnekleri.size() - 1;
    while (sonDurgunIndeks > enAltIndeks
           && m_strokeOrnekleri[sonDurgunIndeks].yukseklikMm > durgunUstSiniriMm) {
        --sonDurgunIndeks;
    }
    m_strokeOrnekleri.resize(sonDurgunIndeks + 1);

    inisiKapat(m_strokeOrnekleri[altaVarisIndeksi].zamanS, altaVarisIndeksi);
    return true;
}

void Calculator::inisiKapat(double zamanS, int bitisIndeksi)
{
    m_altaVarisIndeksi = bitisIndeksi >= 0 ? bitisIndeksi : m_strokeOrnekleri.size() - 1;
    m_bitisYuksekligiMm = m_strokeOrnekleri[m_altaVarisIndeksi].yukseklikMm;
    m_bitisZamaniS = zamanS;
    m_bitisTarihi = QDateTime::currentDateTime();
    m_bitisSonrasiToplaniyor = true;
    durumAyarla("TAMAMLANDI");
}

void Calculator::strokuBaslat(double zamanS)
{
    m_baslangicZamaniS = zamanS;
    m_strokeOrnekleri.clear();
    m_durgunOrnekler.clear();
    m_strokeP0lMbar = m_hazirlananP0lMbar;
    hazirligiSifirla();

    const QVector<Ornek> &ustte = m_ustteBekleyenOrnekler;

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

    int durgunBitisIndeksi = hareketBaslangicIndeksi;
    while (durgunBitisIndeksi > 0
           && hareketZamaniS - ustte[durgunBitisIndeksi - 1].zamanS < HAREKET_PAYI_S) {
        --durgunBitisIndeksi;
    }
    if (durgunBitisIndeksi == 0) durgunBitisIndeksi = hareketBaslangicIndeksi;

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

void Calculator::strokuBitir()
{
    m_bitisSonrasiToplaniyor = false;
    const QVector<Ornek> &ornekler = m_strokeOrnekleri;
    if (m_altaVarisIndeksi < 1 || m_altaVarisIndeksi >= ornekler.size()) {
        m_strokeOrnekleri.clear();
        return;
    }
    const int sonInisIndeksi = m_altaVarisIndeksi;

    const double p0l = m_strokeP0lMbar;

    QVector<double> bitisSonrasiBasinclar;
    for (int i = sonInisIndeksi + 1; i < ornekler.size(); ++i) {
        if (ornekler[i].zamanS - m_bitisZamaniS >= P0R_OTURMA_S) {
            bitisSonrasiBasinclar.append(ornekler[i].basincMbar);
        }
    }
    if (bitisSonrasiBasinclar.isEmpty()) {
        for (int i = sonInisIndeksi + 1; i < ornekler.size(); ++i) {
            bitisSonrasiBasinclar.append(ornekler[i].basincMbar);
        }
    }
    const double p0r = bitisSonrasiBasinclar.isEmpty()
        ? p0l
        : SliperModel::durgunBasincMbar(bitisSonrasiBasinclar);

    QVector<double> inisZamanlari, inisYukseklikleri, inisBasinclari;
    for (int i = 0; i <= sonInisIndeksi; ++i) {
        inisZamanlari.append(ornekler[i].zamanS);
        inisYukseklikleri.append(ornekler[i].yukseklikMm);
        inisBasinclari.append(ornekler[i].basincMbar);
    }
    const double hizMs = SliperModel::strokeHiziMs(inisZamanlari, inisYukseklikleri);
    const double debiM3h = SliperModel::hizdanDebiM3h(hizMs);
    const double pMaks = SliperModel::filtreliMaksimum(inisZamanlari, inisBasinclari);
    const double basincMbar = SliperModel::strokeBasinciMbar(pMaks, p0l);

    const int inisOrnekSayisi = sonInisIndeksi + 1;
    const QString gecersizNedeni = SliperModel::strokeGecersizNedeni(
        inisOrnekSayisi, SliperModel::enBuyukOrnekAraligiS(inisZamanlari), hizMs, basincMbar);

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

void Calculator::hazirla()
{
    if (m_duraklatildi || m_durum == "INIYOR" || m_bitisSonrasiToplaniyor) {
        return;
    }
    m_hazir = false;
    m_hazirlamaOrnekleri.clear();
    m_hazirlaniyor = true;
    emit hazirlikChanged();
}

void Calculator::hazirlamaOrnegiIsle(const Ornek &yeniOrnek)
{
    if (yeniOrnek.yukseklikMm <= ustEsik()) {
        hazirlamayiIptalEt();
        return;
    }

    m_hazirlamaOrnekleri.append(yeniOrnek);
    const double pencereSuresiS = yeniOrnek.zamanS - m_hazirlamaOrnekleri.first().zamanS;
    if (pencereSuresiS < HAZIRLAMA_SURESI_S) {
        return;
    }

    double enDusukBasincMbar = yeniOrnek.basincMbar;
    double enYuksekBasincMbar = yeniOrnek.basincMbar;
    double enDusukYukseklikMm = yeniOrnek.yukseklikMm;
    double enYuksekYukseklikMm = yeniOrnek.yukseklikMm;
    QVector<double> pencereBasinclari;
    for (const Ornek &ornek : m_hazirlamaOrnekleri) {
        enDusukBasincMbar = std::min(enDusukBasincMbar, ornek.basincMbar);
        enYuksekBasincMbar = std::max(enYuksekBasincMbar, ornek.basincMbar);
        enDusukYukseklikMm = std::min(enDusukYukseklikMm, ornek.yukseklikMm);
        enYuksekYukseklikMm = std::max(enYuksekYukseklikMm, ornek.yukseklikMm);
        pencereBasinclari.append(ornek.basincMbar);
    }

    const bool basincSakin = enYuksekBasincMbar - enDusukBasincMbar <= HAZIRLAMA_BASINC_TOLERANSI_MBAR;
    const bool boruSakin = enYuksekYukseklikMm - enDusukYukseklikMm <= DURGUN_TOLERANS_MM;
    if (!basincSakin || !boruSakin) {
        m_hazirlamaOrnekleri.removeFirst();
        return;
    }

    m_hazirlananP0lMbar = SliperModel::durgunBasincMbar(pencereBasinclari);
    m_hazirlamaOrnekleri.clear();
    m_hazirlaniyor = false;
    m_hazir = true;
    emit hazirlikChanged();
}

void Calculator::hazirlamayiIptalEt()
{
    m_hazirlamaOrnekleri.clear();
    if (m_hazirlaniyor) {
        m_hazirlaniyor = false;
        emit hazirlikChanged();
    }
}

void Calculator::hazirligiSifirla()
{
    const bool degisti = m_hazirlaniyor || m_hazir;
    m_hazirlaniyor = false;
    m_hazir = false;
    m_hazirlamaOrnekleri.clear();
    if (degisti) {
        emit hazirlikChanged();
    }
}

void Calculator::duraklat()
{
    if (m_duraklatildi) {
        return;
    }
    hazirligiSifirla();

    if (m_bitisSonrasiToplaniyor) {
        strokuBitir();
    }
    m_duraklatildi = true;
    m_strokeOrnekleri.clear();
    m_ustteBekleyenOrnekler.clear();
    m_durgunOrnekler.clear();
    m_altaVarisIndeksi = -1;
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
    m_inisBaslangicYuksekligiMm = 0.0;
    m_bitisYuksekligiMm = 0.0;
    m_bitisSonrasiToplaniyor = false;
    hazirligiSifirla();
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

QString Calculator::tahminGuvenilmezNedeni(double kesisimA, double egimB, double r2) const
{
    return SliperModel::tahminGuvenilmezNedeni(kesisimA, egimB, r2);
}

bool Calculator::tahminKarariVerilemez(const QString &guvenilmezNedeni) const
{
    return SliperModel::tahminKarariVerilemez(guvenilmezNedeni);
}

QString Calculator::pompaSorunuNedeni(const QVariantMap &tahminSatiri, double pompaMaksBar) const
{
    return SliperModel::pompaSorunuNedeni(tahminSatiri, pompaMaksBar);
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

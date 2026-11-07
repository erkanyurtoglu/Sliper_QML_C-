#include "SliperModel.h"
#include <QMap>
#include <QSet>
#include <QtMath>
#include <algorithm>
#include <cmath>
#include <limits>

namespace SliperModel {
namespace {

struct Cizgi {
    bool hesaplandi = false;
    double egim = 0.0;
    double baslangic = 0.0;
    double uyumR2 = 0.0;
    double ortalamaX = 0.0;
};

Cizgi enUygunCizgi(const QVector<double> &xDegerleri, const QVector<double> &yDegerleri)
{
    Cizgi cizgi;
    const int noktaSayisi = std::min(xDegerleri.size(), yDegerleri.size());
    if (noktaSayisi < 2) return cizgi;

    double xToplami = 0.0, yToplami = 0.0;
    for (int i = 0; i < noktaSayisi; ++i) {
        xToplami += xDegerleri[i];
        yToplami += yDegerleri[i];
    }
    const double ortalamaX = xToplami / noktaSayisi;
    const double ortalamaY = yToplami / noktaSayisi;

    double birlikteSapmaToplami = 0.0;
    double xSapmaKareToplami = 0.0;
    for (int i = 0; i < noktaSayisi; ++i) {
        const double xSapmasi = xDegerleri[i] - ortalamaX;
        const double ySapmasi = yDegerleri[i] - ortalamaY;
        birlikteSapmaToplami += xSapmasi * ySapmasi;
        xSapmaKareToplami += xSapmasi * xSapmasi;
    }
    if (xSapmaKareToplami <= 0.0) return cizgi;

    cizgi.egim = birlikteSapmaToplami / xSapmaKareToplami;
    cizgi.baslangic = ortalamaY - cizgi.egim * ortalamaX;
    cizgi.ortalamaX = ortalamaX;

    double cizgidenKalanKareToplami = 0.0;
    double toplamSapmaKareToplami = 0.0;
    for (int i = 0; i < noktaSayisi; ++i) {
        const double cizgininDedigi = cizgi.baslangic + cizgi.egim * xDegerleri[i];
        const double cizgidenFark = yDegerleri[i] - cizgininDedigi;
        const double ortalamadanFark = yDegerleri[i] - ortalamaY;
        cizgidenKalanKareToplami += cizgidenFark * cizgidenFark;
        toplamSapmaKareToplami += ortalamadanFark * ortalamadanFark;
    }
    cizgi.uyumR2 = toplamSapmaKareToplami > 0.0
        ? 1.0 - cizgidenKalanKareToplami / toplamSapmaKareToplami
        : 0.0;
    cizgi.hesaplandi = true;
    return cizgi;
}

}

double kalibrasyonTablosundanOku(const QVector<double> &hamNoktalar,
                                 const QVector<double> &gercekNoktalar,
                                 double hamDeger)
{
    const int noktaSayisi = std::min(hamNoktalar.size(), gercekNoktalar.size());
    if (noktaSayisi == 0) return 0.0;
    if (noktaSayisi == 1) return gercekNoktalar[0];

    int solNokta;
    if (hamDeger <= hamNoktalar[0]) {
        solNokta = 0;
    } else if (hamDeger >= hamNoktalar[noktaSayisi - 1]) {
        solNokta = noktaSayisi - 2;
    } else {
        for (solNokta = 0; solNokta < noktaSayisi - 1; ++solNokta) {
            if (hamDeger <= hamNoktalar[solNokta + 1]) break;
        }
    }
    const int sagNokta = solNokta + 1;

    const double solHam = hamNoktalar[solNokta];
    const double sagHam = hamNoktalar[sagNokta];
    const double solGercek = gercekNoktalar[solNokta];
    const double sagGercek = gercekNoktalar[sagNokta];

    if (sagHam == solHam) return solGercek;
    const double hamBirimBasinaGercek = (sagGercek - solGercek) / (sagHam - solHam);
    return solGercek + (hamDeger - solHam) * hamBirimBasinaGercek;
}

double strokeHiziMs(const QVector<double> &zamanS, const QVector<double> &yukseklikMm)
{
    const int ornekSayisi = std::min(zamanS.size(), yukseklikMm.size());
    if (ornekSayisi < 2) return 0.0;

    const double baslangicYuksekligi = yukseklikMm.first();
    const double bitisYuksekligi = yukseklikMm[ornekSayisi - 1];
    const double toplamYolMm = baslangicYuksekligi - bitisYuksekligi;

    QVector<double> ortaZamanlar, ortaYukseklikler;
    for (int i = 0; i < ornekSayisi; ++i) {
        const double alinanYolOrani = toplamYolMm > 0.0
            ? (baslangicYuksekligi - yukseklikMm[i]) / toplamYolMm
            : 0.0;
        if (alinanYolOrani >= HIZ_UYUM_ALT && alinanYolOrani <= HIZ_UYUM_UST) {
            ortaZamanlar.append(zamanS[i]);
            ortaYukseklikler.append(yukseklikMm[i]);
        }
    }

    if (ortaZamanlar.size() >= 3) {
        const Cizgi cizgi = enUygunCizgi(ortaZamanlar, ortaYukseklikler);
        if (cizgi.hesaplandi) {
            const double yukseklikKaybiMmSaniye = -cizgi.egim;
            return yukseklikKaybiMmSaniye / 1000.0;
        }
    }

    const double toplamSureS = zamanS[ornekSayisi - 1] - zamanS.first();
    return toplamSureS > 0.0 ? (toplamYolMm / 1000.0) / toplamSureS : 0.0;
}

double filtreliMaksimum(const QVector<double> &zamanS, const QVector<double> &basincMbar,
                        double pencereS)
{
    const int ornekSayisi = std::min(zamanS.size(), basincMbar.size());
    if (ornekSayisi == 0) return 0.0;

    const double yariPencereS = pencereS / 2.0;
    double enBuyukOrtalama = -1e300;
    for (int merkez = 0; merkez < ornekSayisi; ++merkez) {
        const double merkezZamaniS = zamanS[merkez];

        int pencereBasi = merkez;
        while (pencereBasi > 0 && merkezZamaniS - zamanS[pencereBasi - 1] <= yariPencereS) {
            --pencereBasi;
        }
        int pencereSonu = merkez;
        while (pencereSonu < ornekSayisi - 1 && zamanS[pencereSonu + 1] - merkezZamaniS <= yariPencereS) {
            ++pencereSonu;
        }

        while (pencereSonu - pencereBasi + 1 < PMAKS_MIN_ORNEK
               && (pencereBasi > 0 || pencereSonu < ornekSayisi - 1)) {
            const bool solaGenislet = pencereBasi > 0
                && (pencereSonu == ornekSayisi - 1
                    || merkezZamaniS - zamanS[pencereBasi - 1] <= zamanS[pencereSonu + 1] - merkezZamaniS);
            if (solaGenislet) --pencereBasi;
            else ++pencereSonu;
        }

        double penceredekiToplam = 0.0;
        for (int i = pencereBasi; i <= pencereSonu; ++i) {
            penceredekiToplam += basincMbar[i];
        }
        const double penceredekiOrtalama = penceredekiToplam / (pencereSonu - pencereBasi + 1);

        enBuyukOrtalama = std::max(enBuyukOrtalama, penceredekiOrtalama);
    }
    return enBuyukOrtalama;
}

double durgunBasincMbar(const QVector<double> &basincMbar)
{
    if (basincMbar.isEmpty()) return 0.0;

    QVector<double> siraliBasinclar = basincMbar;
    std::sort(siraliBasinclar.begin(), siraliBasinclar.end());

    const int ornekSayisi = siraliBasinclar.size();
    const int ortaIndeks = ornekSayisi / 2;
    if (ornekSayisi % 2 == 1) return siraliBasinclar[ortaIndeks];
    return (siraliBasinclar[ortaIndeks - 1] + siraliBasinclar[ortaIndeks]) / 2.0;
}

double enBuyukOrnekAraligiS(const QVector<double> &zamanS)
{
    double enBuyukAralikS = 0.0;
    for (int i = 1; i < zamanS.size(); ++i) {
        enBuyukAralikS = std::max(enBuyukAralikS, zamanS[i] - zamanS[i - 1]);
    }
    return enBuyukAralikS;
}

QString strokeGecersizNedeni(int inisOrnekSayisi, double enBuyukOrnekAraligiS, double hizMs,
                             double basincMbar)
{
    if (enBuyukOrnekAraligiS > MAKS_ORNEK_ARALIGI_S) return "kesinti";
    if (inisOrnekSayisi < MIN_STROKE_ORNEGI) return "ornek";
    if (hizMs <= 0.0) return "hiz";
    if (basincMbar <= 0.0) return "basinc";
    return QString();
}

double takilmaOrani(const QVector<double> &zamanS, const QVector<double> &konumMm)
{
    const double hesaplanamadi = std::numeric_limits<double>::quiet_NaN();
    const int ornekSayisi = std::min(zamanS.size(), konumMm.size());
    if (ornekSayisi < 6) return hesaplanamadi;

    const double toplamYolMm = konumMm[ornekSayisi - 1] - konumMm.first();
    if (std::abs(toplamYolMm) < 1.0) return hesaplanamadi;

    QVector<double> araOrtaYolOranlari, araHizlari;
    for (int i = 1; i < ornekSayisi; ++i) {
        const double sureS = zamanS[i] - zamanS[i - 1];
        if (sureS <= 0.0) continue;
        const double oncekiOran = (konumMm[i - 1] - konumMm.first()) / toplamYolMm;
        const double sonrakiOran = (konumMm[i] - konumMm.first()) / toplamYolMm;
        araOrtaYolOranlari.append((oncekiOran + sonrakiOran) / 2.0);
        araHizlari.append((sonrakiOran - oncekiOran) / sureS);
    }

    QVector<double> pozitifHizlar;
    for (double hiz : araHizlari) {
        if (hiz > 0.0) pozitifHizlar.append(hiz);
    }
    if (pozitifHizlar.isEmpty()) return hesaplanamadi;
    std::sort(pozitifHizlar.begin(), pozitifHizlar.end());
    const int ortaIndeks = pozitifHizlar.size() / 2;
    const double tipikHiz = pozitifHizlar.size() % 2 == 1
        ? pozitifHizlar[ortaIndeks]
        : (pozitifHizlar[ortaIndeks - 1] + pozitifHizlar[ortaIndeks]) / 2.0;

    double enDusukHiz = std::numeric_limits<double>::max();
    for (int i = 0; i < araHizlari.size(); ++i) {
        if (araOrtaYolOranlari[i] >= TAKILMA_YOL_ALT && araOrtaYolOranlari[i] <= TAKILMA_YOL_UST) {
            enDusukHiz = std::min(enDusukHiz, araHizlari[i]);
        }
    }
    if (enDusukHiz == std::numeric_limits<double>::max()) return hesaplanamadi;
    return enDusukHiz / tipikHiz;
}

QVector<int> otomatikElenecekler(const QVector<qint64> &agirlikAnahtarlari,
                                 const QVector<double> &takilmaOranlari)
{
    const int strokeSayisi = std::min(agirlikAnahtarlari.size(), takilmaOranlari.size());

    QVector<int> adaylar;
    for (int i = 0; i < strokeSayisi; ++i) {
        if (!std::isnan(takilmaOranlari[i]) && takilmaOranlari[i] < TAKILMA_ESIGI) adaylar.append(i);
    }
    std::sort(adaylar.begin(), adaylar.end(), [&](int sol, int sag) {
        return takilmaOranlari[sol] < takilmaOranlari[sag];
    });

    const int enFazlaElenecek = std::max(1, strokeSayisi * MAKS_OTOMATIK_ELEME_YUZDE / 100);
    QVector<int> elenecekler;
    QSet<qint64> elemeYapilanAgirliklar;
    for (int aday : adaylar) {
        if (elenecekler.size() >= enFazlaElenecek) break;
        if (elemeYapilanAgirliklar.contains(agirlikAnahtarlari[aday])) continue;
        elemeYapilanAgirliklar.insert(agirlikAnahtarlari[aday]);
        elenecekler.append(aday);
    }
    return elenecekler;
}

DogruUyumu pqDogrusu(const QVector<double> &debiM3h, const QVector<double> &basincMbar,
                     const QVector<qint64> &agirlikAnahtarlari)
{
    DogruUyumu sonuc;
    const int noktaSayisi = std::min(debiM3h.size(), basincMbar.size());
    sonuc.n = noktaSayisi;
    if (noktaSayisi < 2) return sonuc;

    sonuc.qMin = *std::min_element(debiM3h.begin(), debiM3h.begin() + noktaSayisi);
    sonuc.qMaks = *std::max_element(debiM3h.begin(), debiM3h.begin() + noktaSayisi);

    const Cizgi cizgi = enUygunCizgi(debiM3h, basincMbar);
    double debiToplami = 0.0;
    for (int i = 0; i < noktaSayisi; ++i) debiToplami += debiM3h[i];
    sonuc.qOrt = debiToplami / noktaSayisi;

    if (cizgi.hesaplandi) {
        sonuc.kesisimA = cizgi.baslangic;
        sonuc.egimB = cizgi.egim;
        sonuc.r2 = cizgi.uyumR2;

        QMap<qint64, double> agirlikBasinaDebiToplami;
        QMap<qint64, double> agirlikBasinaBasincToplami;
        QMap<qint64, int> agirlikBasinaNoktaSayisi;
        const int gruplananNoktaSayisi = std::min<int>(noktaSayisi, agirlikAnahtarlari.size());
        for (int i = 0; i < gruplananNoktaSayisi; ++i) {
            agirlikBasinaDebiToplami[agirlikAnahtarlari[i]] += debiM3h[i];
            agirlikBasinaBasincToplami[agirlikAnahtarlari[i]] += basincMbar[i];
            agirlikBasinaNoktaSayisi[agirlikAnahtarlari[i]] += 1;
        }
        QVector<double> ortalamaDebiler;
        QVector<double> ortalamaBasinclar;
        for (auto it = agirlikBasinaNoktaSayisi.constBegin(); it != agirlikBasinaNoktaSayisi.constEnd(); ++it) {
            ortalamaDebiler.append(agirlikBasinaDebiToplami.value(it.key()) / it.value());
            ortalamaBasinclar.append(agirlikBasinaBasincToplami.value(it.key()) / it.value());
        }
        const Cizgi ortalamaCizgisi = enUygunCizgi(ortalamaDebiler, ortalamaBasinclar);
        if (ortalamaCizgisi.hesaplandi && ortalamaDebiler.size() >= MIN_ORTALAMA_R2_AGIRLIK_SAYISI) {
            sonuc.r2 = ortalamaCizgisi.uyumR2;
        }
    } else {
        double basincToplami = 0.0;
        for (int i = 0; i < noktaSayisi; ++i) basincToplami += basincMbar[i];
        sonuc.kesisimA = basincToplami / noktaSayisi;
    }
    return sonuc;
}

double agirlikTepkiOrani(const QHash<qint64, double> &agirlikBasinaOrtalamaPmax)
{
    if (agirlikBasinaOrtalamaPmax.size() < 2) return std::numeric_limits<double>::quiet_NaN();

    qint64 enHafifAnahtar = agirlikBasinaOrtalamaPmax.constBegin().key();
    qint64 enAgirAnahtar = enHafifAnahtar;
    for (auto it = agirlikBasinaOrtalamaPmax.constBegin();
         it != agirlikBasinaOrtalamaPmax.constEnd(); ++it) {
        enHafifAnahtar = std::min(enHafifAnahtar, it.key());
        enAgirAnahtar = std::max(enAgirAnahtar, it.key());
    }

    const double agirlikFarkiKg = (enAgirAnahtar - enHafifAnahtar) / 10.0;
    if (agirlikFarkiKg <= 0.0) return std::numeric_limits<double>::quiet_NaN();

    const double beklenenArtisMbar = agirliktanBasincMbar(agirlikFarkiKg);
    const double olculenArtisMbar = agirlikBasinaOrtalamaPmax.value(enAgirAnahtar)
                                    - agirlikBasinaOrtalamaPmax.value(enHafifAnahtar);
    return olculenArtisMbar / beklenenArtisMbar;
}

QStringList olcumUyarilari(const DogruUyumu &pqCizgisi,
                           const QHash<qint64, int> &agirlikBasinaStrokeSayisi,
                           const QHash<qint64, double> &agirlikBasinaOrtalamaPmax,
                           int toplamStrokeSayisi, int gecersizStrokeSayisi)
{
    QStringList uyarilar;
    if (pqCizgisi.n < MIN_STROKE_SAYISI) uyarilar << "azStroke";
    if (pqCizgisi.egimB < 0.0) uyarilar << "egimNegatif";
    if (pqCizgisi.kesisimA < 0.0) uyarilar << "kesisimNegatif";
    if (pqCizgisi.r2 < MIN_R2) uyarilar << "dusukR2";

    const double debiAraligi = pqCizgisi.qMaks - pqCizgisi.qMin;
    if (pqCizgisi.qOrt > 0.0 && debiAraligi < MIN_DEBI_ARALIGI_ORANI * pqCizgisi.qOrt) {
        uyarilar << "darDebiAraligi";
    }

    const double tepkiOrani = agirlikTepkiOrani(agirlikBasinaOrtalamaPmax);
    if (!std::isnan(tepkiOrani) && tepkiOrani < MIN_AGIRLIK_TEPKI_ORANI) {
        uyarilar.prepend("agirlikTepkisiZayif");
    }

    if (agirlikBasinaStrokeSayisi.size() < 2) uyarilar << "tekYuk";
    for (const int strokeSayisi : agirlikBasinaStrokeSayisi) {
        if (strokeSayisi < MIN_YUK_BASINA_STROKE) { uyarilar << "yukBasinaAzStroke"; break; }
    }

    if (toplamStrokeSayisi > 0
        && gecersizStrokeSayisi * 100 > toplamStrokeSayisi * MAKS_GECERSIZ_YUZDE) {
        uyarilar << "cokGecersiz";
    }
    return uyarilar;
}

QVariantMap varsayilanTahminAyarlari()
{
    QVariantMap ayar;
    ayar["cap"] = 125.0;
    ayar["hatUzunlugu"] = 100.0;
    ayar["yukseklik"] = 0.0;
    ayar["dirsek90"] = 0.0;
    ayar["dirsek45"] = 0.0;
    ayar["hedefDebi"] = 30.0;
    ayar["pompaMaks"] = 0.0;
    ayar["yogunluk"] = 2400.0;
    ayar["hataPayi"] = 10.0;
    return ayar;
}

QVariantMap tahminAyarlariniTamamla(const QVariantMap &ayarlar)
{
    QVariantMap tasinanAyarlar = ayarlar;
    if (!tasinanAyarlar.contains("hatUzunlugu")) {
        if (tasinanAyarlar.contains("yatayUzunluk")) {
            tasinanAyarlar["hatUzunlugu"] = tasinanAyarlar.value("yatayUzunluk").toDouble()
                                            + std::abs(tasinanAyarlar.value("yukseklik").toDouble());
        } else if (tasinanAyarlar.contains("l4")) {
            tasinanAyarlar["hatUzunlugu"] = tasinanAyarlar.value("l4");
        }
    }
    if (!tasinanAyarlar.contains("hedefDebi") && tasinanAyarlar.contains("q2")) {
        tasinanAyarlar["hedefDebi"] = tasinanAyarlar.value("q2");
    }

    QVariantMap tamAyarlar = varsayilanTahminAyarlari();
    for (auto alan = tasinanAyarlar.constBegin(); alan != tasinanAyarlar.constEnd(); ++alan) {
        if (!tamAyarlar.contains(alan.key()) || !alan.value().isValid()) continue;
        bool sayiMi = false;
        const double deger = alan.value().toDouble(&sayiMi);
        if (sayiMi) tamAyarlar[alan.key()] = deger;
    }
    return tamAyarlar;
}

double hesapUzunluguM(const QVariantMap &ayarlar)
{
    const QVariantMap ayar = tahminAyarlariniTamamla(ayarlar);
    return ayar["hatUzunlugu"].toDouble()
           + ayar["dirsek90"].toDouble() * DIRSEK_90_ESDEGER_M
           + ayar["dirsek45"].toDouble() * DIRSEK_45_ESDEGER_M;
}

QVariantMap basincTahmini(double kesisimA, double egimB, double debiM3h, double capMm,
                          double uzunlukM, double yukseklikM, double yogunlukKgM3,
                          double hataPayiYuzde)
{
    QVariantMap sonuc;
    sonuc["gecerliGiris"] = false;
    sonuc["basincBar"] = 0.0;
    sonuc["altSinirBar"] = 0.0;
    sonuc["ustSinirBar"] = 0.0;

    if (capMm <= 0.0 || uzunlukM < 0.0 || debiM3h < 0.0 || yogunlukKgM3 < 0.0) {
        return sonuc;
    }

    const double aMbar = schleibingerA(kesisimA);
    const double bMbarHm = schleibingerB(egimB);
    const double hatCapiM = capMm / 1000.0;
    const double hatUzunluguM = uzunlukM;
    const double hatCapiKupu = hatCapiM * hatCapiM * hatCapiM;

    const double akmaPayiMbar = 4.0 * hatUzunluguM / hatCapiM * aMbar;
    const double hizPayiMbar = 16.0 * hatUzunluguM * debiM3h / (M_PI * hatCapiKupu) * bMbarHm;
    const double yukseklikPayiMbar = yogunlukKgM3 * YERCEKIMI * yukseklikM / 100.0;

    const double toplamBar = (akmaPayiMbar + hizPayiMbar + yukseklikPayiMbar) / 1000.0;

    const double surtunmeBar = (akmaPayiMbar + hizPayiMbar) / 1000.0;
    const double hataOrani = qBound(0.0, hataPayiYuzde, 100.0) / 100.0;

    sonuc["gecerliGiris"] = true;
    sonuc["basincBar"] = toplamBar;
    const double hataBandiBar = std::abs(surtunmeBar) * hataOrani;
    sonuc["altSinirBar"] = toplamBar - hataBandiBar;
    sonuc["ustSinirBar"] = toplamBar + hataBandiBar;
    sonuc["akmaMbar"] = akmaPayiMbar;
    sonuc["viskozMbar"] = hizPayiMbar;
    sonuc["yukseklikMbar"] = yukseklikPayiMbar;
    sonuc["aMbar"] = aMbar;
    sonuc["bMbarHm"] = bMbarHm;
    return sonuc;
}

QVariantList tahminTablosu(double kesisimA, double egimB, const QVariantMap &ayarlar)
{
    const QVariantMap ayar = tahminAyarlariniTamamla(ayarlar);
    const double pompaMaksBar = ayar["pompaMaks"].toDouble();
    const double debi = ayar["hedefDebi"].toDouble();
    const double uzunluk = hesapUzunluguM(ayar);

    QVariantMap satir = basincTahmini(kesisimA, egimB, debi, ayar["cap"].toDouble(), uzunluk,
                                      ayar["yukseklik"].toDouble(), ayar["yogunluk"].toDouble(),
                                      ayar["hataPayi"].toDouble());
    satir["debi"] = debi;
    satir["uzunluk"] = uzunluk;
    satir["pompaAsildi"] = pompaMaksBar > 0.0 && satir["ustSinirBar"].toDouble() > pompaMaksBar;
    satir["basincNegatif"] = satir["basincBar"].toDouble() < 0.0;
    return { satir };
}

QString tahminGuvenilmezNedeni(double kesisimA, double egimB, double r2)
{
    if (egimB < 0.0) return "egimNegatif";
    if (kesisimA < 0.0) return "kesisimNegatif";
    if (r2 < MIN_R2) return "dusukR2";
    return QString();
}

bool tahminKarariVerilemez(const QString &guvenilmezNedeni)
{
    return guvenilmezNedeni == "egimNegatif" || guvenilmezNedeni == "kesisimNegatif";
}

QString pompaSorunuNedeni(const QVariantMap &tahminSatiri, double pompaMaksBar)
{
    const double yukseklikBar = tahminSatiri["yukseklikMbar"].toDouble() / 1000.0;
    if (yukseklikBar >= pompaMaksBar) return "yukseklik";
    if (tahminSatiri["viskozMbar"].toDouble() > tahminSatiri["akmaMbar"].toDouble()) return "viskoz";
    return "akma";
}

double penceredekiHizMs(const QVector<double> &zamanS, const QVector<double> &konumMm, double konumYonu)
{
    const Cizgi cizgi = enUygunCizgi(zamanS, konumMm);
    if (!cizgi.hesaplandi) return 0.0;
    return -konumYonu * cizgi.egim / 1000.0;
}

QVector<double> hizEgrisiMs(const QVector<double> &zamanS, const QVector<double> &konumMm,
                            double konumYonu)
{
    const int ornekSayisi = std::min(zamanS.size(), konumMm.size());
    const double yariPencereS = HIZ_PENCERESI_S / 2.0;
    QVector<double> egri;
    int pencereBasi = 0;
    int pencereSonu = 0;
    for (int merkez = 0; merkez < ornekSayisi; ++merkez) {
        while (zamanS[pencereBasi] < zamanS[merkez] - yariPencereS) ++pencereBasi;
        while (pencereSonu + 1 < ornekSayisi && zamanS[pencereSonu + 1] <= zamanS[merkez] + yariPencereS) {
            ++pencereSonu;
        }
        const int penceredekiOrnekSayisi = pencereSonu - pencereBasi + 1;
        egri.append(penceredekiHizMs(zamanS.mid(pencereBasi, penceredekiOrnekSayisi),
                                     konumMm.mid(pencereBasi, penceredekiOrnekSayisi), konumYonu));
    }
    return egri;
}

EgimAcilari egimAcilari(double ivmeX, double ivmeY, double ivmeZ)
{
    const double radyandanDereceye = 180.0 / PI;
    EgimAcilari acilar;
    acilar.xDerece = std::atan2(ivmeY, ivmeZ) * radyandanDereceye;
    acilar.yDerece = std::atan2(-ivmeX, std::sqrt(ivmeY * ivmeY + ivmeZ * ivmeZ)) * radyandanDereceye;
    return acilar;
}

}

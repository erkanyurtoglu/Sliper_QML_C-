#pragma once
#include <QVariantMap>
#include <QVariantList>
#include <QVector>
#include <QHash>
#include <QString>
#include <QStringList>

namespace SliperModel {
constexpr double PI = 3.14159265358979323846;
constexpr double BORU_CAPI_M = 0.128;
constexpr double BORU_UZUNLUGU_M = 0.5;
constexpr double BORU_ALANI_M2 = PI * BORU_CAPI_M * BORU_CAPI_M / 4.0;
constexpr double YERCEKIMI = 9.80665;

double kalibrasyonTablosundanOku(const QVector<double> &hamNoktalar,
                                 const QVector<double> &gercekNoktalar,
                                 double hamDeger);

constexpr double KONUM_FILTRE_KATSAYISI = 0.35;
constexpr double konumFiltrele(double oncekiFiltreliKonumMm, double hamKonumMm)
{
    return KONUM_FILTRE_KATSAYISI * hamKonumMm
           + (1.0 - KONUM_FILTRE_KATSAYISI) * oncekiFiltreliKonumMm;
}

constexpr double AGIRLIK_FILTRE_KATSAYISI = 0.4;
constexpr double agirlikFiltrele(double oncekiFiltreliHamAgirlik, double hamAgirlik)
{
    return AGIRLIK_FILTRE_KATSAYISI * hamAgirlik
           + (1.0 - AGIRLIK_FILTRE_KATSAYISI) * oncekiFiltreliHamAgirlik;
}

constexpr double agirliktanBasincMbar(double kutleKg)
{
    return kutleKg * YERCEKIMI / BORU_ALANI_M2 / 100.0;
}

constexpr double DARA_UST_SINIRI_KG = 2.0;
constexpr double DARA_UST_SINIRI_MBAR = agirliktanBasincMbar(DARA_UST_SINIRI_KG);

constexpr double hizdanDebiM3h(double hizMs)
{
    return hizMs * BORU_ALANI_M2 * 3600.0;
}

constexpr double KONUM_TOLERANSI_MM = 5.0;
constexpr double UST_YAKALAMA_TOLERANSI_MM = 20.0;
constexpr double ALT_YAKALAMA_TOLERANSI_MM = 25.0;
constexpr double DURGUN_TOLERANS_MM = 5.0;
constexpr double DURMA_TOLERANSI_MM = 2.0;
constexpr double DURMA_ONAYI_S = 1.0;
constexpr double MIN_INIS_YOLU_MM = 40.0;
constexpr double MIN_INIS_SURESI_S = 1.0;
constexpr double KALDIRMA_ESIGI_MM = 10.0;
constexpr double ONCESI_PENCERE_S = 2.0;
constexpr double SONRASI_PENCERE_S = 2.0;
constexpr double HAREKET_PAYI_S = 0.3;
constexpr double P0R_OTURMA_S = 0.5;
constexpr double UST_TAMPON_S = 4.0;
constexpr double HAZIRLAMA_SURESI_S = 2.0;
constexpr double HAZIRLAMA_BASINC_TOLERANSI_MBAR = 3.0;

constexpr double HIZ_UYUM_ALT = 0.2;
constexpr double HIZ_UYUM_UST = 0.8;
double strokeHiziMs(const QVector<double> &zamanS, const QVector<double> &yukseklikMm);

constexpr double PMAKS_PENCERE_S = 0.30;
constexpr int PMAKS_MIN_ORNEK = 3;
double filtreliMaksimum(const QVector<double> &zamanS, const QVector<double> &basincMbar,
                        double pencereS = PMAKS_PENCERE_S);

double durgunBasincMbar(const QVector<double> &basincMbar);

constexpr double strokeBasinciMbar(double pMaksMbar, double p0lMbar)
{
    return pMaksMbar - p0lMbar;
}

constexpr int MIN_STROKE_ORNEGI = 5;
QString strokeGecersizNedeni(int inisOrnekSayisi, double hizMs, double basincMbar);

constexpr double TAKILMA_ESIGI = 0.15;
constexpr double TAKILMA_YOL_ALT = 0.05;
constexpr double TAKILMA_YOL_UST = 0.80;
double takilmaOrani(const QVector<double> &zamanS, const QVector<double> &konumMm);

constexpr int MAKS_OTOMATIK_ELEME_YUZDE = 25;
QVector<int> otomatikElenecekler(const QVector<qint64> &agirlikAnahtarlari,
                                 const QVector<double> &takilmaOranlari);

constexpr int MIN_ORTALAMA_R2_AGIRLIK_SAYISI = 3;
struct DogruUyumu {
    int n = 0;
    double kesisimA = 0.0;
    double egimB = 0.0;
    double r2 = 0.0;
    double qMin = 0.0;
    double qMaks = 0.0;
    double qOrt = 0.0;
};
DogruUyumu pqDogrusu(const QVector<double> &debiM3h, const QVector<double> &basincMbar,
                     const QVector<qint64> &agirlikAnahtarlari);

constexpr int MIN_STROKE_SAYISI = 3;
constexpr double MIN_R2 = 0.85;
constexpr double MIN_DEBI_ARALIGI_ORANI = 0.3;
constexpr int MIN_YUK_BASINA_STROKE = 3;
constexpr int MAKS_GECERSIZ_YUZDE = 30;

constexpr double MIN_AGIRLIK_TEPKI_ORANI = 0.5;
double agirlikTepkiOrani(const QHash<qint64, double> &agirlikBasinaOrtalamaPmax);

QStringList olcumUyarilari(const DogruUyumu &pqCizgisi,
                           const QHash<qint64, int> &agirlikBasinaStrokeSayisi,
                           const QHash<qint64, double> &agirlikBasinaOrtalamaPmax,
                           int toplamStrokeSayisi, int gecersizStrokeSayisi);

constexpr double schleibingerA(double kesisimMbar)
{
    return BORU_CAPI_M * kesisimMbar / (4.0 * BORU_UZUNLUGU_M);
}
constexpr double schleibingerB(double egimMbarHm3)
{
    return egimMbarHm3 * PI * BORU_CAPI_M * BORU_CAPI_M * BORU_CAPI_M
           / (16.0 * BORU_UZUNLUGU_M);
}

constexpr double DIRSEK_90_ESDEGER_M = 3.0;
constexpr double DIRSEK_45_ESDEGER_M = 1.5;
QVariantMap varsayilanTahminAyarlari();
QVariantMap tahminAyarlariniTamamla(const QVariantMap &ayarlar);
double hesapUzunluguM(const QVariantMap &ayarlar);

QVariantMap basincTahmini(double kesisimA, double egimB, double debiM3h, double capMm,
                          double uzunlukM, double yukseklikM, double yogunlukKgM3,
                          double hataPayiYuzde);

QVariantList tahminTablosu(double kesisimA, double egimB, const QVariantMap &ayarlar);

QString tahminGuvenilmezNedeni(double kesisimA, double egimB, double r2);
bool tahminKarariVerilemez(const QString &guvenilmezNedeni);
QString pompaSorunuNedeni(const QVariantMap &tahminSatiri, double pompaMaksBar);

constexpr double HIZ_PENCERESI_S = 0.40;
double penceredekiHizMs(const QVector<double> &zamanS, const QVector<double> &konumMm, double konumYonu);
QVector<double> hizEgrisiMs(const QVector<double> &zamanS, const QVector<double> &konumMm,
                            double konumYonu);

struct EgimAcilari {
    double xDerece = 0.0;
    double yDerece = 0.0;
};
EgimAcilari egimAcilari(double ivmeX, double ivmeY, double ivmeZ);

constexpr double ADS1115_LSB_VOLT = 0.000125;
constexpr double BATARYA_BOLUCU_ORANI = 2.0;
constexpr double bataryaVoltaji(double hamDeger)
{
    return hamDeger * ADS1115_LSB_VOLT * BATARYA_BOLUCU_ORANI;
}

}

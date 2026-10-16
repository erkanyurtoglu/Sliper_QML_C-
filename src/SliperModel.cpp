#include "SliperModel.h"
#include <QtMath>
#include <algorithm>
#include <cmath>
#include <limits>

namespace SliperModel {

// =============================================================================
//  Ortak araç: noktalardan geçen en uygun düz çizgi
// =============================================================================
// Excel'deki "eğilim çizgisi" ile aynı şeyi yapar: y = başlangıç + eğim × x
//
// Nasıl bulunur?
//   1) Bütün noktaların ortalaması alınır: (ortalama x, ortalama y).
//      En uygun çizgi her zaman bu ortalama noktadan geçer.
//   2) Her nokta için "ortalamadan ne kadar sapıyor" hesaplanır:
//      x sapması = x - ortalama x,  y sapması = y - ortalama y
//   3) eğim = Σ(x sapması × y sapması) / Σ(x sapması²)
//      (x arttığında y'nin ortalamada ne kadar arttığı)
//   4) başlangıç = ortalama y - eğim × ortalama x
//   5) Uyum (R²): noktalar çizgiye ne kadar yakın?
//      R² = 1 - (çizgiden kalan sapmaların kare toplamı / y'nin toplam sapmasının kare toplamı)
//      1 = bütün noktalar tam çizgi üzerinde, 0 = çizgi hiçbir şey açıklamıyor.
namespace {

struct Cizgi {
    bool hesaplandi = false;   // en az 2 farklı x değeri varsa true
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

    // 1) Ortalamalar
    double xToplami = 0.0, yToplami = 0.0;
    for (int i = 0; i < noktaSayisi; ++i) {
        xToplami += xDegerleri[i];
        yToplami += yDegerleri[i];
    }
    const double ortalamaX = xToplami / noktaSayisi;
    const double ortalamaY = yToplami / noktaSayisi;

    // 2-3) Sapmalardan eğim
    double birlikteSapmaToplami = 0.0;   // Σ(x sapması × y sapması)
    double xSapmaKareToplami = 0.0;      // Σ(x sapması²)
    for (int i = 0; i < noktaSayisi; ++i) {
        const double xSapmasi = xDegerleri[i] - ortalamaX;
        const double ySapmasi = yDegerleri[i] - ortalamaY;
        birlikteSapmaToplami += xSapmasi * ySapmasi;
        xSapmaKareToplami += xSapmasi * xSapmasi;
    }
    if (xSapmaKareToplami <= 0.0) return cizgi;   // bütün x'ler aynı: çizgi çizilemez

    cizgi.egim = birlikteSapmaToplami / xSapmaKareToplami;
    // 4) Başlangıç değeri (x = 0'daki y)
    cizgi.baslangic = ortalamaY - cizgi.egim * ortalamaX;
    cizgi.ortalamaX = ortalamaX;

    // 5) Uyum (R²)
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

// =============================================================================
//  1. Kalibrasyon
// =============================================================================
//   örnek: (ham 1000 -> 0 kg), (ham 5000 -> 10 kg);  ham 3000 -> 5 kg
double kalibrasyonTablosundanOku(const QVector<double> &hamNoktalar,
                                 const QVector<double> &gercekNoktalar,
                                 double hamDeger)
{
    const int noktaSayisi = std::min(hamNoktalar.size(), gercekNoktalar.size());
    if (noktaSayisi == 0) return 0.0;
    if (noktaSayisi == 1) return gercekNoktalar[0];

    // Ham değerin düştüğü aralığın sol noktası
    int solNokta;
    if (hamDeger <= hamNoktalar[0]) {
        solNokta = 0;                                  // tablonun altında
    } else if (hamDeger >= hamNoktalar[noktaSayisi - 1]) {
        solNokta = noktaSayisi - 2;                    // tablonun üstünde
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

// =============================================================================
//  5. Stroke değerlendirme
// =============================================================================

// Borunun kayma hızı (m/s).
// Boru her an aynı hızla kaymaz: başta hızlanır, sonda alta çarpıp durur.
// Bu yüzden yolun sadece orta kısmı (%20 - %80 arası) kullanılır ve o kısımdaki
// (zaman, yükseklik) noktalarına en uygun çizgi çizilir. Çizginin eğimi
// "saniyede kaç mm yükseklik kaybı" demektir; eksi işareti ve /1000 ile m/s'ye çevrilir.
double strokeHiziMs(const QVector<double> &zamanS, const QVector<double> &yukseklikMm)
{
    const int ornekSayisi = std::min(zamanS.size(), yukseklikMm.size());
    if (ornekSayisi < 2) return 0.0;

    const double baslangicYuksekligi = yukseklikMm.first();
    const double bitisYuksekligi = yukseklikMm[ornekSayisi - 1];
    const double toplamYolMm = baslangicYuksekligi - bitisYuksekligi;

    // Yolun orta kısmındaki örnekleri seç
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

    // Orta kısımda en az 3 nokta varsa: çizginin eğiminden hız
    if (ortaZamanlar.size() >= 3) {
        const Cizgi cizgi = enUygunCizgi(ortaZamanlar, ortaYukseklikler);
        if (cizgi.hesaplandi) {
            const double yukseklikKaybiMmSaniye = -cizgi.egim;
            return yukseklikKaybiMmSaniye / 1000.0;
        }
    }

    // Yeterli nokta yoksa kaba hesap: toplam yol / toplam süre
    const double toplamSureS = zamanS[ornekSayisi - 1] - zamanS.first();
    return toplamSureS > 0.0 ? (toplamYolMm / 1000.0) / toplamSureS : 0.0;
}

// En yüksek basınç (Pmax).
// Basınç sinyali titrer; tek bir anlık sıçramayı Pmax sanmamak için her noktanın
// etrafındaki "pencere" kadar örneğin ortalaması alınır, bu ortalamaların en büyüğü seçilir.
// Pencere genişliği süreyle tanımlıdır, örnek sayısıyla değil; gerekçe SliperModel.h bölüm 5.
double filtreliMaksimum(const QVector<double> &zamanS, const QVector<double> &basincMbar,
                        double pencereS)
{
    const int ornekSayisi = std::min(zamanS.size(), basincMbar.size());
    if (ornekSayisi == 0) return 0.0;

    const double yariPencereS = pencereS / 2.0;
    double enBuyukOrtalama = -1e300;
    for (int merkez = 0; merkez < ornekSayisi; ++merkez) {
        const double merkezZamaniS = zamanS[merkez];

        // Örnekler zamana göre sıralı: merkezden iki yana pencere sınırına kadar yürünür
        int pencereBasi = merkez;
        while (pencereBasi > 0 && merkezZamaniS - zamanS[pencereBasi - 1] <= yariPencereS) {
            --pencereBasi;
        }
        int pencereSonu = merkez;
        while (pencereSonu < ornekSayisi - 1 && zamanS[pencereSonu + 1] - merkezZamaniS <= yariPencereS) {
            ++pencereSonu;
        }

        // Süre şartı az örnek bıraktıysa pencere iki yana dengeli genişletilir
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

// Durağan basınç (P0l veya P0r): boru hareketsizken ölçülen basınçların ortancası.
// Ortalama yerine ortanca alınır; gerekçe SliperModel.h bölüm 5'te.
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

// Hatalı stroke kontrolü. Boş metin = stroke geçerli.
QString strokeGecersizNedeni(int inisOrnekSayisi, double hizMs, double basincMbar)
{
    if (inisOrnekSayisi < MIN_STROKE_ORNEGI) return "ornek";   // çok az ölçüm
    if (hizMs <= 0.0) return "hiz";                              // boru kaymamış
    if (basincMbar <= 0.0) return "basinc";                      // basınç artmamış
    return QString();
}

// =============================================================================
//  6. P-Q doğrusu:  p = A + B × Q
// =============================================================================
// Her geçerli stroke bir (Q, p) noktasıdır. Bu noktalara en uygun çizgi:
//   A = çizginin Q = 0'daki değeri   (harekete geçme direnci)
//   B = çizginin eğimi               (hıza bağlı direnç)
DogruUyumu pqDogrusu(const QVector<double> &debiM3h, const QVector<double> &basincMbar)
{
    DogruUyumu sonuc;
    const int noktaSayisi = std::min(debiM3h.size(), basincMbar.size());
    sonuc.n = noktaSayisi;
    if (noktaSayisi < 2) return sonuc;

    // En küçük ve en büyük debi (debi aralığı uyarısı için)
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
    } else {
        // Bütün stroke'lar aynı debide: eğim bulunamaz, A = ortalama basınç
        double basincToplami = 0.0;
        for (int i = 0; i < noktaSayisi; ++i) basincToplami += basincMbar[i];
        sonuc.kesisimA = basincToplami / noktaSayisi;
    }
    return sonuc;
}

// =============================================================================
//  7. Ölçüm kalitesi uyarıları
// =============================================================================
// Eklenen ağırlık Pmax'ta gerçekten görünüyor mu? Gerekçe SliperModel.h bölüm 7.
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

    // Anahtarlar 0.1 kg hassasiyetinde tam sayıdır (1.6 kg -> 16)
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

    // Debi aralığı dar ise (hep benzer hızda stroke) eğim güvenilir belirlenemez
    const double debiAraligi = pqCizgisi.qMaks - pqCizgisi.qMin;
    if (pqCizgisi.qOrt > 0.0 && debiAraligi < MIN_DEBI_ARALIGI_ORANI * pqCizgisi.qOrt) {
        uyarilar << "darDebiAraligi";
    }

    // Ağırlık load cell'e ulaşmıyorsa eğim ölçülmüş değil, gürültüdür.
    // Diğer uyarılardan (düşük R², negatif eğim) önce gelir: onların sebebi budur.
    const double tepkiOrani = agirlikTepkiOrani(agirlikBasinaOrtalamaPmax);
    if (!std::isnan(tepkiOrani) && tepkiOrani < MIN_AGIRLIK_TEPKI_ORANI) {
        uyarilar.prepend("agirlikTepkisiZayif");
    }

    if (agirlikBasinaStrokeSayisi.size() < 2) uyarilar << "tekYuk";
    // Kılavuz 5.3: "At least three strokes for each load are recommended."
    for (const int strokeSayisi : agirlikBasinaStrokeSayisi) {
        if (strokeSayisi < MIN_YUK_BASINA_STROKE) { uyarilar << "yukBasinaAzStroke"; break; }
    }

    // Tam sayı karşılaştırması (ör. 3/10 tam sınırda kayan nokta hatası olmasın)
    if (toplamStrokeSayisi > 0
        && gecersizStrokeSayisi * 100 > toplamStrokeSayisi * MAKS_GECERSIZ_YUZDE) {
        uyarilar << "cokGecersiz";
    }
    return uyarilar;
}

// =============================================================================
//  9. Pompa hattı tahmini
// =============================================================================

QVariantMap varsayilanTahminAyarlari()
{
    // Schleibinger uygulamasının varsayılanları (kılavuz Şekil 17a / 19b)
    QVariantMap ayar;
    ayar["q1"] = 10.0;         // 1. debi [m3/h]
    ayar["q2"] = 50.0;         // 2. debi [m3/h]
    ayar["cap"] = 126.0;       // pompa hattı boru çapı [mm]
    ayar["l2"] = 50.0;         // 1. hat uzunluğu [m]
    ayar["l3"] = 100.0;        // 2. hat uzunluğu [m]
    ayar["l4"] = 200.0;        // 3. hat uzunluğu [m]
    ayar["yogunluk"] = 2400.0; // beton yoğunluğu [kg/m3]
    ayar["yukseklik"] = 0.0;   // pompalama yüksekliği [m], aşağı ise eksi
    ayar["hataPayi"] = 10.0;   // [%]
    ayar["pompaMaks"] = 0.0;   // pompanın maksimum basıncı [bar], 0 = girilmedi
    return ayar;
}

// Eksik veya bozuk alanları varsayılan değerle doldurur.
QVariantMap tahminAyarlariniTamamla(const QVariantMap &ayarlar)
{
    QVariantMap tamAyarlar = varsayilanTahminAyarlari();
    for (auto alan = ayarlar.constBegin(); alan != ayarlar.constEnd(); ++alan) {
        if (!tamAyarlar.contains(alan.key()) || !alan.value().isValid()) continue;
        bool sayiMi = false;
        const double deger = alan.value().toDouble(&sayiMi);
        if (sayiMi) tamAyarlar[alan.key()] = deger;
    }
    return tamAyarlar;
}

// Tek bir durum için pompa basıncı:
//   pompa basıncı = akma payı + hız payı + yükseklik payı
//     akma payı      = 4 × L / D × a
//     hız payı       = 16 × L × Q / (π × D³) × b
//     yükseklik payı = yoğunluk × g × h
// (D: hat çapı, L: hat uzunluğu, Q: debi, h: yükseklik; a, b: SLIPER sonucu)
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

    const double aMbar = schleibingerA(kesisimA);     // borudan bağımsız a
    const double bMbarHm = schleibingerB(egimB);      // borudan bağımsız b
    const double hatCapiM = capMm / 1000.0;
    const double hatUzunluguM = uzunlukM;
    const double hatCapiKupu = hatCapiM * hatCapiM * hatCapiM;

    const double akmaPayiMbar = 4.0 * hatUzunluguM / hatCapiM * aMbar;
    const double hizPayiMbar = 16.0 * hatUzunluguM * debiM3h / (M_PI * hatCapiKupu) * bMbarHm;
    const double yukseklikPayiMbar = yogunlukKgM3 * YERCEKIMI * yukseklikM / 100.0;   // Pa -> mbar

    const double toplamBar = (akmaPayiMbar + hizPayiMbar + yukseklikPayiMbar) / 1000.0;   // mbar -> bar

    // Hata payı yalnızca sürtünme kısmına (akma + hız) uygulanır;
    // yükseklik payı fiziksel bir sabittir, belirsizliği yoktur.
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

// Orijinal uygulamadaki tahmin tablosu: 2 debi × 3 hat uzunluğu = 6 satır.
QVariantList tahminTablosu(double kesisimA, double egimB, const QVariantMap &ayarlar)
{
    const QVariantMap ayar = tahminAyarlariniTamamla(ayarlar);
    const double pompaMaksBar = ayar["pompaMaks"].toDouble();
    QVariantList satirlar;

    for (const char *uzunlukAlani : { "l2", "l3", "l4" }) {
        for (const char *debiAlani : { "q1", "q2" }) {
            const double debi = ayar[debiAlani].toDouble();
            const double uzunluk = ayar[uzunlukAlani].toDouble();

            QVariantMap satir = basincTahmini(kesisimA, egimB, debi, ayar["cap"].toDouble(), uzunluk,
                                              ayar["yukseklik"].toDouble(), ayar["yogunluk"].toDouble(),
                                              ayar["hataPayi"].toDouble());
            satir["debi"] = debi;
            satir["uzunluk"] = uzunluk;
            satir["pompaAsildi"] = pompaMaksBar > 0.0 && satir["ustSinirBar"].toDouble() > pompaMaksBar;
            satir["basincNegatif"] = satir["basincBar"].toDouble() < 0.0;
            satirlar.append(satir);
        }
    }
    return satirlar;
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

// =============================================================================
//  10. Gösterim hesapları (ölçüm sonucuna girmez)
// =============================================================================

// İki örnek arasındaki anlık hız. Konum farkı yönle çarpılır: böylece konum
// "yükseklik" de olsa "sensörden uzaklık" da olsa aşağı iniş pozitif çıkar.
double anlikHizMs(double oncekiKonumMm, double simdikiKonumMm, double gecenSureS, double konumYonu)
{
    if (gecenSureS <= 0.0) return 0.0;
    const double inilenYolM = konumYonu * (oncekiKonumMm - simdikiKonumMm) / 1000.0;
    return inilenYolM / gecenSureS;
}

QVector<double> hizEgrisiMs(const QVector<double> &zamanS, const QVector<double> &konumMm,
                            double konumYonu)
{
    const int ornekSayisi = std::min(zamanS.size(), konumMm.size());
    QVector<double> egri;
    if (ornekSayisi == 0) return egri;

    // 1) Her örnekte: bir önceki ile bir sonraki örnek arasındaki hız
    QVector<double> anlikHizlar;
    for (int i = 0; i < ornekSayisi; ++i) {
        const int onceki = std::max(0, i - 1);
        const int sonraki = std::min(ornekSayisi - 1, i + 1);
        anlikHizlar.append(anlikHizMs(konumMm[onceki], konumMm[sonraki],
                                      zamanS[sonraki] - zamanS[onceki], konumYonu));
    }

    // 2) HIZ_EGRISI_ORTALAMA örneklik merkezi ortalama (uçlarda pencere daralır)
    const int yariPencere = HIZ_EGRISI_ORTALAMA / 2;
    for (int merkez = 0; merkez < ornekSayisi; ++merkez) {
        const int pencereBasi = std::max(0, merkez - yariPencere);
        const int pencereSonu = std::min(ornekSayisi - 1, merkez + yariPencere);
        double hizToplami = 0.0;
        for (int i = pencereBasi; i <= pencereSonu; ++i) hizToplami += anlikHizlar[i];
        egri.append(hizToplami / (pencereSonu - pencereBasi + 1));
    }
    return egri;
}

// Cihaz düz dururken ivmeölçer yalnızca yerçekimini (Z ekseni) görür.
// Eğildikçe yerçekimi X/Y eksenlerine de dağılır; açı bu dağılımdan bulunur.
EgimAcilari egimAcilari(double ivmeX, double ivmeY, double ivmeZ)
{
    const double radyandanDereceye = 180.0 / PI;
    EgimAcilari acilar;
    acilar.xDerece = std::atan2(ivmeY, ivmeZ) * radyandanDereceye;
    acilar.yDerece = std::atan2(-ivmeX, std::sqrt(ivmeY * ivmeY + ivmeZ * ivmeZ)) * radyandanDereceye;
    return acilar;
}

}

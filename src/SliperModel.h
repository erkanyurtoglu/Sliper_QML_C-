#pragma once
#include <QVariantMap>
#include <QVariantList>
#include <QVector>
#include <QHash>
#include <QString>
#include <QStringList>

// =============================================================================
//  SLIPER HESAP MODELİ 
// =============================================================================
//
// İÇİNDEKİLER 
//   0. Sabitler            : SLIPER borusunun geometrisi
//   1. Kalibrasyon         : ham sensör değeri -> kg / mm (kalibrasyon tablosu)
//   2. Basınç              : load cell kuvveti / piston alanı
//   3. Debi                : Q = A * v * 3600
//   4. Stroke zamanlaması  : başlangıç/bitiş eşikleri, P0l/P0r pencereleri
//   5. Stroke değerlendirme: v (x(t) doğrusu), Pmax (filtreli), p = Pmax - P0l
//   6. P-Q doğrusu         : P = A + B*Q (en küçük kareler)
//   7. Ölçüm kalitesi      : P-Q sonucuna eklenen uyarılar
//   8. a / b               : borudan bağımsız parametreler (Schleibinger)
//   9. Pompa hattı tahmini : P = 4L/D*a + 16*L*Q/(pi*D^3)*b + rho*g*H
//  10. Gösterim hesapları  : canlı hız, hız eğrisi, eğim açısı, batarya
//                            (yalnızca ekrana; ölçüm sonucuna girmez)
// =============================================================================
namespace SliperModel {

// --- 0. Sabitler --------------------------------------------------------------
// Liya SLIPER borusunun ölçülen iç çapı: 128 mm (2026-09-28). Dolum yüksekliği 500 mm.
// Not: Schleibinger SLIPER 125 mm borudur; kılavuzdaki Excel çıktısı d = 0.125 ile
// üretilmiştir. a ve b boru geometrisinden bağımsız olduğu için iki cihazın a/b
// değerleri doğrudan karşılaştırılabilir.
constexpr double PI = 3.14159265358979323846;
constexpr double BORU_CAPI_M = 0.128;                                     // d
constexpr double BORU_UZUNLUGU_M = 0.5;                                   // l
constexpr double BORU_ALANI_M2 = PI * BORU_CAPI_M * BORU_CAPI_M / 4.0;    // A = pi*d^2/4
constexpr double YERCEKIMI = 9.80665;                                     // g [m/s2]

// --- 1. Kalibrasyon -------------------------------------------------------------
// Ham sensör değerini kalibrasyon tablosuyla gerçek birime çevirir
// (load cell: ham -> kg, mesafe sensörü: ham -> mm).
// Tablo: kalibrasyonda kaydedilen (ham, gerçek) noktaları, ham değere göre sıralı.
// İki nokta arasında düz çizgiyle okunur; tablonun dışında en yakın iki noktanın
// çizgisi uzatılır. Tabloda nokta yoksa 0, tek nokta varsa o noktanın değeri döner.
double kalibrasyonTablosundanOku(const QVector<double> &hamNoktalar,
                                 const QVector<double> &gercekNoktalar,
                                 double hamDeger);

// Mesafe sensörünün ham okumasındaki paket-paket gürültüyü bastırmak için
// üstel ortalama (hız filtresiyle aynı mantık). Kalibrasyon tablosundan
// okunduktan hemen sonra, konumu kullanan HER yer için (grafik, ekran,
// stroke tespiti) tek sefer uygulanır.
// K büyükse hızlı tepki/çok gürültü, küçükse yavaş tepki/az gürültü.
constexpr double KONUM_FILTRE_KATSAYISI = 0.35;
constexpr double konumFiltrele(double oncekiFiltreliKonumMm, double hamKonumMm)
{
    return KONUM_FILTRE_KATSAYISI * hamKonumMm
           + (1.0 - KONUM_FILTRE_KATSAYISI) * oncekiFiltreliKonumMm;
}

// --- 2. Basınç ----------------------------------------------------------------
// p [mbar] = m * g / A / 100        (1 mbar = 100 Pa)
// 1 kg -> 9.80665 N / 0.01287 m2 = ~7.6 mbar (128 mm boru)
constexpr double agirliktanBasincMbar(double kutleKg)
{
    return kutleKg * YERCEKIMI / BORU_ALANI_M2 / 100.0;
}

// --- 3. Debi ------------------------------------------------------------------
// Q [m3/h] = A [m2] * v [m/s] * 3600
constexpr double hizdanDebiM3h(double hizMs)
{
    return hizMs * BORU_ALANI_M2 * 3600.0;
}

// --- 4. Stroke zamanlaması --------------------------------------------------------
// Calculator bu sayılarla stroke'un başını/sonunu ve P0l/P0r örneklerini seçer.
//
//  zaman ──►  [ P0l örnekleri ][ HAREKET_PAYI ][ iniş ........ ][ OTURMA ][ P0r örnekleri ]
//             |<-- ONCESI_PENCERE (2 s) -->|   ^başlangıç     ^bitiş  |<- SONRASI_PENCERE (2 s) ->|
//
// Başlangıç: boru üst referansın KONUM_TOLERANSI_MM altına indiğinde.
// Bitiş    : boru durduğunda (aşağıdaki durma ölçütü) ya da alt referansa
//            ALT_YAKALAMA_TOLERANSI_MM kadar yaklaştığında - hangisi önce olursa.
constexpr double KONUM_TOLERANSI_MM = 5.0;    // üst/alt referansa bu kadar yaklaşınca
// Boru "üstte / yeni stroke'a hazır" sayılması için kalibre edilmiş üst noktaya
// bu kadar yaklaşması yeterlidir. KONUM_TOLERANSI_MM'den geniştir: boru elle
// kaldırılıp sabitlendiğinde tam olarak kalibrasyon noktasına oturmaz. Dar bir
// pencerede (5 mm) boru "üstte" sayılmaz ve sonraki iniş stroke olarak
// işlenmez - özellikle duraklat/devam et sırasında boru yeniden konumlandığında.
constexpr double UST_YAKALAMA_TOLERANSI_MM = 20.0;
// Alt referans için aynı gerekçe, daha da güçlüsü: boru alt noktaya betonun
// üstüne oturarak varır, kalibrasyonda elle bastırılan noktaya kadar inmez
// (sahada 538 mm'ye kalibre edilen alt nokta beton dolu boruda 517 mm'de
// kalıyordu). Dar bir pencerede boru "alta vardı" sayılmaz, stroke hiç
// kapanmaz ve durum INIYOR'da takılırdı.
constexpr double ALT_YAKALAMA_TOLERANSI_MM = 25.0;
constexpr double DURGUN_TOLERANS_MM = 5.0;    // bu kadar kıpırtı hâlâ "hareketsiz" sayılır
// Stroke bitişinin asıl ölçütü: boru durdu. Boru DURMA_ONAYI_S saniye boyunca
// DURMA_TOLERANSI_MM'den az kıpırdadıysa durmuş kabul edilir; yani ölçüt
// aslında bir hız sınırıdır: DURMA_TOLERANSI_MM / DURMA_ONAYI_S ≈ 2 mm/s.
// Alt referansa hiç varılmasa bile (kısa iniş, beton yüksekte kalması)
// stroke böylece doğru anda kapanır.
//
// ÖNEMLİ - sınır neden bu kadar düşük: boru beton içinde sabit hızla kaymaz,
// ilk anda hızlanıp sonra betonun direncine göre belirgin yavaşlar. Eski ölçüt
// (5 mm / 0.2 s = 25 mm/s) bu yavaşlamayı "durdu" sanıp inişin ortasında
// stroke'u kapatıyordu: grafik donuyor, boru hâlâ inerken yalnızca baştaki
// hızlı bölüm kaydedildiği için v ve Q gerçeğin kat kat üstünde çıkıyordu.
// Sınır gerçek kayma hızlarının (onlarca mm/s) belirgin altında kalmalı.
constexpr double DURMA_TOLERANSI_MM = 2.0;
constexpr double DURMA_ONAYI_S = 1.0;
// Durma ölçütü ancak boru bu kadar yol indikten sonra işler; aksi halde
// üstteki kıpırtı ya da inişin ilk ivmelenme anı "durdu" sayılırdı.
constexpr double MIN_INIS_YOLU_MM = 40.0;
// Durma ölçütü ayrıca iniş bu süreyi doldurmadan stroke'u kapatmaz. Kılavuzdaki
// stroke'lar 1.5-5 s sürer; inişin ilk saniyesindeki hızlanma/yavaşlama
// dalgalanması böylece stroke'u asla erken bitirmez (alt referansa varış bu
// kuraldan bağımsızdır, orada iniş gerçekten tamamlanmıştır).
constexpr double MIN_INIS_SURESI_S = 1.0;
// Stroke kapandıktan sonra P0r penceresi toplanırken boru bu kadar yukarı
// giderse (operatör yeni stroke için kaldırdı) pencere beklenmeden kapatılır.
// Sensör gürültüsünün pencereyi boşa çıkarmaması için kıpırtı toleransının
// belirgin üstündedir.
constexpr double KALDIRMA_ESIGI_MM = 10.0;
constexpr double ONCESI_PENCERE_S = 2.0;      // orijinal: başlangıçtan 2 s önce saklanır
constexpr double SONRASI_PENCERE_S = 2.0;     // orijinal: bitişten 2 s sonra saklanır
constexpr double HAREKET_PAYI_S = 0.3;        // hareketten hemen önceki bu süre P0l'e katılmaz
constexpr double P0R_OTURMA_S = 0.5;          // bitişten sonraki bu süre P0r'a katılmaz (sönümlenme)
constexpr double UST_TAMPON_S = 4.0;          // boru üstteyken hafızada tutulan son süre

// --- 5. Stroke değerlendirme -----------------------------------------------------
// Stroke hızı: strokun orta bölümünde (yolun HIZ_UYUM_ALT..HIZ_UYUM_UST kısmı)
// yükseklik-zaman verisine en küçük kareler doğrusu uydurulur, v = -eğim.
// Baştaki ivmelenme ve sondaki çarpma bölgeleri hariç tutulur. Orta bölümde
// 3'ten az örnek varsa v = toplam yol / toplam süre.
constexpr double HIZ_UYUM_ALT = 0.2;
constexpr double HIZ_UYUM_UST = 0.8;
// zamanS ve yukseklikMm: iniş örnekleri (ilk = üst, son = alt referans). Dönüş: m/s
double strokeHiziMs(const QVector<double> &zamanS, const QVector<double> &yukseklikMm);

// Pmax: basınç eğrisi PMAKS_PENCERE örneklik merkezi hareketli ortalamayla
// filtrelendikten sonraki en büyük değer (tek örnek gürültü tepelerini bastırır).
// Örnekler 50 Hz gelir ama Liya cihazındaki HX711 modülü 10 SPS'te çalışır
// (RATE pini modül üzerinde GND'ye sabit); her basınç değeri ~5 kez tekrarlanır.
// 15 örnek = 0.3 s ≈ 3 gerçek HX711 okuması.
constexpr int PMAKS_PENCERE = 15;
double filtreliMaksimum(const QVector<double> &basincMbar, int pencere = PMAKS_PENCERE);

// P0l / P0r: durağan bölgedeki örneklerin aritmetik ortalaması.
double durgunBasincMbar(const QVector<double> &basincMbar);

// Stroke basıncı (Schleibinger Excel: p = pmax - P0l). P0l çıkarılarak
// betonun ölü ağırlığı (~120-155 mbar) elenir.
constexpr double strokeBasinciMbar(double pMaksMbar, double p0lMbar)
{
    return pMaksMbar - p0lMbar;
}

// Geçersiz stroke ("Wrong Stroke") kuralı. Boş dönüş = geçerli.
// "ornek": MIN_STROKE_ORNEGI'nden az örnek, "hiz": v <= 0, "basinc": p <= 0
constexpr int MIN_STROKE_ORNEGI = 5;
QString strokeGecersizNedeni(int inisOrnekSayisi, double hizMs, double basincMbar);

// --- 6. P-Q doğrusu -----------------------------------------------------------
// P = A + B*Q, en küçük kareler:
//   B = (Σqp - n*q̄*p̄) / (Σq² - n*q̄²),   A = p̄ - B*q̄,   R² = 1 - SSres/SStot
// A: kesişim [mbar], B: eğim [mbar*h/m3]. (Veritabanı/QML'de "tau0" = A, "mu" = B
// olarak anılır; bunlar reolojik τ0/μ değil, ham doğru parametreleridir.)
struct DogruUyumu {
    int n = 0;
    double kesisimA = 0.0;
    double egimB = 0.0;
    double r2 = 0.0;
    double qMin = 0.0;
    double qMaks = 0.0;
    double qOrt = 0.0;
};
DogruUyumu pqDogrusu(const QVector<double> &debiM3h, const QVector<double> &basincMbar);

// --- 7. Ölçüm kalitesi uyarıları --------------------------------------------------
// P-Q sonucuyla birlikte gösterilen uyarı kodları (metinleri QML/rapor tarafında):
//   azStroke          : 3'ten az kullanılan stroke
//   egimNegatif       : B < 0
//   kesisimNegatif    : A < 0
//   dusukR2           : R² < MIN_R2
//   darDebiAraligi    : (Qmaks - Qmin) < MIN_DEBI_ARALIGI_ORANI * Qort
//   tekYuk            : bütün stroke'lar aynı ek ağırlıkla
//   yukBasinaAzStroke : bir ağırlıkta MIN_YUK_BASINA_STROKE'tan az stroke (kılavuz 5.3)
//   cokGecersiz       : stroke'ların %MAKS_GECERSIZ_YUZDE'sinden fazlası geçersiz
constexpr int MIN_STROKE_SAYISI = 3;
constexpr double MIN_R2 = 0.9;
constexpr double MIN_DEBI_ARALIGI_ORANI = 0.3;
constexpr int MIN_YUK_BASINA_STROKE = 3;
constexpr int MAKS_GECERSIZ_YUZDE = 30;
// agirlikBasinaStrokeSayisi: ek ağırlık -> o ağırlıkla atılan kullanılan stroke sayısı
QStringList olcumUyarilari(const DogruUyumu &pqCizgisi,
                           const QHash<qint64, int> &agirlikBasinaStrokeSayisi,
                           int toplamStrokeSayisi, int gecersizStrokeSayisi);

// --- 8. a / b (borudan bağımsız parametreler) -----------------------------------
// CFD makalesi Denklem 3. Schleibinger uygulaması bunları "Yield Pressure a [mbar]"
// ve "Pressure Gradient b" olarak gösterir; b'yi 1000 ile çarpılmış halde yazar
// (örn. Excel çıktısında a=0.84, b=4.55).
//   a = d*A / (4l)
//   b = B * pi * d^3 / (16l)
constexpr double schleibingerA(double kesisimMbar)
{
    return BORU_CAPI_M * kesisimMbar / (4.0 * BORU_UZUNLUGU_M);
}
constexpr double schleibingerB(double egimMbarHm3)
{
    return egimMbarHm3 * PI * BORU_CAPI_M * BORU_CAPI_M * BORU_CAPI_M
           / (16.0 * BORU_UZUNLUGU_M);
}

// --- 9. Pompa hattı tahmini -------------------------------------------------------
//   P = 4L/D*a + 16*L*Q/(pi*D^3)*b + rho*g*H      (D, L: hedef boru hattı)
// A: P-Q kesişimi [mbar], B: P-Q eğimi [mbar*h/m3], Q: [m3/h], D: [mm], L: [m], H: [m].
// Hata payı yalnızca sürtünme terimlerine (ilk iki terim) uygulanır.
// Schleibinger kılavuzundaki iki tahmin tablosunu birebir verir.

// Orijinal uygulamadaki "Forecast Preferences" alanları + pompa kapasitesi.
// Anahtarlar: q1, q2 [m3/h], cap [mm], l2, l3, l4 [m], yogunluk [kg/m3],
// yukseklik [m] (negatif = aşağı pompalama), hataPayi [%], pompaMaks [bar, 0 = yok]
QVariantMap varsayilanTahminAyarlari();
QVariantMap tahminAyarlariniTamamla(const QVariantMap &ayarlar);

// Tek bir (Q, D, L) için basınç. Dönen alanlar: gecerliGiris, basincBar,
// altSinirBar, ustSinirBar, akmaMbar, viskozMbar, yukseklikMbar, aMbar, bMbarHm
QVariantMap basincTahmini(double kesisimA, double egimB, double debiM3h, double capMm,
                          double uzunlukM, double yukseklikM, double yogunlukKgM3,
                          double hataPayiYuzde);

// Orijinal "Table of Results": {Q1, Q2} x {L2, L3, L4}. Satır alanları:
// debi, uzunluk, basincBar, altSinirBar, ustSinirBar, pompaAsildi
QVariantList tahminTablosu(double kesisimA, double egimB, const QVariantMap &ayarlar);

// --- 10. Gösterim hesapları (ölçüm sonucuna girmez) --------------------------------

// Canlı hız (ölçüm ekranı): ardışık iki örnekten anlık hız, gürültüye karşı üstel
// ortalamayla yumuşatılır:  yeni = K * anlık + (1 - K) * önceki
// K büyükse hızlı tepki/çok gürültü, küçükse yavaş tepki/az gürültü.
constexpr double CANLI_HIZ_FILTRE_KATSAYISI = 0.3;
// konumYonu: +1 konum = yükseklik, -1 konum = sensörden uzaklık. Dönüş: m/s, aşağı = pozitif
double anlikHizMs(double oncekiKonumMm, double simdikiKonumMm, double gecenSureS, double konumYonu);
constexpr double canliHizFiltrele(double oncekiFiltreliHizMs, double anlikHiz)
{
    return CANLI_HIZ_FILTRE_KATSAYISI * anlikHiz
           + (1.0 - CANLI_HIZ_FILTRE_KATSAYISI) * oncekiFiltreliHizMs;
}

// Sonuç sayfasındaki stroke "Speed" eğrisi: her örnekte bir önceki ve bir sonraki
// örnek arasındaki konum farkı / zaman farkı, ardından HIZ_EGRISI_ORTALAMA örneklik
// merkezi ortalama. Stroke hızı bu eğriden DEĞİL, bölüm 5'teki doğrudan hesaplanır.
constexpr int HIZ_EGRISI_ORTALAMA = 5;
QVector<double> hizEgrisiMs(const QVector<double> &zamanS, const QVector<double> &konumMm,
                            double konumYonu);

// Eğim açısı (su terazisi): düzeltilmiş ivmeölçer değerlerinden iki eksende açı [derece].
struct EgimAcilari {
    double xDerece = 0.0;
    double yDerece = 0.0;
};
EgimAcilari egimAcilari(double ivmeX, double ivmeY, double ivmeZ);

// Batarya voltajı: ADS1115 ham değeri (GAIN_ONE, ±4.096 V, 16 bit) x bölücü oranı.
// NOT: Bölücü dirençleri henüz doğrulanmadı; BATARYA_BOLUCU_ORANI varsayımdır
// (bkz. sliper_esp32.ino). Gösterge WifiManager::BATARYA_OLCUMU_AKTIF ile kapalı.
constexpr double ADS1115_LSB_VOLT = 0.000125;   // 4.096 V / 32768
constexpr double BATARYA_BOLUCU_ORANI = 2.0;
constexpr double bataryaVoltaji(double hamDeger)
{
    return hamDeger * ADS1115_LSB_VOLT * BATARYA_BOLUCU_ORANI;
}

}

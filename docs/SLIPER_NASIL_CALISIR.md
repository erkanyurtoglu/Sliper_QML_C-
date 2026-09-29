# SLIPER Programı Nasıl Çalışır?

Bu belge programın ne yaptığını **sade dille**, adım adım anlatır. Her adımda:

- **Ne oluyor?** — olayın kendisi
- **Hesap** — formül, kelimelerle
- **Örnek** — gerçek bir ölçümden sayı
- **Kodda nerede?** — hangi dosya, hangi fonksiyon

Örnek sayılar Schleibinger kılavuzundaki gerçek ölçümden (Şekil 25) alınmış, **bizim 128 mm'lik borumuza** göre hesaplanmıştır. Hepsini hesap makinesiyle kontrol edebilirsiniz.

---

## 1. Tek cümlede cihaz ne yapar?

İçi beton dolu boru, ağırlığıyla sabit bir pistonun üzerinden aşağı kayar. Boru ne kadar **hızlı** kayıyor, beton pistona ne kadar **basınç** yapıyor — bunları ölçeriz. Farklı ağırlıklarla birkaç kez kaydırınca "hız arttıkça basınç ne kadar artıyor" ilişkisi çıkar. Bu ilişkiden, betonun gerçek bir pompa hattında ne kadar basınç gerektireceğini tahmin ederiz.

## 2. Büyük resim: bir sayının yolculuğu

```
 SENSÖRLER           ESP32              BİLGİSAYAR PROGRAMI
 ─────────           ─────              ───────────────────
 Load cell  ──┐
 Mesafe     ──┼──►  ham sayılar  ──►  (A) ham sayı → kg, mm       WifiManager + SliperModel
 Eğim       ──┘     saniyede 50        (B) kg → basınç (mbar)       SliperModel
                    Wi-Fi ile          (C) stroke'u yakala          Calculator
                                       (D) stroke'tan p ve Q        Calculator + SliperModel
                                       (E) tüm stroke'lar → A, B    Database + SliperModel
                                       (F) A, B → a, b              SliperModel
                                       (G) a, b → pompa basıncı     SliperModel
                                       (H) kaydet, rapor, Excel     Database, ReportManager
                                       (I) ekranlar                 qml/pages/*.qml
```

**Bütün formüller ve ayar sayıları tek bir dosyadadır: `src/SliperModel.h` (+ `.cpp`).** Kalibrasyon okuma, stroke süreleri/toleransları, uyarı eşikleri, ekrandaki canlı hız, hız eğrisi, eğim açısı ve batarya voltajı da dahil. Diğer dosyalar sadece "hangi veriyi nereden alacağım, nereye koyacağım" işini yapar. Bir formülü veya sayıyı merak ederseniz önce oraya bakın; dosyanın başında içindekiler listesi (bölüm 0-10) var.

---

## 3. Adım adım

### Adım A — Sensörler sayı gönderir

**Ne oluyor?** ESP32 saniyede 50 kez load cell'i, mesafe sensörünü ve eğim sensörünü okur, bunları "ham sayı" olarak (birimsiz) Wi-Fi ile bilgisayara yollar. Her paketin yanına bir **zaman damgası** koyar ki hız doğru hesaplansın.

- Load cell (HX711 modülü) saniyede sadece **10** yeni değer üretir; arada son değer tekrar gönderilir. Bu normaldir.

**Kodda nerede?** `esp32/sliper_esp32/sliper_esp32.ino` → `loop()`

### Adım B — Ham sayı → kg ve mm (kalibrasyon)

**Ne oluyor?** Ham sayının bir anlamı yoktur. Kalibrasyonda "ham sayı 84 000 iken üstünde 5 kg vardı" gibi noktalar kaydettiniz. Program iki nokta arasını düz çizgiyle birleştirerek (doğrusal ara değer) her ham sayıyı kg'a ve mm'ye çevirir.

**Kodda nerede?** Hesap: `src/SliperModel.cpp` → `kalibrasyonTablosundanOku()`. Bunu çağıran ana fonksiyon: `src/WifiManager.cpp` → `jsonSatiriIsle()` (her paket geldiğinde çalışır).

### Adım C — kg → basınç

**Hesap:** basınç = ağırlık × yerçekimi ÷ boru kesit alanı

- Boru kesit alanı = π × 0,128² ÷ 4 = **0,01287 m²**
- **1 kg = 7,62 mbar** (128 mm boruda)

**Örnek:** Load cell 20 kg gösteriyorsa basınç = 20 × 7,62 = **152 mbar**.

Stroke yokken bile load cell betonun **kendi ağırlığını** taşır (≈15 kg ≈ 120–155 mbar). Bu yüzden ekranda basınç hiç sıfır olmaz; bu normaldir, ileride çıkarılır.

**Kodda nerede?** `src/SliperModel.h` → `agirliktanBasincMbar()`

### Adım D — Stroke'u yakalama

**Ne oluyor?** "Stroke" = borunun bir kez yukarıdan aşağı kayması. Program konuma bakarak borunun nerede olduğunu anlar:

| Trafik ışığı | Durum | Anlamı |
|---|---|---|
| 🟢 Yeşil | YUKARIDA | Boru üstte, bekliyor |
| 🟡 Sarı | İNİYOR | Boru üst konumdan ayrıldı, kayıyor |
| 🔴 Kırmızı | TAMAMLANDI | Boru alta ulaştı, stroke bitti |

Üst ve alt konumu **Kalibrasyon → Stroke Konumları** sayfasında siz kaydedersiniz. Sizin cihazınızda mesafe sensörü tepede durduğu için boru indikçe mesafe **artar** (üst ≈ 100 mm, alt ≈ 540 mm). Program yönü bu iki değerden kendisi anlar.

Orijinal cihaz gibi, program stroke'un **2 saniye öncesini ve 2 saniye sonrasını** da saklar. Öncesi "bekleme basıncı"nı (P0l), sonrası "bitiş sonrası basıncı"nı (P0r) ölçmek içindir.

**Kodda nerede?** `src/Calculator.cpp` → `konumGuncelle()`. Süreler ve toleranslar (2 s, 5 mm vb.) `src/SliperModel.h` bölüm 4'te.

### Adım E — Bir stroke'tan iki sayı: p ve Q

Her stroke'un sonunda program iki sayı çıkarır. Örnek olarak kılavuzdaki 1. stroke:

**1) Stroke basıncı p** — "kaymayı zorlayan basınç"

- **P0l** = boru kıpırdamadan önceki bekleme basıncı (betonun ağırlığı) → **152,74 mbar**
- **Pmax** = kayma sırasındaki en yüksek basınç (0,3 s ortalamayla titreşim temizlenir) → **196,36 mbar**
- **p = Pmax − P0l** = 196,36 − 152,74 = **43,62 mbar**

Betonun ağırlığını çıkarıyoruz ki geriye sadece "kaymaya karşı direnç" kalsın.

**2) Debi Q** — "saatte ne kadar beton akardı"

- **Hız v**: boru ne kadar sürede ne kadar yol aldı. Kılavuzdaki stroke 0,5 m'yi 4,64 s'de almış → v = 0,5 ÷ 4,64 = **0,108 m/s**
  (Program daha hassas yapar: stroke'un baş ve son kısımlarını atar, ortasındaki konum-zaman noktalarına düz çizgi çeker, çizginin eğimi hızdır.)
- **Q = hız × boru alanı × 3600** = 0,108 × 0,01287 × 3600 = **4,99 m³/saat**

**Kodda nerede?** `src/Calculator.cpp` → `strokuBitir()` hangi noktaların kullanılacağını seçer. Hesaplar `src/SliperModel.cpp` içinde: `durgunBasincMbar()` (P0l, P0r), `filtreliMaksimum()` (Pmax), `strokeHiziMs()` (v), `hizdanDebiM3h()` (Q).

### Adım F — Hatalı stroke ("Wrong Stroke")

Şunlardan biri varsa stroke **hatalı** sayılır ve hesaba katılmaz:

- hız sıfır veya ters (boru kaymamış / takılmış)
- p sıfır veya negatif
- 5'ten az ölçüm noktası

**Kodda nerede?** `src/SliperModel.cpp` → `strokeGecersizNedeni()`

### Adım G — Bütün stroke'lardan bir doğru: A ve B

Farklı ağırlıklarla stroke atınca her biri bir (Q, p) noktası verir. Ağırlık arttıkça boru hızlanır, p de artar:

| Stroke | Q (m³/h) | p (mbar) |
|---|---|---|
| 1 | 4,99 | 43,62 |
| 2 | 6,75 | 50,74 |
| 3 | 8,07 | 58,61 |
| 4 | 9,45 | 65,44 |
| 5 | 14,85 | 98,26 |

Bu noktalardan geçen **en uygun düz çizgi** çizilir (en küçük kareler yöntemi; Excel'deki "eğilim çizgisi"nin aynısı):

**p = A + B × Q**

- **A = 13,60 mbar** → çizginin sıfır hızdaki değeri: "harekete başlamak için gereken basınç"
- **B = 5,636 mbar·h/m³** → çizginin eğimi: "hız arttıkça basınç ne kadar artıyor"
- **R²** → noktalar çizgiye ne kadar oturuyor (1,00 = kusursuz)

A büyükse beton "harekete geçmekte" zorlanır; B büyükse "hızlı pompalamada" zorlanır.

**Kodda nerede?** Hesap: `src/SliperModel.cpp` → `pqDogrusu()`. Uyarılar: `src/SliperModel.cpp` → `olcumUyarilari()`. Hangi stroke'ların katılacağı (geçerli + tabloda işaretli olanlar): `src/Database.cpp` → `binghamHesapla()`.

> Not: Veritabanında ve bazı ekran kodlarında A'ya `tau0`, B'ye `mu` denir. Bu eski bir isimlendirmedir; aslında A ve B'dir.

### Adım H — A ve B'yi "boru boyundan bağımsız" yapmak: a ve b

A ve B bizim cihazın boyutlarına bağlıdır (128 mm çap, 500 mm dolum). Başka bir cihazla veya gerçek pompa hattıyla karşılaştırmak için boyuttan kurtarırız:

- **a = çap × A ÷ (4 × dolum yüksekliği)** = 0,128 × 13,60 ÷ 2 = **0,871 mbar**
- **b = B × π × çap³ ÷ (16 × dolum yüksekliği)** = **4,642** (×1000 gösterilir, Schleibinger de öyle gösterir)

a ve b, Schleibinger cihazının gösterdiği "Yield Pressure a" ve "Pressure Gradient b" ile **aynı şeydir** ve doğrudan karşılaştırılabilir.

**Kodda nerede?** `src/SliperModel.h` → `schleibingerA()`, `schleibingerB()`

### Adım I — Pompa basıncı tahmini

Gerçek pompa hattının çapı (D), uzunluğu (L), istenen debi (Q) ve yüksekliği (h) girilir.

**Pompa basıncı = akma payı + hız payı + yükseklik payı**

- **akma payı** = 4 × L ÷ D × a
- **hız payı** = 16 × L × Q ÷ (π × D³) × b
- **yükseklik payı** = beton yoğunluğu × yerçekimi × h

**Örnek:** D = 126 mm boru, L = 50 m, Q = 10 m³/saat, düz hat (h = 0):

- akma payı = 4 × 50 ÷ 0,126 × 0,871 = 1382 mbar = **1,38 bar**
- hız payı = **5,91 bar**
- toplam = **7,29 bar**

Hat 10 m yukarı çıksaydı: + 2400 × 9,81 × 10 = **+2,35 bar**.

Bu formülün doğruluğunu kontrol ettik: Schleibinger kılavuzundaki tahmin tablolarını **birebir** veriyor (7,13 / 52,92 / 211,69 bar).

**Kodda nerede?** `src/SliperModel.cpp` → `basincTahmini()` (tek hesap), `tahminTablosu()` (Q1/Q2 × L2/L3/L4 tablosu)

### Adım J — "Pompalanabilir mi?"

Tahmin tablosundaki **en kötü durum** (hata payı dahil en yüksek basınç), girdiğiniz **pompa maksimum basıncı** ile karşılaştırılır:

- Hepsi pompa kapasitesinin altındaysa → **POMPALANABİLİR**
- Biri bile aşıyorsa → **POMPALAMA SORUNU**; hangi payın (akma / hız / yükseklik) baskın olduğuna göre öneri gösterilir.

**Kodda nerede?** `qml/pages/SonuclarPage.qml` → `durumBilgisi` (ekran), `src/ReportManager.cpp` (rapordaki durum satırı)

### Adım K — Kayıt ve çıktılar

- Her stroke, ham eğrisiyle birlikte veritabanına kaydedilir → `src/Database.cpp` → `strokeKaydet()`
- Excel (Schleibinger düzeninde) → `Database::xmlDisaAktar()`
- PDF rapor (grafikli) → `src/ReportManager.cpp` → `pdfOlustur()`
- Veritabanı dosyası: `%LOCALAPPDATA%\SLIPER\database\sliper.db`
- Rapor ve Excel dosyaları: `Belgeler\SliperRaporlari\`

### Adım L — Sesli komut (isteğe bağlı)

**Ne oluyor?** Eller betonla meşgulken ölçüm, dokunmadan sesle yönetilebilir. Ana ekrandaki **Sesli Komut** düğmesiyle açılır/kapanır. Tanıma **internetsiz**, bilgisayarın içinde (Vosk Türkçe modeli) yapılır.

Program sadece şu kelimeleri tanır; çevredeki gündelik konuşma bu dar listeye düşmediği için genelde yok sayılır:

| Söylenen | Ölçüm ekranında yaptığı |
|---|---|
| "başlat" / "başla" | Ölçümü başlatır |
| "durdur" | Ölçümü duraklatır |
| "devam" | Duraklatılmış ölçüme devam eder |
| "bitir" / "bitti" / "tamamla" ... | Ölçümü bitirme onayını açar |
| "ekle" | 1,6 kg ek ağırlık kaydeder |

Komutlar yalnızca **Ölçüm ekranı açıkken** uygulanır. Dinleme sırasında ekranın altında duyulan metin gösterilir.

**Kodda nerede?** `src/VoiceCommandManager.cpp` (aç/kapa, komut sinyalleri), `src/VoiceRecognitionWorker.cpp` → `grammarKelimeleri()` (tanınan kelimeler, mikrofon + Vosk, ayrı thread'de). Komutlara tepki: `qml/pages/OlcumPage.qml` → `Connections { target: voiceCommandManager }`. Model klasörü: `resources/vosk-model-small-tr-0.3` (derlemede exe'nin yanına kopyalanır).

---

## 4. Kod haritası

| Dosya | Ne işe yarar | Ne zaman açarsınız |
|---|---|---|
| `src/SliperModel.h/.cpp` | **Bütün formüller ve ayar sayıları**: cihaz ölçüleri, kalibrasyon okuma, stroke süreleri/toleransları, uyarı eşikleri, gösterim hesapları | Bir hesabı veya sayıyı merak ettiğinizde, boru değiştiğinde |
| `src/WifiManager.cpp/.h` | ESP32'den veri alır, SliperModel ile kg/mm/basınca çevirir, bağlantı | Bağlantı / sensör sorunu |
| `src/Calculator.cpp/.h` | Stroke'u yakalar, hangi örneklerin kullanılacağını seçer | Stroke algılanmıyorsa |
| `src/Database.cpp/.h` | Kayıt, A-B hesabı için stroke seçimi, Excel/CSV | Kayıt, dışa aktarma |
| `src/ReportManager.cpp/.h` | PDF rapor ve grafikleri | Rapor görünümü |
| `src/SensorManager.cpp/.h` | Anlık değerleri ekrana taşıyan ara katman | Nadiren |
| `src/VoiceCommandManager.cpp/.h` | Sesli komutu açıp kapatır, algılanan komutu sayfalara iletir | Sesli komut davranışı |
| `src/VoiceRecognitionWorker.cpp/.h` | Mikrofonu dinler, Vosk ile kelimeyi tanır (ayrı thread) | Tanınan kelimeler, mikrofon sorunu |
| `src/Backend.cpp/.h` | Giriş ekranı kullanıcı adı/şifre kontrolü | Şifre değişikliği |
| `main.cpp` | Programı başlatır, C++ sınıflarını QML'e tanıtır | Yeni bir sınıf eklendiğinde |
| `qml/pages/LoginPage.qml` | Giriş ekranı | Giriş ekranı |
| `qml/pages/DashboardPage.qml` | Ana menü, sayfa geçişleri, sesli komut düğmesi | Menü / gezinme |
| `qml/pages/OlcumPage.qml` | Ölçüm ekranı | Ölçüm ekranında değişiklik |
| `qml/pages/SonuclarPage.qml` | Sonuçlar, tablolar, grafikler, tahmin | Sonuç ekranında değişiklik |
| `qml/pages/KalibrasyonPage.qml` | Load cell, mesafe, eğim, stroke konumları kalibrasyonu | Kalibrasyon ekranı |
| `qml/pages/GecmisPage.qml` | Eski ölçümler, veritabanı yedekleme | Geçmiş ekranı |
| `qml/pages/RehberPage.qml` + `RehberMockup.qml` | Kullanım rehberi; adımları ekran canlandırmalarıyla gösterir | Rehber metni / görselleri |
| `qml/components/*.qml` | Ortak parçalar: su terazisi (eğim), tarih seçici, menü ikonu | Bu parçaların görünümü |
| `qml/Translations.qml` | Türkçe / İngilizce dil seçimi | Dil ayarı |
| `esp32/sliper_esp32/sliper_esp32.ino` | ESP32 yazılımı (sensör okuma) | Donanım/pin değişikliği |

## 5. "Şunu değiştirmek istersem nereye bakarım?"

| İstek | Dosya | Ne değişir |
|---|---|---|
| Boru çapı / dolum yüksekliği değişti | `src/SliperModel.h` | `BORU_CAPI_M`, `BORU_UZUNLUGU_M` |
| Pmax titreşim filtresi | `src/SliperModel.h` | `PMAKS_PENCERE` (15 örnek = 0,3 s) |
| Hatalı stroke kuralı | `src/SliperModel.cpp` | `strokeGecersizNedeni()` |
| Stroke öncesi/sonrası süre (2 s), konum toleransı (5 mm) | `src/SliperModel.h` bölüm 4 | `ONCESI_PENCERE_S`, `SONRASI_PENCERE_S`, `KONUM_TOLERANSI_MM` |
| Batarya göstergesini açmak | `src/WifiManager.h` + `src/SliperModel.h` bölüm 10 | `BATARYA_OLCUMU_AKTIF = true`, `BATARYA_BOLUCU_ORANI` |
| Veri kesinti uyarı süresi (1,5 s) | `src/WifiManager.h` | `VERI_KESINTI_MS` |
| Tahmin ayarlarının varsayılanı | `src/SliperModel.cpp` | `varsayilanTahminAyarlari()` |
| Ölçüm uyarıları (R² < 0,90 vb.) | `src/SliperModel.h` bölüm 7 | `MIN_R2`, `MIN_DEBI_ARALIGI_ORANI`, `MAKS_GECERSIZ_YUZDE` ... |
| Canlı hız göstergesinin yumuşaklığı | `src/SliperModel.h` bölüm 10 | `CANLI_HIZ_FILTRE_KATSAYISI` |
| Sesli komut kelimeleri | `src/VoiceRecognitionWorker.cpp` | `grammarKelimeleri()` ve `...Adaylari` listeleri (ikisi birlikte) |
| Sesli komutun sayfadaki karşılığı ("ekle" kaç kg) | `qml/pages/OlcumPage.qml` | `onEkleKomutu()` vb. |
| Giriş kullanıcı adı / şifresi | `src/Backend.cpp` | `girisYap()`, `sifreDogrula()` |

## 6. Sözlük

| Terim | Anlamı |
|---|---|
| **Stroke** | Borunun bir kez yukarıdan aşağı kayması |
| **P0l** | Stroke öncesi bekleme basıncı (betonun kendi ağırlığı) |
| **P0r** | Stroke sonrası bekleme basıncı |
| **Pmax** | Stroke sırasındaki en yüksek (filtrelenmiş) basınç |
| **p** | Stroke basıncı = Pmax − P0l (kaymaya karşı direnç) |
| **v** | Borunun kayma hızı (m/s) |
| **Q** | Debi = hız × boru alanı (m³/saat) |
| **A** | p–Q doğrusunun başlangıç değeri (mbar) — "harekete geçme direnci" |
| **B** | p–Q doğrusunun eğimi (mbar·h/m³) — "hıza bağlı direnç" |
| **a, b** | A ve B'nin cihaz boyutundan bağımsız hali (Schleibinger ile karşılaştırılabilir) |
| **R²** | Noktaların doğruya uyumu (1 = mükemmel, 0,90 altı şüpheli) |
| **Yağlama tabakası** | Boru cidarında oluşan ince çimento hamuru katmanı; A ve B aslında bu katmanın özellikleridir |

## 7. Orijinal cihazdan bilinen farklar

| Konu | Orijinal SLIPER | Bizim cihaz | Etkisi |
|---|---|---|---|
| Basınç sensörü | Piston yüzeyinde, betona doğrudan temas | Load cell, üstündeki diskte conta var | Conta sürtünmesi ölçüme karışır; A biraz yüksek çıkabilir. Boş boruyla ölçülüp düzeltilebilir (henüz yapılmadı) |
| Boru çapı | 125 mm | 128 mm | Yazılım hesaba katıyor; a ve b karşılaştırılabilir |
| Basınç okuma hızı | Yüksek | 10/saniye (HX711 modülü) | Yeterli; stroke başına 13–46 okuma |
| Ek ağırlıklar | 3 × 1,6 kg + 3 × 4,8 kg | 3 × 1,6 kg | Hız aralığı dar kalırsa program uyarır |
| Batarya göstergesi | Var | Kapalı | Bölücü dirençleri öğrenilince açılacak |

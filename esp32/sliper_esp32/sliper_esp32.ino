/*
 * SLIPER - ESP32-S3 Firmware (WiFi SoftAP + TCP Versiyonu)
 * -----------------------------------------------------
 * Sensorler:
 *   - MPU6050        : Ham ivme (X/Y/Z)        -> I2C
 *   - HX711 + S-tipi load cell : Ham agirlik    -> Dijital (DT/SCK)
 *   - ATEK LMS lazer : Konum (ham ADC, Qt tarafinda mm'e kalibre ediliyor, ADS1115 uzerinden) -> I2C
 *
 * NOT: Turetilmis hesaplamalar (basinc kalibrasyonu, hiz, debi, egim acisi)
 * artik ESP32'de degil, Qt/PC tarafinda yapiliyor. ESP32 sadece ham veri
 * gonderiyor - islemci yukunu azaltmak ve kalibrasyon degerlerini
 * yeniden derleme yapmadan Qt tarafinda ayarlayabilmek icin.
 *
 * NOT: I2C_SDA/I2C_SCL degerleri, fiziksel kablolamada SDA/SCL'nin
 * ters baglanmis olmasi nedeniyle yazilimsal olarak yer degistirilmistir.
 */

#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <HX711.h>
#include <Adafruit_ADS1X15.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include <esp_system.h>

// ---------------- Pin Tanimlari ----------------
#define I2C_SDA 18
#define I2C_SCL 17

#define HX711_DT 39
#define HX711_SCK 40

// Batarya voltaj olcumu: ADS1115'in 3. kanali (index 3) mesafe sensoru
// icin kullaniliyor, bu yuzden batarya icin 0. kanal ayrildi.
// TODO: Gercek voltaj bolucu direnc degerleri (R1/R2) donanima baglanip
// bir multimetreyle dogrulandiktan sonra Qt tarafindaki
// SliperModel::BATARYA_BOLUCU_ORANI degeri (src/SliperModel.h) buna gore kalibre edilmelidir.
// Su an bu deger yer tutucu (placeholder) bir varsayimdir.
// DIKKAT: ADS1115 girisi VDD+0.3 V'u (3.6 V) asmamalidir. 14.7 V pil icin
// en az 1:5 oraninda bolucu gerekir (ornegin 100k / 22k -> ~2.65 V).
#define BATARYA_ADS_KANALI 0

// ---------------- Nesneler ----------------
Adafruit_MPU6050 mpu;
HX711 loadCell;
Adafruit_ADS1115 ads;

bool mpuHazir = false;
unsigned long sonMpuDenemeMs = 0;
const unsigned long MPU_DENEME_ARALIGI_MS = 2000;

// ADS1115 baslangicta bulunamazsa (sensorsuz test / henuz kablolanmamis
// donanim), hamMesafeOku()/hamBataryaOku() ic I2C cagrilarini calistirmaya
// devam etmek loop()'u kilitleyebiliyordu: bazi ESP32 core surumlerinde
// ACK vermeyen bir I2C adresine Wire istegi zaman asimi olmadan asili
// kalabiliyor, bu da TCP'ye hic paket gonderilmemesine (baglanti "acik"
// gorunse bile veri akmamasina) yol aciyordu. MPU6050'deki mpuHazir
// deseninin ayni: hazir degilse I2C'ye hic dokunmadan 0 dondurulur.
bool adsHazir = false;
unsigned long sonAdsDenemeMs = 0;
const unsigned long ADS_DENEME_ARALIGI_MS = 2000;

// Sensor I2C adresleri: her okumadan once cihazin hala cevap verdigi
// dogrulanir (asagidaki i2cCihazCevapVeriyor).
const uint8_t ADS1115_I2C_ADRESI = 0x48;
const uint8_t MPU6050_I2C_ADRESI = 0x68;
// ADS1115 860 SPS'te bir donusumu ~1.2 ms'de bitirir; bu sureyi asarsa
// cihaz kaybolmus demektir ve beklemeden cikilir.
const unsigned long ADS_DONUSUM_ZAMAN_ASIMI_MS = 20;

// I2C hattinin genel sagligi: cevapsiz deneme sayaci bu esige ulasinca
// surucu bastan kurulur (bkz. i2cVeriYoluSagliginiKontrolEt).
unsigned long i2cHataSayaci = 0;
unsigned long i2cYenidenKurmaSayisi = 0;
const unsigned long I2C_YENIDEN_KURMA_ESIGI = 10;

// ---------------- WiFi SoftAP Ayarlari ----------------
const char *WIFI_SSID = "SLIPER-ESP32";
const char *WIFI_SIFRE = "sliper1234"; // en az 8 karakter olmali
const uint16_t TCP_PORT = 8888;

WiFiServer tcpSunucu(TCP_PORT);
WiFiClient bagliIstemci;

// Kartin en son neden yeniden basladigini seri porta yazar. Baglanti
// kopmalarinin sebebini ayirt etmenin en hizli yolu budur.
void yenidenBaslatmaSebebiniYazdir() {
    const esp_reset_reason_t sebep = esp_reset_reason();
    Serial.print("Yeniden baslatma sebebi: ");
    switch (sebep) {
        case ESP_RST_POWERON:  Serial.println("Normal guc verme."); break;
        case ESP_RST_SW:       Serial.println("Yazilimsal reset."); break;
        case ESP_RST_PANIC:    Serial.println("PANIC/exception - kod cokmus!"); break;
        case ESP_RST_TASK_WDT: Serial.println("TASK WATCHDOG - loop() kilitlenmis!"); break;
        case ESP_RST_INT_WDT:  Serial.println("INTERRUPT WATCHDOG - kesme kilitlenmis!"); break;
        case ESP_RST_WDT:      Serial.println("WATCHDOG."); break;
        case ESP_RST_BROWNOUT: Serial.println("BROWNOUT - besleme voltaji dustu!"); break;
        case ESP_RST_DEEPSLEEP:Serial.println("Derin uykudan uyanma."); break;
        default:               Serial.println(sebep); break;
    }
}

void setup() {
    Serial.begin(115200);
    delay(200);

    // Onceki calismanin nasil bittigini soyler: kart beklenmedik sekilde
    // yeniden baslayip baglantiyi dusuruyorsa sebebi burada gorunur.
    //   TASK_WDT -> loop() bir yerde kilitlendi (I2C / bloklayan yazma)
    //   BROWNOUT -> besleme voltaji dustu (pil / kondansator sorunu)
    yenidenBaslatmaSebebiniYazdir();

    Wire.begin(I2C_SDA, I2C_SCL);
    Wire.setClock(100000);
    // Kablo gevserse / cihaz ACK vermezse Wire cagrilari suresiz asili kalmasin.
    Wire.setTimeOut(50);
    delay(100);

    // MPU6050 baslat (once hatta var mi diye bakilir; bkz. i2cCihazCevapVeriyor)
    if (!i2cCihazKararliCevapVeriyor(MPU6050_I2C_ADRESI) || !mpu.begin()) {
        Serial.println("MPU6050 bulunamadi! Loop icinde tekrar denenecek.");
        mpuHazir = false;
    } else {
        mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
        mpu.setGyroRange(MPU6050_RANGE_250_DEG);
        mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
        Serial.println("MPU6050 hazir.");
        mpuHazir = true;
    }

    // HX711 baslat
    loadCell.begin(HX711_DT, HX711_SCK);
    if (loadCell.wait_ready_timeout(2000)) {
        Serial.println("HX711 hazir.");
    } else {
        Serial.println("HX711 bulunamadi!");
    }

    // ADS1115 baslat (once hatta var mi diye bakilir; bkz. i2cCihazCevapVeriyor)
    if (!i2cCihazKararliCevapVeriyor(ADS1115_I2C_ADRESI) || !ads.begin()) {
        Serial.println("ADS1115 bulunamadi!");
        adsHazir = false;
    } else {
        ads.setGain(GAIN_ONE);
        // Varsayilan 128 SPS'te tek okuma ~8 ms surer; 860 SPS ile ~1.2 ms.
        ads.setDataRate(RATE_ADS1115_860SPS);
        Serial.println("ADS1115 hazir.");
        adsHazir = true;
    }

    // WiFi SoftAP baslat
    WiFi.softAP(WIFI_SSID, WIFI_SIFRE);
    // Guc tasarrufu modu 50 Hz akista paket gecikmelerine ve kopmalara yol aciyor.
    WiFi.setSleep(false);
    Serial.print("SoftAP baslatildi. IP adresi: ");
    Serial.println(WiFi.softAPIP()); // Varsayilan: 192.168.4.1

    tcpSunucu.begin();
    Serial.println("TCP sunucu baslatildi, baglanti bekleniyor...");
}

// ---------------- Ornekleme ----------------
// Stroke'lar 1.5-5 s surer; plato/Pmax ve hiz regresyonu icin stroke basina
// en az ~50 ornek gerekir. Bu yuzden 20 ms (50 Hz) aralikla gonderilir.
// NOT: Kullanilan HX711 modulunde RATE pini kart uzerinde GND'ye sabit,
// yani 10 SPS calisir: basinc saniyede 10 kez yenilenir, arada son deger
// tekrar gonderilir. Stroke basina 13-46 basinc okumasi dusar, bu yeterlidir;
// 10 SPS ayrica 50 Hz sebeke gurultusunu bastirir. Konum 50 Hz'de okunur.
const unsigned long ORNEK_ARALIGI_MS = 20;
const unsigned long BATARYA_ARALIGI_MS = 1000;
const unsigned long MPU_ARALIGI_MS = 100;

#define SERI_DEBUG 0

unsigned long sonOrnekMs = 0;
unsigned long sonBataryaMs = 0;
unsigned long sonMpuMs = 0;
long sonHamAgirlik = 0;
unsigned long atlananPaketSayisi = 0;
unsigned long gonderilenPaketSayisi = 0;
unsigned long artArdaAtlananPaket = 0;
unsigned long sonDurumYazisiMs = 0;
// Tampon dolu raporlansa bile bu kadar paket ust uste atlandiysa yazma zorlanir.
const unsigned long ZORLA_GONDER_ESIGI = 10;
// Loop'un yasadigini gosteren saniyelik seri port ozeti.
const unsigned long DURUM_YAZISI_ARALIGI_MS = 1000;
int16_t sonHamBatarya = 0;
float sonAccelX = 0, sonAccelY = 0, sonAccelZ = 0;

// Bloklamaz: HX711 yeni donusum hazirsa okur, degilse son degeri korur.
void hamAgirlikGuncelle() {
    if (loadCell.is_ready()) {
        sonHamAgirlik = loadCell.read();
    }
}

// I2C cihazi hala yerinde mi: kisa bir adres sorgusu yapar, ACK gelmezse false.
// Wire.setTimeOut() sayesinde bu cagri en fazla birkac on ms surer.
//
// DIKKAT - bos bir beginTransmission/endTransmission ciftini ("probe") ESP32
// core 3.3.8 surucusu i2c_master_probe() ile karsilar; sensor kablosu
// kopuk/gevsek oldugunda bu fonksiyon I2C kesme isleyicisinde cokuyor
// (Guru Meditation / StoreProhibited) ve kart resetleniyor. Bu yuzden adres
// sorgusuna tek bayt eklenir: surucu bunu normal bir yazma islemi olarak
// isler, probe koduna hic girmez. Yazilan deger cihazlarin register
// isaretcisidir, zararsizdir.
bool i2cCihazCevapVeriyor(uint8_t adres) {
    Wire.beginTransmission(adres);
    Wire.write((uint8_t)0x00);
    return Wire.endTransmission() == 0;
}

// Bosta kalan (pull-up'siz) bir I2C hatti rastgele ACK uretebilir. Cihazi var
// saymadan once ust uste iki kez dogrulanir; aksi halde Adafruit begin()
// fonksiyonlari kendi probe cagrilariyla yine cokme riskine girer.
bool i2cCihazKararliCevapVeriyor(uint8_t adres) {
    if (!i2cCihazCevapVeriyor(adres)) return false;
    delay(2);
    return i2cCihazCevapVeriyor(adres);
}

// Art arda cok sayida I2C hatasi, hattin (kablo gevsemesi / kisa devre)
// bozuldugunu gosterir. Bu durumda tek tek cihaz denemek yerine surucu
// bastan kurulur; takilmis bir veri yolu ancak boyle toparlanir.
void i2cVeriYoluSagliginiKontrolEt() {
    if (i2cHataSayaci < I2C_YENIDEN_KURMA_ESIGI) return;

    Serial.println("I2C hatti cevapsiz, veri yolu yeniden kuruluyor...");
    Wire.end();
    delay(50);
    Wire.begin(I2C_SDA, I2C_SCL);
    Wire.setClock(100000);
    Wire.setTimeOut(50);
    i2cHataSayaci = 0;
    i2cYenidenKurmaSayisi++;
}

// ADS1115'ten tek kanal okur. Kutuphanenin readADC_SingleEnded() fonksiyonu
// donusumun bitmesini kosulsuz bekler; test sirasindaki titresim I2C kablosunu
// gevsetirse bu bekleme bitmez, loop() durur ve PC tarafi 5 s veri gelmediginde
// baglantiyi koparir. Bu yuzden okuma once ACK ile dogrulanir, sonra donusum
// zaman asimli beklenir; sorun varsa adsHazir false yapilip yeniden baslatma
// dongusune birakilir.
int16_t adsKanalOku(uint8_t kanal) {
    if (!adsHazir) return 0;

    if (!i2cCihazCevapVeriyor(ADS1115_I2C_ADRESI)) {
        Serial.println("ADS1115 cevap vermiyor, yeniden baslatilacak.");
        adsHazir = false;
        i2cHataSayaci++;
        return 0;
    }

    ads.startADCReading(MUX_BY_CHANNEL[kanal], /*continuous=*/false);

    const unsigned long baslangicMs = millis();
    while (!ads.conversionComplete()) {
        if (millis() - baslangicMs > ADS_DONUSUM_ZAMAN_ASIMI_MS) {
            Serial.println("ADS1115 donusumu zaman asimina ugradi.");
            adsHazir = false;
            return 0;
        }
    }

    return ads.getLastConversionResults();
}

int16_t hamMesafeOku() {
    return adsKanalOku(3);
}

int16_t hamBataryaOku() {
    return adsKanalOku(BATARYA_ADS_KANALI);
}

void loop() {
    // Kopmus istemci serbest birakilmazsa soket tanimlayicisi sizar ve bir sure
    // sonra yeni baglantilar kabul edilemez olur.
    if (bagliIstemci && !bagliIstemci.connected()) {
        bagliIstemci.stop();
        Serial.println("PC baglantisi kapandi.");
    }

    WiFiClient yeniIstemci = tcpSunucu.available();
    if (yeniIstemci) {
        if (bagliIstemci) {
            bagliIstemci.stop();
        }
        bagliIstemci = yeniIstemci;
        // Kucuk paketlerin Nagle algoritmasiyla bekletilip toplu gitmesini engeller.
        bagliIstemci.setNoDelay(true);
        Serial.println("PC baglandi.");
    }

    if (!mpuHazir && millis() - sonMpuDenemeMs > MPU_DENEME_ARALIGI_MS) {
        sonMpuDenemeMs = millis();
        // Once ucuz ACK sorgusu: cihaz hatta yoksa begin() cagrilmaz.
        // (bkz. i2cVeriYoluSagliginiKontrolEt - surekli begin() denemesi
        // ESP32 core 3.x I2C surucusunu cokertiyor.)
        if (!i2cCihazKararliCevapVeriyor(MPU6050_I2C_ADRESI)) {
            i2cHataSayaci++;
        } else if (mpu.begin()) {
            mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
            mpu.setGyroRange(MPU6050_RANGE_250_DEG);
            mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
            Serial.println("MPU6050 sonradan hazir oldu.");
            mpuHazir = true;
        } else {
            Serial.println("MPU6050 hala bulunamadi, tekrar denenecek...");
        }
    }

    if (!adsHazir && millis() - sonAdsDenemeMs > ADS_DENEME_ARALIGI_MS) {
        sonAdsDenemeMs = millis();
        if (!i2cCihazKararliCevapVeriyor(ADS1115_I2C_ADRESI)) {
            i2cHataSayaci++;
        } else if (ads.begin()) {
            ads.setGain(GAIN_ONE);
            ads.setDataRate(RATE_ADS1115_860SPS);
            Serial.println("ADS1115 sonradan hazir oldu.");
            adsHazir = true;
            i2cHataSayaci = 0;
        } else {
            Serial.println("ADS1115 ACK veriyor ama baslatilamadi.");
        }
    }

    // Hat uzun suredir cevapsizsa I2C surucusunu komple yeniden kur: kablo
    // gevsemesinden sonra surucu bazen takili kaliyor ve tek tek denemeler
    // sonsuza kadar basarisiz oluyor.
    i2cVeriYoluSagliginiKontrolEt();

    hamAgirlikGuncelle();

    const unsigned long simdi = millis();
    if (simdi - sonOrnekMs < ORNEK_ARALIGI_MS) {
        return;
    }
    sonOrnekMs = simdi;

    const int16_t hamMesafe = hamMesafeOku();

    if (simdi - sonBataryaMs >= BATARYA_ARALIGI_MS) {
        sonBataryaMs = simdi;
        sonHamBatarya = hamBataryaOku();
    }

    if (mpuHazir && simdi - sonMpuMs >= MPU_ARALIGI_MS) {
        sonMpuMs = simdi;
        // ADS1115'teki ile ayni koruma: cihaz kaybolduysa getEvent() icinde
        // beklemek yerine mpuHazir dusurulur ve yeniden baglanma denenir.
        if (!i2cCihazCevapVeriyor(MPU6050_I2C_ADRESI)) {
            Serial.println("MPU6050 cevap vermiyor, yeniden baslatilacak.");
            mpuHazir = false;
            i2cHataSayaci++;
        } else {
            sensors_event_t ivme, gyro, sicaklik;
            mpu.getEvent(&ivme, &gyro, &sicaklik);
            sonAccelX = ivme.acceleration.x;
            sonAccelY = ivme.acceleration.y;
            sonAccelZ = ivme.acceleration.z;
        }
    }

    StaticJsonDocument<256> doc;
    // Zaman damgasi: Qt tarafi hiz/debiyi bu degerden hesaplar
    // (paketin PC'ye varis zamani WiFi/TCP gecikmesi nedeniyle guvenilmez).
    doc["t"] = simdi;
    doc["hamAgirlik"] = sonHamAgirlik;
    doc["hamMesafe"] = hamMesafe;
    doc["hamBatarya"] = sonHamBatarya;
    doc["accelX"] = round(sonAccelX * 1000) / 1000.0;
    doc["accelY"] = round(sonAccelY * 1000) / 1000.0;
    doc["accelZ"] = round(sonAccelZ * 1000) / 1000.0;

    String json;
    serializeJson(doc, json);
    json += "\n";

    // Wi-Fi sinyali zayifladiginda lwIP gonderim tamponu dolar ve print()
    // bloklar; loop() durdugu icin PC tarafi veri akisi kesildi sanip
    // baglantiyi koparir. Tamponda yer yoksa bu paket atlanir: 50 Hz'de tek
    // ornegin kaybi onemsiz, baglantinin kopmasi degil.
    if (bagliIstemci && bagliIstemci.connected()) {
        // ESP32 core surumlerinin bir kismi availableForWrite()'i her zaman
        // dogru raporlamaz; sirf bu yuzden hic veri gonderilmemesini onlemek
        // icin art arda belli sayida atlamadan sonra yazma yine de denenir.
        const bool tamponYeterli = bagliIstemci.availableForWrite() >= (int)json.length();
        if (tamponYeterli || artArdaAtlananPaket >= ZORLA_GONDER_ESIGI) {
            bagliIstemci.print(json);
            artArdaAtlananPaket = 0;
            gonderilenPaketSayisi++;
        } else {
            artArdaAtlananPaket++;
            atlananPaketSayisi++;
        }
    }

    // Loop'un hala dondugunu ve akisin durumunu gosteren saniyelik ozet:
    // seri monitorde bu satir durursa loop() kilitlenmis demektir.
    if (simdi - sonDurumYazisiMs >= DURUM_YAZISI_ARALIGI_MS) {
        sonDurumYazisiMs = simdi;
        Serial.printf("[%lus] istemci=%d gonderilen=%lu atlanan=%lu ads=%d mpu=%d hx=%d i2cHata=%lu i2cReset=%lu\n",
                      simdi / 1000,
                      (bagliIstemci && bagliIstemci.connected()) ? 1 : 0,
                      gonderilenPaketSayisi, atlananPaketSayisi,
                      adsHazir ? 1 : 0, mpuHazir ? 1 : 0,
                      loadCell.is_ready() ? 1 : 0,
                      i2cHataSayaci, i2cYenidenKurmaSayisi);
    }

#if SERI_DEBUG
    Serial.print(json);
#endif
}
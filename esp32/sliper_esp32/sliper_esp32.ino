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

// ---------------- WiFi SoftAP Ayarlari ----------------
const char *WIFI_SSID = "SLIPER-ESP32";
const char *WIFI_SIFRE = "sliper1234"; // en az 8 karakter olmali
const uint16_t TCP_PORT = 8888;

WiFiServer tcpSunucu(TCP_PORT);
WiFiClient bagliIstemci;

void setup() {
    Serial.begin(115200);
    delay(200);

    Wire.begin(I2C_SDA, I2C_SCL);
    Wire.setClock(100000);
    delay(100);

    // MPU6050 baslat
    if (!mpu.begin()) {
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

    // ADS1115 baslat
    if (!ads.begin()) {
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
int16_t sonHamBatarya = 0;
float sonAccelX = 0, sonAccelY = 0, sonAccelZ = 0;

// Bloklamaz: HX711 yeni donusum hazirsa okur, degilse son degeri korur.
void hamAgirlikGuncelle() {
    if (loadCell.is_ready()) {
        sonHamAgirlik = loadCell.read();
    }
}

int16_t hamMesafeOku() {
    if (!adsHazir) return 0;
    return ads.readADC_SingleEnded(3);
}

int16_t hamBataryaOku() {
    if (!adsHazir) return 0;
    return ads.readADC_SingleEnded(BATARYA_ADS_KANALI);
}

void loop() {
    WiFiClient yeniIstemci = tcpSunucu.available();
    if (yeniIstemci) {
        if (bagliIstemci && bagliIstemci.connected()) {
            bagliIstemci.stop();
        }
        bagliIstemci = yeniIstemci;
        // Kucuk paketlerin Nagle algoritmasiyla bekletilip toplu gitmesini engeller.
        bagliIstemci.setNoDelay(true);
        Serial.println("PC baglandi.");
    }

    if (!mpuHazir && millis() - sonMpuDenemeMs > MPU_DENEME_ARALIGI_MS) {
        sonMpuDenemeMs = millis();
        if (mpu.begin()) {
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
        if (ads.begin()) {
            ads.setGain(GAIN_ONE);
            ads.setDataRate(RATE_ADS1115_860SPS);
            Serial.println("ADS1115 sonradan hazir oldu.");
            adsHazir = true;
        } else {
            Serial.println("ADS1115 hala bulunamadi, tekrar denenecek...");
        }
    }

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
        sensors_event_t ivme, gyro, sicaklik;
        mpu.getEvent(&ivme, &gyro, &sicaklik);
        sonAccelX = ivme.acceleration.x;
        sonAccelY = ivme.acceleration.y;
        sonAccelZ = ivme.acceleration.z;
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

    if (bagliIstemci && bagliIstemci.connected()) {
        bagliIstemci.print(json);
    }

#if SERI_DEBUG
    Serial.print(json);
#endif
}
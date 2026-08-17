/*
 * SLIPER - ESP32-S3 Firmware (WiFi SoftAP + TCP Versiyonu)
 * -----------------------------------------------------
 * Sensorler:
 *   - MPU6050        : Ham ivme (X/Y/Z)        -> I2C
 *   - HX711 + S-tipi load cell : Ham agirlik    -> Dijital (DT/SCK)
 *   - ATEK LMS lazer : Konum (mm, ADS1115 uzerinden) -> I2C
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

// ---------------- Lazer Mesafe Sensoru Olcek Sabitleri ----------------
const float LAZER_MAX_MESAFE_MM = 2000.0f;
const float LAZER_MAX_VOLTAJ = 5.0f;

// ---------------- Nesneler ----------------
Adafruit_MPU6050 mpu;
HX711 loadCell;
Adafruit_ADS1115 ads;

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
        Serial.println("MPU6050 bulunamadi!");
    } else {
        mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
        mpu.setGyroRange(MPU6050_RANGE_250_DEG);
        mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
        Serial.println("MPU6050 hazir.");
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
    } else {
        ads.setGain(GAIN_ONE);
        Serial.println("ADS1115 hazir.");
    }

    // WiFi SoftAP baslat
    WiFi.softAP(WIFI_SSID, WIFI_SIFRE);
    Serial.print("SoftAP baslatildi. IP adresi: ");
    Serial.println(WiFi.softAPIP()); // Varsayilan: 192.168.4.1

    tcpSunucu.begin();
    Serial.println("TCP sunucu baslatildi, baglanti bekleniyor...");
}

long hamAgirlikOku() {
    if (!loadCell.is_ready()) return 0;
    return loadCell.read_average(3);
}

float konumOku() {
    int16_t adcDeger = ads.readADC_SingleEnded(3);
    float voltaj = ads.computeVolts(adcDeger);
    if (voltaj < 0) voltaj = 0;
    if (voltaj > LAZER_MAX_VOLTAJ) voltaj = LAZER_MAX_VOLTAJ;
    return (voltaj / LAZER_MAX_VOLTAJ) * LAZER_MAX_MESAFE_MM;
}

void loop() {
    if (!bagliIstemci || !bagliIstemci.connected()) {
        WiFiClient yeniIstemci = tcpSunucu.available();
        if (yeniIstemci) {
            bagliIstemci = yeniIstemci;
            Serial.println("PC baglandi.");
        }
    }

    long hamAgirlik = hamAgirlikOku();
    float konum = konumOku();

    sensors_event_t ivme, gyro, sicaklik;
    mpu.getEvent(&ivme, &gyro, &sicaklik);

    StaticJsonDocument<256> doc;
    doc["hamAgirlik"] = hamAgirlik;
    doc["konum"] = round(konum * 100) / 100.0;
    doc["accelX"] = round(ivme.acceleration.x * 1000) / 1000.0;
    doc["accelY"] = round(ivme.acceleration.y * 1000) / 1000.0;
    doc["accelZ"] = round(ivme.acceleration.z * 1000) / 1000.0;

    String json;
    serializeJson(doc, json);
    json += "\n";

    if (bagliIstemci && bagliIstemci.connected()) {
        bagliIstemci.print(json);
    }

    Serial.println(json);

    delay(200);
}
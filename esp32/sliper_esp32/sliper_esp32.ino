/*
 * SLIPER - ESP32-S3 Firmware (BLE UART Versiyonu)
 * -----------------------------------------------------
 * Sensorler:
 *   - MPU6050        : Egim (X/Y derece)      -> I2C
 *   - HX711 + S-tipi load cell : Basinc (mbar) -> Dijital (DT/SCK)
 *   - ATEK LMS lazer : Mesafe (Analog 0-5V)   -> ADS1115 uzerinden I2C
 *
 * Cikis: Bluetooth Low Energy (BLE) uzerinden, her 200ms'de bir JSON paketi
 */

#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <HX711.h>
#include <Adafruit_ADS1X15.h>
#include <ArduinoJson.h>

// --- BLE Kutuphaneleri ---
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// ---------------- Pin Tanimlari ----------------
#define I2C_SDA 17
#define I2C_SCL 18

#define HX711_DT 39
#define HX711_SCK 40

// ---------------- Kalibrasyon Sabitleri ----------------
float hx711_kalibrasyonKatsayisi = 2280.0f; 
long  hx711_sifirOfset = 0;

const float LAZER_MAX_MESAFE_MM = 2000.0f;
const float LAZER_MAX_VOLTAJ = 5.0f;

const float BORU_CAPI_M = 0.126f;
const float BORU_ALANI_M2 = 3.14159265f * (BORU_CAPI_M / 2.0f) * (BORU_CAPI_M / 2.0f);

// ---------------- Nesneler ----------------
Adafruit_MPU6050 mpu;
HX711 loadCell;
Adafruit_ADS1115 ads;

// ---------------- BLE Ayarlari ----------------
BLEServer *pServer = NULL;
BLECharacteristic * pTxCharacteristic;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// Standart Nordic UART Service (NUS) UUID'leri
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" 
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

// ---------------- Durum Degiskenleri ----------------
float onceki_konum_mm = 0.0f;
unsigned long onceki_zaman_ms = 0;

void setup() {
    Serial.begin(115200);
    Wire.begin(I2C_SDA, I2C_SCL);

    // --- BLE Baslatma ---
    BLEDevice::init("SLIPER-ESP32");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());
    BLEService *pService = pServer->createService(SERVICE_UUID);

    // TX Karakteristigi (ESP32'den veri gondermek icin)
    pTxCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_TX,
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
    pTxCharacteristic->addDescriptor(new BLE2902());
    pService->start();
    pServer->getAdvertising()->start();
    Serial.println("BLE baslatildi: SLIPER-ESP32 (Baglanti bekleniyor...)");

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
        hx711_sifirOfset = loadCell.read_average(10);
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

    onceki_zaman_ms = millis();
}

float basincOku() {
    if (!loadCell.is_ready()) return 0.0f;
    long ham = loadCell.read_average(3);
    float agirlikGram = (ham - hx711_sifirOfset) / hx711_kalibrasyonKatsayisi;
    return agirlikGram * 0.0981f; 
}

float konumOku() {
    int16_t adcDeger = ads.readADC_SingleEnded(3); 
    float voltaj = ads.computeVolts(adcDeger);
    if (voltaj < 0) voltaj = 0;
    if (voltaj > LAZER_MAX_VOLTAJ) voltaj = LAZER_MAX_VOLTAJ;
    return (voltaj / LAZER_MAX_VOLTAJ) * LAZER_MAX_MESAFE_MM;
}

void egimOku(float &egimX, float &egimY) {
    sensors_event_t ivme, gyro, sicaklik;
    mpu.getEvent(&ivme, &gyro, &sicaklik);
    egimX = atan2(ivme.acceleration.y, ivme.acceleration.z) * 180.0f / PI;
    egimY = atan2(-ivme.acceleration.x,
                   sqrt(ivme.acceleration.y * ivme.acceleration.y +
                        ivme.acceleration.z * ivme.acceleration.z)) * 180.0f / PI;
}

void loop() {
    float basinc = basincOku();
    float konum = konumOku();

    unsigned long simdikiZaman = millis();
    float dt = (simdikiZaman - onceki_zaman_ms) / 1000.0f;
    if (dt <= 0) dt = 0.001f;

    float hiz = fabs(konum - onceki_konum_mm) / 1000.0f / dt;
    float debi = hiz * BORU_ALANI_M2 * 3600.0f;

    onceki_konum_mm = konum;
    onceki_zaman_ms = simdikiZaman;

    float egimX = 0, egimY = 0;
    egimOku(egimX, egimY);

    StaticJsonDocument<256> doc;
    doc["basinc"] = round(basinc * 100) / 100.0;
    doc["konum"] = round(konum * 100) / 100.0;
    doc["hiz"] = round(hiz * 100) / 100.0;
    doc["debi"] = round(debi * 100) / 100.0;
    doc["egimX"] = round(egimX * 100) / 100.0;
    doc["egimY"] = round(egimY * 100) / 100.0;

    String json;
    serializeJson(doc, json);

    // Sadece cihaz bagliyken BLE uzerinden veri gonder
    if (deviceConnected) {
        pTxCharacteristic->setValue(json.c_str());
        pTxCharacteristic->notify(); // Veriyi karsi tarafa it (push)
    }

    Serial.println(json); // USB uzerinden hata ayiklama icin yazdir

    // BLE baglantisi koptugunda tekrar gorunur olmasini sagla
    if (!deviceConnected && oldDeviceConnected) {
        delay(500);
        pServer->startAdvertising();
        Serial.println("BLE cihazi koptu. Tekrar baglanti bekleniyor...");
        oldDeviceConnected = deviceConnected;
    }
    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }

    delay(200); 
}
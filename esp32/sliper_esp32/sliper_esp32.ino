#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <HX711.h>
#include <Adafruit_ADS1X15.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include <lwip/sockets.h>
#include <esp_system.h>

#define I2C_SDA 17
#define I2C_SCL 18

#define HX711_DT 39
#define HX711_SCK 38

const uint8_t TOF250_I2C_ADRESI = 0x52;
const uint8_t TOF250_MESAFE_REGISTERI = 0x00;
const long TOF250_MM_CARPANI = 1;
const unsigned long TOF250_OKUMA_ARALIGI_MS = 100;
const unsigned long TOF250_ZAMAN_ASIMI_MS = 500;
const long TOF250_MAKSIMUM_CM = 250;
const unsigned long HX711_ZAMAN_ASIMI_MS = 500;

#define BATARYA_ADS_KANALI 1

Adafruit_MPU6050 mpu;
HX711 loadCell;
Adafruit_ADS1115 ads;

bool mpuHazir = false;
unsigned long sonMpuDenemeMs = 0;
const unsigned long MPU_DENEME_ARALIGI_MS = 2000;

bool adsHazir = false;
unsigned long sonAdsDenemeMs = 0;
const unsigned long ADS_DENEME_ARALIGI_MS = 2000;

const uint8_t ADS1115_I2C_ADRESI = 0x48;
const uint8_t MPU6050_I2C_ADRESI = 0x68;
const unsigned long ADS_DONUSUM_ZAMAN_ASIMI_MS = 20;

unsigned long i2cHataSayaci = 0;
unsigned long i2cYenidenKurmaSayisi = 0;
const unsigned long I2C_YENIDEN_KURMA_ESIGI = 10;

const char *WIFI_SSID = "SLIPER-ESP32";
const char *WIFI_SIFRE = "sliper1234";
const uint16_t TCP_PORT = 8888;

WiFiServer tcpSunucu(TCP_PORT);
WiFiClient bagliIstemci;

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

    yenidenBaslatmaSebebiniYazdir();

    Wire.begin(I2C_SDA, I2C_SCL);
    Wire.setClock(100000);
    Wire.setTimeOut(50);
    delay(100);

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

    loadCell.begin(HX711_DT, HX711_SCK);
    if (loadCell.wait_ready_timeout(2000)) {
        Serial.println("HX711 hazir.");
    } else {
        Serial.println("HX711 bulunamadi!");
    }

    if (!i2cCihazKararliCevapVeriyor(ADS1115_I2C_ADRESI) || !ads.begin()) {
        Serial.println("ADS1115 bulunamadi!");
        adsHazir = false;
    } else {
        ads.setGain(GAIN_ONE);
        ads.setDataRate(RATE_ADS1115_860SPS);
        Serial.println("ADS1115 hazir.");
        adsHazir = true;
    }

    WiFi.softAP(WIFI_SSID, WIFI_SIFRE);
    WiFi.setSleep(false);
    Serial.print("SoftAP baslatildi. IP adresi: ");
    Serial.println(WiFi.softAPIP());

    tcpSunucu.begin();
    Serial.println("TCP sunucu baslatildi, baglanti bekleniyor...");
}

const unsigned long ORNEK_ARALIGI_MS = 20;
const unsigned long BATARYA_ARALIGI_MS = 1000;
const unsigned long MPU_ARALIGI_MS = 100;

#define SERI_DEBUG 0

unsigned long sonOrnekMs = 0;
unsigned long sonBataryaMs = 0;
unsigned long sonMpuMs = 0;
long sonHamAgirlik = 0;
unsigned long sonAgirlikZamaniMs = 0;
unsigned long atlananPaketSayisi = 0;
unsigned long gonderilenPaketSayisi = 0;
unsigned long sonDurumYazisiMs = 0;
const unsigned long DURUM_YAZISI_ARALIGI_MS = 1000;
int16_t sonHamBatarya = 0;
float sonAccelX = 0, sonAccelY = 0, sonAccelZ = 0;

bool soketYazmayaHazir(NetworkClient &istemci) {
    const int soket = istemci.fd();
    if (soket < 0) return false;

    fd_set yazmaKumesi;
    FD_ZERO(&yazmaKumesi);
    FD_SET(soket, &yazmaKumesi);
    struct timeval beklemeYok = {0, 0};
    return select(soket + 1, NULL, &yazmaKumesi, NULL, &beklemeYok) > 0;
}

void hamAgirlikGuncelle() {
    if (loadCell.is_ready()) {
        sonHamAgirlik = loadCell.read();
        sonAgirlikZamaniMs = millis();
    }
}

bool hx711Hazir() {
    return sonAgirlikZamaniMs != 0 && millis() - sonAgirlikZamaniMs < HX711_ZAMAN_ASIMI_MS;
}

bool i2cCihazCevapVeriyor(uint8_t adres) {
    Wire.beginTransmission(adres);
    Wire.write((uint8_t)0x00);
    return Wire.endTransmission() == 0;
}

bool i2cCihazKararliCevapVeriyor(uint8_t adres) {
    if (!i2cCihazCevapVeriyor(adres)) return false;
    delay(2);
    return i2cCihazCevapVeriyor(adres);
}

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

int16_t adsKanalOku(uint8_t kanal) {
    if (!adsHazir) return 0;

    if (!i2cCihazCevapVeriyor(ADS1115_I2C_ADRESI)) {
        Serial.println("ADS1115 cevap vermiyor, yeniden baslatilacak.");
        adsHazir = false;
        i2cHataSayaci++;
        return 0;
    }

    ads.startADCReading(MUX_BY_CHANNEL[kanal], false);

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

bool tofHamMesafeOku(uint16_t &hamMesafe) {
    Wire.beginTransmission(TOF250_I2C_ADRESI);
    Wire.write(TOF250_MESAFE_REGISTERI);
    if (Wire.endTransmission(false) != 0) {
        Wire.beginTransmission(TOF250_I2C_ADRESI);
        Wire.write(TOF250_MESAFE_REGISTERI);
        if (Wire.endTransmission(true) != 0) return false;
    }
    if (Wire.requestFrom((int)TOF250_I2C_ADRESI, 2) != 2) return false;
    const uint8_t yuksekBayt = Wire.read();
    const uint8_t dusukBayt = Wire.read();
    hamMesafe = ((uint16_t)yuksekBayt << 8) | dusukBayt;
    return true;
}

long sonMesafeMm = 0;
unsigned long sonMesafeZamaniMs = 0;
unsigned long sonTofOkumaMs = 0;

void tofMesafeGuncelle() {
    if (millis() - sonTofOkumaMs < TOF250_OKUMA_ARALIGI_MS) return;
    sonTofOkumaMs = millis();

    uint16_t hamMesafe;
    if (!tofHamMesafeOku(hamMesafe)) {
        i2cHataSayaci++;
        return;
    }
    const long mesafeMm = (long)hamMesafe * TOF250_MM_CARPANI;
    if (mesafeMm <= TOF250_MAKSIMUM_CM) {
        sonMesafeMm = mesafeMm;
        sonMesafeZamaniMs = millis();
    }
}

bool tofHazir() {
    return sonMesafeZamaniMs != 0 && millis() - sonMesafeZamaniMs < TOF250_ZAMAN_ASIMI_MS;
}

int16_t hamBataryaOku() {
    return adsKanalOku(BATARYA_ADS_KANALI);
}

void loop() {
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
        bagliIstemci.setNoDelay(true);
        Serial.println("PC baglandi.");
    }

    if (!mpuHazir && millis() - sonMpuDenemeMs > MPU_DENEME_ARALIGI_MS) {
        sonMpuDenemeMs = millis();
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

    i2cVeriYoluSagliginiKontrolEt();

    hamAgirlikGuncelle();
    tofMesafeGuncelle();

    const unsigned long simdi = millis();
    if (simdi - sonOrnekMs < ORNEK_ARALIGI_MS) {
        return;
    }
    sonOrnekMs = simdi;

    if (simdi - sonBataryaMs >= BATARYA_ARALIGI_MS) {
        sonBataryaMs = simdi;
        sonHamBatarya = hamBataryaOku();
    }

    if (mpuHazir && simdi - sonMpuMs >= MPU_ARALIGI_MS) {
        sonMpuMs = simdi;
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
    doc["t"] = simdi;
    doc["hamAgirlik"] = sonHamAgirlik;
    doc["hamMesafe"] = sonMesafeMm;
    doc["mesafeMm"] = sonMesafeMm;
    doc["tofGecerli"] = tofHazir();
    doc["hxGecerli"] = hx711Hazir();
    doc["hamBatarya"] = sonHamBatarya;
    doc["accelX"] = round(sonAccelX * 1000) / 1000.0;
    doc["accelY"] = round(sonAccelY * 1000) / 1000.0;
    doc["accelZ"] = round(sonAccelZ * 1000) / 1000.0;

    String json;
    serializeJson(doc, json);
    json += "\n";

    if (bagliIstemci && bagliIstemci.connected()) {
        if (soketYazmayaHazir(bagliIstemci)) {
            bagliIstemci.print(json);
            gonderilenPaketSayisi++;
        } else {
            atlananPaketSayisi++;
        }
    }

    if (simdi - sonDurumYazisiMs >= DURUM_YAZISI_ARALIGI_MS) {
        sonDurumYazisiMs = simdi;
        Serial.printf("[%lus] istemci=%d gonderilen=%lu atlanan=%lu tof=%d mesafe=%ldmm ads=%d mpu=%d hx=%d i2cHata=%lu i2cReset=%lu\n",
                      simdi / 1000,
                      (bagliIstemci && bagliIstemci.connected()) ? 1 : 0,
                      gonderilenPaketSayisi, atlananPaketSayisi,
                      tofHazir() ? 1 : 0, sonMesafeMm,
                      adsHazir ? 1 : 0, mpuHazir ? 1 : 0,
                      hx711Hazir() ? 1 : 0,
                      i2cHataSayaci, i2cYenidenKurmaSayisi);
    }

#if SERI_DEBUG
    Serial.print(json);
#endif
}
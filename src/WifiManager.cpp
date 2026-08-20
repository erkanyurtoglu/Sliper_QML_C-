#include "WifiManager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <cmath>

WifiManager::WifiManager(SensorManager *sensorManager, Database *database, QObject *parent)
    : QObject(parent)
    , m_sensorManager(sensorManager)
    , m_database(database)
{
    m_soket = new QTcpSocket(this);

    connect(m_soket, &QTcpSocket::connected, this, &WifiManager::soketBaglandi);
    connect(m_soket, &QTcpSocket::disconnected, this, &WifiManager::soketAyrildi);
    connect(m_soket, &QTcpSocket::errorOccurred, this, &WifiManager::soketHata);
    connect(m_soket, &QTcpSocket::readyRead, this, &WifiManager::veriHazir);
}

bool WifiManager::baglandi() const { return m_baglandi; }
bool WifiManager::baglaniyor() const { return m_baglaniyor; }
QString WifiManager::durumMesaji() const { return m_durumMesaji; }

void WifiManager::baglan()
{
    if (m_baglandi || m_baglaniyor) return;

    m_baglaniyor = true;
    emit baglaniyorChanged();
    durumGuncelle("SLIPER-ESP32'ye baglaniliyor...");

    m_soket->connectToHost(QString(ESP32_IP), ESP32_PORT);
}

void WifiManager::baglantiyiKes()
{
    m_soket->disconnectFromHost();
}

void WifiManager::kalibrasyonYenidenYukle()
{
    kalibrasyonYukle();
}

void WifiManager::kalibrasyonYukle()
{
    if (!m_database) return;

    m_loadCellHamDegerleri.clear();
    m_loadCellKiloDegerleri.clear();
    const QVariantList noktalar = m_database->loadCellNoktalariGetir();
    for (const QVariant &v : noktalar) {
        QVariantMap n = v.toMap();
        m_loadCellHamDegerleri.append(n["hamDeger"].toDouble());
        m_loadCellKiloDegerleri.append(n["hedefKg"].toDouble());
    }
    qDebug() << "Load cell" << m_loadCellHamDegerleri.size() << "nokta yuklendi.";

    m_mesafeHamDegerleri.clear();
    m_mesafeMmDegerleri.clear();
    const QVariantList mesafeNoktalari = m_database->mesafeNoktalariGetir();
    for (const QVariant &v : mesafeNoktalari) {
        QVariantMap n = v.toMap();
        m_mesafeHamDegerleri.append(n["hamDeger"].toDouble());
        m_mesafeMmDegerleri.append(n["hedefMm"].toDouble());
    }
    qDebug() << "Mesafe" << m_mesafeHamDegerleri.size() << "nokta yuklendi.";

    QVariantMap egim = m_database->kalibrasyonGetir("egim");
    if (egim.value("mevcut").toBool()) {
        m_egimOfsetX = egim.value("deger1").toDouble();
        m_egimOfsetY = egim.value("deger2").toDouble();
        qDebug() << "Egim kalibrasyonu yuklendi: X=" << m_egimOfsetX << "Y=" << m_egimOfsetY;
    }
}

void WifiManager::soketBaglandi()
{
    m_baglandi = true;
    m_baglaniyor = false;
    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle("SLIPER-ESP32 Bağlı");

    m_ilkPaket = true;
    m_zamanlayici.restart();
    kalibrasyonYukle();

    if (m_sensorManager) {
        m_sensorManager->veriyiGecersizYap();
    }

    qDebug() << "ESP32'ye baglanildi:" << ESP32_IP << ESP32_PORT;
}

void WifiManager::soketAyrildi()
{
    m_baglandi = false;
    m_baglaniyor = false;
    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle("Bağlı Değil");

    if (m_sensorManager) {
        m_sensorManager->veriyiGecersizYap();
    }

    qDebug() << "ESP32 baglantisi kesildi.";
}

void WifiManager::soketHata(QAbstractSocket::SocketError hata)
{
    m_baglandi = false;
    m_baglaniyor = false;
    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle("Baglanti hatasi: " + m_soket->errorString());

    qWarning() << "Wifi soket hatasi:" << hata << m_soket->errorString();
}

void WifiManager::veriHazir()
{
    m_tamponVeri.append(m_soket->readAll());

    int satirSonu;
    while ((satirSonu = m_tamponVeri.indexOf('\n')) != -1) {
        QByteArray satir = m_tamponVeri.left(satirSonu).trimmed();
        m_tamponVeri.remove(0, satirSonu + 1);

        if (!satir.isEmpty()) {
            jsonSatiriIsle(satir);
        }
    }
}

void WifiManager::egimHesapla(double accelX, double accelY, double accelZ, double &egimX, double &egimY) const
{
    egimX = std::atan2(accelY, accelZ) * 180.0 / M_PI;
    egimY = std::atan2(-accelX, std::sqrt(accelY * accelY + accelZ * accelZ)) * 180.0 / M_PI;
}

void WifiManager::jsonSatiriIsle(const QByteArray &satir)
{
    QJsonParseError hata;
    QJsonDocument belge = QJsonDocument::fromJson(satir, &hata);

    if (hata.error != QJsonParseError::NoError || !belge.isObject()) {
        qWarning() << "JSON parse hatasi:" << hata.errorString() << satir;
        return;
    }

    QJsonObject obj = belge.object();

    const double hamAgirlik = obj.value("hamAgirlik").toDouble();
    const double hamMesafe = obj.contains("hamMesafe")
        ? obj.value("hamMesafe").toDouble()
        : obj.value("konum").toDouble();
    const double accelX = obj.value("accelX").toDouble();
    const double accelY = obj.value("accelY").toDouble();
    const double accelZ = obj.value("accelZ").toDouble();

    // Kalibrasyon ekraninda gerekiyor: ham deger her zaman guncellensin
    if (m_sensorManager) {
        m_sensorManager->hamAgirlikGuncelle(hamAgirlik);
        m_sensorManager->hamMesafeGuncelle(hamMesafe);
    }

    const double konum = m_mesafeHamDegerleri.isEmpty()
        ? hamMesafe
        : mesafeInterpolasyon(hamMesafe);

    // --- Basinc: kayitli kalibrasyon ile ---
    const double agirlikKg = loadCellInterpolasyon(hamAgirlik);
    const double basinc = agirlikKg * 98.1;

    // --- Hiz ve debi: konum farkindan turetiliyor ---
    double hiz = 0.0;
    double debi = 0.0;

    const qint64 simdikiZamanMs = m_zamanlayici.elapsed();

    if (!m_ilkPaket) {
        double dt = (simdikiZamanMs - m_oncekiZamanMs) / 1000.0;
        if (dt <= 0.0) dt = 0.001;

        const double boruAlaniM2 = M_PI * (BORU_CAPI_M / 2.0) * (BORU_CAPI_M / 2.0);
        hiz = std::fabs(konum - m_oncekiKonum) / 1000.0 / dt;
        debi = hiz * boruAlaniM2 * 3600.0;
    } else {
        m_ilkPaket = false;
    }

    m_oncekiKonum = konum;
    m_oncekiZamanMs = simdikiZamanMs;

    // --- Egim: ham ivmeden aci, sonra kayitli ofset uygulanir ---
    double egimXHam = 0.0;
    double egimYHam = 0.0;
    egimHesapla(accelX, accelY, accelZ, egimXHam, egimYHam);

    const double egimX = egimXHam - m_egimOfsetX;
    const double egimY = egimYHam - m_egimOfsetY;

    if (m_sensorManager) {
        m_sensorManager->veriGuncelle(basinc, konum, hiz, debi, egimX, egimY);
    }
}

void WifiManager::durumGuncelle(const QString &mesaj)
{
    if (m_durumMesaji != mesaj) {
        m_durumMesaji = mesaj;
        emit durumMesajiChanged();
    }
}

double WifiManager::loadCellInterpolasyon(double hamDeger) const
{
    const int n = m_loadCellHamDegerleri.size();
    if (n == 0) return 0.0;
    if (n == 1) return m_loadCellKiloDegerleri[0];

    int i;
    if (hamDeger <= m_loadCellHamDegerleri[0]) {
        i = 0;
    } else if (hamDeger >= m_loadCellHamDegerleri[n - 1]) {
        i = n - 2;
    } else {
        for (i = 0; i < n - 1; ++i) {
            if (hamDeger <= m_loadCellHamDegerleri[i + 1]) break;
        }
    }

    const double ham1 = m_loadCellHamDegerleri[i];
    const double ham2 = m_loadCellHamDegerleri[i + 1];
    const double kg1 = m_loadCellKiloDegerleri[i];
    const double kg2 = m_loadCellKiloDegerleri[i + 1];

    if (ham2 == ham1) return kg1;
    return kg1 + (hamDeger - ham1) * (kg2 - kg1) / (ham2 - ham1);
}

double WifiManager::mesafeInterpolasyon(double hamDeger) const
{
    const int n = m_mesafeHamDegerleri.size();
    if (n == 0) return 0.0;
    if (n == 1) return m_mesafeMmDegerleri[0];

    int i;
    if (hamDeger <= m_mesafeHamDegerleri[0]) {
        i = 0;
    } else if (hamDeger >= m_mesafeHamDegerleri[n - 1]) {
        i = n - 2;
    } else {
        for (i = 0; i < n - 1; ++i) {
            if (hamDeger <= m_mesafeHamDegerleri[i + 1]) break;
        }
    }

    const double ham1 = m_mesafeHamDegerleri[i];
    const double ham2 = m_mesafeHamDegerleri[i + 1];
    const double mm1 = m_mesafeMmDegerleri[i];
    const double mm2 = m_mesafeMmDegerleri[i + 1];

    if (ham2 == ham1) return mm1;
    return mm1 + (hamDeger - ham1) * (mm2 - mm1) / (ham2 - ham1);
}
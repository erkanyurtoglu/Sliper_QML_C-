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

void WifiManager::kalibrasyonYukle()
{
    if (!m_database) return;

    QVariantMap loadCell = m_database->kalibrasyonGetir("loadcell");
    if (loadCell.value("mevcut").toBool()) {
        m_loadCellKatsayi = loadCell.value("deger1").toDouble();
        m_loadCellSifirOfset = loadCell.value("deger2").toDouble();
        qDebug() << "Load cell kalibrasyonu yuklendi: katsayi=" << m_loadCellKatsayi << "ofset=" << m_loadCellSifirOfset;
    }

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
    const double konum = obj.value("konum").toDouble();
    const double accelX = obj.value("accelX").toDouble();
    const double accelY = obj.value("accelY").toDouble();
    const double accelZ = obj.value("accelZ").toDouble();

    // Kalibrasyon ekraninda gerekiyor: ham deger her zaman guncellensin
    if (m_sensorManager) {
        m_sensorManager->hamAgirlikGuncelle(hamAgirlik);
    }

    // --- Basinc: kayitli kalibrasyon ile ---
    const double agirlikGram = (hamAgirlik - m_loadCellSifirOfset) / m_loadCellKatsayi;
    const double basinc = agirlikGram * 0.0981;

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
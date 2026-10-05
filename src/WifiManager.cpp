#include "WifiManager.h"
#include "SliperModel.h"
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

    // Hareketsizlik kontrolu: baglanti acikken 2 dakikada bir kontrol edilir,
    // en son veri geldigi zamandan itibaren HAREKETSIZLIK_LIMIT_MS gecmisse
    // baglanti otomatik kesilir (orijinal cihazin "2 saat sonra otomatik
    // kapanma" davranisinin yazilimsal karsiligi).
    m_hareketsizlikTimer.setInterval(2 * 60 * 1000);
    connect(&m_hareketsizlikTimer, &QTimer::timeout, this, &WifiManager::hareketsizlikKontrolEt);

    m_veriBekciTimer.setInterval(500);
    connect(&m_veriBekciTimer, &QTimer::timeout, this, &WifiManager::veriAkisiniKontrolEt);

    // Kopan baglanti otomatik olarak yeniden kurulur: olcum ortasinda kullanicinin
    // elle "Baglan" demesini beklemek veri kaybina yol aciyordu.
    m_yenidenBaglanmaTimer.setSingleShot(true);
    m_yenidenBaglanmaTimer.setInterval(YENIDEN_BAGLANMA_ARALIGI_MS);
    connect(&m_yenidenBaglanmaTimer, &QTimer::timeout, this, &WifiManager::baglan);

    // connectToHost() yanitsiz kalirsa soket Connecting durumunda asili kalir;
    // bu timer onu iptal edip yeniden denemeyi tetikler.
    m_baglantiZamanAsimiTimer.setSingleShot(true);
    m_baglantiZamanAsimiTimer.setInterval(BAGLANTI_ZAMAN_ASIMI_MS);
    connect(&m_baglantiZamanAsimiTimer, &QTimer::timeout, this, &WifiManager::baglantiZamanAsimiOldu);
}

bool WifiManager::baglandi() const { return m_baglandi; }
bool WifiManager::baglaniyor() const { return m_baglaniyor; }
QString WifiManager::durumMesaji() const { return m_durumMesaji; }

void WifiManager::baglan()
{
    // Kullanicinin elle baglanmasi, onceki "kullanici kesti" kararini iptal eder.
    m_kullaniciKesti = false;
    m_yenidenBaglanmaTimer.stop();

    if (m_baglandi || m_baglaniyor) return;

    // Onceki denemeden kalan yarim acik soket (hata sonrasi Connecting/Closing
    // durumunda kalmis olabilir) temizlenmeden connectToHost() sessizce yok sayilir.
    if (m_soket->state() != QAbstractSocket::UnconnectedState) {
        m_soket->abort();
    }

    m_baglaniyor = true;
    emit baglaniyorChanged();
    durumGuncelle("SLIPER-ESP32'ye baglaniliyor...");

    m_soket->connectToHost(QString(ESP32_IP), ESP32_PORT);
    m_baglantiZamanAsimiTimer.start();
}

void WifiManager::baglantiyiKes()
{
    // Bilerek kesildi: otomatik yeniden baglanma devreye girmemeli.
    m_kullaniciKesti = true;
    m_yenidenBaglanmaTimer.stop();
    m_baglantiZamanAsimiTimer.stop();
    m_soket->abort();
    // abort() bagli olmayan bir sokette disconnected yaymaz; durum yine de guncellensin.
    if (m_baglandi || m_baglaniyor) {
        soketAyrildi();
    }
}

void WifiManager::yenidenBaglanmayiPlanla()
{
    if (m_kullaniciKesti) return;
    if (m_yenidenBaglanmaTimer.isActive()) return;

    qDebug() << "Baglanti koptu," << YENIDEN_BAGLANMA_ARALIGI_MS << "ms sonra yeniden denenecek.";
    m_yenidenBaglanmaTimer.start();
}

void WifiManager::baglantiZamanAsimiOldu()
{
    if (!m_baglaniyor) return;

    qWarning() << "Baglanti denemesi zaman asimina ugradi, soket iptal ediliyor.";
    m_soket->abort();
    m_baglaniyor = false;
    emit baglaniyorChanged();
    durumGuncelle("Baglanti kurulamadi, yeniden deneniyor...");
    yenidenBaglanmayiPlanla();
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
    const QVariantList loadCellNoktalari = m_database->loadCellNoktalariGetir();
    for (const QVariant &kayit : loadCellNoktalari) {
        const QVariantMap nokta = kayit.toMap();
        m_loadCellHamDegerleri.append(nokta["hamDeger"].toDouble());
        m_loadCellKiloDegerleri.append(nokta["hedefKg"].toDouble());
    }
    qDebug() << "Load cell" << m_loadCellHamDegerleri.size() << "nokta yuklendi.";

    m_mesafeHamDegerleri.clear();
    m_mesafeMmDegerleri.clear();
    const QVariantList mesafeNoktalari = m_database->mesafeNoktalariGetir();
    for (const QVariant &kayit : mesafeNoktalari) {
        const QVariantMap nokta = kayit.toMap();
        m_mesafeHamDegerleri.append(nokta["hamDeger"].toDouble());
        m_mesafeMmDegerleri.append(nokta["hedefMm"].toDouble());
    }
    qDebug() << "Mesafe" << m_mesafeHamDegerleri.size() << "nokta yuklendi.";

    // Konum yönü: üst referans alttan küçükse konum "sensörden uzaklık"tır.
    // Kalibre edilmemişse varsayılan "sensörden uzaklık" (Calculator ile aynı).
    const QVariantMap konumSinirlari = m_database->kalibrasyonGetir("konum_sinirlari");
    if (konumSinirlari.value("mevcut").toBool()) {
        const double ustKonumMm = konumSinirlari.value("deger1").toDouble();
        const double altKonumMm = konumSinirlari.value("deger2").toDouble();
        m_konumYonu = ustKonumMm < altKonumMm ? -1.0 : 1.0;
    } else {
        m_konumYonu = -1.0;
    }

    QVariantMap egimKal = m_database->egimKalibrasyonuGetir();
    if (egimKal.value("mevcut").toBool()) {
        m_egimBiasX = egimKal.value("biasX").toDouble();
        m_egimBiasY = egimKal.value("biasY").toDouble();
        m_egimBiasZ = egimKal.value("biasZ").toDouble();
        m_egimGainX = egimKal.value("gainX").toDouble();
        m_egimGainY = egimKal.value("gainY").toDouble();
        m_egimGainZ = egimKal.value("gainZ").toDouble();
        qDebug() << "Egim ivme kalibrasyonu yuklendi.";
    }
}

void WifiManager::soketBaglandi()
{
    m_baglandi = true;
    m_baglaniyor = false;
    m_baglantiZamanAsimiTimer.stop();
    m_yenidenBaglanmaTimer.stop();
    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle("SLIPER-ESP32 Bağlı");

    // Kucuk paketler Nagle algoritmasiyla bekletilmesin (ESP32 tarafinda da ayni ayar var).
    m_soket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    // Wi-Fi/ESP32 sessizce kaybolursa isletim sistemi de kopmayi fark edebilsin.
    m_soket->setSocketOption(QAbstractSocket::KeepAliveOption, 1);

    m_ilkPaket = true;
    m_zamanlayici.restart();
    m_hareketsizlikZamanlayici.restart();
    m_hareketsizlikTimer.start();
    m_sonVeriZamani.restart();
    m_sonBekciTikZamani.restart();
    m_veriBekciTimer.start();
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
    m_hareketsizlikTimer.stop();
    m_veriBekciTimer.stop();
    m_baglantiZamanAsimiTimer.stop();
    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle(m_kullaniciKesti ? "Bağlı Değil" : "Bağlantı koptu, yeniden deneniyor...");

    // Yarim kalmis satir bir sonraki baglantinin ilk paketine karismasin.
    m_tamponVeri.clear();

    if (m_sensorManager) {
        m_sensorManager->veriyiGecersizYap();
    }

    qDebug() << "ESP32 baglantisi kesildi.";
    yenidenBaglanmayiPlanla();
}

void WifiManager::hareketsizlikKontrolEt()
{
    if (!m_baglandi) return;

    if (m_hareketsizlikZamanlayici.elapsed() >= HAREKETSIZLIK_LIMIT_MS) {
        qWarning() << "2 saatten uzun suredir veri akisi yok, baglanti otomatik kesiliyor.";
        emit hareketsizlikNedeniyleBaglantiKesildi();
        // Bilerek kesilir: baglantiyiKes() otomatik yeniden baglanmayi da kapatir,
        // aksi halde cihaz 2 saattir bos dururken surekli yeniden baglanilirdi.
        baglantiyiKes();
        durumGuncelle("Hareketsizlik nedeniyle baglanti kesildi");
    }
}

void WifiManager::veriAkisiniKontrolEt()
{
    if (!m_baglandi || !m_sonVeriZamani.isValid()) return;

    // Timer GUI thread'inde calisiyor. Stroke kaydi, grafik cizimi veya rapor
    // olusturma arayuzu birkac saniye bloklarsa gelen paketler islenemez ve
    // m_sonVeriZamani guncellenmez; bu durumda sorun ESP32'de degil PC'dedir ve
    // saglam bir baglantiyi koparmak yanlis olur. Timer'in kendi gecikmesine
    // bakarak bu iki durum ayirt edilir.
    const qint64 bekciGecikmesiMs = m_sonBekciTikZamani.isValid()
        ? m_sonBekciTikZamani.elapsed() - m_veriBekciTimer.interval()
        : 0;
    m_sonBekciTikZamani.restart();

    if (bekciGecikmesiMs > BEKCI_GECIKME_TOLERANSI_MS) {
        qWarning() << "Arayuz" << bekciGecikmesiMs << "ms bloklandi, veri kesintisi sayilmiyor.";
        m_sonVeriZamani.restart();
        return;
    }

    const qint64 gecenSureMs = m_sonVeriZamani.elapsed();

    if (gecenSureMs > VERI_KESINTI_BAGLANTI_KES_MS) {
        // Soket hala "bagli" gorunse bile bu kadar uzun suredir hic paket
        // gelmemesi, ESP32'nin kapandigini/koptugunu gosterir. Kullanicinin
        // "bagli olmadiginda bagli yazmasin" beklentisi icin baglanti burada
        // gercekten sonlandirilir; soketAyrildi() m_baglandi'yi false yapar ve
        // otomatik yeniden baglanmayi baslatir.
        qWarning() << "Uzun suredir (" << gecenSureMs << "ms) veri gelmiyor, baglanti sonlandiriliyor.";
        m_soket->abort();
        return;
    }

    if (gecenSureMs > VERI_KESINTI_MS) {
        if (m_sensorManager && m_sensorManager->veriGecerli()) {
            qWarning() << "Veri akisi kesildi (" << gecenSureMs << "ms paket yok).";
            m_sensorManager->veriyiGecersizYap();
            durumGuncelle("Veri akışı kesildi");
        }
    }
}

void WifiManager::soketHata(QAbstractSocket::SocketError hata)
{
    const QString hataMetni = m_soket->errorString();

    m_baglandi = false;
    m_baglaniyor = false;
    m_hareketsizlikTimer.stop();
    m_veriBekciTimer.stop();
    m_baglantiZamanAsimiTimer.stop();

    // Hata sonrasi soket Connecting/Closing durumunda kalabiliyordu; temizlenmezse
    // sonraki connectToHost() cagrisi sessizce yok sayilir ve bir daha baglanilamaz.
    if (m_soket->state() != QAbstractSocket::UnconnectedState) {
        m_soket->abort();
    }
    m_tamponVeri.clear();

    emit baglandiChanged();
    emit baglaniyorChanged();
    durumGuncelle(m_kullaniciKesti ? "Baglanti hatasi: " + hataMetni
                                   : "Baglanti hatasi, yeniden deneniyor...");

    if (m_sensorManager) {
        m_sensorManager->veriyiGecersizYap();
    }

    qWarning() << "Wifi soket hatasi:" << hata << hataMetni;
    yenidenBaglanmayiPlanla();
}

void WifiManager::veriHazir()
{
    m_sonVeriZamani.restart();
    if (m_durumMesaji == "Veri akışı kesildi") {
        durumGuncelle("SLIPER-ESP32 Bağlı");
    }

    if (m_hareketsizlikZamanlayici.isValid()) {
        m_hareketsizlikZamanlayici.restart();
    }

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

void WifiManager::jsonSatiriIsle(const QByteArray &satir)
{
    QJsonParseError hata;
    QJsonDocument belge = QJsonDocument::fromJson(satir, &hata);

    if (hata.error != QJsonParseError::NoError || !belge.isObject()) {
        qWarning() << "JSON parse hatasi:" << hata.errorString() << satir;
        return;
    }

    const QJsonObject paket = belge.object();

    const double hamAgirlik = paket.value("hamAgirlik").toDouble();
    const double hamMesafe = paket.contains("hamMesafe")
        ? paket.value("hamMesafe").toDouble()
        : paket.value("konum").toDouble();
    const double accelX = paket.value("accelX").toDouble();
    const double accelY = paket.value("accelY").toDouble();
    const double accelZ = paket.value("accelZ").toDouble();

    // Kalibrasyon ekraninda gerekiyor: ham deger her zaman guncellensin
    if (m_sensorManager) {
        m_sensorManager->hamAgirlikGuncelle(hamAgirlik);
        m_sensorManager->hamMesafeGuncelle(hamMesafe);
        m_sensorManager->hamAccelGuncelle(accelX, accelY, accelZ);

        // Batarya voltaji: firmware "hamBatarya" alanini gondermiyorsa
        // (henuz donanim baglanmadiysa) 0 olarak kalir, QML tarafinda
        // gosterge "bilinmiyor" durumunda birakilmalidir.
        if (BATARYA_OLCUMU_AKTIF && paket.contains("hamBatarya")) {
            const double hamBatarya = paket.value("hamBatarya").toDouble();
            m_sensorManager->bataryaVoltajGuncelle(SliperModel::bataryaVoltaji(hamBatarya));
        }
    }

    // --- Konum ve basinc: kalibrasyon tablosu + load cell kuvveti / piston alani
    // (SliperModel bolum 1 ve 2). Mesafe kalibre edilmemisse ham deger gosterilir. ---
    const double konumKalibreliMm = m_mesafeHamDegerleri.isEmpty()
        ? hamMesafe
        : SliperModel::kalibrasyonTablosundanOku(m_mesafeHamDegerleri, m_mesafeMmDegerleri, hamMesafe);

    // Mesafe sensörünün paket-paket gürültüsü burada bastırılır; bundan sonraki
    // her şey (canlı hız, grafik, ekran, Calculator'a giden konum) bu filtrelenmiş
    // değeri kullanır. İlk pakette filtre doğrudan ham değerden başlar, aksi halde
    // 0'dan başlayıp yanlış bir sıçrama gösterir.
    m_filtreliKonum = m_ilkPaket
        ? konumKalibreliMm
        : SliperModel::konumFiltrele(m_filtreliKonum, konumKalibreliMm);
    const double konumMm = m_filtreliKonum;

    const double agirlikKg =
        SliperModel::kalibrasyonTablosundanOku(m_loadCellHamDegerleri, m_loadCellKiloDegerleri, hamAgirlik);
    const double basincMbar = SliperModel::agirliktanBasincMbar(agirlikKg);

    // --- Zaman: ESP32 zaman damgasi (ms). Paketin PC'ye varis zamani
    // kullanilmaz; TCP birden fazla satiri ayni anda teslim edebilir. ---
    // ESP32 yeniden başlarsa (veya bağlantı yenilenirse) zaman damgası sıfırlanır;
    // zamanın geri gitmemesi için ofset eklenir (stroke tamponları ve grafikler
    // monoton zaman bekler).
    const double hamZamanMs = paket.contains("t")
        ? paket.value("t").toDouble()
        : static_cast<double>(m_zamanlayici.elapsed());
    if (m_zamanBasladi && hamZamanMs + m_zamanOfsetiMs < m_oncekiZamanMs - 1000.0) {
        m_zamanOfsetiMs = m_oncekiZamanMs + 20.0 - hamZamanMs;
    }
    const double simdikiZamanMs = hamZamanMs + m_zamanOfsetiMs;
    m_zamanBasladi = true;

    // --- Canli hiz ve debi (SliperModel bolum 10): yalnizca ekran icin.
    // Stroke hizi/debisi Calculator'da ayrica dogru uydurularak hesaplanir. ---
    if (!m_ilkPaket) {
        const double gecenSureS = (simdikiZamanMs - m_oncekiZamanMs) / 1000.0;
        if (gecenSureS > 0.0) {
            const double anlikHiz =
                SliperModel::anlikHizMs(m_oncekiKonum, konumMm, gecenSureS, m_konumYonu);
            m_filtreliHiz = SliperModel::canliHizFiltrele(m_filtreliHiz, anlikHiz);
        }
    } else {
        m_ilkPaket = false;
        m_filtreliHiz = 0.0;
    }

    const double hizMs = m_filtreliHiz;
    const double debiM3h = SliperModel::hizdanDebiM3h(hizMs);

    m_oncekiKonum = konumMm;
    m_oncekiZamanMs = simdikiZamanMs;

    // --- Egim: once ham ivme bias/gain ile duzeltilir, sonra aciya cevrilir ---
    const double duzeltilmisX = (accelX - m_egimBiasX) / m_egimGainX;
    const double duzeltilmisY = (accelY - m_egimBiasY) / m_egimGainY;
    const double duzeltilmisZ = (accelZ - m_egimBiasZ) / m_egimGainZ;

    const SliperModel::EgimAcilari egim =
        SliperModel::egimAcilari(duzeltilmisX, duzeltilmisY, duzeltilmisZ);

    if (m_sensorManager) {
        m_sensorManager->veriGuncelle(simdikiZamanMs / 1000.0, basincMbar, konumMm, hizMs, debiM3h,
                                      egim.xDerece, egim.yDerece);
    }
}

void WifiManager::durumGuncelle(const QString &mesaj)
{
    if (m_durumMesaji != mesaj) {
        m_durumMesaji = mesaj;
        emit durumMesajiChanged();
    }
}


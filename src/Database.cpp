#include "Database.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDateTime>
#include <QVector>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>

Database::Database(QObject *parent)
    : QObject(parent)
{
    const QString klasor = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/database";
    QDir().mkpath(klasor);

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(klasor + "/sliper.db");

    if (!m_db.open()) {
        qWarning() << "Veritabani acilamadi:" << m_db.lastError().text();
    } else {
        qDebug() << "Veritabani basariyla acildi.";
        tablolariOlustur();
    }
}

void Database::tablolariOlustur()
{
    QSqlQuery sorgu;

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS Olcumler ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "tarih TEXT, "
        "musteri TEXT, "
        "recete TEXT, "
        "agirlik REAL"
        ")"
    );

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS Strokelar ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "olcumId INTEGER, "
        "basinc REAL, "
        "konum REAL, "
        "debi REAL, "
        "gecerli INTEGER, "
        "FOREIGN KEY(olcumId) REFERENCES Olcumler(id)"
        ")"
    );

    QSqlQuery kolonKontrol("PRAGMA table_info(Strokelar)");
    bool debiKolonuVar = false;
    while (kolonKontrol.next()) {
        if (kolonKontrol.value("name").toString() == "debi") {
            debiKolonuVar = true;
            break;
        }
    }

    if (!debiKolonuVar) {
        QSqlQuery migrasyon;
        migrasyon.exec("ALTER TABLE Strokelar ADD COLUMN debi REAL DEFAULT 0");
    }

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS Kalibrasyonlar ("
        "sensor TEXT PRIMARY KEY, "
        "deger1 REAL, "
        "deger2 REAL, "
        "tarih TEXT"
        ")"
    );

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS LoadCellNoktalari ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "hedefKg REAL, "
        "hamDeger REAL"
        ")"
    );

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS MesafeNoktalari ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "hedefMm REAL, "
        "hamDeger REAL"
        ")"
    );

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS EgimKalibrasyon ("
        "id INTEGER PRIMARY KEY CHECK (id = 1), "
        "biasX REAL, biasY REAL, biasZ REAL, "
        "gainX REAL, gainY REAL, gainZ REAL, "
        "tarih TEXT"
        ")"
    );

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS KalibrasyonTarihleri ("
        "sensor TEXT PRIMARY KEY, "
        "tarih TEXT"
        ")"
    );

    qDebug() << "Tablolar hazir.";
}

int Database::olcumBaslat(const QString &musteri, const QString &recete, double agirlik)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Olcumler (tarih, musteri, recete, agirlik) "
        "VALUES (:tarih, :musteri, :recete, :agirlik)"
    );

    sorgu.bindValue(":tarih", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));
    sorgu.bindValue(":musteri", musteri);
    sorgu.bindValue(":recete", recete);
    sorgu.bindValue(":agirlik", agirlik);

    if (!sorgu.exec()) {
        qWarning() << "Olcum baslatilamadi:" << sorgu.lastError().text();
        return -1;
    }

    int yeniId = sorgu.lastInsertId().toInt();
    qDebug() << "Yeni olcum baslatildi, id:" << yeniId;
    return yeniId;
}

void Database::strokeKaydet(int olcumId, double basinc, double konum, double debi, bool gecerli)
{
    if (olcumId <= 0) {
        qWarning() << "Gecersiz olcumId, stroke kaydedilemedi.";
        return;
    }

    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Strokelar (olcumId, basinc, konum, debi, gecerli) "
        "VALUES (:olcumId, :basinc, :konum, :debi, :gecerli)"
    );

    sorgu.bindValue(":olcumId", olcumId);
    sorgu.bindValue(":basinc", basinc);
    sorgu.bindValue(":konum", konum);
    sorgu.bindValue(":debi", debi);
    sorgu.bindValue(":gecerli", gecerli ? 1 : 0);

    if (!sorgu.exec()) {
        qWarning() << "Stroke kaydedilemedi:" << sorgu.lastError().text();
    } else {
        qDebug() << "Stroke kaydedildi, olcumId:" << olcumId;
    }
}

bool Database::olcumSil(int olcumId)
{
    if (olcumId <= 0) {
        qWarning() << "Gecersiz olcumId, olcum silinemedi.";
        return false;
    }

    if (!m_db.transaction()) {
        qWarning() << "Olcum silme icin transaction baslatilamadi:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery strokeSil;
    strokeSil.prepare("DELETE FROM Strokelar WHERE olcumId = :olcumId");
    strokeSil.bindValue(":olcumId", olcumId);
    if (!strokeSil.exec()) {
        qWarning() << "Strokelar silinemedi:" << strokeSil.lastError().text();
        m_db.rollback();
        return false;
    }

    QSqlQuery olcumSil;
    olcumSil.prepare("DELETE FROM Olcumler WHERE id = :id");
    olcumSil.bindValue(":id", olcumId);
    if (!olcumSil.exec()) {
        qWarning() << "Olcum silinemedi:" << olcumSil.lastError().text();
        m_db.rollback();
        return false;
    }

    if (!m_db.commit()) {
        qWarning() << "Olcum silme commit edilemedi:" << m_db.lastError().text();
        return false;
    }

    qDebug() << "Olcum silindi, id:" << olcumId;
    return true;
}

QVariantList Database::tumOlcumleriGetir()
{
    QVariantList sonuclar;

    QSqlQuery sorgu(
        "SELECT o.id, o.tarih, o.musteri, o.recete, o.agirlik, "
        "COUNT(s.id) AS strokeSayisi "
        "FROM Olcumler o "
        "LEFT JOIN Strokelar s ON s.olcumId = o.id "
        "GROUP BY o.id "
        "ORDER BY o.id DESC"
    );

    while (sorgu.next()) {
        QVariantMap satir;
        satir["id"] = sorgu.value("id");
        satir["tarih"] = sorgu.value("tarih");
        satir["musteri"] = sorgu.value("musteri");
        satir["recete"] = sorgu.value("recete");
        satir["agirlik"] = sorgu.value("agirlik");
        satir["strokeSayisi"] = sorgu.value("strokeSayisi");
        sonuclar.append(satir);
    }

    return sonuclar;
}

QVariantList Database::strokeVerileriGetir(int olcumId)
{
    QVariantList sonuclar;

    QSqlQuery sorgu;
    sorgu.prepare(
        "SELECT basinc, konum, debi, gecerli FROM Strokelar "
        "WHERE olcumId = :olcumId ORDER BY id ASC"
    );
    sorgu.bindValue(":olcumId", olcumId);

    if (!sorgu.exec()) {
        qWarning() << "Stroke verileri alinamadi:" << sorgu.lastError().text();
        return sonuclar;
    }

    int sira = 1;
    while (sorgu.next()) {
        QVariantMap satir;
        satir["stroke"] = sira++;
        satir["basinc"] = sorgu.value("basinc");
        satir["konum"] = sorgu.value("konum");
        satir["debi"] = sorgu.value("debi");
        satir["gecerli"] = sorgu.value("gecerli").toBool();
        sonuclar.append(satir);
    }

    return sonuclar;
}

QVariantMap Database::binghamHesapla(int olcumId)
{
    QVariantMap sonuc;

    QSqlQuery sorgu;
    sorgu.prepare(
        "SELECT basinc, debi FROM Strokelar "
        "WHERE olcumId = :olcumId AND gecerli = 1"
    );
    sorgu.bindValue(":olcumId", olcumId);

    QVector<double> pDegerleri;
    QVector<double> qDegerleri;

    if (sorgu.exec()) {
        while (sorgu.next()) {
            pDegerleri.append(sorgu.value("basinc").toDouble());
            qDegerleri.append(sorgu.value("debi").toDouble());
        }
    }

    const int n = pDegerleri.size();

    if (n < 2) {
        sonuc["tau0"] = 0.0;
        sonuc["mu"] = 0.0;
        sonuc["r2"] = 0.0;
        sonuc["yeterliVeri"] = false;
        return sonuc;
    }

    double qToplam = 0, pToplam = 0, qpToplam = 0, qKareToplam = 0;
    for (int i = 0; i < n; ++i) {
        qToplam += qDegerleri[i];
        pToplam += pDegerleri[i];
        qpToplam += qDegerleri[i] * pDegerleri[i];
        qKareToplam += qDegerleri[i] * qDegerleri[i];
    }

    const double qOrt = qToplam / n;
    const double pOrt = pToplam / n;

    const double payda = qKareToplam - n * qOrt * qOrt;
    const double mu = (payda != 0.0) ? (qpToplam - n * qOrt * pOrt) / payda : 0.0;
    const double tau0 = pOrt - mu * qOrt;

    double ssTot = 0, ssRes = 0;
    for (int i = 0; i < n; ++i) {
        const double tahmin = tau0 + mu * qDegerleri[i];
        ssRes += (pDegerleri[i] - tahmin) * (pDegerleri[i] - tahmin);
        ssTot += (pDegerleri[i] - pOrt) * (pDegerleri[i] - pOrt);
    }

    const double r2 = (ssTot != 0.0) ? (1.0 - ssRes / ssTot) : 0.0;

    sonuc["tau0"] = tau0;
    sonuc["mu"] = mu;
    sonuc["r2"] = r2;
    sonuc["yeterliVeri"] = true;
    return sonuc;
}

bool Database::kalibrasyonKaydet(const QString &sensor, double deger1, double deger2)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Kalibrasyonlar (sensor, deger1, deger2, tarih) "
        "VALUES (:sensor, :deger1, :deger2, :tarih) "
        "ON CONFLICT(sensor) DO UPDATE SET "
        "deger1 = :deger1, deger2 = :deger2, tarih = :tarih"
    );

    sorgu.bindValue(":sensor", sensor);
    sorgu.bindValue(":deger1", deger1);
    sorgu.bindValue(":deger2", deger2);
    sorgu.bindValue(":tarih", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));

    if (!sorgu.exec()) {
        qWarning() << "Kalibrasyon kaydedilemedi:" << sorgu.lastError().text();
        return false;
    }

    qDebug() << "Kalibrasyon kaydedildi:" << sensor;
    return true;
}

QVariantMap Database::kalibrasyonGetir(const QString &sensor)
{
    QVariantMap sonuc;

    QSqlQuery sorgu;
    sorgu.prepare("SELECT deger1, deger2, tarih FROM Kalibrasyonlar WHERE sensor = :sensor");
    sorgu.bindValue(":sensor", sensor);

    if (sorgu.exec() && sorgu.next()) {
        sonuc["deger1"] = sorgu.value("deger1");
        sonuc["deger2"] = sorgu.value("deger2");
        sonuc["tarih"] = sorgu.value("tarih");
        sonuc["mevcut"] = true;
    } else {
        sonuc["mevcut"] = false;
    }

    return sonuc;
}

void Database::kalibrasyonTarihiKaydet(const QString &sensor)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO KalibrasyonTarihleri (sensor, tarih) VALUES (:sensor, :tarih) "
        "ON CONFLICT(sensor) DO UPDATE SET tarih = :tarih"
    );

    sorgu.bindValue(":sensor", sensor);
    sorgu.bindValue(":tarih", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));

    if (!sorgu.exec()) {
        qWarning() << "Kalibrasyon tarihi kaydedilemedi:" << sorgu.lastError().text();
    }
}

QString Database::kalibrasyonTarihiGetir(const QString &sensor)
{
    QSqlQuery sorgu;
    sorgu.prepare("SELECT tarih FROM KalibrasyonTarihleri WHERE sensor = :sensor");
    sorgu.bindValue(":sensor", sensor);

    if (sorgu.exec() && sorgu.next()) {
        return sorgu.value("tarih").toString();
    }

    return QString();
}

QVariantMap Database::olcumBilgisiGetir(int olcumId)
{
    QVariantMap sonuc;

    QSqlQuery sorgu;
    sorgu.prepare("SELECT tarih, musteri, recete, agirlik FROM Olcumler WHERE id = :id");
    sorgu.bindValue(":id", olcumId);

    if (sorgu.exec() && sorgu.next()) {
        sonuc["tarih"] = sorgu.value("tarih");
        sonuc["musteri"] = sorgu.value("musteri");
        sonuc["recete"] = sorgu.value("recete");
        sonuc["agirlik"] = sorgu.value("agirlik");
        sonuc["bulundu"] = true;
    } else {
        sonuc["bulundu"] = false;
    }

    return sonuc;
}

QString Database::csvDisaAktar(int olcumId)
{
    QVariantMap bilgi = olcumBilgisiGetir(olcumId);
    if (!bilgi["bulundu"].toBool()) {
        qWarning() << "Olcum bulunamadi, csv olusturulamadi.";
        return QString();
    }

    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    if (!QDir().mkpath(klasor)) {
        qWarning() << "Rapor klasoru olusturulamadi:" << klasor;
        return QString();
    }

    QString dosyaAdi = klasor + QString("/SLIPER_Veri_%1_%2.csv")
        .arg(olcumId)
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    QFile dosya(dosyaAdi);
    if (!dosya.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "CSV dosyasi acilamadi:" << dosyaAdi;
        return QString();
    }

    QTextStream akis(&dosya);
    akis.setEncoding(QStringConverter::Utf8);

    akis << "Olcum ID;" << olcumId << "\n";
    akis << "Tarih;" << bilgi["tarih"].toString() << "\n";
    akis << "Musteri;" << bilgi["musteri"].toString() << "\n";
    akis << "Recete;" << bilgi["recete"].toString() << "\n";
    akis << "Agirlik (kg);" << bilgi["agirlik"].toDouble() << "\n";
    akis << "\n";
    akis << "Stroke;Basinc (mbar);Konum (mm);Debi (m3/h);Gecerli\n";

    QVariantList strokelar = strokeVerileriGetir(olcumId);
    for (const QVariant &v : strokelar) {
        QVariantMap s = v.toMap();
        akis << s["stroke"].toInt() << ";"
             << s["basinc"].toDouble() << ";"
             << s["konum"].toDouble() << ";"
             << s["debi"].toDouble() << ";"
             << (s["gecerli"].toBool() ? "Evet" : "Hayir") << "\n";
    }

    dosya.close();
    qDebug() << "CSV disa aktarildi:" << dosyaAdi;
    return dosyaAdi;
}

bool Database::loadCellNoktalariKaydet(const QVariantList &noktalar)
{
    if (!m_db.transaction()) {
        qWarning() << "Load cell noktalari icin transaction baslatilamadi:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery temizle;
    if (!temizle.exec("DELETE FROM LoadCellNoktalari")) {
        qWarning() << "Load cell noktalari temizlenemedi:" << temizle.lastError().text();
        m_db.rollback();
        return false;
    }

    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO LoadCellNoktalari (hedefKg, hamDeger) "
        "VALUES (:hedefKg, :hamDeger)"
    );

    for (const QVariant &v : noktalar) {
        QVariantMap nokta = v.toMap();
        sorgu.bindValue(":hedefKg", nokta["hedefKg"].toDouble());
        sorgu.bindValue(":hamDeger", nokta["hamDeger"].toDouble());
        if (!sorgu.exec()) {
            qWarning() << "Load cell noktasi kaydedilemedi:" << sorgu.lastError().text();
            m_db.rollback();
            return false;
        }
    }

    if (!m_db.commit()) {
        qWarning() << "Load cell noktalari commit edilemedi:" << m_db.lastError().text();
        return false;
    }

    qDebug() << "Load cell" << noktalar.size() << "nokta kaydedildi.";
    kalibrasyonTarihiKaydet("loadcell");
    return true;
}

QVariantList Database::loadCellNoktalariGetir()
{
    QVariantList sonuclar;

    QSqlQuery sorgu("SELECT hedefKg, hamDeger FROM LoadCellNoktalari ORDER BY hamDeger ASC");

    while (sorgu.next()) {
        QVariantMap satir;
        satir["hedefKg"] = sorgu.value("hedefKg");
        satir["hamDeger"] = sorgu.value("hamDeger");
        sonuclar.append(satir);
    }

    return sonuclar;
}

bool Database::mesafeNoktalariKaydet(const QVariantList &noktalar)
{
    if (!m_db.transaction()) {
        qWarning() << "Mesafe noktalari icin transaction baslatilamadi:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery temizle;
    if (!temizle.exec("DELETE FROM MesafeNoktalari")) {
        qWarning() << "Mesafe noktalari temizlenemedi:" << temizle.lastError().text();
        m_db.rollback();
        return false;
    }

    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO MesafeNoktalari (hedefMm, hamDeger) "
        "VALUES (:hedefMm, :hamDeger)"
    );

    for (const QVariant &v : noktalar) {
        QVariantMap nokta = v.toMap();
        sorgu.bindValue(":hedefMm", nokta["hedefMm"].toDouble());
        sorgu.bindValue(":hamDeger", nokta["hamDeger"].toDouble());
        if (!sorgu.exec()) {
            qWarning() << "Mesafe noktasi kaydedilemedi:" << sorgu.lastError().text();
            m_db.rollback();
            return false;
        }
    }

    if (!m_db.commit()) {
        qWarning() << "Mesafe noktalari commit edilemedi:" << m_db.lastError().text();
        return false;
    }

    qDebug() << "Mesafe" << noktalar.size() << "nokta kaydedildi.";
    kalibrasyonTarihiKaydet("mesafe_olcum");
    return true;
}

QVariantList Database::mesafeNoktalariGetir()
{
    QVariantList sonuclar;

    QSqlQuery sorgu("SELECT hedefMm, hamDeger FROM MesafeNoktalari ORDER BY hamDeger ASC");

    while (sorgu.next()) {
        QVariantMap satir;
        satir["hedefMm"] = sorgu.value("hedefMm");
        satir["hamDeger"] = sorgu.value("hamDeger");
        sonuclar.append(satir);
    }

    return sonuclar;
}

bool Database::egimKalibrasyonuKaydet(double biasX, double biasY, double biasZ,
                                       double gainX, double gainY, double gainZ)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT OR REPLACE INTO EgimKalibrasyon (id, biasX, biasY, biasZ, gainX, gainY, gainZ, tarih) "
        "VALUES (1, :biasX, :biasY, :biasZ, :gainX, :gainY, :gainZ, :tarih)"
    );

    sorgu.bindValue(":biasX", biasX);
    sorgu.bindValue(":biasY", biasY);
    sorgu.bindValue(":biasZ", biasZ);
    sorgu.bindValue(":gainX", gainX);
    sorgu.bindValue(":gainY", gainY);
    sorgu.bindValue(":gainZ", gainZ);
    sorgu.bindValue(":tarih", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));

    if (!sorgu.exec()) {
        qWarning() << "Egim kalibrasyonu kaydedilemedi:" << sorgu.lastError().text();
        return false;
    }

    qDebug() << "Egim kalibrasyonu kaydedildi.";
    return true;
}

QVariantMap Database::egimKalibrasyonuGetir()
{
    QVariantMap sonuc;

    QSqlQuery sorgu("SELECT biasX, biasY, biasZ, gainX, gainY, gainZ, tarih FROM EgimKalibrasyon WHERE id = 1");

    if (sorgu.exec() && sorgu.next()) {
        sonuc["biasX"] = sorgu.value("biasX");
        sonuc["biasY"] = sorgu.value("biasY");
        sonuc["biasZ"] = sorgu.value("biasZ");
        sonuc["gainX"] = sorgu.value("gainX");
        sonuc["gainY"] = sorgu.value("gainY");
        sonuc["gainZ"] = sorgu.value("gainZ");
        sonuc["tarih"] = sorgu.value("tarih");
        sonuc["mevcut"] = true;
    } else {
        sonuc["mevcut"] = false;
    }

    return sonuc;
}
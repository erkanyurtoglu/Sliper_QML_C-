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

void Database::kalibrasyonKaydet(const QString &sensor, double deger1, double deger2)
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
    } else {
        qDebug() << "Kalibrasyon kaydedildi:" << sensor;
    }
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

bool Database::csvDisaAktar(int olcumId)
{
    QVariantMap bilgi = olcumBilgisiGetir(olcumId);
    if (!bilgi["bulundu"].toBool()) {
        qWarning() << "Olcum bulunamadi, csv olusturulamadi.";
        return false;
    }

    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    QDir().mkpath(klasor);

    QString dosyaAdi = klasor + QString("/SLIPER_Veri_%1_%2.csv")
        .arg(olcumId)
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    QFile dosya(dosyaAdi);
    if (!dosya.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "CSV dosyasi acilamadi:" << dosyaAdi;
        return false;
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
    return true;
}

void Database::loadCellNoktalariKaydet(const QVariantList &noktalar)
{
    QSqlQuery temizle;
    temizle.exec("DELETE FROM LoadCellNoktalari");

    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO LoadCellNoktalari (hedefKg, hamDeger) "
        "VALUES (:hedefKg, :hamDeger)"
    );

    for (const QVariant &v : noktalar) {
        QVariantMap nokta = v.toMap();
        sorgu.bindValue(":hedefKg", nokta["hedefKg"].toDouble());
        sorgu.bindValue(":hamDeger", nokta["hamDeger"].toDouble());
        sorgu.exec();
    }

    qDebug() << "Load cell" << noktalar.size() << "nokta kaydedildi.";
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
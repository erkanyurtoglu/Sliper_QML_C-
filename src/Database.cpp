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
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>
#include <QHash>
#include <algorithm>
#include "SliperModel.h"

Database::Database(QObject *parent)
    : QObject(parent)
{
    const QString klasor = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/database";
    QDir().mkpath(klasor);

    m_veriTabaniDosyaYolu = klasor + "/sliper.db";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_veriTabaniDosyaYolu);

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

    // Eski veritabanlarını yeni şemaya taşı (eksik kolonlar eklenir, veri korunur)
    auto kolonEkle = [](const QString &tablo, const QString &kolon, const QString &tanim) {
        QSqlQuery kontrol(QString("PRAGMA table_info(%1)").arg(tablo));
        while (kontrol.next()) {
            if (kontrol.value("name").toString() == kolon) return;
        }
        QSqlQuery migrasyon;
        if (!migrasyon.exec(QString("ALTER TABLE %1 ADD COLUMN %2 %3").arg(tablo, kolon, tanim))) {
            qWarning() << "Kolon eklenemedi:" << tablo << kolon << migrasyon.lastError().text();
        }
    };

    kolonEkle("Olcumler", "yer", "TEXT DEFAULT ''");
    kolonEkle("Olcumler", "yorum", "TEXT DEFAULT ''");
    kolonEkle("Olcumler", "tahminAyarlari", "TEXT DEFAULT ''");

    // Orijinal SLIPER stroke kaydı: Date, Time, Duration, pmax, P0l, P0r, p, Q
    // + ham eğri (başlangıçtan 2 s önce - bitişten 2 s sonra) ve tahmine dahil/hariç bilgisi
    kolonEkle("Strokelar", "debi", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "tarih", "TEXT DEFAULT ''");
    kolonEkle("Strokelar", "sure", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "pMaks", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "p0l", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "p0r", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "hiz", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "agirlik", "REAL DEFAULT 0");
    kolonEkle("Strokelar", "secili", "INTEGER DEFAULT 1");
    kolonEkle("Strokelar", "gecersizNedeni", "TEXT DEFAULT ''");
    kolonEkle("Strokelar", "hamVeri", "TEXT DEFAULT ''");

    sorgu.exec(
        "CREATE TABLE IF NOT EXISTS Ayarlar ("
        "anahtar TEXT PRIMARY KEY, "
        "deger TEXT"
        ")"
    );

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

int Database::olcumBaslat(const QString &musteri, const QString &recete, double agirlik,
                          const QString &yer, const QString &yorum)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Olcumler (tarih, musteri, recete, agirlik, yer, yorum, tahminAyarlari) "
        "VALUES (:tarih, :musteri, :recete, :agirlik, :yer, :yorum, :tahminAyarlari)"
    );

    sorgu.bindValue(":tarih", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));
    sorgu.bindValue(":musteri", musteri);
    sorgu.bindValue(":recete", recete);
    sorgu.bindValue(":agirlik", agirlik);
    sorgu.bindValue(":yer", yer);
    sorgu.bindValue(":yorum", yorum);
    // Orijinal uygulamadaki gibi: yeni ölçüm, güncel "Forecast Preferences" ile başlar
    sorgu.bindValue(":tahminAyarlari", jsonYaz(varsayilanTahminAyarlariGetir()));

    if (!sorgu.exec()) {
        qWarning() << "Olcum baslatilamadi:" << sorgu.lastError().text();
        return -1;
    }

    int yeniId = sorgu.lastInsertId().toInt();
    qDebug() << "Yeni olcum baslatildi, id:" << yeniId;
    return yeniId;
}

bool Database::olcumBilgisiGuncelle(int olcumId, const QString &yer, const QString &musteri,
                                    const QString &recete, const QString &yorum)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "UPDATE Olcumler SET yer = :yer, musteri = :musteri, recete = :recete, yorum = :yorum "
        "WHERE id = :id"
    );
    sorgu.bindValue(":yer", yer);
    sorgu.bindValue(":musteri", musteri);
    sorgu.bindValue(":recete", recete);
    sorgu.bindValue(":yorum", yorum);
    sorgu.bindValue(":id", olcumId);

    if (!sorgu.exec()) {
        qWarning() << "Olcum bilgisi guncellenemedi:" << sorgu.lastError().text();
        return false;
    }
    return true;
}

int Database::strokeKaydet(int olcumId, const QVariantMap &stroke, double agirlik)
{
    if (olcumId <= 0) {
        qWarning() << "Gecersiz olcumId, stroke kaydedilemedi.";
        return -1;
    }

    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Strokelar (olcumId, basinc, konum, debi, gecerli, tarih, sure, pMaks, "
        "p0l, p0r, hiz, agirlik, secili, gecersizNedeni, hamVeri) "
        "VALUES (:olcumId, :basinc, :konum, :debi, :gecerli, :tarih, :sure, :pMaks, "
        ":p0l, :p0r, :hiz, :agirlik, 1, :gecersizNedeni, :hamVeri)"
    );

    sorgu.bindValue(":olcumId", olcumId);
    sorgu.bindValue(":basinc", stroke.value("basinc").toDouble());
    sorgu.bindValue(":konum", stroke.value("konum").toDouble());
    sorgu.bindValue(":debi", stroke.value("debi").toDouble());
    sorgu.bindValue(":gecerli", stroke.value("gecerli").toBool() ? 1 : 0);
    sorgu.bindValue(":tarih", stroke.value("tarih").toString());
    sorgu.bindValue(":sure", stroke.value("sure").toDouble());
    sorgu.bindValue(":pMaks", stroke.value("pMaks").toDouble());
    sorgu.bindValue(":p0l", stroke.value("p0l").toDouble());
    sorgu.bindValue(":p0r", stroke.value("p0r").toDouble());
    sorgu.bindValue(":hiz", stroke.value("hiz").toDouble());
    sorgu.bindValue(":agirlik", agirlik);
    sorgu.bindValue(":gecersizNedeni", stroke.value("gecersizNedeni").toString());
    sorgu.bindValue(":hamVeri", jsonYaz(stroke.value("hamVeri").toMap()));

    if (!sorgu.exec()) {
        qWarning() << "Stroke kaydedilemedi:" << sorgu.lastError().text();
        return -1;
    }
    qDebug() << "Stroke kaydedildi, olcumId:" << olcumId;
    return sorgu.lastInsertId().toInt();
}

bool Database::strokeSeciliAyarla(int strokeId, bool secili)
{
    QSqlQuery sorgu;
    sorgu.prepare("UPDATE Strokelar SET secili = :secili WHERE id = :id");
    sorgu.bindValue(":secili", secili ? 1 : 0);
    sorgu.bindValue(":id", strokeId);
    if (!sorgu.exec()) {
        qWarning() << "Stroke secimi guncellenemedi:" << sorgu.lastError().text();
        return false;
    }
    return true;
}

bool Database::strokeSil(int strokeId)
{
    QSqlQuery sorgu;
    sorgu.prepare("DELETE FROM Strokelar WHERE id = :id");
    sorgu.bindValue(":id", strokeId);
    if (!sorgu.exec()) {
        qWarning() << "Stroke silinemedi:" << sorgu.lastError().text();
        return false;
    }
    return true;
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
        "SELECT o.id, o.tarih, o.musteri, o.recete, o.agirlik, o.yer, o.yorum, "
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
        satir["yer"] = sorgu.value("yer").toString();
        satir["yorum"] = sorgu.value("yorum").toString();
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
        "SELECT id, basinc, konum, debi, gecerli, tarih, sure, pMaks, p0l, p0r, hiz, "
        "agirlik, secili, gecersizNedeni FROM Strokelar "
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
        satir["id"] = sorgu.value("id").toInt();
        satir["stroke"] = sira++;
        satir["basinc"] = sorgu.value("basinc").toDouble();
        satir["konum"] = sorgu.value("konum").toDouble();
        satir["debi"] = sorgu.value("debi").toDouble();
        satir["gecerli"] = sorgu.value("gecerli").toBool();
        const QDateTime zaman = QDateTime::fromString(sorgu.value("tarih").toString(), Qt::ISODate);
        satir["tarih"] = zaman.isValid() ? zaman.toString("yyyy-MM-dd") : QString();
        satir["saat"] = zaman.isValid() ? zaman.toString("HH:mm:ss") : QString();
        satir["sure"] = sorgu.value("sure").toDouble();
        satir["pMaks"] = sorgu.value("pMaks").toDouble();
        satir["p0l"] = sorgu.value("p0l").toDouble();
        satir["p0r"] = sorgu.value("p0r").toDouble();
        satir["hiz"] = sorgu.value("hiz").toDouble();
        satir["agirlik"] = sorgu.value("agirlik").toDouble();
        satir["secili"] = sorgu.value("secili").isNull() ? true : sorgu.value("secili").toBool();
        satir["gecersizNedeni"] = sorgu.value("gecersizNedeni").toString();
        sonuclar.append(satir);
    }

    return sonuclar;
}

QVariantMap Database::strokeHamVeriGetir(int strokeId)
{
    QSqlQuery sorgu;
    sorgu.prepare("SELECT hamVeri FROM Strokelar WHERE id = :id");
    sorgu.bindValue(":id", strokeId);
    if (sorgu.exec() && sorgu.next()) {
        return jsonOku(sorgu.value("hamVeri").toString());
    }
    return QVariantMap();
}

// P-Q doğrusu: yalnızca geçerli ve tahmine dahil edilmiş (secili) stroke'lar.
// Ayrıca ölçüm kalitesi uyarıları üretilir (eşik gerektirmeyen, fiziksel/istatistiksel kontroller).
QVariantMap Database::binghamHesapla(int olcumId)
{
    QVariantMap sonuc;

    QSqlQuery sorgu;
    sorgu.prepare(
        "SELECT basinc, debi, gecerli, secili, agirlik FROM Strokelar WHERE olcumId = :olcumId"
    );
    sorgu.bindValue(":olcumId", olcumId);

    QVector<double> basinclarMbar;             // her kullanılan stroke'un p değeri
    QVector<double> debilerM3h;                // her kullanılan stroke'un Q değeri
    // Ek ağırlık 0.1 kg hassasiyetle anahtar yapılır (1.6 kg -> 16), kayan nokta
    // karşılaştırma hatası olmasın diye.
    QHash<qint64, int> agirlikBasinaStrokeSayisi;
    int toplamStrokeSayisi = 0;
    int gecersizStrokeSayisi = 0;

    if (sorgu.exec()) {
        while (sorgu.next()) {
            ++toplamStrokeSayisi;
            const bool gecerli = sorgu.value("gecerli").toBool();
            const bool tahmineDahil = sorgu.value("secili").isNull() || sorgu.value("secili").toBool();
            if (!gecerli) ++gecersizStrokeSayisi;
            if (!gecerli || !tahmineDahil) continue;
            basinclarMbar.append(sorgu.value("basinc").toDouble());
            debilerM3h.append(sorgu.value("debi").toDouble());
            const qint64 agirlikAnahtari = qRound64(sorgu.value("agirlik").toDouble() * 10.0);
            agirlikBasinaStrokeSayisi[agirlikAnahtari] += 1;
        }
    }

    const int kullanilanStrokeSayisi = basinclarMbar.size();
    QStringList uyarilar;
    sonuc["n"] = kullanilanStrokeSayisi;
    sonuc["toplamStroke"] = toplamStrokeSayisi;
    sonuc["gecersizStroke"] = gecersizStrokeSayisi;

    if (kullanilanStrokeSayisi < 2) {
        sonuc["tau0"] = 0.0;
        sonuc["mu"] = 0.0;
        sonuc["r2"] = 0.0;
        sonuc["yeterliVeri"] = false;
        uyarilar << "azStroke";
        sonuc["uyarilar"] = uyarilar;
        return sonuc;
    }

    // p = A + B*Q ve uyarılar: SliperModel bölüm 6 ve 7.
    // Eski kayıtlarla uyum için sonuçta "tau0" = A (kesişim), "mu" = B (eğim) adıyla saklanır.
    const SliperModel::DogruUyumu pqCizgisi = SliperModel::pqDogrusu(debilerM3h, basinclarMbar);
    uyarilar = SliperModel::olcumUyarilari(pqCizgisi, agirlikBasinaStrokeSayisi,
                                           toplamStrokeSayisi, gecersizStrokeSayisi);

    sonuc["tau0"] = pqCizgisi.kesisimA;
    sonuc["mu"] = pqCizgisi.egimB;
    sonuc["r2"] = pqCizgisi.r2;
    sonuc["qMin"] = pqCizgisi.qMin;
    sonuc["qMaks"] = pqCizgisi.qMaks;
    sonuc["yeterliVeri"] = true;
    sonuc["uyarilar"] = uyarilar;
    return sonuc;
}

QVariantMap Database::tahminAyarlariGetir(int olcumId)
{
    QSqlQuery sorgu;
    sorgu.prepare("SELECT tahminAyarlari FROM Olcumler WHERE id = :id");
    sorgu.bindValue(":id", olcumId);
    if (sorgu.exec() && sorgu.next()) {
        const QString json = sorgu.value("tahminAyarlari").toString();
        if (!json.isEmpty()) {
            return SliperModel::tahminAyarlariniTamamla(jsonOku(json));
        }
    }
    return varsayilanTahminAyarlariGetir();
}

bool Database::tahminAyarlariKaydet(int olcumId, const QVariantMap &ayarlar)
{
    const QVariantMap tam = SliperModel::tahminAyarlariniTamamla(ayarlar);
    QSqlQuery sorgu;
    sorgu.prepare("UPDATE Olcumler SET tahminAyarlari = :a WHERE id = :id");
    sorgu.bindValue(":a", jsonYaz(tam));
    sorgu.bindValue(":id", olcumId);
    if (!sorgu.exec()) {
        qWarning() << "Tahmin ayarlari kaydedilemedi:" << sorgu.lastError().text();
        return false;
    }
    // Sonraki ölçümler de bu ayarlarla başlasın (orijinal "Forecast Preferences")
    ayarKaydet("varsayilanTahminAyarlari", jsonYaz(tam));
    return true;
}

QVariantMap Database::varsayilanTahminAyarlariGetir()
{
    const QString json = ayarGetir("varsayilanTahminAyarlari");
    return SliperModel::tahminAyarlariniTamamla(json.isEmpty() ? QVariantMap() : jsonOku(json));
}

QVariantList Database::tahminTablosuGetir(int olcumId)
{
    const QVariantMap pqSonucu = binghamHesapla(olcumId);
    if (!pqSonucu.value("yeterliVeri").toBool()) return QVariantList();
    const double kesisimA = pqSonucu["tau0"].toDouble();
    const double egimB = pqSonucu["mu"].toDouble();
    return SliperModel::tahminTablosu(kesisimA, egimB, tahminAyarlariGetir(olcumId));
}

QString Database::ayarGetir(const QString &anahtar, const QString &varsayilan)
{
    QSqlQuery sorgu;
    sorgu.prepare("SELECT deger FROM Ayarlar WHERE anahtar = :a");
    sorgu.bindValue(":a", anahtar);
    if (sorgu.exec() && sorgu.next()) {
        return sorgu.value("deger").toString();
    }
    return varsayilan;
}

bool Database::ayarKaydet(const QString &anahtar, const QString &deger)
{
    QSqlQuery sorgu;
    sorgu.prepare(
        "INSERT INTO Ayarlar (anahtar, deger) VALUES (:a, :d) "
        "ON CONFLICT(anahtar) DO UPDATE SET deger = :d"
    );
    sorgu.bindValue(":a", anahtar);
    sorgu.bindValue(":d", deger);
    if (!sorgu.exec()) {
        qWarning() << "Ayar kaydedilemedi:" << anahtar << sorgu.lastError().text();
        return false;
    }
    return true;
}

QString Database::jsonYaz(const QVariantMap &veri)
{
    return QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(veri)).toJson(QJsonDocument::Compact));
}

QVariantMap Database::jsonOku(const QString &json)
{
    return QJsonDocument::fromJson(json.toUtf8()).object().toVariantMap();
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
    sorgu.prepare("SELECT tarih, musteri, recete, agirlik, yer, yorum FROM Olcumler WHERE id = :id");
    sorgu.bindValue(":id", olcumId);

    if (sorgu.exec() && sorgu.next()) {
        sonuc["tarih"] = sorgu.value("tarih");
        sonuc["musteri"] = sorgu.value("musteri");
        sonuc["recete"] = sorgu.value("recete");
        sonuc["agirlik"] = sorgu.value("agirlik");
        sonuc["yer"] = sorgu.value("yer").toString();
        sonuc["yorum"] = sorgu.value("yorum").toString();
        sonuc["bulundu"] = true;
    } else {
        sonuc["bulundu"] = false;
    }

    return sonuc;
}

// Orijinal SLIPER'daki Excel dışa aktarımıyla aynı düzen (kılavuz bölüm 5.6,
// Şekil 25): "Results" sayfasında temel veri, stroke özeti (Date, Time,
// Duration, pmax, P0l, P0r, p, Q), tahmin girdileri, a/b parametreleri,
// tahmin tablosu ve cihaz parametreleri; "Stroke_1".."Stroke_N" sayfalarında
// her stroke'un ham verisi. Format: Office 2003 SpreadsheetML (Excel doğrudan açar).
QString Database::xmlDisaAktar(int olcumId)
{
    QVariantMap bilgi = olcumBilgisiGetir(olcumId);
    if (!bilgi["bulundu"].toBool()) {
        qWarning() << "Olcum bulunamadi, xml olusturulamadi.";
        return QString();
    }

    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    if (!QDir().mkpath(klasor)) {
        qWarning() << "Rapor klasoru olusturulamadi:" << klasor;
        return QString();
    }

    const QVariantList strokelar = strokeVerileriGetir(olcumId);
    // Orijinal dosya adı: önek + ilk stroke'un zaman damgası
    QString zamanDamgasi = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH_mm_ss");
    if (!strokelar.isEmpty()) {
        const QVariantMap ilk = strokelar.first().toMap();
        if (!ilk["tarih"].toString().isEmpty()) {
            zamanDamgasi = ilk["tarih"].toString() + "_" + ilk["saat"].toString().replace(':', '_');
        }
    }
    QString dosyaAdi = klasor + QString("/SLIPER_%1_%2.xml").arg(olcumId).arg(zamanDamgasi);

    QFile dosya(dosyaAdi);
    if (!dosya.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "XML dosyasi acilamadi:" << dosyaAdi;
        return QString();
    }

    const QVariantMap pqSonucu = binghamHesapla(olcumId);
    const QVariantMap ayarlar = tahminAyarlariGetir(olcumId);
    const QVariantList tahminSatirlari = tahminTablosuGetir(olcumId);

    QTextStream akis(&dosya);
    akis.setEncoding(QStringConverter::Utf8);

    // XML'de özel anlamı olan karakterler metin içinde kaçışlanır
    auto xmlKacis = [](QString yazi) {
        yazi.replace("&", "&amp;");
        yazi.replace("<", "&lt;");
        yazi.replace(">", "&gt;");
        return yazi;
    };
    auto metin = [&](const QString &yazi) {
        return QString("<Cell><Data ss:Type=\"String\">%1</Data></Cell>").arg(xmlKacis(yazi));
    };
    auto sayi = [](double deger) {
        return QString("<Cell><Data ss:Type=\"Number\">%1</Data></Cell>").arg(QString::number(deger, 'g', 10));
    };
    auto satir = [&](const QStringList &hucreler) {
        akis << "<Row>" << hucreler.join("") << "</Row>\n";
    };

    akis << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    akis << "<?mso-application progid=\"Excel.Sheet\"?>\n";
    akis << "<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" "
            "xmlns:o=\"urn:schemas-microsoft-com:office:office\" "
            "xmlns:x=\"urn:schemas-microsoft-com:office:excel\" "
            "xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\">\n";

    // --- Results sayfası ---
    akis << "<Worksheet ss:Name=\"Results\">\n<Table>\n";
    const QDateTime simdi = QDateTime::currentDateTime();
    satir({ metin("Export Date"), metin(simdi.toString("yyyy-MM-dd")) });
    satir({ metin("Export Time"), metin(simdi.toString("HH:mm:ss")) });
    satir({ metin("Measurement ID"), sayi(olcumId) });
    satir({ metin("Measurement Date"), metin(bilgi["tarih"].toString()) });
    satir({ metin("Comment"), metin(bilgi["yorum"].toString()) });
    satir({ metin("Place"), metin(bilgi["yer"].toString()) });
    satir({ metin("Customer"), metin(bilgi["musteri"].toString()) });
    satir({ metin("Formula"), metin(bilgi["recete"].toString()) });
    satir({});

    satir({ metin("Stroke"), metin("Date [yyyy-mm-dd]"), metin("Time [hh:mm:ss]"),
            metin("Duration [sec]"), metin("pmax [mbar]"), metin("P0l [mbar]"),
            metin("P0r [mbar]"), metin("p [mbar]"), metin("Q [m3/h]"),
            metin("Weight [kg]"), metin("Valid"), metin("In forecast") });
    for (const QVariant &kayit : strokelar) {
        const QVariantMap stroke = kayit.toMap();
        satir({ sayi(stroke["stroke"].toInt()), metin(stroke["tarih"].toString()), metin(stroke["saat"].toString()),
                sayi(stroke["sure"].toDouble()), sayi(stroke["pMaks"].toDouble()), sayi(stroke["p0l"].toDouble()),
                sayi(stroke["p0r"].toDouble()), sayi(stroke["basinc"].toDouble()), sayi(stroke["debi"].toDouble()),
                sayi(stroke["agirlik"].toDouble()),
                metin(stroke["gecerli"].toBool() ? "yes" : "Wrong Stroke"),
                metin(stroke["secili"].toBool() ? "yes" : "no") });
    }
    satir({});

    satir({ metin("Forecast at following input parameters") });
    satir({ metin("Output Q1 [m3/h]"), sayi(ayarlar["q1"].toDouble()) });
    satir({ metin("Output Q2 [m3/h]"), sayi(ayarlar["q2"].toDouble()) });
    satir({ metin("Length of pipe L2 [m]"), sayi(ayarlar["l2"].toDouble()) });
    satir({ metin("Length of pipe L3 [m]"), sayi(ayarlar["l3"].toDouble()) });
    satir({ metin("Length of pipe L4 [m]"), sayi(ayarlar["l4"].toDouble()) });
    satir({ metin("Diameter of pipe D2 [m]"), sayi(ayarlar["cap"].toDouble() / 1000.0) });
    satir({ metin("bulk density [kg/m3]"), sayi(ayarlar["yogunluk"].toDouble()) });
    satir({ metin("pumping head h [m]"), sayi(ayarlar["yukseklik"].toDouble()) });
    satir({ metin("Error Bar Tolerance [%]"), sayi(ayarlar["hataPayi"].toDouble()) });
    satir({ metin("Pump max. pressure [bar]"), sayi(ayarlar["pompaMaks"].toDouble()) });
    satir({});

    const double kesisimA = pqSonucu["tau0"].toDouble();
    const double egimB = pqSonucu["mu"].toDouble();
    satir({ metin("A - p-Q intercept [mbar]"), sayi(kesisimA) });
    satir({ metin("B - p-Q slope [mbar*h/m3]"), sayi(egimB) });
    satir({ metin("a - Yield Pressure [mbar]"), sayi(SliperModel::schleibingerA(kesisimA)) });
    satir({ metin("b - Pressure Gradient [x1000]"), sayi(SliperModel::schleibingerB(egimB) * 1000.0) });
    satir({ metin("R2"), sayi(pqSonucu["r2"].toDouble()) });
    satir({ metin("Strokes used"), sayi(pqSonucu["n"].toInt()) });
    satir({});

    satir({ metin("Output Q [m3/h]"), metin("Length of pipe [m]"), metin("Pressure [bar]"),
            metin("Lower [bar]"), metin("Upper [bar]"), metin("Pump capacity") });
    const bool pompaGirildi = ayarlar["pompaMaks"].toDouble() > 0.0;
    for (const QVariant &kayit : tahminSatirlari) {
        const QVariantMap tahmin = kayit.toMap();
        satir({ sayi(tahmin["debi"].toDouble()), sayi(tahmin["uzunluk"].toDouble()),
                sayi(tahmin["basincBar"].toDouble()), sayi(tahmin["altSinirBar"].toDouble()),
                sayi(tahmin["ustSinirBar"].toDouble()),
                metin(!pompaGirildi ? "-" : (tahmin["pompaAsildi"].toBool() ? "exceeded" : "ok")) });
    }
    satir({});

    const QVariantMap konumSinirlari = kalibrasyonGetir("konum_sinirlari");
    const bool konumKalibreEdildi = konumSinirlari["mevcut"].toBool();
    satir({ metin("Device parameters") });
    satir({ metin("Diameter of rheometer [m]"), sayi(SliperModel::BORU_CAPI_M) });
    satir({ metin("Length of rheometer [m]"), sayi(SliperModel::BORU_UZUNLUGU_M) });
    satir({ metin("Top position [mm]"), konumKalibreEdildi ? sayi(konumSinirlari["deger1"].toDouble()) : metin("-") });
    satir({ metin("Bottom position [mm]"), konumKalibreEdildi ? sayi(konumSinirlari["deger2"].toDouble()) : metin("-") });
    satir({ metin("Load cell calibration"), metin(kalibrasyonTarihiGetir("loadcell")) });
    satir({ metin("Distance sensor calibration"), metin(kalibrasyonTarihiGetir("mesafe_olcum")) });
    akis << "</Table>\n</Worksheet>\n";

    // --- Her stroke için ham veri sayfası ---
    for (const QVariant &kayit : strokelar) {
        const QVariantMap stroke = kayit.toMap();
        const QVariantMap hamVeri = strokeHamVeriGetir(stroke["id"].toInt());
        const QVariantList zamanlar = hamVeri["t"].toList();
        const QVariantList konumlar = hamVeri["x"].toList();
        const QVariantList basinclar = hamVeri["p"].toList();

        akis << "<Worksheet ss:Name=\"Stroke_" << stroke["stroke"].toInt() << "\">\n<Table>\n";
        satir({ metin("Start [s]"), sayi(hamVeri["tBaslangic"].toDouble()),
                metin("End [s]"), sayi(hamVeri["tBitis"].toDouble()) });
        satir({ metin("Time [s]"), metin("Distance [mm]"), metin("Pressure [mbar]") });
        const int ornekSayisi = std::min({ zamanlar.size(), konumlar.size(), basinclar.size() });
        for (int i = 0; i < ornekSayisi; ++i) {
            satir({ sayi(zamanlar[i].toDouble()), sayi(konumlar[i].toDouble()), sayi(basinclar[i].toDouble()) });
        }
        akis << "</Table>\n</Worksheet>\n";
    }

    akis << "</Workbook>\n";

    dosya.close();
    qDebug() << "XML disa aktarildi:" << dosyaAdi;
    return dosyaAdi;
}

// Orijinal SLIPER'daki (Expert Settings > Database Export, sifre korumali)
// veritabani disa aktarim ozelligine karsilik gelir. Aktif SQLite baglantisi
// dosya uzerinde kilit tutabileceginden, kopyalamadan once WAL/journal'in
// diske yazilmasi icin basit bir bekleme (checkpoint) yapilir.
QString Database::veriTabaniDisaAktar()
{
    if (m_veriTabaniDosyaYolu.isEmpty() || !QFile::exists(m_veriTabaniDosyaYolu)) {
        qWarning() << "Disa aktarilacak veritabani bulunamadi.";
        return QString();
    }

    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    if (!QDir().mkpath(klasor)) {
        qWarning() << "Rapor klasoru olusturulamadi:" << klasor;
        return QString();
    }

    // Bekleyen yazmalarin diske gitmesini garantiye almak icin.
    QSqlQuery checkpoint(m_db);
    checkpoint.exec("PRAGMA wal_checkpoint(FULL)");

    QString hedefDosya = klasor + QString("/sliper_yedek_%1.db")
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    if (!QFile::copy(m_veriTabaniDosyaYolu, hedefDosya)) {
        qWarning() << "Veritabani disa aktarilamadi.";
        return QString();
    }

    qDebug() << "Veritabani disa aktarildi:" << hedefDosya;
    return hedefDosya;
}

// Orijinal SLIPER'daki "Database Import" ozelligine karsilik gelir. Ice
// aktarmadan once mevcut veritabaninin bir yedegi otomatik alinir; sonra
// baglanti kapatilip yeni dosya yerine kopyalanir ve yeniden acilir.
bool Database::veriTabaniIcaAktar(const QString &kaynakDosyaYolu)
{
    if (!QFile::exists(kaynakDosyaYolu)) {
        qWarning() << "Ice aktarilacak dosya bulunamadi:" << kaynakDosyaYolu;
        return false;
    }

    // Guvenlik: mevcut veriyi kaybetmemek icin otomatik yedek al.
    veriTabaniDisaAktar();

    m_db.close();

    QFile hedef(m_veriTabaniDosyaYolu);
    if (hedef.exists() && !hedef.remove()) {
        qWarning() << "Eski veritabani silinemedi, ice aktarim iptal edildi.";
        m_db.open();
        return false;
    }

    if (!QFile::copy(kaynakDosyaYolu, m_veriTabaniDosyaYolu)) {
        qWarning() << "Veritabani ice aktarilamadi.";
        m_db.open();
        return false;
    }

    if (!m_db.open()) {
        qWarning() << "Ice aktarim sonrasi veritabani acilamadi:" << m_db.lastError().text();
        return false;
    }

    tablolariOlustur();
    qDebug() << "Veritabani ice aktarildi:" << kaynakDosyaYolu;
    return true;
}

// Orijinal SLIPER'daki "Database Delete" ozelligine karsilik gelir. Sadece
// olcum/stroke verilerini siler; sensor kalibrasyonlari (load cell, mesafe,
// egim) korunur, cunku bunlar donanimsal kalibrasyon olup ayri bir islemdir.
bool Database::tumVeriyiSil()
{
    if (!m_db.transaction()) {
        qWarning() << "Tum veriyi silme icin transaction baslatilamadi:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery strokeSil;
    if (!strokeSil.exec("DELETE FROM Strokelar")) {
        qWarning() << "Strokelar silinemedi:" << strokeSil.lastError().text();
        m_db.rollback();
        return false;
    }

    QSqlQuery olcumSil;
    if (!olcumSil.exec("DELETE FROM Olcumler")) {
        qWarning() << "Olcumler silinemedi:" << olcumSil.lastError().text();
        m_db.rollback();
        return false;
    }

    if (!m_db.commit()) {
        qWarning() << "Tum veriyi silme commit edilemedi:" << m_db.lastError().text();
        return false;
    }

    qDebug() << "Tum olcum verileri silindi.";
    return true;
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
    // Alan içindeki ';' ve '"' karakterleri tabloyu bozmasın
    auto alan = [](QString yazi) {
        if (yazi.contains(';') || yazi.contains('"') || yazi.contains('\n')) {
            yazi.replace("\"", "\"\"");
            yazi = "\"" + yazi + "\"";
        }
        return yazi;
    };

    akis << "Olcum ID;" << olcumId << "\n";
    akis << "Tarih;" << alan(bilgi["tarih"].toString()) << "\n";
    akis << "Yer;" << alan(bilgi["yer"].toString()) << "\n";
    akis << "Musteri;" << alan(bilgi["musteri"].toString()) << "\n";
    akis << "Recete;" << alan(bilgi["recete"].toString()) << "\n";
    akis << "Yorum;" << alan(bilgi["yorum"].toString()) << "\n";
    akis << "\n";
    akis << "Stroke;Tarih;Saat;Sure (s);Pmax (mbar);P0l (mbar);P0r (mbar);p (mbar);Q (m3/h);"
            "Agirlik (kg);Gecerli;Tahmine Dahil\n";

    const QVariantList strokelar = strokeVerileriGetir(olcumId);
    for (const QVariant &kayit : strokelar) {
        const QVariantMap stroke = kayit.toMap();
        akis << stroke["stroke"].toInt() << ";"
             << stroke["tarih"].toString() << ";"
             << stroke["saat"].toString() << ";"
             << stroke["sure"].toDouble() << ";"
             << stroke["pMaks"].toDouble() << ";"
             << stroke["p0l"].toDouble() << ";"
             << stroke["p0r"].toDouble() << ";"
             << stroke["basinc"].toDouble() << ";"
             << stroke["debi"].toDouble() << ";"
             << stroke["agirlik"].toDouble() << ";"
             << (stroke["gecerli"].toBool() ? "Evet" : "Hatali Stroke") << ";"
             << (stroke["secili"].toBool() ? "Evet" : "Hayir") << "\n";
    }

    const QVariantMap pqSonucu = binghamHesapla(olcumId);
    const double kesisimA = pqSonucu["tau0"].toDouble();
    const double egimB = pqSonucu["mu"].toDouble();
    akis << "\n";
    akis << "A (mbar);" << kesisimA << "\n";
    akis << "B (mbar.h/m3);" << egimB << "\n";
    akis << "a (mbar);" << SliperModel::schleibingerA(kesisimA) << "\n";
    akis << "b (x1000);" << SliperModel::schleibingerB(egimB) * 1000.0 << "\n";
    akis << "R2;" << pqSonucu["r2"].toDouble() << "\n";

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
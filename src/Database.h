#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>
#include <QVariantMap>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);

    // --- Ölçüm (orijinal "Measure Preferences": place, customer, formula + comment) ---
    Q_INVOKABLE int olcumBaslat(const QString &musteri, const QString &recete, double agirlik,
                                const QString &yer = QString(), const QString &yorum = QString());
    Q_INVOKABLE bool olcumBilgisiGuncelle(int olcumId, const QString &yer, const QString &musteri,
                                          const QString &recete, const QString &yorum);
    Q_INVOKABLE bool olcumSil(int olcumId);
    Q_INVOKABLE QVariantList tumOlcumleriGetir();
    Q_INVOKABLE QVariantMap olcumBilgisiGetir(int olcumId);

    // --- Stroke'lar ---
    // stroke: Calculator::strokeTamamlandi haritası; agirlik: stroke anındaki ek ağırlık (kg)
    Q_INVOKABLE int strokeKaydet(int olcumId, const QVariantMap &stroke, double agirlik);
    Q_INVOKABLE QVariantList strokeVerileriGetir(int olcumId);
    Q_INVOKABLE QVariantMap strokeHamVeriGetir(int strokeId);
    // Orijinal "Table of Strokes": tahmin hesabından çıkar / geri al, kalıcı sil
    Q_INVOKABLE bool strokeSeciliAyarla(int strokeId, bool secili);
    Q_INVOKABLE bool strokeSil(int strokeId);

    // --- Sonuç ve tahmin ---
    Q_INVOKABLE QVariantMap binghamHesapla(int olcumId);
    Q_INVOKABLE QVariantMap tahminAyarlariGetir(int olcumId);
    Q_INVOKABLE bool tahminAyarlariKaydet(int olcumId, const QVariantMap &ayarlar);
    Q_INVOKABLE QVariantMap varsayilanTahminAyarlariGetir();
    Q_INVOKABLE QVariantList tahminTablosuGetir(int olcumId);

    // --- Genel ayarlar (anahtar/değer) ---
    Q_INVOKABLE QString ayarGetir(const QString &anahtar, const QString &varsayilan = QString());
    Q_INVOKABLE bool ayarKaydet(const QString &anahtar, const QString &deger);

    // --- Dışa aktarım / veritabanı yönetimi ---
    Q_INVOKABLE QString csvDisaAktar(int olcumId);
    Q_INVOKABLE QString xmlDisaAktar(int olcumId);
    Q_INVOKABLE QString veriTabaniDisaAktar();
    Q_INVOKABLE bool veriTabaniIcaAktar(const QString &kaynakDosyaYolu);
    Q_INVOKABLE bool tumVeriyiSil();

    // --- Kalibrasyon ---
    Q_INVOKABLE bool kalibrasyonKaydet(const QString &sensor, double deger1, double deger2);
    Q_INVOKABLE QVariantMap kalibrasyonGetir(const QString &sensor);
    Q_INVOKABLE bool loadCellNoktalariKaydet(const QVariantList &noktalar);
    Q_INVOKABLE QVariantList loadCellNoktalariGetir();
    Q_INVOKABLE bool mesafeNoktalariKaydet(const QVariantList &noktalar);
    Q_INVOKABLE QVariantList mesafeNoktalariGetir();
    Q_INVOKABLE bool egimKalibrasyonuKaydet(double biasX, double biasY, double biasZ,
                                             double gainX, double gainY, double gainZ);
    Q_INVOKABLE QVariantMap egimKalibrasyonuGetir();
    Q_INVOKABLE void kalibrasyonTarihiKaydet(const QString &sensor);
    Q_INVOKABLE QString kalibrasyonTarihiGetir(const QString &sensor);

private:
    void tablolariOlustur();
    static QString jsonYaz(const QVariantMap &veri);
    static QVariantMap jsonOku(const QString &json);
    QSqlDatabase m_db;
    QString m_veriTabaniDosyaYolu;
};

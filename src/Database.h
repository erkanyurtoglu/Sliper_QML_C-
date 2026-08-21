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

    Q_INVOKABLE int olcumBaslat(const QString &musteri, const QString &recete, double agirlik);
    Q_INVOKABLE void strokeKaydet(int olcumId, double basinc, double konum, double debi, bool gecerli);
    Q_INVOKABLE bool olcumSil(int olcumId);
    Q_INVOKABLE QVariantList tumOlcumleriGetir();
    Q_INVOKABLE QVariantList strokeVerileriGetir(int olcumId);
    Q_INVOKABLE QVariantMap binghamHesapla(int olcumId);
    Q_INVOKABLE bool kalibrasyonKaydet(const QString &sensor, double deger1, double deger2);
    Q_INVOKABLE QVariantMap kalibrasyonGetir(const QString &sensor);
    Q_INVOKABLE QVariantMap olcumBilgisiGetir(int olcumId);
    Q_INVOKABLE QString csvDisaAktar(int olcumId);
    Q_INVOKABLE QString xmlDisaAktar(int olcumId);
    Q_INVOKABLE QString veriTabaniDisaAktar();
    Q_INVOKABLE bool veriTabaniIcaAktar(const QString &kaynakDosyaYolu);
    Q_INVOKABLE bool tumVeriyiSil();
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
    QSqlDatabase m_db;
    QString m_veriTabaniDosyaYolu;
};
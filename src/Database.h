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
    Q_INVOKABLE QVariantList tumOlcumleriGetir();
    Q_INVOKABLE QVariantList strokeVerileriGetir(int olcumId);
    Q_INVOKABLE QVariantMap binghamHesapla(int olcumId);
    Q_INVOKABLE void kalibrasyonKaydet(const QString &sensor, double deger1, double deger2);
    Q_INVOKABLE QVariantMap kalibrasyonGetir(const QString &sensor);
    Q_INVOKABLE QVariantMap olcumBilgisiGetir(int olcumId);
    Q_INVOKABLE bool csvDisaAktar(int olcumId);
    Q_INVOKABLE void loadCellNoktalariKaydet(const QVariantList &noktalar);
    Q_INVOKABLE QVariantList loadCellNoktalariGetir();

private:
    void tablolariOlustur();
    QSqlDatabase m_db;
};
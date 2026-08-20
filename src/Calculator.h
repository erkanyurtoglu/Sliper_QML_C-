#pragma once
#include <QObject>

class Calculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString durum READ durum NOTIFY durumChanged)
    Q_PROPERTY(int strokeSayisi READ strokeSayisi NOTIFY strokeSayisiChanged)
    Q_PROPERTY(bool duraklatildi READ duraklatildi NOTIFY duraklatildiChanged)
    Q_PROPERTY(double ustEsik READ ustEsik NOTIFY esiklerChanged)
    Q_PROPERTY(double altEsik READ altEsik NOTIFY esiklerChanged)

public:
    explicit Calculator(QObject *parent = nullptr);
    QString durum() const;
    int strokeSayisi() const;
    bool duraklatildi() const;
    double ustEsik() const;
    double altEsik() const;

    Q_INVOKABLE void konumGuncelle(double konum);
    Q_INVOKABLE void duraklat();
    Q_INVOKABLE void devamEt();
    Q_INVOKABLE void sifirla();
    Q_INVOKABLE void esikleriAyarla(double ust, double alt);

signals:
    void durumChanged();
    void strokeSayisiChanged();
    void duraklatildiChanged();
    void esiklerChanged();

private:
    QString m_durum = "BEKLENIYOR";
    int m_strokeSayisi = 0;
    bool m_duraklatildi = false;
    bool m_yukaridaGorulduMu = false;
    double m_ustEsik = 450.0;
    double m_altEsik = 20.0;
};
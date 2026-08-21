#pragma once
#include <QObject>

class SensorManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double basinc READ basinc NOTIFY basincChanged)
    Q_PROPERTY(double konum READ konum NOTIFY konumChanged)
    Q_PROPERTY(double hiz READ hiz NOTIFY hizChanged)
    Q_PROPERTY(double debi READ debi NOTIFY debiChanged)
    Q_PROPERTY(double egimX READ egimX NOTIFY egimXChanged)
    Q_PROPERTY(double egimY READ egimY NOTIFY egimYChanged)
    Q_PROPERTY(double hamAgirlik READ hamAgirlik NOTIFY hamAgirlikChanged)
    Q_PROPERTY(double hamMesafe READ hamMesafe NOTIFY hamMesafeChanged)
    Q_PROPERTY(double hamAccelX READ hamAccelX NOTIFY hamAccelDegisti)
    Q_PROPERTY(double hamAccelY READ hamAccelY NOTIFY hamAccelDegisti)
    Q_PROPERTY(double hamAccelZ READ hamAccelZ NOTIFY hamAccelDegisti)
    Q_PROPERTY(bool veriGecerli READ veriGecerli NOTIFY veriGecerliChanged)
    Q_PROPERTY(double bataryaVoltaj READ bataryaVoltaj NOTIFY bataryaVoltajChanged)

public:
    explicit SensorManager(QObject *parent = nullptr);

    double basinc() const;
    double konum() const;
    double hiz() const;
    double debi() const;
    double egimX() const;
    double egimY() const;
    double hamAgirlik() const;
    double hamMesafe() const;
    double hamAccelX() const;
    double hamAccelY() const;
    double hamAccelZ() const;
    bool veriGecerli() const;
    double bataryaVoltaj() const;

    Q_INVOKABLE void veriGuncelle(double basinc, double konum, double hiz, double debi, double egimX, double egimY);
    Q_INVOKABLE void hamAgirlikGuncelle(double hamAgirlik);
    Q_INVOKABLE void hamMesafeGuncelle(double hamMesafe);
    Q_INVOKABLE void hamAccelGuncelle(double x, double y, double z);
    Q_INVOKABLE void bataryaVoltajGuncelle(double voltaj);
    Q_INVOKABLE void veriyiGecersizYap();

signals:
    void basincChanged();
    void konumChanged();
    void hizChanged();
    void debiChanged();
    void egimXChanged();
    void egimYChanged();
    void hamAgirlikChanged();
    void hamMesafeChanged();
    void hamAccelDegisti();
    void veriGecerliChanged();
    void veriGuncellendi();
    void bataryaVoltajChanged();

private:
    double m_basinc = 0.0;
    double m_konum = 0.0;
    double m_hiz = 0.0;
    double m_debi = 0.0;
    double m_egimX = 0.0;
    double m_egimY = 0.0;
    double m_hamAgirlik = 0.0;
    double m_hamMesafe = 0.0;
    double m_hamAccelX = 0.0;
    double m_hamAccelY = 0.0;
    double m_hamAccelZ = 0.0;
    bool m_veriGecerli = false;
    double m_bataryaVoltaj = 0.0;
};
#pragma once
#include <QObject>
#include <QTimer>

class SensorManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double basinc READ basinc NOTIFY basincChanged)
    Q_PROPERTY(double konum READ konum NOTIFY konumChanged)
    Q_PROPERTY(double hiz READ hiz NOTIFY hizChanged)
    Q_PROPERTY(double debi READ debi NOTIFY debiChanged)

public:
    explicit SensorManager(QObject *parent = nullptr);
    double basinc() const;
    double konum() const;
    double hiz() const;
    double debi() const;

public slots:
    void veriUret();

signals:
    void basincChanged();
    void konumChanged();
    void hizChanged();
    void debiChanged();

private:
    double m_basinc = 0.0;
    double m_konum = 0.0;
    double m_hiz = 0.0;
    double m_debi = 0.0;
    QTimer *m_timer;
};
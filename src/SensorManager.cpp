#include "SensorManager.h"
#include <QRandomGenerator>

SensorManager::SensorManager(QObject *parent)
    : QObject(parent)
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &SensorManager::veriUret);
    m_timer->start(200);
}

double SensorManager::basinc() const
{
    return m_basinc;
}

double SensorManager::konum() const
{
    return m_konum;
}

double SensorManager::hiz() const
{
    return m_hiz;
}

double SensorManager::debi() const
{
    return m_debi;
}

void SensorManager::veriUret()
{
    m_basinc = QRandomGenerator::global()->bounded(0, 300) / 10.0;
    emit basincChanged();

    m_konum = QRandomGenerator::global()->bounded(0, 5000) / 10.0;
    emit konumChanged();

    m_hiz = QRandomGenerator::global()->bounded(0, 40) / 10.0;
    emit hizChanged();

    m_debi = QRandomGenerator::global()->bounded(0, 150) / 10.0;
    emit debiChanged();
}
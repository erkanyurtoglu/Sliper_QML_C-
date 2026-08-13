#include "SensorManager.h"

SensorManager::SensorManager(QObject *parent)
    : QObject(parent)
{
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

bool SensorManager::veriGecerli() const
{
    return m_veriGecerli;
}

void SensorManager::veriGuncelle(double basinc, double konum, double hiz, double debi)
{
    const bool veriGecerliDegisti = !m_veriGecerli;
    m_veriGecerli = true;

    if (m_basinc != basinc) {
        m_basinc = basinc;
        emit basincChanged();
    }

    if (m_konum != konum) {
        m_konum = konum;
        emit konumChanged();
    }

    if (m_hiz != hiz) {
        m_hiz = hiz;
        emit hizChanged();
    }

    if (m_debi != debi) {
        m_debi = debi;
        emit debiChanged();
    }

    if (veriGecerliDegisti) {
        emit veriGecerliChanged();
    }
}

void SensorManager::veriyiGecersizYap()
{
    if (!m_veriGecerli) {
        return;
    }

    m_veriGecerli = false;
    emit veriGecerliChanged();
}
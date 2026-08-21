#include "SensorManager.h"

SensorManager::SensorManager(QObject *parent)
    : QObject(parent)
{
}

double SensorManager::basinc() const { return m_basinc; }
double SensorManager::konum() const { return m_konum; }
double SensorManager::hiz() const { return m_hiz; }
double SensorManager::debi() const { return m_debi; }
double SensorManager::egimX() const { return m_egimX; }
double SensorManager::egimY() const { return m_egimY; }
double SensorManager::hamAgirlik() const { return m_hamAgirlik; }
double SensorManager::hamMesafe() const { return m_hamMesafe; }
double SensorManager::hamAccelX() const { return m_hamAccelX; }
double SensorManager::hamAccelY() const { return m_hamAccelY; }
double SensorManager::hamAccelZ() const { return m_hamAccelZ; }
bool SensorManager::veriGecerli() const { return m_veriGecerli; }
double SensorManager::bataryaVoltaj() const { return m_bataryaVoltaj; }

void SensorManager::veriGuncelle(double basinc, double konum, double hiz, double debi, double egimX, double egimY)
{
    const bool veriGecerliDegisti = !m_veriGecerli;
    m_veriGecerli = true;

    if (m_basinc != basinc) { m_basinc = basinc; emit basincChanged(); }
    if (m_konum != konum) { m_konum = konum; emit konumChanged(); }
    if (m_hiz != hiz) { m_hiz = hiz; emit hizChanged(); }
    if (m_debi != debi) { m_debi = debi; emit debiChanged(); }
    if (m_egimX != egimX) { m_egimX = egimX; emit egimXChanged(); }
    if (m_egimY != egimY) { m_egimY = egimY; emit egimYChanged(); }
    if (veriGecerliDegisti) { emit veriGecerliChanged(); }

    emit veriGuncellendi();
}

void SensorManager::hamAgirlikGuncelle(double hamAgirlik)
{
    if (m_hamAgirlik != hamAgirlik) {
        m_hamAgirlik = hamAgirlik;
        emit hamAgirlikChanged();
    }
}

void SensorManager::hamMesafeGuncelle(double hamMesafe)
{
    if (m_hamMesafe != hamMesafe) {
        m_hamMesafe = hamMesafe;
        emit hamMesafeChanged();
    }
}

void SensorManager::hamAccelGuncelle(double x, double y, double z)
{
    if (m_hamAccelX != x || m_hamAccelY != y || m_hamAccelZ != z) {
        m_hamAccelX = x;
        m_hamAccelY = y;
        m_hamAccelZ = z;
        emit hamAccelDegisti();
    }
}

void SensorManager::bataryaVoltajGuncelle(double voltaj)
{
    if (m_bataryaVoltaj != voltaj) {
        m_bataryaVoltaj = voltaj;
        emit bataryaVoltajChanged();
    }
}

void SensorManager::veriyiGecersizYap()
{
    if (!m_veriGecerli) return;
    m_veriGecerli = false;
    emit veriGecerliChanged();
}
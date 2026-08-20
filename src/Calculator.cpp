#include "Calculator.h"
#include <QDebug>

Calculator::Calculator(QObject *parent)
    : QObject(parent)
{
}

QString Calculator::durum() const
{
    return m_durum;
}

int Calculator::strokeSayisi() const
{
    return m_strokeSayisi;
}

bool Calculator::duraklatildi() const
{
    return m_duraklatildi;
}

double Calculator::ustEsik() const
{
    return m_ustEsik;
}

double Calculator::altEsik() const
{
    return m_altEsik;
}

void Calculator::konumGuncelle(double konum)
{
    if (m_duraklatildi) {
        return;
    }

    QString yeniDurum;

    if (konum > m_ustEsik) {
        yeniDurum = "YUKARIDA";
    } else if (konum > m_altEsik) {
        yeniDurum = "INIYOR";
    } else {
        yeniDurum = "TAMAMLANDI";
    }

    if (yeniDurum == "YUKARIDA") {
        m_yukaridaGorulduMu = true;
    }

    if (yeniDurum == "TAMAMLANDI" && m_durum != "TAMAMLANDI" && m_yukaridaGorulduMu) {
        m_strokeSayisi++;
        m_yukaridaGorulduMu = false;
        emit strokeSayisiChanged();
    }

    if (yeniDurum != m_durum) {
        m_durum = yeniDurum;
        emit durumChanged();
    }
}

void Calculator::duraklat()
{
    if (m_duraklatildi) {
        return;
    }

    m_duraklatildi = true;
    emit duraklatildiChanged();
}

void Calculator::devamEt()
{
    if (!m_duraklatildi) {
        return;
    }

    m_duraklatildi = false;
    emit duraklatildiChanged();
}

void Calculator::sifirla()
{
    m_strokeSayisi = 0;
    m_durum = "BEKLENIYOR";
    m_duraklatildi = false;
    m_yukaridaGorulduMu = false;
    emit strokeSayisiChanged();
    emit durumChanged();
    emit duraklatildiChanged();
}

void Calculator::esikleriAyarla(double ust, double alt)
{
    if (ust <= alt) {
        qWarning() << "Gecersiz esik degerleri, ust alt'tan buyuk olmali:" << ust << alt;
        return;
    }

    m_ustEsik = ust;
    m_altEsik = alt;
    emit esiklerChanged();
}
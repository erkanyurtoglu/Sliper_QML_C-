#include "Calculator.h"

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

void Calculator::konumGuncelle(double konum)
{
    if (m_duraklatildi) {
        return;
    }

    QString yeniDurum;

    if (konum > 450) {
        yeniDurum = "YUKARIDA";
    } else if (konum > 20) {
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
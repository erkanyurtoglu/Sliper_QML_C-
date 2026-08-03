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

void Calculator::konumGuncelle(double konum)
{
    QString yeniDurum;

    if (konum > 450) {
        yeniDurum = "YUKARIDA";
    } else if (konum > 20) {
        yeniDurum = "INIYOR";
    } else {
        yeniDurum = "TAMAMLANDI";
    }

    if (yeniDurum == "TAMAMLANDI" && m_durum != "TAMAMLANDI") {
        m_strokeSayisi++;
        emit strokeSayisiChanged();
    }

    if (yeniDurum != m_durum) {
        m_durum = yeniDurum;
        emit durumChanged();
    }
}
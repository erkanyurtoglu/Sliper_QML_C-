#include "Calculator.h"
#include <cmath>

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

bool Calculator::sonStrokeGecerli() const
{
    return m_sonStrokeGecerli;
}

void Calculator::konumGuncelle(double konum, double hiz)
{
    if (m_duraklatildi) {
        return;
    }

    m_sonHiz = hiz;

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
        // Orijinal SLIPER'daki "invalid stroke" mantığı: hızı negatif veya
        // sıfır olan stroke'lar geçersiz sayılır (boru gerçekte hareket
        // etmemiş veya sensör verisi tutarsızdır).
        m_sonStrokeGecerli = hiz > 0.0;
        emit sonStrokeGecerliChanged();

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
    m_sonStrokeGecerli = true;
    m_sonHiz = 0.0;
    emit strokeSayisiChanged();
    emit durumChanged();
    emit duraklatildiChanged();
    emit sonStrokeGecerliChanged();
}

QVariantMap Calculator::boruHattiTahminHesapla(double tau0Mbar, double muMbarHm3,
                                                double debiM3h, double boruCapiMm,
                                                double boruUzunluguM,
                                                double hataPayiYuzde) const
{
    QVariantMap sonuc;
    sonuc["gecerliGiris"] = false;
    sonuc["basincBar"] = 0.0;
    sonuc["altSinirBar"] = 0.0;
    sonuc["ustSinirBar"] = 0.0;

    if (boruCapiMm <= 0.0 || boruUzunluguM <= 0.0 || debiM3h < 0.0) {
        return sonuc;
    }

    const double D_ref = REF_BORU_CAPI_MM / 1000.0;   // m
    const double L_ref = REF_BORU_UZUNLUGU_M;         // m
    const double A_ref = M_PI * (D_ref / 2.0) * (D_ref / 2.0); // m^2

    // Referans borudaki (tau0, mu) katsayılarından "gerçek" Bingham
    // rheolojik parametrelerini (tau0': Pa, mu': Pa.s) geri hesapla.
    // Bkz. Calculator.h başındaki formül açıklaması.
    const double tau0Prime = (100.0 * tau0Mbar * D_ref) / (4.0 * L_ref);
    const double muPrime = (100.0 * muMbarHm3 * A_ref * 3600.0 * D_ref * D_ref) / (32.0 * L_ref);

    const double D_t = boruCapiMm / 1000.0; // m
    const double L_t = boruUzunluguM;       // m
    const double A_t = M_PI * (D_t / 2.0) * (D_t / 2.0); // m^2
    const double v_t = (debiM3h / 3600.0) / A_t;         // m/s

    const double basincPa = L_t * (4.0 * tau0Prime / D_t + 32.0 * muPrime * v_t / (D_t * D_t));
    const double basincBar = basincPa / 1.0e5;

    const double tolerans = qBound(0.0, hataPayiYuzde, 100.0) / 100.0;

    sonuc["gecerliGiris"] = true;
    sonuc["basincBar"] = basincBar;
    sonuc["altSinirBar"] = basincBar * (1.0 - tolerans);
    sonuc["ustSinirBar"] = basincBar * (1.0 + tolerans);
    return sonuc;
}

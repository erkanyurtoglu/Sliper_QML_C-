#pragma once
#include <QObject>
#include <QVariantMap>
#include <QVector>
#include <QDateTime>

class Calculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString durum READ durum NOTIFY durumChanged)
    Q_PROPERTY(int strokeSayisi READ strokeSayisi NOTIFY strokeSayisiChanged)
    Q_PROPERTY(bool duraklatildi READ duraklatildi NOTIFY duraklatildiChanged)
    Q_PROPERTY(bool hazirlaniyor READ hazirlaniyor NOTIFY hazirlikChanged)
    Q_PROPERTY(bool hazir READ hazir NOTIFY hazirlikChanged)
    Q_PROPERTY(bool sonStrokeGecerli READ sonStrokeGecerli NOTIFY sonStrokeGecerliChanged)
    Q_PROPERTY(QVariantMap sonStroke READ sonStroke NOTIFY sonStrokeChanged)
    Q_PROPERTY(double ustKonumMm READ ustKonumMm WRITE setUstKonumMm NOTIFY konumSinirlariChanged)
    Q_PROPERTY(double altKonumMm READ altKonumMm WRITE setAltKonumMm NOTIFY konumSinirlariChanged)

public:
    explicit Calculator(QObject *parent = nullptr);
    QString durum() const;
    int strokeSayisi() const;
    bool duraklatildi() const;
    bool hazirlaniyor() const;
    bool hazir() const;
    bool sonStrokeGecerli() const;
    QVariantMap sonStroke() const;
    double ustKonumMm() const;
    double altKonumMm() const;
    void setUstKonumMm(double deger);
    void setAltKonumMm(double deger);

    Q_INVOKABLE void konumGuncelle(double zamanS, double konumMm, double basincMbar);
    Q_INVOKABLE void hazirla();
    Q_INVOKABLE void duraklat();
    Q_INVOKABLE void devamEt();
    Q_INVOKABLE void sifirla();

    Q_INVOKABLE QVariantMap boruHattiTahminHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                                    double debiM3h, double boruCapiMm,
                                                    double boruUzunluguM,
                                                    double pompalamaYuksekligiM,
                                                    double yogunlukKgM3,
                                                    double hataPayiYuzde) const;
    Q_INVOKABLE QVariantList tahminTablosuHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                                   const QVariantMap &ayarlar) const;
    Q_INVOKABLE QVariantMap varsayilanTahminAyarlari() const;
    Q_INVOKABLE QString tahminGuvenilmezNedeni(double kesisimA, double egimB, double r2) const;
    Q_INVOKABLE bool tahminKarariVerilemez(const QString &guvenilmezNedeni) const;
    Q_INVOKABLE double schleibingerA(double kesisimA) const;
    Q_INVOKABLE double schleibingerB(double egimB) const;
    Q_INVOKABLE double ustYakalamaToleransiMm() const;
    Q_INVOKABLE double minInisYoluMm() const;
    Q_INVOKABLE double sliperBoruCapiMm() const;
    Q_INVOKABLE double sliperBoruUzunluguMm() const;
    Q_INVOKABLE QVariantList hizEgrisiHesapla(const QVariantList &zamanS, const QVariantList &konumMm,
                                              double konumYonu) const;

signals:
    void durumChanged();
    void strokeSayisiChanged();
    void duraklatildiChanged();
    void hazirlikChanged();
    void sonStrokeGecerliChanged();
    void sonStrokeChanged();
    void konumSinirlariChanged();
    void strokeTamamlandi(const QVariantMap &stroke);

private:
    struct Ornek {
        double zamanS;
        double yukseklikMm;
        double basincMbar;
    };

    void strokuBaslat(double zamanS);
    void strokuBitir();
    void hazirlamaOrnegiIsle(const Ornek &yeniOrnek);
    void hazirlamayiIptalEt();
    void hazirligiSifirla();
    int durmaBaslangicIndeksi(double zamanS) const;
    void inisiKapat(double zamanS, int bitisIndeksi = -1);
    void durumAyarla(const QString &yeniDurum);
    double yon() const { return m_ustKonumMm >= m_altKonumMm ? 1.0 : -1.0; }
    double ustEsik() const;
    double altEsik() const;

    QString m_durum = "BEKLENIYOR";
    int m_strokeSayisi = 0;
    bool m_duraklatildi = false;
    bool m_sonStrokeGecerli = true;
    QVariantMap m_sonStroke;
    double m_ustKonumMm = 40.0;
    double m_altKonumMm = 540.0;

    bool m_hazirlaniyor = false;
    bool m_hazir = false;
    QVector<Ornek> m_hazirlamaOrnekleri;
    double m_hazirlananP0lMbar = 0.0;
    double m_strokeP0lMbar = 0.0;
    QVector<Ornek> m_ustteBekleyenOrnekler;
    QVector<Ornek> m_durgunOrnekler;
    QVector<Ornek> m_strokeOrnekleri;
    int m_altaVarisIndeksi = -1;
    double m_inisBaslangicYuksekligiMm = 0.0;
    double m_bitisYuksekligiMm = 0.0;
    double m_baslangicZamaniS = 0.0;
    double m_bitisZamaniS = 0.0;
    QDateTime m_bitisTarihi;
    bool m_bitisSonrasiToplaniyor = false;
};

#pragma once
#include <QObject>
#include <QVariantMap>

class Calculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString durum READ durum NOTIFY durumChanged)
    Q_PROPERTY(int strokeSayisi READ strokeSayisi NOTIFY strokeSayisiChanged)
    Q_PROPERTY(bool duraklatildi READ duraklatildi NOTIFY duraklatildiChanged)
    Q_PROPERTY(bool sonStrokeGecerli READ sonStrokeGecerli NOTIFY sonStrokeGecerliChanged)

public:
    explicit Calculator(QObject *parent = nullptr);
    QString durum() const;
    int strokeSayisi() const;
    bool duraklatildi() const;
    bool sonStrokeGecerli() const;

    // konum: mesafe sensöründen gelen anlık konum (mm)
    // hiz: sensorManager.hiz üzerinden hesaplanan anlık hız (m/s)
    // Stroke tamamlandığında (YUKARIDA -> INIYOR -> TAMAMLANDI geçişinde),
    // orijinal SLIPER cihazındaki "invalid stroke" mantığına paralel olarak
    // hız negatif veya sıfırsa (yani boru gerçekte hareket etmediyse ya da
    // yön/konum sensörü tutarsız veri verdiyse) stroke geçersiz sayılır.
    Q_INVOKABLE void konumGuncelle(double konum, double hiz);
    Q_INVOKABLE void duraklat();
    Q_INVOKABLE void devamEt();
    Q_INVOKABLE void sifirla();

    // Bingham modelinden (tau0, mu) elde edilen değerleri, hedef pompa
    // hattının çapı ve uzunluğuna göre ölçekleyerek beklenen basınç kaybını
    // hesaplar. Referans değerler SLIPER'ın kendi ölçüm borusuna aittir
    // (boru çapı 126 mm, dolum yüksekliği/ölçüm uzunluğu 500 mm -
    // bkz. Datasheet_SLIPER.pdf / slipermanV13.pdf "Technical specifications").
    //
    // NOT: Orijinal Schleibinger SLIPER yazılımının tam hesaplama modeli
    // kamuya açık değildir. Burada kullanılan yaklaşım, Bingham akışkanlar
    // için bilinen genelleştirilmiş boru basınç kaybı formülüne dayanır:
    //   dP/dL = 4*tau0/D + 32*mu*v/D^2
    // (v: ortalama akış hızı = Q/A). Referans borudaki ölçümden elde edilen
    // tau0 ve mu, bu formülle referans geometriye göre "geri hesaplanır",
    // sonra hedef boru geometrisine uygulanır. Bu, sahadaki gerçek pompa
    // basıncıyla karşılaştırılarak doğrulanmalıdır - kesin mühendislik
    // referansı olarak kullanılmadan önce gerçek verilerle kalibre edilmeli.
    Q_INVOKABLE QVariantMap boruHattiTahminHesapla(double tau0Mbar, double muMbarHm3,
                                                    double debiM3h, double boruCapiMm,
                                                    double boruUzunluguM,
                                                    double hataPayiYuzde) const;

signals:
    void durumChanged();
    void strokeSayisiChanged();
    void duraklatildiChanged();
    void sonStrokeGecerliChanged();

private:
    QString m_durum = "BEKLENIYOR";
    int m_strokeSayisi = 0;
    bool m_duraklatildi = false;
    bool m_yukaridaGorulduMu = false;
    bool m_sonStrokeGecerli = true;
    double m_sonHiz = 0.0;

    // Referans geometri: SLIPER'ın kendi ölçüm borusu (WifiManager::BORU_CAPI_M ile aynı)
    static constexpr double REF_BORU_CAPI_MM = 126.0;
    static constexpr double REF_BORU_UZUNLUGU_M = 0.5;
};

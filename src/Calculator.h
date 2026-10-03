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
    Q_PROPERTY(bool sonStrokeGecerli READ sonStrokeGecerli NOTIFY sonStrokeGecerliChanged)
    Q_PROPERTY(QVariantMap sonStroke READ sonStroke NOTIFY sonStrokeChanged)
    // Kalibre edilmiş üst/alt boru konumları (mm). Orijinal cihazdaki
    // "Calibrate Top/Bottom Position" referans noktalarına karşılık gelir.
    Q_PROPERTY(double ustKonumMm READ ustKonumMm WRITE setUstKonumMm NOTIFY konumSinirlariChanged)
    Q_PROPERTY(double altKonumMm READ altKonumMm WRITE setAltKonumMm NOTIFY konumSinirlariChanged)

public:
    explicit Calculator(QObject *parent = nullptr);
    QString durum() const;
    int strokeSayisi() const;
    bool duraklatildi() const;
    bool sonStrokeGecerli() const;
    QVariantMap sonStroke() const;
    double ustKonumMm() const;
    double altKonumMm() const;
    void setUstKonumMm(double deger);
    void setAltKonumMm(double deger);

    // Her sensör örneğinde çağrılır.
    // zamanS: cihaz zaman damgası (s), konumMm: boru konumu (mm, yukarıda büyük),
    // basincMbar: piston üzerindeki toplam basınç (betonun ölü ağırlığı dahil).
    //
    // Stroke mantığı (orijinal SLIPER kılavuzu bölüm 5):
    //  - Boru üst referansın altına indiğinde başlangıç işaretlenir. Bitiş,
    //    borunun durduğu andır (alt referansa varmak da bitiştir, ama tek
    //    ölçüt değildir: beton dolu boru alt kalibrasyon noktasına kadar
    //    inmeyebilir ve stroke o zaman hiç kapanmazdı). Başlangıçtan 2 s önce
    //    ile bitişten 2 s sonrası arasındaki veri stroke olarak saklanır.
    //  - P0l: hareket öncesi durağan basınç, P0r: bitiş sonrası durağan basınç
    //  - p, Q, v ve geçersizlik kuralı SliperModel'de (bölüm 5) hesaplanır;
    //    bu sınıf yalnızca hangi örneklerin kullanılacağını seçer.
    //  - Sonuç strokeTamamlandi sinyaliyle bildirilir.
    Q_INVOKABLE void konumGuncelle(double zamanS, double konumMm, double basincMbar);
    Q_INVOKABLE void duraklat();
    Q_INVOKABLE void devamEt();
    Q_INVOKABLE void sifirla();

    // Bkz. SliperModel::basincTahmini / tahminTablosu
    Q_INVOKABLE QVariantMap boruHattiTahminHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                                    double debiM3h, double boruCapiMm,
                                                    double boruUzunluguM,
                                                    double pompalamaYuksekligiM,
                                                    double yogunlukKgM3,
                                                    double hataPayiYuzde) const;
    Q_INVOKABLE QVariantList tahminTablosuHesapla(double aKesisimMbar, double bEgimMbarHm3,
                                                   const QVariantMap &ayarlar) const;
    Q_INVOKABLE QVariantMap varsayilanTahminAyarlari() const;
    // P-Q kesişim/eğiminden Schleibinger a/b (bkz. SliperModel bölüm 8)
    Q_INVOKABLE double schleibingerA(double kesisimA) const;
    Q_INVOKABLE double schleibingerB(double egimB) const;
    // Borunun "üstte" sayılması için üst referansa gereken yakınlık (mm).
    // QML grafik kaydıyla Calculator'ın stroke mantığı aynı eşiği kullansın diye
    // buradan okunur (bkz. SliperModel bölüm 4).
    Q_INVOKABLE double ustYakalamaToleransiMm() const;
    // "İniş gerçekten başladı" sayılması için gereken yol (mm). Grafik kaydı da
    // bunu kullanır ki grafiğin ve stroke hesabının iniş tanımı aynı olsun.
    Q_INVOKABLE double minInisYoluMm() const;
    Q_INVOKABLE double sliperBoruCapiMm() const;
    Q_INVOKABLE double sliperBoruUzunluguMm() const;
    // Sonuç sayfasındaki stroke hız eğrisi (bkz. SliperModel bölüm 10). Dönüş: m/s listesi
    Q_INVOKABLE QVariantList hizEgrisiHesapla(const QVariantList &zamanS, const QVariantList &konumMm,
                                              double konumYonu) const;

signals:
    void durumChanged();
    void strokeSayisiChanged();
    void duraklatildiChanged();
    void sonStrokeGecerliChanged();
    void sonStrokeChanged();
    void konumSinirlariChanged();
    // Alanlar: tarih, sure, pMaks, p0l, p0r, basinc, debi, hiz, konum,
    // gecerli, gecersizNedeni, hamVeri {t[], x[], p[], tBaslangic, tBitis}
    void strokeTamamlandi(const QVariantMap &stroke);

private:
    // Sensörden gelen tek bir ölçüm anı
    struct Ornek {
        double zamanS;        // cihaz zamanı [s]
        double yukseklikMm;   // borunun yüksekliği [mm], yukarı = büyük (h = yon * konum)
        double basincMbar;    // piston üzerindeki toplam basınç [mbar]
    };

    void strokuBaslat(double zamanS);
    void strokuBitir();
    // İnişin bittiği an: boru durdu ya da alt referansa vardı.
    // durmaBaslangicIndeksi: boru durduysa durmanın başladığı örneğin indeksi,
    // durmadıysa -1. inisiKapat'a bitiş örneği olarak bu indeks verilir.
    int durmaBaslangicIndeksi(double zamanS) const;
    void inisiKapat(double zamanS, int bitisIndeksi = -1);
    void durumAyarla(const QString &yeniDurum);
    // Konum yönü kalibrasyondan çıkarılır: üst > alt ise konum "yükseklik",
    // üst < alt ise orijinal SLIPER'daki gibi "sensörden uzaklık"tır (üstte ~100,
    // altta ~540 mm). İçeride hep yükseklik (h = yon * konum) kullanılır.
    double yon() const { return m_ustKonumMm >= m_altKonumMm ? 1.0 : -1.0; }
    double ustEsik() const;
    double altEsik() const;

    QString m_durum = "BEKLENIYOR";
    int m_strokeSayisi = 0;
    bool m_duraklatildi = false;
    bool m_sonStrokeGecerli = true;
    QVariantMap m_sonStroke;
    // Kalibre edilmemişken varsayılan: konum = sensörden uzaklık (Liya cihazında
    // sensör tepede sabit, reflektör çubuk borunun dibinde; orijinal SLIPER gibi).
    double m_ustKonumMm = 100.0;
    double m_altKonumMm = 540.0;

    QVector<Ornek> m_ustteBekleyenOrnekler;   // boru üstteyken son UST_TAMPON_S saniyelik örnekler
    QVector<Ornek> m_durgunOrnekler;          // stroke öncesi, boru hareketsizken (P0l bunlardan)
    QVector<Ornek> m_strokeOrnekleri;         // iniş + bitiş sonrası örnekler
    int m_altaVarisIndeksi = -1;              // m_strokeOrnekleri içinde inişin bittiği örnek
    double m_inisBaslangicYuksekligiMm = 0.0; // inişin başladığı yükseklik (inilen yol buna göre)
    double m_bitisYuksekligiMm = 0.0;         // inişin bittiği yükseklik (boru burada durdu)
    double m_baslangicZamaniS = 0.0;
    double m_bitisZamaniS = 0.0;
    QDateTime m_bitisTarihi;
    bool m_bitisSonrasiToplaniyor = false;
    // Süreler ve eşikler (ONCESI_PENCERE_S, HAREKET_PAYI_S, ...): SliperModel.h bölüm 4
};

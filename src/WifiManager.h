#pragma once
#include <QObject>
#include <QTcpSocket>
#include <QElapsedTimer>
#include <QTimer>
#include <QVector>
#include "SensorManager.h"
#include "Database.h"

class WifiManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool baglandi READ baglandi NOTIFY baglandiChanged)
    Q_PROPERTY(bool baglaniyor READ baglaniyor NOTIFY baglaniyorChanged)
    Q_PROPERTY(QString durumMesaji READ durumMesaji NOTIFY durumMesajiChanged)

public:
    explicit WifiManager(SensorManager *sensorManager, Database *database, QObject *parent = nullptr);

    bool baglandi() const;
    bool baglaniyor() const;
    QString durumMesaji() const;

    Q_INVOKABLE void baglan();
    Q_INVOKABLE void baglantiyiKes();
    Q_INVOKABLE void kalibrasyonYenidenYukle();

signals:
    void baglandiChanged();
    void baglaniyorChanged();
    void durumMesajiChanged();
    // Orijinal SLIPER'daki "2 saat hareketsizlikten sonra otomatik kapanma"
    // davranışının yazılımsal karşılığı: gerçek donanımsal güç kesme yerine,
    // uzun süre veri akışı olmayınca bağlantı otomatik kesilip kullanıcı
    // bilgilendirilir.
    void hareketsizlikNedeniyleBaglantiKesildi();

private slots:
    void soketBaglandi();
    void soketAyrildi();
    void soketHata(QAbstractSocket::SocketError hata);
    void veriHazir();
    void hareketsizlikKontrolEt();

private:
    void durumGuncelle(const QString &mesaj);
    void jsonSatiriIsle(const QByteArray &satir);
    void egimHesapla(double accelX, double accelY, double accelZ, double &egimX, double &egimY) const;
    void kalibrasyonYukle();
    double loadCellInterpolasyon(double hamDeger) const;
    double mesafeInterpolasyon(double hamDeger) const;

    QTcpSocket *m_soket = nullptr;
    SensorManager *m_sensorManager = nullptr;
    Database *m_database = nullptr;
    QByteArray m_tamponVeri;

    bool m_baglandi = false;
    bool m_baglaniyor = false;
    QString m_durumMesaji = "Bağlı Değil";

    bool m_ilkPaket = true;
    double m_oncekiKonum = 0.0;
    qint64 m_oncekiZamanMs = 0;
    QElapsedTimer m_zamanlayici;
    QElapsedTimer m_hareketsizlikZamanlayici;

    // --- Kayitli kalibrasyon degerleri (Database'den yuklenir) ---
    
    QVector<double> m_loadCellHamDegerleri;
    QVector<double> m_loadCellKiloDegerleri;

    QVector<double> m_mesafeHamDegerleri;
    QVector<double> m_mesafeMmDegerleri;

    double m_egimBiasX = 0.0, m_egimBiasY = 0.0, m_egimBiasZ = 0.0;
    double m_egimGainX = 1.0, m_egimGainY = 1.0, m_egimGainZ = 1.0;

    static constexpr const char *ESP32_IP = "192.168.4.1";
    static constexpr quint16 ESP32_PORT = 8888;

    static constexpr double BORU_CAPI_M = 0.126;

    // --- Batarya izleme ---
    // NOT: ESP32 firmware'inde henuz gercek bir voltaj bolucu devre
    // kalibrasyonu yapilmadi (bkz. sliper_esp32.ino icindeki TODO notu).
    // Asagidaki katsayi, ADS1115'in GAIN_ONE modunda ( +-4.096V, 16 bit )
    // okudugu ham degeri, varsayimsal 1:2 oranli bir bolucu ile pil
    // voltajina cevirir. Gercek donanim baglaninca BATARYA_BOLUCU_ORANI
    // olcum yapilarak duzeltilmelidir.
    static constexpr double ADS1115_LSB_VOLT = 0.000125; // 4.096V / 32768
    static constexpr double BATARYA_BOLUCU_ORANI = 2.0;
    static constexpr double BATARYA_UYARI_VOLTAJ = 14.0;
    static constexpr double BATARYA_IYI_VOLTAJ = 14.5;

    QTimer m_hareketsizlikTimer;
    static constexpr int HAREKETSIZLIK_LIMIT_MS = 2 * 60 * 60 * 1000; // 2 saat
};
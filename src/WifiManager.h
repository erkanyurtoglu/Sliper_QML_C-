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
    void veriAkisiniKontrolEt();

private:
    void durumGuncelle(const QString &mesaj);
    void jsonSatiriIsle(const QByteArray &satir);
    void kalibrasyonYukle();

    QTcpSocket *m_soket = nullptr;
    SensorManager *m_sensorManager = nullptr;
    Database *m_database = nullptr;
    QByteArray m_tamponVeri;

    bool m_baglandi = false;
    bool m_baglaniyor = false;
    QString m_durumMesaji = "Bağlı Değil";

    bool m_ilkPaket = true;
    double m_oncekiKonum = 0.0;
    double m_oncekiZamanMs = 0.0;
    double m_filtreliHiz = 0.0;
    double m_filtreliKonum = 0.0;
    double m_zamanOfsetiMs = 0.0;
    bool m_zamanBasladi = false;
    double m_konumYonu = -1.0;  // +1: konum = yükseklik, -1: konum = sensörden uzaklık
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

    // --- Batarya izleme ---
    // Pil voltajı ve bölücü dirençleri doğrulanana kadar gösterge kapalı: bağlı
    // olmayan/yanlış bölücülü ADS1115 girişi anlamsız değer verir. Doğrulandıktan
    // sonra SliperModel::BATARYA_BOLUCU_ORANI ayarlanıp bu değer true yapılmalı.
    static constexpr bool BATARYA_OLCUMU_AKTIF = false;

    QTimer m_hareketsizlikTimer;
    // Orijinal SLIPER: "Data transfer interrupted - Move closer to the SLIPER".
    // Soket açık kalsa bile VERI_KESINTI_MS boyunca paket gelmezse veri geçersiz sayılır.
    QTimer m_veriBekciTimer;
    QElapsedTimer m_sonVeriZamani;
    static constexpr int VERI_KESINTI_MS = 1500;
    // ESP32 aniden kapanir/resetlenir veya Wi-Fi sinyali koparsa, TCP soketi
    // bunu her zaman hemen fark etmez (FIN/RST gelmeyebilir) ve arayuz
    // "Bagli" gostermeye devam eder. Bu sure boyunca hic paket gelmezse
    // baglanti gercekten sonlandirilir; kullanici "Bagli" yaziyorken aslinda
    // veri akmiyor olma durumuna dusmesin.
    static constexpr int VERI_KESINTI_BAGLANTI_KES_MS = 5000;
    static constexpr int HAREKETSIZLIK_LIMIT_MS = 2 * 60 * 60 * 1000; // 2 saat
};
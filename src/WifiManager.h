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
    Q_PROPERTY(double daraBasinciMbar READ daraBasinciMbar NOTIFY daraBasinciMbarChanged)
    Q_PROPERTY(double daraUstSiniriMbar READ daraUstSiniriMbar CONSTANT)

public:
    explicit WifiManager(SensorManager *sensorManager, Database *database, QObject *parent = nullptr);

    bool baglandi() const;
    bool baglaniyor() const;
    QString durumMesaji() const;
    double daraBasinciMbar() const;
    double daraUstSiniriMbar() const;

    Q_INVOKABLE void baglan();
    Q_INVOKABLE void baglantiyiKes();
    Q_INVOKABLE void kalibrasyonYenidenYukle();

    Q_INVOKABLE bool daraAl();
    Q_INVOKABLE void daraSifirla();

signals:
    void baglandiChanged();
    void baglaniyorChanged();
    void durumMesajiChanged();
    void daraBasinciMbarChanged();
    void hareketsizlikNedeniyleBaglantiKesildi();

private slots:
    void soketBaglandi();
    void soketAyrildi();
    void soketHata(QAbstractSocket::SocketError hata);
    void veriHazir();
    void hareketsizlikKontrolEt();
    void veriAkisiniKontrolEt();
    void baglantiZamanAsimiOldu();

private:
    void durumGuncelle(const QString &mesaj);
    void jsonSatiriIsle(const QByteArray &satir);
    void kalibrasyonYukle();
    void yenidenBaglanmayiPlanla();

    QTcpSocket *m_soket = nullptr;
    SensorManager *m_sensorManager = nullptr;
    Database *m_database = nullptr;
    QByteArray m_tamponVeri;

    bool m_baglandi = false;
    bool m_baglaniyor = false;
    QString m_durumMesaji = "Bağlı Değil";

    bool m_kullaniciKesti = false;

    bool m_ilkPaket = true;
    double m_oncekiZamanMs = 0.0;
    QVector<double> m_canliHizZamanlariS;
    QVector<double> m_canliHizKonumlariMm;
    double m_filtreliKonum = 0.0;
    double m_filtreliHamAgirlik = 0.0;
    double m_oncekiGelenHamAgirlik = 0.0;
    bool m_agirlikFiltresiBasladi = false;

    double m_darasizBasincMbar = 0.0;
    double m_daraBasinciMbar = 0.0;
    double m_zamanOfsetiMs = 0.0;
    bool m_zamanBasladi = false;
    double m_konumYonu = -1.0;
    QElapsedTimer m_zamanlayici;
    QElapsedTimer m_hareketsizlikZamanlayici;

    QVector<double> m_loadCellHamDegerleri;
    QVector<double> m_loadCellKiloDegerleri;

    QVector<double> m_mesafeHamDegerleri;
    QVector<double> m_mesafeMmDegerleri;

    double m_egimBiasX = 0.0, m_egimBiasY = 0.0, m_egimBiasZ = 0.0;
    double m_egimGainX = 1.0, m_egimGainY = 1.0, m_egimGainZ = 1.0;

    static constexpr const char *ESP32_IP = "192.168.4.1";
    static constexpr quint16 ESP32_PORT = 8888;

    static constexpr bool BATARYA_OLCUMU_AKTIF = false;

    QTimer m_hareketsizlikTimer;
    QTimer m_veriBekciTimer;
    QElapsedTimer m_sonVeriZamani;
    QElapsedTimer m_sonBekciTikZamani;
    QTimer m_yenidenBaglanmaTimer;
    QTimer m_baglantiZamanAsimiTimer;
    static constexpr int VERI_KESINTI_MS = 1500;
    static constexpr int VERI_KESINTI_BAGLANTI_KES_MS = 5000;
    static constexpr int HAREKETSIZLIK_LIMIT_MS = 2 * 60 * 60 * 1000;
    static constexpr int BEKCI_GECIKME_TOLERANSI_MS = 2000;
    static constexpr int YENIDEN_BAGLANMA_ARALIGI_MS = 2000;
    static constexpr int BAGLANTI_ZAMAN_ASIMI_MS = 8000;
};
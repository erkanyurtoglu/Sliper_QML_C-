#pragma once
#include <QObject>
#include <QString>
#include <QElapsedTimer>

class QAudioSource;
class QIODevice;
struct VoskModel;
struct VoskRecognizer;

// VoiceCommandManager'in ayri bir QThread icinde calistirdigi gercek isci.
// Mikrofon yakalama ve Vosk ile konusma tanima burada, arayuz thread'ini
// bloklamadan yapilir.
class VoiceRecognitionWorker : public QObject
{
    Q_OBJECT

public:
    enum KomutTuru {
        KomutBaslat = 0,
        KomutDurdur = 1,
        KomutBitir = 2,
        KomutDevam = 3
    };
    Q_ENUM(KomutTuru)

    explicit VoiceRecognitionWorker(const QString &modelYolu, QObject *parent = nullptr);
    ~VoiceRecognitionWorker() override;

public slots:
    void modeliYukle();
    void dinlemeyeBasla();
    void dinlemeyiDurdur();

signals:
    void modelHazir(bool basarili);
    void dinliyorDegisti(bool dinliyor);
    void hataOlustu(const QString &mesaj);
    void komutAlgilandi(int komutTuru, const QString &metin);
    void anlikMetinDegisti(const QString &metin);

private slots:
    void sesVerisiHazir();

private:
    void sonucuIsle(const QString &json);
    void metniDegerlendir(const QString &metin);

    QString m_modelYolu;
    VoskModel *m_model = nullptr;
    VoskRecognizer *m_recognizer = nullptr;
    QAudioSource *m_audioSource = nullptr;
    QIODevice *m_audioDevice = nullptr;

    QElapsedTimer m_sonKomutZamani;
    static constexpr qint64 KOMUT_BEKLEME_MS = 1200;
};

#pragma once
#include <QObject>
#include <QString>
#include <QThread>

class VoiceRecognitionWorker;

// "Başlat", "Durdur", "Bitir" gibi sesli komutları dinlemek için kullanılır.
// Laboratuvar ortamında eller kirli/meşgulken dokunmadan ölçüm kontrolü
// yapılabilmesi amacıyla eklendi.
//
// Tanıma tamamen cihaz üzerinde (offline) Vosk kütüphanesi ile yapılır,
// internet bağlantısı gerekmez. Yanlışlıkla tetiklenmeyi önlemek için
// tanıyıcı sadece bu komut kelimelerini içeren kısıtlı bir sözlükle
// (grammar) çalışır; çevredeki gündelik konuşma bu dar kelime setine
// düşmediği için genelde göz ardı edilir (bkz. VoiceRecognitionWorker).
class VoiceCommandManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool etkin READ etkin WRITE setEtkin NOTIFY etkinChanged)
    Q_PROPERTY(bool dinliyor READ dinliyor NOTIFY dinliyorChanged)
    Q_PROPERTY(bool modelHazir READ modelHazir NOTIFY modelHazirChanged)
    Q_PROPERTY(QString sonKomutMetni READ sonKomutMetni NOTIFY sonKomutMetniChanged)
    Q_PROPERTY(QString anlikMetin READ anlikMetin NOTIFY anlikMetinChanged)
    Q_PROPERTY(QString sonHata READ sonHata NOTIFY sonHataChanged)

public:
    explicit VoiceCommandManager(QObject *parent = nullptr);
    ~VoiceCommandManager() override;

    bool etkin() const;
    void setEtkin(bool etkin);
    bool dinliyor() const;
    bool modelHazir() const;
    QString sonKomutMetni() const;
    QString anlikMetin() const;
    QString sonHata() const;

signals:
    void etkinChanged();
    void dinliyorChanged();
    void modelHazirChanged();
    void sonKomutMetniChanged();
    void anlikMetinChanged();
    void sonHataChanged();

    // Sayfalar bu sinyallere baglanip ilgili aksiyonu tetikler.
    void baslatKomutu();
    void durdurKomutu();
    void bitirKomutu();
    void devamKomutu();

private slots:
    void workerModelHazir(bool hazir);
    void workerDinliyorDegisti(bool dinliyor);
    void workerHataOlustu(const QString &mesaj);
    void workerKomutAlgilandi(int komutTuru, const QString &metin);
    void workerAnlikMetinDegisti(const QString &metin);

private:
    QThread m_workerThread;
    VoiceRecognitionWorker *m_worker = nullptr;

    bool m_etkin = false;
    bool m_dinliyor = false;
    bool m_modelHazir = false;
    QString m_sonKomutMetni;
    QString m_anlikMetin;
    QString m_sonHata;
};

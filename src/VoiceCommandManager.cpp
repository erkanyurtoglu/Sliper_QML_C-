#include "VoiceCommandManager.h"
#include "VoiceRecognitionWorker.h"

#include <QCoreApplication>
#include <QDir>
#include <QMetaObject>

VoiceCommandManager::VoiceCommandManager(QObject *parent)
    : QObject(parent)
{
    const QString modelYolu = QDir(QCoreApplication::applicationDirPath()).filePath("vosk-model-small-tr-0.3");

    m_worker = new VoiceRecognitionWorker(modelYolu);
    m_worker->moveToThread(&m_workerThread);

    connect(&m_workerThread, &QThread::finished, m_worker, &QObject::deleteLater);

    connect(m_worker, &VoiceRecognitionWorker::modelHazir, this, &VoiceCommandManager::workerModelHazir);
    connect(m_worker, &VoiceRecognitionWorker::dinliyorDegisti, this, &VoiceCommandManager::workerDinliyorDegisti);
    connect(m_worker, &VoiceRecognitionWorker::hataOlustu, this, &VoiceCommandManager::workerHataOlustu);
    connect(m_worker, &VoiceRecognitionWorker::komutAlgilandi, this, &VoiceCommandManager::workerKomutAlgilandi);
    connect(m_worker, &VoiceRecognitionWorker::anlikMetinDegisti, this, &VoiceCommandManager::workerAnlikMetinDegisti);

    m_workerThread.start();
    QMetaObject::invokeMethod(m_worker, "modeliYukle", Qt::QueuedConnection);
}

VoiceCommandManager::~VoiceCommandManager()
{
    m_workerThread.quit();
    m_workerThread.wait(3000);
}

bool VoiceCommandManager::etkin() const { return m_etkin; }

void VoiceCommandManager::setEtkin(bool etkin)
{
    if (m_etkin == etkin)
        return;
    m_etkin = etkin;
    emit etkinChanged();

    if (m_etkin)
        QMetaObject::invokeMethod(m_worker, "dinlemeyeBasla", Qt::QueuedConnection);
    else
        QMetaObject::invokeMethod(m_worker, "dinlemeyiDurdur", Qt::QueuedConnection);
}

bool VoiceCommandManager::dinliyor() const { return m_dinliyor; }
bool VoiceCommandManager::modelHazir() const { return m_modelHazir; }
QString VoiceCommandManager::sonKomutMetni() const { return m_sonKomutMetni; }
QString VoiceCommandManager::anlikMetin() const { return m_anlikMetin; }
QString VoiceCommandManager::sonHata() const { return m_sonHata; }

void VoiceCommandManager::workerModelHazir(bool hazir)
{
    m_modelHazir = hazir;
    emit modelHazirChanged();

    if (hazir && m_etkin)
        QMetaObject::invokeMethod(m_worker, "dinlemeyeBasla", Qt::QueuedConnection);
}

void VoiceCommandManager::workerDinliyorDegisti(bool dinliyor)
{
    m_dinliyor = dinliyor;
    emit dinliyorChanged();
}

void VoiceCommandManager::workerHataOlustu(const QString &mesaj)
{
    m_sonHata = mesaj;
    emit sonHataChanged();
}

void VoiceCommandManager::workerKomutAlgilandi(int komutTuru, const QString &metin)
{
    m_sonKomutMetni = metin;
    emit sonKomutMetniChanged();

    switch (static_cast<VoiceRecognitionWorker::KomutTuru>(komutTuru)) {
    case VoiceRecognitionWorker::KomutBaslat: emit baslatKomutu(); break;
    case VoiceRecognitionWorker::KomutDurdur: emit durdurKomutu(); break;
    case VoiceRecognitionWorker::KomutBitir:  emit bitirKomutu();  break;
    case VoiceRecognitionWorker::KomutDevam:  emit devamKomutu();  break;
    case VoiceRecognitionWorker::KomutEkle:   emit ekleKomutu();   break;
    }
}

void VoiceCommandManager::workerAnlikMetinDegisti(const QString &metin)
{
    m_anlikMetin = metin;
    emit anlikMetinChanged();
}

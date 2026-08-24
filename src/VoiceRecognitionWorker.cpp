#include "VoiceRecognitionWorker.h"
#include "vosk_api.h"

#include <QAudioSource>
#include <QAudioFormat>
#include <QMediaDevices>
#include <QAudioDevice>
#include <QIODevice>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QLocale>
#include <QVector>
#include <algorithm>
#include <cstdlib>

namespace {

// Vosk'un tanıyabileceği komut kelimeleri. Tanıyıcı, dinlemeye başlarken
// bu listeyle "grammar" (kısıtlı sözlük) moduna alınır: motor SADECE bu
// kelimeleri ya da "[unk]" (bilinmeyen) çıktısını üretebilir. Bu sayede
// etraftaki gündelik konuşma bu dar kelime setine düşmediği icin genelde
// [unk] olarak elenir, ama gercek komut soylenince net yakalanir - ayrica
// arama uzayi kuculdugu icin tanima cok daha hizli/dogru calisir.
const QStringList &grammarKelimeleri()
{
    static const QStringList kelimeler = {
        "başlat", "başla",
        "durdur",
        "bitir", "bitti", "bitirdi", "bitiriyor", "bitirelim", "tamamla",
        "devam"
    };
    return kelimeler;
}

QByteArray grammarJsonUret()
{
    QJsonArray dizi;
    for (const QString &kelime : grammarKelimeleri())
        dizi.append(kelime);
    dizi.append(QStringLiteral("[unk]"));
    return QJsonDocument(dizi).toJson(QJsonDocument::Compact);
}

// Turkce karakterleri ASCII'ye indirger, kucuk harfe cevirir; boylece
// Vosk ciktisi ile aday kelime listeleri arasinda esnek karsilastirma
// yapilabilir (aksan/karakter farkindan etkilenmez).
QString sadelestir(const QString &metin)
{
    QString kucuk = QLocale(QLocale::Turkish).toLower(metin);
    QString sonuc;
    sonuc.reserve(kucuk.size());
    for (const QChar &ch : kucuk) {
        switch (ch.unicode()) {
        case u'ş': sonuc += 's'; break;
        case u'ç': sonuc += 'c'; break;
        case u'ğ': sonuc += 'g'; break;
        case u'ü': sonuc += 'u'; break;
        case u'ö': sonuc += 'o'; break;
        case u'ı': sonuc += 'i'; break;
        case u'İ': sonuc += 'i'; break;
        default:
            if (ch.isLetterOrNumber() || ch.isSpace())
                sonuc += ch;
            break;
        }
    }
    return sonuc;
}

int levenshtein(const QString &a, const QString &b)
{
    const int n = a.size();
    const int m = b.size();
    QVector<int> onceki(m + 1), simdiki(m + 1);
    for (int j = 0; j <= m; ++j) onceki[j] = j;

    for (int i = 1; i <= n; ++i) {
        simdiki[0] = i;
        for (int j = 1; j <= m; ++j) {
            int maliyet = (a[i - 1] == b[j - 1]) ? 0 : 1;
            simdiki[j] = std::min({ onceki[j] + 1, simdiki[j - 1] + 1, onceki[j - 1] + maliyet });
        }
        onceki.swap(simdiki);
    }
    return onceki[m];
}

bool kelimeUyuyorMu(const QString &token, const QStringList &adaylar, int tolerans)
{
    if (adaylar.contains(token))
        return true;
    for (const QString &aday : adaylar) {
        if (std::abs(token.size() - aday.size()) <= tolerans && levenshtein(token, aday) <= tolerans)
            return true;
    }
    return false;
}

} // namespace

VoiceRecognitionWorker::VoiceRecognitionWorker(const QString &modelYolu, QObject *parent)
    : QObject(parent)
    , m_modelYolu(modelYolu)
{
    m_sonKomutZamani.start();
}

VoiceRecognitionWorker::~VoiceRecognitionWorker()
{
    dinlemeyiDurdur();
    if (m_recognizer) vosk_recognizer_free(m_recognizer);
    if (m_model) vosk_model_free(m_model);
}

void VoiceRecognitionWorker::modeliYukle()
{
    vosk_set_log_level(-1);
    m_model = vosk_model_new(m_modelYolu.toUtf8().constData());
    if (!m_model) {
        emit hataOlustu(QStringLiteral("Ses tanima modeli yuklenemedi: ") + m_modelYolu);
        emit modelHazir(false);
        return;
    }
    emit modelHazir(true);
}

void VoiceRecognitionWorker::dinlemeyeBasla()
{
    if (!m_model) {
        emit hataOlustu(QStringLiteral("Ses tanima modeli hazir degil."));
        return;
    }
    if (m_audioSource)
        return; // zaten dinliyor

    QAudioFormat format;
    format.setSampleRate(16000);
    format.setChannelCount(1);
    format.setSampleFormat(QAudioFormat::Int16);

    const QAudioDevice girisAygiti = QMediaDevices::defaultAudioInput();
    if (girisAygiti.isNull()) {
        emit hataOlustu(QStringLiteral("Mikrofon bulunamadi."));
        return;
    }

    if (!m_recognizer) {
        const QByteArray grammar = grammarJsonUret();
        m_recognizer = vosk_recognizer_new_grm(m_model, 16000.0f, grammar.constData());
        if (!m_recognizer) {
            emit hataOlustu(QStringLiteral("Ses tanima motoru baslatilamadi."));
            return;
        }
        vosk_recognizer_set_words(m_recognizer, 0);
    } else {
        vosk_recognizer_reset(m_recognizer);
    }

    m_audioSource = new QAudioSource(girisAygiti, format, this);
    m_audioDevice = m_audioSource->start();
    if (!m_audioDevice) {
        emit hataOlustu(QStringLiteral("Mikrofon acilamadi."));
        delete m_audioSource;
        m_audioSource = nullptr;
        return;
    }

    connect(m_audioDevice, &QIODevice::readyRead, this, &VoiceRecognitionWorker::sesVerisiHazir);
    emit dinliyorDegisti(true);
}

void VoiceRecognitionWorker::dinlemeyiDurdur()
{
    if (!m_audioSource)
        return;

    m_audioSource->stop();
    m_audioSource->deleteLater();
    m_audioSource = nullptr;
    m_audioDevice = nullptr;

    if (m_recognizer)
        vosk_recognizer_reset(m_recognizer);

    emit dinliyorDegisti(false);
    emit anlikMetinDegisti(QString());
}

void VoiceRecognitionWorker::sesVerisiHazir()
{
    if (!m_audioDevice || !m_recognizer)
        return;

    const QByteArray veri = m_audioDevice->readAll();
    if (veri.isEmpty())
        return;

    const int bitti = vosk_recognizer_accept_waveform(m_recognizer, veri.constData(), veri.size());
    if (bitti == 1) {
        sonucuIsle(QString::fromUtf8(vosk_recognizer_result(m_recognizer)));
    } else if (bitti == 0) {
        const QString kismi = QString::fromUtf8(vosk_recognizer_partial_result(m_recognizer));
        QJsonObject obj = QJsonDocument::fromJson(kismi.toUtf8()).object();
        emit anlikMetinDegisti(obj.value(QStringLiteral("partial")).toString());
    }
}

void VoiceRecognitionWorker::sonucuIsle(const QString &json)
{
    QJsonObject obj = QJsonDocument::fromJson(json.toUtf8()).object();
    const QString metin = obj.value(QStringLiteral("text")).toString().trimmed();
    emit anlikMetinDegisti(QString());
    if (metin.isEmpty())
        return;

    metniDegerlendir(metin);
}

void VoiceRecognitionWorker::metniDegerlendir(const QString &metin)
{
    static const QStringList baslatAdaylari = { "baslat", "basla" };
    static const QStringList durdurAdaylari = { "durdur" };
    static const QStringList bitirAdaylari = { "bitir", "bitti", "bitirdi", "bitiriyor", "bitirelim", "tamamla" };
    static const QStringList devamAdaylari = { "devam" };

    const QString sade = sadelestir(metin);
    const QStringList tokenlar = sade.split(' ', Qt::SkipEmptyParts);

    for (const QString &token : tokenlar) {
        if (token == "unk")
            continue; // grammar disina cikan / eslesmeyen ses

        int komutTuru = -1;
        if (kelimeUyuyorMu(token, bitirAdaylari, 1)) komutTuru = VoiceRecognitionWorker::KomutBitir;
        else if (kelimeUyuyorMu(token, durdurAdaylari, 1)) komutTuru = VoiceRecognitionWorker::KomutDurdur;
        else if (kelimeUyuyorMu(token, devamAdaylari, 1)) komutTuru = VoiceRecognitionWorker::KomutDevam;
        else if (kelimeUyuyorMu(token, baslatAdaylari, 1)) komutTuru = VoiceRecognitionWorker::KomutBaslat;

        if (komutTuru >= 0) {
            if (m_sonKomutZamani.elapsed() < KOMUT_BEKLEME_MS)
                return; // cok yakin zamanda baska komut tetiklendi, tekrari engelle
            m_sonKomutZamani.restart();
            emit komutAlgilandi(komutTuru, metin);
            return;
        }
    }
}

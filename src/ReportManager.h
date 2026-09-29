#pragma once
#include <QObject>
#include <QVariantMap>
#include <QImage>
#include <QPointF>
#include <QColor>
#include <QMap>

class Database;

// Orijinal SLIPER PDF raporu (kılavuz bölüm 5.5): stroke ve tahmin grafikleri,
// temel veriler, stroke özeti, tahmin tablosu ve cihaz parametreleri.
// Tüm veriler ölçüm kimliğiyle veritabanından okunur; tahmin, ölçüme kayıtlı
// tahmin ayarlarıyla (Forecast Preferences) hesaplanır.
class ReportManager : public QObject
{
    Q_OBJECT

public:
    explicit ReportManager(Database *database, QObject *parent = nullptr);

    Q_INVOKABLE QString pdfOnizlemeHtml(int olcumId);
    Q_INVOKABLE QString pdfOlustur(int olcumId);

    struct Seri {
        QVector<QPointF> noktalar;
        QColor renk;
        bool noktaMi = false;           // true: saçılım, false: çizgi
        Qt::PenStyle stil = Qt::SolidLine;
        QString ad;
        QVector<QPair<QPointF, QPointF>> hataCubuklari;
    };

private:
    QString raporHtmlOlustur(int olcumId, QMap<QString, QImage> &gorseller);
    static QImage grafikCiz(const QString &baslik, const QString &xEtiket, const QString &yEtiket,
                            const QVector<Seri> &seriler);

    Database *m_database = nullptr;
};

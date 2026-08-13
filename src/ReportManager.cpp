#include "ReportManager.h"
#include <QPrinter>
#include <QPainter>
#include <QTextDocument>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QDebug>

ReportManager::ReportManager(QObject *parent)
    : QObject(parent)
{
}

bool ReportManager::pdfOlustur(int olcumId, const QString &musteri, const QString &recete,
                                 double tau0, double mu, double r2)
{
    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    QDir().mkpath(klasor);

    QString dosyaAdi = klasor + QString("/SLIPER_Rapor_%1_%2.pdf")
        .arg(olcumId)
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    QTextDocument belge;
    QString html = QString(
        "<h1 style='color:#3b82f6;'>SLIPER Analiz Raporu</h1>"
        "<p><b>Olcum ID:</b> %1</p>"
        "<p><b>Musteri:</b> %2</p>"
        "<p><b>Recete:</b> %3</p>"
        "<p><b>Tarih:</b> %4</p>"
        "<hr>"
        "<h2>Bingham Model Sonuclari</h2>"
        "<p><b>Akma Gerilmesi (tau0):</b> %5 mbar</p>"
        "<p><b>Plastik Viskozite (mu):</b> %6 mbar*h/m3</p>"
        "<p><b>Uyum Kalitesi (R2):</b> %7</p>"
        "<hr>"
        "<p style='color:#6b7280; font-size:10px;'>Liya Laboratuvar Test Cihazlari - SLIPER Analiz Sistemi</p>"
    ).arg(olcumId)
     .arg(musteri)
     .arg(recete)
     .arg(QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"))
     .arg(QString::number(tau0, 'f', 2))
     .arg(QString::number(mu, 'f', 2))
     .arg(QString::number(r2, 'f', 2));

    belge.setHtml(html);

    QPrinter yazici(QPrinter::HighResolution);
    yazici.setOutputFormat(QPrinter::PdfFormat);
    yazici.setOutputFileName(dosyaAdi);

    belge.print(&yazici);

    qDebug() << "PDF rapor olusturuldu:" << dosyaAdi;
    return true;
}
#include "ReportManager.h"
#include <QPrinter>
#include <QPainter>
#include <QTextDocument>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QFile>
#include <QDebug>

ReportManager::ReportManager(QObject *parent)
    : QObject(parent)
{
}

// Önizleme ve gerçek PDF çıktısı bu tek fonksiyondan beslenir; ikisi arasında
// tasarım/veri tutarsızlığı oluşmasın diye HTML üretimi burada merkezileştirildi.
QString ReportManager::raporHtmlOlustur(int olcumId, const QString &musteri, const QString &recete,
                                          double tau0, double mu, double r2)
{
    const bool pompalanabilir = tau0 < 5 && mu < 10;
    const QString durumRengi = pompalanabilir ? "#16a34a" : "#dc2626";
    const QString durumMetni = pompalanabilir ? "POMPALANABİLİR" : "POMPALAMA SORUNU";

    return QString(
        "<html><body style='font-family:Segoe UI, Arial, sans-serif; color:#111827;'>"
        "<h1 style='color:#3b82f6; margin-bottom:4px;'>SLIPER Analiz Raporu</h1>"
        "<p style='color:#6b7280; font-size:11px; margin-top:0;'>Liya Laboratuvar Test Cihazları</p>"
        "<hr style='border:none; border-top:1px solid #d1d5db;'>"
        "<table style='width:100%; border-collapse:collapse; margin-top:10px;'>"
        "<tr><td style='padding:4px 0; width:140px;'><b>Ölçüm ID</b></td><td>%1</td></tr>"
        "<tr><td style='padding:4px 0;'><b>Müşteri</b></td><td>%2</td></tr>"
        "<tr><td style='padding:4px 0;'><b>Reçete</b></td><td>%3</td></tr>"
        "<tr><td style='padding:4px 0;'><b>Tarih</b></td><td>%4</td></tr>"
        "</table>"
        "<h2 style='color:#111827; margin-top:24px; margin-bottom:8px; font-size:16px;'>Bingham Model Sonuçları</h2>"
        "<table style='width:100%; border-collapse:collapse;' cellpadding='6'>"
        "<tr style='background:#f3f4f6;'>"
        "<th style='text-align:left; border:1px solid #d1d5db;'>Parametre</th>"
        "<th style='text-align:left; border:1px solid #d1d5db;'>Değer</th></tr>"
        "<tr><td style='border:1px solid #d1d5db;'>Akma Gerilmesi (τ₀)</td><td style='border:1px solid #d1d5db;'>%5 mbar</td></tr>"
        "<tr><td style='border:1px solid #d1d5db;'>Plastik Viskozite (μ)</td><td style='border:1px solid #d1d5db;'>%6 mbar·h/m³</td></tr>"
        "<tr><td style='border:1px solid #d1d5db;'>Uyum Kalitesi (R²)</td><td style='border:1px solid #d1d5db;'>%7</td></tr>"
        "</table>"
        "<p style='margin-top:20px;'><b>Durum:</b> "
        "<span style='color:%8; font-weight:bold;'>%9</span></p>"
        "<hr style='border:none; border-top:1px solid #d1d5db; margin-top:24px;'>"
        "<p style='color:#6b7280; font-size:10px;'>Liya Laboratuvar Test Cihazları - SLIPER Analiz Sistemi</p>"
        "</body></html>"
    ).arg(olcumId)
     .arg(musteri.toHtmlEscaped())
     .arg(recete.toHtmlEscaped())
     .arg(QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"))
     .arg(QString::number(tau0, 'f', 2))
     .arg(QString::number(mu, 'f', 2))
     .arg(QString::number(r2, 'f', 2))
     .arg(durumRengi)
     .arg(durumMetni);
}

QString ReportManager::pdfOnizlemeHtml(int olcumId, const QString &musteri, const QString &recete,
                                         double tau0, double mu, double r2)
{
    return raporHtmlOlustur(olcumId, musteri, recete, tau0, mu, r2);
}

QString ReportManager::pdfOlustur(int olcumId, const QString &musteri, const QString &recete,
                                    double tau0, double mu, double r2)
{
    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    if (!QDir().mkpath(klasor)) {
        qWarning() << "Rapor klasoru olusturulamadi:" << klasor;
        return QString();
    }

    QString dosyaAdi = klasor + QString("/SLIPER_Rapor_%1_%2.pdf")
        .arg(olcumId)
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    QTextDocument belge;
    belge.setHtml(raporHtmlOlustur(olcumId, musteri, recete, tau0, mu, r2));

    QPrinter yazici(QPrinter::HighResolution);
    yazici.setOutputFormat(QPrinter::PdfFormat);
    yazici.setOutputFileName(dosyaAdi);

    belge.print(&yazici);

    if (!QFile::exists(dosyaAdi)) {
        qWarning() << "PDF dosyasi yazilamadi:" << dosyaAdi;
        return QString();
    }

    qDebug() << "PDF rapor olusturuldu:" << dosyaAdi;
    return dosyaAdi;
}

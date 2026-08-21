#pragma once
#include <QObject>

class ReportManager : public QObject
{
    Q_OBJECT

public:
    explicit ReportManager(QObject *parent = nullptr);
    Q_INVOKABLE QString pdfOnizlemeHtml(int olcumId, const QString &musteri, const QString &recete,
                                         double tau0, double mu, double r2);
    Q_INVOKABLE QString pdfOlustur(int olcumId, const QString &musteri, const QString &recete,
                                     double tau0, double mu, double r2);

private:
    QString raporHtmlOlustur(int olcumId, const QString &musteri, const QString &recete,
                              double tau0, double mu, double r2);
};
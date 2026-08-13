#pragma once
#include <QObject>

class ReportManager : public QObject
{
    Q_OBJECT

public:
    explicit ReportManager(QObject *parent = nullptr);
    Q_INVOKABLE bool pdfOlustur(int olcumId, const QString &musteri, const QString &recete,
                                  double tau0, double mu, double r2);
};
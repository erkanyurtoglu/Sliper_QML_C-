#pragma once
#include <QObject>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString durum READ durum CONSTANT)

public:
    explicit Backend(QObject *parent = nullptr);
    QString durum() const;
    Q_INVOKABLE bool girisYap(const QString &kullaniciAdi, const QString &sifre);
};
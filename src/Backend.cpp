#include "Backend.h"
#include <QDebug>

Backend::Backend(QObject *parent)
    : QObject(parent)
{
}

QString Backend::durum() const
{
    return "Baglanti bekleniyor...";
}

bool Backend::girisYap(const QString &kullaniciAdi, const QString &sifre)
{
    if (kullaniciAdi == "admin" && sifre == "admin123") {
        qDebug() << "Giris Basarili:" << kullaniciAdi;
        return true;
    }

    qDebug() << "Giris Basarisiz:" << kullaniciAdi;
    return false;
}

bool Backend::sifreDogrula(const QString &sifre)
{
    return sifre == "admin123";
}
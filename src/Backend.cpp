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
    if(kullaniciAdi == "admin" && sifre == "admin123")
    {
        qDebug() << "Giriş Başarılı:" << kullaniciAdi;
        return true;
    }

    qDebug() << "Giriş Başarısız:" << kullaniciAdi;
    return false;

}
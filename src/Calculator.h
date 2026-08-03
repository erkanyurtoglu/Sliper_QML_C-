#pragma once
#include <QObject>

class Calculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString durum READ durum NOTIFY durumChanged)
    Q_PROPERTY(int strokeSayisi READ strokeSayisi NOTIFY strokeSayisiChanged)

public:
    explicit Calculator(QObject *parent = nullptr);
    QString durum() const;
    int strokeSayisi() const;
    Q_INVOKABLE void konumGuncelle(double konum);

signals:
    void durumChanged();
    void strokeSayisiChanged();

private:
    QString m_durum = "BEKLENIYOR";
    int m_strokeSayisi = 0;
};
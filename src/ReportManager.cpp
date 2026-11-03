#include "ReportManager.h"
#include "Database.h"
#include "SliperModel.h"
#include <QPrinter>
#include <QPainter>
#include <QPainterPath>
#include <QTextDocument>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QFile>
#include <QUrl>
#include <QDebug>
#include <cmath>
#include <algorithm>

ReportManager::ReportManager(Database *database, QObject *parent)
    : QObject(parent)
    , m_database(database)
{
}

namespace {

QString sayi(double deger, int basamak) { return QString::number(deger, 'f', basamak); }
QString tarihVeyaCizgi(const QString &tarih) { return tarih.isEmpty() ? QStringLiteral("—") : tarih; }

double okunakliEksenAdimi(double aralik, int hedefCizgiSayisi)
{
    if (aralik <= 0.0) return 1.0;
    const double kabaAdim = aralik / hedefCizgiSayisi;
    const double onunKuvveti = std::pow(10.0, std::floor(std::log10(kabaAdim)));
    const double ilkRakam = kabaAdim / onunKuvveti;
    double yuvarlakRakam = 10.0;
    if (ilkRakam <= 1.0) yuvarlakRakam = 1.0;
    else if (ilkRakam <= 2.0) yuvarlakRakam = 2.0;
    else if (ilkRakam <= 5.0) yuvarlakRakam = 5.0;
    return yuvarlakRakam * onunKuvveti;
}

QString uyariMetni(const QString &kod)
{
    static const QMap<QString, QString> metinler {
        { "azStroke", "Tahmin için yeterli geçerli stroke yok (en az 3 önerilir; her yük için 3 stroke idealdir)." },
        { "egimNegatif", "P–Q eğimi (B) negatif: debi arttıkça basınç düşüyor. Ayrışma/blokaj veya ölçüm hatası olabilir." },
        { "kesisimNegatif", "P–Q kesişimi (A) negatif: durağan basınç (P0) hatalı ölçülmüş olabilir." },
        { "dusukR2", QString("Uyum kalitesi düşük (R² < %1): stroke noktaları doğrudan çok sapıyor.")
                         .arg(SliperModel::MIN_R2, 0, 'f', 2) },
        { "darDebiAraligi", "Debi aralığı çok dar: farklı ağırlıklarla stroke atılmalı, aksi halde eğim güvenilir değil." },
        { "yukBasinaAzStroke", "Bazı yüklerde 3'ten az geçerli stroke var; kılavuz her yük için en az 3 stroke önerir." },
        { "tekYuk", "Tüm stroke'lar aynı ek ağırlıkla atılmış: en az iki farklı yük kullanılmalı." },
        { "cokGecersiz", "Stroke'ların %30'undan fazlası geçersiz: boru sıkışması veya ayrışma belirtisi olabilir." },
        { "agirlikTepkisiZayif", "Eklenen ağırlık Pmax'ta görünmüyor: her kg Pmax'ı 7.6 mbar yükseltmeliydi. "
                                 "Ağırlık load cell'e ulaşmıyor (kızak sürtünmesi, ağırlığın boruya oturmaması "
                                 "veya load cell kalibrasyonu). Bu ölçümde eğim ölçülmüş değildir." }
    };
    return metinler.value(kod, kod);
}

}

QImage ReportManager::grafikCiz(const QString &baslik, const QString &xEtiket, const QString &yEtiket,
                                const QVector<Seri> &seriler)
{
    const int gorselGenislik = 1000, gorselYukseklik = 560;
    const QRectF cizimAlani(90, 50, gorselGenislik - 120, gorselYukseklik - 130);
    QImage gorsel(gorselGenislik, gorselYukseklik, QImage::Format_ARGB32);
    gorsel.fill(Qt::white);

    double xMin = 0, xMaks = 1, yMin = 0, yMaks = 1;
    bool ilkNokta = true;
    auto araligaKat = [&](const QPointF &nokta) {
        if (ilkNokta) { xMaks = std::max(1e-9, nokta.x()); yMaks = std::max(1e-9, nokta.y()); ilkNokta = false; }
        xMin = std::min(xMin, nokta.x()); xMaks = std::max(xMaks, nokta.x());
        yMin = std::min(yMin, nokta.y()); yMaks = std::max(yMaks, nokta.y());
    };
    for (const Seri &seri : seriler) {
        for (const QPointF &nokta : seri.noktalar) araligaKat(nokta);
        for (const auto &cubuk : seri.hataCubuklari) { araligaKat(cubuk.first); araligaKat(cubuk.second); }
    }
    const double xAdim = okunakliEksenAdimi(xMaks - xMin, 8);
    const double yAdim = okunakliEksenAdimi(yMaks - yMin, 6);
    xMin = std::floor(xMin / xAdim) * xAdim; xMaks = std::ceil(xMaks * 1.05 / xAdim) * xAdim;
    yMin = std::floor(yMin / yAdim) * yAdim; yMaks = std::ceil(yMaks * 1.08 / yAdim) * yAdim;
    if (xMaks <= xMin) xMaks = xMin + xAdim;
    if (yMaks <= yMin) yMaks = yMin + yAdim;

    auto pikseleCevir = [&](const QPointF &veriNoktasi) {
        return QPointF(cizimAlani.left() + (veriNoktasi.x() - xMin) / (xMaks - xMin) * cizimAlani.width(),
                       cizimAlani.bottom() - (veriNoktasi.y() - yMin) / (yMaks - yMin) * cizimAlani.height());
    };

    QPainter kalem(&gorsel);
    kalem.setRenderHint(QPainter::Antialiasing);
    QFont normalYazi("Segoe UI", 11);
    kalem.setFont(normalYazi);

    kalem.setPen(QPen(QColor("#e5e7eb"), 1));
    for (double x = xMin; x <= xMaks + xAdim * 0.01; x += xAdim) {
        const QPointF piksel = pikseleCevir({ x, yMin });
        kalem.drawLine(QPointF(piksel.x(), cizimAlani.top()), QPointF(piksel.x(), cizimAlani.bottom()));
    }
    for (double y = yMin; y <= yMaks + yAdim * 0.01; y += yAdim) {
        const QPointF piksel = pikseleCevir({ xMin, y });
        kalem.drawLine(QPointF(cizimAlani.left(), piksel.y()), QPointF(cizimAlani.right(), piksel.y()));
    }
    kalem.setPen(QColor("#374151"));
    for (double x = xMin; x <= xMaks + xAdim * 0.01; x += xAdim) {
        const QPointF piksel = pikseleCevir({ x, yMin });
        kalem.drawText(QRectF(piksel.x() - 40, cizimAlani.bottom() + 6, 80, 20), Qt::AlignHCenter | Qt::AlignTop,
                       QString::number(x, 'g', 6));
    }
    for (double y = yMin; y <= yMaks + yAdim * 0.01; y += yAdim) {
        const QPointF piksel = pikseleCevir({ xMin, y });
        kalem.drawText(QRectF(cizimAlani.left() - 86, piksel.y() - 10, 80, 20), Qt::AlignRight | Qt::AlignVCenter,
                       QString::number(y, 'g', 6));
    }
    kalem.setPen(QPen(QColor("#6b7280"), 1.5));
    kalem.drawRect(cizimAlani);

    kalem.drawText(QRectF(cizimAlani.left(), gorselYukseklik - 50, cizimAlani.width(), 24), Qt::AlignCenter, xEtiket);
    kalem.save();
    kalem.translate(18, cizimAlani.center().y());
    kalem.rotate(-90);
    kalem.drawText(QRectF(-cizimAlani.height() / 2, -12, cizimAlani.height(), 24), Qt::AlignCenter, yEtiket);
    kalem.restore();
    QFont baslikYazisi("Segoe UI", 14, QFont::Bold);
    kalem.setFont(baslikYazisi);
    kalem.setPen(QColor("#111827"));
    kalem.drawText(QRectF(0, 10, gorselGenislik, 30), Qt::AlignCenter, baslik);
    kalem.setFont(normalYazi);

    kalem.setClipRect(cizimAlani.adjusted(-6, -6, 6, 6));
    for (const Seri &seri : seriler) {
        if (seri.noktaMi) {
            kalem.setPen(QPen(seri.renk.darker(130), 1));
            kalem.setBrush(seri.renk);
            for (const QPointF &nokta : seri.noktalar) kalem.drawEllipse(pikseleCevir(nokta), 6, 6);
        } else if (seri.noktalar.size() >= 2) {
            kalem.setPen(QPen(seri.renk, 2.5, seri.stil));
            kalem.setBrush(Qt::NoBrush);
            QPainterPath cizgi(pikseleCevir(seri.noktalar.first()));
            for (int i = 1; i < seri.noktalar.size(); ++i) cizgi.lineTo(pikseleCevir(seri.noktalar[i]));
            kalem.drawPath(cizgi);
        }
        kalem.setPen(QPen(seri.renk, 1.8));
        for (const auto &cubuk : seri.hataCubuklari) {
            const QPointF altUc = pikseleCevir(cubuk.first), ustUc = pikseleCevir(cubuk.second);
            kalem.drawLine(altUc, ustUc);
            kalem.drawLine(QPointF(altUc.x() - 7, altUc.y()), QPointF(altUc.x() + 7, altUc.y()));
            kalem.drawLine(QPointF(ustUc.x() - 7, ustUc.y()), QPointF(ustUc.x() + 7, ustUc.y()));
        }
    }
    kalem.setClipping(false);

    double lejantX = cizimAlani.left() + 12;
    const double lejantY = cizimAlani.top() + 12;
    for (const Seri &seri : seriler) {
        if (seri.ad.isEmpty()) continue;
        kalem.setPen(QPen(seri.renk, 2.5, seri.stil));
        kalem.setBrush(seri.renk);
        if (seri.noktaMi) kalem.drawEllipse(QPointF(lejantX + 8, lejantY + 8), 5, 5);
        else kalem.drawLine(QPointF(lejantX, lejantY + 8), QPointF(lejantX + 22, lejantY + 8));
        kalem.setPen(QColor("#111827"));
        const double yaziGenisligi = kalem.fontMetrics().horizontalAdvance(seri.ad);
        kalem.drawText(QPointF(lejantX + 28, lejantY + 13), seri.ad);
        lejantX += 40 + yaziGenisligi;
    }
    return gorsel;
}

QString ReportManager::raporHtmlOlustur(int olcumId, QMap<QString, QImage> &gorseller)
{
    if (!m_database) return QString();

    const QVariantMap bilgi = m_database->olcumBilgisiGetir(olcumId);
    const QVariantList strokelar = m_database->strokeVerileriGetir(olcumId);
    const QVariantMap pqSonucu = m_database->binghamHesapla(olcumId);
    const QVariantMap ayarlar = m_database->tahminAyarlariGetir(olcumId);
    const QVariantList tahminSatirlari = m_database->tahminTablosuGetir(olcumId);
    const double kesisimA = pqSonucu.value("tau0").toDouble();
    const double egimB = pqSonucu.value("mu").toDouble();
    const bool yeterliVeri = pqSonucu.value("yeterliVeri").toBool();

    const QString hucreStili = "style='border:1px solid #d1d5db; padding:3pt;'";
    const QString baslikHucreStili = "style='border:1px solid #d1d5db; padding:3pt; background:#f3f4f6; text-align:left;'";
    auto satir = [&](const QStringList &hucreler, bool basliksatiri = false) {
        QString satirHtml = "<tr>";
        for (const QString &hucre : hucreler) {
            satirHtml += QString("<%1 %2>%3</%1>").arg(basliksatiri ? "th" : "td",
                                                       basliksatiri ? baslikHucreStili : hucreStili, hucre);
        }
        return satirHtml + "</tr>";
    };
    auto tablo = [](const QString &icerik) {
        return "<table width='100%' cellspacing='0' cellpadding='3' style='border-collapse:collapse; font-size:9pt;'>" + icerik + "</table>";
    };
    auto baslik = [](const QString &yazi) {
        return "<h2 style='color:#111827; margin-top:22px; margin-bottom:6px; font-size:12pt;'>" + yazi + "</h2>";
    };

    QString html = "<html><body style='font-family:Segoe UI, Arial, sans-serif; color:#111827;'>";
    html += "<h1 style='color:#3b82f6; margin-bottom:4px; font-size:18pt;'>SLIPER Analiz Raporu</h1>"
            "<p style='color:#6b7280; font-size:9pt; margin-top:0;'>Liya Laboratuvar Test Cihazları — Sliding Pipe Rheometer</p>"
            "<hr style='border:none; border-top:1px solid #d1d5db;'>";

    html += tablo(
        satir({ "<b>Ölçüm ID</b>", QString::number(olcumId) })
        + satir({ "<b>Ölçüm tarihi</b>", bilgi["tarih"].toString().toHtmlEscaped() })
        + satir({ "<b>Yer</b>", bilgi["yer"].toString().toHtmlEscaped() })
        + satir({ "<b>Müşteri</b>", bilgi["musteri"].toString().toHtmlEscaped() })
        + satir({ "<b>Reçete</b>", bilgi["recete"].toString().toHtmlEscaped() })
        + satir({ "<b>Yorum</b>", bilgi["yorum"].toString().toHtmlEscaped() })
        + satir({ "<b>Rapor tarihi</b>", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm") }));

    html += baslik("P–Q Sonuçları");
    html += tablo(
        satir({ "Parametre", "Değer" }, true)
        + satir({ "P–Q kesişimi A", yeterliVeri ? sayi(kesisimA, 2) + " mbar" : "—" })
        + satir({ "P–Q eğimi B", yeterliVeri ? sayi(egimB, 3) + " mbar·h/m³" : "—" })
        + satir({ "a (Yield Pressure)", yeterliVeri ? sayi(SliperModel::schleibingerA(kesisimA), 3) + " mbar" : "—" })
        + satir({ "b (Pressure Gradient, ×1000)", yeterliVeri ? sayi(SliperModel::schleibingerB(egimB) * 1000.0, 3) : "—" })
        + satir({ "Uyum kalitesi R²", yeterliVeri ? sayi(pqSonucu["r2"].toDouble(), 3) : "—" })
        + satir({ "Kullanılan / toplam stroke", QString("%1 / %2").arg(pqSonucu["n"].toInt()).arg(pqSonucu["toplamStroke"].toInt()) }));

    const QStringList uyarilar = pqSonucu.value("uyarilar").toStringList();
    if (!uyarilar.isEmpty()) {
        html += "<p style='color:#b45309; font-size:9pt;'><b>Uyarılar:</b><br>";
        for (const QString &uyariKodu : uyarilar) html += "• " + uyariMetni(uyariKodu).toHtmlEscaped() + "<br>";
        html += "</p>";
    }

    {
        Seri dahilNoktalar; dahilNoktalar.noktaMi = true; dahilNoktalar.renk = QColor("#3b82f6"); dahilNoktalar.ad = "Stroke (tahmine dahil)";
        Seri haricNoktalar; haricNoktalar.noktaMi = true; haricNoktalar.renk = QColor("#9ca3af"); haricNoktalar.ad = "Hariç / hatalı";
        double enBuyukDebi = 1.0;
        for (const QVariant &kayit : strokelar) {
            const QVariantMap stroke = kayit.toMap();
            const QPointF nokta(stroke["debi"].toDouble(), stroke["basinc"].toDouble());
            const bool tahmineDahil = stroke["gecerli"].toBool() && stroke["secili"].toBool();
            (tahmineDahil ? dahilNoktalar : haricNoktalar).noktalar.append(nokta);
            enBuyukDebi = std::max(enBuyukDebi, nokta.x());
        }
        QVector<Seri> seriler { dahilNoktalar };
        if (!haricNoktalar.noktalar.isEmpty()) seriler.append(haricNoktalar);
        if (yeterliVeri) {
            Seri pqCizgisi; pqCizgisi.renk = QColor("#111827"); pqCizgisi.ad = "Regresyon";
            const double cizgiSonuDebi = enBuyukDebi * 1.1;
            pqCizgisi.noktalar = { QPointF(0, kesisimA), QPointF(cizgiSonuDebi, kesisimA + egimB * cizgiSonuDebi) };
            seriler.append(pqCizgisi);
        }
        gorseller["pq"] = grafikCiz(QString("p–Q  (A = %1 mbar, B = %2 mbar·h/m³)").arg(sayi(kesisimA, 2), sayi(egimB, 3)),
                                    "Q [m³/h]", "p [mbar]", seriler);
        html += "<p align='center'><img src='__pq__' width='620'></p>";
    }

    html += baslik("Stroke Özeti");
    {
        QString icerik = satir({ "No", "Saat", "Süre [s]", "Ağırlık [kg]", "Pmax", "P0l", "P0r", "p [mbar]", "Q [m³/h]", "Durum" }, true);
        for (const QVariant &kayit : strokelar) {
            const QVariantMap stroke = kayit.toMap();
            const QString durum = stroke["gecerli"].toBool()
                ? (stroke["secili"].toBool() ? "Dahil"
                   : stroke["otomatikHaric"].toBool() ? "Otomatik hariç" : "Hariç")
                : "Hatalı stroke";
            icerik += satir({ QString::number(stroke["stroke"].toInt()), stroke["saat"].toString(),
                              sayi(stroke["sure"].toDouble(), 2), sayi(stroke["agirlik"].toDouble(), 1),
                              sayi(stroke["pMaks"].toDouble(), 1), sayi(stroke["p0l"].toDouble(), 1),
                              sayi(stroke["p0r"].toDouble(), 1), sayi(stroke["basinc"].toDouble(), 2),
                              sayi(stroke["debi"].toDouble(), 2), durum });
        }
        html += tablo(icerik);
    }

    html += baslik("Pompa Basıncı Tahmini");
    html += tablo(
        satir({ "Girdi", "Değer" }, true)
        + satir({ "Hedef debi Q", sayi(ayarlar["hedefDebi"].toDouble(), 1) + " m³/h" })
        + satir({ "Boru iç çapı D", sayi(ayarlar["cap"].toDouble(), 0) + " mm" })
        + satir({ "Hat uzunluğu", sayi(ayarlar["hatUzunlugu"].toDouble(), 0) + " m" })
        + satir({ "Pompalama yüksekliği h", sayi(ayarlar["yukseklik"].toDouble(), 1) + " m" })
        + satir({ "90° dirsek", QString("%1 adet × %2 m").arg(sayi(ayarlar["dirsek90"].toDouble(), 0), sayi(SliperModel::DIRSEK_90_ESDEGER_M, 1)) })
        + satir({ "45° dirsek", QString("%1 adet × %2 m").arg(sayi(ayarlar["dirsek45"].toDouble(), 0), sayi(SliperModel::DIRSEK_45_ESDEGER_M, 1)) })
        + satir({ "Hesap uzunluğu L (hat + dirsekler)", sayi(SliperModel::hesapUzunluguM(ayarlar), 1) + " m" })
        + satir({ "Beton yoğunluğu ρ", sayi(ayarlar["yogunluk"].toDouble(), 0) + " kg/m³" })
        + satir({ "Hata payı", "±%" + sayi(ayarlar["hataPayi"].toDouble(), 0) })
        + satir({ "Pompa maks. basıncı", ayarlar["pompaMaks"].toDouble() > 0 ? sayi(ayarlar["pompaMaks"].toDouble(), 1) + " bar" : "girilmedi" }));

    const double pompaMaksBar = ayarlar["pompaMaks"].toDouble();
    bool pompaAsildi = false;
    const QString guvenilmezNedeni = SliperModel::tahminGuvenilmezNedeni(kesisimA, egimB, pqSonucu["r2"].toDouble());
    const bool kararVerilemez = SliperModel::tahminKarariVerilemez(guvenilmezNedeni);
    const bool dusukGuven = guvenilmezNedeni == "dusukR2";
    double enYuksekTahminBar = 0.0;
    QVariantMap enKotuTahmin;
    if (!tahminSatirlari.isEmpty()) {
        QString icerik = satir({ "Q [m³/h]", "L [m]", "P [bar]", "Alt–Üst [bar]", "Pompa" }, true);
        for (const QVariant &kayit : tahminSatirlari) {
            const QVariantMap tahmin = kayit.toMap();
            if (enKotuTahmin.isEmpty() || tahmin["ustSinirBar"].toDouble() > enYuksekTahminBar) enKotuTahmin = tahmin;
            enYuksekTahminBar = std::max(enYuksekTahminBar, tahmin["ustSinirBar"].toDouble());
            pompaAsildi = pompaAsildi || tahmin["pompaAsildi"].toBool();
            QString pompaDurumu = "—";
            if (pompaMaksBar > 0) {
                if (kararVerilemez || tahmin["basincNegatif"].toBool())
                    pompaDurumu = "<span style='color:#6b7280;'>geçersiz</span>";
                else if (tahmin["pompaAsildi"].toBool())
                    pompaDurumu = "<span style='color:#dc2626;'><b>aşıldı</b></span>";
                else if (dusukGuven)
                    pompaDurumu = "<span style='color:#b45309;'>uygun?</span>";
                else
                    pompaDurumu = "<span style='color:#16a34a;'>uygun</span>";
            }
            icerik += satir({ sayi(tahmin["debi"].toDouble(), 1), sayi(tahmin["uzunluk"].toDouble(), 0),
                              "<b>" + sayi(tahmin["basincBar"].toDouble(), 2) + "</b>",
                              sayi(tahmin["altSinirBar"].toDouble(), 2) + " – " + sayi(tahmin["ustSinirBar"].toDouble(), 2),
                              pompaDurumu });
        }
        html += "<br>" + tablo(icerik);
        html += "<p style='color:#6b7280; font-size:8pt;'>Model: P = 4L/D·a + 16·L·Q/(π·D³)·b + ρ·g·h "
                + QString("(a = d·A/4l, b = B·π·d³/16l; d = %1 m, l = %2 m)</p>")
                      .arg(SliperModel::BORU_CAPI_M).arg(SliperModel::BORU_UZUNLUGU_M);

        const double hedefDebi = ayarlar["hedefDebi"].toDouble();
        const double grafikSonuDebi = std::max(hedefDebi * 1.5, 10.0);
        const double hatCapiMm = ayarlar["cap"].toDouble();
        const double hatUzunluguM = SliperModel::hesapUzunluguM(ayarlar);
        const double yukseklikM = ayarlar["yukseklik"].toDouble();
        const double yogunluk = ayarlar["yogunluk"].toDouble();
        const double hataPayi = ayarlar["hataPayi"].toDouble();
        QVector<Seri> seriler;
        Seri tahminCizgisi; tahminCizgisi.renk = QColor("#2563eb"); tahminCizgisi.stil = Qt::SolidLine;
        tahminCizgisi.ad = QString("Tahmin %1 m").arg(sayi(hatUzunluguM, 0));
        for (double debi : { 0.0, grafikSonuDebi }) {
            const QVariantMap tahmin = SliperModel::basincTahmini(kesisimA, egimB, debi, hatCapiMm,
                hatUzunluguM, yukseklikM, yogunluk, hataPayi);
            tahminCizgisi.noktalar.append(QPointF(debi, tahmin["basincBar"].toDouble()));
        }
        if (hataPayi > 0) {
            const QVariantMap tahmin = SliperModel::basincTahmini(kesisimA, egimB, hedefDebi, hatCapiMm,
                hatUzunluguM, yukseklikM, yogunluk, hataPayi);
            tahminCizgisi.hataCubuklari.append({ QPointF(hedefDebi, tahmin["altSinirBar"].toDouble()),
                                                 QPointF(hedefDebi, tahmin["ustSinirBar"].toDouble()) });
        }
        seriler.append(tahminCizgisi);
        Seri hedefNoktasi; hedefNoktasi.noktaMi = true; hedefNoktasi.renk = QColor("#dc2626"); hedefNoktasi.ad = "Hedef debi";
        hedefNoktasi.noktalar.append(QPointF(hedefDebi, SliperModel::basincTahmini(kesisimA, egimB, hedefDebi, hatCapiMm,
            hatUzunluguM, yukseklikM, yogunluk, hataPayi)["basincBar"].toDouble()));
        seriler.append(hedefNoktasi);
        if (pompaMaksBar > 0) {
            Seri pompaCizgisi; pompaCizgisi.renk = QColor("#f59e0b"); pompaCizgisi.stil = Qt::DashDotLine; pompaCizgisi.ad = "Pompa maks.";
            pompaCizgisi.noktalar = { QPointF(0, pompaMaksBar), QPointF(grafikSonuDebi, pompaMaksBar) };
            seriler.append(pompaCizgisi);
        }
        gorseller["tahmin"] = grafikCiz("Tahmin Grafiği", "Q [m³/h]", "P [bar]", seriler);
        html += "<p align='center'><img src='__tahmin__' width='620'></p>";
    } else {
        html += "<p style='color:#6b7280;'>Tahmin için yeterli geçerli stroke yok.</p>";
    }

    QString durumRengi = "#6b7280";
    QString durumMetni = "DEĞERLENDİRİLMEDİ (pompa maks. basıncı girilmedi)";
    if (!yeterliVeri) {
        durumMetni = "DEĞERLENDİRİLEMEDİ (yetersiz stroke verisi)";
    } else if (kararVerilemez) {
        durumMetni = guvenilmezNedeni == "egimNegatif"
            ? "DEĞERLENDİRİLEMEDİ — P–Q eğimi (B) negatif, tahmin fiziksel değil. Ölçümü tekrarlayın."
            : "DEĞERLENDİRİLEMEDİ — P–Q kesişimi (A) negatif, tahmin fiziksel değil. Ölçümü tekrarlayın.";
    } else if (pompaMaksBar > 0) {
        if (pompaAsildi) {
            durumRengi = "#dc2626";
            durumMetni = QString("POMPA KAPASİTESİ YETERSİZ — gereken en fazla %1 bar / pompa %2 bar")
                .arg(sayi(enYuksekTahminBar, 1), sayi(pompaMaksBar, 1));
        } else if (dusukGuven) {
            durumRengi = "#b45309";
            durumMetni = QString("POMPALANABİLİR — GÜVENİLİR DEĞİL (R² = %1) — gereken en fazla %2 bar / pompa %3 bar")
                .arg(sayi(pqSonucu["r2"].toDouble(), 2), sayi(enYuksekTahminBar, 1), sayi(pompaMaksBar, 1));
        } else {
            durumRengi = "#16a34a";
            durumMetni = QString("POMPALANABİLİR — gereken en fazla %1 bar / pompa %2 bar")
                .arg(sayi(enYuksekTahminBar, 1), sayi(pompaMaksBar, 1));
        }
    }
    html += QString("<p style='margin-top:16px;'><b>Durum:</b> <span style='color:%1; font-weight:bold;'>%2</span></p>")
                .arg(durumRengi, durumMetni.toHtmlEscaped());

    if (yeterliVeri && !kararVerilemez && pompaMaksBar > 0 && pompaAsildi) {
        const QString sorunNedeni = SliperModel::pompaSorunuNedeni(enKotuTahmin, pompaMaksBar);
        QString oneriBasligi;
        QString gerekce;
        QStringList maddeler;
        if (sorunNedeni == "yukseklik") {
            oneriBasligi = "Reçeteyle çözülmez";
            gerekce = "Yalnızca pompalama yüksekliğinden gelen basınç (ρ·g·h) pompa kapasitesine ulaşıyor; "
                      "karışımın sürtünmesini azaltmak yeterli olmaz.";
            maddeler = { "Daha yüksek basınçlı pompa gerekir" };
        } else if (sorunNedeni == "viskoz") {
            oneriBasligi = "Karışım yapışkan";
            gerekce = "Sürtünmenin büyük kısmı viskoz terimden (b) geliyor: boru cidarındaki kayma tabakası koyu, "
                      "direnç debiyle hızla artıyor.";
            maddeler = { "Katkıyı (akışkanlaştırıcı) artırın", "Viskozite düzenleyici katkıyı azaltın",
                         "Toz / ince malzemeyi azaltın" };
        } else {
            oneriBasligi = "Karışım sert";
            gerekce = "Sürtünmenin büyük kısmı akma teriminden (a) geliyor: boru cidarında kayma tabakasını "
                      "oluşturacak harç yetersiz, betonu harekete geçirmek için yüksek basınç gerekiyor.";
            maddeler = { "Katkıyı (akışkanlaştırıcı) artırın", "İnce kum / harç oranını artırın",
                         "İri agregayı azaltın" };
        }
        html += baslik("Reçete Önerisi");
        html += "<p><b>" + oneriBasligi.toHtmlEscaped() + "</b></p><ul>";
        for (const QString &madde : maddeler) html += "<li>" + madde.toHtmlEscaped() + "</li>";
        html += "</ul>";
        if (sorunNedeni != "yukseklik") html += "<p>Değişiklikten sonra tekrar ölçün.</p>";
        html += "<p style='color:#6b7280; font-size:8pt;'>" + gerekce.toHtmlEscaped()
                + " Öneriler yön belirtir; miktar kullanılan malzemeye bağlıdır ve yeniden ölçümle doğrulanmalıdır.</p>";
    }

    const QVariantMap konumSinirlari = m_database->kalibrasyonGetir("konum_sinirlari");
    html += baslik("Cihaz Parametreleri");
    html += tablo(
        satir({ "Reometre boru çapı", sayi(SliperModel::BORU_CAPI_M * 1000.0, 0) + " mm" })
        + satir({ "Reometre dolum yüksekliği", sayi(SliperModel::BORU_UZUNLUGU_M * 1000.0, 0) + " mm" })
        + satir({ "Üst / alt konum referansı", konumSinirlari["mevcut"].toBool()
                  ? sayi(konumSinirlari["deger1"].toDouble(), 1) + " / " + sayi(konumSinirlari["deger2"].toDouble(), 1) + " mm"
                  : "kalibre edilmedi (varsayılan)" })
        + satir({ "Load cell kalibrasyonu", tarihVeyaCizgi(m_database->kalibrasyonTarihiGetir("loadcell")) })
        + satir({ "Mesafe sensörü kalibrasyonu", tarihVeyaCizgi(m_database->kalibrasyonTarihiGetir("mesafe_olcum")) })
        + satir({ "Uygulanan dara", bilgi["daraBasinci"].toDouble() != 0.0
                  ? sayi(bilgi["daraBasinci"].toDouble(), 2) + " mbar (A ve a bu kadar düşüktür)"
                  : "yok" }));

    html += "<hr style='border:none; border-top:1px solid #d1d5db; margin-top:20px;'>"
            "<p style='color:#6b7280; font-size:8pt;'>Liya Laboratuvar Test Cihazları - SLIPER Analiz Sistemi</p>"
            "</body></html>";
    return html;
}

QString ReportManager::pdfOnizlemeHtml(int olcumId)
{
    QMap<QString, QImage> gorseller;
    QString html = raporHtmlOlustur(olcumId, gorseller);

    const QString klasor = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/rapor_onizleme";
    QDir().mkpath(klasor);
    const QString damga = QString::number(QDateTime::currentMSecsSinceEpoch());
    for (auto it = gorseller.constBegin(); it != gorseller.constEnd(); ++it) {
        const QString yol = klasor + QString("/%1_%2_%3.png").arg(olcumId).arg(it.key(), damga);
        it.value().save(yol);
        html.replace("__" + it.key() + "__", QUrl::fromLocalFile(yol).toString());
    }
    return html;
}

QString ReportManager::pdfOlustur(int olcumId)
{
    QString klasor = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/SliperRaporlari";
    if (!QDir().mkpath(klasor)) {
        qWarning() << "Rapor klasoru olusturulamadi:" << klasor;
        return QString();
    }

    QString dosyaAdi = klasor + QString("/SLIPER_Rapor_%1_%2.pdf")
        .arg(olcumId)
        .arg(QDateTime::currentDateTime().toString("ddMMyyyy_HHmmss"));

    QMap<QString, QImage> gorseller;
    QString html = raporHtmlOlustur(olcumId, gorseller);

    QTextDocument belge;
    auto kaynaklariEkle = [&]() {
        for (auto it = gorseller.constBegin(); it != gorseller.constEnd(); ++it) {
            belge.addResource(QTextDocument::ImageResource, QUrl("gorsel://" + it.key()), it.value());
        }
    };
    for (auto it = gorseller.constBegin(); it != gorseller.constEnd(); ++it) {
        html.replace("__" + it.key() + "__", "gorsel://" + it.key());
    }
    kaynaklariEkle();
    belge.setHtml(html);
    kaynaklariEkle();

    QPrinter yazici(QPrinter::HighResolution);
    yazici.setOutputFormat(QPrinter::PdfFormat);
    yazici.setPageSize(QPageSize(QPageSize::A4));
    yazici.setOutputFileName(dosyaAdi);

    belge.print(&yazici);

    if (!QFile::exists(dosyaAdi)) {
        qWarning() << "PDF dosyasi yazilamadi:" << dosyaAdi;
        return QString();
    }

    qDebug() << "PDF rapor olusturuldu:" << dosyaAdi;
    return dosyaAdi;
}

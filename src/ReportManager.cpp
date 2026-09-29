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

// Eksen çizgileri arasındaki okunaklı adım: 1, 2, 5, 10, 20, 50 ... gibi.
//   örnek: aralık 0..37, 8 çizgi isteniyor -> kaba adım 4.6 -> 5 seçilir
double okunakliEksenAdimi(double aralik, int hedefCizgiSayisi)
{
    if (aralik <= 0.0) return 1.0;
    const double kabaAdim = aralik / hedefCizgiSayisi;
    const double onunKuvveti = std::pow(10.0, std::floor(std::log10(kabaAdim)));   // 4.6 -> 1, 46 -> 10
    const double ilkRakam = kabaAdim / onunKuvveti;                                // 1 ile 10 arası
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
        { "dusukR2", "Uyum kalitesi düşük (R² < 0.90): stroke noktaları doğrudan çok sapıyor." },
        { "darDebiAraligi", "Debi aralığı çok dar: farklı ağırlıklarla stroke atılmalı, aksi halde eğim güvenilir değil." },
        { "yukBasinaAzStroke", "Bazı yüklerde 3'ten az geçerli stroke var; kılavuz her yük için en az 3 stroke önerir." },
        { "tekYuk", "Tüm stroke'lar aynı ek ağırlıkla atılmış: en az iki farklı yük kullanılmalı." },
        { "cokGecersiz", "Stroke'ların %30'undan fazlası geçersiz: boru sıkışması veya ayrışma belirtisi olabilir." }
    };
    return metinler.value(kod, kod);
}

}

QImage ReportManager::grafikCiz(const QString &baslik, const QString &xEtiket, const QString &yEtiket,
                                const QVector<Seri> &seriler)
{
    // Görsel boyutu (piksel) ve içindeki çizim alanı (kenarlarda eksen yazıları için boşluk)
    const int gorselGenislik = 1000, gorselYukseklik = 560;
    const QRectF cizimAlani(90, 50, gorselGenislik - 120, gorselYukseklik - 130);
    QImage gorsel(gorselGenislik, gorselYukseklik, QImage::Format_ARGB32);
    gorsel.fill(Qt::white);

    // Veri aralığı (0 dahil, eksenler sıfırdan başlar)
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
    // Eksen sınırları adımın katına yuvarlanır; üstte biraz boşluk bırakılır
    const double xAdim = okunakliEksenAdimi(xMaks - xMin, 8);
    const double yAdim = okunakliEksenAdimi(yMaks - yMin, 6);
    xMin = std::floor(xMin / xAdim) * xAdim; xMaks = std::ceil(xMaks * 1.05 / xAdim) * xAdim;
    yMin = std::floor(yMin / yAdim) * yAdim; yMaks = std::ceil(yMaks * 1.08 / yAdim) * yAdim;
    if (xMaks <= xMin) xMaks = xMin + xAdim;
    if (yMaks <= yMin) yMaks = yMin + yAdim;

    // Veri koordinatı (ör. Q, p) -> görsel üzerindeki piksel konumu
    auto pikseleCevir = [&](const QPointF &veriNoktasi) {
        return QPointF(cizimAlani.left() + (veriNoktasi.x() - xMin) / (xMaks - xMin) * cizimAlani.width(),
                       cizimAlani.bottom() - (veriNoktasi.y() - yMin) / (yMaks - yMin) * cizimAlani.height());
    };

    QPainter kalem(&gorsel);
    kalem.setRenderHint(QPainter::Antialiasing);
    QFont normalYazi("Segoe UI", 11);
    kalem.setFont(normalYazi);

    // Izgara çizgileri
    kalem.setPen(QPen(QColor("#e5e7eb"), 1));
    for (double x = xMin; x <= xMaks + xAdim * 0.01; x += xAdim) {
        const QPointF piksel = pikseleCevir({ x, yMin });
        kalem.drawLine(QPointF(piksel.x(), cizimAlani.top()), QPointF(piksel.x(), cizimAlani.bottom()));
    }
    for (double y = yMin; y <= yMaks + yAdim * 0.01; y += yAdim) {
        const QPointF piksel = pikseleCevir({ xMin, y });
        kalem.drawLine(QPointF(cizimAlani.left(), piksel.y()), QPointF(cizimAlani.right(), piksel.y()));
    }
    // Eksen sayıları
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

    // Eksen adları ve başlık
    kalem.drawText(QRectF(cizimAlani.left(), gorselYukseklik - 50, cizimAlani.width(), 24), Qt::AlignCenter, xEtiket);
    kalem.save();
    kalem.translate(18, cizimAlani.center().y());
    kalem.rotate(-90);   // y ekseni adı dikey yazılır
    kalem.drawText(QRectF(-cizimAlani.height() / 2, -12, cizimAlani.height(), 24), Qt::AlignCenter, yEtiket);
    kalem.restore();
    QFont baslikYazisi("Segoe UI", 14, QFont::Bold);
    kalem.setFont(baslikYazisi);
    kalem.setPen(QColor("#111827"));
    kalem.drawText(QRectF(0, 10, gorselGenislik, 30), Qt::AlignCenter, baslik);
    kalem.setFont(normalYazi);

    // Seriler (nokta veya çizgi) ve hata çubukları
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

    // Lejant (sol üst köşe, yan yana)
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

    // --- Temel veriler ---
    html += tablo(
        satir({ "<b>Ölçüm ID</b>", QString::number(olcumId) })
        + satir({ "<b>Ölçüm tarihi</b>", bilgi["tarih"].toString().toHtmlEscaped() })
        + satir({ "<b>Yer</b>", bilgi["yer"].toString().toHtmlEscaped() })
        + satir({ "<b>Müşteri</b>", bilgi["musteri"].toString().toHtmlEscaped() })
        + satir({ "<b>Reçete</b>", bilgi["recete"].toString().toHtmlEscaped() })
        + satir({ "<b>Yorum</b>", bilgi["yorum"].toString().toHtmlEscaped() })
        + satir({ "<b>Rapor tarihi</b>", QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm") }));

    // --- P–Q sonuçları ---
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

    // --- p-Q grafiği ---
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

    // --- Stroke özeti ---
    html += baslik("Stroke Özeti");
    {
        QString icerik = satir({ "No", "Saat", "Süre [s]", "Ağırlık [kg]", "Pmax", "P0l", "P0r", "p [mbar]", "Q [m³/h]", "Durum" }, true);
        for (const QVariant &kayit : strokelar) {
            const QVariantMap stroke = kayit.toMap();
            const QString durum = stroke["gecerli"].toBool()
                ? (stroke["secili"].toBool() ? "Dahil" : "Hariç")
                : "Hatalı stroke";
            icerik += satir({ QString::number(stroke["stroke"].toInt()), stroke["saat"].toString(),
                              sayi(stroke["sure"].toDouble(), 2), sayi(stroke["agirlik"].toDouble(), 1),
                              sayi(stroke["pMaks"].toDouble(), 1), sayi(stroke["p0l"].toDouble(), 1),
                              sayi(stroke["p0r"].toDouble(), 1), sayi(stroke["basinc"].toDouble(), 2),
                              sayi(stroke["debi"].toDouble(), 2), durum });
        }
        html += tablo(icerik);
    }

    // --- Tahmin ---
    html += baslik("Pompa Basıncı Tahmini");
    html += tablo(
        satir({ "Girdi", "Değer" }, true)
        + satir({ "Debi Q1 / Q2", sayi(ayarlar["q1"].toDouble(), 1) + " / " + sayi(ayarlar["q2"].toDouble(), 1) + " m³/h" })
        + satir({ "Boru çapı D", sayi(ayarlar["cap"].toDouble(), 0) + " mm" })
        + satir({ "Boru uzunlukları L2 / L3 / L4", sayi(ayarlar["l2"].toDouble(), 0) + " / " + sayi(ayarlar["l3"].toDouble(), 0) + " / " + sayi(ayarlar["l4"].toDouble(), 0) + " m" })
        + satir({ "Pompalama yüksekliği h", sayi(ayarlar["yukseklik"].toDouble(), 1) + " m" })
        + satir({ "Beton yoğunluğu ρ", sayi(ayarlar["yogunluk"].toDouble(), 0) + " kg/m³" })
        + satir({ "Hata payı", "±%" + sayi(ayarlar["hataPayi"].toDouble(), 0) })
        + satir({ "Pompa maks. basıncı", ayarlar["pompaMaks"].toDouble() > 0 ? sayi(ayarlar["pompaMaks"].toDouble(), 1) + " bar" : "girilmedi" }));

    const double pompaMaksBar = ayarlar["pompaMaks"].toDouble();
    double enYuksekTahminBar = 0.0;   // hata payı üst sınırıyla en kötü durum
    if (!tahminSatirlari.isEmpty()) {
        QString icerik = satir({ "Q [m³/h]", "L [m]", "P [bar]", "Alt–Üst [bar]", "Pompa" }, true);
        for (const QVariant &kayit : tahminSatirlari) {
            const QVariantMap tahmin = kayit.toMap();
            enYuksekTahminBar = std::max(enYuksekTahminBar, tahmin["ustSinirBar"].toDouble());
            const QString pompaDurumu = pompaMaksBar <= 0 ? "—" : (tahmin["pompaAsildi"].toBool()
                ? "<span style='color:#dc2626;'><b>aşıldı</b></span>" : "<span style='color:#16a34a;'>uygun</span>");
            icerik += satir({ sayi(tahmin["debi"].toDouble(), 1), sayi(tahmin["uzunluk"].toDouble(), 0),
                              "<b>" + sayi(tahmin["basincBar"].toDouble(), 2) + "</b>",
                              sayi(tahmin["altSinirBar"].toDouble(), 2) + " – " + sayi(tahmin["ustSinirBar"].toDouble(), 2),
                              pompaDurumu });
        }
        html += "<br>" + tablo(icerik);
        html += "<p style='color:#6b7280; font-size:8pt;'>Model: P = 4L/D·a + 16·L·Q/(π·D³)·b + ρ·g·h "
                + QString("(a = d·A/4l, b = B·π·d³/16l; d = %1 m, l = %2 m)</p>")
                      .arg(SliperModel::BORU_CAPI_M).arg(SliperModel::BORU_UZUNLUGU_M);

        // Tahmin grafiği: her uzunluk için P(Q) doğrusu + Q1/Q2'de hata çubukları
        const QColor renkler[3] = { QColor("#2563eb"), QColor("#16a34a"), QColor("#dc2626") };
        const Qt::PenStyle stiller[3] = { Qt::SolidLine, Qt::DotLine, Qt::DashLine };
        const char *uzunlukAlanlari[3] = { "l2", "l3", "l4" };
        const double grafikSonuDebi = std::max(ayarlar["q1"].toDouble(), ayarlar["q2"].toDouble()) * 1.1;
        const double hatCapiMm = ayarlar["cap"].toDouble();
        const double yukseklikM = ayarlar["yukseklik"].toDouble();
        const double yogunluk = ayarlar["yogunluk"].toDouble();
        const double hataPayi = ayarlar["hataPayi"].toDouble();
        QVector<Seri> seriler;
        for (int i = 0; i < 3; ++i) {
            const double hatUzunluguM = ayarlar[uzunlukAlanlari[i]].toDouble();
            Seri tahminCizgisi; tahminCizgisi.renk = renkler[i]; tahminCizgisi.stil = stiller[i];
            tahminCizgisi.ad = QString("Tahmin %1 m").arg(sayi(hatUzunluguM, 0));
            // Tahmin Q'ya göre düz çizgidir: iki uç nokta yeter
            for (double debi : { 0.0, grafikSonuDebi }) {
                const QVariantMap tahmin = SliperModel::basincTahmini(kesisimA, egimB, debi, hatCapiMm,
                    hatUzunluguM, yukseklikM, yogunluk, hataPayi);
                tahminCizgisi.noktalar.append(QPointF(debi, tahmin["basincBar"].toDouble()));
            }
            // Q1 ve Q2'de hata payı çubukları
            for (double debi : { ayarlar["q1"].toDouble(), ayarlar["q2"].toDouble() }) {
                const QVariantMap tahmin = SliperModel::basincTahmini(kesisimA, egimB, debi, hatCapiMm,
                    hatUzunluguM, yukseklikM, yogunluk, hataPayi);
                if (hataPayi > 0) {
                    tahminCizgisi.hataCubuklari.append({ QPointF(debi, tahmin["altSinirBar"].toDouble()),
                                                         QPointF(debi, tahmin["ustSinirBar"].toDouble()) });
                }
            }
            seriler.append(tahminCizgisi);
        }
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

    // --- Durum ---
    QString durumRengi = "#6b7280";
    QString durumMetni = "DEĞERLENDİRİLMEDİ (pompa maks. basıncı girilmedi)";
    if (!yeterliVeri) {
        durumMetni = "DEĞERLENDİRİLEMEDİ (yetersiz stroke verisi)";
    } else if (pompaMaksBar > 0) {
        const bool pompaYeterli = enYuksekTahminBar <= pompaMaksBar;
        durumRengi = pompaYeterli ? "#16a34a" : "#dc2626";
        durumMetni = QString("%1 — en yüksek tahmin %2 bar / pompa %3 bar")
            .arg(pompaYeterli ? "TÜM DURUMLARDA POMPALANABİLİR" : "BAZI DURUMLARDA POMPA KAPASİTESİ YETERSİZ",
                 sayi(enYuksekTahminBar, 1), sayi(pompaMaksBar, 1));
    }
    html += QString("<p style='margin-top:16px;'><b>Durum:</b> <span style='color:%1; font-weight:bold;'>%2</span></p>")
                .arg(durumRengi, durumMetni.toHtmlEscaped());

    // --- Cihaz parametreleri ---
    const QVariantMap konumSinirlari = m_database->kalibrasyonGetir("konum_sinirlari");
    html += baslik("Cihaz Parametreleri");
    html += tablo(
        satir({ "Reometre boru çapı", sayi(SliperModel::BORU_CAPI_M * 1000.0, 0) + " mm" })
        + satir({ "Reometre dolum yüksekliği", sayi(SliperModel::BORU_UZUNLUGU_M * 1000.0, 0) + " mm" })
        + satir({ "Üst / alt konum referansı", konumSinirlari["mevcut"].toBool()
                  ? sayi(konumSinirlari["deger1"].toDouble(), 1) + " / " + sayi(konumSinirlari["deger2"].toDouble(), 1) + " mm"
                  : "kalibre edilmedi (varsayılan)" })
        + satir({ "Load cell kalibrasyonu", tarihVeyaCizgi(m_database->kalibrasyonTarihiGetir("loadcell")) })
        + satir({ "Mesafe sensörü kalibrasyonu", tarihVeyaCizgi(m_database->kalibrasyonTarihiGetir("mesafe_olcum")) }));

    html += "<hr style='border:none; border-top:1px solid #d1d5db; margin-top:20px;'>"
            "<p style='color:#6b7280; font-size:8pt;'>Liya Laboratuvar Test Cihazları - SLIPER Analiz Sistemi</p>"
            "</body></html>";
    return html;
}

// Önizleme: grafikler geçici PNG dosyalarına yazılıp file:/// ile gösterilir
// (QML RichText yerel dosya görsellerini yükleyebilir).
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
    // setHtml belgeyi temizlerken kaynakları da silebildiği için iki kez eklenir
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

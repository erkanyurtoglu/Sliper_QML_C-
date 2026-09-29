import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import QtCharts 6.7
import sliper

// Orijinal SLIPER "View Results / Calculate Forecast" ekranlarının karşılığı:
// Table of Strokes, p-Q Chart of Strokes, Calculation of the Forecast,
// Forecast Chart ve her stroke'un basınç / mesafe-hız eğrileri.
Rectangle {
    id: kok
    color: "#0a0a0d"

    property int olcumId: -1
    property var bilgi: ({})
    property var sonuc: ({ yeterliVeri: false, tau0: 0, mu: 0, r2: 0, n: 0, toplamStroke: 0, uyarilar: [] })
    property var strokeListesi: []
    property var tahminAyarlari: ({})
    property var tahminSatirlari: []
    property int seciliStrokeIndex: -1
    property int aktifSekme: 0
    property int playbackAdimi: -1

    readonly property real hesaplananTau0: sonuc.tau0 || 0
    readonly property real hesaplananMu: sonuc.mu || 0

    readonly property var metinler: ({
        sonucOzeti: { tr: "SONUÇ ÖZETİ", en: "RESULT SUMMARY" },
        duzenle: { tr: "✎ Düzenle", en: "✎ Edit" },
        yer: { tr: "Yer", en: "Place" },
        musteri: { tr: "Müşteri", en: "Customer" },
        recete: { tr: "Reçete", en: "Formula" },
        yorum: { tr: "Yorum", en: "Comment" },
        kesisimA: { tr: "P–Q KESİŞİMİ (A)", en: "P–Q INTERCEPT (A)" },
        egimB: { tr: "P–Q EĞİMİ (B)", en: "P–Q SLOPE (B)" },
        yieldA: { tr: "a (Yield Pressure)", en: "a (Yield Pressure)" },
        gradyanB: { tr: "b (Pressure Gradient ×1000)", en: "b (Pressure Gradient ×1000)" },
        uyumKalitesi: { tr: "UYUM (R²)", en: "FIT (R²)" },
        kullanilanStroke: { tr: "KULLANILAN STROKE", en: "STROKES USED" },
        uyarilarBaslik: { tr: "ÖLÇÜM KALİTESİ UYARILARI", en: "MEASUREMENT QUALITY WARNINGS" },
        uyari_azStroke: { tr: "Yeterli geçerli stroke yok (en az 3; her yük için 3 stroke önerilir).", en: "Not enough valid strokes (at least 3; 3 per load recommended)." },
        uyari_egimNegatif: { tr: "Eğim (B) negatif: debi arttıkça basınç düşüyor. Ayrışma/blokaj veya ölçüm hatası olabilir.", en: "Slope (B) is negative: pressure drops as flow rises. Possible segregation/blockage or measurement error." },
        uyari_kesisimNegatif: { tr: "Kesişim (A) negatif: durağan basınç (P0) hatalı ölçülmüş olabilir.", en: "Intercept (A) is negative: static pressure (P0) may be wrong." },
        uyari_dusukR2: { tr: "Uyum kalitesi düşük (R² < 0.90): noktalar doğrudan çok sapıyor.", en: "Low fit quality (R² < 0.90): points scatter strongly around the line." },
        uyari_darDebiAraligi: { tr: "Debi aralığı dar: farklı ağırlıklarla stroke atın, aksi halde eğim güvenilir değil.", en: "Flow range too narrow: use different weights, otherwise the slope is unreliable." },
        uyari_yukBasinaAzStroke: { tr: "Bazı yüklerde 3'ten az geçerli stroke var; kılavuz her yük için en az 3 stroke önerir.", en: "Some loads have fewer than 3 valid strokes; the manual recommends at least 3 strokes per load." },
        uyari_tekYuk: { tr: "Tüm stroke'lar aynı ağırlıkla atılmış: en az iki farklı yük kullanın.", en: "All strokes used the same weight: use at least two different loads." },
        uyari_cokGecersiz: { tr: "Stroke'ların %30'undan fazlası hatalı: boru sıkışması veya ayrışma belirtisi olabilir.", en: "More than 30% of strokes are invalid: possible pipe jamming or segregation." },
        tahminAyarlari: { tr: "TAHMİN AYARLARI", en: "FORECAST PREFERENCES" },
        q1: { tr: "Q1 (m³/h)", en: "Q1 (m³/h)" },
        q2: { tr: "Q2 (m³/h)", en: "Q2 (m³/h)" },
        cap: { tr: "Boru çapı D (mm)", en: "Pipe diameter D (mm)" },
        l2: { tr: "L2 (m)", en: "L2 (m)" },
        l3: { tr: "L3 (m)", en: "L3 (m)" },
        l4: { tr: "L4 (m)", en: "L4 (m)" },
        yukseklik: { tr: "Pompalama yüks. h (m)", en: "Pumping head h (m)" },
        yogunluk: { tr: "Yoğunluk ρ (kg/m³)", en: "Density ρ (kg/m³)" },
        hataPayi: { tr: "Hata payı (%)", en: "Error bar tol. (%)" },
        pompaMaks: { tr: "Pompa maks. (bar)", en: "Pump max. (bar)" },
        pompaIpucu: { tr: "tipik 85–130, yüksek basınç 200–250. h negatif = aşağı pompalama.", en: "typical 85–130, high pressure 200–250. Negative h = pumping downward." },
        hesaplaKaydet: { tr: "Tahmini Hesapla ve Kaydet", en: "Calculate and Save Forecast" },
        gecersizGirdi: { tr: "Geçersiz değer: tüm alanlar sayı olmalı, D > 0.", en: "Invalid value: all fields must be numbers, D > 0." },
        kaydedildi: { tr: "✓ Tahmin ayarları kaydedildi", en: "✓ Forecast preferences saved" },
        pompalanabilir: { tr: "POMPALANABİLİR", en: "PUMPABLE" },
        pompalamaSorunu: { tr: "POMPALAMA SORUNU", en: "PUMPING ISSUE" },
        degerlendirilmedi: { tr: "DEĞERLENDİRİLMEDİ", en: "NOT EVALUATED" },
        durumYetersizVeri: { tr: "Yeterli stroke verisi yok.", en: "Not enough stroke data." },
        durumPompaYok: { tr: "Pompalanabilirlik kararı için pompa maks. basıncını girip tahmini hesaplayın.", en: "Enter the pump max. pressure and calculate the forecast to evaluate pumpability." },
        durumUygun: { tr: "Tüm durumlarda uygun. En yüksek tahmin %1 bar (Q = %2 m³/h, L = %3 m), pompa kapasitesi kullanımı %%4.", en: "Suitable in all cases. Highest estimate %1 bar (Q = %2 m³/h, L = %3 m), %4% of pump capacity." },
        durumAkma: { tr: "%1 durumda kapasite aşılıyor (en yüksek %2 bar). Basıncın çoğu akma (A) teriminden geliyor: süperakışkanlaştırıcı veya ince malzeme/pasta miktarını artırmayı, daha kısa/geniş hattı değerlendirin.", en: "Capacity exceeded in %1 case(s) (highest %2 bar). Mostly from the yield (A) term: consider more superplasticizer or fines/paste, or a shorter/wider line." },
        durumViskoz: { tr: "%1 durumda kapasite aşılıyor (en yüksek %2 bar). Basıncın çoğu viskoz (B) terimden geliyor: debiyi düşürmeyi, daha geniş boruyu veya daha düşük viskoziteli karışımı değerlendirin.", en: "Capacity exceeded in %1 case(s) (highest %2 bar). Mostly from the viscous (B) term: consider a lower flow rate, a wider pipe or a less viscous mix." },
        durumYukseklik: { tr: "%1 durumda kapasite aşılıyor (en yüksek %2 bar). Basıncın çoğu pompalama yüksekliğinden (ρ·g·h) geliyor: daha yüksek basınçlı pompa gerekir.", en: "Capacity exceeded in %1 case(s) (highest %2 bar). Mostly from the pumping head (ρ·g·h): a higher-pressure pump is required." },
        pdfRaporOnizle: { tr: "📄  PDF Rapor Önizle", en: "📄  Preview PDF Report" },
        excelCsvOnizle: { tr: "📊  Excel (CSV) Önizle", en: "📊  Preview Excel (CSV)" },
        excelXmlDisaAktar: { tr: "📑  Excel (XML) Dışa Aktar", en: "📑  Export Excel (XML)" },
        disaAktarildi: { tr: "✓ Dışa aktarıldı: ", en: "✓ Exported: " },
        disaAktarilamadi: { tr: "✕ Dışa aktarılamadı", en: "✕ Export failed" },
        sekmePq: { tr: "P–Q Grafiği", en: "p–Q Chart" },
        sekmeTablo: { tr: "Stroke Tablosu", en: "Table of Strokes" },
        sekmeEgri: { tr: "Stroke Eğrileri", en: "Stroke Curves" },
        sekmeTahminTablo: { tr: "Tahmin Tablosu", en: "Forecast Table" },
        sekmeTahminGrafik: { tr: "Tahmin Grafiği", en: "Forecast Chart" },
        dahilNokta: { tr: "Tahmine dahil", en: "In forecast" },
        haricNokta: { tr: "Hariç / hatalı", en: "Excluded / wrong" },
        regresyon: { tr: "Regresyon", en: "Regression" },
        oynat: { tr: "▶ Oynat", en: "▶ Play" },
        durdur: { tr: "⏸ Durdur", en: "⏸ Pause" },
        tabloIpucu: { tr: "Kutucuk: stroke'u tahmine dahil et / çıkar. Satıra tıkla: seç, çift tıkla: eğrisini aç. Hatalı stroke'lar otomatik hariç tutulur.", en: "Checkbox: include / exclude the stroke from the forecast. Click a row to select, double-click to open its curve. Wrong strokes are excluded automatically." },
        no: { tr: "No", en: "No" },
        saat: { tr: "Saat", en: "Time" },
        sure: { tr: "Süre s", en: "Dur. s" },
        agirlik: { tr: "Ağırlık kg", en: "Weight kg" },
        durum: { tr: "Durum", en: "Status" },
        dahil: { tr: "Dahil", en: "Included" },
        haric: { tr: "Hariç", en: "Excluded" },
        hatali: { tr: "Wrong Stroke", en: "Wrong Stroke" },
        strokeYok: { tr: "Bu ölçümde stroke yok", en: "No strokes in this measurement" },
        strokeSilSoru: { tr: "Stroke %1 kalıcı olarak silinsin mi? Bu işlem geri alınamaz.", en: "Delete stroke %1 permanently? This cannot be undone." },
        sil: { tr: "Sil", en: "Delete" },
        vazgec: { tr: "Vazgeç", en: "Cancel" },
        kaydet: { tr: "Kaydet", en: "Save" },
        basincEgrisi: { tr: "Basınç Eğrisi", en: "Pressure Curve" },
        konumHizEgrisi: { tr: "Mesafe ve Hız Eğrisi", en: "Distance and Speed Curve" },
        hamVeriYok: { tr: "Bu stroke için ham eğri verisi yok (eski sürümle kaydedilmiş).", en: "No raw curve data for this stroke (saved with an older version)." },
        zaman: { tr: "Zaman (s)", en: "Time (s)" },
        basinc: { tr: "Basınç (mbar)", en: "Pressure (mbar)" },
        mesafe: { tr: "Mesafe (mm)", en: "Distance (mm)" },
        hiz: { tr: "Hız (m/s)", en: "Speed (m/s)" },
        debi: { tr: "Debi Q (m³/h)", en: "Flow Q (m³/h)" },
        uzunluk: { tr: "Uzunluk L (m)", en: "Length L (m)" },
        basincBar: { tr: "P (bar)", en: "P (bar)" },
        aralik: { tr: "Alt – Üst (bar)", en: "Lower – Upper (bar)" },
        pompa: { tr: "Pompa", en: "Pump" },
        uygun: { tr: "uygun", en: "ok" },
        asildi: { tr: "aşıldı", en: "exceeded" },
        tahminYok: { tr: "Tahmin için en az 2 geçerli stroke gerekir.", en: "At least 2 valid strokes are required for a forecast." },
        modelNotu: { tr: "Model: P = 4L/D·a + 16·L·Q/(π·D³)·b + ρ·g·h   (a = d·A/4l, b = B·π·d³/16l;  d = %1 mm, l = %2 mm). Hata payı sürtünme kısmına uygulanır.", en: "Model: P = 4L/D·a + 16·L·Q/(π·D³)·b + ρ·g·h   (a = d·A/4l, b = B·π·d³/16l;  d = %1 mm, l = %2 mm). The error tolerance applies to the friction part." },
        tahmin: { tr: "Tahmin", en: "Forecast" },
        pompaCizgi: { tr: "Pompa maks.", en: "Pump max." },
        olcumBilgisi: { tr: "Ölçüm Bilgileri", en: "Measurement Information" },
        pdfRaporOnizlemeBaslik: { tr: "PDF Rapor Önizleme", en: "PDF Report Preview" },
        indirPdf: { tr: "💾  İndir (PDF)", en: "💾  Download (PDF)" },
        pdfKaydedildi: { tr: "PDF kaydedildi: ", en: "PDF saved: " },
        pdfOlusturulamadi: { tr: "PDF oluşturulamadı.", en: "Could not generate PDF." },
        kapat: { tr: "Kapat", en: "Close" },
        excelCsvOnizlemeBaslik: { tr: "Excel (CSV) Önizleme", en: "Excel (CSV) Preview" },
        indirCsv: { tr: "💾  İndir (CSV)", en: "💾  Download (CSV)" },
        csvKaydedildi: { tr: "CSV kaydedildi: ", en: "CSV saved: " },
        csvOlusturulamadi: { tr: "CSV oluşturulamadı.", en: "Could not generate CSV." },
        olcumSecilmedi: { tr: "Geçmiş sayfasından bir ölçüm seçin veya yeni bir ölçüm tamamlayın.", en: "Select a measurement from History or complete a new measurement." }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    // Sayıyı virgülden sonra "basamak" haneyle yazar; değer yoksa "—"
    function sayi(deger, basamak) {
        return (deger === undefined || deger === null || isNaN(deger)) ? "—" : Number(deger).toFixed(basamak)
    }

    // Schleibinger dönüşümü: formül ve geometri C++ tarafındaki SliperModel.h'den gelir
    function schleibingerA(kesisimA) { return calculator.schleibingerA(kesisimA) }
    function schleibingerB(egimB) { return calculator.schleibingerB(egimB) }

    onOlcumIdChanged: verileriYukle()
    Component.onCompleted: verileriYukle()
    onVisibleChanged: if (visible) verileriYukle()

    function verileriYukle() {
        playbackTimer.stop()
        playbackAdimi = -1
        if (olcumId <= 0) {
            bilgi = ({})
            strokeListesi = []
            tahminSatirlari = []
            return
        }
        bilgi = database.olcumBilgisiGetir(olcumId)
        sonuc = database.binghamHesapla(olcumId)
        strokeListesi = database.strokeVerileriGetir(olcumId)
        tahminAyarlari = database.tahminAyarlariGetir(olcumId)
        ayarAlanlariniDoldur()
        if (seciliStrokeIndex >= strokeListesi.length || seciliStrokeIndex < 0)
            seciliStrokeIndex = strokeListesi.length > 0 ? 0 : -1
        pqGrafiginiCiz()
        tahminiGuncelle()
        strokeEgrisiniCiz()
    }

    // --------------------------------------------------------------- P-Q grafiği
    function pqGrafiginiCiz() {
        pqDahil.clear()
        pqHaric.clear()
        pqDogru.clear()
        oynatmaIsaretci.clear()
        var enBuyukDebi = 5, enBuyukBasinc = 10, enKucukBasinc = 0
        for (var i = 0; i < strokeListesi.length; i++) {
            var stroke = strokeListesi[i]
            if (stroke.gecerli && stroke.secili) pqDahil.append(stroke.debi, stroke.basinc)
            else pqHaric.append(stroke.debi, stroke.basinc)
            enBuyukDebi = Math.max(enBuyukDebi, stroke.debi)
            enBuyukBasinc = Math.max(enBuyukBasinc, stroke.basinc)
            enKucukBasinc = Math.min(enKucukBasinc, stroke.basinc)
        }
        if (sonuc.yeterliVeri) {
            // p = A + B*Q çizgisi ("tau0" = A kesişim, "mu" = B eğim)
            var kesisimA = sonuc.tau0, egimB = sonuc.mu
            var cizgiSonuDebi = enBuyukDebi * 1.1
            var cizgiSonuBasinc = kesisimA + egimB * cizgiSonuDebi
            pqDogru.append(0, kesisimA)
            pqDogru.append(cizgiSonuDebi, cizgiSonuBasinc)
            enBuyukBasinc = Math.max(enBuyukBasinc, cizgiSonuBasinc)
            enKucukBasinc = Math.min(enKucukBasinc, kesisimA)
        }
        pqQEkseni.max = Math.ceil(enBuyukDebi * 1.15)
        pqPEkseni.min = Math.floor(enKucukBasinc * 1.1)
        pqPEkseni.max = Math.ceil(enBuyukBasinc * 1.15)
    }

    // --------------------------------------------------------------- Tahmin
    function ayarAlanlariniDoldur() {
        var ayar = tahminAyarlari
        q1Alani.metin = ayar.q1; q2Alani.metin = ayar.q2; capAlani.metin = ayar.cap
        l2Alani.metin = ayar.l2; l3Alani.metin = ayar.l3; l4Alani.metin = ayar.l4
        yukseklikAlani.metin = ayar.yukseklik; yogunlukAlani.metin = ayar.yogunluk
        hataAlani.metin = ayar.hataPayi
        pompaAlani.metin = ayar.pompaMaks > 0 ? ayar.pompaMaks : ""
        ayarBildirimi.text = ""
    }

    function ayarlariKaydet() {
        var alanlar = { q1: q1Alani, q2: q2Alani, cap: capAlani, l2: l2Alani, l3: l3Alani, l4: l4Alani,
                        yukseklik: yukseklikAlani, yogunluk: yogunlukAlani, hataPayi: hataAlani }
        var yeni = {}
        for (var anahtar in alanlar) {
            var deger = parseFloat(String(alanlar[anahtar].metin).replace(",", "."))
            if (isNaN(deger)) { ayarBildirimi.hata = true; ayarBildirimi.text = txt("gecersizGirdi"); return }
            yeni[anahtar] = deger
        }
        var pompa = parseFloat(String(pompaAlani.metin).replace(",", "."))
        yeni.pompaMaks = (isNaN(pompa) || pompa < 0) ? 0 : pompa
        if (yeni.cap <= 0 || yeni.q1 < 0 || yeni.q2 < 0 || yeni.l2 < 0 || yeni.l3 < 0 || yeni.l4 < 0 || yeni.yogunluk < 0) {
            ayarBildirimi.hata = true; ayarBildirimi.text = txt("gecersizGirdi"); return
        }
        yeni.hataPayi = Math.max(0, Math.min(100, yeni.hataPayi))
        if (database.tahminAyarlariKaydet(olcumId, yeni)) {
            tahminAyarlari = database.tahminAyarlariGetir(olcumId)
            ayarBildirimi.hata = false
            ayarBildirimi.text = txt("kaydedildi")
            tahminiGuncelle()
        }
    }

    function tahminiGuncelle() {
        tahminSatirlari = sonuc.yeterliVeri
            ? calculator.tahminTablosuHesapla(sonuc.tau0, sonuc.mu, tahminAyarlari) : []
        tahminGrafiginiCiz()
    }

    function tahminGrafiginiCiz() {
        var cizgiler = [tahminL2, tahminL3, tahminL4]
        var cubuklar = [hc0, hc1, hc2, hc3, hc4, hc5]
        for (var i = 0; i < cizgiler.length; i++) cizgiler[i].clear()
        for (i = 0; i < cubuklar.length; i++) cubuklar[i].clear()
        pompaCizgisi.clear()
        if (!sonuc.yeterliVeri) return
        var ayar = tahminAyarlari
        var kesisimA = sonuc.tau0, egimB = sonuc.mu
        function tahminEt(debi, hatUzunlugu) {
            return calculator.boruHattiTahminHesapla(kesisimA, egimB, debi, ayar.cap, hatUzunlugu,
                                                     ayar.yukseklik, ayar.yogunluk, ayar.hataPayi)
        }
        var grafikSonuDebi = Math.max(ayar.q1, ayar.q2, 1) * 1.1
        var hatUzunluklari = [ayar.l2, ayar.l3, ayar.l4]
        var debiler = [ayar.q1, ayar.q2]
        var enBuyukBasinc = 1, enKucukBasinc = 0
        for (i = 0; i < 3; i++) {
            // Tahmin Q'ya göre düz çizgidir: iki uç nokta yeter
            var sifirDebide = tahminEt(0, hatUzunluklari[i])
            var grafikSonunda = tahminEt(grafikSonuDebi, hatUzunluklari[i])
            cizgiler[i].append(0, sifirDebide.basincBar)
            cizgiler[i].append(grafikSonuDebi, grafikSonunda.basincBar)
            enBuyukBasinc = Math.max(enBuyukBasinc, grafikSonunda.ustSinirBar, sifirDebide.ustSinirBar)
            enKucukBasinc = Math.min(enKucukBasinc, sifirDebide.altSinirBar, grafikSonunda.altSinirBar)
            // Q1 ve Q2'de hata payı çubukları
            for (var j = 0; j < 2; j++) {
                var tahmin = tahminEt(debiler[j], hatUzunluklari[i])
                if (ayar.hataPayi > 0) {
                    cubuklar[i * 2 + j].append(debiler[j], tahmin.altSinirBar)
                    cubuklar[i * 2 + j].append(debiler[j], tahmin.ustSinirBar)
                }
            }
        }
        if (ayar.pompaMaks > 0) {
            pompaCizgisi.append(0, ayar.pompaMaks)
            pompaCizgisi.append(grafikSonuDebi, ayar.pompaMaks)
            enBuyukBasinc = Math.max(enBuyukBasinc, ayar.pompaMaks)
        }
        tgQEkseni.max = Math.ceil(grafikSonuDebi)
        tgPEkseni.min = Math.floor(enKucukBasinc * 1.1)
        tgPEkseni.max = Math.ceil(enBuyukBasinc * 1.1)
    }

    // Pompalanabilirlik: tablodaki en kötü durum (hata payı üst sınırı) pompa kapasitesiyle karşılaştırılır
    readonly property var durumBilgisi: {
        if (!sonuc.yeterliVeri) return { kod: "yetersiz" }
        var pompa = tahminAyarlari.pompaMaks || 0
        if (pompa <= 0 || tahminSatirlari.length === 0) return { kod: "yok" }
        var enKotu = tahminSatirlari[0], asilan = 0
        for (var i = 0; i < tahminSatirlari.length; i++) {
            var satir = tahminSatirlari[i]
            if (satir.ustSinirBar > enKotu.ustSinirBar) enKotu = satir
            if (satir.pompaAsildi) asilan++
        }
        var baskin = "akma"
        if (enKotu.viskozMbar > enKotu.akmaMbar && enKotu.viskozMbar >= enKotu.yukseklikMbar) baskin = "viskoz"
        else if (enKotu.yukseklikMbar > enKotu.akmaMbar && enKotu.yukseklikMbar > enKotu.viskozMbar) baskin = "yukseklik"
        return { kod: asilan === 0 ? "uygun" : "sorun", enKotu: enKotu, asilan: asilan, pompa: pompa, baskin: baskin }
    }

    // --------------------------------------------------------------- Stroke eğrisi
    function strokeEgrisiniCiz() {
        var seriler = [egriBasinc, egriP0l, egriP0r, egriPmaks, egriBaslangic, egriBitis, egriKonum, egriHiz, egriBaslangic2, egriBitis2]
        for (var i = 0; i < seriler.length; i++) seriler[i].clear()
        egriVeriYok.visible = false
        if (seciliStrokeIndex < 0 || seciliStrokeIndex >= strokeListesi.length) return
        var stroke = strokeListesi[seciliStrokeIndex]
        var hamVeri = database.strokeHamVeriGetir(stroke.id)
        if (!hamVeri.t || hamVeri.t.length < 2) { egriVeriYok.visible = true; return }
        var zamanlar = hamVeri.t, konumlar = hamVeri.x, basinclar = hamVeri.p
        var ornekSayisi = zamanlar.length
        var sonZaman = zamanlar[ornekSayisi - 1]
        var enKucukBasinc = 1e9, enBuyukBasinc = -1e9, enBuyukKonum = 10, enBuyukHiz = 0.1
        for (i = 0; i < ornekSayisi; i++) {
            egriBasinc.append(zamanlar[i], basinclar[i])
            egriKonum.append(zamanlar[i], konumlar[i])
            enKucukBasinc = Math.min(enKucukBasinc, basinclar[i])
            enBuyukBasinc = Math.max(enBuyukBasinc, basinclar[i])
            enBuyukKonum = Math.max(enBuyukKonum, konumlar[i])
        }
        // Hız eğrisi (orijinal "Speed"): hesap SliperModel bölüm 10'da.
        // Yalnızca grafik içindir; stroke hızı ayrıca (bölüm 5) hesaplanır.
        var konumYonu = hamVeri.yon || 1   // -1: konum "sensörden uzaklık"
        var hizlar = calculator.hizEgrisiHesapla(zamanlar, konumlar, konumYonu)
        for (i = 0; i < hizlar.length; i++) {
            egriHiz.append(zamanlar[i], hizlar[i])
            enBuyukHiz = Math.max(enBuyukHiz, hizlar[i])
        }
        egriP0l.append(0, stroke.p0l); egriP0l.append(hamVeri.tBaslangic, stroke.p0l)
        egriP0r.append(hamVeri.tBitis, stroke.p0r); egriP0r.append(sonZaman, stroke.p0r)
        egriPmaks.append(hamVeri.tBaslangic, stroke.pMaks); egriPmaks.append(hamVeri.tBitis, stroke.pMaks)
        var basincAralik = enBuyukBasinc - enKucukBasinc
        var basincEkseniAlt = Math.floor(enKucukBasinc - basincAralik * 0.1 - 1)
        var basincEkseniUst = Math.ceil(enBuyukBasinc + basincAralik * 0.15 + 1)
        egriBaslangic.append(hamVeri.tBaslangic, basincEkseniAlt); egriBaslangic.append(hamVeri.tBaslangic, basincEkseniUst)
        egriBitis.append(hamVeri.tBitis, basincEkseniAlt); egriBitis.append(hamVeri.tBitis, basincEkseniUst)
        egriBaslangic2.append(hamVeri.tBaslangic, 0); egriBaslangic2.append(hamVeri.tBaslangic, enBuyukKonum * 1.1)
        egriBitis2.append(hamVeri.tBitis, 0); egriBitis2.append(hamVeri.tBitis, enBuyukKonum * 1.1)
        egTEkseni.max = Math.ceil(sonZaman); egPEkseni.min = basincEkseniAlt; egPEkseni.max = basincEkseniUst
        egT2Ekseni.max = Math.ceil(sonZaman); egXEkseni.max = Math.ceil(enBuyukKonum * 1.1 / 10) * 10
        egVEkseni.max = Math.ceil(enBuyukHiz * 1.2 * 10) / 10
    }

    onSeciliStrokeIndexChanged: strokeEgrisiniCiz()

    function strokeDahilDegistir(id, secili) {
        database.strokeSeciliAyarla(id, secili)
        verileriYukle()
    }

    Timer {
        id: playbackTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (playbackAdimi < strokeListesi.length - 1) {
                playbackAdimi++
                var s = strokeListesi[playbackAdimi]
                oynatmaIsaretci.clear()
                oynatmaIsaretci.append(s.debi, s.basinc)
            } else {
                stop()
            }
        }
    }

    // --------------------------------------------------------------- Bileşenler
    component Kart: Rectangle {
        radius: 10
        color: "#0a0a0d"
        border.color: "#1e2a3f"
        border.width: 1
    }

    component KartBaslik: Text {
        color: "#6b7280"
        font.family: "Segoe UI"
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 1
    }

    component Girdi: Column {
        id: girdiKoku
        property string etiket: ""
        property alias metin: alan.text
        property string ipucu: ""
        spacing: 2
        Text { text: girdiKoku.etiket; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 10 }
        TextField {
            id: alan
            width: girdiKoku.width
            height: 28
            color: "#dce8f5"
            font.pixelSize: 12
            leftPadding: 8
            placeholderText: girdiKoku.ipucu
            placeholderTextColor: "#4b5563"
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            background: Rectangle {
                color: "#07070a"
                radius: 5
                border.color: alan.activeFocus ? "#3b82f6" : "#1e2a3f"
                border.width: 1
            }
        }
    }

    component Dugme: Button {
        id: dugmeKoku
        property color renk: "#3b82f6"
        height: 36
        font.pixelSize: 12
        font.bold: true
        background: Rectangle {
            radius: 8
            color: dugmeKoku.enabled ? (dugmeKoku.hovered ? Qt.lighter(dugmeKoku.renk, 1.15) : dugmeKoku.renk) : "#1e2a3f"
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        contentItem: Text {
            text: dugmeKoku.text
            color: dugmeKoku.enabled ? "#dce8f5" : "#6b7280"
            font: dugmeKoku.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    component DegerSatiri: Item {
        id: satirKoku
        property string etiket: ""
        property string deger: "—"
        property color cizgi: "#3b82f6"
        height: 34
        Rectangle { width: 3; height: satirKoku.height - 8; anchors.verticalCenter: parent.verticalCenter; color: satirKoku.cizgi; radius: 2 }
        Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: satirKoku.etiket; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 10 }
        Text { anchors.right: parent.right; anchors.rightMargin: 4; anchors.verticalCenter: parent.verticalCenter; text: satirKoku.deger; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true }
    }

    component Hucre: Text {
        color: "#dce8f5"
        font.family: "Segoe UI"
        font.pixelSize: 12
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component BaslikHucre: Text {
        color: "#6b7280"
        font.family: "Segoe UI"
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 0.5
        elide: Text.ElideRight
    }

    component Eksen: ValueAxis {
        gridLineColor: "#1a1a20"
        labelsColor: "#6b7280"
        labelsFont.pixelSize: 9
        titleFont.pixelSize: 10
        lineVisible: false
        minorGridVisible: false
    }

    component PopupArka: Rectangle {
        color: "#12121a"
        radius: 12
        border.color: "#1e2a3f"
        border.width: 1
    }

    // --------------------------------------------------------------- Yerleşim
    Row {
        anchors.fill: parent
        spacing: 0

        // ======================= SOL PANEL =======================
        Rectangle {
            id: solPanel
            width: 300
            height: parent.height
            color: "#12121a"

            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: "#1e2a3f" }

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentWidth: width
                contentHeight: solIcerik.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: solIcerik
                    width: parent.width
                    spacing: 10

                    // --- Başlık / ölçüm bilgisi ---
                    Item {
                        width: parent.width
                        height: 16
                        KartBaslik { anchors.left: parent.left; text: txt("sonucOzeti") }
                        Text {
                            anchors.right: parent.right
                            text: txt("duzenle")
                            color: olcumId > 0 ? "#4f8cf7" : "#374151"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            MouseArea {
                                anchors.fill: parent
                                enabled: olcumId > 0
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bilgiPopup.ac()
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 2
                        Text {
                            width: parent.width
                            text: bilgi.musteri ? bilgi.musteri : "—"
                            color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 16; font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: (bilgi.recete ? bilgi.recete : "—") + (bilgi.tarih ? "  ·  " + bilgi.tarih : "")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11; elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            visible: !!bilgi.yer
                            text: "📍 " + (bilgi.yer || "")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11; elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            visible: !!bilgi.yorum
                            text: "💬 " + (bilgi.yorum || "")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11; wrapMode: Text.WordWrap
                        }
                    }

                    Text {
                        width: parent.width
                        visible: olcumId <= 0
                        text: txt("olcumSecilmedi")
                        color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 12; wrapMode: Text.WordWrap
                    }

                    // --- P-Q sonuçları ---
                    Kart {
                        width: parent.width
                        height: sonucSutunu.implicitHeight + 16
                        visible: olcumId > 0
                        Column {
                            id: sonucSutunu
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: 8
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("kesisimA"); deger: sonuc.yeterliVeri ? sayi(sonuc.tau0, 2) + " mbar" : "—"; cizgi: "#3b82f6" }
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("egimB"); deger: sonuc.yeterliVeri ? sayi(sonuc.mu, 3) + " mbar·h/m³" : "—"; cizgi: "#9333ea" }
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("yieldA"); deger: sonuc.yeterliVeri ? sayi(schleibingerA(sonuc.tau0), 3) + " mbar" : "—"; cizgi: "#2563eb" }
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("gradyanB"); deger: sonuc.yeterliVeri ? sayi(schleibingerB(sonuc.mu) * 1000, 3) : "—"; cizgi: "#7c3aed" }
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("uyumKalitesi"); deger: sonuc.yeterliVeri ? sayi(sonuc.r2, 3) : "—"; cizgi: "#16a34a" }
                            DegerSatiri { width: sonucSutunu.width; etiket: txt("kullanilanStroke"); deger: (sonuc.n || 0) + " / " + (sonuc.toplamStroke || 0); cizgi: "#6b7280" }
                        }
                    }

                    // --- Kalite uyarıları ---
                    Kart {
                        width: parent.width
                        height: uyariSutunu.implicitHeight + 20
                        visible: olcumId > 0 && sonuc.uyarilar !== undefined && sonuc.uyarilar.length > 0
                        border.color: "#78350f"
                        Column {
                            id: uyariSutunu
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: 10
                            spacing: 6
                            KartBaslik { text: "⚠ " + txt("uyarilarBaslik"); color: "#f59e0b" }
                            Repeater {
                                model: sonuc.uyarilar || []
                                Text {
                                    width: uyariSutunu.width
                                    text: "• " + (metinler["uyari_" + modelData] ? txt("uyari_" + modelData) : modelData)
                                    color: "#fbbf24"; font.family: "Segoe UI"; font.pixelSize: 11; wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // --- Tahmin ayarları (orijinal "Forecast Preferences") ---
                    Kart {
                        width: parent.width
                        height: ayarSutunu.implicitHeight + 20
                        visible: olcumId > 0
                        Column {
                            id: ayarSutunu
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: 10
                            spacing: 8
                            KartBaslik { text: txt("tahminAyarlari") }
                            Grid {
                                id: ayarIzgarasi
                                width: parent.width
                                columns: 2
                                columnSpacing: 8
                                rowSpacing: 6
                                readonly property real hucre: (width - columnSpacing) / 2
                                Girdi { id: q1Alani; width: ayarIzgarasi.hucre; etiket: txt("q1") }
                                Girdi { id: q2Alani; width: ayarIzgarasi.hucre; etiket: txt("q2") }
                                Girdi { id: capAlani; width: ayarIzgarasi.hucre; etiket: txt("cap") }
                                Girdi { id: hataAlani; width: ayarIzgarasi.hucre; etiket: txt("hataPayi") }
                                Girdi { id: l2Alani; width: ayarIzgarasi.hucre; etiket: txt("l2") }
                                Girdi { id: l3Alani; width: ayarIzgarasi.hucre; etiket: txt("l3") }
                                Girdi { id: l4Alani; width: ayarIzgarasi.hucre; etiket: txt("l4") }
                                Girdi { id: yukseklikAlani; width: ayarIzgarasi.hucre; etiket: txt("yukseklik") }
                                Girdi { id: yogunlukAlani; width: ayarIzgarasi.hucre; etiket: txt("yogunluk") }
                                Girdi { id: pompaAlani; width: ayarIzgarasi.hucre; etiket: txt("pompaMaks"); ipucu: "85–130" }
                            }
                            Text { width: parent.width; text: txt("pompaIpucu"); color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 9; wrapMode: Text.WordWrap }
                            Dugme {
                                width: parent.width
                                text: txt("hesaplaKaydet")
                                onClicked: ayarlariKaydet()
                            }
                            Text {
                                id: ayarBildirimi
                                property bool hata: false
                                width: parent.width
                                visible: text.length > 0
                                color: hata ? "#f87171" : "#4ade80"
                                font.family: "Segoe UI"; font.pixelSize: 11; wrapMode: Text.WordWrap
                            }
                        }
                    }

                    // --- Pompalanabilirlik durumu ---
                    Kart {
                        id: durumKutusu
                        width: parent.width
                        height: durumSutunu.implicitHeight + 20
                        visible: olcumId > 0
                        property color vurgu: durumBilgisi.kod === "uygun" ? "#16a34a" : (durumBilgisi.kod === "sorun" ? "#dc2626" : "#6b7280")
                        border.color: Qt.darker(vurgu, 1.6)
                        Rectangle { width: 4; height: parent.height; radius: 2; color: durumKutusu.vurgu }
                        Column {
                            id: durumSutunu
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: 10; anchors.leftMargin: 16
                            spacing: 4
                            Text {
                                text: durumBilgisi.kod === "uygun" ? "✓ " + txt("pompalanabilir")
                                      : (durumBilgisi.kod === "sorun" ? "! " + txt("pompalamaSorunu") : "? " + txt("degerlendirilmedi"))
                                color: durumKutusu.vurgu; font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 1
                            }
                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 11
                                text: {
                                    var d = durumBilgisi
                                    if (d.kod === "yetersiz") return txt("durumYetersizVeri")
                                    if (d.kod === "yok") return txt("durumPompaYok")
                                    var bar = sayi(d.enKotu.ustSinirBar, 1)
                                    if (d.kod === "uygun")
                                        return txt("durumUygun").arg(bar).arg(sayi(d.enKotu.debi, 1)).arg(sayi(d.enKotu.uzunluk, 0))
                                                                .arg(sayi(d.enKotu.ustSinirBar / d.pompa * 100, 0))
                                    var anahtar = d.baskin === "viskoz" ? "durumViskoz" : (d.baskin === "yukseklik" ? "durumYukseklik" : "durumAkma")
                                    return txt(anahtar).arg(d.asilan).arg(bar)
                                }
                            }
                        }
                    }

                    // --- Dışa aktarım ---
                    Dugme {
                        width: parent.width
                        text: txt("pdfRaporOnizle")
                        enabled: olcumId > 0
                        onClicked: {
                            pdfOnizlemePopup.onizlemeHtml = reportManager.pdfOnizlemeHtml(olcumId)
                            pdfOnizlemePopup.open()
                        }
                    }
                    Dugme {
                        width: parent.width
                        text: txt("excelCsvOnizle")
                        renk: "#16a34a"
                        enabled: olcumId > 0
                        onClicked: csvOnizlemePopup.open()
                    }
                    Dugme {
                        width: parent.width
                        text: txt("excelXmlDisaAktar")
                        renk: "#0d9488"
                        enabled: olcumId > 0
                        onClicked: {
                            var yol = database.xmlDisaAktar(olcumId)
                            bildirimKutusu.goster(yol.length > 0 ? txt("disaAktarildi") + yol : txt("disaAktarilamadi"), yol.length === 0)
                        }
                    }
                    Item { width: 1; height: 8 }
                }
            }
        }

        // ======================= SAĞ ALAN =======================
        Item {
            width: parent.width - solPanel.width
            height: parent.height

            Row {
                id: sekmeler
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
                spacing: 6
                Repeater {
                    model: ["sekmePq", "sekmeTablo", "sekmeEgri", "sekmeTahminTablo", "sekmeTahminGrafik"]
                    Rectangle {
                        width: sekmeMetni.implicitWidth + 28
                        height: 34
                        radius: 8
                        color: aktifSekme === index ? "#17263d" : (sekmeFare.containsMouse ? "#141419" : "#12121a")
                        border.color: aktifSekme === index ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                        Text {
                            id: sekmeMetni
                            anchors.centerIn: parent
                            text: txt(modelData)
                            color: aktifSekme === index ? "#dce8f5" : "#9ca3af"
                            font.family: "Segoe UI"; font.pixelSize: 12; font.bold: aktifSekme === index
                        }
                        MouseArea {
                            id: sekmeFare
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: aktifSekme = index
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: sekmeler.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 16
                anchors.topMargin: 10
                radius: 10
                color: "#12121a"
                border.color: "#1e2a3f"
                border.width: 1

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    currentIndex: aktifSekme

                    // ---------------- 0: P-Q grafiği ----------------
                    Item {
                        Item {
                            id: pqUstBilgi
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: sonuc.yeterliVeri
                                      ? "A = " + sayi(sonuc.tau0, 2) + " mbar    B = " + sayi(sonuc.mu, 3) + " mbar·h/m³    a = "
                                        + sayi(schleibingerA(sonuc.tau0), 3) + " mbar    b = " + sayi(schleibingerB(sonuc.mu) * 1000, 3)
                                        + "    R² = " + sayi(sonuc.r2, 3)
                                      : txt("tahminYok")
                                color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12
                            }
                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: playbackAdimi >= 0
                                    text: "Stroke " + (playbackAdimi + 1) + " / " + strokeListesi.length
                                    color: "#f59e0b"; font.family: "Segoe UI"; font.pixelSize: 12
                                }
                                Dugme {
                                    width: 100; height: 28
                                    text: playbackTimer.running ? txt("durdur") : txt("oynat")
                                    enabled: strokeListesi.length > 0
                                    onClicked: {
                                        if (playbackTimer.running) { playbackTimer.stop(); return }
                                        if (playbackAdimi >= strokeListesi.length - 1) playbackAdimi = -1
                                        playbackTimer.start()
                                    }
                                }
                            }
                        }

                        ChartView {

                            theme: ChartView.ChartThemeDark
                            anchors.top: pqUstBilgi.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            backgroundColor: "transparent"
                            antialiasing: true
                            legend.visible: true
                            legend.labelColor: "#9ca3af"
                            legend.alignment: Qt.AlignBottom

                            Eksen { id: pqQEkseni; min: 0; max: 20; titleText: txt("debi") }
                            Eksen { id: pqPEkseni; min: 0; max: 100; titleText: "p (mbar)" }

                            ScatterSeries { id: pqDahil; name: txt("dahilNokta"); axisX: pqQEkseni; axisY: pqPEkseni; color: "#3b82f6"; borderColor: "#1d4ed8"; markerSize: 11 }
                            ScatterSeries { id: pqHaric; name: txt("haricNokta"); axisX: pqQEkseni; axisY: pqPEkseni; color: "#4b5563"; borderColor: "#6b7280"; markerSize: 9 }
                            LineSeries { id: pqDogru; name: txt("regresyon"); axisX: pqQEkseni; axisY: pqPEkseni; color: "#dce8f5"; width: 2 }
                            ScatterSeries { id: oynatmaIsaretci; name: "▶"; axisX: pqQEkseni; axisY: pqPEkseni; color: "#f59e0b"; borderColor: "#f59e0b"; markerSize: 18 }
                        }
                    }

                    // ---------------- 1: Stroke tablosu ----------------
                    Item {
                        id: tabloSekmesi
                        readonly property var kolonlar: [0.05, 0.05, 0.1, 0.07, 0.08, 0.08, 0.08, 0.08, 0.09, 0.09, 0.19, 0.04]

                        Text {
                            id: tabloIpucu
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: txt("tabloIpucu")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11; wrapMode: Text.WordWrap
                        }

                        Row {
                            id: tabloBasligi
                            anchors.top: tabloIpucu.bottom
                            anchors.topMargin: 10
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 6
                            readonly property var k: tabloSekmesi.kolonlar
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[0]; text: "✓" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[1]; text: txt("no") }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[2]; text: txt("saat") }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[3]; text: txt("sure") }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[4]; text: txt("agirlik") }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[5]; text: "Pmax" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[6]; text: "P0l" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[7]; text: "P0r" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[8]; text: "p mbar" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[9]; text: "Q m³/h" }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[10]; text: txt("durum") }
                            BaslikHucre { width: tabloBasligi.width * tabloBasligi.k[11]; text: "" }
                        }

                        Rectangle { id: tabloCizgi; anchors.top: tabloBasligi.bottom; anchors.topMargin: 6; width: parent.width; height: 1; color: "#1e2a3f" }

                        Text {
                            anchors.centerIn: parent
                            visible: strokeListesi.length === 0
                            text: txt("strokeYok")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 13
                        }

                        ListView {
                            id: strokeTablosu
                            anchors.top: tabloCizgi.bottom
                            anchors.topMargin: 4
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            clip: true
                            model: strokeListesi
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                            delegate: Rectangle {
                                id: strokeSatiri
                                required property var modelData
                                required property int index
                                readonly property var s: modelData
                                readonly property var k: tabloSekmesi.kolonlar
                                width: strokeTablosu.width
                                height: 30
                                radius: 5
                                color: index === seciliStrokeIndex ? "#17263d" : (index % 2 === 0 ? "transparent" : "#0e0e14")

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: seciliStrokeIndex = strokeSatiri.index
                                    onDoubleClicked: { seciliStrokeIndex = strokeSatiri.index; aktifSekme = 2 }
                                }

                                Row {
                                    id: satirDuzeni
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    readonly property real g: width

                                    Item {
                                        width: satirDuzeni.g * strokeSatiri.k[0]; height: strokeSatiri.height
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 16; height: 16; radius: 3
                                            color: strokeSatiri.s.secili && strokeSatiri.s.gecerli ? "#1d4ed8" : "transparent"
                                            border.color: strokeSatiri.s.gecerli ? "#3b82f6" : "#374151"
                                            opacity: strokeSatiri.s.gecerli ? 1 : 0.5
                                            Text { anchors.centerIn: parent; text: strokeSatiri.s.secili && strokeSatiri.s.gecerli ? "✓" : ""; color: "#dce8f5"; font.pixelSize: 11; font.bold: true }
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -4
                                                enabled: strokeSatiri.s.gecerli
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: strokeDahilDegistir(strokeSatiri.s.id, !strokeSatiri.s.secili)
                                            }
                                        }
                                    }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[1]; height: strokeSatiri.height; text: strokeSatiri.s.stroke }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[2]; height: strokeSatiri.height; text: strokeSatiri.s.saat || "—" }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[3]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.sure, 2) }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[4]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.agirlik, 1) }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[5]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.pMaks, 1) }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[6]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.p0l, 1) }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[7]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.p0r, 1) }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[8]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.basinc, 2); font.bold: true }
                                    Hucre { width: satirDuzeni.g * strokeSatiri.k[9]; height: strokeSatiri.height; text: sayi(strokeSatiri.s.debi, 2); font.bold: true }
                                    Item {
                                        width: satirDuzeni.g * strokeSatiri.k[10]; height: strokeSatiri.height
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: durumYazisi.implicitWidth + 14; height: 20; radius: 10
                                            color: !strokeSatiri.s.gecerli ? "#2a1414" : (strokeSatiri.s.secili ? "#123321" : "#1f2937")
                                            Text {
                                                id: durumYazisi
                                                anchors.centerIn: parent
                                                text: !strokeSatiri.s.gecerli ? txt("hatali") : (strokeSatiri.s.secili ? txt("dahil") : txt("haric"))
                                                color: !strokeSatiri.s.gecerli ? "#f87171" : (strokeSatiri.s.secili ? "#4ade80" : "#9ca3af")
                                                font.pixelSize: 10; font.bold: true
                                            }
                                        }
                                    }
                                    Item {
                                        width: satirDuzeni.g * strokeSatiri.k[11]; height: strokeSatiri.height
                                        Text {
                                            anchors.centerIn: parent
                                            text: "🗑"
                                            font.pixelSize: 13
                                            opacity: silFare.containsMouse ? 1 : 0.5
                                            MouseArea {
                                                id: silFare
                                                anchors.fill: parent
                                                anchors.margins: -4
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    strokeSilPopup.strokeId = strokeSatiri.s.id
                                                    strokeSilPopup.strokeNo = strokeSatiri.s.stroke
                                                    strokeSilPopup.open()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ---------------- 2: Stroke eğrileri ----------------
                    Item {
                        Row {
                            id: egriUst
                            anchors.top: parent.top
                            anchors.left: parent.left
                            height: 30
                            spacing: 10
                            Dugme { width: 34; height: 28; text: "◀"; enabled: seciliStrokeIndex > 0; onClicked: seciliStrokeIndex-- }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: strokeListesi.length > 0 ? "Stroke " + (seciliStrokeIndex + 1) + " / " + strokeListesi.length : txt("strokeYok")
                                color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                            }
                            Dugme { width: 34; height: 28; text: "▶"; enabled: seciliStrokeIndex < strokeListesi.length - 1; onClicked: seciliStrokeIndex++ }
                            Text {
                                id: egriOzet
                                anchors.verticalCenter: parent.verticalCenter
                                readonly property bool var_: seciliStrokeIndex >= 0 && seciliStrokeIndex < strokeListesi.length
                                readonly property var s: var_ ? strokeListesi[seciliStrokeIndex] : ({})
                                text: var_ ? "Pmax " + sayi(s.pMaks, 1) + "   P0l " + sayi(s.p0l, 1) + "   P0r " + sayi(s.p0r, 1)
                                             + "   p " + sayi(s.basinc, 2) + " mbar   Q " + sayi(s.debi, 2) + " m³/h   " + sayi(s.sure, 2) + " s"
                                             + (s.gecerli ? "" : "   ✕ " + txt("hatali")) : ""
                                color: var_ && !s.gecerli ? "#f87171" : "#9ca3af"
                                font.family: "Segoe UI"; font.pixelSize: 12
                            }
                        }

                        Text {
                            id: egriVeriYok
                            anchors.centerIn: parent
                            visible: false
                            text: txt("hamVeriYok")
                            color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 13
                            z: 5
                        }

                        Column {
                            anchors.top: egriUst.bottom
                            anchors.topMargin: 6
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom

                            ChartView {

                                theme: ChartView.ChartThemeDark
                                width: parent.width
                                height: parent.height / 2
                                title: txt("basincEgrisi")
                                titleColor: "#9ca3af"
                                backgroundColor: "transparent"
                                antialiasing: true
                                legend.visible: true
                                legend.labelColor: "#9ca3af"
                                legend.alignment: Qt.AlignRight

                                Eksen { id: egTEkseni; min: 0; max: 10; titleText: txt("zaman") }
                                Eksen { id: egPEkseni; min: 0; max: 200; titleText: txt("basinc") }

                                LineSeries { id: egriBasinc; name: txt("basinc"); axisX: egTEkseni; axisY: egPEkseni; color: "#3b82f6"; width: 1.5 }
                                LineSeries { id: egriP0l; name: "P0l"; axisX: egTEkseni; axisY: egPEkseni; color: "#4ade80"; width: 2; style: Qt.DashLine }
                                LineSeries { id: egriP0r; name: "P0r"; axisX: egTEkseni; axisY: egPEkseni; color: "#14b8a6"; width: 2; style: Qt.DashLine }
                                LineSeries { id: egriPmaks; name: "Pmax"; axisX: egTEkseni; axisY: egPEkseni; color: "#f87171"; width: 2; style: Qt.DashLine }
                                LineSeries { id: egriBaslangic; name: ""; axisX: egTEkseni; axisY: egPEkseni; color: "#6b7280"; width: 1; style: Qt.DotLine }
                                LineSeries { id: egriBitis; name: ""; axisX: egTEkseni; axisY: egPEkseni; color: "#6b7280"; width: 1; style: Qt.DotLine }
                            }

                            ChartView {

                                theme: ChartView.ChartThemeDark
                                width: parent.width
                                height: parent.height / 2
                                title: txt("konumHizEgrisi")
                                titleColor: "#9ca3af"
                                backgroundColor: "transparent"
                                antialiasing: true
                                legend.visible: true
                                legend.labelColor: "#9ca3af"
                                legend.alignment: Qt.AlignRight

                                Eksen { id: egT2Ekseni; min: 0; max: 10; titleText: txt("zaman") }
                                Eksen { id: egXEkseni; min: 0; max: 600; titleText: txt("mesafe") }
                                Eksen { id: egVEkseni; min: 0; max: 1; titleText: txt("hiz") }

                                LineSeries { id: egriKonum; name: txt("mesafe"); axisX: egT2Ekseni; axisY: egXEkseni; color: "#9333ea"; width: 2 }
                                LineSeries { id: egriHiz; name: txt("hiz"); axisX: egT2Ekseni; axisYRight: egVEkseni; color: "#f59e0b"; width: 1.5 }
                                LineSeries { id: egriBaslangic2; name: ""; axisX: egT2Ekseni; axisY: egXEkseni; color: "#6b7280"; width: 1; style: Qt.DotLine }
                                LineSeries { id: egriBitis2; name: ""; axisX: egT2Ekseni; axisY: egXEkseni; color: "#6b7280"; width: 1; style: Qt.DotLine }
                            }
                        }
                    }

                    // ---------------- 3: Tahmin tablosu ----------------
                    Item {
                        Column {
                            id: tahminTabloSutunu
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                text: txt("tahmin") + "  —  D = " + sayi(tahminAyarlari.cap, 0) + " mm,  h = " + sayi(tahminAyarlari.yukseklik, 1)
                                      + " m,  ρ = " + sayi(tahminAyarlari.yogunluk, 0) + " kg/m³,  ±%" + sayi(tahminAyarlari.hataPayi, 0)
                                      + (tahminAyarlari.pompaMaks > 0 ? ",  " + txt("pompaCizgi") + " " + sayi(tahminAyarlari.pompaMaks, 0) + " bar" : "")
                                color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12
                            }

                            Text {
                                visible: tahminSatirlari.length === 0
                                text: txt("tahminYok")
                                color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 13
                            }

                            Column {
                                id: tahminTablosu
                                visible: tahminSatirlari.length > 0
                                width: Math.min(tahminTabloSutunu.width, 760)
                                spacing: 0

                                Row {
                                    width: tahminTablosu.width
                                    height: 30
                                    BaslikHucre { width: tahminTablosu.width * 0.18; text: txt("debi"); anchors.verticalCenter: parent.verticalCenter }
                                    BaslikHucre { width: tahminTablosu.width * 0.18; text: txt("uzunluk"); anchors.verticalCenter: parent.verticalCenter }
                                    BaslikHucre { width: tahminTablosu.width * 0.18; text: txt("basincBar"); anchors.verticalCenter: parent.verticalCenter }
                                    BaslikHucre { width: tahminTablosu.width * 0.28; text: txt("aralik"); anchors.verticalCenter: parent.verticalCenter }
                                    BaslikHucre { width: tahminTablosu.width * 0.18; text: txt("pompa"); anchors.verticalCenter: parent.verticalCenter }
                                }
                                Rectangle { width: tahminTablosu.width; height: 1; color: "#1e2a3f" }

                                Repeater {
                                    model: tahminSatirlari
                                    Rectangle {
                                        id: tahminSatiri
                                        required property var modelData
                                        required property int index
                                        width: tahminTablosu.width
                                        height: 34
                                        color: index % 2 === 0 ? "transparent" : "#0e0e14"
                                        readonly property bool pompaVar: tahminAyarlari.pompaMaks > 0
                                        Row {
                                            anchors.fill: parent
                                            Hucre { width: tahminTablosu.width * 0.18; height: tahminSatiri.height; text: sayi(tahminSatiri.modelData.debi, 1) }
                                            Hucre { width: tahminTablosu.width * 0.18; height: tahminSatiri.height; text: sayi(tahminSatiri.modelData.uzunluk, 0) }
                                            Hucre { width: tahminTablosu.width * 0.18; height: tahminSatiri.height; text: sayi(tahminSatiri.modelData.basincBar, 2); font.bold: true; font.pixelSize: 14 }
                                            Hucre { width: tahminTablosu.width * 0.28; height: tahminSatiri.height; text: sayi(tahminSatiri.modelData.altSinirBar, 2) + " – " + sayi(tahminSatiri.modelData.ustSinirBar, 2); color: "#9ca3af" }
                                            Hucre {
                                                width: tahminTablosu.width * 0.18; height: tahminSatiri.height
                                                text: !tahminSatiri.pompaVar ? "—" : (tahminSatiri.modelData.pompaAsildi ? "✕ " + txt("asildi") : "✓ " + txt("uygun"))
                                                color: !tahminSatiri.pompaVar ? "#6b7280" : (tahminSatiri.modelData.pompaAsildi ? "#f87171" : "#4ade80")
                                                font.bold: true
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: txt("modelNotu").arg(calculator.sliperBoruCapiMm()).arg(calculator.sliperBoruUzunluguMm())
                                color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 10; wrapMode: Text.WordWrap
                            }
                        }
                    }

                    // ---------------- 4: Tahmin grafiği ----------------
                    Item {
                        ChartView {
                            theme: ChartView.ChartThemeDark
                            anchors.fill: parent
                            backgroundColor: "transparent"
                            antialiasing: true
                            legend.visible: true
                            legend.labelColor: "#9ca3af"
                            legend.alignment: Qt.AlignBottom

                            Eksen { id: tgQEkseni; min: 0; max: 100; titleText: txt("debi") }
                            Eksen { id: tgPEkseni; min: 0; max: 100; titleText: "P (bar)" }

                            LineSeries { id: tahminL2; name: txt("tahmin") + " " + sayi(tahminAyarlari.l2, 0) + " m"; axisX: tgQEkseni; axisY: tgPEkseni; color: "#3b82f6"; width: 2.5 }
                            LineSeries { id: tahminL3; name: txt("tahmin") + " " + sayi(tahminAyarlari.l3, 0) + " m"; axisX: tgQEkseni; axisY: tgPEkseni; color: "#22c55e"; width: 2.5; style: Qt.DotLine }
                            LineSeries { id: tahminL4; name: txt("tahmin") + " " + sayi(tahminAyarlari.l4, 0) + " m"; axisX: tgQEkseni; axisY: tgPEkseni; color: "#ef4444"; width: 2.5; style: Qt.DashLine }
                            LineSeries { id: pompaCizgisi; name: txt("pompaCizgi"); axisX: tgQEkseni; axisY: tgPEkseni; color: "#f59e0b"; width: 2; style: Qt.DashDotLine }
                            // Hata çubukları (Q1 ve Q2'de, her uzunluk için)
                            LineSeries { id: hc0; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#3b82f6"; width: 2 }
                            LineSeries { id: hc1; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#3b82f6"; width: 2 }
                            LineSeries { id: hc2; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#22c55e"; width: 2 }
                            LineSeries { id: hc3; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#22c55e"; width: 2 }
                            LineSeries { id: hc4; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#ef4444"; width: 2 }
                            LineSeries { id: hc5; name: ""; axisX: tgQEkseni; axisY: tgPEkseni; color: "#ef4444"; width: 2 }
                        }
                    }
                }
            }
        }
    }

    // --------------------------------------------------------------- Bildirim
    Rectangle {
        id: bildirimKutusu
        property bool hataMi: false

        function goster(mesaj, hata) {
            bildirimMetni.text = mesaj
            hataMi = hata
            opacity = 1
            bildirimTimer.restart()
        }

        visible: opacity > 0
        opacity: 0
        z: 100
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        width: Math.min(bildirimMetni.implicitWidth + 40, parent.width - 40)
        height: 44
        radius: 10
        color: hataMi ? "#7f1d1d" : "#14532d"
        border.color: hataMi ? "#dc2626" : "#22c55e"
        border.width: 1

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            id: bildirimMetni
            anchors.centerIn: parent
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            color: "#dce8f5"
            font.family: "Segoe UI"
            font.pixelSize: 13
            font.bold: true
        }

        Timer {
            id: bildirimTimer
            interval: 4000
            onTriggered: bildirimKutusu.opacity = 0
        }
    }

    // --------------------------------------------------------------- Popup'lar
    Popup {
        id: strokeSilPopup
        property int strokeId: -1
        property int strokeNo: 0
        modal: true
        anchors.centerIn: parent
        width: 380
        padding: 22
        background: PopupArka {}
        Overlay.modal: Rectangle { color: "#a6000000" }
        contentItem: Column {
            spacing: 18
            Text {
                width: 336
                text: txt("strokeSilSoru").arg(strokeSilPopup.strokeNo)
                color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 14; wrapMode: Text.WordWrap
            }
            Row {
                spacing: 10
                Dugme {
                    width: 163; text: txt("sil"); renk: "#b91c1c"
                    onClicked: {
                        database.strokeSil(strokeSilPopup.strokeId)
                        strokeSilPopup.close()
                        verileriYukle()
                    }
                }
                Dugme { width: 163; text: txt("vazgec"); renk: "#1e2a3f"; onClicked: strokeSilPopup.close() }
            }
        }
    }

    Popup {
        id: bilgiPopup
        modal: true
        anchors.centerIn: parent
        width: 420
        padding: 22
        background: PopupArka {}
        Overlay.modal: Rectangle { color: "#a6000000" }

        function ac() {
            yerDuzenle.metin = bilgi.yer || ""
            musteriDuzenle.metin = bilgi.musteri || ""
            receteDuzenle.metin = bilgi.recete || ""
            yorumDuzenle.metin = bilgi.yorum || ""
            open()
        }

        contentItem: Column {
            spacing: 10
            Text { text: txt("olcumBilgisi"); color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 15; font.bold: true }
            Girdi { id: yerDuzenle; width: 376; etiket: txt("yer") }
            Girdi { id: musteriDuzenle; width: 376; etiket: txt("musteri") }
            Girdi { id: receteDuzenle; width: 376; etiket: txt("recete") }
            Girdi { id: yorumDuzenle; width: 376; etiket: txt("yorum") }
            Row {
                spacing: 10
                Dugme {
                    width: 183; text: txt("kaydet")
                    onClicked: {
                        database.olcumBilgisiGuncelle(olcumId, yerDuzenle.metin, musteriDuzenle.metin, receteDuzenle.metin, yorumDuzenle.metin)
                        bilgiPopup.close()
                        verileriYukle()
                    }
                }
                Dugme { width: 183; text: txt("vazgec"); renk: "#1e2a3f"; onClicked: bilgiPopup.close() }
            }
        }
    }

    Popup {
        id: pdfOnizlemePopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 720
        height: Math.min(820, parent.height - 40)
        padding: 0
        closePolicy: Popup.CloseOnEscape
        property string onizlemeHtml: ""
        background: PopupArka {}
        Overlay.modal: Rectangle { color: "#a6000000" }

        contentItem: Column {
            width: pdfOnizlemePopup.width
            spacing: 0

            Rectangle {
                width: parent.width
                height: 52
                color: "#0a0a0d"
                radius: 12
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: txt("pdfRaporOnizlemeBaslik")
                    color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: pdfOnizlemePopup.height - 52 - 64
                color: "#ffffff"

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 20
                    contentWidth: width
                    contentHeight: onizlemeMetni.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    TextEdit {
                        id: onizlemeMetni
                        width: parent.width
                        readOnly: true
                        selectByMouse: true
                        textFormat: TextEdit.RichText
                        wrapMode: Text.WordWrap
                        text: pdfOnizlemePopup.onizlemeHtml
                        color: "#14141a"
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0a0d"
                radius: 12
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    Dugme {
                        width: 150
                        text: txt("indirPdf")
                        onClicked: {
                            var yol = reportManager.pdfOlustur(olcumId)
                            pdfOnizlemePopup.close()
                            bildirimKutusu.goster(yol.length > 0 ? txt("pdfKaydedildi") + yol : txt("pdfOlusturulamadi"), yol.length === 0)
                        }
                    }
                    Dugme { width: 100; text: txt("kapat"); renk: "#1e2a3f"; onClicked: pdfOnizlemePopup.close() }
                }
            }
        }
    }

    Popup {
        id: csvOnizlemePopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 860
        height: Math.min(680, parent.height - 40)
        padding: 0
        closePolicy: Popup.CloseOnEscape
        background: PopupArka {}
        Overlay.modal: Rectangle { color: "#a6000000" }

        contentItem: Column {
            width: csvOnizlemePopup.width
            spacing: 0

            Rectangle {
                width: parent.width
                height: 52
                color: "#0a0a0d"
                radius: 12
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: txt("excelCsvOnizlemeBaslik") + "  —  " + (bilgi.musteri || "") + "  ·  " + (bilgi.recete || "") + "  ·  " + (bilgi.tarih || "")
                    color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: csvOnizlemePopup.height - 52 - 64
                color: "#0a0a0d"

                Row {
                    id: csvBaslik
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 14
                    readonly property var k: [0.06, 0.12, 0.08, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.14]
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[0]; text: txt("no") }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[1]; text: txt("saat") }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[2]; text: txt("sure") }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[3]; text: txt("agirlik") }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[4]; text: "Pmax" }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[5]; text: "P0l" }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[6]; text: "P0r" }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[7]; text: "p mbar" }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[8]; text: "Q m³/h" }
                    BaslikHucre { width: csvBaslik.width * csvBaslik.k[9]; text: txt("durum") }
                }

                ListView {
                    id: csvListesi
                    anchors.top: csvBaslik.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 14
                    anchors.topMargin: 8
                    clip: true
                    model: strokeListesi
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Row {
                        id: csvSatiri
                        required property var modelData
                        readonly property var k: csvBaslik.k
                        readonly property real g: csvListesi.width
                        width: csvListesi.width
                        height: 26
                        Hucre { width: csvSatiri.g * csvSatiri.k[0]; height: csvSatiri.height; text: csvSatiri.modelData.stroke }
                        Hucre { width: csvSatiri.g * csvSatiri.k[1]; height: csvSatiri.height; text: csvSatiri.modelData.saat || "—" }
                        Hucre { width: csvSatiri.g * csvSatiri.k[2]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.sure, 2) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[3]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.agirlik, 1) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[4]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.pMaks, 1) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[5]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.p0l, 1) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[6]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.p0r, 1) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[7]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.basinc, 2) }
                        Hucre { width: csvSatiri.g * csvSatiri.k[8]; height: csvSatiri.height; text: sayi(csvSatiri.modelData.debi, 2) }
                        Hucre {
                            width: csvSatiri.g * csvSatiri.k[9]; height: csvSatiri.height
                            text: !csvSatiri.modelData.gecerli ? txt("hatali") : (csvSatiri.modelData.secili ? txt("dahil") : txt("haric"))
                            color: !csvSatiri.modelData.gecerli ? "#f87171" : (csvSatiri.modelData.secili ? "#4ade80" : "#9ca3af")
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0a0d"
                radius: 12
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    Dugme {
                        width: 150
                        text: txt("indirCsv")
                        renk: "#16a34a"
                        onClicked: {
                            var yol = database.csvDisaAktar(olcumId)
                            csvOnizlemePopup.close()
                            bildirimKutusu.goster(yol.length > 0 ? txt("csvKaydedildi") + yol : txt("csvOlusturulamadi"), yol.length === 0)
                        }
                    }
                    Dugme { width: 100; text: txt("kapat"); renk: "#1e2a3f"; onClicked: csvOnizlemePopup.close() }
                }
            }
        }
    }
}

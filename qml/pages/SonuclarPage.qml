import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7
import sliper

Rectangle {
    color: "#0a0a0d"

    property int olcumId: -1
    property real hesaplananTau0: 0
    property real hesaplananMu: 0
    property int playbackAdimi: -1
    property bool oynatiliyor: false
    property int playbackHizi: 1
    property string musteriAdi: ""
    property string receteAdi: ""
    property real agirlikDegeri: 0
    property string olcumTarihi: ""

    readonly property var metinler: ({
        sonucOzeti: { tr: "SONUÇ ÖZETİ", en: "RESULT SUMMARY" },
        akmaGerilmesi: { tr: "AKMA GERİLMESİ (τ₀)", en: "YIELD STRESS (τ₀)" },
        plastikViskozite: { tr: "PLASTİK VİSKOZİTE (μ)", en: "PLASTIC VISCOSITY (μ)" },
        uyumKalitesi: { tr: "UYUM KALİTESİ (R²)", en: "FIT QUALITY (R²)" },
        boruHattiTahmini: { tr: "BORU HATTI TAHMİNİ", en: "PIPELINE ESTIMATE" },
        hedefBoruCapi: { tr: "Hedef Boru Çapı (mm)", en: "Target Pipe Diameter (mm)" },
        boruUzunlugu: { tr: "Boru Uzunluğu (m) - karşılaştırma referansı", en: "Pipe Length (m) - comparison reference" },
        hedefDebi: { tr: "Hedef Debi (m³/h)", en: "Target Flow Rate (m³/h)" },
        hataPayi: { tr: "Hata Payı:", en: "Margin of Error:" },
        tahminiHesapla: { tr: "Tahmini Hesapla", en: "Calculate Estimate" },
        gecerliDegerGirin: { tr: "Geçerli değer girin", en: "Enter a valid value" },
        hesaplanamadi: { tr: "Hesaplanamadı", en: "Could not calculate" },
        pompalanabilir: { tr: "POMPALANABİLİR", en: "PUMPABLE" },
        pompalamaSorunu: { tr: "POMPALAMA SORUNU", en: "PUMPING ISSUE" },
        durumHerIkisiYuksek: { tr: "Hem akma gerilmesi hem plastik viskozite yüksek. Su/çimento oranını artırın ve agrega gradasyonunu gözden geçirin.", en: "Both yield stress and plastic viscosity are high. Increase the water/cement ratio and review the aggregate gradation." },
        durumTau0Yuksek: { tr: "Akma gerilmesi yüksek. Su/çimento oranını artırmayı veya süperakışkanlaştırıcı dozajını yükseltmeyi değerlendirin.", en: "Yield stress is high. Consider increasing the water/cement ratio or raising the superplasticizer dosage." },
        durumMuYuksek: { tr: "Plastik viskozite yüksek. İnce agrega oranını azaltmayı veya su azaltıcı katkı eklemeyi değerlendirin.", en: "Plastic viscosity is high. Consider reducing the fine aggregate ratio or adding a water-reducing admixture." },
        durumYetersizVeri: { tr: "Yeterli stroke verisi bulunamadı.", en: "Not enough stroke data found." },
        pdfRaporOnizle: { tr: "📄  PDF Rapor Önizle", en: "📄  Preview PDF Report" },
        excelCsvOnizle: { tr: "📊  Excel (CSV) Önizle", en: "📊  Preview Excel (CSV)" },
        excelXmlDisaAktar: { tr: "📑  Excel (XML) Dışa Aktar", en: "📑  Export Excel (XML)" },
        disaAktarildi: { tr: "✓ Dışa aktarıldı: ", en: "✓ Exported: " },
        disaAktarilamadi: { tr: "✕ Dışa aktarılamadı", en: "✕ Export failed" },
        oynatmaPlayback: { tr: "OYNATMA (PLAYBACK)", en: "PLAYBACK" },
        strokeEtiket: { tr: "Stroke", en: "Stroke" },
        oynatilacakStrokeYok: { tr: "Oynatilacak stroke yok", en: "No stroke to play back" },
        pqDagilimGrafigi: { tr: "P-Q Dağılım Grafiği", en: "P-Q Distribution Chart" },
        olcumNoktalari: { tr: "Ölçüm Noktaları", en: "Measurement Points" },
        regresyonDogrusu: { tr: "Regresyon Doğrusu", en: "Regression Line" },
        oynatmaEtiket: { tr: "Oynatma", en: "Playback" },
        strokeTablosu: { tr: "Stroke Tablosu", en: "Stroke Table" },
        strokeBaslik: { tr: "STROKE", en: "STROKE" },
        durumBaslik: { tr: "DURUM", en: "STATUS" },
        gecerliEtiket: { tr: "Geçerli", en: "Valid" },
        hataliEtiket: { tr: "Hatalı", en: "Invalid" },
        pdfRaporOnizlemeBaslik: { tr: "PDF Rapor Önizleme", en: "PDF Report Preview" },
        indirPdf: { tr: "💾  İndir (PDF)", en: "💾  Download (PDF)" },
        pdfKaydedildi: { tr: "PDF kaydedildi: ", en: "PDF saved: " },
        pdfOlusturulamadi: { tr: "PDF oluşturulamadı.", en: "Could not generate PDF." },
        kapat: { tr: "Kapat", en: "Close" },
        excelCsvOnizlemeBaslik: { tr: "Excel (CSV) Önizleme", en: "Excel (CSV) Preview" },
        olcumIdEtiket: { tr: "Ölçüm ID: ", en: "Measurement ID: " },
        tarihEtiket: { tr: "Tarih: ", en: "Date: " },
        musteriEtiket: { tr: "Müşteri: ", en: "Customer: " },
        receteEtiket: { tr: "Reçete: ", en: "Recipe: " },
        agirlikEtiket: { tr: "Ağırlık (kg): ", en: "Weight (kg): " },
        basincBaslik: { tr: "BASINÇ (mbar)", en: "PRESSURE (mbar)" },
        konumBaslik: { tr: "KONUM (mm)", en: "POSITION (mm)" },
        debiBuyukBaslik: { tr: "DEBİ (m³/h)", en: "FLOW (m³/h)" },
        gecerliBuyukBaslik: { tr: "GEÇERLİ", en: "VALID" },
        evet: { tr: "Evet", en: "Yes" },
        hayir: { tr: "Hayır", en: "No" },
        indirCsv: { tr: "💾  İndir (CSV)", en: "💾  Download (CSV)" },
        csvKaydedildi: { tr: "CSV kaydedildi: ", en: "CSV saved: " },
        csvOlusturulamadi: { tr: "CSV oluşturulamadı.", en: "Could not generate CSV." },
        bilinmiyor: { tr: "Bilinmiyor", en: "Unknown" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    onOlcumIdChanged: verileriYukle()

    function verileriYukle() {
        if (olcumId <= 0) {
            return
        }

        playbackAdimi = -1
        oynatiliyor = false
        playbackTimer.stop()

        var bilgi = database.olcumBilgisiGetir(olcumId)
        musteriAdi = bilgi.bulundu ? bilgi.musteri : txt("bilinmiyor")
        receteAdi = bilgi.bulundu ? bilgi.recete : txt("bilinmiyor")
        agirlikDegeri = bilgi.bulundu ? bilgi.agirlik : 0
        olcumTarihi = bilgi.bulundu ? bilgi.tarih : ""

        var sonuc = database.binghamHesapla(olcumId)

        hesaplananTau0 = sonuc.tau0
        hesaplananMu = sonuc.mu

        tau0Metni.text = sonuc.tau0.toFixed(2) + " mbar"
        muMetni.text = sonuc.mu.toFixed(2) + " mbar·h/m³"
        r2Metni.text = sonuc.r2.toFixed(2)

        durumKutusu.durumIyiMi = sonuc.yeterliVeri && sonuc.tau0 < 5 && sonuc.mu < 10
        durumKutusu.tau0Yuksek = sonuc.tau0 >= 5
        durumKutusu.muYuksek = sonuc.mu >= 10

        pqSerisi.clear()
        regresyonCizgisi.clear()
        oynatmaSerisi.clear()
        strokeModeli.clear()

        var strokeListesi = database.strokeVerileriGetir(olcumId)
        var pMaks = 0
        var qMaks = 0
        for (var i = 0; i < strokeListesi.length; i++) {
            var s = strokeListesi[i]
            pqSerisi.append(s.debi, s.basinc)
            strokeModeli.append({ stroke: s.stroke, p: s.basinc, q: s.debi, gecerli: s.gecerli })
            if (s.basinc > pMaks) pMaks = s.basinc
            if (s.debi > qMaks) qMaks = s.debi
        }

        // Eksenler gerçek ölçüm verisine göre ayarlanır; sabit aralık kullanılırsa
        // basınç/debi bu aralığı aştığında noktalar (ve oynatma imleci) grafik
        // dışına taşıp görünmez olur.
        qMaks = Math.max(qMaks, 5)
        regresyonCizgisi.append(0, sonuc.tau0)
        regresyonCizgisi.append(qMaks, sonuc.tau0 + sonuc.mu * qMaks)

        pMaks = Math.max(pMaks, sonuc.tau0 + sonuc.mu * qMaks, 10)
        pEkseni.max = pMaks * 1.15
        qEkseni.max = qMaks * 1.15
    }

    Timer {
        id: playbackTimer
        interval: 1000 / playbackHizi
        repeat: true
        running: false

        onTriggered: {
            if (playbackAdimi < strokeModeli.count - 1) {
                playbackAdimi++
                var satir = strokeModeli.get(playbackAdimi)
                oynatmaSerisi.clear()
                oynatmaSerisi.append(satir.q, satir.p)
            } else {
                oynatiliyor = false
                playbackTimer.stop()
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: ozetPaneli
            width: 280
            height: parent.height
            color: "#12121a"

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#1e2a3f"
            }

            Column {
                id: raporBasligi
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                spacing: 14

                Text {
                    text: txt("sonucOzeti")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 2
                }

                Row {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: musteriAdi.length > 0 ? musteriAdi.charAt(0).toUpperCase() : "—"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    Column {
                        width: parent.width - 52
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: musteriAdi.length > 0 ? musteriAdi : "—"
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: (receteAdi.length > 0 ? receteAdi : "—") + (olcumTarihi.length > 0 ? "  ·  " + olcumTarihi : "")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#1e2a3f"
                }
            }

            Flickable {
                anchors.top: raporBasligi.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20
                anchors.topMargin: 16
                contentWidth: width
                contentHeight: sonucKartlari.height
                clip: true

                Column {
                    id: sonucKartlari
                    width: parent.width
                    spacing: 10

                    Rectangle {
                        width: parent.width
                        radius: 10
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1
                        height: metrikSatirlari.height + 8

                        Column {
                            id: metrikSatirlari
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 4

                            Item {
                                width: parent.width
                                height: 52
                                Rectangle { width: 4; height: parent.height; anchors.verticalCenter: parent.verticalCenter; color: "#3b82f6" }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 76
                                    text: txt("akmaGerilmesi")
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                Text {
                                    id: tau0Metni
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "—"
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }

                            Rectangle { width: parent.width; height: 1; color: "#1e1e18" }

                            Item {
                                width: parent.width
                                height: 52
                                Rectangle { width: 4; height: parent.height; anchors.verticalCenter: parent.verticalCenter; color: "#9333ea" }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 76
                                    text: txt("plastikViskozite")
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                Text {
                                    id: muMetni
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "—"
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }

                            Rectangle { width: parent.width; height: 1; color: "#1e1e18" }

                            Item {
                                width: parent.width
                                height: 52
                                Rectangle { width: 4; height: parent.height; anchors.verticalCenter: parent.verticalCenter; color: "#16a34a" }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 76
                                    text: txt("uyumKalitesi")
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                Text {
                                    id: r2Metni
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "—"
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 10
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1
                        height: tahminIcerik.implicitHeight + 24

                        Column {
                            id: tahminIcerik
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: txt("boruHattiTahmini")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            TextField {
                                id: capKutusu
                                width: parent.width
                                height: 34
                                placeholderText: txt("hedefBoruCapi")
                                placeholderTextColor: "#4b5563"
                                color: "#dce8f5"
                                font.pixelSize: 12
                                leftPadding: 10
                                text: "125"
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 10; top: 500; decimals: 0 }
                                background: Rectangle {
                                    color: "#07070a"
                                    radius: 6
                                    border.color: capKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            TextField {
                                id: uzunlukKutusu
                                width: parent.width
                                height: 34
                                placeholderText: txt("boruUzunlugu")
                                placeholderTextColor: "#4b5563"
                                color: "#dce8f5"
                                font.pixelSize: 12
                                leftPadding: 10
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 0; top: 2000; decimals: 0 }
                                background: Rectangle {
                                    color: "#07070a"
                                    radius: 6
                                    border.color: uzunlukKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            TextField {
                                id: debiKutusu
                                width: parent.width
                                height: 34
                                placeholderText: txt("hedefDebi")
                                placeholderTextColor: "#4b5563"
                                color: "#dce8f5"
                                font.pixelSize: 12
                                leftPadding: 10
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 0; top: 200; decimals: 1 }
                                background: Rectangle {
                                    color: "#07070a"
                                    radius: 6
                                    border.color: debiKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: txt("hataPayi")
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                ComboBox {
                                    id: hataPayiSecici
                                    width: 90
                                    height: 28
                                    model: ["0", "10", "20"]
                                    currentIndex: 1

                                    background: Rectangle {
                                        color: "#07070a"
                                        radius: 6
                                        border.color: hataPayiSecici.activeFocus ? "#3b82f6" : "#1e2a3f"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: hataPayiSecici.displayText
                                        color: "#dce8f5"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 11
                                        leftPadding: 10
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    indicator: Text {
                                        x: hataPayiSecici.width - width - 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "▾"
                                        color: "#6b7280"
                                        font.pixelSize: 11
                                    }

                                    popup: Popup {
                                        y: hataPayiSecici.height + 2
                                        width: hataPayiSecici.width
                                        implicitHeight: contentItem.implicitHeight
                                        padding: 1

                                        background: Rectangle {
                                            color: "#0a0a0d"
                                            radius: 6
                                            border.color: "#1e2a3f"
                                            border.width: 1
                                        }

                                        contentItem: ListView {
                                            implicitHeight: contentHeight
                                            model: hataPayiSecici.popup.visible ? hataPayiSecici.delegateModel : null
                                            currentIndex: hataPayiSecici.highlightedIndex
                                            clip: true
                                        }
                                    }

                                    delegate: ItemDelegate {
                                        id: hataPayiDelege
                                        width: hataPayiSecici.width
                                        height: 28
                                        highlighted: hataPayiSecici.highlightedIndex === index

                                        background: Rectangle {
                                            color: hataPayiDelege.highlighted ? "#17263d" : "#0a0a0d"
                                        }

                                        contentItem: Text {
                                            text: modelData
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 11
                                            leftPadding: 10
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                Text {
                                    text: "%"
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Button {
                                width: parent.width
                                height: 36
                                text: txt("tahminiHesapla")
                                font.pixelSize: 12
                                font.bold: true

                                background: Rectangle {
                                    radius: 6
                                    color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#dce8f5"
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    var D = parseFloat(capKutusu.text)
                                    var L = parseFloat(uzunlukKutusu.text)
                                    var Q = parseFloat(debiKutusu.text)
                                    var tolerans = parseFloat(hataPayiSecici.currentText)

                                    if (isNaN(D) || isNaN(L) || isNaN(Q) || D <= 0 || L <= 0) {
                                        tahminSonucu.text = txt("gecerliDegerGirin")
                                        tahminKarsilastirma.text = ""
                                        return
                                    }

                                    var sonuc = calculator.boruHattiTahminHesapla(
                                        hesaplananTau0, hesaplananMu, Q, D, L, tolerans)

                                    if (!sonuc.gecerliGiris) {
                                        tahminSonucu.text = txt("hesaplanamadi")
                                        tahminKarsilastirma.text = ""
                                        return
                                    }

                                    tahminSonucu.text = sonuc.basincBar.toFixed(2) + " bar"
                                    if (tolerans > 0) {
                                        tahminSonucu.text += "  (±%1: %2 – %3 bar)".arg(tolerans.toFixed(0))
                                            .arg(sonuc.altSinirBar.toFixed(2)).arg(sonuc.ustSinirBar.toFixed(2))
                                    }

                                    // Aynı D/Q icin farkli boru uzunluklarinda karsilastirma
                                    // (orijinal SLIPER'daki "birden fazla boru uzunlugu" karsilastirmasi)
                                    var uzunluklar = [L * 0.5, L, L * 2]
                                    var satirlar = []
                                    for (var i = 0; i < uzunluklar.length; i++) {
                                        var s = calculator.boruHattiTahminHesapla(
                                            hesaplananTau0, hesaplananMu, Q, D, uzunluklar[i], 0)
                                        satirlar.push(uzunluklar[i].toFixed(0) + " m: " + s.basincBar.toFixed(2) + " bar")
                                    }
                                    tahminKarsilastirma.text = satirlar.join("   |   ")
                                }
                            }

                            Text {
                                id: tahminSonucu
                                width: parent.width
                                text: "—"
                                color: "#4f8cf7"
                                font.family: "Segoe UI"
                                font.pixelSize: 18
                                font.bold: true
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                id: tahminKarsilastirma
                                width: parent.width
                                text: ""
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        id: durumKutusu
                        width: parent.width
                        height: durumIcerik.implicitHeight + 28
                        radius: 10
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1
                        clip: true

                        property bool durumIyiMi: true
                        property bool tau0Yuksek: false
                        property bool muYuksek: false
                        property color vurguRengi: durumIyiMi ? "#16a34a" : "#dc2626"

                        Rectangle { width: 4; height: parent.height; color: durumKutusu.vurguRengi }

                        Item {
                            id: durumIcerik
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 18
                            width: parent.width - 36
                            implicitHeight: durumMetinSutunu.implicitHeight

                            Rectangle {
                                id: durumRozeti
                                width: 34
                                height: 34
                                radius: 17
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                border.color: durumKutusu.vurguRengi
                                border.width: 1.5

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: durumKutusu.vurguRengi
                                    opacity: 0.16
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: durumKutusu.durumIyiMi ? "✓" : "!"
                                    color: durumKutusu.vurguRengi
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                            }

                            Column {
                                id: durumMetinSutunu
                                anchors.left: durumRozeti.right
                                anchors.leftMargin: 14
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    text: durumKutusu.durumIyiMi ? txt("pompalanabilir") : txt("pompalamaSorunu")
                                    color: durumKutusu.vurguRengi
                                    font.family: "Segoe UI"
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    width: parent.width
                                    visible: !durumKutusu.durumIyiMi
                                    text: {
                                        if (durumKutusu.tau0Yuksek && durumKutusu.muYuksek) {
                                            return txt("durumHerIkisiYuksek")
                                        } else if (durumKutusu.tau0Yuksek) {
                                            return txt("durumTau0Yuksek")
                                        } else if (durumKutusu.muYuksek) {
                                            return txt("durumMuYuksek")
                                        }
                                        return txt("durumYetersizVeri")
                                    }
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    Button {
                        width: parent.width
                        height: 40
                        text: txt("pdfRaporOnizle")
                        font.pixelSize: 13
                        font.bold: true
                        enabled: olcumId > 0

                        onClicked: {
                            pdfOnizlemePopup.onizlemeHtml = reportManager.pdfOnizlemeHtml(
                                olcumId,
                                musteriAdi,
                                receteAdi,
                                hesaplananTau0,
                                hesaplananMu,
                                parseFloat(r2Metni.text)
                            )
                            pdfOnizlemePopup.open()
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.hovered ? "#4f8cf7" : "#3b82f6") : "#1e2a3f"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: parent.width
                        height: 40
                        text: txt("excelCsvOnizle")
                        font.pixelSize: 13
                        font.bold: true
                        enabled: olcumId > 0

                        onClicked: {
                            csvOnizlemePopup.satirlar = database.strokeVerileriGetir(olcumId)
                            csvOnizlemePopup.open()
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.hovered ? "#22c55e" : "#16a34a") : "#1e2a3f"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: parent.width
                        height: 40
                        text: txt("excelXmlDisaAktar")
                        font.pixelSize: 13
                        font.bold: true
                        enabled: olcumId > 0

                        onClicked: {
                            var yol = database.xmlDisaAktar(olcumId)
                            xmlDisaAktarBildirim.text = yol.length > 0
                                ? txt("disaAktarildi") + yol
                                : txt("disaAktarilamadi")
                            xmlDisaAktarBildirim.visible = true
                            xmlDisaAktarTimer.restart()
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.hovered ? "#4f8cf7" : "#3b82f6") : "#1e2a3f"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        id: xmlDisaAktarBildirim
                        width: parent.width
                        visible: false
                        text: ""
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        wrapMode: Text.WrapAnywhere
                        horizontalAlignment: Text.AlignHCenter

                        Timer {
                            id: xmlDisaAktarTimer
                            interval: 4000
                            onTriggered: xmlDisaAktarBildirim.visible = false
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 10
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1
                        height: playbackIcerik.implicitHeight + 24
                        visible: olcumId > 0

                        Column {
                            id: playbackIcerik
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: txt("oynatmaPlayback")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            Text {
                                text: strokeModeli.count > 0
                                      ? txt("strokeEtiket") + " " + (playbackAdimi + 1) + " / " + strokeModeli.count
                                      : txt("oynatilacakStrokeYok")
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 12
                            }

                            Flow {
                                width: parent.width
                                spacing: 5

                                Button {
                                    width: 40
                                    height: 34
                                    text: oynatiliyor ? "⏸" : "▶"
                                    font.pixelSize: 14
                                    enabled: strokeModeli.count > 0

                                    onClicked: {
                                        if (oynatiliyor) {
                                            oynatiliyor = false
                                            playbackTimer.stop()
                                        } else {
                                            if (playbackAdimi >= strokeModeli.count - 1) {
                                                playbackAdimi = -1
                                            }
                                            oynatiliyor = true
                                            playbackTimer.start()
                                        }
                                    }

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.enabled ? (parent.hovered ? "#4f8cf7" : "#3b82f6") : "#1e2a3f"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#dce8f5"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Repeater {
                                    model: [1, 2, 5, 10]

                                    Button {
                                        width: 38
                                        height: 34
                                        text: modelData + "x"
                                        font.pixelSize: 12

                                        onClicked: playbackHizi = modelData

                                        background: Rectangle {
                                            radius: 6
                                            color: playbackHizi === modelData ? "#3b82f6" : "#12121a"
                                            border.color: "#1e2a3f"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: playbackHizi === modelData ? "#dce8f5" : "#9ca3af"
                                            font: parent.font
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: panelAyraci
            width: 3
            height: parent.height
            color: "#060607"

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#403b82f6"
            }
        }

        Item {
            width: parent.width - ozetPaneli.width - panelAyraci.width
            height: parent.height

            Rectangle {
                id: grafikKutusu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                height: parent.height * 0.55
                radius: 10
                color: "#12121a"
                border.color: "#1e2a3f"
                border.width: 1

                Item {
                    id: grafikBaslik
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 14
                    height: 20

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: txt("pqDagilimGrafigi")
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#3b82f6"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: txt("olcumNoktalari")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 12
                                height: 2
                                color: "#4f8cf7"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: txt("regresyonDogrusu")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#4f8cf7"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: txt("oynatmaEtiket")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                ChartView {
                    anchors.top: grafikBaslik.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 4
                    anchors.margins: 8
                    backgroundColor: "transparent"
                    legend.visible: false
                    antialiasing: true

                    ValueAxis {
                        id: qEkseni
                        min: 0
                        max: 20
                        titleText: Translations.turkish ? "Debi (Q) m³/h" : "Flow Rate (Q) m³/h"
                        gridLineColor: "#1a1a20"
                        labelsColor: "#4b5563"
                        labelsFont.pixelSize: 9
                        lineVisible: false
                        minorGridVisible: false
                    }

                    ValueAxis {
                        id: pEkseni
                        min: 0
                        max: 100
                        titleText: Translations.turkish ? "Basınç (P) mbar" : "Pressure (P) mbar"
                        gridLineColor: "#1a1a20"
                        labelsColor: "#4b5563"
                        labelsFont.pixelSize: 9
                        lineVisible: false
                        minorGridVisible: false
                    }

                    ScatterSeries {
                        id: pqSerisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#3b82f6"
                        markerSize: 10
                    }

                    LineSeries {
                        id: regresyonCizgisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#4f8cf7"
                        width: 2
                    }

                    ScatterSeries {
                        id: oynatmaSerisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#4f8cf7"
                        markerSize: 16
                    }
                }
            }

            Rectangle {
                anchors.top: grafikKutusu.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 16
                anchors.topMargin: 8
                radius: 10
                color: "#12121a"
                border.color: "#1e2a3f"
                border.width: 1

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 14
                    text: txt("strokeTablosu")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                    font.bold: true
                }

                Row {
                    id: tabloBasligi
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 36
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Text { width: parent.width * 0.25; text: txt("strokeBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: "P (mbar)"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: "Q (m³/h)"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: txt("durumBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                }

                Rectangle {
                    anchors.top: tabloBasligi.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    height: 1
                    color: "#1e2a3f"
                }

                ListView {
                    anchors.top: tabloBasligi.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    anchors.topMargin: 14
                    clip: true

                    model: ListModel {
                        id: strokeModeli
                    }

                    delegate: Rectangle {
                        width: parent.width
                        height: 32
                        radius: 6
                        color: index === playbackAdimi ? "#1e2a3f" : (index % 2 === 0 ? "transparent" : "#0a0a0d")

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 6

                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: stroke; color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: p.toFixed(1); color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: q.toFixed(2); color: "#dce8f5"; font.pixelSize: 12 }

                            Item {
                                width: parent.width * 0.25
                                height: parent.height

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: durumMetni.implicitWidth + 16
                                    height: 20
                                    radius: 10
                                    color: gecerli ? "#123321" : "#2a1414"

                                    Text {
                                        id: durumMetni
                                        anchors.centerIn: parent
                                        text: gecerli ? txt("gecerliEtiket") : txt("hataliEtiket")
                                        color: gecerli ? "#4ade80" : "#f87171"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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
        width: bildirimMetni.implicitWidth + 40
        height: 44
        radius: 10
        color: hataMi ? "#7f1d1d" : "#14532d"
        border.color: hataMi ? "#dc2626" : "#22c55e"
        border.width: 1

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            id: bildirimMetni
            anchors.centerIn: parent
            text: ""
            color: "#dce8f5"
            font.family: "Segoe UI"
            font.pixelSize: 13
            font.bold: true
        }

        Timer {
            id: bildirimTimer
            interval: 3000
            onTriggered: bildirimKutusu.opacity = 0
        }
    }

    Popup {
        id: pdfOnizlemePopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 640
        height: Math.min(720, parent.height - 40)
        padding: 0
        closePolicy: Popup.CloseOnEscape

        property string onizlemeHtml: ""

        background: Rectangle {
            color: "#12121a"
            radius: 12
            border.color: "#1e2a3f"
            border.width: 1
        }

        Overlay.modal: Rectangle {
            color: "#a6000000"
        }

        contentItem: Column {
            width: pdfOnizlemePopup.width
            spacing: 0

            Rectangle {
                width: parent.width
                height: 52
                color: "#0a0a0d"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: txt("pdfRaporOnizlemeBaslik")
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: pdfOnizlemePopup.height - 52 - 64
                color: "#efe9da"

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 20
                    contentWidth: width
                    contentHeight: onizlemeMetni.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    TextEdit {
                        id: onizlemeMetni
                        width: parent.width
                        readOnly: true
                        selectByMouse: true
                        textFormat: TextEdit.RichText
                        wrapMode: Text.WordWrap
                        text: pdfOnizlemePopup.onizlemeHtml
                        color: "#14141a"
                        font.pixelSize: 13
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0a0d"

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Button {
                        width: 140
                        height: 38
                        text: txt("indirPdf")
                        font.pixelSize: 13
                        font.bold: true

                        onClicked: {
                            var yol = reportManager.pdfOlustur(
                                olcumId,
                                musteriAdi,
                                receteAdi,
                                hesaplananTau0,
                                hesaplananMu,
                                parseFloat(r2Metni.text)
                            )
                            pdfOnizlemePopup.close()
                            if (yol.length > 0) {
                                bildirimKutusu.goster(txt("pdfKaydedildi") + yol, false)
                            } else {
                                bildirimKutusu.goster(txt("pdfOlusturulamadi"), true)
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 100
                        height: 38
                        text: txt("kapat")
                        font.pixelSize: 13

                        onClicked: pdfOnizlemePopup.close()

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#1e2a3f" : "transparent"
                            border.color: "#1e2a3f"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#9ca3af"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: csvOnizlemePopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 640
        height: Math.min(680, parent.height - 40)
        padding: 0
        closePolicy: Popup.CloseOnEscape

        property var satirlar: []

        background: Rectangle {
            color: "#12121a"
            radius: 12
            border.color: "#1e2a3f"
            border.width: 1
        }

        Overlay.modal: Rectangle {
            color: "#a6000000"
        }

        contentItem: Column {
            width: csvOnizlemePopup.width
            spacing: 0

            Rectangle {
                width: parent.width
                height: 52
                color: "#0a0a0d"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: txt("excelCsvOnizlemeBaslik")
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            Item {
                width: parent.width
                height: csvBilgiSutunu.implicitHeight + 32

                Column {
                    id: csvBilgiSutunu
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 4

                    Text { text: txt("olcumIdEtiket") + olcumId; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12 }
                    Text { text: txt("tarihEtiket") + olcumTarihi; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12 }
                    Text { text: txt("musteriEtiket") + musteriAdi; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12 }
                    Text { text: txt("receteEtiket") + receteAdi; color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12 }
                    Text { text: txt("agirlikEtiket") + agirlikDegeri.toFixed(1); color: "#9ca3af"; font.family: "Segoe UI"; font.pixelSize: 12 }
                }
            }

            Rectangle {
                width: parent.width
                height: csvOnizlemePopup.height - 52 - 130 - 64
                color: "#0a0a0d"
                border.color: "#1e2a3f"
                border.width: 1

                Row {
                    id: csvTabloBasligi
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12

                    Text { width: parent.width * 0.2; text: txt("strokeBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true }
                    Text { width: parent.width * 0.2; text: txt("basincBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true }
                    Text { width: parent.width * 0.2; text: txt("konumBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true }
                    Text { width: parent.width * 0.2; text: txt("debiBuyukBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true }
                    Text { width: parent.width * 0.2; text: txt("gecerliBuyukBaslik"); color: "#6b7280"; font.pixelSize: 11; font.bold: true }
                }

                ListView {
                    anchors.top: csvTabloBasligi.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    anchors.topMargin: 8
                    clip: true

                    model: csvOnizlemePopup.satirlar

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 26
                        color: index % 2 === 0 ? "transparent" : "#12121a"

                        Row {
                            anchors.fill: parent

                            Text { width: parent.width * 0.2; anchors.verticalCenter: parent.verticalCenter; text: modelData.stroke; color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.2; anchors.verticalCenter: parent.verticalCenter; text: modelData.basinc.toFixed(1); color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.2; anchors.verticalCenter: parent.verticalCenter; text: modelData.konum.toFixed(1); color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.2; anchors.verticalCenter: parent.verticalCenter; text: modelData.debi.toFixed(2); color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.2; anchors.verticalCenter: parent.verticalCenter; text: modelData.gecerli ? txt("evet") : txt("hayir"); color: modelData.gecerli ? "#4ade80" : "#f87171"; font.pixelSize: 12 }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0a0d"

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Button {
                        width: 140
                        height: 38
                        text: txt("indirCsv")
                        font.pixelSize: 13
                        font.bold: true

                        onClicked: {
                            var yol = database.csvDisaAktar(olcumId)
                            csvOnizlemePopup.close()
                            if (yol.length > 0) {
                                bildirimKutusu.goster(txt("csvKaydedildi") + yol, false)
                            } else {
                                bildirimKutusu.goster(txt("csvOlusturulamadi"), true)
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#22c55e" : "#16a34a"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 100
                        height: 38
                        text: txt("kapat")
                        font.pixelSize: 13

                        onClicked: csvOnizlemePopup.close()

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#1e2a3f" : "transparent"
                            border.color: "#1e2a3f"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#9ca3af"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
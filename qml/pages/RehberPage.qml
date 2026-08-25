import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import sliper

Rectangle {
    color: "#0a0e17"

    readonly property var metinler: ({
        baslik: { tr: "REHBER — SLIPER Nasıl Kullanılır", en: "GUIDE — How to Use SLIPER" },
        geriButon: { tr: "← Geri", en: "← Back" },
        adimSonEk: { tr: " Adım", en: " Steps" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    readonly property color konuRengi: "#ef4444"

    readonly property var bolumler: [
        {
            renk: "#ef4444",
            baslikTr: "Ölçüm Nasıl Başlatılır",
            baslikEn: "How to Start a Measurement",
            ozetTr: "Yeni bir test için müşteri bilgisi, reçete ve cihaz bağlantısı",
            ozetEn: "Customer info, mix design and device connection for a new test",
            adimlar: [
                {
                    baslikTr: "Müşteri ve reçete bilgisini girin",
                    baslikEn: "Enter the customer and mix design",
                    metinTr: "Sol menüden Ölçüm sayfasını açın. \"Müşteri\" alanına müşteri adını yazın ve \"Beton Reçetesi\" listesinden ilgili reçeteyi seçin.",
                    metinEn: "Open the Measurement page from the left menu. Type the customer name into the \"Customer\" field and pick the relevant mix from the \"Concrete Mix Design\" list.",
                    mockup: { tur: "olcum", bolge: "musteriRecete" }
                },
                {
                    baslikTr: "Cihaz bağlantısını kontrol edin",
                    baslikEn: "Check the device connection",
                    metinTr: "Sol alt köşedeki bağlantı göstergesi yeşilse SLIPER-ESP32 bağlıdır. Bağlı değilse üzerine tıklayarak bağlanmayı deneyin.",
                    metinEn: "If the connection indicator in the bottom-left corner is green, the SLIPER-ESP32 is connected. If not, click it to attempt a connection.",
                    mockup: { tur: "navBaglanti", bolge: "baglanti" }
                },
                {
                    baslikTr: "\"▶ Ölçümü Başlat\" butonuna basın",
                    baslikEn: "Press \"▶ Start Measurement\"",
                    metinTr: "Tüm bilgiler girildikten sonra bu butonla ölçüm başlar; anlık basınç, konum, hız ve debi değerleri ekranda canlı olarak izlenir.",
                    metinEn: "Once all information is filled in, this button starts the measurement; live pressure, position, speed and flow rate values appear on screen.",
                    mockup: { tur: "olcum", bolge: "baslat" }
                },
                {
                    baslikTr: "Ağırlık ekleyin, gerekirse duraklatın",
                    baslikEn: "Add weight, pause if needed",
                    metinTr: "Ölçüm sırasında \"Eklenen Ağırlık (kg)\" alanından eklenen ağırlığı kaydedin. \"⏸ Duraklat\" ile teste ara verip \"▶ Devam Et\" ile kaldığınız yerden sürdürebilirsiniz.",
                    metinEn: "During the measurement, log added weight using the \"Added Weight (kg)\" field. Use \"⏸ Pause\" to pause the test and \"▶ Resume\" to continue from where you left off.",
                    mockup: { tur: "olcum", bolge: "agirlikDuraklat" }
                }
            ]
        },
        {
            renk: "#ef4444",
            baslikTr: "Test Nasıl Bitirilir",
            baslikEn: "How to Finish a Test",
            ozetTr: "Ölçümü kaydetme veya silme",
            ozetEn: "Saving or discarding the measurement",
            adimlar: [
                {
                    baslikTr: "\"⏹ Bitir\" butonuna basın",
                    baslikEn: "Press \"⏹ Finish\"",
                    metinTr: "Ölçüm tamamlandığında bu butona basın. Test aktif değilse veya cihaz bağlı değilse önce ölçümü başlatmanız istenir.",
                    metinEn: "Press this button once the measurement is complete. If no test is active or the device is not connected, you'll be asked to start a measurement first.",
                    mockup: { tur: "olcum", bolge: "bitir" }
                },
                {
                    baslikTr: "Onay penceresinden seçim yapın",
                    baslikEn: "Choose an option in the confirmation dialog",
                    metinTr: "\"Ölçümü bitirmek istediğinize emin misiniz?\" sorusuna karşılık \"💾 Kaydet ve Bitir\", \"🗑 Testi Sil ve Bitir\" veya \"Vazgeç, Teste Devam Et\" seçeneklerinden birini seçin.",
                    metinEn: "In response to \"Are you sure you want to finish the measurement?\", choose \"💾 Save and Finish\", \"🗑 Delete Test and Finish\", or \"Cancel, Continue Testing\".",
                    mockup: { tur: "onay", bolge: "secenekler" }
                },
                {
                    baslikTr: "Sonuçlar sayfasına yönlendirilirsiniz",
                    baslikEn: "You are taken to the Results page",
                    metinTr: "Testi kaydettiğinizde uygulama otomatik olarak Sonuçlar sayfasını açar ve hesaplanan değerleri gösterir.",
                    metinEn: "When you save the test, the app automatically opens the Results page and shows the calculated values.",
                    mockup: { tur: "sonuclar", bolge: "ozet" }
                }
            ]
        },
        {
            renk: "#ef4444",
            baslikTr: "Sonuçlar Nasıl Görüntülenir",
            baslikEn: "How to View Results",
            ozetTr: "Akma gerilmesi, viskozite, grafikler ve raporlar",
            ozetEn: "Yield stress, viscosity, charts and reports",
            adimlar: [
                {
                    baslikTr: "Sonuç özetini inceleyin",
                    baslikEn: "Review the result summary",
                    metinTr: "\"SONUÇ ÖZETİ\" kartında akma gerilmesi (τ₀), plastik viskozite (μ) ve uyum kalitesi (R²) değerleri listelenir.",
                    metinEn: "The \"RESULT SUMMARY\" card lists yield stress (τ₀), plastic viscosity (μ), and fit quality (R²).",
                    mockup: { tur: "sonuclar", bolge: "ozet" }
                },
                {
                    baslikTr: "Boru hattı tahminini hesaplayın",
                    baslikEn: "Calculate the pipeline estimate",
                    metinTr: "\"BORU HATTI TAHMİNİ\" bölümüne hedef boru çapı, boru uzunluğu ve hedef debiyi girip \"Tahmini Hesapla\" butonuna basın; sonuç \"POMPALANABİLİR\" veya \"POMPALAMA SORUNU\" olarak gösterilir.",
                    metinEn: "In the \"PIPELINE ESTIMATE\" section, enter the target pipe diameter, pipe length and target flow rate, then press \"Calculate Estimate\"; the result shows as \"PUMPABLE\" or \"PUMPING ISSUE\".",
                    mockup: { tur: "sonuclar", bolge: "boru" }
                },
                {
                    baslikTr: "Grafik ve stroke tablosunu inceleyin",
                    baslikEn: "Review the chart and stroke table",
                    metinTr: "\"P-Q Dağılım Grafiği\" ölçüm noktalarını ve regresyon doğrusunu gösterir. \"Stroke Tablosu\"ndan her strokun geçerli/hatalı durumunu görebilir, \"Oynatma\" ile bir strokun kaydını tekrar izleyebilirsiniz.",
                    metinEn: "The \"P-Q Distribution Chart\" shows measurement points and the regression line. The \"Stroke Table\" shows each stroke's valid/invalid status, and \"Playback\" lets you replay a recorded stroke.",
                    mockup: { tur: "sonuclar", bolge: "grafikTablo" }
                },
                {
                    baslikTr: "Rapor olarak dışa aktarın",
                    baslikEn: "Export as a report",
                    metinTr: "\"📄 PDF Rapor Önizle\" veya \"📊 Excel (CSV) Önizle\" ile raporu önizleyebilir, \"📑 Excel (XML) Dışa Aktar\" ile doğrudan dosyaya kaydedebilirsiniz.",
                    metinEn: "Preview the report with \"📄 Preview PDF Report\" or \"📊 Preview Excel (CSV)\", or save it directly to a file with \"📑 Export Excel (XML)\".",
                    mockup: { tur: "sonuclar", bolge: "disaAktar" }
                }
            ]
        },
        {
            renk: "#ef4444",
            baslikTr: "Geçmiş Nasıl İncelenir",
            baslikEn: "How to Review History",
            ozetTr: "Eski testleri arama, filtreleme ve yönetme",
            ozetEn: "Searching, filtering and managing past tests",
            adimlar: [
                {
                    baslikTr: "Kayıtlarda arama ve filtreleme yapın",
                    baslikEn: "Search and filter records",
                    metinTr: "Sol menüden Geçmiş sayfasını açın. Üstteki arama kutusuna müşteri veya reçete adı yazabilir, \"Tüm Testler\", \"Son 7 Gün\", \"Son 30 Gün\" veya \"Özel Tarih\" filtrelerini kullanabilirsiniz.",
                    metinEn: "Open the History page from the left menu. Type a customer or mix design name into the search box at the top, and use the \"All Tests\", \"Last 7 Days\", \"Last 30 Days\" or \"Custom Date\" filters.",
                    mockup: { tur: "gecmis", bolge: "arama" }
                },
                {
                    baslikTr: "Bir testi görüntüleyin",
                    baslikEn: "View a test",
                    metinTr: "İlgili kaydın yanındaki \"Görüntüle\" butonuna basarak o testin Sonuçlar sayfasını açabilirsiniz.",
                    metinEn: "Press the \"View\" button next to a record to open that test's Results page.",
                    mockup: { tur: "gecmis", bolge: "goruntule" }
                },
                {
                    baslikTr: "Bir kaydı silin",
                    baslikEn: "Delete a record",
                    metinTr: "\"Kaydı Sil\" seçeneğiyle şifre girerek istenmeyen bir testi kalıcı olarak silebilirsiniz. Bu işlem geri alınamaz.",
                    metinEn: "Use \"Delete Record\" and enter the password to permanently delete an unwanted test. This action cannot be undone.",
                    mockup: { tur: "gecmis", bolge: "sil" }
                },
                {
                    baslikTr: "Veritabanını yedekleyin veya geri yükleyin",
                    baslikEn: "Back up or restore the database",
                    metinTr: "\"Gelişmiş Ayarlar\" bölümünden veritabanını dışa aktararak yedekleyebilir, bir .db dosyasından içe aktararak geri yükleyebilirsiniz. Sensör kalibrasyonları bu işlemlerden etkilenmez.",
                    metinEn: "From \"Advanced Settings\" you can export the database as a backup or restore it by importing a .db file. Sensor calibrations are not affected by these operations.",
                    mockup: { tur: "gecmis", bolge: "gelismis" }
                }
            ]
        },
        {
            renk: "#ef4444",
            baslikTr: "Kalibrasyon Nasıl Yapılır",
            baslikEn: "How to Calibrate Sensors",
            ozetTr: "Eğim, Load Cell ve Mesafe sensörlerinin kalibrasyonu",
            ozetEn: "Calibrating the incline, load cell and distance sensors",
            adimlar: [
                {
                    baslikTr: "Kalibre edilecek sensörü seçin",
                    baslikEn: "Select the sensor to calibrate",
                    metinTr: "Sol menüden Kalibrasyon sayfasını açın ve Eğim Sensörü, Load Cell veya Mesafe Sensörü kartlarından birine tıklayın.",
                    metinEn: "Open the Calibration page from the left menu and click one of the Incline Sensor, Load Cell or Distance Sensor cards.",
                    mockup: { tur: "kalibrasyonSecim", bolge: "kartlar" }
                },
                {
                    baslikTr: "Eğim sensörünü sıfırlayın",
                    baslikEn: "Zero the incline sensor",
                    metinTr: "Cihazı düz ve sabit bir yüzeye yerleştirin, su terazisi göstergesinin ortalanmasını bekleyin ve \"Sıfırla (Zero)\" butonuna basın.",
                    metinEn: "Place the device on a flat, stable surface, wait for the level indicator to center, then press \"Zero (Reset)\".",
                    mockup: { tur: "kalibrasyonEgim", bolge: "sifirla" }
                },
                {
                    baslikTr: "Load Cell / Mesafe sensörü için nokta sayısını seçin",
                    baslikEn: "Choose the point count for the Load Cell / Distance sensor",
                    metinTr: "Kaç noktalı kalibrasyon yapılacağını (4, 6, 8 veya 10) seçin — daha fazla nokta daha hassas bir kalibrasyon sağlar.",
                    metinEn: "Choose how many calibration points to use (4, 6, 8 or 10) — more points give a more precise calibration.",
                    mockup: { tur: "kalibrasyonNoktaSayisi", bolge: "secim" }
                },
                {
                    baslikTr: "Her nokta için hedef değeri girip kaydedin",
                    baslikEn: "Enter and save the target value for each point",
                    metinTr: "Hedef ağırlık veya mesafeyi girin, o değeri cihaza uygulayın ve noktayı kaydedin. Son noktadan sonra \"Kaydet ve Bitir\" ile kalibrasyon tamamlanır.",
                    metinEn: "Enter the target weight or distance, apply that value on the device, and save the point. After the last point, calibration is completed with \"Save and Finish\".",
                    mockup: { tur: "kalibrasyonNoktaGir", bolge: "kaydet" }
                },
                {
                    baslikTr: "Mevcut kalibrasyonu görüntüleyin veya yenileyin",
                    baslikEn: "View or refresh an existing calibration",
                    metinTr: "Daha önce kaydedilmiş bir kalibrasyon varsa \"Mevcut Kalibrasyonu Görüntüle\" ile noktaları inceleyebilir veya \"Yeniden Kalibre Et\" ile sıfırdan yeni bir ölçüm alabilirsiniz.",
                    metinEn: "If a calibration was already saved, use \"View Current Calibration\" to review the points, or \"Recalibrate\" to take a fresh measurement from scratch.",
                    mockup: { tur: "kalibrasyonMevcut", bolge: "kartlar" }
                }
            ]
        }
    ]

    property int seciliKonu: -1

    Component {
        id: rehberMockupBileseni
        RehberMockup {}
    }

    Component {
        id: konuIkonu

        Canvas {
            property int konu: -1
            property color cizgiRengi: "#6b7280"
            onCizgiRengiChanged: requestPaint()
            onKonuChanged: requestPaint()
            Component.onCompleted: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = cizgiRengi
                ctx.fillStyle = cizgiRengi
                ctx.lineWidth = width / 11
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                var k = width / 20

                if (konu === 0) {
                    ctx.fillRect(3 * k, 12 * k, 3.4 * k, 5 * k)
                    ctx.fillRect(8.3 * k, 8 * k, 3.4 * k, 9 * k)
                    ctx.fillRect(13.6 * k, 3.5 * k, 3.4 * k, 13.5 * k)
                } else if (konu === 1) {
                    ctx.beginPath(); ctx.arc(10 * k, 10 * k, 8 * k, 0, Math.PI * 2, false); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(6 * k, 10.3 * k); ctx.lineTo(8.8 * k, 13 * k); ctx.lineTo(14 * k, 6.8 * k); ctx.stroke()
                } else if (konu === 2) {
                    ctx.beginPath()
                    ctx.moveTo(3 * k, 15.5 * k); ctx.lineTo(8 * k, 10.5 * k); ctx.lineTo(12 * k, 12.5 * k); ctx.lineTo(17 * k, 4.5 * k)
                    ctx.stroke()
                    ;[[3, 15.5], [8, 10.5], [12, 12.5], [17, 4.5]].forEach(function(p) {
                        ctx.beginPath(); ctx.arc(p[0] * k, p[1] * k, 1.3 * k, 0, Math.PI * 2, false); ctx.fill()
                    })
                } else if (konu === 3) {
                    ctx.beginPath(); ctx.arc(10 * k, 10.5 * k, 7.2 * k, 0, Math.PI * 2, false); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(10 * k, 10.5 * k); ctx.lineTo(10 * k, 5.8 * k); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(10 * k, 10.5 * k); ctx.lineTo(13.2 * k, 12.3 * k); ctx.stroke()
                } else {
                    ;[5.5, 10, 14.5].forEach(function(y, i) {
                        ctx.beginPath(); ctx.moveTo(2.5 * k, y * k); ctx.lineTo(17.5 * k, y * k); ctx.stroke()
                        var knobX = [7.5, 12.5, 6.5][i]
                        ctx.beginPath(); ctx.arc(knobX * k, y * k, 2.1 * k, 0, Math.PI * 2, false); ctx.fill()
                    })
                }
            }
        }
    }

    Component {
        id: konuKartBileseni

        Rectangle {
            id: konuKarti
            property int gercekIndex: 0
            readonly property var modelData: bolumler[gercekIndex]
            width: 280
            height: 300
            radius: 12
            color: "#0f1420"
            border.color: konuKarti.hovered ? modelData.renk : "#1e2a3f"
            border.width: 1
            property bool hovered: false
            scale: hovered ? 1.02 : 1.0
            Behavior on border.color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

            Column {
                anchors.centerIn: parent
                width: parent.width - 28
                spacing: 16

                Loader {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 30
                    height: 30
                    sourceComponent: konuIkonu
                    onLoaded: {
                        item.konu = konuKarti.gercekIndex
                        item.cizgiRengi = Qt.binding(function() {
                            return konuKarti.hovered ? modelData.renk : "#9ca3af"
                        })
                    }
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: Translations.turkish ? modelData.baslikTr : modelData.baslikEn
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 15
                    font.bold: true
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: Translations.turkish ? modelData.ozetTr : modelData.ozetEn
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    lineHeight: 1.2
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: adimSayisiYazi.implicitWidth + 16
                    height: 20
                    radius: 10
                    color: "#1e2a3f"

                    Text {
                        id: adimSayisiYazi
                        anchors.centerIn: parent
                        text: modelData.adimlar.length + txt("adimSonEk")
                        color: modelData.renk
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: konuKarti.hovered = true
                onExited: konuKarti.hovered = false
                onClicked: seciliKonu = konuKarti.gercekIndex
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: seciliKonu === -1 ? 0 : 1

        // SAYFA 0: konu kartları
        ScrollView {
            id: konularScroll
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: konularScroll.availableWidth - 40
                x: 20
                spacing: 20
                topPadding: 20
                bottomPadding: 20

                Text {
                    text: txt("baslik")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1
                }

                Column {
                    width: parent.width
                    spacing: 18

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 18

                        Repeater {
                            model: 3

                            Loader {
                                sourceComponent: konuKartBileseni
                                onLoaded: item.gercekIndex = index
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 18

                        Repeater {
                            model: 2

                            Loader {
                                sourceComponent: konuKartBileseni
                                onLoaded: item.gercekIndex = index + 3
                            }
                        }
                    }
                }
            }
        }

        // SAYFA 1: konu detayı
        ScrollView {
            id: detayScroll
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: detayScroll.availableWidth - 40
                x: 20
                spacing: 18
                topPadding: 20
                bottomPadding: 24

                Row {
                    spacing: 12

                    Button {
                        text: txt("geriButon")
                        font.pixelSize: 13

                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#1e2a3f" : "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#dce8f5"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            rightPadding: 10
                        }

                        onClicked: seciliKonu = -1
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: seciliKonu >= 0 ? bolumler[seciliKonu].renk : "#6b7280"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: seciliKonu >= 0 ? (Translations.turkish ? bolumler[seciliKonu].baslikTr : bolumler[seciliKonu].baslikEn) : ""
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                Text {
                    visible: seciliKonu >= 0
                    width: parent.width
                    text: seciliKonu >= 0 ? (Translations.turkish ? bolumler[seciliKonu].ozetTr : bolumler[seciliKonu].ozetEn) : ""
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#1e2a3f"
                }

                Column {
                    width: parent.width
                    spacing: 26

                    Repeater {
                        model: seciliKonu >= 0 ? bolumler[seciliKonu].adimlar : []

                        RowLayout {
                            width: parent.width
                            spacing: 18

                            Rectangle {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                Layout.alignment: Qt.AlignTop
                                radius: 13
                                color: Qt.darker(bolumler[seciliKonu].renk, 3.2)
                                border.color: bolumler[seciliKonu].renk
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                                    color: bolumler[seciliKonu].renk
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }

                            Column {
                                Layout.preferredWidth: 300
                                Layout.alignment: Qt.AlignTop
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: Translations.turkish ? modelData.baslikTr : modelData.baslikEn
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 14
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    width: parent.width
                                    text: Translations.turkish ? modelData.metinTr : modelData.metinEn
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.3
                                }
                            }

                            Loader {
                                id: mockupYukleyici
                                Layout.fillWidth: true
                                Layout.maximumWidth: 460
                                Layout.preferredHeight: 260
                                Layout.alignment: Qt.AlignTop
                                asynchronous: true
                                sourceComponent: rehberMockupBileseni

                                property var adimModeli: modelData
                                property color konuRengi: bolumler[seciliKonu].renk

                                onLoaded: {
                                    item.sahneAdi = adimModeli.mockup.tur
                                    item.vurguAnahtari = adimModeli.mockup.bolge
                                    item.vurguRengi = konuRengi
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    visible: mockupYukleyici.status !== Loader.Ready
                                    radius: 10
                                    color: "#0a0e17"
                                    border.color: "#1e2a3f"
                                    border.width: 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import sliper

Rectangle {
    color: "#0a0e17"

    readonly property var metinler: ({
        baslik: { tr: "REHBER — SLIPER Nasıl Kullanılır", en: "GUIDE — How to Use SLIPER" },
        hosgeldinBaslik: { tr: "SLIPER Analiz Uygulamasına Hoş Geldiniz", en: "Welcome to the SLIPER Analysis App" },
        hosgeldinMetin: {
            tr: "Bu rehber, SLIPER-ESP32 cihazıyla ölçüm almaktan sonuçları görüntülemeye, geçmiş testleri incelemekten sensör kalibrasyonuna kadar uygulamanın tüm adımlarını anlatır. Aşağıdaki başlıklardan birine tıklayarak adım adım açıklamaları görebilirsiniz.",
            en: "This guide walks you through every step of the app — from taking a measurement with the SLIPER-ESP32 device, to viewing results, reviewing past tests, and calibrating sensors. Click any topic below to see the step-by-step instructions."
        },
        adimOnEk: { tr: "Adım ", en: "Step " }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    readonly property var bolumler: [
        {
            renk: "#16a34a",
            baslikTr: "Ölçüm Nasıl Başlatılır",
            baslikEn: "How to Start a Measurement",
            ozetTr: "Yeni bir test için müşteri bilgisi, reçete ve cihaz bağlantısı",
            ozetEn: "Customer info, mix design and device connection for a new test",
            adimlar: [
                {
                    baslikTr: "Müşteri ve reçete bilgisini girin",
                    baslikEn: "Enter the customer and mix design",
                    metinTr: "Sol menüden Ölçüm sayfasını açın. \"Müşteri\" alanına müşteri adını yazın ve \"Beton Reçetesi\" listesinden ilgili reçeteyi seçin.",
                    metinEn: "Open the Measurement page from the left menu. Type the customer name into the \"Customer\" field and pick the relevant mix from the \"Concrete Mix Design\" list."
                },
                {
                    baslikTr: "Cihaz bağlantısını kontrol edin",
                    baslikEn: "Check the device connection",
                    metinTr: "Sol alt köşedeki bağlantı göstergesi yeşilse SLIPER-ESP32 bağlıdır. Bağlı değilse üzerine tıklayarak bağlanmayı deneyin.",
                    metinEn: "If the connection indicator in the bottom-left corner is green, the SLIPER-ESP32 is connected. If not, click it to attempt a connection."
                },
                {
                    baslikTr: "\"▶ Ölçümü Başlat\" butonuna basın",
                    baslikEn: "Press \"▶ Start Measurement\"",
                    metinTr: "Tüm bilgiler girildikten sonra bu butonla ölçüm başlar; anlık basınç, konum, hız ve debi değerleri ekranda canlı olarak izlenir.",
                    metinEn: "Once all information is filled in, this button starts the measurement; live pressure, position, speed and flow rate values appear on screen."
                },
                {
                    baslikTr: "Ağırlık ekleyin, gerekirse duraklatın",
                    baslikEn: "Add weight, pause if needed",
                    metinTr: "Ölçüm sırasında \"Eklenen Ağırlık (kg)\" alanından eklenen ağırlığı kaydedin. \"⏸ Duraklat\" ile teste ara verip \"▶ Devam Et\" ile kaldığınız yerden sürdürebilirsiniz.",
                    metinEn: "During the measurement, log added weight using the \"Added Weight (kg)\" field. Use \"⏸ Pause\" to pause the test and \"▶ Resume\" to continue from where you left off."
                }
            ]
        },
        {
            renk: "#dc2626",
            baslikTr: "Test Nasıl Bitirilir",
            baslikEn: "How to Finish a Test",
            ozetTr: "Ölçümü kaydetme veya silme",
            ozetEn: "Saving or discarding the measurement",
            adimlar: [
                {
                    baslikTr: "\"⏹ Bitir\" butonuna basın",
                    baslikEn: "Press \"⏹ Finish\"",
                    metinTr: "Ölçüm tamamlandığında bu butona basın. Test aktif değilse veya cihaz bağlı değilse önce ölçümü başlatmanız istenir.",
                    metinEn: "Press this button once the measurement is complete. If no test is active or the device is not connected, you'll be asked to start a measurement first."
                },
                {
                    baslikTr: "Onay penceresinden seçim yapın",
                    baslikEn: "Choose an option in the confirmation dialog",
                    metinTr: "\"Ölçümü bitirmek istediğinize emin misiniz?\" sorusuna karşılık \"💾 Kaydet ve Bitir\", \"🗑 Testi Sil ve Bitir\" veya \"Vazgeç, Teste Devam Et\" seçeneklerinden birini seçin.",
                    metinEn: "In response to \"Are you sure you want to finish the measurement?\", choose \"💾 Save and Finish\", \"🗑 Delete Test and Finish\", or \"Cancel, Continue Testing\"."
                },
                {
                    baslikTr: "Sonuçlar sayfasına yönlendirilirsiniz",
                    baslikEn: "You are taken to the Results page",
                    metinTr: "Testi kaydettiğinizde uygulama otomatik olarak Sonuçlar sayfasını açar ve hesaplanan değerleri gösterir.",
                    metinEn: "When you save the test, the app automatically opens the Results page and shows the calculated values."
                }
            ]
        },
        {
            renk: "#3b82f6",
            baslikTr: "Sonuçlar Nasıl Görüntülenir",
            baslikEn: "How to View Results",
            ozetTr: "Akma gerilmesi, viskozite, grafikler ve raporlar",
            ozetEn: "Yield stress, viscosity, charts and reports",
            adimlar: [
                {
                    baslikTr: "Sonuç özetini inceleyin",
                    baslikEn: "Review the result summary",
                    metinTr: "\"SONUÇ ÖZETİ\" kartında akma gerilmesi (τ₀), plastik viskozite (μ) ve uyum kalitesi (R²) değerleri listelenir.",
                    metinEn: "The \"RESULT SUMMARY\" card lists yield stress (τ₀), plastic viscosity (μ), and fit quality (R²)."
                },
                {
                    baslikTr: "Boru hattı tahminini hesaplayın",
                    baslikEn: "Calculate the pipeline estimate",
                    metinTr: "\"BORU HATTI TAHMİNİ\" bölümüne hedef boru çapı, boru uzunluğu ve hedef debiyi girip \"Tahmini Hesapla\" butonuna basın; sonuç \"POMPALANABİLİR\" veya \"POMPALAMA SORUNU\" olarak gösterilir.",
                    metinEn: "In the \"PIPELINE ESTIMATE\" section, enter the target pipe diameter, pipe length and target flow rate, then press \"Calculate Estimate\"; the result shows as \"PUMPABLE\" or \"PUMPING ISSUE\"."
                },
                {
                    baslikTr: "Grafik ve stroke tablosunu inceleyin",
                    baslikEn: "Review the chart and stroke table",
                    metinTr: "\"P-Q Dağılım Grafiği\" ölçüm noktalarını ve regresyon doğrusunu gösterir. \"Stroke Tablosu\"ndan her strokun geçerli/hatalı durumunu görebilir, \"Oynatma\" ile bir strokun kaydını tekrar izleyebilirsiniz.",
                    metinEn: "The \"P-Q Distribution Chart\" shows measurement points and the regression line. The \"Stroke Table\" shows each stroke's valid/invalid status, and \"Playback\" lets you replay a recorded stroke."
                },
                {
                    baslikTr: "Rapor olarak dışa aktarın",
                    baslikEn: "Export as a report",
                    metinTr: "\"📄 PDF Rapor Önizle\" veya \"📊 Excel (CSV) Önizle\" ile raporu önizleyebilir, \"📑 Excel (XML) Dışa Aktar\" ile doğrudan dosyaya kaydedebilirsiniz.",
                    metinEn: "Preview the report with \"📄 Preview PDF Report\" or \"📊 Preview Excel (CSV)\", or save it directly to a file with \"📑 Export Excel (XML)\"."
                }
            ]
        },
        {
            renk: "#9333ea",
            baslikTr: "Geçmiş Nasıl İncelenir",
            baslikEn: "How to Review History",
            ozetTr: "Eski testleri arama, filtreleme ve yönetme",
            ozetEn: "Searching, filtering and managing past tests",
            adimlar: [
                {
                    baslikTr: "Kayıtlarda arama ve filtreleme yapın",
                    baslikEn: "Search and filter records",
                    metinTr: "Sol menüden Geçmiş sayfasını açın. Üstteki arama kutusuna müşteri veya reçete adı yazabilir, \"Tüm Testler\", \"Son 7 Gün\", \"Son 30 Gün\" veya \"Özel Tarih\" filtrelerini kullanabilirsiniz.",
                    metinEn: "Open the History page from the left menu. Type a customer or mix design name into the search box at the top, and use the \"All Tests\", \"Last 7 Days\", \"Last 30 Days\" or \"Custom Date\" filters."
                },
                {
                    baslikTr: "Bir testi görüntüleyin",
                    baslikEn: "View a test",
                    metinTr: "İlgili kaydın yanındaki \"Görüntüle\" butonuna basarak o testin Sonuçlar sayfasını açabilirsiniz.",
                    metinEn: "Press the \"View\" button next to a record to open that test's Results page."
                },
                {
                    baslikTr: "Bir kaydı silin",
                    baslikEn: "Delete a record",
                    metinTr: "\"Kaydı Sil\" seçeneğiyle şifre girerek istenmeyen bir testi kalıcı olarak silebilirsiniz. Bu işlem geri alınamaz.",
                    metinEn: "Use \"Delete Record\" and enter the password to permanently delete an unwanted test. This action cannot be undone."
                },
                {
                    baslikTr: "Veritabanını yedekleyin veya geri yükleyin",
                    baslikEn: "Back up or restore the database",
                    metinTr: "\"Gelişmiş Ayarlar\" bölümünden veritabanını dışa aktararak yedekleyebilir, bir .db dosyasından içe aktararak geri yükleyebilirsiniz. Sensör kalibrasyonları bu işlemlerden etkilenmez.",
                    metinEn: "From \"Advanced Settings\" you can export the database as a backup or restore it by importing a .db file. Sensor calibrations are not affected by these operations."
                }
            ]
        },
        {
            renk: "#14b8a6",
            baslikTr: "Kalibrasyon Nasıl Yapılır",
            baslikEn: "How to Calibrate Sensors",
            ozetTr: "Eğim, Load Cell ve Mesafe sensörlerinin kalibrasyonu",
            ozetEn: "Calibrating the incline, load cell and distance sensors",
            adimlar: [
                {
                    baslikTr: "Kalibre edilecek sensörü seçin",
                    baslikEn: "Select the sensor to calibrate",
                    metinTr: "Sol menüden Kalibrasyon sayfasını açın ve Eğim Sensörü, Load Cell veya Mesafe Sensörü kartlarından birine tıklayın.",
                    metinEn: "Open the Calibration page from the left menu and click one of the Incline Sensor, Load Cell or Distance Sensor cards."
                },
                {
                    baslikTr: "Eğim sensörünü sıfırlayın",
                    baslikEn: "Zero the incline sensor",
                    metinTr: "Cihazı düz ve sabit bir yüzeye yerleştirin, su terazisi göstergesinin ortalanmasını bekleyin ve \"Sıfırla (Zero)\" butonuna basın.",
                    metinEn: "Place the device on a flat, stable surface, wait for the level indicator to center, then press \"Zero (Reset)\"."
                },
                {
                    baslikTr: "Load Cell / Mesafe sensörü için nokta sayısını seçin",
                    baslikEn: "Choose the point count for the Load Cell / Distance sensor",
                    metinTr: "Kaç noktalı kalibrasyon yapılacağını (4, 6, 8 veya 10) seçin — daha fazla nokta daha hassas bir kalibrasyon sağlar.",
                    metinEn: "Choose how many calibration points to use (4, 6, 8 or 10) — more points give a more precise calibration."
                },
                {
                    baslikTr: "Her nokta için hedef değeri girip kaydedin",
                    baslikEn: "Enter and save the target value for each point",
                    metinTr: "Hedef ağırlık veya mesafeyi girin, o değeri cihaza uygulayın ve noktayı kaydedin. Son noktadan sonra \"Kaydet ve Bitir\" ile kalibrasyon tamamlanır.",
                    metinEn: "Enter the target weight or distance, apply that value on the device, and save the point. After the last point, calibration is completed with \"Save and Finish\"."
                },
                {
                    baslikTr: "Mevcut kalibrasyonu görüntüleyin veya yenileyin",
                    baslikEn: "View or refresh an existing calibration",
                    metinTr: "Daha önce kaydedilmiş bir kalibrasyon varsa \"Mevcut Kalibrasyonu Görüntüle\" ile noktaları inceleyebilir veya \"Yeniden Kalibre Et\" ile sıfırdan yeni bir ölçüm alabilirsiniz.",
                    metinEn: "If a calibration was already saved, use \"View Current Calibration\" to review the points, or \"Recalibrate\" to take a fresh measurement from scratch."
                }
            ]
        }
    ]

    property int acikIndex: 0

    ScrollView {
        id: rehberScroll
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: rehberScroll.availableWidth
            spacing: 20

            Text {
                text: txt("baslik")
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Rectangle {
                width: parent.width
                height: hosgeldinIcerik.implicitHeight + 36
                radius: 12
                color: "#0f1420"
                border.color: "#1e2a3f"
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 3
                    radius: 1.5
                    color: "#3b82f6"
                }

                Row {
                    id: hosgeldinIcerik
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    spacing: 16

                    Rectangle {
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        width: 30
                        height: 30
                        radius: 8
                        color: "#132335"
                        border.color: "#3b82f6"
                        border.width: 1

                        Canvas {
                            anchors.fill: parent
                            anchors.margins: 8
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "#3b82f6"
                                ctx.fillStyle = "#3b82f6"
                                ctx.lineWidth = 1.6
                                ctx.lineCap = "round"

                                ctx.beginPath()
                                ctx.arc(width / 2, height / 2, width / 2 - 1, 0, Math.PI * 2, false)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.arc(width / 2, height * 0.3, 1.1, 0, Math.PI * 2, false)
                                ctx.fill()

                                ctx.beginPath()
                                ctx.moveTo(width / 2, height * 0.46)
                                ctx.lineTo(width / 2, height * 0.76)
                                ctx.stroke()
                            }
                        }
                    }

                    Column {
                        width: parent.width - 46
                        spacing: 6

                        Text {
                            width: parent.width
                            text: txt("hosgeldinBaslik")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 16
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            width: parent.width
                            text: txt("hosgeldinMetin")
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            lineHeight: 1.3
                        }
                    }
                }
            }

            Repeater {
                model: bolumler

                Rectangle {
                    id: bolumKarti
                    width: parent.width
                    property bool acik: acikIndex === index
                    property color renk: modelData.renk
                    height: bolumIcerik.implicitHeight + 24
                    radius: 12
                    color: "#0f1420"
                    border.color: bolumKarti.acik ? bolumKarti.renk : "#1e2a3f"
                    border.width: 1
                    clip: true
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Column {
                        id: bolumIcerik
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 0

                        Rectangle {
                            id: bolumBaslikSatiri
                            width: parent.width
                            height: 56
                            radius: 8
                            color: baslikAlani.hoverli ? "#101a2c" : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 14

                                Rectangle {
                                    width: 38
                                    height: 38
                                    radius: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Qt.darker(bolumKarti.renk, 3.2)
                                    border.color: bolumKarti.renk
                                    border.width: 1

                                    Canvas {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        property int konu: index
                                        property color cizgiRengi: bolumKarti.renk
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            ctx.strokeStyle = cizgiRengi
                                            ctx.fillStyle = cizgiRengi
                                            ctx.lineWidth = 1.7
                                            ctx.lineCap = "round"
                                            ctx.lineJoin = "round"

                                            if (konu === 0) {
                                                // Ölçüm: yükselen çubuk grafik
                                                ctx.fillRect(3, 12, 3.4, 5)
                                                ctx.fillRect(8.3, 8, 3.4, 9)
                                                ctx.fillRect(13.6, 3.5, 3.4, 13.5)
                                            } else if (konu === 1) {
                                                // Bitirme: onay işareti
                                                ctx.beginPath()
                                                ctx.arc(10, 10, 8, 0, Math.PI * 2, false)
                                                ctx.stroke()
                                                ctx.beginPath()
                                                ctx.moveTo(6, 10.3)
                                                ctx.lineTo(8.8, 13)
                                                ctx.lineTo(14, 6.8)
                                                ctx.stroke()
                                            } else if (konu === 2) {
                                                // Sonuçlar: trend çizgisi ve noktalar
                                                ctx.beginPath()
                                                ctx.moveTo(3, 15.5)
                                                ctx.lineTo(8, 10.5)
                                                ctx.lineTo(12, 12.5)
                                                ctx.lineTo(17, 4.5)
                                                ctx.stroke()
                                                ;[[3, 15.5], [8, 10.5], [12, 12.5], [17, 4.5]].forEach(function(p) {
                                                    ctx.beginPath()
                                                    ctx.arc(p[0], p[1], 1.3, 0, Math.PI * 2, false)
                                                    ctx.fill()
                                                })
                                            } else if (konu === 3) {
                                                // Geçmiş: saat
                                                ctx.beginPath()
                                                ctx.arc(10, 10.5, 7.2, 0, Math.PI * 2, false)
                                                ctx.stroke()
                                                ctx.beginPath()
                                                ctx.moveTo(10, 10.5)
                                                ctx.lineTo(10, 5.8)
                                                ctx.stroke()
                                                ctx.beginPath()
                                                ctx.moveTo(10, 10.5)
                                                ctx.lineTo(13.2, 12.3)
                                                ctx.stroke()
                                            } else {
                                                // Kalibrasyon: ayar sürgüleri
                                                ;[5.5, 10, 14.5].forEach(function(y, i) {
                                                    ctx.beginPath()
                                                    ctx.moveTo(2.5, y)
                                                    ctx.lineTo(17.5, y)
                                                    ctx.stroke()

                                                    var knobX = [7.5, 12.5, 6.5][i]
                                                    ctx.beginPath()
                                                    ctx.arc(knobX, y, 2.1, 0, Math.PI * 2, false)
                                                    ctx.fill()
                                                })
                                            }
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: Translations.turkish ? modelData.baslikTr : modelData.baslikEn
                                        color: "#dce8f5"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 15
                                        font.bold: true
                                    }

                                    Text {
                                        text: Translations.turkish ? modelData.ozetTr : modelData.ozetEn
                                        color: "#6b7280"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            Canvas {
                                id: acilirIsareti
                                anchors.right: parent.right
                                anchors.rightMargin: 18
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14
                                height: 14
                                rotation: bolumKarti.acik ? 180 : 0
                                Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                                property color cizgiRengi: bolumKarti.acik ? bolumKarti.renk : "#6b7280"
                                onCizgiRengiChanged: requestPaint()
                                Component.onCompleted: requestPaint()

                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    ctx.strokeStyle = cizgiRengi
                                    ctx.lineWidth = 1.8
                                    ctx.lineCap = "round"
                                    ctx.lineJoin = "round"
                                    ctx.beginPath()
                                    ctx.moveTo(3, 5.5)
                                    ctx.lineTo(7, 9.5)
                                    ctx.lineTo(11, 5.5)
                                    ctx.stroke()
                                }
                            }

                            MouseArea {
                                id: baslikAlani
                                property bool hoverli: false
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: hoverli = true
                                onExited: hoverli = false
                                onClicked: acikIndex = bolumKarti.acik ? -1 : index
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 14
                            topPadding: 10
                            bottomPadding: 6
                            visible: bolumKarti.acik
                            opacity: bolumKarti.acik ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#1e2a3f"
                            }

                            Repeater {
                                model: modelData.adimlar

                                Row {
                                    width: parent.width
                                    spacing: 14

                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: Qt.darker(bolumKarti.renk, 3.2)
                                        border.color: bolumKarti.renk
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: bolumKarti.renk
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        width: parent.width - 38
                                        spacing: 3

                                        Text {
                                            width: parent.width
                                            text: Translations.turkish ? modelData.baslikTr : modelData.baslikEn
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 13
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
                                            lineHeight: 1.25
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 8 }
        }
    }
}

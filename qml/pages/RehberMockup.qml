import QtQuick 6.7

Rectangle {
    id: root

    property string sahneAdi: "olcum"
    property string vurguAnahtari: ""
    property color vurguRengi: "#3b82f6"

    color: "#0a0e17"
    radius: 10
    border.color: "#1e2a3f"
    border.width: 1
    clip: true

    readonly property var sahneler: ({
        navBaglanti: {
            w: 150, h: 260,
            ogeler: [
                { x: 35, y: 6, w: 80, h: 16, tip: "merkezMetin", metin: "LIYA", renk: "#c0392b", boyut: 11, kalin: true },
                { x: 8, y: 30, w: 28, h: 14, tip: "buton", metin: "TR", renk: "#0f1420", kenar: "#3b82f6" },
                { x: 40, y: 30, w: 28, h: 14, tip: "buton", metin: "EN", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 8, y: 53, w: 8, h: 8, tip: "nokta", renk: "#dc2626" },
                { x: 20, y: 51, w: 110, h: 12, tip: "etiket", metin: "Bağlı Değil" },
                { x: 8, y: 69, w: 8, h: 8, tip: "nokta", renk: "#dc2626" },
                { x: 20, y: 67, w: 120, h: 12, tip: "etiket", metin: "Sesli Komut: Kapalı" },
                { x: 8, y: 88, w: 134, h: 1, tip: "cizgi" },
                { x: 8, y: 98, w: 134, h: 24, tip: "navSatir", etiket: "Ölçüm", aktif: true },
                { x: 8, y: 126, w: 134, h: 24, tip: "navSatir", etiket: "Sonuçlar", aktif: false },
                { x: 8, y: 154, w: 134, h: 24, tip: "navSatir", etiket: "Geçmiş", aktif: false },
                { x: 8, y: 182, w: 134, h: 24, tip: "navSatir", etiket: "Kalibrasyon", aktif: false },
                { x: 8, y: 210, w: 134, h: 24, tip: "navSatir", etiket: "Rehber", aktif: false }
            ],
            bolgeler: { baglanti: { x: 5, y: 47, w: 130, h: 20 } }
        },
        olcum: {
            w: 460, h: 260,
            ogeler: [
                { x: 8, y: 6, w: 150, h: 10, tip: "etiket", metin: "TEST BİLGİLERİ" },
                { x: 8, y: 20, w: 154, h: 16, tip: "alan", metin: "Müşteri" },
                { x: 8, y: 40, w: 154, h: 16, tip: "alan", metin: "Reçete Seçin ▾" },
                { x: 8, y: 62, w: 130, h: 9, tip: "etiket", metin: "Eklenen Ağırlık (kg)" },
                { x: 8, y: 74, w: 50, h: 18, tip: "buton", metin: "+1.6", renk: "#1d4ed8", kenar: "#3b82f6" },
                { x: 62, y: 74, w: 52, h: 18, tip: "buton", metin: "− Geri", renk: "#78350f", kenar: "#92400e" },
                { x: 118, y: 74, w: 44, h: 18, tip: "buton", metin: "↺", renk: "#7f1d1d", kenar: "#991b1b" },
                { x: 8, y: 96, w: 154, h: 14, tip: "merkezMetin", metin: "0 x 1.6 = 0.0 kg", renk: "#6b7280", boyut: 7 },
                { x: 8, y: 114, w: 154, h: 20, tip: "buton", metin: "▶ Ölçümü Başlat", renk: "#15803d", kenar: "#22c55e" },
                { x: 8, y: 138, w: 75, h: 18, tip: "buton", metin: "⏸ Duraklat", renk: "#92400e", kenar: "#a16207" },
                { x: 87, y: 138, w: 75, h: 18, tip: "buton", metin: "⏹ Bitir", renk: "#991b1b", kenar: "#b91c1c" },
                { x: 8, y: 160, w: 154, h: 24, tip: "durumKart", solRenk: "#dc2626", solMetin: "VERİ YOK", sagMetin: "STROKE 0" },
                { x: 8, y: 190, w: 130, h: 9, tip: "etiket", metin: "ANLIK DEĞERLER" },
                { x: 8, y: 202, w: 154, h: 54, tip: "izgara2x2", grid: [
                    { renk: "#3b82f6", etiket: "BASINÇ" }, { renk: "#9333ea", etiket: "KONUM" },
                    { renk: "#f59e0b", etiket: "HIZ" }, { renk: "#16a34a", etiket: "DEBİ" }
                ] },
                { x: 178, y: 6, w: 130, h: 118, tip: "grafikKart", renk: "#3b82f6", baslik: "Basınç-Zaman", birim: "mbar" },
                { x: 316, y: 6, w: 130, h: 118, tip: "grafikKart", renk: "#9333ea", baslik: "Konum-Zaman", birim: "mm" },
                { x: 178, y: 132, w: 130, h: 118, tip: "grafikKart", renk: "#f59e0b", baslik: "Hız-Zaman", birim: "m/s" },
                { x: 316, y: 132, w: 130, h: 118, tip: "grafikKart", renk: "#16a34a", baslik: "Debi-Zaman", birim: "m3/h" }
            ],
            bolgeler: {
                musteriRecete: { x: 5, y: 17, w: 160, h: 42 },
                baslat: { x: 5, y: 111, w: 160, h: 26 },
                agirlikDuraklat: { x: 5, y: 59, w: 160, h: 100 },
                bitir: { x: 84, y: 135, w: 81, h: 24 }
            }
        },
        onay: {
            w: 280, h: 170,
            ogeler: [
                { x: 16, y: 14, w: 248, h: 20, tip: "merkezMetin", metin: "Ölçümü bitirmek istediğinize emin misiniz?", renk: "#9ca3af", boyut: 8 },
                { x: 16, y: 46, w: 248, h: 20, tip: "buton", metin: "💾 Kaydet ve Bitir", renk: "#15803d", kenar: "#22c55e" },
                { x: 16, y: 72, w: 248, h: 20, tip: "buton", metin: "🗑 Testi Sil ve Bitir", renk: "#991b1b", kenar: "#b91c1c" },
                { x: 16, y: 98, w: 248, h: 20, tip: "buton", metin: "Vazgeç, Teste Devam Et", renk: "#182131", kenar: "#1e2a3f" }
            ],
            bolgeler: { secenekler: { x: 12, y: 42, w: 256, h: 80 } }
        },
        sonuclar: {
            w: 460, h: 300,
            ogeler: [
                { x: 8, y: 6, w: 150, h: 9, tip: "etiket", metin: "SONUÇ ÖZETİ" },
                { x: 8, y: 18, w: 154, h: 34, tip: "kart", baslik: "AKMA GERİLMESİ (τ0)", altMetin: "—", renk: "#3b82f6" },
                { x: 8, y: 56, w: 154, h: 34, tip: "kart", baslik: "PLASTİK VİSKOZİTE (μ)", altMetin: "—", renk: "#9333ea" },
                { x: 8, y: 94, w: 154, h: 34, tip: "kart", baslik: "UYUM KALİTESİ (R²)", altMetin: "—", renk: "#16a34a" },
                { x: 8, y: 136, w: 150, h: 9, tip: "etiket", metin: "BORU HATTI TAHMİNİ" },
                { x: 8, y: 148, w: 154, h: 16, tip: "alan", metin: "125" },
                { x: 8, y: 168, w: 154, h: 16, tip: "alan", metin: "Boru Uzunluğu (m)" },
                { x: 8, y: 188, w: 154, h: 18, tip: "buton", metin: "Tahmini Hesapla", renk: "#1d4ed8", kenar: "#3b82f6" },
                { x: 8, y: 210, w: 154, h: 20, tip: "buton", metin: "✓ POMPALANABİLİR", renk: "#14532d", kenar: "#22c55e" },
                { x: 8, y: 236, w: 130, h: 9, tip: "etiket", metin: "RAPOR" },
                { x: 8, y: 248, w: 154, h: 16, tip: "buton", metin: "📄 PDF Rapor Önizle", renk: "#1d4ed8", kenar: "#3b82f6" },
                { x: 8, y: 266, w: 154, h: 16, tip: "buton", metin: "📊 Excel (CSV) Önizle", renk: "#15803d", kenar: "#22c55e" },
                { x: 8, y: 284, w: 154, h: 16, tip: "buton", metin: "📑 Excel (XML) Dışa Aktar", renk: "#1d4ed8", kenar: "#3b82f6" },
                { x: 178, y: 6, w: 274, h: 170, tip: "grafikKart", renk: "#3b82f6", baslik: "P-Q Dağılım Grafiği", legend: true },
                { x: 178, y: 184, w: 274, h: 110, tip: "tablo", baslik: "Stroke Tablosu" }
            ],
            bolgeler: {
                ozet: { x: 5, y: 15, w: 160, h: 116 },
                boru: { x: 5, y: 133, w: 160, h: 100 },
                disaAktar: { x: 5, y: 233, w: 160, h: 70 },
                grafikTablo: { x: 175, y: 3, w: 280, h: 294 }
            }
        },
        gecmis: {
            w: 420, h: 260,
            ogeler: [
                { x: 8, y: 6, w: 280, h: 18, tip: "alan", metin: "🔍 Müşteri veya reçete ara..." },
                { x: 296, y: 6, w: 80, h: 18, tip: "buton", metin: "Tüm Testler ▾", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 384, y: 6, w: 28, h: 18, tip: "buton", metin: "⚙", renk: "#0f1420", kenar: "#3b82f6" },
                { x: 8, y: 30, w: 200, h: 12, tip: "etiket", metin: "Özel Tarih:" },
                { x: 8, y: 50, w: 404, h: 32, tip: "kayitSatiri" },
                { x: 8, y: 86, w: 404, h: 32, tip: "kayitSatiri" },
                { x: 8, y: 122, w: 404, h: 32, tip: "kayitSatiri" },
                { x: 8, y: 158, w: 404, h: 32, tip: "kayitSatiri" }
            ],
            bolgeler: {
                arama: { x: 5, y: 3, w: 294, h: 24 },
                gelismis: { x: 381, y: 3, w: 34, h: 24 },
                goruntule: { x: 340, y: 47, w: 72, h: 38 },
                sil: { x: 296, y: 47, w: 36, h: 38 }
            }
        },
        kalibrasyonSecim: {
            w: 460, h: 190,
            ogeler: [
                { x: 8, y: 4, w: 300, h: 10, tip: "etiket", metin: "KALİBRASYON — Sensör Seçin" },
                { x: 8, y: 20, w: 142, h: 160, tip: "kart", baslik: "Eğim Sensörü", altMetin: "Yatay hizalama kalibrasyonu", renk: "#14b8a6", rozet: "✓ Kalibre Edildi" },
                { x: 158, y: 20, w: 142, h: 160, tip: "kart", baslik: "Load Cell", altMetin: "Basınç sensörü kalibrasyonu", renk: "#3b82f6", rozet: "✓ Kalibre Edildi" },
                { x: 308, y: 20, w: 142, h: 160, tip: "kart", baslik: "Mesafe Sensörü", altMetin: "Konum ölçümü kalibrasyonu", renk: "#9333ea", rozet: "✓ Kalibre Edildi" }
            ],
            bolgeler: { kartlar: { x: 5, y: 17, w: 450, h: 166 } }
        },
        kalibrasyonEgim: {
            w: 300, h: 306,
            ogeler: [
                { x: 0, y: 6, w: 60, h: 14, tip: "buton", metin: "← Geri", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 68, y: 8, w: 8, h: 8, tip: "nokta", renk: "#14b8a6" },
                { x: 80, y: 6, w: 200, h: 14, tip: "etiket", metin: "Eğim Sensörü Kalibrasyonu" },
                { x: 40, y: 32, w: 220, h: 12, tip: "merkezMetin", metin: "Son kalibrasyon: 21.08.2026", renk: "#6b7280", boyut: 7 },
                { x: 20, y: 52, w: 260, h: 16, tip: "merkezMetin", metin: "Cihazı düz ve sabit bir yüzeye yerleştirin", renk: "#9ca3af", boyut: 7 },
                { x: 75, y: 74, w: 150, h: 150, tip: "seviye" },
                { x: 75, y: 232, w: 150, h: 28, tip: "kutu", renk: "#14b8a6", dolgu: "#0f2e2a", metin: "X: 0.0°   Y: 0.0°", metinRenk: "#2dd4bf" },
                { x: 20, y: 266, w: 260, h: 10, tip: "merkezMetin", metin: "Cihaz bağlı değil — kalibrasyon kaydedilemez", renk: "#f87171", boyut: 6 },
                { x: 30, y: 280, w: 240, h: 20, tip: "buton", metin: "Sıfırla (Zero)", renk: "#0f1420", kenar: "#1e2a3f" }
            ],
            bolgeler: { sifirla: { x: 27, y: 277, w: 246, h: 26 } }
        },
        kalibrasyonNoktaSayisi: {
            w: 320, h: 170,
            ogeler: [
                { x: 0, y: 6, w: 60, h: 14, tip: "buton", metin: "← Geri", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 20, y: 40, w: 280, h: 14, tip: "merkezMetin", metin: "Kaç noktalı kalibrasyon yapmak istersiniz?", renk: "#dce8f5", boyut: 8, kalin: true },
                { x: 20, y: 58, w: 280, h: 20, tip: "merkezMetin", metin: "Daha fazla nokta, daha hassas kalibrasyon sağlar", renk: "#6b7280", boyut: 6 },
                { x: 40, y: 90, w: 240, h: 40, tip: "noktaSecici" }
            ],
            bolgeler: { secim: { x: 37, y: 87, w: 246, h: 46 } }
        },
        kalibrasyonNoktaGir: {
            w: 420, h: 170,
            ogeler: [
                { x: 0, y: 4, w: 60, h: 14, tip: "buton", metin: "← Geri", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 10, y: 26, w: 170, h: 10, tip: "merkezMetin", metin: "Nokta 1 / 8", renk: "#3b82f6", boyut: 8, kalin: true },
                { x: 10, y: 40, w: 170, h: 4, tip: "kutu", renk: "#1e2a3f", dolgu: "#132335" },
                { x: 10, y: 50, w: 170, h: 22, tip: "merkezMetin", metin: "Hedef ağırlığı gir, sonra o ağırlığı load cell'e koy", renk: "#9ca3af", boyut: 6 },
                { x: 10, y: 76, w: 170, h: 18, tip: "alan", metin: "kg" },
                { x: 10, y: 98, w: 170, h: 26, tip: "kutu", renk: "#dc2626", dolgu: "#2a1414", metin: "Ham değer: 0", metinRenk: "#f87171" },
                { x: 10, y: 130, w: 170, h: 20, tip: "buton", metin: "Bu Noktayı Kaydet", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 200, y: 26, w: 210, h: 10, tip: "etiket", metin: "KAYDEDİLEN NOKTALAR" },
                { x: 200, y: 42, w: 210, h: 22, tip: "kart", baslik: "① 0.00 kg", altMetin: "ADC: 81541", renk: "#3b82f6" },
                { x: 200, y: 68, w: 210, h: 22, tip: "kart", baslik: "② 1.00 kg", altMetin: "ADC: 127417", renk: "#3b82f6" },
                { x: 200, y: 94, w: 210, h: 22, tip: "kart", baslik: "③ 2.00 kg", altMetin: "ADC: 183259", renk: "#3b82f6" }
            ],
            bolgeler: {
                kaydet: { x: 7, y: 127, w: 176, h: 26 },
                hedefAlan: { x: 7, y: 73, w: 176, h: 24 }
            }
        },
        kalibrasyonMevcut: {
            w: 360, h: 170,
            ogeler: [
                { x: 0, y: 4, w: 60, h: 14, tip: "buton", metin: "← Geri", renk: "#0f1420", kenar: "#1e2a3f" },
                { x: 40, y: 24, w: 280, h: 12, tip: "merkezMetin", metin: "Bu sensör için kayıtlı bir kalibrasyon bulundu", renk: "#dce8f5", boyut: 8, kalin: true },
                { x: 30, y: 44, w: 145, h: 110, tip: "kart", baslik: "👁 Mevcut Kalibrasyonu Görüntüle", altMetin: "Kayıtlı noktaları incele", renk: "#3b82f6" },
                { x: 185, y: 44, w: 145, h: 110, tip: "kart", baslik: "↻ Yeniden Kalibre Et", altMetin: "Sıfırdan yeni ölçüm al", renk: "#6b7280" }
            ],
            bolgeler: { kartlar: { x: 27, y: 41, w: 303, h: 116 } }
        }
    })

    readonly property var sahne: sahneler[sahneAdi] || sahneler.olcum
    readonly property var vurguKutu: (sahne.bolgeler && sahne.bolgeler[vurguAnahtari]) ? sahne.bolgeler[vurguAnahtari] : null

    Item {
        id: disCerceve
        anchors.fill: parent
        anchors.margins: 8
        readonly property real olcek: Math.min(width / root.sahne.w, height / root.sahne.h, 1.4)

        Item {
            id: tuval
            width: root.sahne.w
            height: root.sahne.h
            scale: disCerceve.olcek
            transformOrigin: Item.TopLeft
            x: Math.round((disCerceve.width - width * disCerceve.olcek) / 2)
            y: Math.round((disCerceve.height - height * disCerceve.olcek) / 2)

            Repeater {
                model: root.sahne.ogeler

                Item {
                    id: oge
                    property var ov: modelData
                    x: ov.x
                    y: ov.y
                    width: ov.w
                    height: ov.h

                    Rectangle {
                        anchors.fill: parent
                        visible: oge.ov.tip === "alan" || oge.ov.tip === "buton" || oge.ov.tip === "kart"
                        radius: oge.ov.tip === "buton" ? 5 : 4
                        color: oge.ov.tip === "buton" ? (oge.ov.renk || "#182131")
                             : oge.ov.tip === "kart" ? Qt.darker(oge.ov.renk || "#3b82f6", 4.5)
                             : "#0a0e17"
                        border.color: oge.ov.tip === "buton" ? (oge.ov.kenar || "#1e2a3f")
                                    : oge.ov.tip === "kart" ? (oge.ov.renk || "#3b82f6")
                                    : "#1e2a3f"
                        border.width: 1

                        Rectangle {
                            visible: oge.ov.tip === "kart"
                            anchors.top: parent.top
                            width: parent.width
                            height: 3
                            radius: 1.5
                            color: oge.ov.renk || "#3b82f6"
                        }

                        Text {
                            visible: oge.ov.tip === "alan" || oge.ov.tip === "buton"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: oge.ov.tip === "buton" ? parent.verticalCenter : undefined
                            anchors.top: oge.ov.tip === "alan" ? parent.top : undefined
                            anchors.topMargin: oge.ov.tip === "alan" ? 3 : 0
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            horizontalAlignment: oge.ov.tip === "buton" ? Text.AlignHCenter : Text.AlignLeft
                            text: oge.ov.metin || ""
                            color: oge.ov.tip === "buton" ? "#e8eef7" : "#6b7280"
                            font.pixelSize: 8
                            font.bold: oge.ov.tip === "buton"
                            font.family: "Segoe UI"
                            wrapMode: Text.WordWrap
                        }

                        Column {
                            visible: oge.ov.tip === "kart"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 9
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 3

                            Text {
                                width: parent.width
                                text: oge.ov.baslik || ""
                                color: oge.ov.renk || "#dce8f5"
                                font.pixelSize: 8
                                font.bold: true
                                font.family: "Segoe UI"
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                visible: oge.ov.altMetin !== undefined
                                width: parent.width
                                text: oge.ov.altMetin || ""
                                color: "#6b7280"
                                font.pixelSize: 7
                                font.family: "Segoe UI"
                                wrapMode: Text.WordWrap
                            }
                        }

                        Rectangle {
                            visible: oge.ov.tip === "kart" && oge.ov.rozet !== undefined
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 8
                            width: rozetYazi.implicitWidth + 12
                            height: 14
                            radius: 7
                            color: "#123321"
                            Text {
                                id: rozetYazi
                                anchors.centerIn: parent
                                text: oge.ov.rozet || ""
                                color: "#4ade80"
                                font.pixelSize: 6
                                font.bold: true
                                font.family: "Segoe UI"
                            }
                        }
                    }

                    Text {
                        visible: oge.ov.tip === "etiket"
                        text: oge.ov.metin || ""
                        color: "#6b7280"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.6
                        font.family: "Segoe UI"
                    }

                    Text {
                        visible: oge.ov.tip === "merkezMetin"
                        anchors.fill: parent
                        text: oge.ov.metin || ""
                        color: oge.ov.renk || "#9ca3af"
                        font.pixelSize: oge.ov.boyut || 8
                        font.bold: oge.ov.kalin === true
                        font.family: "Segoe UI"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        visible: oge.ov.tip === "nokta"
                        anchors.fill: parent
                        radius: width / 2
                        color: oge.ov.renk || "#16a34a"
                    }

                    Rectangle {
                        visible: oge.ov.tip === "cizgi"
                        anchors.fill: parent
                        color: "#1e2a3f"
                    }

                    Rectangle {
                        visible: oge.ov.tip === "kutu"
                        anchors.fill: parent
                        radius: 5
                        color: oge.ov.dolgu || "#0f1420"
                        border.color: oge.ov.renk || "#1e2a3f"
                        border.width: 1

                        Text {
                            visible: oge.ov.metin !== undefined
                            anchors.centerIn: parent
                            text: oge.ov.metin || ""
                            color: oge.ov.metinRenk || "#9ca3af"
                            font.pixelSize: 8
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "durumKart"
                        anchors.fill: parent
                        radius: 5
                        color: "#0a0e17"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            spacing: 6
                            Rectangle { width: 8; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter; color: oge.ov.solRenk || "#dc2626" }
                            Text { text: oge.ov.solMetin || ""; color: "#dce8f5"; font.pixelSize: 7; font.bold: true; font.family: "Segoe UI" }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 8
                            text: oge.ov.sagMetin || ""
                            color: "#e8a020"
                            font.pixelSize: 7
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                    }

                    Grid {
                        visible: oge.ov.tip === "izgara2x2"
                        anchors.fill: parent
                        columns: 2
                        rows: 2
                        spacing: 6
                        Repeater {
                            model: oge.ov.grid || []
                            Rectangle {
                                width: (oge.width - 6) / 2
                                height: (oge.height - 6) / 2
                                radius: 3
                                color: "#0a0e17"
                                border.color: "#1e2a3f"
                                border.width: 1

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: 2
                                    color: modelData.renk
                                }
                                Column {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 6
                                    spacing: 1
                                    Text { text: modelData.etiket; color: "#6b7280"; font.pixelSize: 6; font.family: "Segoe UI" }
                                    Text { text: "--"; color: "#dce8f5"; font.pixelSize: 8; font.bold: true; font.family: "Segoe UI" }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "grafikKart"
                        anchors.fill: parent
                        radius: 6
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Row {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 6
                            spacing: 5

                            Rectangle { width: 6; height: 6; radius: 3; anchors.verticalCenter: parent.verticalCenter; color: oge.ov.renk || "#3b82f6" }
                            Text { text: oge.ov.baslik || ""; color: "#dce8f5"; font.pixelSize: 7; font.bold: true; font.family: "Segoe UI" }
                        }

                        Row {
                            visible: oge.ov.legend === true
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            spacing: 8
                            Row {
                                spacing: 3
                                Rectangle { width: 5; height: 5; radius: 2.5; anchors.verticalCenter: parent.verticalCenter; color: oge.ov.renk || "#3b82f6" }
                                Text { text: "Ölçüm"; color: "#6b7280"; font.pixelSize: 6; font.family: "Segoe UI" }
                            }
                            Row {
                                spacing: 3
                                Rectangle { width: 8; height: 2; anchors.verticalCenter: parent.verticalCenter; color: "#e8a020" }
                                Text { text: "Regresyon"; color: "#6b7280"; font.pixelSize: 6; font.family: "Segoe UI" }
                            }
                        }

                        Text {
                            visible: oge.ov.legend !== true
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            text: "-- " + (oge.ov.birim || "")
                            color: oge.ov.renk || "#3b82f6"
                            font.pixelSize: 6
                            font.family: "Segoe UI"
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 10
                            height: parent.height - 26
                            color: "transparent"
                            border.color: "#1a2436"
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.bottomMargin: 4
                                height: 1
                                rotation: -12
                                transformOrigin: Item.Left
                                color: "#e8a020"
                                opacity: 0.7
                            }

                            Repeater {
                                model: 4
                                Rectangle {
                                    readonly property real oran: index / 3
                                    x: 8 + oran * (parent.width - 16)
                                    y: parent.height - 8 - oran * (parent.height * 0.55) - (index % 2) * 6
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: oge.ov.renk || "#3b82f6"
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "tablo"
                        anchors.fill: parent
                        radius: 6
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            Text {
                                visible: oge.ov.baslik !== undefined
                                text: oge.ov.baslik || ""
                                color: "#dce8f5"
                                font.pixelSize: 7
                                font.bold: true
                                font.family: "Segoe UI"
                            }

                            Repeater {
                                model: 3
                                Row {
                                    spacing: 6
                                    Rectangle { width: 34; height: 6; radius: 2; color: "#1e2a3f" }
                                    Rectangle { width: 60; height: 6; radius: 2; color: "#1e2a3f" }
                                    Rectangle {
                                        width: 40; height: 10; radius: 5
                                        color: index === 1 ? "#2a1414" : "#123321"
                                        Text {
                                            anchors.centerIn: parent
                                            text: index === 1 ? "Hatalı" : "Geçerli"
                                            color: index === 1 ? "#f87171" : "#4ade80"
                                            font.pixelSize: 6
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "kayitSatiri"
                        anchors.fill: parent
                        radius: 6
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            spacing: 8

                            Rectangle {
                                width: 18; height: 18; radius: 9
                                color: "#132335"
                                border.color: "#3b82f6"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Rectangle { width: 70; height: 6; radius: 2; color: "#2a3548" }
                                Rectangle { width: 46; height: 5; radius: 2; color: "#1e2a3f" }
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 8
                            spacing: 6

                            Rectangle {
                                width: 18; height: 18; radius: 4
                                color: "#1a1420"
                                border.color: "#3f1d24"
                                border.width: 1
                            }
                            Rectangle {
                                width: 34; height: 18; radius: 4
                                color: "#132335"
                                border.color: "#3b82f6"
                                border.width: 1
                            }
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "navSatir"
                        anchors.fill: parent
                        radius: 5
                        color: oge.ov.aktif ? "#16233c" : "transparent"

                        Rectangle {
                            visible: oge.ov.aktif === true
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 2
                            color: "#3b82f6"
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            spacing: 7
                            Rectangle { width: 8; height: 8; radius: 2; anchors.verticalCenter: parent.verticalCenter; color: oge.ov.aktif ? "#3b82f6" : "#4b5563" }
                            Text { text: oge.ov.etiket || ""; color: oge.ov.aktif ? "#dce8f5" : "#6b7280"; font.pixelSize: 7; font.bold: oge.ov.aktif === true; font.family: "Segoe UI" }
                        }
                    }

                    Rectangle {
                        visible: oge.ov.tip === "seviye"
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Rectangle { anchors.centerIn: parent; width: parent.width - 2; height: 1; color: "#1e2a3f" }
                        Rectangle { anchors.centerIn: parent; width: 1; height: parent.height - 2; color: "#1e2a3f" }
                        Rectangle { anchors.centerIn: parent; width: 12; height: 12; radius: 6; color: "#16a34a" }
                    }

                    Row {
                        visible: oge.ov.tip === "noktaSecici"
                        anchors.fill: parent
                        spacing: 6
                        Repeater {
                            model: ["4", "6", "8", "10"]
                            Rectangle {
                                width: (oge.width - 18) / 4
                                height: oge.height
                                radius: 5
                                color: index === 1 ? "#132335" : "#0a0e17"
                                border.color: index === 1 ? "#3b82f6" : "#1e2a3f"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: index === 1 ? "#3b82f6" : "#6b7280"
                                    font.pixelSize: 9
                                    font.bold: index === 1
                                    font.family: "Segoe UI"
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: vurgu
                visible: root.vurguKutu !== null
                x: root.vurguKutu ? root.vurguKutu.x : 0
                y: root.vurguKutu ? root.vurguKutu.y : 0
                width: root.vurguKutu ? root.vurguKutu.w : 0
                height: root.vurguKutu ? root.vurguKutu.h : 0
                radius: 7
                color: Qt.rgba(root.vurguRengi.r, root.vurguRengi.g, root.vurguRengi.b, 0.14)
                border.color: root.vurguRengi
                border.width: 1.6

                SequentialAnimation {
                    running: vurgu.visible
                    loops: Animation.Infinite
                    NumberAnimation { target: vurgu; property: "border.width"; to: 2.6; duration: 700; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: vurgu; property: "border.width"; to: 1.4; duration: 700; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}

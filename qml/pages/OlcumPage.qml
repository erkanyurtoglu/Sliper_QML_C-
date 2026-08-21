import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7

Rectangle {
    color: "#0a0e17"
    property real zamanSayaci: 0
    property int aktifOlcumId: -1
    property string uyariMesaji: ""

    property var basincGecmis: []
    property var konumGecmis: []
    property var hizGecmis: []
    property var debiGecmis: []

    // TS EN 206 / TS 13515 normal beton dayanım sınıfları (C sınıfı) — çimento dozajı
    // ve azami su/çimento oranı, ilgili sınıfın minimum bağlayıcı gereksinimine göre.
    readonly property var receteListesi: [
        { sinif: "Reçete Seçin...", cimento: "", suCimento: "", aciklama: "" },
        { sinif: "C16/20", cimento: "min. 260 kg/m³", suCimento: "maks. 0.65", aciklama: "Hafif yükte yalın/donatılı beton" },
        { sinif: "C20/25", cimento: "min. 280 kg/m³", suCimento: "maks. 0.60", aciklama: "Standart betonarme" },
        { sinif: "C25/30", cimento: "min. 300 kg/m³", suCimento: "maks. 0.55", aciklama: "Standart betonarme (TS EN 206)" },
        { sinif: "C30/37", cimento: "min. 320 kg/m³", suCimento: "maks. 0.50", aciklama: "Standart betonarme" },
        { sinif: "C30/37 SCC", cimento: "min. 380 kg/m³", suCimento: "maks. 0.45", aciklama: "Kendiliğinden yerleşen beton (SF2)" },
        { sinif: "C35/45", cimento: "min. 340 kg/m³", suCimento: "maks. 0.45", aciklama: "Orta-yüksek dayanım" },
        { sinif: "C40/50", cimento: "min. 360 kg/m³", suCimento: "maks. 0.40", aciklama: "Yüksek dayanım" },
        { sinif: "C45/55", cimento: "min. 380 kg/m³", suCimento: "maks. 0.38", aciklama: "Yüksek dayanım" },
        { sinif: "C50/60", cimento: "min. 400 kg/m³", suCimento: "maks. 0.35", aciklama: "Yüksek dayanım (TS EN 206 normal beton sınırı)" }
    ]

    signal olcumTamamlandi(int id)

    function resetMeasurementScreen() {
        aktifOlcumId = -1
        uyariMesaji = ""
        musteriKutusu.text = ""
        receteKutusu.currentIndex = 0
        agirlikKutusu.text = ""
        calculator.sifirla()
        grafikleriSifirla()
    }

    function grafikleriSifirla() {
        zamanSayaci = 0
        basincSerisi.clear()
        konumSerisi.clear()
        hizSerisi.clear()
        debiSerisi.clear()
        basincGecmis = []
        konumGecmis = []
        hizGecmis = []
        debiGecmis = []
        xEkseni.min = 0
        xEkseni.max = 60
        yEkseni.min = 0
        yEkseni.max = 1100
        konumXEkseni.min = 0
        konumXEkseni.max = 60
        konumYEkseni.max = 500
        hizXEkseni.min = 0
        hizXEkseni.max = 60
        hizYEkseni.max = 4
        debiXEkseni.min = 0
        debiXEkseni.max = 60
        debiYEkseni.max = 180
    }

    function eksenTavaniHesapla(dizi, tavan, taban) {
        if (dizi.length === 0) return taban
        var maxDeger = Math.max.apply(null, dizi)
        var hedef = maxDeger * 1.25
        if (hedef < taban) hedef = taban
        if (hedef > tavan) hedef = tavan
        return hedef
    }

    // Basınç (mbar) atmosferik seviyede sabit bir taban etrafında dalgalanır,
    // bu yüzden sabit tavanlı ölçekleme yerine veriye göre kayan min/max kullanılır.
    function basincEkseniHesapla(dizi) {
        if (dizi.length === 0) return { min: 0, max: 1100 }
        var maxDeger = Math.max.apply(null, dizi)
        var minDeger = Math.min.apply(null, dizi)
        var pad = Math.max((maxDeger - minDeger) * 0.2, maxDeger * 0.02, 5)
        return { min: Math.max(0, minDeger - pad), max: maxDeger + pad }
    }

    Connections {
        target: sensorManager
        function onVeriGuncellendi() {
            if (!sensorManager.veriGecerli || aktifOlcumId <= 0 || calculator.duraklatildi) return

            zamanSayaci += 0.2

            basincSerisi.append(zamanSayaci, sensorManager.basinc)
            konumSerisi.append(zamanSayaci, sensorManager.konum)
            hizSerisi.append(zamanSayaci, sensorManager.hiz)
            debiSerisi.append(zamanSayaci, sensorManager.debi)

            basincGecmis.push(sensorManager.basinc)
            konumGecmis.push(sensorManager.konum)
            hizGecmis.push(sensorManager.hiz)
            debiGecmis.push(sensorManager.debi)

            if (zamanSayaci > 60) {
                basincSerisi.remove(0)
                konumSerisi.remove(0)
                hizSerisi.remove(0)
                debiSerisi.remove(0)

                basincGecmis.shift()
                konumGecmis.shift()
                hizGecmis.shift()
                debiGecmis.shift()

                xEkseni.min = zamanSayaci - 60
                xEkseni.max = zamanSayaci
                konumXEkseni.min = zamanSayaci - 60
                konumXEkseni.max = zamanSayaci
                hizXEkseni.min = zamanSayaci - 60
                hizXEkseni.max = zamanSayaci
                debiXEkseni.min = zamanSayaci - 60
                debiXEkseni.max = zamanSayaci
            }

            var basincAralik = basincEkseniHesapla(basincGecmis)
            yEkseni.min = basincAralik.min
            yEkseni.max = basincAralik.max
            konumYEkseni.max = eksenTavaniHesapla(konumGecmis, 500, 50)
            hizYEkseni.max = eksenTavaniHesapla(hizGecmis, 4, 0.5)
            debiYEkseni.max = eksenTavaniHesapla(debiGecmis, 180, 10)

            calculator.konumGuncelle(sensorManager.konum)
        }
    }

    Row {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: testBilgileriPaneli
            width: 280
            height: parent.height
            color: "#0f1420"

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                text: "TEST BİLGİLERİ"
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Column {
                id: formAlanlari
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                anchors.topMargin: 60
                spacing: 6

                Text {
                    text: "Müşteri"
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                TextField {
                    id: musteriKutusu
                    width: parent.width
                    height: 38
                    placeholderText: "Musteri adi girin..."
                    placeholderTextColor: "#4b5563"
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0e17"
                        radius: 6
                        border.color: musteriKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }

                Text {
                    text: "Beton Reçetesi"
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: receteKutusu
                    width: parent.width
                    height: 38
                    model: receteListesi
                    textRole: "sinif"

                    background: Rectangle {
                        color: "#0a0e17"
                        radius: 6
                        border.color: receteKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: receteKutusu.displayText
                        color: "#9ca3af"
                        font.pixelSize: 13
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }

                    delegate: ItemDelegate {
                        id: receteDelege
                        width: receteKutusu.width
                        height: modelData.cimento.length > 0 ? 52 : 36
                        highlighted: receteKutusu.highlightedIndex === index

                        background: Rectangle {
                            color: receteDelege.highlighted ? "#182644" : "#0a0e17"
                        }

                        contentItem: Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            spacing: 2

                            Text {
                                text: modelData.sinif
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Text {
                                visible: modelData.cimento.length > 0
                                text: "Çimento " + modelData.cimento + "  •  Su/Çimento " + modelData.suCimento
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                Text {
                    text: "Eklenen Ağırlık (kg)"
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                TextField {
                    id: agirlikKutusu
                    width: parent.width
                    height: 38
                    placeholderText: "orn: 4.8"
                    placeholderTextColor: "#4b5563"
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: TextInput.AlignVCenter
                    validator: DoubleValidator { bottom: 0; top: 20; decimals: 1 }
                    background: Rectangle {
                        color: "#0a0e17"
                        radius: 6
                        border.color: agirlikKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }

                Item { width: parent.width; height: 10 }

                Button {
                    id: baslatButonu
                    width: parent.width
                    height: 44
                    text: "▶  Ölçümü Başlat"
                    font.family: "Segoe UI"
                    font.pixelSize: 14
                    font.bold: true
                    enabled: aktifOlcumId <= 0

                    onClicked: {
                        if (musteriKutusu.text.trim().length === 0) {
                            uyariMesaji = "Lütfen müşteri adını girin."
                            return
                        }

                        if (receteKutusu.currentIndex <= 0) {
                            uyariMesaji = "Lütfen bir beton reçetesi seçin."
                            return
                        }

                        if (!sensorManager.veriGecerli) {
                            console.warn("Gercek sensor verisi yok, olcum baslatilmadi.")
                            uyariMesaji = "Cihaz bağlı değil. Lütfen önce sol alttan SLIPER-ESP32'ye bağlanın."
                            return
                        }

                        uyariMesaji = ""
                        grafikleriSifirla()

                        calculator.sifirla()
                        aktifOlcumId = database.olcumBaslat(
                            musteriKutusu.text,
                            receteKutusu.currentText,
                            parseFloat(agirlikKutusu.text)
                        )
                        console.log("Aktif olcum id:", aktifOlcumId)
                    }

                    background: Rectangle {
                        radius: 8
                        color: !baslatButonu.enabled ? "#14532d" : (baslatButonu.pressed ? "#15803d" : (baslatButonu.hovered ? "#22c55e" : "#16a34a"))
                        opacity: baslatButonu.enabled ? 1.0 : 0.5
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: baslatButonu.text
                        color: "#ffffff"
                        opacity: baslatButonu.enabled ? 1.0 : 0.6
                        font: baslatButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    width: parent.width
                    visible: uyariMesaji.length > 0
                    text: uyariMesaji
                    color: "#f87171"
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                Row {
                    width: parent.width
                    spacing: 10

                    Button {
                        id: duraklatButonu
                        width: (parent.width - parent.spacing) / 2
                        height: 40
                        text: calculator.duraklatildi ? "▶  Devam Et" : "⏸  Duraklat"
                        font.family: "Segoe UI"
                        font.pixelSize: 13

                        onClicked: {
                            if (calculator.duraklatildi) {
                                calculator.devamEt()
                            } else {
                                calculator.duraklat()
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: duraklatButonu.pressed ? "#78350f" : (duraklatButonu.hovered ? "#a16207" : "#92400e")
                            border.color: "#d97706"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: duraklatButonu.text
                            color: "#ffffff"
                            font: duraklatButonu.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: bitirButonu
                        width: (parent.width - parent.spacing) / 2
                        height: 40
                        text: "⏹  Bitir"
                        font.family: "Segoe UI"
                        font.pixelSize: 13

                        onClicked: {
                            if (aktifOlcumId > 0) {
                                bitirOnayPopup.open()
                            } else {
                                uyariMesaji = "Aktif bir ölçüm yok. Önce ölçümü başlatın."
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: bitirButonu.pressed ? "#7f1d1d" : (bitirButonu.hovered ? "#b91c1c" : "#991b1b")
                            border.color: "#dc2626"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: bitirButonu.text
                            color: "#ffffff"
                            font: bitirButonu.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Rectangle {
                id: durumKarti
                anchors.top: formAlanlari.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                height: 52
                radius: 10
                color: "#0a0e17"
                border.color: "#1e2a3f"
                border.width: 1

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 14
                    spacing: 10

                    Rectangle {
                        id: trafikIsigi
                        width: 12
                        height: 12
                        radius: 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: {
                            if (!sensorManager.veriGecerli) return "#dc2626"
                            if (calculator.duraklatildi) return "#6b7280"
                            if (calculator.durum === "YUKARIDA") return "#16a34a"
                            if (calculator.durum === "INIYOR") return "#f59e0b"
                            return "#dc2626"
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 8
                            height: parent.height + 8
                            radius: width / 2
                            color: "transparent"
                            border.color: parent.color
                            border.width: 1
                            opacity: 0.35
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (!sensorManager.veriGecerli) return "VERI YOK"
                            if (calculator.duraklatildi) return "DURAKLATILDI"
                            return calculator.durum
                        }
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 14
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "STROKE"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: calculator.strokeSayisi
                        color: "#e8a020"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }

            Text {
                id: anlikDegerlerBaslik
                anchors.top: durumKarti.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 20
                text: "ANLIK DEĞERLER"
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Grid {
                anchors.top: anlikDegerlerBaslik.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 20
                columns: 2
                spacing: 10

                Rectangle {
                    id: basincKarti
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#3b82f6" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: "BASINÇ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.veriGecerli ? sensorManager.basinc.toFixed(1) : "--"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "mbar"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#9333ea" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: "KONUM"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.veriGecerli ? sensorManager.konum.toFixed(1) : "--"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "mm"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#f59e0b" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: "HIZ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.veriGecerli ? sensorManager.hiz.toFixed(1) : "--"
                            color: "#f59e0b"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "m/s"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#16a34a" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: "DEBİ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.veriGecerli ? sensorManager.debi.toFixed(1) : "--"
                            color: "#16a34a"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "m3/h"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        Rectangle {
            id: panelAyraci
            width: 3
            height: parent.height
            color: "#05070b"

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#403b82f6"
            }
        }

        Item {
            width: parent.width - testBilgileriPaneli.width - panelAyraci.width
            height: parent.height

            Grid {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                spacing: 16

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#0f1420"
                    border.color: "#17263d"
                    border.width: 1

                    Item {
                        id: basincBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: basincNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#3b82f6"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: basincNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Basınç - Zaman"
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.basinc.toFixed(1) + " mbar" : "-- mbar"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: basincBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: xEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: yEkseni
                            min: 0
                            max: 1100
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: basincSerisi
                            axisX: xEkseni
                            axisY: yEkseni
                            color: "#3b82f6"
                            width: 2
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#0f1420"
                    border.color: "#241a38"
                    border.width: 1

                    Item {
                        id: konumBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: konumNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#9333ea"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: konumNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Konum - Zaman"
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.konum.toFixed(1) + " mm" : "-- mm"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: konumBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: konumXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: konumYEkseni
                            min: 0
                            max: 500
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: konumSerisi
                            axisX: konumXEkseni
                            axisY: konumYEkseni
                            color: "#9333ea"
                            width: 2
                        }

                        Connections {
                            target: calculator
                            function onStrokeSayisiChanged() {
                                if (aktifOlcumId > 0 && sensorManager.veriGecerli) {
                                    database.strokeKaydet(aktifOlcumId, sensorManager.basinc, sensorManager.konum, sensorManager.debi, true)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#0f1420"
                    border.color: "#3a2a14"
                    border.width: 1

                    Item {
                        id: hizBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: hizNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#f59e0b"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: hizNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Hız - Zaman"
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.hiz.toFixed(1) + " m/s" : "-- m/s"
                            color: "#f59e0b"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: hizBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: hizXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: hizYEkseni
                            min: 0
                            max: 4
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: hizSerisi
                            axisX: hizXEkseni
                            axisY: hizYEkseni
                            color: "#f59e0b"
                            width: 2
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#0f1420"
                    border.color: "#163321"
                    border.width: 1

                    Item {
                        id: debiBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: debiNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#16a34a"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: debiNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Debi - Zaman"
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.debi.toFixed(1) + " m3/h" : "-- m3/h"
                            color: "#16a34a"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: debiBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: debiXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: debiYEkseni
                            min: 0
                            max: 180
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: debiSerisi
                            axisX: debiXEkseni
                            axisY: debiYEkseni
                            color: "#16a34a"
                            width: 2
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: bitirOnayPopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 340
        padding: 24
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#0f1420"
            radius: 12
            border.color: "#1e2a3f"
            border.width: 1
        }

        Overlay.modal: Rectangle {
            color: "#a6000000"
        }

        contentItem: Column {
            spacing: 20

            Text {
                width: 292
                text: "Ölçümü bitirmek istediğinize emin misiniz?"
                color: "#dce8f5"
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Column {
                width: 292
                spacing: 10

                Button {
                    id: kaydetBitirButonu
                    width: parent.width
                    height: 40
                    text: "💾  Kaydet ve Bitir"
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: {
                        bitirOnayPopup.close()
                        var bitenId = aktifOlcumId
                        console.log("Olcum kaydedilip sonlandirildi, id:", bitenId)
                        resetMeasurementScreen()
                        olcumTamamlandi(bitenId)
                    }

                    background: Rectangle {
                        radius: 8
                        color: kaydetBitirButonu.pressed ? "#14532d" : (kaydetBitirButonu.hovered ? "#15803d" : "#16a34a")
                        border.color: "#22c55e"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: kaydetBitirButonu.text
                        color: "#ffffff"
                        font: kaydetBitirButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: silBitirButonu
                    width: parent.width
                    height: 40
                    text: "🗑  Testi Sil ve Bitir"
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: {
                        bitirOnayPopup.close()
                        var silinecekId = aktifOlcumId
                        var basarili = database.olcumSil(silinecekId)
                        console.log("Olcum silinip sonlandirildi, id:", silinecekId, "basarili:", basarili)
                        resetMeasurementScreen()
                    }

                    background: Rectangle {
                        radius: 8
                        color: silBitirButonu.pressed ? "#7f1d1d" : (silBitirButonu.hovered ? "#b91c1c" : "#991b1b")
                        border.color: "#dc2626"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: silBitirButonu.text
                        color: "#ffffff"
                        font: silBitirButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: vazgecButonu
                    width: parent.width
                    height: 40
                    text: "Vazgeç, Teste Devam Et"
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: bitirOnayPopup.close()

                    background: Rectangle {
                        radius: 8
                        color: vazgecButonu.pressed ? "#1e2a3f" : (vazgecButonu.hovered ? "#243349" : "#182131")
                        border.color: "#2c3b52"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: vazgecButonu.text
                        color: "#dce8f5"
                        font: vazgecButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
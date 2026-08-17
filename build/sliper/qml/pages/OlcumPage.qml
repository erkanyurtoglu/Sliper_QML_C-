import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7

Rectangle {
    color: "#0a0e17"
    property real zamanSayaci: 0
    property int aktifOlcumId: -1

    signal olcumTamamlandi(int id)

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
                    model: ["Reçete Seçin...", "C25/30 Standart", "C30/37 SCC", "C35/45 Yuksek Mukavemet"]

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

                    onClicked: {
                        if (!sensorManager.veriGecerli) {
                            console.warn("Gercek sensor verisi yok, olcum baslatilmadi.")
                            return
                        }

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
                        color: baslatButonu.pressed ? "#15803d" : (baslatButonu.hovered ? "#22c55e" : "#16a34a")
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: baslatButonu.text
                        color: "#ffffff"
                        font: baslatButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
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
                                var bitenId = aktifOlcumId
                                aktifOlcumId = -1
                                console.log("Olcum sonlandirildi, id:", bitenId)
                                olcumTamamlandi(bitenId)
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
                            max: 30
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        SplineSeries {
                            id: basincSerisi
                            axisX: xEkseni
                            axisY: yEkseni
                            color: "#3b82f6"
                            width: 2
                        }

                        Connections {
                            target: sensorManager
                            function onBasincChanged() {
                                if (!sensorManager.veriGecerli) return

                                zamanSayaci += 0.2
                                basincSerisi.append(zamanSayaci, sensorManager.basinc)

                                if (zamanSayaci > 60) {
                                    basincSerisi.remove(0)
                                    xEkseni.min = zamanSayaci - 60
                                    xEkseni.max = zamanSayaci
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

                        SplineSeries {
                            id: konumSerisi
                            axisX: konumXEkseni
                            axisY: konumYEkseni
                            color: "#9333ea"
                            width: 2
                        }

                        Connections {
                            target: sensorManager
                            function onKonumChanged() {
                                if (!sensorManager.veriGecerli) return

                                konumSerisi.append(zamanSayaci, sensorManager.konum)

                                if (zamanSayaci > 60) {
                                    konumSerisi.remove(0)
                                    konumXEkseni.min = zamanSayaci - 60
                                    konumXEkseni.max = zamanSayaci
                                }

                                calculator.konumGuncelle(sensorManager.konum)
                            }
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

                        SplineSeries {
                            id: hizSerisi
                            axisX: hizXEkseni
                            axisY: hizYEkseni
                            color: "#f59e0b"
                            width: 2
                        }

                        Connections {
                            target: sensorManager
                            function onHizChanged() {
                                if (!sensorManager.veriGecerli) return

                                hizSerisi.append(zamanSayaci, sensorManager.hiz)

                                if (zamanSayaci > 60) {
                                    hizSerisi.remove(0)
                                    hizXEkseni.min = zamanSayaci - 60
                                    hizXEkseni.max = zamanSayaci
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
                            max: 15
                            gridLineColor: "#182131"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        SplineSeries {
                            id: debiSerisi
                            axisX: debiXEkseni
                            axisY: debiYEkseni
                            color: "#16a34a"
                            width: 2
                        }

                        Connections {
                            target: sensorManager
                            function onDebiChanged() {
                                if (!sensorManager.veriGecerli) return

                                debiSerisi.append(zamanSayaci, sensorManager.debi)

                                if (zamanSayaci > 60) {
                                    debiSerisi.remove(0)
                                    debiXEkseni.min = zamanSayaci - 60
                                    debiXEkseni.max = zamanSayaci
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7

Rectangle {
    color: "#0a0e17"
    property real zamanSayaci: 0
    
    Row {
        anchors.fill: parent
        spacing: 1

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
                        text: "⏸  Duraklat"
                        font.family: "Segoe UI"
                        font.pixelSize: 13

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

            Row {
                anchors.top: formAlanlari.bottom
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 20
                spacing: 12

                Rectangle {
                    id: trafikIsigi
                    width: 16
                    height: 16
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: {
                        if (calculator.durum === "YUKARIDA") return "#16a34a"
                        if (calculator.durum === "INIYOR") return "#f59e0b"
                        return "#dc2626"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: calculator.durum
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                    font.bold: true
                }

                Rectangle {
                    width: 60
                    height: 28
                    radius: 6
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: calculator.strokeSayisi
                        color: "#e8a020"
                        font.family: "Segoe UI"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
            }

            Text {
                anchors.top: formAlanlari.bottom
                anchors.left: parent.left
                anchors.topMargin: 70
                anchors.leftMargin: 20
                text: "ANLIK DEĞERLER"
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Grid {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 470
                anchors.leftMargin: 20
                columns: 2
                spacing: 10

                Rectangle {
                    id: basincKarti
                    width: 115
                    height: 90
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "BASINÇ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.basinc.toFixed(1)
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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "KONUM"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.konum.toFixed(1)
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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "HIZ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.hiz.toFixed(1)
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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "DEBİ"
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sensorManager.debi.toFixed(1)
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

        Item {
            width: parent.width - testBilgileriPaneli.width - parent.spacing
            height: parent.height

            Grid {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                spacing: 16

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 8
                    color: "#0f1420"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        text: "Basınç - Zaman"
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    ChartView {
                        anchors.fill: parent
                        anchors.topMargin: 36
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: xEkseni
                            min: 0
                            max: 60
                        }

                        ValueAxis {
                            id: yEkseni
                            min: 0
                            max: 30
                        }

                        LineSeries {
                            id: basincSerisi
                            axisX: xEkseni
                            axisY: yEkseni
                            color: "#3b82f6"
                        }

                        Connections {
                            target: sensorManager
                            function onBasincChanged() {
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
                    radius: 8
                    color: "#0f1420"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        text: "Konum - Zaman"
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    ChartView {
                        anchors.fill: parent
                        anchors.topMargin: 36
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: konumXEkseni
                            min: 0
                            max: 60
                        }

                        ValueAxis {
                            id: konumYEkseni
                            min: 0
                            max: 500
                        }

                        LineSeries {
                            id: konumSerisi
                            axisX: konumXEkseni
                            axisY: konumYEkseni
                            color: "#9333ea"
                        }

                        Connections {
                            target: sensorManager
                            function onKonumChanged() {
                                konumSerisi.append(zamanSayaci, sensorManager.konum)

                                if (zamanSayaci > 60) {
                                    konumSerisi.remove(0)
                                    konumXEkseni.min = zamanSayaci - 60
                                    konumXEkseni.max = zamanSayaci
                                }

                                calculator.konumGuncelle(sensorManager.konum)
                            }
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 8
                    color: "#0f1420"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        text: "Hız - Zaman"
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    ChartView {
                        anchors.fill: parent
                        anchors.topMargin: 36
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: hizXEkseni
                            min: 0
                            max: 60
                        }

                        ValueAxis {
                            id: hizYEkseni
                            min: 0
                            max: 4
                        }

                        LineSeries {
                            id: hizSerisi
                            axisX: hizXEkseni
                            axisY: hizYEkseni
                            color: "#f59e0b"
                        }

                        Connections {
                            target: sensorManager
                            function onHizChanged() {
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
                    radius: 8
                    color: "#0f1420"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        text: "Debi - Zaman"
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    ChartView {
                        anchors.fill: parent
                        anchors.topMargin: 36
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: debiXEkseni
                            min: 0
                            max: 60
                        }

                        ValueAxis {
                            id: debiYEkseni
                            min: 0
                            max: 15
                        }

                        LineSeries {
                            id: debiSerisi
                            axisX: debiXEkseni
                            axisY: debiYEkseni
                            color: "#16a34a"
                        }

                        Connections {
                            target: sensorManager
                            function onDebiChanged() {
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
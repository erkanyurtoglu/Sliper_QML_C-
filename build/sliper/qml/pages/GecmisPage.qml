import QtQuick 6.7
import QtQuick.Controls 6.7

Rectangle {
    color: "#0a0e17"

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Row {
            width: parent.width
            spacing: 12

            TextField {
                id: aramaKutusu
                width: parent.width - filtreKutusu.width - parent.spacing
                height: 40
                placeholderText: "Müşteri veya reçete ara..."
                placeholderTextColor: "#4b5563"
                color: "#ffffff"
                font.pixelSize: 13
                leftPadding: 12
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: "#0f1420"
                    radius: 8
                    border.color: aramaKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                }
            }

            ComboBox {
                id: filtreKutusu
                width: 160
                height: 40
                model: ["Tüm Testler", "Son 7 Gün", "Son 30 Gün"]

                background: Rectangle {
                    color: "#0f1420"
                    radius: 8
                    border.color: "#1e2a3f"
                    border.width: 1
                }

                contentItem: Text {
                    text: filtreKutusu.displayText
                    color: "#9ca3af"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 56
            clip: true
            spacing: 10

            model: ListModel {
                ListElement { tarih: "31.07.2026 14:20"; musteri: "ABC İnşaat"; recete: "C25/30 Standart"; strokeSayisi: 24 }
                ListElement { tarih: "30.07.2026 09:15"; musteri: "XYZ Beton"; recete: "C30/37 SCC"; strokeSayisi: 18 }
                ListElement { tarih: "28.07.2026 16:42"; musteri: "Liya Test"; recete: "C35/45 Yuksek Mukavemet"; strokeSayisi: 15 }
                ListElement { tarih: "27.07.2026 11:05"; musteri: "ABC İnşaat"; recete: "C25/30 Standart"; strokeSayisi: 22 }
                ListElement { tarih: "25.07.2026 08:30"; musteri: "DEF Hazır Beton"; recete: "C30/37 SCC"; strokeSayisi: 20 }
            }

            delegate: Rectangle {
                width: parent.width
                height: 76
                radius: 8
                color: "#0f1420"
                border.color: "#1e2a3f"
                border.width: 1

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    spacing: 4

                    Text {
                        text: tarih
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                    }

                    Text {
                        text: "Müşteri: " + musteri + "  •  Reçete: " + recete
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        text: "Strokes: " + strokeSayisi
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                    }
                }

                Button {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    height: 34
                    text: "Görüntüle"
                    font.pixelSize: 12

                    background: Rectangle {
                        radius: 6
                        color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                        rightPadding: 8
                    }
                }
            }
        }
    }
}
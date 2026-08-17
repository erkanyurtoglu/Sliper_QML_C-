import QtQuick 6.7
import QtQuick.Controls 6.7

Rectangle {
    id: gecmisSayfasi
    color: "#0a0e17"

    signal testSecildi(int id)

    property var olcumListesi: []

    function listeyiYenile() {
        olcumListesi = database.tumOlcumleriGetir()
    }

    onVisibleChanged: {
        if (visible) {
            listeyiYenile()
        }
    }

    Component.onCompleted: listeyiYenile()

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
                leftPadding: 34
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: "#0f1420"
                    radius: 8
                    border.color: aramaKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "🔍"
                    color: "#4b5563"
                    font.pixelSize: 13
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
                    border.color: filtreKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
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

            model: gecmisSayfasi.olcumListesi

            delegate: Rectangle {
                id: gecmisKarti
                width: parent.width
                height: 76
                radius: 10
                color: "#0f1420"
                border.color: kartAlani.containsMouse ? "#3b82f6" : "#1e2a3f"
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id: kartAlani
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                Rectangle {
                    id: rozet
                    width: 44
                    height: 44
                    radius: 10
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    color: "#132335"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.musteri.charAt(0).toUpperCase()
                        color: "#3b82f6"
                        font.family: "Segoe UI"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Column {
                    anchors.left: rozet.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 14
                    spacing: 4

                    Row {
                        spacing: 8

                        Text {
                            text: modelData.tarih
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                        }

                        Rectangle {
                            width: strokeMetni.implicitWidth + 12
                            height: 16
                            radius: 8
                            color: "#2a2010"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: strokeMetni
                                anchors.centerIn: parent
                                text: modelData.strokeSayisi + " stroke"
                                color: "#e8a020"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: "Müşteri: " + modelData.musteri + "  •  Reçete: " + modelData.recete
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Button {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    height: 34
                    text: "Görüntüle"
                    font.pixelSize: 12

                    onClicked: testSecildi(modelData.id)

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
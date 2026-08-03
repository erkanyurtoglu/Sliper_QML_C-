import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7

Rectangle {
    color: "#0a0e17"

    property int seciliSensor: -1
    property int egimAdimi: 0
    property int loadCellAdimi: 0
    property int mesafeAdimi: 0

    StackLayout {
        anchors.fill: parent
        currentIndex: seciliSensor === -1 ? 0 : 1

        // Katman 0: Kart secim ekrani
        Item {
            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                text: "KALİBRASYON — Sensör Seçin"
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Row {
                anchors.centerIn: parent
                spacing: 24

                Rectangle {
                    id: egimKarti
                    width: 220
                    height: 260
                    radius: 12
                    color: "#0f1420"
                    border.color: egimKarti.hovered ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "📐"; font.pixelSize: 48 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Eğim Sensörü"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 15; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Yatay hizalama kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: egimKarti.hovered = true
                        onExited: egimKarti.hovered = false
                        onClicked: { seciliSensor = 0; egimAdimi = 0 }
                    }
                }

                Rectangle {
                    id: loadCellKarti
                    width: 220
                    height: 260
                    radius: 12
                    color: "#0f1420"
                    border.color: loadCellKarti.hovered ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "⚖️"; font.pixelSize: 48 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Load Cell"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 15; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Basınç sensörü kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: loadCellKarti.hovered = true
                        onExited: loadCellKarti.hovered = false
                        onClicked: { seciliSensor = 1; loadCellAdimi = 0 }
                    }
                }

                Rectangle {
                    id: mesafeKarti
                    width: 220
                    height: 260
                    radius: 12
                    color: "#0f1420"
                    border.color: mesafeKarti.hovered ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "📏"; font.pixelSize: 48 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Mesafe Sensörü"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 15; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Konum ölçümü kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 11 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: mesafeKarti.hovered = true
                        onExited: mesafeKarti.hovered = false
                        onClicked: { seciliSensor = 2; mesafeAdimi = 0 }
                    }
                }
            }
        }

        // Katman 1: Secili sensorun kalibrasyon ekrani
        Item {
            Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                spacing: 12

                Button {
                    text: "← Geri"
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

                    onClicked: seciliSensor = -1
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (seciliSensor === 0) return "Eğim Sensörü Kalibrasyonu"
                        if (seciliSensor === 1) return "Load Cell Kalibrasyonu"
                        if (seciliSensor === 2) return "Mesafe Sensörü Kalibrasyonu"
                        return ""
                    }
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            // ---- EĞİM SENSÖRÜ İÇERİĞİ (tek adım: sıfırlama) ----
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: 360

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Cihazı düz ve sabit bir yüzeye yerleştirin"
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "X: 0.0°   Y: 0.0°"
                        color: "#3b82f6"
                        font.family: "Segoe UI"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Button {
                        width: parent.width
                        height: 44
                        text: "Sıfırla (Zero)"
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // ---- LOAD CELL İÇERİĞİ (iki adım: sıfırlama + referans agirlik) ----
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 1

                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: 360

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Adım " + (loadCellAdimi + 1) + " / 2"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }

                    // Adim 0: Sifirlama
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: loadCellAdimi === 0

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: "Load cell üzerinde hiçbir ağırlık olmadığından emin olun"
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "0.0 mbar"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 24
                            font.bold: true
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Sıfırla ve Devam Et"
                            font.pixelSize: 14
                            font.bold: true

                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: loadCellAdimi = 1
                        }
                    }

                    // Adim 1: Referans agirlik
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: loadCellAdimi === 1

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: "Bilinen bir referans ağırlığı yerleştirin"
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 12

                            Button {
                                width: 100
                                height: 40
                                text: "1.6 kg"
                                font.pixelSize: 13

                                background: Rectangle {
                                    radius: 8
                                    color: parent.hovered ? "#1e2a3f" : "#0a0e17"
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
                                }
                            }

                            Button {
                                width: 100
                                height: 40
                                text: "4.8 kg"
                                font.pixelSize: 13

                                background: Rectangle {
                                    radius: 8
                                    color: parent.hovered ? "#1e2a3f" : "#0a0e17"
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
                                }
                            }
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Referansı Uygula ve Tamamla"
                            font.pixelSize: 14
                            font.bold: true

                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#22c55e" : "#16a34a"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: seciliSensor = -1
                        }
                    }
                }
            }

            // ---- MESAFE SENSÖRÜ İÇERİĞİ (iki adım: ust pozisyon + alt pozisyon) ----
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 2

                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: 360

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Adım " + (mesafeAdimi + 1) + " / 2"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }

                    // Adim 0: Ust pozisyon
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: mesafeAdimi === 0

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: "Boruyu üst pozisyona getirin ve sabitleyin"
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "0.0 mm"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 24
                            font.bold: true
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Üst Pozisyonu Kaydet"
                            font.pixelSize: 14
                            font.bold: true

                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: mesafeAdimi = 1
                        }
                    }

                    // Adim 1: Alt pozisyon
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: mesafeAdimi === 1

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: "Boruyu alt pozisyona getirin ve sabitleyin"
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "0.0 mm"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 24
                            font.bold: true
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Alt Pozisyonu Kaydet ve Tamamla"
                            font.pixelSize: 14
                            font.bold: true

                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#22c55e" : "#16a34a"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: seciliSensor = -1
                        }
                    }
                }
            }
        }
    }
}
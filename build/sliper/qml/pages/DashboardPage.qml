import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7

Rectangle {
    color: "#0a0e17"

    readonly property var navOgeleri: [
        { etiket: "Ölçüm", ikon: "📊" },
        { etiket: "Sonuçlar", ikon: "📈" },
        { etiket: "Geçmiş", ikon: "🕒" },
        { etiket: "Kalibrasyon", ikon: "⚙️" }
    ]

    Row {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: sidebar
            width: 230
            height: parent.height

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#121b30" }
                GradientStop { position: 1.0; color: "#080b12" }
            }

            Image {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
                source: "../assets/logo.png"
                width: 144
                height: 144
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                id: baglantiDurumu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 178
                height: 36
                radius: 6
                color: baglantiAlani.hoverli ? "#101a2c" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: wifiManager.baglandi ? "#16a34a" : (wifiManager.baglaniyor ? "#f59e0b" : "#dc2626")
                    }

                    Text {
                        text: wifiManager.baglandi ? "SLIPER-ESP32 Bağlı" : (wifiManager.baglaniyor ? "Bağlanıyor..." : "Bağlı Değil")
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: baglantiAlani
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !wifiManager.baglandi && !wifiManager.baglaniyor
                    onClicked: wifiManager.baglan()
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 224
                height: 1
                color: "#1f2c46"
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: 242
                width: parent.width
                spacing: 2

                Repeater {
                    model: navOgeleri

                    Rectangle {
                        id: navOgesi
                        width: parent.width
                        height: 46
                        property bool aktif: icerikStack.currentIndex === index
                        property bool hoverli: false
                        color: aktif ? "#182644" : (hoverli ? "#101a2c" : "transparent")
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Rectangle {
                            width: 3
                            height: parent.height
                            color: "#3b82f6"
                            visible: navOgesi.aktif
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Text {
                                text: modelData.ikon
                                font.pixelSize: 15
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.etiket
                                color: navOgesi.aktif ? "#6ea8ff" : (navOgesi.hoverli ? "#dce8f5" : "#9ca3af")
                                font.family: "Segoe UI"
                                font.pixelSize: 14
                                font.bold: navOgesi.aktif
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: navOgesi.hoverli = true
                            onExited: navOgesi.hoverli = false
                            onClicked: icerikStack.currentIndex = index
                        }
                    }
                }
            }
        }

        Rectangle {
            id: sidebarAyraci
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

        StackLayout {
            id: icerikStack
            width: parent.width - sidebar.width - sidebarAyraci.width
            height: parent.height
            currentIndex: 0

            OlcumPage {}

            SonuclarPage {
                id: sonuclarSayfasi
            }

            GecmisPage {
                onTestSecildi: function(id) {
                    sonuclarSayfasi.olcumId = id
                    icerikStack.currentIndex = 1
                }
            }

            KalibrasyonPage {}
        }
    }
}
import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import QtMultimedia

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
                id: bataryaGostergesi
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 190
                height: 22
                radius: 4
                visible: wifiManager.baglandi && sensorManager.bataryaVoltaj > 0.1
                color: {
                    if (sensorManager.bataryaVoltaj >= 14.5) return "#0f2417"
                    if (sensorManager.bataryaVoltaj >= 14.0) return "#2a2414"
                    return "#2a1414"
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "🔋 Batarya: " + sensorManager.bataryaVoltaj.toFixed(2) + " V"
                    color: {
                        if (sensorManager.bataryaVoltaj >= 14.5) return "#4ade80"
                        if (sensorManager.bataryaVoltaj >= 14.0) return "#e8a020"
                        return "#f87171"
                    }
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Rectangle {
                id: sesKontrolu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 218
                height: 30
                radius: 6
                color: sesKontroluAlani.hoverli ? "#101a2c" : "transparent"
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
                        color: !voiceCommandManager.modelHazir ? "#6b7280" : (voiceCommandManager.etkin ? "#16a34a" : "#dc2626")
                    }

                    Text {
                        text: "🎙 Sesli Komut: " + (!voiceCommandManager.modelHazir ? "Yükleniyor..." : (voiceCommandManager.etkin ? "Açık" : "Kapalı"))
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: sesKontroluAlani
                    property bool hoverli: false
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: voiceCommandManager.modelHazir
                    onEntered: hoverli = true
                    onExited: hoverli = false
                    onClicked: voiceCommandManager.etkin = !voiceCommandManager.etkin
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 256
                height: 1
                color: "#1f2c46"
            }

            Column {
                id: navColumn
                anchors.top: parent.top
                anchors.topMargin: 274
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

            MediaPlayer {
                id: simulasyonOynatici
                source: "../assets/slipergif.mp4"
                videoOutput: simulasyonVideo
                loops: 1
            }

            Item {
                id: simulasyonAlani
                anchors.top: navColumn.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 16
                anchors.topMargin: 20
                clip: true

                VideoOutput {
                    id: simulasyonVideo
                    anchors.fill: parent
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

            OlcumPage {
                onOlcumTamamlandi: function(id) {
                    sonuclarSayfasi.olcumId = id
                    icerikStack.currentIndex = 1
                }
                onAgirlikEklendi: {
                    simulasyonOynatici.stop()
                    simulasyonOynatici.play()
                }
            }

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
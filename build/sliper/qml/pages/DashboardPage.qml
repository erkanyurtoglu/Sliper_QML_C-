import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import QtMultimedia
import sliper

Rectangle {
    color: "#0a0e17"

    signal cikisYapildi()

    readonly property var navOgeleri: [
        { etiketTr: "Ölçüm", etiketEn: "Measurement", ikon: "olcum" },
        { etiketTr: "Sonuçlar", etiketEn: "Results", ikon: "sonuclar" },
        { etiketTr: "Geçmiş", etiketEn: "History", ikon: "gecmis" },
        { etiketTr: "Kalibrasyon", etiketEn: "Calibration", ikon: "kalibrasyon" },
        { etiketTr: "Rehber", etiketEn: "Guide", ikon: "rehber" }
    ]

    readonly property var metinler: ({
        baglandi: { tr: "SLIPER-ESP32 Bağlı", en: "SLIPER-ESP32 Connected" },
        baglaniyor: { tr: "Bağlanıyor...", en: "Connecting..." },
        bagliDegil: { tr: "Bağlı Değil", en: "Not Connected" },
        batarya: { tr: "🔋 Batarya: ", en: "🔋 Battery: " },
        sesliKomut: { tr: "🎙 Sesli Komut: ", en: "🎙 Voice Command: " },
        yukleniyor: { tr: "Yükleniyor...", en: "Loading..." },
        acik: { tr: "Açık", en: "On" },
        kapali: { tr: "Kapalı", en: "Off" },
        cikisYap: { tr: "Çıkış Yap", en: "Log Out" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

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
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 172
                height: 1
                color: "#1f2c46"
            }

            Row {
                anchors.top: parent.top
                anchors.topMargin: 184
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                Rectangle {
                    width: 32
                    height: 22
                    radius: 5
                    color: "#0f1420"
                    border.color: Translations.turkish ? "#3b82f6" : "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "TR"
                        color: Translations.turkish ? "#ffffff" : "#6b7280"
                        font.pixelSize: 10
                        font.bold: Translations.turkish
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Translations.turkish = true
                    }
                }

                Rectangle {
                    width: 32
                    height: 22
                    radius: 5
                    color: "#0f1420"
                    border.color: !Translations.turkish ? "#3b82f6" : "#1e2a3f"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "EN"
                        color: !Translations.turkish ? "#ffffff" : "#6b7280"
                        font.pixelSize: 10
                        font.bold: !Translations.turkish
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Translations.turkish = false
                    }
                }

                Rectangle {
                    id: cikisButonu
                    width: cikisMetni.implicitWidth + 16
                    height: 22
                    radius: 5
                    color: cikisAlani.pressed ? "#4c1414" : (cikisAlani.containsMouse ? "#3a1414" : "#1f1414")
                    border.color: "#7f1d1d"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        id: cikisMetni
                        anchors.centerIn: parent
                        text: txt("cikisYap")
                        color: "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        id: cikisAlani
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cikisYapildi()
                    }
                }
            }

            Rectangle {
                id: baglantiDurumu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 224
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
                        text: wifiManager.baglandi ? txt("baglandi") : (wifiManager.baglaniyor ? txt("baglaniyor") : txt("bagliDegil"))
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
                anchors.topMargin: 236
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
                    text: txt("batarya") + sensorManager.bataryaVoltaj.toFixed(2) + " V"
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
                anchors.topMargin: 264
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
                        text: txt("sesliKomut") + (!voiceCommandManager.modelHazir ? txt("yukleniyor") : (voiceCommandManager.etkin ? txt("acik") : txt("kapali")))
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
                anchors.topMargin: 302
                height: 1
                color: "#1f2c46"
            }

            Column {
                id: navColumn
                anchors.top: parent.top
                anchors.topMargin: 320
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

                            NavIkon {
                                tur: modelData.ikon
                                width: 17
                                height: 17
                                renk: navOgesi.aktif ? "#6ea8ff" : (navOgesi.hoverli ? "#dce8f5" : "#9ca3af")
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on renk { ColorAnimation { duration: 120 } }
                            }

                            Text {
                                text: Translations.turkish ? modelData.etiketTr : modelData.etiketEn
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

            RehberPage {}
        }
    }
}
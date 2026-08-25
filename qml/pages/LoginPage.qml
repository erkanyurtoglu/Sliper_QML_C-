import QtQuick 6.7
import QtQuick.Controls 6.7
import sliper

Rectangle {
    id: sayfa

    property bool sifreGorunur: false
    property bool beniHatirla: false

    signal girisBasarili()

    readonly property var metinler: ({
        girisBasligi: { tr: "Sisteme Giriş", en: "System Login" },
        girisAltBaslik: { tr: "Yetkili hesabınızla devam edin", en: "Continue with your authorized account" },
        kullaniciAdiEtiket: { tr: "KULLANICI ADI", en: "USERNAME" },
        kullaniciAdiPlaceholder: { tr: "kullanici_adi", en: "username" },
        sifreEtiket: { tr: "ŞİFRE", en: "PASSWORD" },
        girisYapButon: { tr: "Giriş Yap", en: "Log In" },
        telifHakki: { tr: "© 2026 Liya Test A.Ş. SLIPER Analiz Yazılımı", en: "© 2026 Liya Test A.Ş. SLIPER Analysis Software" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#15121a" }
        GradientStop { position: 0.55; color: "#0c0b0e" }
        GradientStop { position: 1.0; color: "#07070a" }
    }

    Rectangle {
        anchors.centerIn: kart
        width: 640
        height: 640
        radius: width / 2
        opacity: 0.10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3b82f6" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 8

        Rectangle {
            width: 44
            height: 30
            radius: 6
            color: "#12121a"
            border.color: Translations.turkish ? "#3b82f6" : "#1e2a3f"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "TR"
                color: Translations.turkish ? "#dce8f5" : "#6b7280"
                font.pixelSize: 12
                font.bold: Translations.turkish
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Translations.turkish = true
            }
        }

        Rectangle {
            width: 44
            height: 30
            radius: 6
            color: "#12121a"
            border.color: !Translations.turkish ? "#3b82f6" : "#1e2a3f"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "EN"
                color: !Translations.turkish ? "#dce8f5" : "#6b7280"
                font.pixelSize: 12
                font.bold: !Translations.turkish
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Translations.turkish = false
            }
        }
    }

    Rectangle {
        anchors.centerIn: kart
        width: kart.width + 48
        height: kart.height + 48
        radius: 28
        color: "#18000000"
    }

    Rectangle {
        anchors.centerIn: kart
        width: kart.width + 32
        height: kart.height + 32
        radius: 24
        color: "#25000000"
    }

    Rectangle {
        anchors.centerIn: kart
        width: kart.width + 18
        height: kart.height + 18
        radius: 20
        color: "#35000000"
    }

    Rectangle {
        anchors.centerIn: kart
        width: kart.width + 8
        height: kart.height + 8
        radius: 18
        color: "#45000000"
    }

    Rectangle {
        id: kart
        anchors.centerIn: parent
        width: 400
        color: "#12121a"
        radius: 16
        border.color: "#1e2a3f"
        border.width: 1
        height: govde.implicitHeight + 48

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: -1
            height: 3
            radius: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 0.5; color: "#3b82f6" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }

        Column {
            id: govde
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 32
            width: parent.width - 48
            spacing: 20

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../assets/logo.png"
                width: 144
                height: 144
                fillMode: Image.PreserveAspectFit
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Rectangle { width: 50; height: 1; color: "#1e2a3f"; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 5; height: 5; rotation: 45; color: "#3b82f6"; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 50; height: 1; color: "#1e2a3f"; anchors.verticalCenter: parent.verticalCenter }
            }

            Column {
                width: parent.width
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: txt("girisBasligi")
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 22
                    font.letterSpacing: 0.5
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: txt("girisAltBaslik")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: txt("kullaniciAdiEtiket")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                TextField {
                    id: kullaniciAdiKutusu
                    width: parent.width
                    height: 42
                    placeholderText: txt("kullaniciAdiPlaceholder")
                    placeholderTextColor: "#4b5563"
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: kullaniciAdiKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: txt("sifreEtiket")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                TextField {
                    id: sifreKutusu
                    width: parent.width
                    height: 42
                    placeholderText: "********"
                    placeholderTextColor: "#4b5563"
                    echoMode: sayfa.sifreGorunur ? TextInput.Normal : TextInput.Password
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 12
                    rightPadding: 48
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: sifreKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }

                    Rectangle {
                        id: sifreGosterButonu
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 8
                        width: 28
                        height: 28
                        radius: 6
                        color: sifreGosterMouse.pressed ? "#191921" : (sifreGosterMouse.containsMouse ? "#14141a" : "transparent")
                        border.color: sayfa.sifreGorunur ? "#334155" : "transparent"
                        border.width: 1

                        property color ikonRengi: sifreGosterMouse.containsMouse || sayfa.sifreGorunur ? "#dce8f5" : "#6b7280"

                        Canvas {
                            id: sifreIkonu
                            anchors.centerIn: parent
                            width: 18
                            height: 18

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.lineWidth = 1.7
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.strokeStyle = sifreGosterButonu.ikonRengi

                                ctx.beginPath()
                                ctx.moveTo(1.5, 9)
                                ctx.bezierCurveTo(4.2, 4.8, 7.0, 3.8, 9, 3.8)
                                ctx.bezierCurveTo(11.0, 3.8, 13.8, 4.8, 16.5, 9)
                                ctx.bezierCurveTo(13.8, 13.2, 11.0, 14.2, 9, 14.2)
                                ctx.bezierCurveTo(7.0, 14.2, 4.2, 13.2, 1.5, 9)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.arc(9, 9, 2.5, 0, Math.PI * 2, false)
                                ctx.stroke()

                                if (sayfa.sifreGorunur) {
                                    ctx.beginPath()
                                    ctx.moveTo(3, 15)
                                    ctx.lineTo(15, 3)
                                    ctx.stroke()
                                }
                            }

                            Connections {
                                target: sayfa
                                function onSifreGorunurChanged() {
                                    sifreIkonu.requestPaint()
                                }
                            }

                            Connections {
                                target: sifreGosterButonu
                                function onIkonRengiChanged() {
                                    sifreIkonu.requestPaint()
                                }
                            }
                        }

                        MouseArea {
                            id: sifreGosterMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sayfa.sifreGorunur = !sayfa.sifreGorunur
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 12
                        text: sayfa.sifreGorunur ? "👁" : "👁"
                        color: "#6b7280"
                        font.pixelSize: 14
                        visible: false

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sayfa.sifreGorunur = !sayfa.sifreGorunur
                        }
                    }
                }
            }

            Button {
                width: parent.width
                height: 44
                text: txt("girisYapButon")
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.letterSpacing: 0.5
                font.bold: true

                onClicked: {
                    var sonuc = backend.girisYap(kullaniciAdiKutusu.text, sifreKutusu.text)

                    if (sonuc) {
                        sayfa.girisBasarili()
                    } else {
                        console.log("Kullanici adi veya sifre hatali")
                    }
                }

                background: Rectangle {
                    radius: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: parent.pressed ? "#1d4ed8" : (parent.hovered ? "#dce8f5" : "#3b82f6") }
                        GradientStop { position: 1.0; color: parent.pressed ? "#1e3a8a" : (parent.hovered ? "#4f8cf7" : "#1d4ed8") }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: "#1e2a3f"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#17263d"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: txt("telifHakki")
                color: "#4b5563"
                font.family: "Segoe UI"
                font.pixelSize: 10
            }
        }
    }
}

import QtQuick 6.7
import QtQuick.Controls 6.7

Rectangle {
    id: sayfa

    signal girisBasarili()

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#101c33" }
        GradientStop { position: 1.0; color: "#0a1220" }
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
            color: "#0f1420"
            border.color: "#3b82f6"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "TR"
                color: "#ffffff"
                font.pixelSize: 12
                font.bold: true
            }
        }

        Rectangle {
            width: 44
            height: 30
            radius: 6
            color: "#0f1420"
            border.color: "#1e2a3f"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "EN"
                color: "#6b7280"
                font.pixelSize: 12
            }
        }
    }

    // Kartin golgesi - her yonden saran katmanli yari saydam dikdortgenler
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
        color: "#0f1420"
        radius: 16
        border.color: "#4b5563"
        border.width: 1
        height: govde.implicitHeight + 48

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

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "KULLANICI ADI"
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                TextField {
                    id: kullaniciAdiKutusu
                    width: parent.width
                    height: 42
                    placeholderText: "kullanici_adi"
                    placeholderTextColor: "#4b5563"
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0e17"
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
                    text: "ŞİFRE"
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
                    echoMode: TextInput.Password
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0e17"
                        radius: 6
                        border.color: sifreKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }
            }

            Button {
                width: parent.width
                height: 44
                text: "Giriş Yap"
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.bold: true

                onClicked: {

                    var sonuc = backend.girisYap(kullaniciAdiKutusu.text, sifreKutusu.text)
                    
                    if(sonuc)
                    {
                        sayfa.girisBasarili()
                    }

                    else
                    {
                        console.log("Kullanici adi veya sifre hatali")
                    }
                }

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? "#2563eb" : (parent.hovered ? "#4f8cf7" : "#3b82f6")
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

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u00A9 2026 Liya Test A.Ş. SLIPER Analiz Yazılımı"
                color: "#4b5563"
                font.family: "Segoe UI"
                font.pixelSize: 10
            }
        }
    }
}
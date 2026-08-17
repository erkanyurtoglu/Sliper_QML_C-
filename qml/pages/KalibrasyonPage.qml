import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import "../components"

Rectangle {
    color: "#0a0e17"
    
    property int seciliSensor: -1
    property int egimAdimi: 0
    property int loadCellAdimi: 0
    property int mesafeAdimi: 0

    property bool egimKayitliVar: false
    property string egimSonTarih: ""

    property bool loadCellKayitliVar: false
    property real loadCellReferans: 0
    property string loadCellSonTarih: ""
    property real loadCellSifirHam: 0

    property bool mesafeUstKayitliVar: false
    property bool mesafeAltKayitliVar: false
    property string mesafeSonTarih: ""
    
    onSeciliSensorChanged: {
        if (seciliSensor === 0) {
            var e = database.kalibrasyonGetir("egim")
            egimKayitliVar = e.mevcut
            egimSonTarih = e.mevcut ? e.tarih : ""
        } else if (seciliSensor === 1) {
            var l = database.kalibrasyonGetir("loadcell")
            loadCellKayitliVar = l.mevcut
            loadCellReferans = l.mevcut ? l.deger1 : 0
            loadCellSonTarih = l.mevcut ? l.tarih : ""
        } else if (seciliSensor === 2) {
            var u = database.kalibrasyonGetir("mesafe_ust")
            var a = database.kalibrasyonGetir("mesafe_alt")
            mesafeUstKayitliVar = u.mevcut
            mesafeAltKayitliVar = a.mevcut
            mesafeSonTarih = u.mevcut ? u.tarih : (a.mevcut ? a.tarih : "")
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: seciliSensor === -1 ? 0 : 1

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
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: egimKarti.hovered ? "#14b8a6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/egim_sensor.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Eğim Sensörü"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Yatay hizalama kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: egimKayitliVar
                            width: kaliMetni1.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni1
                                anchors.centerIn: parent
                                text: "✓ Kalibre Edildi"
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
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
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: loadCellKarti.hovered ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/loadcell.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Load Cell"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Basınç sensörü kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: loadCellKayitliVar
                            width: kaliMetni2.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni2
                                anchors.centerIn: parent
                                text: "✓ Kalibre Edildi"
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
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
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: mesafeKarti.hovered ? "#9333ea" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/mesafe_sensor.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Mesafe Sensörü"; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Konum ölçümü kalibrasyonu"; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: mesafeUstKayitliVar && mesafeAltKayitliVar
                            width: kaliMetni3.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni3
                                anchors.centerIn: parent
                                text: "✓ Kalibre Edildi"
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
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

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: {
                        if (seciliSensor === 0) return "#14b8a6"
                        if (seciliSensor === 1) return "#3b82f6"
                        if (seciliSensor === 2) return "#9333ea"
                        return "#6b7280"
                    }
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

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: egimKayitliVar
                        width: sonKaliMetni1.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: sonKaliMetni1
                            anchors.centerIn: parent
                            text: "Son kalibrasyon: " + egimSonTarih
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Cihazı düz ve sabit bir yüzeye yerleştirin"
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                    }

                    SuTerazisi {
                        anchors.horizontalCenter: parent.horizontalCenter
                        egimX: sensorManager.egimX
                        egimY: sensorManager.egimY
                    }
                    
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        height: 72
                        radius: 12
                        color: "#0f2e2a"
                        border.color: "#14b8a6"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "X: " + sensorManager.egimX.toFixed(1) + "°   Y: " + sensorManager.egimY.toFixed(1) + "°"
                            color: "#2dd4bf"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }

                    Button {
                        width: parent.width
                        height: 44
                        text: "Sıfırla (Zero)"
                        font.pixelSize: 14
                        font.bold: true

                        onClicked: {
                            var eskiKal = database.kalibrasyonGetir("egim")
                            var eskiOfsetX = eskiKal.mevcut ? eskiKal.deger1 : 0.0
                            var eskiOfsetY = eskiKal.mevcut ? eskiKal.deger2 : 0.0
                            var yeniOfsetX = eskiOfsetX + sensorManager.egimX
                            var yeniOfsetY = eskiOfsetY + sensorManager.egimY
                            database.kalibrasyonKaydet("egim", yeniOfsetX, yeniOfsetY)
                            console.log("Egim sensoru kalibrasyonu kaydedildi.")
                            seciliSensor = -1
                        }

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

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: loadCellKayitliVar
                        width: sonKaliMetni2.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: sonKaliMetni2
                            anchors.centerIn: parent
                            text: "Son referans: " + loadCellReferans.toFixed(1) + " kg — " + loadCellSonTarih
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Adım " + (loadCellAdimi + 1) + " / 2"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Repeater {
                            model: 2
                            Rectangle {
                                width: index === loadCellAdimi ? 22 : 8
                                height: 8
                                radius: 4
                                color: index <= loadCellAdimi ? "#3b82f6" : "#1e2a3f"
                                Behavior on width { NumberAnimation { duration: 150 } }
                            }
                        }
                    }

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

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 220
                            height: 72
                            radius: 12
                            color: "#132335"
                            border.color: "#3b82f6"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Ham deger: " + sensorManager.hamAgirlik.toFixed(0)
                                color: "#3b82f6"
                                font.family: "Segoe UI"
                                font.pixelSize: 22
                                font.bold: true
                            }
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

                            onClicked: {
                                loadCellSifirHam = sensorManager.hamAgirlik
                                loadCellAdimi = 1
                            }
                        }
                    }

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

                                onClicked: {
                                    var fark = sensorManager.hamAgirlik - loadCellSifirHam
                                    var katsayi = fark !== 0 ? fark / (1.6 * 1000) : 2280.0
                                    database.kalibrasyonKaydet("loadcell", katsayi, loadCellSifirHam)
                                    console.log("Load cell kalibrasyonu kaydedildi (1.6kg referans).")
                                    seciliSensor = -1
                                }

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

                                onClicked: {
                                    var fark = sensorManager.hamAgirlik - loadCellSifirHam
                                    var katsayi = fark !== 0 ? fark / (4.8 * 1000) : 2280.0
                                    database.kalibrasyonKaydet("loadcell", katsayi, loadCellSifirHam)
                                    console.log("Load cell kalibrasyonu kaydedildi (4.8kg referans).")
                                    seciliSensor = -1
                                }

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
                    }
                }
            }

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

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: mesafeUstKayitliVar || mesafeAltKayitliVar
                        width: sonKaliMetni3.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: sonKaliMetni3
                            anchors.centerIn: parent
                            text: "Son kalibrasyon: " + mesafeSonTarih
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Adım " + (mesafeAdimi + 1) + " / 2"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Repeater {
                            model: 2
                            Rectangle {
                                width: index === mesafeAdimi ? 22 : 8
                                height: 8
                                radius: 4
                                color: index <= mesafeAdimi ? "#9333ea" : "#1e2a3f"
                                Behavior on width { NumberAnimation { duration: 150 } }
                            }
                        }
                    }

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

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 220
                            height: 72
                            radius: 12
                            color: "#241a38"
                            border.color: "#9333ea"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: sensorManager.konum.toFixed(1) + " mm"
                                color: "#c084fc"
                                font.family: "Segoe UI"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Üst Pozisyonu Kaydet"
                            font.pixelSize: 14
                            font.bold: true

                            onClicked: {
                                database.kalibrasyonKaydet("mesafe_ust", sensorManager.konum, 0.0)
                                mesafeAdimi = 1
                            }

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

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 220
                            height: 72
                            radius: 12
                            color: "#241a38"
                            border.color: "#9333ea"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: sensorManager.konum.toFixed(1) + " mm"
                                color: "#c084fc"
                                font.family: "Segoe UI"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }

                        Button {
                            width: parent.width
                            height: 44
                            text: "Alt Pozisyonu Kaydet ve Tamamla"
                            font.pixelSize: 14
                            font.bold: true

                            onClicked: {
                                database.kalibrasyonKaydet("mesafe_alt", sensorManager.konum, 0.0)
                                seciliSensor = -1
                            }

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
                        }
                    }
                }
            }
        }
    }
}
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
    property string loadCellSonTarih: ""
    property int loadCellNoktaSayisi: 0
    property var loadCellNoktalari: []
    onLoadCellNoktalariChanged: loadCellAdimi = loadCellNoktalari.length
    property int loadCellToplamNokta: 10
    property bool loadCellSayiSecildi: false
    property int loadCellDuzenlemeIndex: -1

    property bool loadCellAraEkranGoster: false
    property bool loadCellGoruntuleModu: false
    property bool loadCellTamDuzenlemeModu: false
    property bool loadCellYenidenOnayGoster: false
    property bool loadCellTamamlandiOnayGoster: false

    property bool loadCellBildirimGoster: false
    property bool loadCellBildirimBasarili: true
    property string loadCellBildirimMesaj: ""

    property bool mesafeUstKayitliVar: false
    property bool mesafeAltKayitliVar: false
    property string mesafeSonTarih: ""

    function loadCellSiraliKopya(dizi) {
        var kopya = dizi.slice()
        kopya.sort(function(a, b) { return a.hamDeger - b.hamDeger })
        return kopya
    }

    function loadCellKaydetVeBildir() {
        var sirali = loadCellSiraliKopya(loadCellNoktalari)
        var basarili = database.loadCellNoktalariKaydet(sirali)
        loadCellBildirimBasarili = basarili
        loadCellBildirimMesaj = basarili ? "✓ Kalibrasyon kaydedildi" : "✕ Kalibrasyon kaydedilemedi, tekrar deneyin"
        loadCellBildirimGoster = true
        loadCellBildirimTimer.restart()
    }

    Timer {
        id: loadCellBildirimTimer
        interval: loadCellBildirimBasarili ? 1800 : 2500
        repeat: false
        onTriggered: {
            loadCellBildirimGoster = false
            if (loadCellBildirimBasarili) {
                seciliSensor = -1
            }
        }
    }

    onSeciliSensorChanged: {
        if (seciliSensor === 0) {
            var e = database.kalibrasyonGetir("egim")
            egimKayitliVar = e.mevcut
            egimSonTarih = e.mevcut ? e.tarih : ""
        } else if (seciliSensor === 1) {
            var noktalar = database.loadCellNoktalariGetir()
            loadCellKayitliVar = noktalar.length > 0
            loadCellNoktaSayisi = noktalar.length
            loadCellNoktalari = []
            loadCellSayiSecildi = false
            loadCellDuzenlemeIndex = -1
            loadCellTamDuzenlemeModu = false
            loadCellGoruntuleModu = false
            loadCellYenidenOnayGoster = false
            loadCellTamamlandiOnayGoster = false
            loadCellBildirimGoster = false
            loadCellAraEkranGoster = loadCellKayitliVar
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
                        onClicked: seciliSensor = 1
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
                    spacing: 24
                    width: 420
                    visible: loadCellAraEkranGoster

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: araEkranBadge.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: araEkranBadge
                            anchors.centerIn: parent
                            text: "Kayıtlı: " + loadCellNoktaSayisi + " nokta"
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Bu sensör için kayıtlı bir kalibrasyon bulundu"
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        Rectangle {
                            id: goruntuleKarti
                            width: 190
                            height: 180
                            radius: 14
                            color: "#0f1420"
                            border.color: goruntuleKarti.hovered ? "#3b82f6" : "#1e2a3f"
                            border.width: 1
                            property bool hovered: false
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 28

                                Canvas {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 32
                                    height: 32
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        ctx.lineWidth = 1.8
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"
                                        ctx.strokeStyle = "#3b82f6"

                                        ctx.beginPath()
                                        ctx.moveTo(3, 16)
                                        ctx.bezierCurveTo(7.5, 8.5, 12.5, 6.8, 16, 6.8)
                                        ctx.bezierCurveTo(19.5, 6.8, 24.5, 8.5, 29, 16)
                                        ctx.bezierCurveTo(24.5, 23.5, 19.5, 25.2, 16, 25.2)
                                        ctx.bezierCurveTo(12.5, 25.2, 7.5, 23.5, 3, 16)
                                        ctx.stroke()

                                        ctx.beginPath()
                                        ctx.arc(16, 16, 4.4, 0, Math.PI * 2, false)
                                        ctx.stroke()
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: "Mevcut Kalibrasyonu Görüntüle"
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: "Kayıtlı noktaları incele"
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: goruntuleKarti.hovered = true
                                onExited: goruntuleKarti.hovered = false
                                onClicked: {
                                    loadCellNoktalari = database.loadCellNoktalariGetir()
                                    loadCellAraEkranGoster = false
                                    loadCellGoruntuleModu = true
                                    loadCellDuzenlemeIndex = -1
                                }
                            }
                        }

                        Rectangle {
                            id: yenidenKarti
                            width: 190
                            height: 180
                            radius: 14
                            color: "#0f1420"
                            border.color: yenidenKarti.hovered ? "#9ca3af" : "#1e2a3f"
                            border.width: 1
                            property bool hovered: false
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 28

                                Canvas {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 32
                                    height: 32
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        ctx.strokeStyle = "#9ca3af"
                                        ctx.fillStyle = "#9ca3af"
                                        ctx.lineWidth = 3.4
                                        ctx.lineCap = "butt"

                                        function yayOku(startDeg, endDeg) {
                                            var s = startDeg * Math.PI / 180
                                            var e = endDeg * Math.PI / 180
                                            var cx = 16, cy = 16, r = 10.5

                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, s, e, false)
                                            ctx.stroke()

                                            var ex = cx + r * Math.cos(e)
                                            var ey = cy + r * Math.sin(e)
                                            var tx = -Math.sin(e)
                                            var ty = Math.cos(e)
                                            var px = -ty
                                            var py = tx
                                            var geri = 6.2
                                            var yaricap = 3.6
                                            var bx = ex - tx * geri
                                            var by = ey - ty * geri

                                            ctx.beginPath()
                                            ctx.moveTo(ex, ey)
                                            ctx.lineTo(bx + px * yaricap, by + py * yaricap)
                                            ctx.lineTo(bx - px * yaricap, by - py * yaricap)
                                            ctx.closePath()
                                            ctx.fill()
                                        }

                                        yayOku(195, 345)
                                        yayOku(15, 165)
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: "Yeniden Kalibre Et"
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: "Sıfırdan yeni ölçüm al"
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: yenidenKarti.hovered = true
                                onExited: yenidenKarti.hovered = false
                                onClicked: loadCellYenidenOnayGoster = true
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: 340
                    visible: loadCellGoruntuleModu

                    Text {
                        text: "KAYITLI KALİBRASYON NOKTALARI"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Rectangle {
                        width: parent.width
                        height: 320
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 16
                            clip: true
                            spacing: 8

                            model: loadCellNoktalari

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                radius: 8
                                color: "#0a0e17"
                                border.color: "#1e2a3f"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#182644"
                                        border.color: "#3b82f6"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: "#3b82f6"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            text: modelData.hedefKg.toFixed(2) + " kg"
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Text {
                                            text: "ADC: " + modelData.hamDeger.toFixed(0)
                                            color: "#6b7280"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        width: parent.width
                        height: 46
                        text: "Düzenle"
                        font.pixelSize: 14
                        font.bold: true

                        onClicked: {
                            loadCellToplamNokta = loadCellNoktalari.length
                            loadCellGoruntuleModu = false
                            loadCellTamDuzenlemeModu = true
                            loadCellSayiSecildi = true
                            loadCellDuzenlemeIndex = -1
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

                Rectangle {
                    anchors.fill: parent
                    color: "#000000b3"
                    visible: loadCellYenidenOnayGoster
                    z: 200

                    MouseArea { anchors.fill: parent }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 360
                        height: 200
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 18
                            width: parent.width - 40

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                text: "Mevcut kalibrasyon silinecek, emin misiniz?"
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 12

                                Button {
                                    width: 150
                                    height: 42
                                    text: "Vazgeç"

                                    onClicked: loadCellYenidenOnayGoster = false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#1e2a3f" : "transparent"
                                        border.color: "#1e2a3f"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#9ca3af"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: 150
                                    height: 42
                                    text: "Evet, Yeniden Başla"
                                    font.bold: true

                                    onClicked: {
                                        loadCellYenidenOnayGoster = false
                                        loadCellAraEkranGoster = false
                                        loadCellGoruntuleModu = false
                                        loadCellTamDuzenlemeModu = false
                                        loadCellNoktalari = []
                                        loadCellSayiSecildi = false
                                        loadCellDuzenlemeIndex = -1
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#b91c1c" : "#991b1b"
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

                Rectangle {
                    anchors.fill: parent
                    color: "#000000b3"
                    visible: loadCellTamamlandiOnayGoster
                    z: 200

                    MouseArea { anchors.fill: parent }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 380
                        height: 220
                        radius: 14
                        color: "#0f1420"
                        border.color: "#16a34a"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 18
                            width: parent.width - 40

                            Column {
                                width: parent.width
                                spacing: 6

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "Kalibrasyon Tamamlandı"
                                    color: "#4ade80"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 17
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: "Toplam " + loadCellToplamNokta + " nokta girildi. Bu kalibrasyonu kaydetmek istiyor musunuz?"
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                }
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 12

                                Button {
                                    width: 150
                                    height: 42
                                    text: "Noktaları Kontrol Et"

                                    onClicked: loadCellTamamlandiOnayGoster = false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#1e2a3f" : "transparent"
                                        border.color: "#1e2a3f"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#9ca3af"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: 150
                                    height: 42
                                    text: "Kaydet ve Bitir"
                                    font.bold: true

                                    onClicked: {
                                        loadCellTamamlandiOnayGoster = false
                                        loadCellKaydetVeBildir()
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

                Rectangle {
                    id: loadCellBildirimKutusu
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 12
                    z: 100
                    width: loadCellBildirimMetni.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: loadCellBildirimBasarili ? "#123321" : "#3a1414"
                    opacity: loadCellBildirimGoster ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Text {
                        id: loadCellBildirimMetni
                        anchors.centerIn: parent
                        text: loadCellBildirimMesaj
                        color: loadCellBildirimBasarili ? "#4ade80" : "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 24
                    width: 360
                    visible: !loadCellSayiSecildi && !loadCellAraEkranGoster && !loadCellGoruntuleModu

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Kaç noktalı kalibrasyon yapmak istersiniz?"
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Daha fazla nokta, daha hassas kalibrasyon sağlar"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                    }

                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 4
                        spacing: 12

                        Repeater {
                            model: [4, 6, 8, 10]

                            Rectangle {
                                id: secKarti
                                width: 72
                                height: 72
                                radius: 12
                                color: secKarti.hovered ? "#182644" : "#0f1420"
                                border.color: "#3b82f6"
                                border.width: 1
                                property bool hovered: false
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 26
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: secKarti.hovered = true
                                    onExited: secKarti.hovered = false
                                    onClicked: {
                                        loadCellToplamNokta = modelData
                                        loadCellNoktalari = []
                                        loadCellDuzenlemeIndex = -1
                                        loadCellSayiSecildi = true
                                    }
                                }
                            }
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 24
                    visible: loadCellSayiSecildi

                    Rectangle {
                        width: 340
                        height: 500
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 16
                            width: parent.width - 40

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: loadCellKayitliVar && !loadCellTamDuzenlemeModu
                                width: sonKaliMetni2.implicitWidth + 20
                                height: 24
                                radius: 12
                                color: "#0a0e17"
                                border.color: "#1e2a3f"
                                border.width: 1

                                Text {
                                    id: sonKaliMetni2
                                    anchors.centerIn: parent
                                    text: "Kayıtlı: " + loadCellNoktaSayisi + " nokta"
                                    color: "#6b7280"
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: loadCellTamDuzenlemeModu
                                      ? "Kalibrasyonu Düzenle"
                                      : "Nokta " + (loadCellNoktalari.length + 1) + " / " + loadCellToplamNokta
                                color: "#3b82f6"
                                font.family: "Segoe UI"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#1e2a3f"

                                Rectangle {
                                    width: parent.width * (loadCellNoktalari.length / loadCellToplamNokta)
                                    height: parent.height
                                    radius: 3
                                    color: "#3b82f6"
                                    Behavior on width { NumberAnimation { duration: 150 } }
                                }
                            }

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                text: loadCellDuzenlemeIndex >= 0
                                      ? "Nokta " + (loadCellDuzenlemeIndex + 1) + " düzenleniyor"
                                      : (loadCellTamDuzenlemeModu
                                         ? "Düzenlemek istediğiniz noktaya sağdaki listeden tıklayın"
                                         : "Hedef ağırlığı gir, sonra o ağırlığı load cell'e koy")
                                color: loadCellDuzenlemeIndex >= 0 ? "#3b82f6" : "#9ca3af"
                                font.family: "Segoe UI"
                                font.bold: loadCellDuzenlemeIndex >= 0
                                font.pixelSize: 13
                            }

                            TextField {
                                id: hedefKgKutusu
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 180
                                height: 44
                                placeholderText: "kg"
                                placeholderTextColor: "#4b5563"
                                color: "#ffffff"
                                font.pixelSize: 16
                                horizontalAlignment: TextInput.AlignHCenter
                                validator: DoubleValidator { bottom: 0; top: 500; decimals: 2 }
                                background: Rectangle {
                                    color: "#0a0e17"
                                    radius: 10
                                    border.color: hedefKgKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                height: 64
                                radius: 12
                                color: "#132335"
                                border.color: wifiManager.baglandi ? "#3b82f6" : "#dc2626"
                                border.width: 1
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Ham değer: " + sensorManager.hamAgirlik.toFixed(0)
                                    color: wifiManager.baglandi ? "#3b82f6" : "#f87171"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 20
                                    font.bold: true
                                }
                            }

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: !wifiManager.baglandi
                                text: "Cihaz bağlı değil — ham değer 0 olarak kaydedilecek"
                                color: "#f87171"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                            }

                            Button {
                                id: noktaKaydetButonu
                                width: parent.width
                                height: 46
                                property bool tumNoktalarGirildi: !loadCellTamDuzenlemeModu && loadCellDuzenlemeIndex < 0 && loadCellNoktalari.length >= loadCellToplamNokta
                                text: loadCellDuzenlemeIndex >= 0
                                      ? "Noktayı Güncelle"
                                      : (tumNoktalarGirildi
                                         ? "Kalibrasyonu Tamamla"
                                         : (loadCellNoktalari.length >= loadCellToplamNokta - 1 ? "Son Noktayı Kaydet" : "Bu Noktayı Kaydet"))
                                font.pixelSize: 14
                                font.bold: true
                                enabled: tumNoktalarGirildi || (hedefKgKutusu.text.length > 0 && (loadCellDuzenlemeIndex >= 0 || loadCellNoktalari.length < loadCellToplamNokta))

                                onClicked: {
                                    if (tumNoktalarGirildi) {
                                        loadCellTamamlandiOnayGoster = true
                                        return
                                    }

                                    var yeniNokta = { hedefKg: parseFloat(hedefKgKutusu.text), hamDeger: sensorManager.hamAgirlik }

                                    if (loadCellDuzenlemeIndex >= 0) {
                                        // Var olan bir noktayı yerinde güncelliyoruz, diğer noktalar etkilenmiyor
                                        var guncelDizi = loadCellNoktalari.slice()
                                        guncelDizi[loadCellDuzenlemeIndex] = yeniNokta
                                        loadCellNoktalari = guncelDizi
                                        loadCellDuzenlemeIndex = -1
                                        hedefKgKutusu.text = ""
                                        return
                                    }

                                    var yeniDizi = loadCellNoktalari.slice()
                                    yeniDizi.push(yeniNokta)
                                    loadCellNoktalari = yeniDizi
                                    hedefKgKutusu.text = ""

                                    if (loadCellNoktalari.length >= loadCellToplamNokta) {
                                        loadCellTamamlandiOnayGoster = true
                                    }
                                }

                                background: Rectangle {
                                    radius: 10
                                    color: parent.enabled ? (parent.hovered ? "#4f8cf7" : "#3b82f6") : "#1e2a3f"
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

                            Button {
                                width: parent.width
                                height: 46
                                visible: loadCellTamDuzenlemeModu
                                text: "Değişiklikleri Kaydet"
                                font.pixelSize: 14
                                font.bold: true

                                onClicked: loadCellKaydetVeBildir()

                                background: Rectangle {
                                    radius: 10
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

                            Button {
                                width: parent.width
                                height: 38
                                visible: loadCellDuzenlemeIndex >= 0
                                text: "Vazgeç"
                                font.pixelSize: 13

                                onClicked: {
                                    loadCellDuzenlemeIndex = -1
                                    hedefKgKutusu.text = ""
                                }

                                background: Rectangle {
                                    radius: 8
                                    color: parent.hovered ? "#1e2a3f" : "transparent"
                                    border.color: "#1e2a3f"
                                    border.width: 1
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#9ca3af"
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 300
                        height: 500
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20
                            spacing: 4

                            Text {
                                text: "KAYDEDİLEN NOKTALAR"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: "Düzeltmek için bir noktaya tıkla"
                                color: "#4b5563"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                            }
                        }

                        ListView {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 16
                            anchors.topMargin: 60
                            clip: true
                            spacing: 8

                            model: loadCellNoktalari

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                radius: 8
                                color: satirAlani.containsMouse ? "#182644" : "#0a0e17"
                                border.color: index === loadCellDuzenlemeIndex ? "#3b82f6" : "#1e2a3f"
                                border.width: index === loadCellDuzenlemeIndex ? 2 : 1
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#182644"
                                        border.color: "#3b82f6"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: "#3b82f6"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            text: modelData.hedefKg.toFixed(2) + " kg"
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Text {
                                            text: "ADC: " + modelData.hamDeger.toFixed(0)
                                            color: "#6b7280"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 12
                                    text: "✎"
                                    color: "#6b7280"
                                    font.pixelSize: 13
                                    visible: satirAlani.containsMouse
                                }

                                MouseArea {
                                    id: satirAlani
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        hedefKgKutusu.text = modelData.hedefKg.toString()
                                        loadCellDuzenlemeIndex = index
                                    }
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
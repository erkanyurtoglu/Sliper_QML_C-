import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7

Rectangle {
    color: "#0a0e17"

    property int olcumId: -1
    property real hesaplananTau0: 0
    property real hesaplananMu: 0
    property int playbackAdimi: -1
    property bool oynatiliyor: false
    property int playbackHizi: 1
    property string musteriAdi: ""
    property string receteAdi: ""

    onOlcumIdChanged: verileriYukle()

    function verileriYukle() {
        if (olcumId <= 0) {
            return
        }

        playbackAdimi = -1
        oynatiliyor = false
        playbackTimer.stop()

        var bilgi = database.olcumBilgisiGetir(olcumId)
        musteriAdi = bilgi.bulundu ? bilgi.musteri : "Bilinmiyor"
        receteAdi = bilgi.bulundu ? bilgi.recete : "Bilinmiyor"

        var sonuc = database.binghamHesapla(olcumId)

        hesaplananTau0 = sonuc.tau0
        hesaplananMu = sonuc.mu

        tau0Metni.text = sonuc.tau0.toFixed(2) + " mbar"
        muMetni.text = sonuc.mu.toFixed(2) + " mbar·h/m³"
        r2Metni.text = sonuc.r2.toFixed(2)

        durumKutusu.durumIyiMi = sonuc.yeterliVeri && sonuc.tau0 < 5 && sonuc.mu < 10
        durumKutusu.tau0Yuksek = sonuc.tau0 >= 5
        durumKutusu.muYuksek = sonuc.mu >= 10

        pqSerisi.clear()
        regresyonCizgisi.clear()
        oynatmaSerisi.clear()
        strokeModeli.clear()

        var strokeListesi = database.strokeVerileriGetir(olcumId)
        for (var i = 0; i < strokeListesi.length; i++) {
            var s = strokeListesi[i]
            pqSerisi.append(s.debi, s.basinc)
            strokeModeli.append({ stroke: s.stroke, p: s.basinc, q: s.debi, gecerli: s.gecerli })
        }

        regresyonCizgisi.append(0, sonuc.tau0)
        regresyonCizgisi.append(20, sonuc.tau0 + sonuc.mu * 20)
    }

    Timer {
        id: playbackTimer
        interval: 1000 / playbackHizi
        repeat: true
        running: false

        onTriggered: {
            if (playbackAdimi < strokeModeli.count - 1) {
                playbackAdimi++
                var satir = strokeModeli.get(playbackAdimi)
                oynatmaSerisi.clear()
                oynatmaSerisi.append(satir.q, satir.p)
            } else {
                oynatiliyor = false
                playbackTimer.stop()
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: ozetPaneli
            width: 280
            height: parent.height
            color: "#0f1420"

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                text: "SONUÇ ÖZETİ"
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Flickable {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20
                anchors.topMargin: 60
                contentWidth: width
                contentHeight: sonucKartlari.height
                clip: true

                Column {
                    id: sonucKartlari
                    width: parent.width
                    spacing: 10

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: 10
                        color: "#0a0e17"
                        border.color: "#17263d"
                        border.width: 1
                        clip: true

                        Rectangle { width: 4; height: parent.height; color: "#3b82f6" }

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 2

                            Text {
                                text: "AKMA GERİLMESİ (τ₀)"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            Text {
                                id: tau0Metni
                                text: "—"
                                color: "#3b82f6"
                                font.family: "Segoe UI"
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: 10
                        color: "#0a0e17"
                        border.color: "#241a38"
                        border.width: 1
                        clip: true

                        Rectangle { width: 4; height: parent.height; color: "#9333ea" }

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 2

                            Text {
                                text: "PLASTİK VİSKOZİTE (μ)"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            Text {
                                id: muMetni
                                text: "—"
                                color: "#9333ea"
                                font.family: "Segoe UI"
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: 10
                        color: "#0a0e17"
                        border.color: "#163321"
                        border.width: 1
                        clip: true

                        Rectangle { width: 4; height: parent.height; color: "#16a34a" }

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 2

                            Text {
                                text: "UYUM KALİTESİ (R²)"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            Text {
                                id: r2Metni
                                text: "—"
                                color: "#16a34a"
                                font.family: "Segoe UI"
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 10
                        color: "#0a0e17"
                        border.color: "#1e2a3f"
                        border.width: 1
                        height: tahminIcerik.implicitHeight + 24

                        Column {
                            id: tahminIcerik
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "BORU HATTI TAHMİNİ"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            TextField {
                                id: uzunlukKutusu
                                width: parent.width
                                height: 34
                                placeholderText: "Boru Uzunluğu (m)"
                                placeholderTextColor: "#4b5563"
                                color: "#ffffff"
                                font.pixelSize: 12
                                leftPadding: 10
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 0; top: 2000; decimals: 0 }
                                background: Rectangle {
                                    color: "#060d17"
                                    radius: 6
                                    border.color: uzunlukKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            TextField {
                                id: debiKutusu
                                width: parent.width
                                height: 34
                                placeholderText: "Hedef Debi (m³/h)"
                                placeholderTextColor: "#4b5563"
                                color: "#ffffff"
                                font.pixelSize: 12
                                leftPadding: 10
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 0; top: 200; decimals: 1 }
                                background: Rectangle {
                                    color: "#060d17"
                                    radius: 6
                                    border.color: debiKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            Button {
                                width: parent.width
                                height: 36
                                text: "Tahmini Hesapla"
                                font.pixelSize: 12
                                font.bold: true

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
                                }

                                onClicked: {
                                    var L = parseFloat(uzunlukKutusu.text)
                                    var Q = parseFloat(debiKutusu.text)

                                    if (isNaN(L) || isNaN(Q) || L <= 0) {
                                        tahminSonucu.text = "Geçerli değer girin"
                                        return
                                    }

                                    var basincMbar = (hesaplananTau0 + hesaplananMu * Q) * (L / 50)
                                    var basincBar = basincMbar / 1000
                                    tahminSonucu.text = basincBar.toFixed(2) + " bar"
                                }
                            }

                            Text {
                                id: tahminSonucu
                                width: parent.width
                                text: "—"
                                color: "#e8a020"
                                font.family: "Segoe UI"
                                font.pixelSize: 18
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        id: durumKutusu
                        width: parent.width
                        height: durumIcerik.implicitHeight + 24
                        radius: 10
                        color: durumIyiMi ? "#0f2417" : "#2a1414"
                        border.color: durumIyiMi ? "#16a34a" : "#dc2626"
                        border.width: 1

                        property bool durumIyiMi: true
                        property bool tau0Yuksek: false
                        property bool muYuksek: false

                        Column {
                            id: durumIcerik
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 12
                            spacing: 8
                            width: parent.width - 24

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 10

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: durumKutusu.durumIyiMi ? "#16a34a" : "#dc2626"

                                    Text {
                                        anchors.centerIn: parent
                                        text: durumKutusu.durumIyiMi ? "✓" : "✗"
                                        color: "#ffffff"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: durumKutusu.durumIyiMi ? "POMPALANABİLİR" : "POMPALAMA SORUNU"
                                    color: durumKutusu.durumIyiMi ? "#4ade80" : "#f87171"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                            }

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                visible: !durumKutusu.durumIyiMi
                                text: {
                                    if (durumKutusu.tau0Yuksek && durumKutusu.muYuksek) {
                                        return "Hem akma gerilmesi hem plastik viskozite yüksek. Su/çimento oranını artırın ve agrega gradasyonunu gözden geçirin."
                                    } else if (durumKutusu.tau0Yuksek) {
                                        return "Akma gerilmesi yüksek. Su/çimento oranını artırmayı veya süperakışkanlaştırıcı dozajını yükseltmeyi değerlendirin."
                                    } else if (durumKutusu.muYuksek) {
                                        return "Plastik viskozite yüksek. İnce agrega oranını azaltmayı veya su azaltıcı katkı eklemeyi değerlendirin."
                                    }
                                    return "Yeterli stroke verisi bulunamadı."
                                }
                                color: "#9ca3af"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Button {
                        width: parent.width
                        height: 40
                        text: "📄  PDF Rapor Oluştur"
                        font.pixelSize: 13
                        font.bold: true
                        enabled: olcumId > 0

                        onClicked: {
                            reportManager.pdfOlustur(
                                olcumId,
                                musteriAdi,
                                receteAdi,
                                hesaplananTau0,
                                hesaplananMu,
                                parseFloat(r2Metni.text)
                            )
                            console.log("PDF rapor olusturuldu.")
                        }

                        background: Rectangle {
                            radius: 8
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
                        height: 40
                        text: "📊  Excel (CSV) Olarak Dışa Aktar"
                        font.pixelSize: 13
                        font.bold: true
                        enabled: olcumId > 0

                        onClicked: {
                            database.csvDisaAktar(olcumId)
                            console.log("CSV disa aktarildi.")
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.hovered ? "#22c55e" : "#16a34a") : "#1e2a3f"
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

                    Rectangle {
                        width: parent.width
                        radius: 10
                        color: "#0a0e17"
                        border.color: "#1e2a3f"
                        border.width: 1
                        height: playbackIcerik.implicitHeight + 24
                        visible: olcumId > 0

                        Column {
                            id: playbackIcerik
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "OYNATMA (PLAYBACK)"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }

                            Text {
                                text: strokeModeli.count > 0
                                      ? "Stroke " + (playbackAdimi + 1) + " / " + strokeModeli.count
                                      : "Oynatilacak stroke yok"
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 12
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Button {
                                    width: 44
                                    height: 34
                                    text: oynatiliyor ? "⏸" : "▶"
                                    font.pixelSize: 14
                                    enabled: strokeModeli.count > 0

                                    onClicked: {
                                        if (oynatiliyor) {
                                            oynatiliyor = false
                                            playbackTimer.stop()
                                        } else {
                                            if (playbackAdimi >= strokeModeli.count - 1) {
                                                playbackAdimi = -1
                                            }
                                            oynatiliyor = true
                                            playbackTimer.start()
                                        }
                                    }

                                    background: Rectangle {
                                        radius: 6
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

                                Repeater {
                                    model: [1, 2, 5, 10]

                                    Button {
                                        width: 44
                                        height: 34
                                        text: modelData + "x"
                                        font.pixelSize: 12

                                        onClicked: playbackHizi = modelData

                                        background: Rectangle {
                                            radius: 6
                                            color: playbackHizi === modelData ? "#3b82f6" : "#0f1420"
                                            border.color: "#1e2a3f"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: playbackHizi === modelData ? "#ffffff" : "#9ca3af"
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
        }

        Rectangle {
            id: panelAyraci
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

        Item {
            width: parent.width - ozetPaneli.width - panelAyraci.width
            height: parent.height

            Rectangle {
                id: grafikKutusu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                height: parent.height * 0.55
                radius: 10
                color: "#0f1420"
                border.color: "#1e2a3f"
                border.width: 1

                Item {
                    id: grafikBaslik
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 14
                    height: 20

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "P-Q Dağılım Grafiği"
                        color: "#9ca3af"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#3b82f6"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Ölçüm Noktaları"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 12
                                height: 2
                                color: "#e8a020"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Regresyon Doğrusu"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#e8a020"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Oynatma"
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                ChartView {
                    anchors.top: grafikBaslik.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 4
                    anchors.margins: 8
                    backgroundColor: "transparent"
                    legend.visible: false
                    antialiasing: true

                    ValueAxis {
                        id: qEkseni
                        min: 0
                        max: 20
                        titleText: "Debi (Q) m³/h"
                        gridLineColor: "#182131"
                        labelsColor: "#4b5563"
                        labelsFont.pixelSize: 9
                        lineVisible: false
                        minorGridVisible: false
                    }

                    ValueAxis {
                        id: pEkseni
                        min: 0
                        max: 100
                        titleText: "Basınç (P) mbar"
                        gridLineColor: "#182131"
                        labelsColor: "#4b5563"
                        labelsFont.pixelSize: 9
                        lineVisible: false
                        minorGridVisible: false
                    }

                    ScatterSeries {
                        id: pqSerisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#3b82f6"
                        markerSize: 10
                    }

                    LineSeries {
                        id: regresyonCizgisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#e8a020"
                        width: 2
                    }

                    ScatterSeries {
                        id: oynatmaSerisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#e8a020"
                        markerSize: 16
                    }
                }
            }

            Rectangle {
                anchors.top: grafikKutusu.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 16
                anchors.topMargin: 8
                radius: 10
                color: "#0f1420"
                border.color: "#1e2a3f"
                border.width: 1

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 14
                    text: "Stroke Tablosu"
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                    font.bold: true
                }

                Row {
                    id: tabloBasligi
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 36
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Text { width: parent.width * 0.25; text: "STROKE"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: "P (mbar)"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: "Q (m³/h)"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                    Text { width: parent.width * 0.25; text: "DURUM"; color: "#6b7280"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                }

                Rectangle {
                    anchors.top: tabloBasligi.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    height: 1
                    color: "#1e2a3f"
                }

                ListView {
                    anchors.top: tabloBasligi.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    anchors.topMargin: 14
                    clip: true

                    model: ListModel {
                        id: strokeModeli
                    }

                    delegate: Rectangle {
                        width: parent.width
                        height: 32
                        radius: 6
                        color: index === playbackAdimi ? "#1e2a3f" : (index % 2 === 0 ? "transparent" : "#0a0e17")

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 6

                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: stroke; color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: p.toFixed(1); color: "#dce8f5"; font.pixelSize: 12 }
                            Text { width: parent.width * 0.25; anchors.verticalCenter: parent.verticalCenter; text: q.toFixed(2); color: "#dce8f5"; font.pixelSize: 12 }

                            Item {
                                width: parent.width * 0.25
                                height: parent.height

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: durumMetni.implicitWidth + 16
                                    height: 20
                                    radius: 10
                                    color: gecerli ? "#123321" : "#2a1414"

                                    Text {
                                        id: durumMetni
                                        anchors.centerIn: parent
                                        text: gecerli ? "Geçerli" : "Hatalı"
                                        color: gecerli ? "#4ade80" : "#f87171"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
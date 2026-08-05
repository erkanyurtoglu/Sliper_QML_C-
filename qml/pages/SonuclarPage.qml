import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7

Rectangle {
    color: "#0a0e17"

    Row {
        anchors.fill: parent
        spacing: 1

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

            Column {
                id: sonucKartlari
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                anchors.topMargin: 60
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
                            text: "0.84 mbar"
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
                            text: "4.55 mbar·h/m³"
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
                            text: "0.97"
                            color: "#16a34a"
                            font.family: "Segoe UI"
                            font.pixelSize: 20
                            font.bold: true
                        }
                    }
                }

                // ---- BORU HATTI TAHMİNİ ----
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

                                // Gecici mock formul - gercek Bingham hesabi backend'de yapilacak
                                var basincBar = (2.054 + 0.1306 * Q) * (L / 50)
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

                // ---- DURUM KUTUSU ----
                Rectangle {
                    id: durumKutusu
                    width: parent.width
                    height: durumIcerik.implicitHeight + 24
                    radius: 10
                    color: durumIyiMi ? "#0f2417" : "#2a1414"
                    border.color: durumIyiMi ? "#16a34a" : "#dc2626"
                    border.width: 1

                    property bool durumIyiMi: true

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
                            text: "Akma gerilmesi yüksek. Su/çimento oranını artırmayı veya süperakışkanlaştırıcı dozajını yükseltmeyi değerlendirin."
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width - ozetPaneli.width - parent.spacing
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

                        XYPoint { x: 6.99; y: 19.8 }
                        XYPoint { x: 7.55; y: 25.7 }
                        XYPoint { x: 7.86; y: 34.7 }
                        XYPoint { x: 11.58; y: 37.1 }
                        XYPoint { x: 11.49; y: 42.2 }
                        XYPoint { x: 14.25; y: 53.6 }
                        XYPoint { x: 14.61; y: 58.6 }
                    }

                    LineSeries {
                        id: regresyonCizgisi
                        axisX: qEkseni
                        axisY: pEkseni
                        color: "#e8a020"
                        width: 2

                        XYPoint { x: 0; y: 0.84 }
                        XYPoint { x: 20; y: 91.84 }
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
                        ListElement { stroke: 1; p: 19.8; q: 6.99; gecerli: true }
                        ListElement { stroke: 2; p: 25.7; q: 7.55; gecerli: true }
                        ListElement { stroke: 3; p: 34.7; q: 7.86; gecerli: true }
                        ListElement { stroke: 4; p: 37.1; q: 11.58; gecerli: true }
                        ListElement { stroke: 5; p: 42.2; q: 11.49; gecerli: false }
                        ListElement { stroke: 6; p: 53.6; q: 14.25; gecerli: true }
                        ListElement { stroke: 7; p: 58.6; q: 14.61; gecerli: true }
                    }

                    delegate: Rectangle {
                        width: parent.width
                        height: 32
                        radius: 6
                        color: index % 2 === 0 ? "transparent" : "#0a0e17"

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
import QtQuick 6.7
import QtQuick.Controls 6.7

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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
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
                    radius: 8
                    color: "#0a0e17"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
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
            }
        }

        Item {
            width: parent.width - ozetPaneli.width - parent.spacing
            height: parent.height

            Text {
                anchors.centerIn: parent
                text: "Grafik ve Tablo Buraya Gelecek"
                color: "#6b7280"
                font.pixelSize: 16
            }
        }
    }
}
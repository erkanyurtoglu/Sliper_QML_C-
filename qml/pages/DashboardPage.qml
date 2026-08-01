import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7


Rectangle {
    color: "#0a0e17"

    Row {
        anchors.fill: parent

        Rectangle {
            id: sidebar
            width: 220
            height: parent.height
            color: "#0f1420"

            Image {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
                source: "../assets/logo.png"
                width: 144
                height: 144
                fillMode: Image.PreserveAspectFit
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: 210
                width: parent.width

                Rectangle {
                    width: parent.width
                    height: 44
                    color: icerikStack.currentIndex === 0 ? "#1e2a3f" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Ölçüm"
                        color: icerikStack.currentIndex === 0 ? "#3b82f6" : "#9ca3af"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: icerikStack.currentIndex = 0
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 44
                    color: icerikStack.currentIndex === 1 ? "#1e2a3f" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Sonuçlar"
                        color: icerikStack.currentIndex === 1 ? "#3b82f6" : "#9ca3af"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: icerikStack.currentIndex = 1
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 44
                    color: icerikStack.currentIndex === 2 ? "#1e2a3f" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Geçmiş"
                        color: icerikStack.currentIndex === 2 ? "#3b82f6" : "#9ca3af"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: icerikStack.currentIndex = 2
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 44
                    color: icerikStack.currentIndex === 3 ? "#1e2a3f" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Kalibrasyon"
                        color: icerikStack.currentIndex === 3 ? "#3b82f6" : "#9ca3af"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: icerikStack.currentIndex = 3
                    }
                }
            }
        }

        StackLayout {
            id: icerikStack
            width: parent.width - sidebar.width
            height: parent.height
            currentIndex: 0

            OlcumPage {}
            SonuclarPage {}
            GecmisPage {}
            KalibrasyonPage {}
        }
    }
}
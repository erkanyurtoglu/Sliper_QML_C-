import QtQuick 6.7
import QtQuick.Controls 6.7

ApplicationWindow {
    visible: true
    width: 1920 
    height: 1080
    title: "SLIPER Analiz"

    background: Rectangle {
        color: "#060d17"
    }

    Loader {
        anchors.fill: parent
        source: "pages/LoginPage.qml"
    }
}
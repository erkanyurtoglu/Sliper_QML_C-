import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Window 6.7
import QtQuick.Layouts 6.7
import "pages"

ApplicationWindow {
    id: pencere
    visible: true
    visibility: Window.Maximized // rectangle içine alınca bozuluyor
    title: "SLIPER Analiz"

    background: Rectangle {
        color: "#060d17"
    }


    StackLayout {
        id: anaStack
        anchors.fill: parent
        currentIndex: 0

        LoginPage {
            onGirisBasarili: anaStack.currentIndex = 1
        }

        DashboardPage {
        }
    }
}

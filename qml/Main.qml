import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Window 6.7
import QtQuick.Layouts 6.7
import "pages"

ApplicationWindow {
    id: pencere
    visibility: Window.Maximized
    title: "SLIPER Analiz"

    background: Rectangle {
        color: "#07070a"
    }

    StackLayout {
        id: anaStack
        anchors.fill: parent
        currentIndex: 0

        LoginPage {
            onGirisBasarili: anaStack.currentIndex = 1
        }

        DashboardPage {
            onCikisYapildi: anaStack.currentIndex = 0
        }
    }
}
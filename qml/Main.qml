import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Window 

ApplicationWindow {
    visible: true
    visibility: Window.Maximized //Görev çubuğu görünür kalır, pencere "büyütülmüş" hâlde açılır.
    title: "SLIPER Analiz"

    background: Rectangle {
        color: "#060d17"
    }

    Loader {
        id: sayfaYukleyici
        anchors.fill: parent
        source: "pages/LoginPage.qml"

        onLoaded: {
            item.girisBasarili.connect(function() {
                sayfaYukleyici.source = "pages/DashboardPage.qml"
            })
        }
    }
}
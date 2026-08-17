import QtQuick 6.7

Item {
    id: root
    property real egimX: 0
    property real egimY: 0
    property real maxAci: 15

    width: 200
    height: 200

    readonly property real yaricap: (width / 2) - 20
    readonly property bool duz: Math.abs(egimX) < 0.5 && Math.abs(egimY) < 0.5

    readonly property real kabarcikOfsetX: Math.max(-1, Math.min(1, egimY / maxAci)) * yaricap
    readonly property real kabarcikOfsetY: Math.max(-1, Math.min(1, egimX / maxAci)) * yaricap

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#0f1420"
        border.color: "#1e2a3f"
        border.width: 2
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.yaricap * 1.2
        height: width
        radius: width / 2
        color: "transparent"
        border.color: "#1e2a3f"
        border.width: 1
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 20
        height: 1
        color: "#1e2a3f"
    }

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: parent.height - 20
        color: "#1e2a3f"
    }

    Rectangle {
        id: kabarcik
        width: 28
        height: 28
        radius: 14
        color: root.duz ? "#16a34a" : "#dc2626"
        border.color: root.duz ? "#4ade80" : "#f87171"
        border.width: 2

        x: (root.width / 2) - (width / 2) + root.kabarcikOfsetX
        y: (root.height / 2) - (height / 2) + root.kabarcikOfsetY

        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    Text {
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        text: root.duz ? "Düz" : "Ayarlanıyor..."
        color: root.duz ? "#4ade80" : "#6b7280"
        font.family: "Segoe UI"
        font.pixelSize: 12
        font.bold: root.duz
    }
}
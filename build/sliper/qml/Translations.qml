pragma Singleton
import QtQuick

QtObject {
    property bool turkish: true

    function toggle() {
        turkish = !turkish
    }
}

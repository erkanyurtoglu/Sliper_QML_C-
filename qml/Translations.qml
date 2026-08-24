pragma Singleton
import QtQuick

QtObject {
    // true = Türkçe, false = English
    property bool turkish: true

    function toggle() {
        turkish = !turkish
    }
}

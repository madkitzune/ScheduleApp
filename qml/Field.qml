import QtQuick
import QtQuick.Controls
TextField {
    id: root
    property color green: "#39ff14"
    height: 36; leftPadding: 10
    font.pixelSize: 12; font.family: "Consolas"
    color: "#e0e0e0"
    placeholderTextColor: "#404040"
    background: Rectangle {
        radius: 3
        color: "#111111"
        border.color: root.activeFocus ? root.green : "#2a2a2a"
        border.width: root.activeFocus ? 1 : 1
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }
}

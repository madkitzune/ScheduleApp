import QtQuick
import QtQuick.Controls
TextField {
    id: root
    property color green:   "#00cc44"
    property string placeholder: ""
    placeholderText: placeholder
    height: 32; leftPadding: 8
    font.pixelSize: 12; font.family: "Consolas"
    color: "#cccccc"; placeholderTextColor: "#3a3a3a"
    background: Rectangle {
        radius: 2; color: "#111111"
        border.color: root.activeFocus ? root.green : "#252525"
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }
}

import QtQuick
Rectangle {
    id: root
    required property string label
    property color accent:  "#00cc44"
    property bool  ghost:   false
    height: 36; radius: 3

    color: ghost ? "transparent" : (ma.containsMouse ? "#141414" : "#0a0a0a")
    border.color: ghost ? accent : "#1e1e1e"
    border.width: ghost ? 1 : 1

    signal clicked

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.accent
        font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
    }

    // Зелена лінія знизу (тільки для не-ghost)
    Rectangle {
        visible: !root.ghost
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2; radius: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.2; color: root.accent }
            GradientStop { position: 0.8; color: root.accent }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
    Behavior on color { ColorAnimation { duration: 80 } }
}

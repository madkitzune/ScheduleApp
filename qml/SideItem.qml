// SideItem.qml — пункт бокового меню
import QtQuick

Rectangle {
    id: root
    height: 44

    required property string label
    required property string icon
    required property bool   active
    required property bool   expanded
    required property color  bg
    required property color  panel
    required property color  hover
    required property color  sel
    required property color  green
    required property color  greenDim
    required property color  textCol
    required property color  dimCol

    signal clicked

    color: active ? sel : (hov.containsMouse ? hover : "transparent")

    // Зелена лінія зліва для активного
    Rectangle {
        width: 3; height: parent.height
        color: green
        visible: active
        anchors.left: parent.left
    }

    // Зелена підсвітка знизу (градієнт)
    Rectangle {
        visible: active
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: greenDim
    }

    Row {
        anchors { left: parent.left; leftMargin: active ? 17 : 14; verticalCenter: parent.verticalCenter }
        spacing: 12

        // Іконка (монопростір символ)
        Text {
            text: icon
            color: active ? green : dimCol
            font.pixelSize: 14
            font.family: "Consolas"
            font.bold: true
            width: 18
            horizontalAlignment: Text.AlignHCenter
        }

        // Назва
        Text {
            text: label
            color: active ? green : textCol
            font.pixelSize: 13
            font.family: "Segoe UI"
            font.bold: active
            opacity: expanded ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    HoverHandler { id: hov }
    TapHandler  { onTapped: root.clicked() }
    Behavior on color { ColorAnimation { duration: 80 } }
}

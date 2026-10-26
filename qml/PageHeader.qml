import QtQuick
Item {
    id: root
    required property string title
    required property string subtitle
    required property var    colors
    height: 56

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Text {
            text: root.title
            color: "#cccccc"
            font.pixelSize: 18
            font.bold: true
            font.family: "Segoe UI"
        }
        Text {
            text: root.subtitle
            color: "#484848"
            font.pixelSize: 11
            font.family: "Segoe UI"
        }
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#1e1e1e"
    }
}

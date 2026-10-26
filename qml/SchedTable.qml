import QtQuick
import QtQuick.Controls

Item {
    id: root
    required property var model
    property int selectedRow: -1
    signal rowSelected(int index)

    readonly property var heads:  ["#", "Предмет", "Початок", "Аудиторія", "Викладач", "Хв."]
    readonly property var ww:     [36,  240,        72,        88,           200,         52]

    // Заголовок
    Rectangle {
        id: hdr
        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.top:   parent.top
        height: 32
        color: "#141414"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: heads
                Text {
                    width: ww[index]
                    text: modelData
                    color: "#00cc44"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "Consolas"
                    elide: Text.ElideRight
                    leftPadding: 4
                }
            }
        }

        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#222222"
        }
    }

    // Список рядків
    ListView {
        id: lv
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.top:    hdr.bottom
        anchors.bottom: parent.bottom
        clip: true
        model: root.model

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                radius: 2
                color: "#00cc44"
                opacity: 0.4
            }
        }

        delegate: Rectangle {
            id: row
            width: lv.width
            height: 38

            property bool isSelected: root.selectedRow === index
            color: isSelected ? "#0a1f00" : (index % 2 === 0 ? "#0d0d0d" : "#111111")

            Rectangle {
                width: 2
                height: parent.height
                color: "#00cc44"
                visible: row.isSelected
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                Text { width: ww[0]; text: index+1;   color: "#555555"; font.pixelSize: 11; font.family: "Consolas"; leftPadding: 4 }
                Text { width: ww[1]; text: subject;   color: "#cccccc"; font.pixelSize: 11; font.family: "Segoe UI"; elide: Text.ElideRight; leftPadding: 4 }
                Text { width: ww[2]; text: startTime; color: "#00cc44"; font.pixelSize: 11; font.family: "Consolas"; leftPadding: 4 }
                Text { width: ww[3]; text: room;      color: "#cccccc"; font.pixelSize: 11; font.family: "Segoe UI"; leftPadding: 4 }
                Text { width: ww[4]; text: teacher;   color: "#cccccc"; font.pixelSize: 11; font.family: "Segoe UI"; elide: Text.ElideRight; leftPadding: 4 }
                Text { width: ww[5]; text: duration;  color: "#555555"; font.pixelSize: 11; font.family: "Consolas"; leftPadding: 4 }
            }

            Rectangle {
                anchors.left:   parent.left
                anchors.right:  parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#1a1a1a"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.selectedRow = index
                    root.rowSelected(index)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.model.count === 0
            text: "[ no records ]"
            color: "#2a2a2a"
            font.pixelSize: 14
            font.family: "Consolas"
        }
    }
}

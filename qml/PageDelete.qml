import QtQuick
Item {
    required property var model
    required property var colors
    property int selIdx: -1

    Column {
        anchors.fill: parent; anchors.margins: 24; spacing: 10

        PageHeader { title: "Delete"; subtitle: "Click row to select, set count, press Delete"; colors: colors; width: parent.width }

        Rectangle {
            width: parent.width; height: 50
            color: "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1; radius: 3

            Row {
                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 9; anchors.bottomMargin: 9
                spacing: 10

                Text { text: "From row:"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: selIdx >= 0 ? "#"+(selIdx+1) : "— click a row —"
                    color: selIdx >= 0 ? "#cc3333" : "#484848"
                    font.pixelSize: 11; font.bold: selIdx >= 0; font.family: "Consolas"
                    anchors.verticalCenter: parent.verticalCenter; width: 130
                }
                Item { width: parent.width - 130 - 170 - 80 - 50; height: 1 }
                Text { text: "Count (0=end):"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 60; height: 32; radius: 2; color: "#111"; border.color: cntF.activeFocus ? "#cc3333" : "#252525"; border.width: 1
                    TextInput { id: cntF; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "0" }
                }
                Rectangle {
                    width: 80; height: 32; radius: 3
                    color: delMA.containsMouse ? "#991111" : "#cc3333"
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Delete"; color: "#fff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    MouseArea {
                        id: delMA; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (selIdx < 0) return
                            model.deleteFrom(selIdx, parseInt(cntF.text)||0)
                            selIdx = -1; cntF.text = "0"
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }

        SchedTable {
            width: parent.width
            height: parent.height - 130
            model: parent.parent.model
            onRowSelected: function(i) { parent.parent.selIdx = i }
        }
    }
}

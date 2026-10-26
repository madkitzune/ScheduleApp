import QtQuick
Item {
    required property var model
    required property var colors
    property string searchResult: ""

    Column {
        anchors.fill: parent; anchors.margins: 24; spacing: 10

        PageHeader { title: "Sort / Search"; subtitle: "Shell Sort by time  +  Binary search by subject"; colors: colors; width: parent.width }

        Rectangle {
            width: parent.width; height: 50
            color: "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1; radius: 3

            Row {
                anchors.fill: parent; anchors.margins: 10; spacing: 10

                // Кнопка Sort
                Rectangle {
                    width: 180; height: 32; radius: 3
                    color: sortMA.containsMouse ? "#141414" : "#0a0a0a"
                    border.color: "#1e1e1e"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Shell Sort by Time"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 2; radius: 1
                        gradient: Gradient { orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#00cc44" }
                            GradientStop { position: 0.7; color: "#00cc44" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    MouseArea { id: sortMA; anchors.fill: parent; hoverEnabled: true; onClicked: model.sortByTime() }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                // Поле пошуку — займає залишок мінус кнопка
                Rectangle {
                    width: parent.width - 180 - 140 - 30; height: 32; radius: 2
                    color: "#111111"; border.color: sf.activeFocus ? "#00cc44" : "#252525"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    TextInput {
                        id: sf; anchors.fill: parent; anchors.margins: 8
                        color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"
                        clip: true
                    }
                    Text { anchors.fill: parent; anchors.margins: 8; text: "Subject name..."; color: "#333"; font.pixelSize: 12; visible: sf.text === "" }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                }

                // Кнопка Binary Search
                Rectangle {
                    width: 140; height: 32; radius: 3
                    color: "transparent"; border.color: "#00cc44"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Binary Search"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    MouseArea { anchors.fill: parent; onClicked: { searchResult = model.searchBySubject(sf.text) } }
                }
            }
        }

        // Результат пошуку
        Rectangle {
            width: parent.width
            height: searchResult === "" ? 0 : 80
            visible: searchResult !== ""
            color: "#080808"; border.color: "#00cc44"; border.width: 1; radius: 3; clip: true
            Behavior on height { NumberAnimation { duration: 150 } }
            Text {
                anchors.fill: parent; anchors.margins: 10
                text: searchResult; color: "#00cc44"; font.pixelSize: 12; font.family: "Consolas"
                wrapMode: Text.WordWrap; lineHeight: 1.4; elide: Text.ElideRight
            }
        }

        SchedTable {
            width: parent.width
            height: parent.height - (searchResult === "" ? 140 : 240)
            model: parent.parent.model
        }
    }
}

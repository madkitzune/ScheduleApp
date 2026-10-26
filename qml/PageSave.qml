import QtQuick
import QtQuick.Dialogs
Item {
    required property var model
    required property var colors

    FileDialog { id: dTxt; title: "Save TXT";    fileMode: FileDialog.SaveFile; nameFilters: ["TXT (*.txt)"];            onAccepted: model.saveToFile(selectedFile) }
    FileDialog { id: dSql; title: "Save SQLite"; fileMode: FileDialog.SaveFile; nameFilters: ["SQLite (*.db *.sqlite)"]; onAccepted: model.saveToSqlite(selectedFile) }

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        PageHeader { title: "Save Data"; subtitle: "Save schedule to file"; colors: colors; width: parent.width }

        Rectangle {
            width: parent.width; height: 90; radius: 3
            color: "#0d0d0d"; border.color: "#1e1e1e"; border.width: 1
            Row {
                anchors.fill: parent; anchors.margins: 20; spacing: 16
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 5; width: parent.width - 170
                    Text { text: "Text File  (.txt)"; color: "#cccccc"; font.pixelSize: 14; font.bold: true; font.family: "Segoe UI" }
                    Text { text: "Saves in format: subject|startHHMM|room|teacher|duration"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI" }
                }
                Rectangle {
                    width: 140; height: 38; radius: 3
                    color: stMA.containsMouse ? "#141414" : "#0a0a0a"
                    border.color: "#1e1e1e"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Save TXT"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                        height: 2; radius: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#00cc44" }
                            GradientStop { position: 0.7; color: "#00cc44" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    MouseArea { id: stMA; anchors.fill: parent; hoverEnabled: true; onClicked: dTxt.open() }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }

        Rectangle {
            width: parent.width; height: 90; radius: 3
            color: "#0d0d0d"; border.color: "#1e1e1e"; border.width: 1
            Row {
                anchors.fill: parent; anchors.margins: 20; spacing: 16
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 5; width: parent.width - 170
                    Text { text: "SQLite DB  (.db)"; color: "#cccccc"; font.pixelSize: 14; font.bold: true; font.family: "Segoe UI" }
                    Text { text: "Writes to schedule table in SQLite database"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI" }
                }
                Rectangle {
                    width: 140; height: 38; radius: 3
                    color: ssMA.containsMouse ? "#141414" : "#0a0a0a"
                    border.color: "#1e1e1e"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Save SQLite"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                        height: 2; radius: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#00cc44" }
                            GradientStop { position: 0.7; color: "#00cc44" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    MouseArea { id: ssMA; anchors.fill: parent; hoverEnabled: true; onClicked: dSql.open() }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }
        Item { height: 1; width: 1 }
    }
}

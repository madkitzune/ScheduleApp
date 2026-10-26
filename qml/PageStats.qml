import QtQuick
Item {
    required property var model
    required property var colors
    property string result:   ""
    property string errorMsg: ""

    function validate() {
        errorMsg = ""
        var fh = parseInt(fH.text), fm = parseInt(fM.text)
        var th = parseInt(tH.text), tm = parseInt(tM.text)
        if (isNaN(fh) || fh < 0 || fh > 23) { errorMsg = "Від: години від 00 до 23"; return false }
        if (isNaN(fm) || fm < 0 || fm > 59)  { errorMsg = "Від: хвилини від 00 до 59"; return false }
        if (isNaN(th) || th < 0 || th > 23) { errorMsg = "До: години від 00 до 23"; return false }
        if (isNaN(tm) || tm < 0 || tm > 59)  { errorMsg = "До: хвилини від 00 до 59"; return false }
        var from = fh*100+fm, to = th*100+tm
        if (from >= to) { errorMsg = "Початок діапазону має бути меншим за кінець"; return false }
        return true
    }

    Column {
        anchors.fill: parent; anchors.margins: 24; spacing: 10

        PageHeader { title: "Statistics"; subtitle: "Min / Max / Avg for selected time range"; colors: colors; width: parent.width }

        Rectangle {
            width: parent.width; height: 50
            color: "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1; radius: 3

            Row {
                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; anchors.topMargin: 9; anchors.bottomMargin: 9
                spacing: 8

                Text { text: "Від HH:"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 44; height: 32; radius: 2; color: "#111111"; border.width: 1
                    border.color: fH.activeFocus ? "#00cc44" : (fH.text !== "" && (parseInt(fH.text) < 0 || parseInt(fH.text) > 23) ? "#cc4400" : "#252525")
                    TextInput { id: fH; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "08"; inputMethodHints: Qt.ImhDigitsOnly }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                }
                Text { text: ":"; color: "#00cc44"; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 44; height: 32; radius: 2; color: "#111111"; border.width: 1
                    border.color: fM.activeFocus ? "#00cc44" : (fM.text !== "" && (parseInt(fM.text) < 0 || parseInt(fM.text) > 59) ? "#cc4400" : "#252525")
                    TextInput { id: fM; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "00"; inputMethodHints: Qt.ImhDigitsOnly }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                }

                Text { text: "  До HH:"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 44; height: 32; radius: 2; color: "#111111"; border.width: 1
                    border.color: tH.activeFocus ? "#00cc44" : (tH.text !== "" && (parseInt(tH.text) < 0 || parseInt(tH.text) > 23) ? "#cc4400" : "#252525")
                    TextInput { id: tH; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "17"; inputMethodHints: Qt.ImhDigitsOnly }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                }
                Text { text: ":"; color: "#00cc44"; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 44; height: 32; radius: 2; color: "#111111"; border.width: 1
                    border.color: tM.activeFocus ? "#00cc44" : (tM.text !== "" && (parseInt(tM.text) < 0 || parseInt(tM.text) > 59) ? "#cc4400" : "#252525")
                    TextInput { id: tM; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "00"; inputMethodHints: Qt.ImhDigitsOnly }
                    Behavior on border.color { ColorAnimation { duration: 100 } }
                }

                Rectangle {
                    width: 120; height: 32; radius: 3
                    color: calcMA.containsMouse ? "#141414" : "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "Calculate"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 2; radius: 1
                        gradient: Gradient { orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#00cc44" }
                            GradientStop { position: 0.7; color: "#00cc44" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    MouseArea {
                        id: calcMA; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (!validate()) { result = ""; return }
                            var from = (parseInt(fH.text)||0)*100 + (parseInt(fM.text)||0)
                            var to   = (parseInt(tH.text)||0)*100 + (parseInt(tM.text)||0)
                            result = model.rangeStats(from, to)
                            errorMsg = ""
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }

        // Помилка валідації
        Text {
            visible: errorMsg !== ""; width: parent.width; height: errorMsg !== "" ? 22 : 0
            text: "  ⚠  " + errorMsg; color: "#cc4400"; font.pixelSize: 11; font.family: "Segoe UI"
        }

        // Результат
        Rectangle {
            width: parent.width; height: 90
            color: "#080808"
            border.color: result === "" ? "#1e1e1e" : "#00cc44"; border.width: 1; radius: 3; clip: true
            Text {
                anchors.fill: parent; anchors.margins: 12
                text: result === "" ? "[ введіть діапазон і натисніть Calculate ]" : result
                color: result === "" ? "#333" : "#00cc44"
                font.pixelSize: 12; font.family: "Consolas"; wrapMode: Text.WordWrap; lineHeight: 1.4
            }
        }

        SchedTable {
            width: parent.width
            height: parent.height - (errorMsg !== "" ? 280 : 258)
            model: parent.parent.model
        }
    }
}

import QtQuick
Item {
    required property var model
    required property var colors
    property int    selIdx:   -1
    property string errorMsg: ""

    function validate() {
        errorMsg = ""
        if (rep_s.text.trim().length < 2)  { errorMsg = "Предмет: мін. 2 символи"; return false }
        var hh = parseInt(rep_h.text)
        var mm = parseInt(rep_m.text)
        if (isNaN(hh) || hh < 6 || hh > 22) { errorMsg = "Години: від 06 до 22"; return false }
        if (isNaN(mm) || mm < 0 || mm > 59) { errorMsg = "Хвилини: від 00 до 59"; return false }
        if (rep_r.text.trim() === "")        { errorMsg = "Введіть аудиторію"; return false }
        if (rep_p.text.trim().length < 5)    { errorMsg = "Викладач: мін. 5 символів"; return false }
        var d = parseInt(rep_d.text)
        if (isNaN(d) || d < 30 || d > 300)  { errorMsg = "Тривалість: від 30 до 300 хв."; return false }
        return true
    }

    function fillForm(rec) {
        rep_s.text = rec.subject || ""
        var hhmm = rec.startTime || 0
        var h = Math.floor(hhmm / 100)
        var m = hhmm % 100
        rep_h.text = h < 10 ? "0" + h : "" + h
        rep_m.text = m < 10 ? "0" + m : "" + m
        rep_r.text = rec.room || ""
        rep_p.text = rec.teacher || ""
        rep_d.text = rec.duration ? "" + rec.duration : "90"
        errorMsg = ""
    }

    Column {
        anchors.fill: parent; anchors.margins: 24; spacing: 10

        PageHeader { title: "Replace"; subtitle: "Click row to fill form, edit and confirm"; colors: colors; width: parent.width }

        Row {
            spacing: 8
            Text { text: "Selected:"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
            Text { text: selIdx >= 0 ? "#"+(selIdx+1) : "— click a row —"; color: selIdx >= 0 ? "#00cc44" : "#484848"; font.pixelSize: 11; font.bold: selIdx >= 0; font.family: "Consolas"; anchors.verticalCenter: parent.verticalCenter }
        }

        SchedTable {
            width: parent.width; height: parent.height - 310
            model: parent.parent.model
            onRowSelected: function(i) {
                parent.parent.selIdx = i
                parent.parent.fillForm(model.getRecord(i))
            }
        }

        Rectangle {
            width: parent.width; height: 220
            color: "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1; radius: 3; clip: true

            Column {
                anchors.fill: parent; anchors.margins: 12; spacing: 8

                Row {
                    width: parent.width; height: 32; spacing: 0
                    Text { text: "Предмет"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        width: parent.width - 76; height: 32; radius: 2; color: "#111111"
                        border.color: rep_s.activeFocus ? "#00cc44" : (rep_s.text.trim().length < 2 && rep_s.text !== "" ? "#cc4400" : "#252525"); border.width: 1
                        TextInput { id: rep_s; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; clip: true }
                        Text { anchors.fill: parent; anchors.margins: 6; text: "Назва предмету"; color: "#333"; font.pixelSize: 12; visible: rep_s.text === "" }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                }

                Row {
                    width: parent.width; height: 32; spacing: 0
                    Text { text: "Час"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 50; height: 32; radius: 2; color: "#111111"; border.width: 1
                        border.color: rep_h.activeFocus ? "#00cc44" : (rep_h.text !== "" && (parseInt(rep_h.text) < 6 || parseInt(rep_h.text) > 22) ? "#cc4400" : "#252525")
                        TextInput { id: rep_h; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; inputMethodHints: Qt.ImhDigitsOnly }
                        Text { anchors.fill: parent; anchors.margins: 6; text: "HH"; color: "#333"; font.pixelSize: 12; visible: rep_h.text === "" }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                    Text { text: " : "; color: "#00cc44"; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 50; height: 32; radius: 2; color: "#111111"; border.width: 1
                        border.color: rep_m.activeFocus ? "#00cc44" : (rep_m.text !== "" && (parseInt(rep_m.text) < 0 || parseInt(rep_m.text) > 59) ? "#cc4400" : "#252525")
                        TextInput { id: rep_m; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; inputMethodHints: Qt.ImhDigitsOnly }
                        Text { anchors.fill: parent; anchors.margins: 6; text: "MM"; color: "#333"; font.pixelSize: 12; visible: rep_m.text === "" }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                    Text { text: "   Ауд. "; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        width: parent.width - 76 - 50 - 28 - 50 - 52 - 30 - 68; height: 32; radius: 2; color: "#111111"
                        border.color: rep_r.activeFocus ? "#00cc44" : "#252525"; border.width: 1
                        TextInput { id: rep_r; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas" }
                        Text { anchors.fill: parent; anchors.margins: 6; text: "А-201"; color: "#333"; font.pixelSize: 12; visible: rep_r.text === "" }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                    Text { text: "  Хв. "; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 60; height: 32; radius: 2; color: "#111111"; border.width: 1
                        border.color: rep_d.activeFocus ? "#00cc44" : (rep_d.text !== "" && (parseInt(rep_d.text) < 30 || parseInt(rep_d.text) > 300) ? "#cc4400" : "#252525")
                        TextInput { id: rep_d; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "90"; inputMethodHints: Qt.ImhDigitsOnly }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                }

                Row {
                    width: parent.width; height: 32; spacing: 0
                    Text { text: "Викладач"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        width: parent.width - 76; height: 32; radius: 2; color: "#111111"
                        border.color: rep_p.activeFocus ? "#00cc44" : (rep_p.text.trim().length < 5 && rep_p.text !== "" ? "#cc4400" : "#252525"); border.width: 1
                        TextInput { id: rep_p; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; clip: true }
                        Text { anchors.fill: parent; anchors.margins: 6; text: "ПІБ викладача (мін. 5 символів)"; color: "#333"; font.pixelSize: 12; visible: rep_p.text === "" }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                }

                Text {
                    visible: errorMsg !== ""; width: parent.width; height: errorMsg !== "" ? 20 : 0
                    text: "  ⚠  " + errorMsg; color: "#cc4400"; font.pixelSize: 11; font.family: "Segoe UI"
                }

                Rectangle {
                    width: parent.width; height: 36; radius: 3
                    color: saveMA.containsMouse ? "#141414" : "#0a0a0a"; border.color: "#1e1e1e"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Save Changes"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 2; radius: 1
                        gradient: Gradient { orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.2; color: "#00cc44" }
                            GradientStop { position: 0.8; color: "#00cc44" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    MouseArea {
                        id: saveMA; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (selIdx < 0) { errorMsg = "Спочатку оберіть рядок у таблиці"; return }
                            if (!validate()) return
                            var hh = parseInt(rep_h.text)
                            var mm = parseInt(rep_m.text)
                            model.replaceRecord(selIdx, rep_s.text.trim(), hh*100+mm, rep_r.text.trim(), rep_p.text.trim(), parseInt(rep_d.text))
                            errorMsg = ""
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }
    }
}

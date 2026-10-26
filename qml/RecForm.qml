import QtQuick
Item {
    id: root
    signal confirmed(string subject, int startTime, string room, string teacher, int duration)

    property string errorMsg: ""

    function clear() {
        f_s.text = ""; f_h.text = ""; f_m.text = ""
        f_r.text = ""; f_p.text = ""; f_d.text = "90"
        errorMsg = ""
    }

    function fill(rec) {
        f_s.text = rec.subject || ""
        var hhmm = rec.startTime || 0
        var h = Math.floor(hhmm / 100)
        var m = hhmm % 100
        f_h.text = h < 10 ? "0" + h : "" + h
        f_m.text = m < 10 ? "0" + m : "" + m
        f_r.text = rec.room || ""
        f_p.text = rec.teacher || ""
        f_d.text = rec.duration ? "" + rec.duration : "90"
        errorMsg = ""
    }

    // Валідація всіх полів, повертає true якщо все добре
    function validate() {
        errorMsg = ""

        if (f_s.text.trim() === "") {
            errorMsg = "Назва предмету не може бути порожньою"
            return false
        }
        if (f_s.text.trim().length < 2) {
            errorMsg = "Назва предмету занадто коротка (мін. 2 символи)"
            return false
        }

        var hh = parseInt(f_h.text)
        var mm = parseInt(f_m.text)
        if (isNaN(hh) || f_h.text.trim() === "") {
            errorMsg = "Введіть години (HH)"
            return false
        }
        if (isNaN(mm) || f_m.text.trim() === "") {
            errorMsg = "Введіть хвилини (MM)"
            return false
        }
        if (hh < 6 || hh > 22) {
            errorMsg = "Години мають бути від 06 до 22"
            return false
        }
        if (mm < 0 || mm > 59) {
            errorMsg = "Хвилини мають бути від 00 до 59"
            return false
        }

        if (f_r.text.trim() === "") {
            errorMsg = "Введіть аудиторію"
            return false
        }
        if (f_p.text.trim() === "") {
            errorMsg = "Введіть ПІБ викладача"
            return false
        }
        if (f_p.text.trim().length < 5) {
            errorMsg = "ПІБ викладача занадто коротке"
            return false
        }

        var dur = parseInt(f_d.text)
        if (isNaN(dur) || dur < 30 || dur > 300) {
            errorMsg = "Тривалість має бути від 30 до 300 хвилин"
            return false
        }

        return true
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Предмет
        Row {
            width: parent.width; height: 32; spacing: 0
            Text { text: "Предмет"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: parent.width - 76; height: 32; radius: 2
                color: "#111111"
                border.color: f_s.activeFocus ? "#00cc44" : (f_s.text.trim().length < 2 && f_s.text !== "" ? "#cc4400" : "#252525")
                border.width: 1
                TextInput { id: f_s; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; clip: true }
                Text { anchors.fill: parent; anchors.margins: 6; text: "Назва предмету (мін. 2 символи)"; color: "#333"; font.pixelSize: 12; visible: f_s.text === "" }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }
        }

        // Час + Аудиторія + Хв
        Row {
            width: parent.width; height: 32; spacing: 0
            Text { text: "Час"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }

            // HH — підсвічується червоним якщо поза 06-22
            Rectangle {
                width: 50; height: 32; radius: 2; color: "#111111"
                border.width: 1
                border.color: {
                    if (!f_h.activeFocus && f_h.text !== "") {
                        var v = parseInt(f_h.text)
                        if (isNaN(v) || v < 6 || v > 22) return "#cc4400"
                    }
                    return f_h.activeFocus ? "#00cc44" : "#252525"
                }
                TextInput { id: f_h; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; inputMethodHints: Qt.ImhDigitsOnly }
                Text { anchors.fill: parent; anchors.margins: 6; text: "HH"; color: "#333"; font.pixelSize: 12; visible: f_h.text === "" }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }
            Text { text: " : "; color: "#00cc44"; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }

            // MM — підсвічується червоним якщо поза 00-59
            Rectangle {
                width: 50; height: 32; radius: 2; color: "#111111"
                border.width: 1
                border.color: {
                    if (!f_m.activeFocus && f_m.text !== "") {
                        var v = parseInt(f_m.text)
                        if (isNaN(v) || v < 0 || v > 59) return "#cc4400"
                    }
                    return f_m.activeFocus ? "#00cc44" : "#252525"
                }
                TextInput { id: f_m; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; inputMethodHints: Qt.ImhDigitsOnly }
                Text { anchors.fill: parent; anchors.margins: 6; text: "MM"; color: "#333"; font.pixelSize: 12; visible: f_m.text === "" }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }

            Text { text: "   Ауд. "; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: parent.width - 76 - 50 - 28 - 50 - 52 - 30 - 68
                height: 32; radius: 2; color: "#111111"
                border.color: f_r.activeFocus ? "#00cc44" : (f_r.text === "" && errorMsg !== "" ? "#cc4400" : "#252525")
                border.width: 1
                TextInput { id: f_r; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas" }
                Text { anchors.fill: parent; anchors.margins: 6; text: "А-201"; color: "#333"; font.pixelSize: 12; visible: f_r.text === "" }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }

            Text { text: "  Хв. "; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: 60; height: 32; radius: 2; color: "#111111"
                border.width: 1
                border.color: {
                    if (!f_d.activeFocus && f_d.text !== "") {
                        var v = parseInt(f_d.text)
                        if (isNaN(v) || v < 30 || v > 300) return "#cc4400"
                    }
                    return f_d.activeFocus ? "#00cc44" : "#252525"
                }
                TextInput { id: f_d; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; text: "90"; inputMethodHints: Qt.ImhDigitsOnly }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }
        }

        // Викладач
        Row {
            width: parent.width; height: 32; spacing: 0
            Text { text: "Викладач"; color: "#484848"; font.pixelSize: 11; font.family: "Segoe UI"; width: 76; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: parent.width - 76; height: 32; radius: 2
                color: "#111111"
                border.color: f_p.activeFocus ? "#00cc44" : (f_p.text.trim().length < 5 && f_p.text !== "" ? "#cc4400" : "#252525")
                border.width: 1
                TextInput { id: f_p; anchors.fill: parent; anchors.margins: 6; color: "#cccccc"; font.pixelSize: 12; font.family: "Consolas"; clip: true }
                Text { anchors.fill: parent; anchors.margins: 6; text: "ПІБ викладача (мін. 5 символів)"; color: "#333"; font.pixelSize: 12; visible: f_p.text === "" }
                Behavior on border.color { ColorAnimation { duration: 100 } }
            }
        }

        // Повідомлення про помилку
        Rectangle {
            width: parent.width
            height: errorMsg !== "" ? 26 : 0
            color: "transparent"
            clip: true
            visible: errorMsg !== ""
            Behavior on height { NumberAnimation { duration: 120 } }
            Text {
                anchors.fill: parent
                text: "  ⚠  " + errorMsg
                color: "#cc4400"
                font.pixelSize: 11
                font.family: "Segoe UI"
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Кнопка Confirm
        Rectangle {
            width: parent.width; height: 36; radius: 3
            color: cfMA.containsMouse ? "#141414" : "#0a0a0a"
            border.color: "#1e1e1e"; border.width: 1
            Text { anchors.centerIn: parent; text: "Confirm"; color: "#00cc44"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI" }
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: 2; radius: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#00cc44" }
                    GradientStop { position: 0.8; color: "#00cc44" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            MouseArea {
                id: cfMA; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    if (!root.validate()) return
                    var hh = parseInt(f_h.text)
                    var mm = parseInt(f_m.text)
                    root.confirmed(f_s.text.trim(), hh*100+mm, f_r.text.trim(), f_p.text.trim(), parseInt(f_d.text))
                }
            }
            Behavior on color { ColorAnimation { duration: 80 } }
        }
    }
}

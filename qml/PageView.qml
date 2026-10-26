import QtQuick
Item {
    required property var model
    required property var colors

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        PageHeader { title: "View / Add"; subtitle: "All records + add new"; colors: colors; width: parent.width }

        SchedTable {
            width: parent.width
            height: parent.height - 270
            model: parent.parent.model
        }

        // Форма у боксі — як у Replace
        Rectangle {
            width: parent.width
            height: 190
            color: "#0a0a0a"
            border.color: "#1e1e1e"
            border.width: 1
            radius: 3

            RecForm {
                anchors.fill: parent
                onConfirmed: function(s, t, r, p, d) {
                    model.addRecord(s, t, r, p, d)
                    clear()
                }
            }
        }
    }
}

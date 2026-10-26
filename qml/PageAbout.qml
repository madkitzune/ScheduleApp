import QtQuick
Item {
    required property var model
    required property var colors
    Column {
        anchors.fill: parent; anchors.margins: 40; spacing: 20
        Text { text: "Schedule Manager"; color: "#cccccc"; font.pixelSize: 28; font.bold: true; font.family: "Segoe UI" }
        Text { text: "Курсовий проект — Алгоритмізація та програмування"; color: "#484848"; font.pixelSize: 13; font.family: "Segoe UI" }
        Rectangle { width: parent.width; height: 1; color: "#1e1e1e" }
        Repeater {
            model: [
                "[>]  Завантаження з TXT та SQLite",
                "[S]  Збереження у TXT та SQLite",
                "[+]  Додавання, вставка, редагування",
                "[X]  Видалення записів",
                "[?]  Shell Sort + бінарний пошук",
                "[=]  Статистика за діапазоном часу"
            ]
            Text { text: modelData; color: "#cccccc"; font.pixelSize: 13; font.family: "Consolas" }
        }
        Rectangle { width: parent.width; height: 1; color: "#1e1e1e" }
        Text { text: "Qt 6.11  |  C++17  |  QML  |  SQLite"; color: "#00cc44"; font.pixelSize: 12; font.family: "Consolas" }
        Item { height: 1 }
    }
}

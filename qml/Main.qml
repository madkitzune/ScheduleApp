import QtQuick
import QtQuick.Controls
import ScheduleApp

ApplicationWindow {
    id: root
    visible: true
    width: 1100; height: 700
    minimumWidth: 800; minimumHeight: 500
    title: "Schedule Manager"

    readonly property color c_bg:     "#0d0d0d"
    readonly property color c_panel:  "#0f0f0f"
    readonly property color c_green:  "#00cc44"
    readonly property color c_border: "#1e1e1e"
    readonly property color c_text:   "#cccccc"
    readonly property color c_dim:    "#484848"
    readonly property color c_sel:    "#091a0e"
    readonly property color c_hover:  "#141414"

    property bool sideOpen: true
    property int  curPage:  0

    color: c_bg

    ScheduleModel { id: schedModel }

    Connections {
        target: schedModel
        function onMessage(text, isError) {
            toastMsg.text = text
            toastBox.isErr = isError || false
            toastBox.visible = true
            toastTimer.restart()
        }
    }

    // ── Бокова панель ────────────────────────────────────────────────
    Rectangle {
        id: sidebar
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: sideOpen ? 210 : 44
        color: c_panel
        z: 2; clip: true
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        // Градієнт зліва — тонка вертикальна смуга
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: 3
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#004422" }
                GradientStop { position: 0.5; color: c_green   }
                GradientStop { position: 1.0; color: "#004422" }
            }
        }

        // Заголовок
        Item {
            id: sideHead
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 52

            Text {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                text: "S"; color: c_green
                font.pixelSize: 20; font.bold: true; font.family: "Consolas"
            }
            Text {
                anchors { left: parent.left; leftMargin: 38; verticalCenter: parent.verticalCenter }
                text: "Schedule"; color: c_text
                font.pixelSize: 14; font.bold: true; font.family: "Segoe UI"
                opacity: sideOpen ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
            Rectangle {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 26; height: 26; radius: 3
                color: tglMA.containsMouse ? c_hover : "transparent"
                Text { anchors.centerIn: parent; text: sideOpen ? "<" : ">"; color: c_dim; font.pixelSize: 11; font.family: "Consolas" }
                MouseArea { id: tglMA; anchors.fill: parent; hoverEnabled: true; onClicked: sideOpen = !sideOpen }
            }
        }

        // Лічильник
        Item {
            id: counter
            anchors { left: parent.left; right: parent.right; top: sideHead.bottom }
            height: sideOpen ? 28 : 0; clip: true
            Behavior on height { NumberAnimation { duration: 150 } }
            Row {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 6
                Text { text: "Записів:"; color: c_dim; font.pixelSize: 11; font.family: "Segoe UI" }
                Text {
                    text: schedModel.count + ""
                    color: c_green; font.pixelSize: 11; font.bold: true; font.family: "Consolas"
                }
            }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: counter.bottom }
            height: 1; color: c_border
        }

        // Пункти меню
        Column {
            anchors { left: parent.left; right: parent.right; top: counter.bottom; topMargin: 4 }

            Repeater {
                model: [
                    {icon:"~", label:"About"       },
                    {icon:">", label:"Load"        },
                    {icon:"#", label:"View / Add"  },
                    {icon:"S", label:"Save"        },
                    {icon:"?", label:"Sort / Search"},
                    {icon:"+", label:"Insert"      },
                    {icon:"E", label:"Replace"     },
                    {icon:"X", label:"Delete"      },
                    {icon:"=", label:"Statistics"  }
                ]
                delegate: Item {
                    width: sidebar.width; height: 44

                    // Фон
                    Rectangle {
                        anchors.fill: parent
                        color: curPage === index ? c_sel : (itemMA.containsMouse ? c_hover : "transparent")
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }

                    // Градієнт при наведенні/активному — зліва направо
                    Rectangle {
                        anchors.fill: parent
                        visible: curPage === index || itemMA.containsMouse
                        opacity: curPage === index ? 0.12 : 0.05
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: c_green }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    // Лінія зліва
                    Rectangle {
                        width: 3; height: parent.height
                        color: c_green
                        visible: curPage === index
                    }

                    // Іконка
                    Text {
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        text: modelData.icon
                        color: curPage === index ? c_green : c_dim
                        font.pixelSize: 12; font.bold: true; font.family: "Consolas"
                        width: 18; horizontalAlignment: Text.AlignHCenter
                    }

                    // Назва
                    Text {
                        anchors { left: parent.left; leftMargin: 42; verticalCenter: parent.verticalCenter }
                        text: modelData.label
                        color: curPage === index ? c_green : c_text
                        font.pixelSize: 13; font.bold: curPage === index
                        font.family: "Segoe UI"
                        opacity: sideOpen ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }

                    MouseArea { id: itemMA; anchors.fill: parent; hoverEnabled: true; onClicked: curPage = index }
                }
            }
        }

        // Версія
        Text {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 10 }
            text: sideOpen ? "v1.0  Qt 6.11" : "v1"
            color: c_dim; font.pixelSize: 10; font.family: "Consolas"
        }
    }

    // Роздільник
    Rectangle {
        anchors { left: sidebar.right; top: parent.top; bottom: parent.bottom }
        width: 1; color: c_border; z: 2
    }

    // ── Контент ──────────────────────────────────────────────────────
    Item {
        anchors { left: sidebar.right; leftMargin: 1; right: parent.right; top: parent.top; bottom: parent.bottom }
        PageAbout   { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 0 }
        PageLoad    { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 1 }
        PageView    { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 2 }
        PageSave    { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 3 }
        PageSort    { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 4 }
        PageInsert  { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 5 }
        PageReplace { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 6 }
        PageDelete  { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 7 }
        PageStats   { anchors.fill: parent; model: schedModel; colors: root; visible: curPage === 8 }
    }

    // ── Toast ─────────────────────────────────────────────────────────
    Rectangle {
        id: toastBox
        property bool isErr: false
        visible: false
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 20 }
        height: 36; radius: 3; z: 999
        width: toastMsg.implicitWidth + 28
        color: isErr ? "#1a0000" : "#051500"
        border.color: isErr ? "#cc2222" : c_green; border.width: 1
        Text {
            id: toastMsg; anchors.centerIn: parent
            color: toastBox.isErr ? "#ff4444" : c_green
            font.pixelSize: 12; font.family: "Consolas"
        }
        Timer { id: toastTimer; interval: 3000; onTriggered: toastBox.visible = false }
    }
}

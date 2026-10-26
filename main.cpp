#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "schedulemodel.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("ScheduleApp");
    app.setApplicationDisplayName("Розклад занять");
    app.setOrganizationName("University");

    qmlRegisterType<ScheduleModel>("ScheduleApp", 1, 0, "ScheduleModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/ScheduleApp/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}

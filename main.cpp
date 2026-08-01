#include <QQmlContext>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QtGlobal>
#include "src/Backend.h"

int main(int argc, char *argv[])
{
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    }

    QGuiApplication app(argc, argv);

    Backend backend; // Stack üzerinde Backend nesnesi oluşturdum. 

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("backend", &backend);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            qWarning() << "QML nesnesi olusturulamadi!";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.loadFromModule("sliper", "Main");

    return app.exec();
}

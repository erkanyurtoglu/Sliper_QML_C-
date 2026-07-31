#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

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
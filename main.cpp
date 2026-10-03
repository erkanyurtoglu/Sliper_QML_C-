#include <QQmlContext>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QtGlobal>
#include "src/Backend.h"
#include "src/SensorManager.h"
#include "src/Calculator.h"
#include "src/Database.h"
#include "src/ReportManager.h"
#include "src/WifiManager.h"
#include "src/VoiceCommandManager.h"

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QApplication app(argc, argv);   
    QApplication::setApplicationName("SLIPER");

    Backend backend;
    SensorManager sensorManager;
    Calculator calculator;
    Database database;
    ReportManager reportManager(&database);
    WifiManager wifiManager(&sensorManager, &database);
    VoiceCommandManager voiceCommandManager;

    // Kalibre edilmiş üst/alt boru konumları (stroke başlangıç/bitiş referansı)
    const QVariantMap konumSinirlari = database.kalibrasyonGetir("konum_sinirlari");
    if (konumSinirlari.value("mevcut").toBool()) {
        calculator.setUstKonumMm(konumSinirlari.value("deger1").toDouble());
        calculator.setAltKonumMm(konumSinirlari.value("deger2").toDouble());
    }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("sensorManager", &sensorManager);
    engine.rootContext()->setContextProperty("calculator", &calculator);
    engine.rootContext()->setContextProperty("database", &database);
    engine.rootContext()->setContextProperty("reportManager", &reportManager);
    engine.rootContext()->setContextProperty("wifiManager", &wifiManager);
    engine.rootContext()->setContextProperty("voiceCommandManager", &voiceCommandManager);

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
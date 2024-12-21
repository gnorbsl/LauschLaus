#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QScreen>

int main(int argc, char *argv[])
{
    // Use X11 platform
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("DISPLAY", ":0");
    
    QGuiApplication app(argc, argv);
    
    // Set up fullscreen on the primary screen
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
} 
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    // Set EGLFS as the default platform
    qputenv("QT_QPA_PLATFORM", "eglfs");
    
    // Disable cursor (we're using touch)
    qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
} 
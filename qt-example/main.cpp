#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    // Set EGLFS as the default platform
    qputenv("QT_QPA_PLATFORM", "eglfs");
    
    // Configure EGLFS for Raspberry Pi
    qputenv("QT_QPA_EGLFS_INTEGRATION", "eglfs_brcm");
    qputenv("QT_QPA_EGLFS_PHYSICAL_WIDTH", "800");
    qputenv("QT_QPA_EGLFS_PHYSICAL_HEIGHT", "480");
    qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");
    
    // Set the FB device
    qputenv("QT_QPA_EGLFS_FB", "/dev/fb0");
    
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
} 
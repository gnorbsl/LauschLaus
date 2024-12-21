#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    // Enable debug output
    qputenv("QT_DEBUG_PLUGINS", "1");
    qputenv("QT_LOGGING_RULES", "qt.qpa.*=true");
    
    // Use Linux Framebuffer
    qputenv("QT_QPA_PLATFORM", "linuxfb");
    qputenv("QT_QPA_FB_DEV", "/dev/fb0");
    qputenv("QT_QPA_FB_TTY", "/dev/tty1");
    qputenv("QT_QPA_FB_HIDECURSOR", "1");
    qputenv("QT_QPA_FB_TSLIB", "1");
    
    QGuiApplication app(argc, argv);
    
    qDebug() << "Available platforms:" << QGuiApplication::platformName();
    qDebug() << "Current platform:" << app.platformName();
    
    QQmlApplicationEngine engine;
    
    qDebug() << "Loading QML file...";
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Failed to load QML";
        return -1;
    }
    
    qDebug() << "Application started successfully";
    return app.exec();
} 
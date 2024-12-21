#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QWindow>

int main(int argc, char *argv[])
{
    // Enable debug output
    qputenv("QT_DEBUG_PLUGINS", "1");
    qputenv("QT_LOGGING_RULES", "qt.qpa.*=true");
    
    // Use XCB (X11) platform
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("DISPLAY", ":0");
    
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
    
    // Get the main window
    QWindow *window = qobject_cast<QWindow*>(engine.rootObjects().first());
    if (window) {
        window->setFlag(Qt::FramelessWindowHint);
        window->showFullScreen();
        qDebug() << "Window shown in fullscreen mode";
    }
    
    qDebug() << "Application started successfully";
    return app.exec();
} 
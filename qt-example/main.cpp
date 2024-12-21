#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QWindow>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    // Performance optimizations
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");  // Use basic style for better performance
    qputenv("QML_DISABLE_DISK_CACHE", "0");       // Enable QML disk cache
    qputenv("QSG_RENDER_LOOP", "basic");          // Use basic render loop for embedded systems
    
    // Enable debug output
    qputenv("QT_DEBUG_PLUGINS", "1");
    qputenv("QT_LOGGING_RULES", "qt.qpa.*=true");
    
    // Use XCB (X11) platform
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("DISPLAY", ":0");
    
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    QGuiApplication app(argc, argv);
    
    // Enable shader disk cache
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
    
    qDebug() << "Available platforms:" << QGuiApplication::platformName();
    qDebug() << "Current platform:" << app.platformName();
    
    QQmlApplicationEngine engine;
    
    // Optimize QML engine
    engine.setOfflineStoragePath("/tmp/qml-cache");
    
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
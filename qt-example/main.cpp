#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QWindow>
#include <QQuickWindow>
#include <QFontDatabase>
#include <QDir>
#include <QFileInfo>

int main(int argc, char *argv[])
{
    // Performance optimizations
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");  // Use basic style for better performance
    qputenv("QML_DISABLE_DISK_CACHE", "0");       // Enable QML disk cache
    qputenv("QSG_RENDER_LOOP", "basic");          // Use basic render loop for embedded systems
    
    // Allow file reading for XMLHttpRequest
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");
    
    // Font rendering settings
    qputenv("QT_QPA_FONTDIR", "/usr/share/fonts");
    
    // Enable debug output
    qputenv("QT_DEBUG_PLUGINS", "1");
    qputenv("QT_LOGGING_RULES", "qt.qpa.input.*=false;qt.qpa.events=false;qt.qpa.backingstore=false;qt.qpa.window=false;qt.qpa.screen.*=false;qt.qpa.drawing=false");
    
#ifdef Q_OS_MACOS
    qputenv("QT_QPA_PLATFORM", "cocoa");
#else
    // Use XCB (X11) platform for Linux
    qputenv("QT_QPA_PLATFORM", "xcb");
    qputenv("DISPLAY", ":0");
#endif
    
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    QGuiApplication app(argc, argv);
    
    // Set QML import path to current working directory
    QString currentPath = QDir::currentPath();
    QStringList importPaths = QStringList() << currentPath;
    qputenv("QML_IMPORT_PATH", currentPath.toLocal8Bit());
    
    // Load emoji fonts
    QFontDatabase::addApplicationFont("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf");
    
    // Enable shader disk cache
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
    
    qDebug() << "Available platforms:" << QGuiApplication::platformName();
    qDebug() << "Current platform:" << app.platformName();
    qDebug() << "Current working directory:" << currentPath;
    qDebug() << "QML import paths:" << importPaths;
    
    QQmlApplicationEngine engine;
    
    // Add import paths
    engine.setImportPathList(engine.importPathList() << importPaths);
    
    // Optimize QML engine
    engine.setOfflineStoragePath("/tmp/qml-cache");
    
    // Load QML file directly instead of from resources
    QString qmlFile = QFileInfo(currentPath + "/main.qml").absoluteFilePath();
    qDebug() << "Loading QML file:" << qmlFile;
    engine.load(QUrl::fromLocalFile(qmlFile));
    
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
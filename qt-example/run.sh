#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"

# Allow file reading for XMLHttpRequest
export QML_XHR_ALLOW_FILE_READ=1

# Run the application
QML_IMPORT_PATH="$PWD" /opt/homebrew/opt/qt@5/bin/qmlscene main.qml
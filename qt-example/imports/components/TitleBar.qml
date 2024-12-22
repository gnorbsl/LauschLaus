import QtQuick 2.15

Rectangle {
    id: root
    height: 60
    color: "transparent"

    property string title: ""

    Text {
        anchors.centerIn: parent
        text: root.title
        color: "white"
        font.pixelSize: 24
        font.bold: true
    }
} 
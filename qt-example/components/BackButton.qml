import QtQuick 2.15

Rectangle {
    id: root
    width: 60
    height: 60
    radius: 30
    color: Qt.rgba(1, 1, 1, 0.2)

    signal clicked()

    Text {
        anchors.centerIn: parent
        text: "⬅️"
        font.pixelSize: 24
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
} 
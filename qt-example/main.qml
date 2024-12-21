import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    title: "LauschLaus"
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }

        // Debug info
        Text {
            id: debugText
            anchors.top: parent.top
            anchors.left: parent.left
            color: "white"
            font.pixelSize: 12
            z: 100
        }
    }

    Grid {
        anchors.fill: parent
        anchors.margins: 12
        columns: Math.floor(parent.width / 150)
        spacing: 4

        Repeater {
            model: ListModel {
                ListElement { name: "Aladdin" }
                ListElement { name: "Bob der Baumeister" }
                ListElement { name: "Das Dschungelbuch" }
                ListElement { name: "Die Playmos" }
                ListElement { name: "PAW Patrol" }
                ListElement { name: "Ratatouille" }
                ListElement { name: "Tarzan" }
            }

            delegate: Rectangle {
                id: card
                width: 140
                height: 180
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.2)
                
                // Scale animation on press
                scale: mouseArea.pressed ? 0.95 : mouseArea.containsMouse ? 1.02 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Rectangle {
                        Layout.alignment: Qt.AlignCenter
                        width: 135
                        height: 135
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 6

                        Text {
                            anchors.centerIn: parent
                            text: getEmoji(model.name)
                            font.pixelSize: 72
                            font.family: "Noto Color Emoji"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        text: model.name
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Clicked:", model.name)
                        debugText.text = "Clicked: " + model.name
                    }
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            debugText.text = "Hovering: " + model.name
                        }
                    }
                }

                Component.onCompleted: {
                    console.log("Created card for:", model.name)
                }
            }
        }
    }

    function getEmoji(name) {
        var emojiMap = {
            'Aladdin': '🧞',
            'Bob der Baumeister': '👷',
            'Das Dschungelbuch': '🐯',
            'Die Playmos': '🎮',
            'PAW Patrol': '🐕',
            'Ratatouille': '🐀',
            'Tarzan': '🦍'
        };
        return emojiMap[name] || '🎵';
    }
} 
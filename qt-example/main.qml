import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Window {
    id: root
    visible: true
    width: 800
    height: 480
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    title: "LauschLaus"
    
    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }
    }

    // Main content
    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 4
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: 7
            delegate: Rectangle {
                id: card
                Layout.preferredWidth: 185  // (800 - 2*10 - 3*10) / 4
                Layout.preferredHeight: 220
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.2)
                
                // Debug border
                border.width: 1
                border.color: "red"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Rectangle {
                        Layout.alignment: Qt.AlignCenter
                        width: 160
                        height: 160
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 6

                        Text {
                            anchors.centerIn: parent
                            text: getEmoji(getArtistName(index))
                            font.pixelSize: 72
                            font.family: "Noto Color Emoji"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        text: getArtistName(index)
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
                        console.log("Clicked:", getArtistName(index))
                    }
                }

                Component.onCompleted: {
                    console.log("Created card for:", getArtistName(index))
                }
            }
        }
    }

    function getArtistName(index) {
        var artists = [
            "Aladdin",
            "Bob der Baumeister",
            "Das Dschungelbuch",
            "Die Playmos",
            "PAW Patrol",
            "Ratatouille",
            "Tarzan"
        ];
        return artists[index];
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
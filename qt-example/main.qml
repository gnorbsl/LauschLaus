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
            text: "Screen size: " + parent.width + "x" + parent.height
        }
    }

    // Main content area
    Rectangle {
        anchors.fill: parent
        anchors.margins: 12
        color: "transparent"

        Column {
            anchors.fill: parent
            spacing: 8

            // First row
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 4  // First 4 items
                    delegate: ArtistCard {
                        artistName: getArtistName(index)
                    }
                }
            }

            // Second row
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 3  // Last 3 items
                    delegate: ArtistCard {
                        artistName: getArtistName(index + 4)
                    }
                }
            }
        }
    }

    // Artist Card Component
    component ArtistCard: Rectangle {
        property string artistName
        id: card
        width: 140
        height: 180
        radius: 8
        color: Qt.rgba(1, 1, 1, 0.2)
        
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
                    text: getEmoji(artistName)
                    font.pixelSize: 72
                    font.family: "Noto Color Emoji"
                }
            }

            Text {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                text: artistName
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
                console.log("Clicked:", artistName)
                debugText.text = "Clicked: " + artistName
            }
            onContainsMouseChanged: {
                if (containsMouse) {
                    debugText.text = "Hovering: " + artistName
                }
            }
        }

        Component.onCompleted: {
            console.log("Created card for:", artistName)
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
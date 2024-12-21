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
    
    // Background gradient matching React app
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }
    }

    // Main content area matching React styling
    Rectangle {
        id: mainContent
        anchors.fill: parent
        anchors.margins: 12
        color: Qt.rgba(1, 1, 1, 0.1)
        radius: 12

        // Grid view for artists
        GridView {
            id: artistsGrid
            anchors.fill: parent
            anchors.margins: 4
            cellWidth: Math.floor(width / Math.floor(width / 150))  // Responsive grid
            cellHeight: 190
            flow: GridView.LeftToRight
            clip: true

            model: ListModel {
                ListElement { name: "Aladdin"; imageUrl: ""; type: "artist" }
                ListElement { name: "Bob der Baumeister"; imageUrl: ""; type: "artist" }
                ListElement { name: "Das Dschungelbuch"; imageUrl: ""; type: "artist" }
                ListElement { name: "Die Playmos"; imageUrl: ""; type: "artist" }
                ListElement { name: "PAW Patrol"; imageUrl: ""; type: "artist" }
                ListElement { name: "Ratatouille"; imageUrl: ""; type: "artist" }
                ListElement { name: "Tarzan"; imageUrl: ""; type: "artist" }
            }

            delegate: Item {
                width: artistsGrid.cellWidth
                height: artistsGrid.cellHeight

                Rectangle {
                    id: card
                    anchors.centerIn: parent
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

                    // Hover effect
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    states: State {
                        name: "hovered"
                        when: mouseArea.containsMouse
                        PropertyChanges {
                            target: card
                            color: Qt.rgba(1, 1, 1, 0.3)
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        // Cover art placeholder
                        Rectangle {
                            Layout.alignment: Qt.AlignCenter
                            width: 135
                            height: 135
                            color: Qt.rgba(1, 1, 1, 0.1)
                            radius: 6

                            // Emoji as placeholder
                            Text {
                                anchors.centerIn: parent
                                text: getEmoji(model.name)
                                font.pixelSize: 72
                                font.family: "Noto Color Emoji"
                            }

                            // Shadow effect
                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 2
                                radius: 4
                                samples: 8
                                color: "#20000000"
                            }
                        }

                        // Artist name
                        Text {
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            text: model.name
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            
                            // Text shadow
                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 1
                                radius: 2
                                samples: 4
                                color: "#40000000"
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Clicked:", model.name)
                        }
                    }
                }
            }
        }
    }

    // Function to get emoji based on name (matching your React implementation)
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
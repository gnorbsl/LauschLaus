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
    
    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }

        // Main content area
        Rectangle {
            id: mainContent
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 12

            // Grid view for artists
            GridView {
                id: artistsGrid
                anchors.fill: parent
                anchors.margins: 10
                
                // Fixed number of columns
                cellWidth: Math.floor((parent.width - 20) / 5)  // 5 columns
                cellHeight: 190
                
                // Debug property
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

                delegate: Rectangle {
                    id: card
                    width: artistsGrid.cellWidth - 10  // Leave some margin
                    height: 180
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.2)
                    
                    // Debug border
                    border.width: 1
                    border.color: "white"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Rectangle {
                            Layout.alignment: Qt.AlignCenter
                            width: Math.min(parent.width - 10, 135)
                            height: width
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
                            parent.scale = 0.95
                            clickAnim.start()
                        }
                    }

                    SequentialAnimation {
                        id: clickAnim
                        NumberAnimation {
                            target: card
                            property: "scale"
                            to: 1.1
                            duration: 100
                        }
                        NumberAnimation {
                            target: card
                            property: "scale"
                            to: 1.0
                            duration: 100
                        }
                    }
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
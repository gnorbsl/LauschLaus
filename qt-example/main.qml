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
    
    // View state management
    property string currentView: "artists"
    property string selectedArtist: ""
    
    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }

        // Back button
        Rectangle {
            id: backButton
            width: 60
            height: 60
            radius: 30
            color: Qt.rgba(1, 1, 1, 0.2)
            visible: currentView === "albums"
            x: 10
            y: 10
            z: 1

            Text {
                anchors.centerIn: parent
                text: "⬅️"
                font.pixelSize: 24
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentView = "artists"
                    selectedArtist = ""
                }
            }
        }

        // Title bar for album view
        Rectangle {
            id: titleBar
            height: 60
            anchors {
                top: parent.top
                left: backButton.right
                right: parent.right
                margins: 10
            }
            color: "transparent"
            visible: currentView === "albums"
            z: 1

            Text {
                anchors.centerIn: parent
                text: selectedArtist
                color: "white"
                font.pixelSize: 24
                font.bold: true
            }
        }

        // Main content area
        Rectangle {
            id: mainContent
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 12

            // Artists Grid
            GridView {
                id: artistsGrid
                anchors.fill: parent
                anchors.margins: 10
                visible: currentView === "artists"
                
                cellWidth: Math.floor((parent.width - 20) / 5)
                cellHeight: 190
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
                    width: artistsGrid.cellWidth - 10
                    height: 180
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.2)
                    
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
                            selectedArtist = model.name
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
                        ScriptAction {
                            script: currentView = "albums"
                        }
                    }
                }
            }

            // Albums Grid
            GridView {
                id: albumsGrid
                anchors.fill: parent
                anchors.margins: 10
                anchors.topMargin: 70  // Make room for title
                visible: currentView === "albums"
                
                cellWidth: Math.floor((parent.width - 20) / 5)
                cellHeight: 190
                clip: true

                model: {
                    if (selectedArtist === "Aladdin") return aladdinAlbums;
                    if (selectedArtist === "Bob der Baumeister") return bobAlbums;
                    return defaultAlbums;
                }

                // Example album collections
                ListModel {
                    id: aladdinAlbums
                    ListElement { name: "Wunderlampe"; emoji: "💫" }
                    ListElement { name: "Dschinni"; emoji: "🧞" }
                    ListElement { name: "Wüstenabenteuer"; emoji: "🐪" }
                }

                ListModel {
                    id: bobAlbums
                    ListElement { name: "Baustelle"; emoji: "🏗️" }
                    ListElement { name: "Bagger & Co"; emoji: "🚜" }
                    ListElement { name: "Werkzeugkiste"; emoji: "🔨" }
                }

                ListModel {
                    id: defaultAlbums
                    ListElement { name: "Album 1"; emoji: "💿" }
                    ListElement { name: "Album 2"; emoji: "💿" }
                }

                delegate: Rectangle {
                    id: albumCard
                    width: albumsGrid.cellWidth - 10
                    height: 180
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.2)
                    
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
                                text: model.emoji
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
                        anchors.fill: parent
                        onClicked: {
                            console.log("Album clicked:", model.name)
                            parent.scale = 0.95
                            albumClickAnim.start()
                        }
                    }

                    SequentialAnimation {
                        id: albumClickAnim
                        NumberAnimation {
                            target: albumCard
                            property: "scale"
                            to: 1.1
                            duration: 100
                        }
                        NumberAnimation {
                            target: albumCard
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
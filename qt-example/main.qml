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
    title: "KidsPlayer"
    color: "#4158D0"

    // View state management
    property string currentView: "artists"
    property string selectedArtist: ""

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
            visible: currentView !== "artists"
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
                    backButton.scale = 0.9
                    backAnimation.start()
                    currentView = "artists"
                }
            }

            SequentialAnimation {
                id: backAnimation
                NumberAnimation {
                    target: backButton
                    property: "scale"
                    to: 1.1
                    duration: 100
                }
                NumberAnimation {
                    target: backButton
                    property: "scale"
                    to: 1.0
                    duration: 100
                }
            }
        }

        // Artists View
        GridView {
            id: artistsGrid
            anchors.fill: parent
            anchors.margins: 10
            cellWidth: 160
            cellHeight: 200
            visible: currentView === "artists"
            model: ListModel {
                ListElement { name: "Aladdin"; emoji: "🧞"; albums: 3 }
                ListElement { name: "Bob der Baumeister"; emoji: "👷"; albums: 4 }
                ListElement { name: "Das Dschungelbuch"; emoji: "🐯"; albums: 2 }
                ListElement { name: "Die Playmos"; emoji: "🎮"; albums: 5 }
                ListElement { name: "PAW Patrol"; emoji: "🐕"; albums: 3 }
                ListElement { name: "Ratatouille"; emoji: "🐀"; albums: 2 }
                ListElement { name: "Tarzan"; emoji: "🦍"; albums: 4 }
            }

            delegate: Rectangle {
                width: 150
                height: 190
                radius: 15
                color: Qt.rgba(1, 1, 1, 0.2)

                // Scale animation on press
                scale: artistMouseArea.pressed ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBounce
                    }
                }

                // Glow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80FFFFFF"
                    radius: artistMouseArea.containsMouse ? 20 : 0
                    samples: 20
                    Behavior on radius {
                        NumberAnimation { duration: 200 }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.emoji
                        font.pixelSize: 72
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.name
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.albums + " Albums"
                        color: "white"
                        opacity: 0.7
                        font.pixelSize: 14
                    }
                }

                MouseArea {
                    id: artistMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        selectedArtist = model.name
                        artistClickAnimation.start()
                    }
                }

                SequentialAnimation {
                    id: artistClickAnimation
                    NumberAnimation {
                        target: parent
                        property: "scale"
                        to: 1.1
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: parent
                        property: "scale"
                        to: 1.0
                        duration: 100
                        easing.type: Easing.OutBounce
                    }
                    ScriptAction {
                        script: currentView = "albums"
                    }
                }
            }

            add: Transition {
                NumberAnimation { property: "scale"; from: 0; to: 1; duration: 250; easing.type: Easing.OutBounce }
            }
        }

        // Albums View
        GridView {
            id: albumsGrid
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 80
            cellWidth: 160
            cellHeight: 200
            visible: currentView === "albums"
            opacity: visible ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            model: {
                if (selectedArtist === "Aladdin") return aladdinAlbums
                if (selectedArtist === "Bob der Baumeister") return bobAlbums
                return defaultAlbums
            }

            ListModel {
                id: aladdinAlbums
                ListElement { name: "Wunderlampe"; emoji: "💫"; tracks: 5 }
                ListElement { name: "Dschinni"; emoji: "🧞"; tracks: 4 }
                ListElement { name: "Wüstenabenteuer"; emoji: "🐪"; tracks: 6 }
            }

            ListModel {
                id: bobAlbums
                ListElement { name: "Baustelle"; emoji: "🏗️"; tracks: 4 }
                ListElement { name: "Bagger & Co"; emoji: "🚜"; tracks: 5 }
                ListElement { name: "Werkzeugkiste"; emoji: "🔨"; tracks: 3 }
                ListElement { name: "Reparaturtag"; emoji: "🔧"; tracks: 4 }
            }

            ListModel {
                id: defaultAlbums
                ListElement { name: "Album 1"; emoji: "💿"; tracks: 4 }
                ListElement { name: "Album 2"; emoji: "💿"; tracks: 5 }
                ListElement { name: "Album 3"; emoji: "💿"; tracks: 6 }
            }

            delegate: Rectangle {
                width: 150
                height: 190
                radius: 15
                color: Qt.rgba(1, 1, 1, 0.2)

                scale: albumMouseArea.pressed ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBounce
                    }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80FFFFFF"
                    radius: albumMouseArea.containsMouse ? 20 : 0
                    samples: 20
                    Behavior on radius {
                        NumberAnimation { duration: 200 }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.emoji
                        font.pixelSize: 72
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.name
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: model.tracks + " Songs"
                        color: "white"
                        opacity: 0.7
                        font.pixelSize: 14
                    }
                }

                MouseArea {
                    id: albumMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        albumClickAnimation.start()
                    }
                }

                SequentialAnimation {
                    id: albumClickAnimation
                    NumberAnimation {
                        target: parent
                        property: "scale"
                        to: 1.1
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: parent
                        property: "scale"
                        to: 1.0
                        duration: 100
                        easing.type: Easing.OutBounce
                    }
                }
            }

            add: Transition {
                NumberAnimation { property: "scale"; from: 0; to: 1; duration: 250; easing.type: Easing.OutBounce }
            }
        }

        // Title for Albums View
        Rectangle {
            visible: currentView === "albums"
            anchors.top: parent.top
            anchors.left: backButton.right
            anchors.right: parent.right
            anchors.margins: 10
            height: 60
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: selectedArtist
                color: "white"
                font.pixelSize: 24
                font.bold: true
            }
        }
    }
} 
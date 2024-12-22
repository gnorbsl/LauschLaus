import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtWebSockets 1.1

import "utils"
import "components"
import "views"

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
    
    // Mopidy controller
    MopidyController {
        id: mopidyController
    }
    
    // WebSocket for Mopidy connection
    WebSocket {
        id: socket
        url: "ws://localhost:6680/mopidy/ws"
        active: true
        
        onTextMessageReceived: {
            mopidyController.handleMessage(message)
        }
        
        onStatusChanged: {
            if (socket.status === WebSocket.Open) {
                console.log("WebSocket connected")
                mopidyController.initialize(socket)
                mopidyController.getArtists()
                mopidyController.getCurrentTrack()
            }
        }
    }
    
    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4158D0" }
            GradientStop { position: 0.46; color: "#C850C0" }
            GradientStop { position: 1.0; color: "#FFCC70" }
        }

        // Back button
        BackButton {
            id: backButton
            x: 10
            y: 10
            z: 1
            visible: currentView === "albums" || currentView === "player"
            onClicked: {
                if (currentView === "player") {
                    currentView = "albums"
                } else {
                    currentView = "artists"
                    selectedArtist = ""
                }
            }
        }

        // Title bar
        TitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: backButton.right
                right: parent.right
                margins: 10
            }
            visible: currentView === "albums" || currentView === "player"
            z: 1
            title: currentView === "player" ? mopidyController.currentAlbum : selectedArtist
        }

        // Main content area
        Rectangle {
            id: mainContent
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 12

            // Artists View
            ArtistsView {
                id: artistsView
                anchors.fill: parent
                visible: currentView === "artists"
                mopidyController: mopidyController
                onArtistSelected: (name, uri) => {
                    selectedArtist = name
                    mopidyController.getAlbums(uri)
                    currentView = "albums"
                }
            }

            // Albums View
            AlbumsView {
                id: albumsView
                anchors.fill: parent
                anchors.topMargin: 70
                visible: currentView === "albums"
                mopidyController: mopidyController
                onAlbumSelected: (name, uri) => {
                    mopidyController.playAlbum(uri)
                    currentView = "player"
                }
            }

            // Player View
            PlayerView {
                id: playerView
                anchors.fill: parent
                visible: currentView === "player"
                mopidyController: mopidyController
            }
        }
    }
} 
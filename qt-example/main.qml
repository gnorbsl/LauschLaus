import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtWebSockets 1.1

import "imports/utils" as Utils
import "imports/components" as Components
import "imports/views" as Views

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
    
    // Controllers
    Utils.ConfigLoader {
        id: configLoader
        
        onLoaded: {
            // Initialize Spotify
            var clientId = getValue("spotify.clientId", "")
            var clientSecret = getValue("spotify.clientSecret", "")
            
            if (clientId && clientSecret) {
                console.log("Initializing Spotify with credentials from config")
                spotifyController.initialize(clientId, clientSecret)
            } else {
                console.error("Spotify credentials not found in config")
            }
            
            // Initialize WebSocket connection
            socket.url = getValue("mopidy.url", "ws://localhost:6680/mopidy/ws")
            socket.active = true
        }
        
        onError: function(message) {
            console.error("Config error:", message)
        }
        
        Component.onCompleted: load()
    }
    
    Utils.MopidyController {
        id: mopidyController
    }
    
    Utils.SpotifyController {
        id: spotifyController
    }
    
    // WebSocket for Mopidy connection
    WebSocket {
        id: socket
        active: false
        
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

        // Navigation bar
        Components.NavigationBar {
            id: navigationBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            z: 1
            currentView: root.currentView
            onViewChanged: (view) => root.currentView = view
        }

        // Back button
        Components.BackButton {
            id: backButton
            x: 10
            y: navigationBar.height + 20
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
        Components.TitleBar {
            id: titleBar
            anchors {
                top: navigationBar.bottom
                left: backButton.right
                right: parent.right
                margins: 10
            }
            visible: currentView === "albums" || currentView === "player"
            z: 1
            title: currentView === "player" ? mopidyController.currentTrack : selectedArtist
        }

        // Main content area
        Rectangle {
            id: mainContent
            anchors {
                top: titleBar.visible ? titleBar.bottom : navigationBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 12

            // Artists View
            Views.ArtistsView {
                id: artistsView
                anchors.fill: parent
                visible: currentView === "artists"
                mopidyController: mopidyController
                spotifyController: spotifyController
                onArtistSelected: (name, uri) => {
                    selectedArtist = name
                    mopidyController.getAlbums(uri)
                    currentView = "albums"
                }
            }

            // Albums View
            Views.AlbumsView {
                id: albumsView
                anchors.fill: parent
                visible: currentView === "albums"
                mopidyController: mopidyController
                spotifyController: spotifyController
                selectedArtist: root.selectedArtist
                onAlbumSelected: (name, uri) => {
                    mopidyController.playAlbum(uri)
                    currentView = "player"
                }
            }

            // Player View
            Views.PlayerView {
                id: playerView
                anchors.fill: parent
                visible: currentView === "player"
                mopidyController: mopidyController
            }
        }
    }
} 
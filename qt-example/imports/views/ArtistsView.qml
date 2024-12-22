import QtQuick 2.15
import QtQuick.Layouts 1.15

GridView {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    
    property var mopidyController
    property var spotifyController
    signal artistSelected(string name, string uri)
    
    cellWidth: Math.floor((width - 20) / 4)
    cellHeight: 250
    clip: true

    model: ListModel {
        id: artistsModel
        dynamicRoles: true
    }

    delegate: Rectangle {
        id: card
        width: root.cellWidth - 15
        height: 240
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.2)
        
        Component.onCompleted: {
            console.log("Created card for", model.name, "with image URL:", model.imageUrl)
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            Rectangle {
                id: imageContainer
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: card.width - 12
                Layout.preferredHeight: card.height - 36
                Layout.maximumWidth: Layout.preferredWidth
                Layout.maximumHeight: Layout.preferredHeight
                color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
                clip: true

                // Background placeholder
                Text {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: 120
                    visible: !artistImage.visible
                }

                Image {
                    id: artistImage
                    width: parent.width - 4
                    height: parent.height - 4

                    anchors.fill: parent
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    opacity: status === Image.Ready ? 1 : 0
                    visible: status === Image.Ready

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    onSourceChanged: {
                        console.log("Image source changed for", model.name + ":", source)
                    }

                    onStatusChanged: {
                        switch (status) {
                            case Image.Loading:
                                console.log("Loading image for", model.name)
                                break
                            case Image.Ready:
                                console.log("Successfully loaded image for", model.name)
                                break
                            case Image.Error:
                                console.log("Error loading image for", model.name + ":", source)
                                break
                            case Image.Null:
                                console.log("Null image for", model.name)
                                break
                        }
                    }
                }

                // Loading indicator
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: artistImage.status === Image.Loading
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⌛"
                        font.pixelSize: 48
                    }
                }

                // Error indicator
                Text {
                    anchors.centerIn: parent
                    text: "❌"
                    font.pixelSize: 92
                    visible: artistImage.status === Image.Error
                }
            }

            Text {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                text: model.name
                color: "white"
                font.pixelSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                opacity: 0.8
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                parent.scale = 0.95
                clickAnim.start()
            }
        }

        SequentialAnimation {
            id: clickAnim
            NumberAnimation {
                target: card
                property: "scale"
                to: 1.15
                duration: 100
            }
            NumberAnimation {
                target: card
                property: "scale"
                to: 1.0
                duration: 100
            }
            ScriptAction {
                script: root.artistSelected(model.name, model.uri)
            }
        }
    }

    Connections {
        target: mopidyController
        function onArtistsReceived(artists) {
            console.log("Received artists:", artists.length)
            artistsModel.clear()
            for (var i = 0; i < artists.length; i++) {
                var artist = artists[i]
                artist.imageUrl = ""  // Initialize with empty string
                artistsModel.append(artist)
                if (spotifyController && spotifyController.isInitialized) {
                    console.log("Fetching image for artist:", artist.name)
                    fetchSpotifyImage(artist.name, i)
                }
            }
        }
    }

    Connections {
        target: spotifyController
        function onInitialized() {
            console.log("Spotify initialized, refreshing artist images")
            for (var i = 0; i < artistsModel.count; i++) {
                var artist = artistsModel.get(i)
                console.log("Refreshing image for artist:", artist.name)
                fetchSpotifyImage(artist.name, i)
            }
        }
    }

    function fetchSpotifyImage(artistName, modelIndex) {
        spotifyController.getArtistImage(artistName, function(imageUrl) {
            if (imageUrl && modelIndex < artistsModel.count) {
                console.log("Setting image URL for", artistName + ":", imageUrl)
                artistsModel.setProperty(modelIndex, "imageUrl", imageUrl)
            }
        })
    }
} 
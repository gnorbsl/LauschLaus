import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

GridView {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    
    property var mopidyController
    property var spotifyController
    property string selectedArtist
    signal albumSelected(string name, string uri)
    
    cellWidth: Math.floor((width - 20) / 5)
    cellHeight: 190
    clip: true

    model: ListModel {
        id: albumsModel
    }

    property var pendingImageRequests: ({})

    delegate: Rectangle {
        id: albumCard
        width: root.cellWidth - 10
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
                clip: true

                // Background placeholder
                Text {
                    anchors.centerIn: parent
                    text: model.emoji || "💿"
                    font.pixelSize: 72
                    font.family: "Noto Color Emoji"
                    visible: albumImage.status !== Image.Ready
                }

                Image {
                    id: albumImage
                    anchors.fill: parent
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    opacity: status === Image.Ready ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    onStatusChanged: {
                        switch (status) {
                            case Image.Loading:
                                console.log("[Image] Loading:", model.name)
                                break
                            case Image.Ready:
                                console.log("[Image] Ready:", model.name)
                                break
                            case Image.Error:
                                console.log("[Image] Error:", model.name, source)
                                break
                            case Image.Null:
                                console.log("[Image] Null:", model.name)
                                break
                        }
                    }
                }

                // Loading indicator
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: albumImage.status === Image.Loading
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⌛"
                        font.pixelSize: 32
                    }
                }

                // Error indicator
                Text {
                    anchors.centerIn: parent
                    text: "❌"
                    font.pixelSize: 72
                    visible: albumImage.status === Image.Error
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
            ScriptAction {
                script: root.albumSelected(model.name, model.uri)
            }
        }

        Component.onCompleted: {
            console.log("Album delegate created for:", model.name)
        }
    }

    Connections {
        target: mopidyController
        function onAlbumsReceived(albums) {
            console.log("Received", albums.length, "albums")
            albumsModel.clear()
            pendingImageRequests = ({})
            for (var i = 0; i < albums.length; i++) {
                var album = albums[i]
                album.imageUrl = "" // Start with empty URL
                albumsModel.append(album)
                // Request image immediately
                if (!pendingImageRequests[album.uri]) {
                    pendingImageRequests[album.uri] = true
                    console.log("[Mopidy] Requesting image for:", album.name, "URI:", album.uri)
                    mopidyController.getImage(album.uri)
                }
            }
        }

        function onImageReceived(uri, imageUrl) {
            if (!imageUrl) return
            console.log("[Mopidy] Setting image URL for URI:", uri)
            delete pendingImageRequests[uri]
            for (var i = 0; i < albumsModel.count; i++) {
                if (albumsModel.get(i).uri === uri) {
                    albumsModel.setProperty(i, "imageUrl", imageUrl)
                    break
                }
            }
        }
    }

    Component.onCompleted: {
        if (spotifyController && spotifyController.isInitialized) {
            console.log("Spotify controller is initialized")
        }
    }
} 
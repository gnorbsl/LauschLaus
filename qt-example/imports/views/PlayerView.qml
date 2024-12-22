import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "transparent"

    property var mopidyController

    // Controls container (left side)
    Rectangle {
        id: controlsContainer
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.35
        color: Qt.rgba(0, 0, 0, 0.3)

        Column {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20

            // Title container
            Rectangle {
                width: parent.width
                height: 80
                color: Qt.rgba(1, 1, 1, 0.1)
                radius: 12

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 40
                    text: mopidyController.currentTrack || "No track playing"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
            }

            // Playback controls
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                // Previous track
                Rectangle {
                    width: 70
                    height: 70
                    radius: 35
                    color: Qt.rgba(1, 1, 1, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "⏮️"
                        font.pixelSize: 32
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mopidyController.previousTrack()
                    }
                }

                // Play/Pause
                Rectangle {
                    width: 90
                    height: 90
                    radius: 45
                    color: Qt.rgba(1, 1, 1, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: mopidyController.isPlaying ? "⏸️" : "▶️"
                        font.pixelSize: 40
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mopidyController.togglePlayPause()
                    }
                }

                // Next track
                Rectangle {
                    width: 70
                    height: 70
                    radius: 35
                    color: Qt.rgba(1, 1, 1, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: "⏭️"
                        font.pixelSize: 32
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mopidyController.nextTrack()
                    }
                }
            }
        }
    }

    // Album art container (right side)
    Rectangle {
        anchors {
            left: controlsContainer.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.8
            height: width
            color: Qt.rgba(1, 1, 1, 0.1)
            radius: 12
            clip: true

            Image {
                id: albumArtImage
                anchors.fill: parent
                source: mopidyController.currentAlbumImage || ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
                asynchronous: true
                cache: false

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("Error loading image:", source)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "💿"
                font.pixelSize: Math.min(parent.width, parent.height) * 0.6
                font.family: "Noto Color Emoji"
                visible: !mopidyController.currentAlbumImage || albumArtImage.status !== Image.Ready
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: mopidyController.getCurrentTrack()
    }
} 
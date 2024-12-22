import QtQuick 2.15
import QtQuick.Layouts 1.15

GridView {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    
    property var mopidyController
    signal artistSelected(string name, string uri)
    
    cellWidth: Math.floor((width - 20) / 5)
    cellHeight: 190
    clip: true

    model: ListModel {
        id: artistsModel
    }

    delegate: Rectangle {
        id: card
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

                Image {
                    id: artistImage
                    anchors.fill: parent
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: 72
                    font.family: "Noto Color Emoji"
                    visible: artistImage.status !== Image.Ready
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
                script: root.artistSelected(model.name, model.uri)
            }
        }

        Component.onCompleted: {
            mopidyController.getArtistImage(model.uri)
        }
    }

    Connections {
        target: mopidyController
        function onArtistsReceived(artists) {
            artistsModel.clear()
            for (var i = 0; i < artists.length; i++) {
                artistsModel.append(artists[i])
            }
        }

        function onArtistImageReceived(uri, imageUrl) {
            for (var i = 0; i < artistsModel.count; i++) {
                if (artistsModel.get(i).uri === uri) {
                    artistsModel.setProperty(i, "imageUrl", imageUrl)
                    break
                }
            }
        }
    }
} 
import QtQuick 2.15
import QtQuick.Layouts 1.15

GridView {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    
    property var mopidyController
    signal albumSelected(string name, string uri)
    
    cellWidth: Math.floor((width - 20) / 5)
    cellHeight: 190
    clip: true

    model: ListModel {
        id: albumsModel
    }

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

                Image {
                    id: albumImage
                    anchors.fill: parent
                    source: model.imageUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    text: model.emoji || "💿"
                    font.pixelSize: 72
                    font.family: "Noto Color Emoji"
                    visible: albumImage.status !== Image.Ready
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
            mopidyController.getAlbumImage(model.uri)
        }
    }

    Connections {
        target: mopidyController
        function onAlbumsReceived(albums) {
            albumsModel.clear()
            for (var i = 0; i < albums.length; i++) {
                albumsModel.append(albums[i])
            }
        }

        function onAlbumImageReceived(uri, imageUrl) {
            for (var i = 0; i < albumsModel.count; i++) {
                if (albumsModel.get(i).uri === uri) {
                    albumsModel.setProperty(i, "imageUrl", imageUrl)
                    break
                }
            }
        }
    }
} 
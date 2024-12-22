import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    height: 60
    color: Qt.rgba(0, 0, 0, 0.3)
    
    property string currentView: "artists"
    signal viewChanged(string view)
    
    Row {
        anchors.centerIn: parent
        spacing: 20
        
        // Artists button
        Rectangle {
            width: 120
            height: 40
            radius: 20
            color: root.currentView === "artists" ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)
            
            Text {
                anchors.centerIn: parent
                text: "Artists"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: root.viewChanged("artists")
            }
        }
        
        // Albums button
        Rectangle {
            width: 120
            height: 40
            radius: 20
            color: root.currentView === "albums" ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)
            
            Text {
                anchors.centerIn: parent
                text: "Albums"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: root.viewChanged("albums")
            }
        }
        
        // Player button
        Rectangle {
            width: 120
            height: 40
            radius: 20
            color: root.currentView === "player" ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)
            
            Text {
                anchors.centerIn: parent
                text: "Player"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: root.viewChanged("player")
            }
        }
    }
} 
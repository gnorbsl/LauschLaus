import QtQuick 2.15
import QtWebSockets 1.1

QtObject {
    id: root

    property string mopidyServerUrl: "http://localhost:6680"
    property var socket: null
    property bool isPlaying: false
    property string currentTrack: ""
    property string currentAlbum: ""
    property string currentAlbumUri: ""
    property string currentAlbumImage: ""
    property var artists: []
    
    signal artistsReceived(var artists)
    signal albumsReceived(var albums)
    signal playbackStateChanged()
    signal imageReceived(string uri, string imageUrl)

    function initialize(websocket) {
        socket = websocket
    }

    function sendRequest(method, params, id) {
        if (!socket) return
        
        var request = {
            jsonrpc: "2.0",
            id: id,
            method: method,
            params: params || {}
        }
        
        socket.sendTextMessage(JSON.stringify(request))
    }

    function handleMessage(message) {
        var msg = JSON.parse(message)
        
        if (msg.event === "state_changed") {
            if (msg.new_state === "playing") {
                isPlaying = true
            } else if (msg.new_state === "stopped" || msg.new_state === "paused") {
                isPlaying = false
            }
            playbackStateChanged()
            return
        }
        
        if (msg.id === "getArtists") {
            artists = msg.result
            artistsReceived(msg.result)
        } else if (msg.id === "getAlbums") {
            albumsReceived(msg.result)
        } else if (msg.id === "getCurrentTrack") {
            if (msg.result && msg.result.name) {
                currentTrack = msg.result.name
                if (msg.result.album) {
                    currentAlbum = msg.result.album.name
                    currentAlbumUri = msg.result.album.uri
                    getImage(currentAlbumUri)
                }
            }
        } else if (msg.id && msg.id.startsWith("getImage_")) {
            var uri = msg.id.replace("getImage_", "")
            if (msg.result && msg.result[uri] && msg.result[uri].length > 0) {
                var images = msg.result[uri]
                console.log("[Mopidy] Images received for", uri + ":", JSON.stringify(images))
                images.sort((a, b) => (b.width || 0) - (a.width || 0))
                if (images[0].uri) {
                    var imageUrl = images[0].uri
                    if (!imageUrl.startsWith("http")) {
                        imageUrl = mopidyServerUrl + imageUrl
                    }
                    console.log("[Mopidy] Image received for", uri + ":", imageUrl)
                    imageReceived(uri, imageUrl)
                    if (uri === currentAlbumUri) {
                        currentAlbumImage = imageUrl
                    }
                }
            }
        }
    }

    function getArtists() {
        sendRequest("core.library.browse", { uri: "local:directory?type=artist" }, "getArtists")
    }

    function getAlbums(artistUri) {
        sendRequest("core.library.browse", { uri: artistUri }, "getAlbums")
    }

    function playAlbum(albumUri) {
        sendRequest("core.tracklist.clear", {}, "clear")
        sendRequest("core.tracklist.add", { uris: [albumUri] }, "add")
        sendRequest("core.playback.play", {}, "play")
        getCurrentTrack()
    }

    function getCurrentTrack() {
        sendRequest("core.playback.get_current_track", {}, "getCurrentTrack")
    }

    function getImage(uri) {
        sendRequest("core.library.get_images", { uris: [uri] }, "getImage_" + uri)
    }
} 
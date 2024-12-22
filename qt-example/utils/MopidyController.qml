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
    
    signal artistsReceived(var artists)
    signal albumsReceived(var albums)
    signal currentTrackChanged()
    signal playbackStateChanged()
    signal artistImageReceived(string uri, string imageUrl)
    signal albumImageReceived(string uri, string imageUrl)

    function initialize(websocket) {
        socket = websocket
    }

    function sendRequest(method, params, id) {
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
        console.log("Received message:", JSON.stringify(msg))
        
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
            artistsReceived(processArtists(msg.result))
        } else if (msg.id === "getAlbums") {
            albumsReceived(processAlbums(msg.result))
        } else if (msg.id === "getCurrentTrack") {
            if (msg.result && msg.result.name) {
                currentTrack = msg.result.name
                if (msg.result.album) {
                    currentAlbum = msg.result.album.name
                    currentAlbumUri = msg.result.album.uri
                    getAlbumImage(currentAlbumUri)
                }
                currentTrackChanged()
            }
        } else if (msg.id && msg.id.startsWith("getArtistImage_")) {
            var artistUri = msg.id.replace("getArtistImage_", "")
            if (msg.result && msg.result[artistUri] && msg.result[artistUri].length > 0) {
                var images = msg.result[artistUri]
                images.sort((a, b) => (b.width || 0) - (a.width || 0))
                if (images[0].uri) {
                    artistImageReceived(artistUri, mopidyServerUrl + images[0].uri)
                }
            }
        } else if (msg.id && msg.id.startsWith("getAlbumImage_")) {
            var albumUri = msg.id.replace("getAlbumImage_", "")
            if (msg.result && msg.result[albumUri] && msg.result[albumUri].length > 0) {
                var albumImages = msg.result[albumUri]
                albumImages.sort((a, b) => (b.width || 0) - (a.width || 0))
                if (albumImages[0].uri) {
                    var imageUrl = mopidyServerUrl + albumImages[0].uri
                    albumImageReceived(albumUri, imageUrl)
                    if (albumUri === currentAlbumUri) {
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

    function togglePlayPause() {
        if (isPlaying) {
            sendRequest("core.playback.pause", {}, "pause")
        } else {
            sendRequest("core.playback.play", {}, "play")
        }
    }

    function nextTrack() {
        sendRequest("core.playback.next", {}, "next")
        getCurrentTrack()
    }

    function previousTrack() {
        sendRequest("core.playback.previous", {}, "previous")
        getCurrentTrack()
    }

    function getArtistImage(artistUri) {
        if (artistUri) {
            try {
                sendRequest("core.library.get_images", { uris: [artistUri] }, "getArtistImage_" + artistUri)
            } catch (error) {
                console.log("Error getting artist image:", error)
            }
        }
    }

    function getAlbumImage(albumUri) {
        if (albumUri) {
            try {
                sendRequest("core.library.get_images", { uris: [albumUri] }, "getAlbumImage_" + albumUri)
            } catch (error) {
                console.log("Error getting album image:", error)
            }
        }
    }

    function processArtists(result) {
        var artists = []
        for (var i = 0; i < result.length; i++) {
            var artist = result[i]
            artists.push({
                name: artist.name,
                uri: artist.uri,
                type: "artist",
                imageUrl: ""
            })
        }
        return artists
    }

    function processAlbums(result) {
        var albums = []
        for (var i = 0; i < result.length; i++) {
            var album = result[i]
            albums.push({
                name: album.name,
                uri: album.uri,
                emoji: getEmoji(album.name),
                imageUrl: ""
            })
        }
        return albums
    }

    function getEmoji(name) {
        var emojiMap = {
            'Aladdin': '🧞',
            'Bob der Baumeister': '👷',
            'Das Dschungelbuch': '🐯',
            'Die Playmos': '🎮',
            'PAW Patrol': '🐕',
            'Ratatouille': '🐀',
            'Tarzan': '🦍'
        }
        return emojiMap[name] || '🎵'
    }
} 
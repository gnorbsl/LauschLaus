import QtQuick 2.15

QtObject {
    id: root
    
    property string clientId: ""
    property string clientSecret: ""
    property string accessToken: ""
    property bool isInitialized: false
    
    signal initialized()
    
    function initialize(id, secret) {
        clientId = id
        clientSecret = secret
        
        // Get access token
        var xhr = new XMLHttpRequest()
        var data = "grant_type=client_credentials"
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    accessToken = response.access_token
                    isInitialized = true
                    initialized()
                } else {
                    console.error("Failed to get Spotify access token:", xhr.status, xhr.statusText)
                }
            }
        }
        
        xhr.open("POST", "https://accounts.spotify.com/api/token")
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        xhr.setRequestHeader("Authorization", "Basic " + Qt.btoa(clientId + ":" + clientSecret))
        xhr.send(data)
    }
    
    function getArtistImage(artistName, callback) {
        if (!isInitialized) {
            callback(null)
            return
        }
        
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.artists.items.length > 0) {
                        var images = response.artists.items[0].images
                        if (images.length > 0) {
                            callback(images[0].url)
                            return
                        }
                    }
                    callback(null)
                } else {
                    console.error("Failed to get artist image:", xhr.status, xhr.statusText)
                    callback(null)
                }
            }
        }
        
        xhr.open("GET", "https://api.spotify.com/v1/search?q=" + encodeURIComponent(artistName) + "&type=artist&limit=1")
        xhr.setRequestHeader("Authorization", "Bearer " + accessToken)
        xhr.send()
    }
    
    function getAlbumImage(albumName, artistName, callback) {
        if (!isInitialized) {
            callback(null)
            return
        }
        
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.albums.items.length > 0) {
                        var images = response.albums.items[0].images
                        if (images.length > 0) {
                            callback(images[0].url)
                            return
                        }
                    }
                    callback(null)
                } else {
                    console.error("Failed to get album image:", xhr.status, xhr.statusText)
                    callback(null)
                }
            }
        }
        
        var query = albumName
        if (artistName) {
            query += " artist:" + artistName
        }
        
        xhr.open("GET", "https://api.spotify.com/v1/search?q=" + encodeURIComponent(query) + "&type=album&limit=1")
        xhr.setRequestHeader("Authorization", "Bearer " + accessToken)
        xhr.send()
    }
} 
import QtQuick 2.15

QtObject {
    id: root
    
    property var config: ({})
    property bool isLoaded: false
    property string configPath: Qt.resolvedUrl("../../config.json")
    signal loaded()
    signal error(string message)
    
    function load() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        config = JSON.parse(xhr.responseText)
                        isLoaded = true
                        console.log("Config loaded successfully")
                        loaded()
                    } catch (e) {
                        console.error("Failed to parse config:", e)
                        error("Failed to parse config file")
                    }
                } else {
                    console.error("Failed to load config from path:", configPath)
                    error("Failed to load config file")
                }
            }
        }
        
        console.log("Loading config from:", configPath)
        xhr.open("GET", configPath)
        xhr.send()
    }
    
    function getValue(path, defaultValue) {
        if (!isLoaded) {
            console.warn("Config not loaded yet")
            return defaultValue
        }
        
        var parts = path.split('.')
        var current = config
        
        for (var i = 0; i < parts.length; i++) {
            if (current === undefined || current === null) {
                return defaultValue
            }
            current = current[parts[i]]
        }
        
        return current !== undefined ? current : defaultValue
    }
} 
#!/bin/bash

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Create runtime directory if it doesn't exist
mkdir -p /tmp/runtime-pi
chmod 700 /tmp/runtime-pi

# Common environment variables
export QT_FONT_DPI=96
export XDG_RUNTIME_DIR=/tmp/runtime-pi

# Try platforms in order: eglfs -> linuxfb -> minimal
platforms=("eglfs" "linuxfb" "minimal")
for platform in "${platforms[@]}"; do
    echo "Trying platform: $platform"
    export QT_QPA_PLATFORM=$platform
    
    case $platform in
        "eglfs")
            export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
            ;;
        "linuxfb")
            export QT_QPA_FB_DRM=1
            export QT_QPA_FB_HIDECURSOR=1
            export QT_QPA_FB_TSLIB=1
            if [ -e /dev/fb0 ]; then
                sudo chmod 666 /dev/fb0
            fi
            ;;
        "minimal")
            unset QT_QPA_FB_DRM
            unset QT_QPA_FB_HIDECURSOR
            unset QT_QPA_FB_TSLIB
            ;;
    esac
    
    # Try to run the application
    sudo -E ./KidsPlayer
    
    # If the application exits with status 0, break the loop
    if [ $? -eq 0 ]; then
        break
    fi
done
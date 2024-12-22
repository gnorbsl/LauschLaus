#!/bin/bash

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Set environment variables for Qt
export QT_QPA_PLATFORM=linuxfb
export QT_QPA_FB_DRM=1
export QT_QPA_FB_HIDECURSOR=1
export QT_QPA_FB_TSLIB=1
export QT_QPA_GENERIC_PLUGINS=evdevtouch:/dev/input/event0
export QT_FONT_DPI=96
export XDG_RUNTIME_DIR=/tmp/runtime-pi

# Create runtime directory if it doesn't exist
mkdir -p /tmp/runtime-pi
chmod 700 /tmp/runtime-pi

# Make sure we have access to the framebuffer device
if [ -e /dev/fb0 ]; then
    sudo chmod 666 /dev/fb0
fi

# Run the application
sudo -E ./KidsPlayer
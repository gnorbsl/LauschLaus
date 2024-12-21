#!/bin/bash

# Enable debug output
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="qt.qpa.*=true"

# Set up framebuffer environment
export QT_QPA_PLATFORM=linuxfb
export QT_QPA_FB_DEV=/dev/fb0
export QT_QPA_FB_TTY=/dev/tty1
export QT_QPA_FB_HIDECURSOR=1
export QT_QPA_FB_TSLIB=1

# Check if we need sudo for framebuffer access
if [ ! -w /dev/fb0 ] || [ ! -w /dev/tty1 ]; then
    echo "Need root access for framebuffer"
    sudo -E ./build/KidsPlayer 2>&1 | tee app.log
else
    ./build/KidsPlayer 2>&1 | tee app.log
fi
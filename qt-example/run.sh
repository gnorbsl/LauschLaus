#!/bin/bash

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Create runtime directory if it doesn't exist
mkdir -p /tmp/runtime-pi
chmod 700 /tmp/runtime-pi

# Set environment variables for Qt
export QT_QPA_PLATFORM=linuxfb
export QT_QPA_FB_NO_LIBINPUT=1
export QT_QPA_GENERIC_PLUGINS=evdevtouch:/dev/input/event0
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/event0:rotate=0
export QT_QPA_FB_HIDECURSOR=1
export QT_FONT_DPI=96
export XDG_RUNTIME_DIR=/tmp/runtime-pi

# Make sure we have access to the framebuffer and input devices
if [ -e /dev/fb0 ]; then
    sudo chmod 666 /dev/fb0
fi

for dev in /dev/input/event*; do
    sudo chmod 666 "$dev"
done

# Run the application
sudo -E ./KidsPlayer
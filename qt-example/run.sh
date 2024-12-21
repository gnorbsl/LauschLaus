#!/bin/bash

# Install required packages if they're not present
if ! command -v matchbox-window-manager &> /dev/null; then
    echo "Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y matchbox-window-manager x11-xserver-utils
fi

# Kill any existing X server and related processes
sudo killall X matchbox-window-manager KidsPlayer 2>/dev/null

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Set up environment
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Create XDG_RUNTIME_DIR if it doesn't exist
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    sudo mkdir -p $XDG_RUNTIME_DIR
    sudo chmod 700 $XDG_RUNTIME_DIR
    sudo chown $(id -u):$(id -g) $XDG_RUNTIME_DIR
fi

# Qt configuration
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="qt.qpa.*=true"
export QT_QPA_PLATFORM=xcb
export QT_QPA_GENERIC_PLUGINS=evdevtouch:/dev/input/event0

# Copy X session configuration
cp .xinitrc ~/

# Build the application
./build.sh

# Start X server with our configuration
startx -- -nocursor

# Show logs if something goes wrong
echo "Checking logs..."
cat /tmp/xinitrc.log
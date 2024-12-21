#!/bin/bash

# Install required packages if they're not present
if ! command -v matchbox-window-manager &> /dev/null; then
    echo "Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y matchbox-window-manager x11-xserver-utils
fi

# Copy our X session configuration
cp .xinitrc ~/

# Set up X11 environment
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Create XDG_RUNTIME_DIR if it doesn't exist
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    sudo mkdir -p $XDG_RUNTIME_DIR
    sudo chmod 700 $XDG_RUNTIME_DIR
    sudo chown $(id -u):$(id -g) $XDG_RUNTIME_DIR
fi

# Enable debug output
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="qt.qpa.*=true"
export QT_QPA_PLATFORM=xcb

# Kill any existing X server
sudo killall X

# Start X with our configuration
startx -- -nocursor

# Run the application
./build/KidsPlayer 2>&1 | tee app.log
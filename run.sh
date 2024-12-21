#!/bin/bash

# Pull latest changes
git pull

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Set environment variables for Qt
export QT_QPA_PLATFORM=xcb
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
export QT_FONT_DPI=96
export XDG_RUNTIME_DIR=/tmp/runtime-pi

# Create runtime directory if it doesn't exist
mkdir -p /tmp/runtime-pi
chmod 700 /tmp/runtime-pi

# Build the application
./build.sh

# Run the application
sudo ./build/KidsPlayer

# ... existing code ... 
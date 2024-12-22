#!/bin/bash

# Clean up any existing X locks
sudo rm -f /tmp/.X0-lock

# Set environment variables for Qt
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
export QT_QPA_EGLFS_KMS_ATOMIC=1
export QT_QPA_EGLFS_FORCE888=1
export QT_FONT_DPI=96
export XDG_RUNTIME_DIR=/tmp/runtime-pi

# Create runtime directory if it doesn't exist
mkdir -p /tmp/runtime-pi
chmod 700 /tmp/runtime-pi

# Run the application with access to the graphics device
sudo -E ./KidsPlayer
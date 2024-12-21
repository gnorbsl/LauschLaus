#!/bin/bash

# Make sure X is running
if ! ps aux | grep -v grep | grep -q "X.*:0"; then
    echo "Starting X server..."
    startx &
    sleep 5  # Wait for X to start
fi

# Set environment variables for X11
export DISPLAY=:0
export QT_QPA_PLATFORM=xcb
export XAUTHORITY=$HOME/.Xauthority

# Run the application
./build/KidsPlayer 
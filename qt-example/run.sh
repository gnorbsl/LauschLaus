#!/bin/bash

# Make sure we're in a graphical environment
if ! pgrep -x "X" > /dev/null; then
    echo "Starting X server..."
    startx -- -nocursor &
    sleep 3
fi

# Enable debug output
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="qt.qpa.*=true"
export DISPLAY=:0
export QT_QPA_PLATFORM=offscreen

# Run the application
./build/KidsPlayer 2>&1 | tee app.log
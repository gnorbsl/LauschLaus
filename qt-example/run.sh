#!/bin/bash

# Enable debug output
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="qt.qpa.*=true"
export QT_QPA_PLATFORM=minimal

# Run the application with debug output
./build/KidsPlayer 2>&1 | tee app.log 
#!/bin/sh

# Enable error logging
exec 1>/tmp/xinitrc.log 2>&1

# Set background color
xsetroot -solid "#4158D0"

# Start window manager
matchbox-window-manager -use_cursor no &

# Wait a moment for window manager to start
sleep 2

# Start our application
cd /home/dietpi/LauschLaus/qt-example
exec ./build/KidsPlayer
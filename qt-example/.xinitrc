#!/bin/sh

# Load X resources
xrdb -merge ~/.Xresources

# Start a minimal window manager
matchbox-window-manager -use_cursor no &

# Execute our application
cd /home/dietpi/LauschLaus/qt-example
./build/KidsPlayer

# Keep the X session running
exec sleep infinity 
#!/bin/bash

# Set environment variables
export QT_QPA_EGLFS_KMS_CONFIG=$(pwd)/eglfs.json
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=eglfs_brcm
export QT_QPA_EGLFS_PHYSICAL_WIDTH=800
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=480
export QT_QPA_EGLFS_HIDECURSOR=1
export QT_QPA_EGLFS_FB=/dev/fb0

# Make sure we have access to the framebuffer
if [ ! -w /dev/fb0 ]; then
    echo "Need root access for framebuffer"
    sudo ./build/KidsPlayer
else
    ./build/KidsPlayer
fi 
#!/bin/bash

# Remove build artifacts
rm -rf CMakeCache.txt
rm -rf CMakeFiles
rm -rf Makefile
rm -rf KidsPlayer
rm -rf qrc_resources.cpp
rm -rf resources.qrc.depends
rm -rf KidsPlayer_autogen
rm -rf cmake_install.cmake
rm -rf build
rm -rf cache
rm -rf .xinitrc
rm -rf eglfs.json
rm -rf build.sh

# Keep only essential files
essential_files=(
    "main.cpp"
    "main.qml"
    "CMakeLists.txt"
    "run.sh"
    "config.json"
    "imports"
)

# List files that will be kept
echo "The following files will be kept:"
for file in "${essential_files[@]}"; do
    if [ -e "$file" ]; then
        echo "  $file"
    fi
done 
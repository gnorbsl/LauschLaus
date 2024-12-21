#!/bin/bash

# Exit on error
set -e

echo "🎵 Downloading LauschLaus installer..."
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/gnorbsl/LauschLaus/master/install.sh"
TEMP_DIR=$(mktemp -d)
INSTALL_SCRIPT="$TEMP_DIR/install.sh"

# Download the installation script
curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SCRIPT"
chmod +x "$INSTALL_SCRIPT"

# Run the installation script
echo "🚀 Starting installation..."
$INSTALL_SCRIPT

# Clean up
rm -rf "$TEMP_DIR" 
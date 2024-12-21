#!/bin/bash

# Exit on error
set -e

echo "🗑️  Uninstalling LauschLaus..."

# Stop and disable services
echo "⏹️  Stopping services..."
sudo systemctl stop lausch-laus-monitor || true
sudo systemctl stop filebrowser || true
sudo systemctl stop lausch-laus-frontend || true
sudo systemctl stop mopidy || true

echo "🔌 Disabling services..."
sudo systemctl disable lausch-laus-monitor || true
sudo systemctl disable filebrowser || true
sudo systemctl disable lausch-laus-frontend || true
sudo systemctl disable mopidy || true

# Remove service files
echo "🗑️  Removing service files..."
sudo rm -f /etc/systemd/system/lausch-laus-monitor.service
sudo rm -f /etc/systemd/system/filebrowser.service
sudo rm -f /etc/systemd/system/lausch-laus-frontend.service
sudo rm -f /etc/systemd/system/mopidy.service
sudo systemctl daemon-reload

# Remove scripts and binaries
echo "🗑️  Removing scripts and binaries..."
sudo rm -f /usr/local/bin/lausch-laus-monitor
sudo rm -f /usr/local/bin/filebrowser

# Remove configuration files
echo "🗑️  Removing configuration files..."
sudo rm -rf /etc/mopidy
sudo rm -f /etc/apt/sources.list.d/mopidy.list
sudo rm -f /etc/apt/keyrings/mopidy-archive-keyring.gpg

# Remove Node.js repository
echo "🗑️  Removing Node.js repository..."
sudo rm -f /etc/apt/sources.list.d/nodesource.list*
sudo rm -f /etc/apt/keyrings/nodesource.gpg

# Remove LauschLaus directory and files
echo "🗑️  Removing LauschLaus files..."
cd ~
rm -rf LauschLaus

# Ask about removing music directory
read -p "❓ Do you want to remove the music directory (~/Music/LauschLaus)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing music directory..."
    rm -rf ~/Music/LauschLaus
else
    echo "💾 Keeping music directory at ~/Music/LauschLaus"
fi

echo "✨ Uninstallation complete!"
echo "🔄 Note: System packages were not removed to avoid affecting other applications."
echo "🔄 You may need to reboot your system for all changes to take effect." 
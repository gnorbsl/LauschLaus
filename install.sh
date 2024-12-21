#!/bin/bash

# Exit on error
set -e

echo "🎵 Installing LauschLaus..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt-get install -y \
    python3-pip \
    python3-gst-1.0 \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools \
    gir1.2-gstreamer-1.0 \
    gir1.2-gst-plugins-base-1.0 \
    git \
    curl \
    inotify-tools

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Mopidy and extensions
echo "📦 Installing Mopidy..."
# Add Mopidy APT repository signing key
sudo mkdir -p /etc/apt/keyrings
sudo wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    https://apt.mopidy.com/mopidy.gpg

# Add the APT repo to package sources
sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/bookworm.list

# Install Mopidy and all dependencies
sudo apt-get update
sudo apt-get install -y mopidy

# Install Mopidy extensions
echo "📦 Installing Mopidy extensions..."
sudo pip3 install Mopidy-MPD Mopidy-Local

# Create default music directory
echo "📁 Creating default music directory..."
mkdir -p ~/Music/LauschLaus
sudo chown -R $USER:$USER ~/Music/LauschLaus

# Clone LauschLaus repository
echo "📦 Cloning LauschLaus repository..."
git clone https://github.com/gnorbsl/LauschLaus.git
cd LauschLaus

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
npm install
npm run build
cd ..

# Configure Mopidy
echo "🔧 Configuring Mopidy..."
sudo mkdir -p /etc/mopidy
sudo tee /etc/mopidy/mopidy.conf > /dev/null << EOL
[http]
enabled = true
hostname = 127.0.0.1
port = 6680
allowed_origins = localhost:3000

[audio]
output = autoaudiosink

[local]
enabled = true
media_dir = $(eval echo ~)/Music/LauschLaus
EOL

# Install File Browser
echo "📦 Installing File Browser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | sudo bash

# Create systemd service for File Browser
echo "🔧 Creating systemd service for File Browser..."
sudo tee /etc/systemd/system/filebrowser.service > /dev/null << EOL
[Unit]
Description=File Browser
After=network.target

[Service]
ExecStart=/bin/bash -c '/usr/local/bin/filebrowser -a $(hostname -I | cut -d" " -f1) -r ~/Music/LauschLaus --branding.name "LauschLaus"'
Restart=on-failure
User=$USER

[Install]
WantedBy=multi-user.target
EOL

# Create systemd service for Mopidy
echo "🔧 Creating systemd service for Mopidy..."
sudo tee /etc/systemd/system/mopidy.service > /dev/null << EOL
[Unit]
Description=Mopidy Music Server
After=network.target

[Service]
User=mopidy
ExecStart=/usr/bin/mopidy
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Create systemd service for frontend
echo "🔧 Creating systemd service for frontend..."
sudo tee /etc/systemd/system/lausch-laus-frontend.service > /dev/null << EOL
[Unit]
Description=LauschLaus Frontend
After=network.target

[Service]
WorkingDirectory=/home/pi/LauschLaus/frontend
ExecStart=/usr/bin/npm run preview
Restart=on-failure
User=pi
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
EOL

# Create media monitor script
echo "📝 Creating media monitor script..."
sudo tee /usr/local/bin/lausch-laus-monitor << EOL
#!/bin/bash

MUSIC_DIR="\$HOME/Music/LauschLaus"
EVENTS="create,delete,modify,move"
DEBOUNCE_SECONDS=30
LAST_SCAN_FILE="/tmp/lausch_laus_last_scan"

echo "🔍 Starting LauschLaus media monitor..."
echo "📁 Watching directory: \$MUSIC_DIR"

# Function to perform the scan
do_scan() {
    echo "🔄 Triggering Mopidy local scan..."
    mopidy local scan
    date +%s > "\$LAST_SCAN_FILE"
}

# Initial scan on startup
do_scan

inotifywait -m -r -e \$EVENTS "\$MUSIC_DIR" | while read -r directory events filename; do
    echo "📀 Detected changes in music directory: \$events on \$filename"
    
    # Get current time and last scan time
    current_time=\$(date +%s)
    last_scan_time=\$(cat "\$LAST_SCAN_FILE" 2>/dev/null || echo 0)
    
    # Calculate time difference
    time_diff=\$((current_time - last_scan_time))
    
    # If enough time has passed since last scan
    if [ \$time_diff -ge \$DEBOUNCE_SECONDS ]; then
        echo "⏰ Debounce period passed, scanning..."
        do_scan
    else
        remaining=\$((\$DEBOUNCE_SECONDS - time_diff))
        echo "⏳ Waiting \$remaining seconds before next scan..."
    fi
done
EOL

# Make the monitor script executable
sudo chmod +x /usr/local/bin/lausch-laus-monitor

# Create systemd service for media monitor
echo "🔧 Creating systemd service for media monitor..."
sudo tee /etc/systemd/system/lausch-laus-monitor.service > /dev/null << EOL
[Unit]
Description=LauschLaus Media Monitor
After=mopidy.service

[Service]
ExecStart=/usr/local/bin/lausch-laus-monitor
Restart=on-failure
User=\$USER

[Install]
WantedBy=multi-user.target
EOL

# Enable and start services
echo "🚀 Starting services..."

# Check if we're running in Docker
if [ -f /.dockerenv ]; then
    echo "🐳 Running in Docker environment - skipping service management"
    echo "✨ Installation verification complete!"
else
    # Normal system installation
    sudo systemctl daemon-reload
    sudo systemctl enable mopidy
    sudo systemctl enable lausch-laus-frontend
    sudo systemctl enable filebrowser
    sudo systemctl enable lausch-laus-monitor
    sudo systemctl start mopidy
    sudo systemctl start lausch-laus-frontend
    sudo systemctl start filebrowser
    sudo systemctl start lausch-laus-monitor
fi

echo "✨ Installation complete!"
echo "🌐 You can access LauschLaus at http://localhost:3000"
echo "⚙️ Mopidy is running on port 6680"
echo "📂 File Browser is available at http://$(hostname -I | cut -d" " -f1):8080"
echo "💡 Your music directory is located at ~/Music/LauschLaus" 
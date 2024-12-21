#!/bin/bash

# Exit on error
set -e

# Clean up function
cleanup() {
    echo "🧹 Cleaning up..."
    docker-compose down --remove-orphans
    if [ "$1" = "full" ]; then
        echo "🗑️  Removing all containers and images..."
        docker-compose down --rmi all --volumes
    fi
}

# Set up trap for cleanup on script exit
trap 'cleanup' EXIT

# Clean up any previous containers and images
echo "🧹 Cleaning up previous installation..."
cleanup "full"

# Create Music directory if it doesn't exist
echo "📁 Creating Music directory..."
mkdir -p Music/LauschLaus

# Build and start the container
echo "🐳 Building and starting Docker container..."
docker-compose up -d --build

# Wait a moment for the container to start
echo "⏳ Waiting for container to start..."
sleep 10

# Check if container is running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Container failed to start. Checking logs..."
    docker-compose logs
    exit 1
fi

# Execute the installation script inside the container
echo "🚀 Running installation script..."
if ! docker-compose exec -T lausch-laus ./install.sh; then
    echo "❌ Installation script failed. Checking logs..."
    docker-compose logs
    exit 1
fi

echo "✨ Test environment is ready!"
echo "You can access the services at:"
echo "- Frontend: http://localhost:3000"
echo "- Mopidy: http://localhost:6680"
echo "- File Browser: http://localhost:8080"
echo ""
echo "📝 Useful commands:"
echo "- View logs: docker-compose logs -f"
echo "- Stop services: docker-compose down"
echo "- Shell access: docker-compose exec lausch-laus bash"
echo "- Clean up everything: docker-compose down --rmi all --volumes" 
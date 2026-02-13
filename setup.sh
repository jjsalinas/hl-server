#!/bin/bash

echo "Half-Life Crossfire Server - Setup Script"
echo "=========================================="
echo ""

# Check if running in the correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found!"
    echo "Please run this script from the directory containing all server files."
    exit 1
fi

# Check if all required files exist
required_files=("Dockerfile" "docker-compose.yml" "server.cfg" "mapcycle.txt" "motd.txt" "start-server.sh" "roundstart.cfg")
missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "❌ Missing required files:"
    printf '%s\n' "${missing_files[@]}"
    exit 1
fi

echo "✅ All required files found"
echo ""

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✅ Created .env file - please edit it with your settings"
    echo ""
fi

# Make start-server.sh executable
chmod +x start-server.sh

echo "Setup complete! You can now:"
echo ""
echo "1. Edit .env file with your server settings:"
echo "   nano .env"
echo ""
echo "2. Build and start the server:"
echo "   docker-compose up -d"
echo ""
echo "3. View logs:"
echo "   docker-compose logs -f"
echo ""

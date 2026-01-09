#!/bin/bash
# GodotMark - Raspberry Pi 5 Deployment Script

set -e

# Configuration
RPI_HOST="${RPI_HOST:-pi@raspberrypi5}"
RPI_PATH="${RPI_PATH:-/home/pi/godotmark}"
LOCAL_PATH="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "GodotMark - RPi5 Deployment"
echo "========================================"
echo ""
echo "Target: $RPI_HOST"
echo "Remote Path: $RPI_PATH"
echo "Local Path: $LOCAL_PATH"
echo ""

# Check if library exists
if [ ! -f "$LOCAL_PATH/bin/libgodotmark.linux.template_release.arm64.so" ]; then
    echo "❌ Error: ARM64 release library not found!"
    echo "Please build first:"
    echo "  scons platform=linux arch=arm64 target=template_release cpu=rpi5 optimize_size=yes"
    exit 1
fi

echo "✅ ARM64 library found"
echo ""

# Test SSH connection
echo "🔍 Testing SSH connection..."
if ! ssh -o ConnectTimeout=5 "$RPI_HOST" "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "❌ Error: Cannot connect to $RPI_HOST"
    echo "Please check:"
    echo "  - RPi5 is powered on and connected to network"
    echo "  - SSH is enabled on RPi5"
    echo "  - RPI_HOST environment variable is correct"
    echo ""
    echo "Set host: export RPI_HOST=pi@your-rpi-hostname"
    exit 1
fi
echo "✅ SSH connection successful"
echo ""

# Create remote directory
echo "📁 Creating remote directory..."
ssh "$RPI_HOST" "mkdir -p $RPI_PATH/{bin,scenes,scripts,addons}"
echo "✅ Directory created"
echo ""

# Copy library
echo "📦 Deploying ARM64 library..."
scp "$LOCAL_PATH/bin/libgodotmark.linux.template_release.arm64.so" \
    "$RPI_HOST:$RPI_PATH/bin/"
echo "✅ Library deployed"
echo ""

# Copy project files (exclude Windows binaries and build artifacts)
echo "📦 Deploying project files..."
rsync -av --progress \
    --exclude='bin/*.dll' \
    --exclude='bin/*.exp' \
    --exclude='bin/*.lib' \
    --exclude='.godot/' \
    --exclude='.git/' \
    --exclude='*.o' \
    --exclude='*.obj' \
    --exclude='godot-cpp/' \
    --exclude='art/models/' \
    --exclude='art/textures/' \
    --exclude='art/hdri/' \
    "$LOCAL_PATH/" \
    "$RPI_HOST:$RPI_PATH/"
echo "✅ Project files deployed"
echo ""

# Verify deployment
echo "🔍 Verifying deployment..."
REMOTE_SIZE=$(ssh "$RPI_HOST" "du -sh $RPI_PATH/bin/libgodotmark.linux.template_release.arm64.so" | cut -f1)
echo "  Library size: $REMOTE_SIZE"

# Check for Godot on RPi5
echo ""
echo "🔍 Checking for Godot on RPi5..."
if ssh "$RPI_HOST" "command -v godot > /dev/null 2>&1"; then
    GODOT_VERSION=$(ssh "$RPI_HOST" "godot --version 2>&1 | head -n1")
    echo "✅ Godot found: $GODOT_VERSION"
else
    echo "⚠️  Godot not found in PATH"
    echo ""
    echo "To install Godot on RPi5:"
    echo "  wget https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.arm64.zip"
    echo "  unzip Godot_v4.4-stable_linux.arm64.zip"
    echo "  sudo mv Godot_v4.4-stable_linux.arm64 /usr/local/bin/godot"
    echo "  sudo chmod +x /usr/local/bin/godot"
fi

echo ""
echo "========================================"
echo "✅ Deployment Complete!"
echo "========================================"
echo ""
echo "To run on RPi5:"
echo "  ssh $RPI_HOST"
echo "  cd $RPI_PATH"
echo "  godot --headless --path . --script scripts/main.gd"
echo ""
echo "Or with display:"
echo "  ssh -X $RPI_HOST"
echo "  cd $RPI_PATH"
echo "  godot --path ."
echo ""
echo "To monitor performance:"
echo "  ssh $RPI_HOST 'vcgencmd measure_temp'"
echo "  ssh $RPI_HOST 'vcgencmd get_throttled'"
echo ""


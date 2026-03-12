#!/bin/bash
# Native build script for Raspberry Pi 5
# Run this directly on your RPi5
#
# Usage:
#   ./build_native_rpi5.sh [target] [cpu] [optimize_size]
#
# Examples:
#   ./build_native_rpi5.sh                          # Release build for RPi5
#   ./build_native_rpi5.sh template_debug           # Debug build
#   ./build_native_rpi5.sh template_release rpi4    # Build for RPi4
#   ./build_native_rpi5.sh template_release rpi5 no # No size optimization
#   ./build_native_rpi5.sh clean                    # Clean build artifacts
#
# This script will:
# 1. Check dependencies (scons, g++, python3)
# 2. Initialize godot-cpp submodule
# 3. Build godot-cpp library (10-15 minutes first time)
# 4. Build GodotMark extension (2-3 minutes)

set -e  # Exit on error

echo "=========================================="
echo "GodotMark - Native RPi5 Build Script"
echo "=========================================="

# Check if we're on ARM64
if [ "$(uname -m)" != "aarch64" ]; then
    echo "❌ ERROR: This script must run on ARM64 Linux (RPi5)"
    echo "   Current architecture: $(uname -m)"
    exit 1
fi

echo "✅ Architecture: $(uname -m)"
echo "✅ OS: $(uname -s)"

# Check dependencies
echo ""
echo "Checking dependencies..."

if ! command -v scons &> /dev/null; then
    echo "❌ SCons not found. Installing..."
    sudo apt update
    sudo apt install -y scons
fi

if ! command -v g++ &> /dev/null; then
    echo "❌ g++ not found. Installing..."
    sudo apt update
    sudo apt install -y build-essential
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

echo "✅ All dependencies installed"

# Check godot-cpp submodule
echo ""
echo "Checking godot-cpp..."
if [ ! -d "godot-cpp/.git" ]; then
    echo "📦 Initializing godot-cpp submodule..."
    git submodule update --init --recursive
else
    echo "✅ godot-cpp already initialized"
fi

# Build godot-cpp first (CRITICAL - must be built before extension)
echo ""
echo "=========================================="
echo "Step 1: Building godot-cpp"
echo "=========================================="
if [ ! -f "godot-cpp/bin/libgodot-cpp.linux.template_release.arm64.a" ] || [ "$BUILD_TARGET" = "template_release" ]; then
    echo "🔨 Building godot-cpp (this may take 10-15 minutes)..."
    cd godot-cpp
    scons platform=linux \
          arch=arm64 \
          target=template_release \
          -j$(nproc) \
          2>&1 | tee ../godot-cpp-build.log
    BUILD_RESULT=$?
    cd ..
    
    if [ $BUILD_RESULT -ne 0 ]; then
        echo "❌ ERROR: godot-cpp build failed!"
        echo "   Check godot-cpp-build.log for details"
        exit 1
    fi
    echo "✅ godot-cpp built successfully"
else
    echo "✅ godot-cpp already built (skipping)"
fi

if [ ! -f "godot-cpp/bin/libgodot-cpp.linux.template_debug.arm64.a" ] && [ "$BUILD_TARGET" = "template_debug" ]; then
    echo "🔨 Building godot-cpp debug..."
    cd godot-cpp
    scons platform=linux \
          arch=arm64 \
          target=template_debug \
          -j$(nproc) \
          2>&1 | tee ../godot-cpp-debug-build.log
    BUILD_RESULT=$?
    cd ..
    
    if [ $BUILD_RESULT -ne 0 ]; then
        echo "❌ ERROR: godot-cpp debug build failed!"
        echo "   Check godot-cpp-debug-build.log for details"
        exit 1
    fi
    echo "✅ godot-cpp debug built successfully"
fi

# Verify godot-cpp library exists
GODOT_CPP_LIB="godot-cpp/bin/libgodot-cpp.linux.$BUILD_TARGET.arm64.a"
if [ ! -f "$GODOT_CPP_LIB" ]; then
    echo "❌ ERROR: godot-cpp library not found!"
    echo "   Expected: $GODOT_CPP_LIB"
    exit 1
fi
echo "✅ godot-cpp library verified: $GODOT_CPP_LIB"

# Build configuration
BUILD_TARGET="${1:-template_release}"  # Default: release
CPU_TARGET="${2:-rpi5}"                # Default: rpi5
OPTIMIZE_SIZE="${3:-yes}"              # Default: yes (for undervolted)

echo ""
echo "=========================================="
echo "Build Configuration:"
echo "=========================================="
echo "Platform:        linux"
echo "Architecture:    arm64 (native)"
echo "Target:          $BUILD_TARGET"
echo "CPU Optimization: $CPU_TARGET"
echo "Size Optimization: $OPTIMIZE_SIZE"
echo "=========================================="
echo ""

# Clean previous build (optional)
if [ "$BUILD_TARGET" = "clean" ]; then
    echo "🧹 Cleaning build artifacts..."
    scons -c
    rm -rf bin/*.so
    echo "✅ Clean complete"
    exit 0
fi

# Build
echo ""
echo "=========================================="
echo "Step 2: Building GodotMark Extension"
echo "=========================================="
echo ""

START_TIME=$(date +%s)

scons platform=linux \
      arch=arm64 \
      target=$BUILD_TARGET \
      cpu=$CPU_TARGET \
      optimize_size=$OPTIMIZE_SIZE \
      -j$(nproc) \
      2>&1 | tee build.log

END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo "Build time: ${BUILD_TIME}s"
echo ""

# Verify output
if [ "$BUILD_TARGET" = "template_release" ]; then
    EXPECTED_LIB="bin/libgodotmark.linux.template_release.arm64.so"
elif [ "$BUILD_TARGET" = "template_debug" ]; then
    EXPECTED_LIB="bin/libgodotmark.linux.template_debug.arm64.so"
fi

if [ -f "$EXPECTED_LIB" ]; then
    echo "✅ Library built successfully:"
    ls -lh "$EXPECTED_LIB"
    echo ""
    echo "File type:"
    file "$EXPECTED_LIB"
    echo ""
    echo "Size: $(du -h "$EXPECTED_LIB" | cut -f1)"
    echo ""
    echo "=========================================="
    echo "✅ Ready to run!"
    echo "=========================================="
    echo ""
    echo "Run the benchmark:"
    echo "  ./Godot_v4.4-stable_linux.arm64 --path /mnt/exfat_drive/dev/godotmark-project/godotmark"
    echo ""
    echo "Or with verbose logging:"
    echo "  ./Godot_v4.4-stable_linux.arm64 --path /mnt/exfat_drive/dev/godotmark-project/godotmark --verbose"
    echo ""
else
    echo "❌ ERROR: Build failed!"
    echo "   Expected: $EXPECTED_LIB"
    echo "   Check build.log for errors"
    exit 1
fi


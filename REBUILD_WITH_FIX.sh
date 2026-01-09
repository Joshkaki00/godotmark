#!/bin/bash
# Rebuild GodotMark with Adaptive Quality Fix

cd /mnt/exfat_drive/dev/godotmark-project/godotmark

echo "==============================================="
echo "Rebuilding GodotMark with Adaptive Quality Fix"
echo "==============================================="
echo ""
echo "Changes:"
echo "  • Lowered UPGRADE_FPS: 40 → 33 (works at 36 FPS!)"
echo "  • Lowered MIN_FPS: 20 → 25"
echo "  • Changed from frame-based to time-based hysteresis"
echo "  • Now framerate-independent!"
echo ""
echo "==============================================="

# Clean previous build
echo "🧹 Cleaning previous build..."
scons -c
rm -f bin/libgodotmark.linux.template_release.arm64.so

echo ""
echo "🔨 Building with optimizations..."
echo ""

# Rebuild
scons platform=linux arch=arm64 target=template_release cpu=rpi5 -j4

if [ $? -eq 0 ]; then
    echo ""
    echo "==============================================="
    echo "✅ Build successful!"
    echo "==============================================="
    echo ""
    echo "Library created:"
    ls -lh bin/libgodotmark.linux.template_release.arm64.so
    echo ""
    echo "==============================================="
    echo "🚀 Run with:"
    echo "==============================================="
    echo ""
    echo "  cd /mnt/exfat_drive/dev/godotmark-project"
    echo "  ./Godot_v4.4-stable_linux.arm64 --path godotmark"
    echo ""
    echo "Then press 'V' to enable verbose logging and watch:"
    echo "  - Quality should upgrade from Medium → High → Ultra"
    echo "  - Each upgrade after ~3 seconds at 36 FPS"
    echo ""
else
    echo ""
    echo "❌ Build failed! Check errors above."
    exit 1
fi


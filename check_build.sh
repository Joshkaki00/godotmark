#!/bin/bash
# Quick build verification script for RPi5

echo "=========================================="
echo "GodotMark Build Verification"
echo "=========================================="
echo ""

# Check architecture
echo "System Architecture:"
uname -m
echo ""

# Check for ARM64 release library
RELEASE_LIB="bin/libgodotmark.linux.template_release.arm64.so"
DEBUG_LIB="bin/libgodotmark.linux.template_debug.arm64.so"

if [ -f "$RELEASE_LIB" ]; then
    echo "✅ Release library found:"
    ls -lh "$RELEASE_LIB"
    echo ""
    echo "File type:"
    file "$RELEASE_LIB"
    echo ""
    echo "Size: $(du -h "$RELEASE_LIB" | cut -f1)"
    echo ""
    echo "Dependencies:"
    ldd "$RELEASE_LIB" 2>&1 | head -n 10
    echo ""
    echo "✅ Ready to run!"
    echo ""
    echo "Run benchmark:"
    echo "  cd /mnt/exfat_drive/dev/godotmark-project"
    echo "  ./Godot_v4.4-stable_linux.arm64 --path godotmark"
else
    echo "❌ Release library NOT found: $RELEASE_LIB"
    echo ""
    echo "Build it with:"
    echo "  ./build_native_rpi5.sh template_release rpi5 yes"
fi

echo ""

if [ -f "$DEBUG_LIB" ]; then
    echo "✅ Debug library found:"
    ls -lh "$DEBUG_LIB"
else
    echo "ℹ️  Debug library not built (optional)"
    echo "   Build it with: ./build_native_rpi5.sh template_debug rpi5 no"
fi

echo ""
echo "=========================================="


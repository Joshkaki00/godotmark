#!/bin/bash

echo "==============================================="
echo "GodotMark Library Diagnostic"
echo "==============================================="
echo ""

cd /mnt/exfat_drive/dev/godotmark-project/godotmark

echo "1. Checking bin directory contents:"
echo "-----------------------------------"
ls -lh bin/ 2>&1 || echo "❌ bin/ directory not found!"
echo ""

echo "2. Looking for .so files:"
echo "-------------------------"
find bin/ -name "*.so" -ls 2>&1 || echo "❌ No .so files found"
echo ""

echo "3. Checking what godotmark.gdextension expects:"
echo "------------------------------------------------"
grep "linux.release.arm64" godotmark.gdextension
echo ""

echo "4. Checking if expected file exists:"
echo "-------------------------------------"
EXPECTED="bin/libgodotmark.linux.template_release.arm64.so"
if [ -f "$EXPECTED" ]; then
    echo "✅ File exists: $EXPECTED"
    ls -lh "$EXPECTED"
    file "$EXPECTED"
else
    echo "❌ File NOT found: $EXPECTED"
fi
echo ""

echo "5. Checking build.log for success/failure:"
echo "-------------------------------------------"
if [ -f "build.log" ]; then
    if grep -q "scons: done building targets" build.log; then
        echo "✅ Build log says: SUCCESS"
    else
        echo "❌ Build did not complete successfully"
    fi
    
    echo ""
    echo "Last error in build log (if any):"
    grep -i "error:" build.log | tail -5
else
    echo "❌ build.log not found"
fi
echo ""

echo "6. Checking for build artifacts in src/:"
echo "-----------------------------------------"
find src/ -name "*.o" -o -name "*.so" 2>&1 | head -5 || echo "None found"
echo ""

echo "==============================================="
echo "Recommendation:"
echo "==============================================="
if [ ! -f "$EXPECTED" ]; then
    echo "The library was NOT created despite build.log"
    echo "showing success. This usually means:"
    echo ""
    echo "1. Build script continued after error"
    echo "2. Library was created in wrong location"
    echo "3. Filesystem/permissions issue"
    echo ""
    echo "Try rebuilding with verbose output:"
    echo "  ./build_native_rpi5.sh template_release rpi5 yes 2>&1 | tee build_verbose.log"
fi
echo ""


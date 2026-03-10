#!/bin/bash
# GodotMark Clean Build Script (Bash)
# Removes all build artifacts and compiled binaries

set -e

echo "========================================================================"
echo "GodotMark Clean Build"
echo "========================================================================"
echo ""

# Function to remove directory
clean_dir() {
    local path=$1
    local desc=$2
    
    if [ -d "$path" ]; then
        echo "Removing $desc: $path"
        rm -rf "$path"
        echo "  ✓ Removed"
    else
        echo "Skipping $desc (not found): $path"
    fi
}

# Function to remove files
clean_files() {
    local pattern=$1
    local desc=$2
    
    echo "Cleaning $desc: $pattern"
    find . -type f -name "$pattern" -delete 2>/dev/null || true
    echo "  ✓ Done"
}

# Clean godot-cpp build artifacts
echo ""
echo "[1/5] Cleaning godot-cpp build artifacts..."
clean_dir "godot-cpp/.scons_cache" "SCons cache"
clean_dir "godot-cpp/gen" "Generated bindings"
clean_files "*.so" "Linux shared libraries (in godot-cpp/bin)"
clean_files "*.dll" "Windows DLLs (in godot-cpp/bin)"
clean_files "*.dylib" "macOS dylibs (in godot-cpp/bin)"
clean_files "*.a" "Static libraries (in godot-cpp/bin)"
find godot-cpp -type f \( -name "*.o" -o -name "*.os" \) -delete 2>/dev/null || true

# Clean GodotMark build artifacts
echo ""
echo "[2/5] Cleaning GodotMark build artifacts..."
clean_dir ".scons_cache" "SCons cache"
clean_dir "bin" "Binaries"
find src -type f \( -name "*.o" -o -name "*.os" \) -delete 2>/dev/null || true

# Clean Godot import cache
echo ""
echo "[3/5] Cleaning Godot import cache..."
clean_dir ".godot" "Godot import cache"

# Clean SCons database
echo ""
echo "[4/5] Cleaning SCons database..."
rm -f .sconsign.dblite godot-cpp/.sconsign.dblite
echo "  ✓ Done"

# User data info
echo ""
echo "[5/5] User data (kept by default):"
echo "  user:// directory contains benchmark results and settings"
echo "  To clean manually:"
echo "    rm -rf ~/.local/share/godot/app_userdata/godotmark/"

echo ""
echo "========================================================================"
echo "Clean complete!"
echo "========================================================================"
echo ""
echo "To rebuild:"
echo "  scons platform=linux target=template_release cpu=rpi5"
echo ""

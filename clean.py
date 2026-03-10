#!/usr/bin/env python3
"""
GodotMark Clean Build Script
Removes all build artifacts and compiled binaries
"""

import os
import shutil
import glob

def clean_directory(path, description):
    """Remove a directory and all its contents"""
    if os.path.exists(path):
        print(f"Removing {description}: {path}")
        try:
            shutil.rmtree(path)
            print(f"  ✓ Removed")
        except Exception as e:
            print(f"  ✗ Failed: {e}")
    else:
        print(f"Skipping {description} (not found): {path}")

def clean_files(pattern, description):
    """Remove files matching a glob pattern"""
    files = glob.glob(pattern, recursive=True)
    if files:
        print(f"Removing {description} ({len(files)} files):")
        for file in files:
            try:
                os.remove(file)
                print(f"  ✓ {file}")
            except Exception as e:
                print(f"  ✗ Failed to remove {file}: {e}")
    else:
        print(f"No {description} found")

def main():
    print("=" * 80)
    print("GodotMark Clean Build")
    print("=" * 80)
    print()
    
    # Get current directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Clean godot-cpp build artifacts
    print("\n[1/5] Cleaning godot-cpp build artifacts...")
    clean_directory("godot-cpp/.scons_cache", "SCons cache")
    clean_directory("godot-cpp/gen", "Generated bindings")
    clean_files("godot-cpp/bin/**/*.so", "Linux shared libraries")
    clean_files("godot-cpp/bin/**/*.dll", "Windows DLLs")
    clean_files("godot-cpp/bin/**/*.dylib", "macOS dylibs")
    clean_files("godot-cpp/bin/**/*.a", "Static libraries")
    clean_files("godot-cpp/**/*.o", "Object files")
    clean_files("godot-cpp/**/*.os", "Shared object files")
    
    # Clean GodotMark build artifacts
    print("\n[2/5] Cleaning GodotMark build artifacts...")
    clean_directory(".scons_cache", "SCons cache")
    clean_directory("bin", "Binaries")
    clean_files("src/**/*.o", "Object files")
    clean_files("src/**/*.os", "Shared object files")
    
    # Clean Godot import cache
    print("\n[3/5] Cleaning Godot import cache...")
    clean_directory(".godot", "Godot import cache")
    
    # Clean SCons database
    print("\n[4/5] Cleaning SCons database...")
    clean_files(".sconsign.dblite", "SCons database")
    clean_files("godot-cpp/.sconsign.dblite", "godot-cpp SCons database")
    
    # Clean user data (optional - keeping by default)
    print("\n[5/5] User data (kept by default):")
    print("  user:// directory contains benchmark results and settings")
    print("  To clean manually: rm -rf ~/.local/share/godot/app_userdata/godotmark/")
    
    print()
    print("=" * 80)
    print("Clean complete!")
    print("=" * 80)
    print()
    print("To rebuild:")
    print("  scons platform=linux target=template_release cpu=rpi5")
    print()

if __name__ == "__main__":
    main()

# Clean Build Guide

This guide explains how to perform clean builds of GodotMark.

---

## Quick Start

```bash
# Python (cross-platform, recommended)
python clean.py

# Bash (Linux/Mac)
./clean.sh

# PowerShell (Windows)
./clean.ps1

# SCons clean (basic)
scons -c
```

---

## Clean Scripts

### clean.py (Recommended)

**Cross-platform Python script** with comprehensive cleaning.

**Usage:**
```bash
cd godotmark
python clean.py
# or
python3 clean.py
```

**What it cleans:**
- godot-cpp build artifacts (`.scons_cache`, `gen/`, `bin/`)
- GodotMark build artifacts (`.scons_cache`, `bin/`, object files)
- Godot import cache (`.godot/`)
- SCons database files (`.sconsign.dblite`)

### clean.sh (Linux/Mac)

**Bash script** for Unix-like systems.

**Usage:**
```bash
cd godotmark
chmod +x clean.sh
./clean.sh
```

### clean.ps1 (Windows)

**PowerShell script** for Windows.

**Usage:**
```powershell
cd godotmark
pwsh -ExecutionPolicy Bypass -File clean.ps1
```

### scons -c (Basic)

**Built-in SCons clean** (removes only build targets).

**Usage:**
```bash
scons -c
```

**Note:** This only removes compiled binaries, not intermediate files or caches.

---

## What Gets Cleaned

### ✓ Always Cleaned

| Path | Description |
|------|-------------|
| `godot-cpp/.scons_cache/` | godot-cpp SCons cache |
| `godot-cpp/gen/` | Generated binding code |
| `godot-cpp/bin/` | godot-cpp compiled libraries |
| `.scons_cache/` | GodotMark SCons cache |
| `bin/` | GodotMark compiled libraries |
| `src/**/*.o` | Object files |
| `src/**/*.os` | Shared object files |
| `.godot/` | Godot import cache |
| `.sconsign.dblite` | SCons database |

### ✗ Kept (Preserved)

| Path | Description | Manual Clean |
|------|-------------|--------------|
| `user://` | Benchmark results, settings | See [User Data](#user-data-cleaning) |
| Source files | `.cpp`, `.h`, `.gd` files | Never cleaned |
| Assets | Textures, models, audio | Never cleaned |
| Documentation | `.md` files | Never cleaned |

---

## User Data Cleaning

User data (benchmark results, settings) is stored in Godot's `user://` directory.

### Location by Platform

| Platform | Path |
|----------|------|
| **Linux** | `~/.local/share/godot/app_userdata/godotmark/` |
| **Windows** | `%APPDATA%\Godot\app_userdata\godotmark\` |
| **macOS** | `~/Library/Application Support/Godot/app_userdata/godotmark/` |

### Clean User Data

```bash
# Linux
rm -rf ~/.local/share/godot/app_userdata/godotmark/

# Windows (PowerShell)
Remove-Item -Path "$env:APPDATA\Godot\app_userdata\godotmark\" -Recurse -Force

# macOS
rm -rf ~/Library/Application\ Support/Godot/app_userdata/godotmark/
```

**Warning:** This deletes all benchmark results and user settings!

---

## Build Scenarios

### Scenario 1: Quick Rebuild

```bash
# Clean and rebuild
python clean.py
scons platform=linux target=template_release cpu=rpi5 -j4
```

**When to use:**
- After pulling new changes
- Build artifacts seem corrupt
- Switching between debug/release

### Scenario 2: Full Clean Build

```bash
# Clean everything including godot-cpp
cd godotmark
python clean.py

# Rebuild godot-cpp first
cd godot-cpp
scons platform=linux target=template_release custom_api_file=../gdextension/extension_api.json -j4
cd ..

# Build GodotMark
scons platform=linux target=template_release cpu=rpi5 -j4
```

**When to use:**
- godot-cpp updates
- Major build system changes
- Switching Godot versions

### Scenario 3: CI/CD Clean Build

```bash
# Automated clean build script
#!/bin/bash
set -e

cd godotmark
python clean.py

echo "Building godot-cpp..."
cd godot-cpp
scons platform=linux target=template_release -j$(nproc)
cd ..

echo "Building GodotMark..."
scons platform=linux target=template_release cpu=generic -j$(nproc)

echo "Build complete!"
```

### Scenario 4: Switch CPU Target

```bash
# Clean when switching CPU optimizations
python clean.py

# Build for different CPU
scons platform=linux target=template_release cpu=rpi4 -j4   # Was rpi5
```

**Why:** CPU-specific optimizations are baked into object files.

---

## Troubleshooting

### "Build files remain after clean"

**Problem:** `scons -c` doesn't clean everything.

**Solution:** Use `clean.py` instead:
```bash
python clean.py
```

### "Permission denied" on clean.sh

**Problem:** Script not executable.

**Solution:** Add execute permission:
```bash
chmod +x clean.sh
./clean.sh
```

### "SCons database locked"

**Problem:** Previous build process didn't exit cleanly.

**Solution:** 
```bash
rm -f .sconsign.dblite
python clean.py
```

### "bin/ directory not removed"

**Problem:** Files in use or permission issue.

**Solution:**
```bash
# Linux: Check for running processes
lsof | grep godotmark
kill <pid>

# Then clean
python clean.py
```

### "Clean script not found"

**Problem:** Running from wrong directory.

**Solution:**
```bash
cd godotmark  # Project root
ls clean.py  # Should exist
python clean.py
```

---

## Advanced Usage

### Clean Specific Components

```python
# Python script: clean_godot_cpp_only.py
import shutil
import os

if os.path.exists("godot-cpp/bin"):
    shutil.rmtree("godot-cpp/bin")
    print("Cleaned godot-cpp binaries")
```

### Verify Clean State

```bash
# Check if clean was successful
echo "Checking clean state..."

# Should be empty
find godot-cpp/bin -type f 2>/dev/null || echo "✓ godot-cpp/bin clean"
find bin -type f 2>/dev/null || echo "✓ bin/ clean"
find . -name "*.o" -o -name "*.os" 2>/dev/null || echo "✓ Object files clean"

echo "Clean verification complete"
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
# Auto-clean before commits (optional)

if [ -f "godotmark/clean.py" ]; then
    echo "Running clean build..."
    cd godotmark
    python clean.py
    scons platform=linux target=template_release -j4
fi
```

---

## Best Practices

### ✓ Do

- Run clean script before major rebuilds
- Clean when switching CPU targets
- Clean after godot-cpp updates
- Use `python clean.py` for thorough cleaning
- Backup user data before cleaning (if needed)

### ✗ Don't

- Don't manually delete files (use scripts)
- Don't clean during active builds
- Don't commit build artifacts (`.gitignore` handles this)
- Don't clean source files or assets

---

## Integration with IDEs

### VS Code

Add to `.vscode/tasks.json`:
```json
{
    "label": "Clean Build",
    "type": "shell",
    "command": "python",
    "args": ["clean.py"],
    "options": {
        "cwd": "${workspaceFolder}/godotmark"
    },
    "problemMatcher": []
}
```

### CLion

Add External Tool:
- Program: `python`
- Arguments: `clean.py`
- Working directory: `$ProjectFileDir$/godotmark`

---

## See Also

- [`BUILD_AND_RUN.md`](BUILD_AND_RUN.md) - Build instructions
- [`SConstruct`](SConstruct) - Build configuration
- [`.gitignore`](.gitignore) - Ignored files

---

**Last Updated:** February 8, 2026

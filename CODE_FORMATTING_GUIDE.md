# C++ Code Formatting Guide for GodotMark

## Overview

GodotMark uses **clang-format** with the **Google C++ Style Guide** for consistent code formatting across the project.

---

## What is clang-format?

`clang-format` is an industry-standard tool for automatically formatting C++ code according to predefined style guidelines. It ensures:
- Consistent indentation and spacing
- Proper brace placement
- Aligned operators and comments
- Organized includes
- Professional, readable code

---

## Style Guide: Google C++ Style

The project uses the **Google C++ Style Guide**, which includes:

### Key Features
- **Indentation:** 2 spaces (no tabs)
- **Column Limit:** 80 characters per line
- **Braces:** Opening brace on same line (Attach style)
- **Pointer Alignment:** `int* ptr` (left-aligned)
- **Include Sorting:** Automatically organized by category
- **Comments:** Aligned with 2 spaces before trailing comments
- **Functions:** Short functions allowed on single line

### Why Google Style?
- ✅ Industry standard used by major projects
- ✅ Clear, readable code structure
- ✅ Well-documented and widely adopted
- ✅ Optimized for collaboration
- ✅ Automatic include organization

---

## Installation

### Windows (PowerShell)

```powershell
# Install LLVM (includes clang-format)
winget install LLVM.LLVM

# Add to PATH (for current session)
$env:Path += ";C:\Program Files\LLVM\bin"

# Verify installation
clang-format --version
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install clang-format

# Verify installation
clang-format --version
```

### Raspberry Pi

```bash
sudo apt install clang-format

# Verify installation
clang-format --version
```

---

## Usage

### Format a Single File

```bash
# Preview changes (prints to stdout)
clang-format your_file.cpp

# Apply changes in-place
clang-format -i your_file.cpp
```

### Format Multiple Files

```bash
# Format all C++ files in current directory
clang-format -i src/**/*.cpp src/**/*.h

# Windows PowerShell
Get-ChildItem -Path "src" -Recurse -Include *.cpp,*.h | ForEach-Object { clang-format -i $_.FullName }
```

### Format All C++ Files in Project

```bash
# Linux/macOS
find src -name "*.cpp" -o -name "*.h" | xargs clang-format -i

# Windows PowerShell (from godotmark directory)
Get-ChildItem -Path "src" -Recurse -Include *.cpp,*.h | ForEach-Object { 
    $env:Path += ";C:\Program Files\LLVM\bin"
    clang-format -i $_.FullName 
}
```

---

## IDE Integration

### Visual Studio Code

1. Install the **C/C++ Extension Pack**
2. The `.clang-format` file will be auto-detected
3. Format on save:
   - Open Settings (Ctrl+,)
   - Search "format on save"
   - Enable "Format On Save"
4. Manual format: `Shift+Alt+F`

### Visual Studio

1. Tools → Options → Text Editor → C/C++ → Formatting
2. Enable "Automatically format on paste"
3. Set "Use clang-format only" to "Yes"
4. Manual format: `Ctrl+K, Ctrl+D`

### CLion

1. Settings → Editor → Code Style → C/C++
2. Set Scheme to "Project"
3. Enable ClangFormat
4. Manual format: `Ctrl+Alt+L`

---

## Configuration File

The `.clang-format` file in the project root defines all formatting rules. It was generated using:

```bash
clang-format -style=google -dump-config > .clang-format
```

### Key Settings

```yaml
Language: Cpp
IndentWidth: 2              # 2 spaces per indent level
ColumnLimit: 80             # Max 80 characters per line
BreakBeforeBraces: Attach   # Opening brace on same line
PointerAlignment: Left      # int* ptr (not int *ptr)
UseTab: Never               # Always use spaces
Standard: Auto              # Auto-detect C++ standard
```

---

## Before and After Examples

### Example 1: Indentation and Braces

**Before:**
```cpp
void PlatformDetector::initialize()
{
if(verbose_logging)
{
UtilityFunctions::print("[Verbose] Starting");
}
detect_platform( );
}
```

**After:**
```cpp
void PlatformDetector::initialize() {
  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] Starting");
  }
  detect_platform();
}
```

### Example 2: Long Lines and Operators

**Before:**
```cpp
String summary = "Very long string that exceeds the 80 character limit and should be broken up into multiple lines for better readability";
int result=value1+value2*value3-value4/value5;
```

**After:**
```cpp
String summary =
    "Very long string that exceeds the 80 character limit and "
    "should be broken up into multiple lines for better readability";
int result = value1 + value2 * value3 - value4 / value5;
```

### Example 3: Include Organization

**Before:**
```cpp
#include <godot_cpp/classes/os.hpp>
#include "platform_detector.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <fstream>
```

**After:**
```cpp
#include "platform_detector.h"

#include <fstream>

#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
```

---

## Best Practices

### 1. Format Before Committing
Always format your code before committing to Git:

```bash
# Format all changed files
git diff --name-only | grep -E '\.(cpp|h)$' | xargs clang-format -i
```

### 2. Check Formatting in CI/CD
Add a formatting check to your build process:

```bash
# Check if files are formatted (returns error if not)
clang-format --dry-run --Werror src/**/*.cpp src/**/*.h
```

### 3. Don't Mix Formatting Changes
When making code changes, format in a **separate commit**:

```bash
git add .
git commit -m "Format code with clang-format"
git add your_changes.cpp
git commit -m "Add new feature"
```

### 4. Disable Formatting for Specific Sections
If you need to preserve specific formatting:

```cpp
// clang-format off
int matrix[3][3] = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9}
};
// clang-format on
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Format single file | `clang-format -i file.cpp` |
| Check without modifying | `clang-format file.cpp` |
| Format all project files | `find src -name "*.cpp" -o -name "*.h" \| xargs clang-format -i` |
| Generate config file | `clang-format -style=google -dump-config > .clang-format` |
| View available styles | `clang-format -style=help` |

---

## Troubleshooting

### "clang-format: command not found"
- **Windows:** Add `C:\Program Files\LLVM\bin` to PATH
- **Linux/RPi:** Install with `sudo apt install clang-format`

### "Different clang-format versions give different results"
- Use clang-format 14+ for consistency
- Check version: `clang-format --version`
- Project uses version 21.1.8

### "Formatting breaks my code"
- clang-format only changes whitespace, not logic
- If code breaks, it likely had syntax errors
- Use `// clang-format off` to disable for specific sections

---

## Additional Resources

- **Google C++ Style Guide:** https://google.github.io/styleguide/cppguide.html
- **clang-format Documentation:** https://clang.llvm.org/docs/ClangFormat.html
- **Style Options Reference:** https://clang.llvm.org/docs/ClangFormatStyleOptions.html

---

## Summary

✅ **Installed:** clang-format (LLVM 21.1.8)  
✅ **Style:** Google C++ Style Guide  
✅ **Config:** `.clang-format` in project root  
✅ **Usage:** `clang-format -i src/**/*.cpp src/**/*.h`

**Keep the codebase clean, consistent, and professional!** 🎯


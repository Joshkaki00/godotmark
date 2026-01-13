# C++ Style Guide Setup for GodotMark

## Overview

This project uses **clang-format** with a custom LLVM-based style guide for consistent C++ code formatting.

---

## Installing clang-format

### Option 1: Visual Studio (Recommended for Windows)

If you have Visual Studio installed:

1. Open **Visual Studio Installer**
2. Click **Modify** on your VS installation
3. Go to **Individual components** tab
4. Search for "Clang"
5. Check **"C++ Clang tools for Windows"**
6. Click **Modify** to install

After installation, clang-format will be available at:
```
C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin\clang-format.exe
```

Add it to your PATH or use the full path.

### Option 2: Download LLVM Binary

1. Download LLVM from: https://github.com/llvm/llvm-project/releases
2. Look for `LLVM-<version>-win64.exe`
3. Run the installer
4. **Important:** Check "Add LLVM to system PATH" during installation
5. Restart PowerShell/terminal

### Option 3: Chocolatey (if available)

```powershell
choco install llvm -y
```

### Option 4: Scoop (alternative package manager)

```powershell
scoop install llvm
```

### Verify Installation

```powershell
clang-format --version
```

You should see output like: `clang-format version 17.0.0`

---

## Configuration

The project uses a `.clang-format` file in the `godotmark/` directory with these key settings:

- **Base Style:** LLVM (clean, modern, widely used)
- **Indent:** 4 spaces (no tabs)
- **Line Length:** 100 characters
- **Braces:** Attach style (K&R-like)
- **Pointer Alignment:** Left (`int* ptr` not `int *ptr`)
- **Standard:** C++17
- **Include Sorting:** Enabled (Godot headers → Project headers → STL)

---

## Usage

### Format a Single File

```powershell
clang-format -i godotmark/src/platform/platform_detector.cpp
```

The `-i` flag formats the file **in-place** (modifies the original).

### Format All C++ Files in Project

Use the provided PowerShell script:

```powershell
cd D:\dev\godotmark-project
.\godotmark\format_cpp.ps1
```

Or manually:

```powershell
Get-ChildItem -Path "godotmark\src" -Recurse -Include *.cpp,*.h | ForEach-Object {
    clang-format -i $_.FullName
    Write-Host "Formatted: $($_.Name)"
}
```

### Check Format Without Modifying (Dry Run)

```powershell
clang-format --dry-run --Werror godotmark/src/platform/platform_detector.cpp
```

This will show errors if the file doesn't match the style guide.

---

## IDE Integration

### Visual Studio Code

1. Install extension: **C/C++** (by Microsoft)
2. Add to `.vscode/settings.json`:

```json
{
    "editor.formatOnSave": true,
    "C_Cpp.clang_format_style": "file",
    "C_Cpp.clang_format_fallbackStyle": "LLVM"
}
```

### Visual Studio

1. Go to **Tools → Options → Text Editor → C/C++ → Code Style → Formatting**
2. Select **"Use ClangFormat"**
3. Set **"Style"** to **"File"**

Now pressing `Ctrl+K, Ctrl+D` will format the current document.

### CLion / JetBrains IDEs

1. Go to **Settings → Editor → Code Style → C/C++**
2. Click **"Set from..."** → **"Predefined Style"** → **"LLVM"**
3. Enable **"Enable ClangFormat"**

---

## Popular C++ Style Guides Comparison

| Style Guide | Description | Used By | Characteristics |
|------------|-------------|---------|----------------|
| **LLVM** | Clean, modern, compact | LLVM, Clang, many OSS projects | Attach braces, 2-space indent (we use 4) |
| **Google** | Strict, detailed rules | Google projects | 2-space indent, extensive rules |
| **Mozilla** | Balanced approach | Firefox, Mozilla projects | 2-space indent, compact |
| **Chromium** | Browser-specific | Chrome, Chromium | 2-space indent, Google-like |
| **WebKit** | Apple's style | WebKit, Safari | 4-space indent, K&R braces |
| **Microsoft** | Visual Studio default | Windows projects | Allman braces, 4-space indent |

**GodotMark uses:** LLVM-based with 4-space indent (matches Godot conventions)

---

## Why LLVM Style?

- ✅ **Modern C++ conventions** (C++11/17/20)
- ✅ **Compact and readable** (not overly verbose)
- ✅ **Widely adopted** in open-source projects
- ✅ **Good default rules** that work for most codebases
- ✅ **Compatible with Godot** C++ conventions

---

## Customization

To modify the style guide, edit `godotmark/.clang-format`.

Key settings you might want to adjust:

```yaml
# Change indent size
IndentWidth: 4  # Change to 2 for Google/Mozilla style

# Change line length
ColumnLimit: 100  # Common values: 80, 100, 120

# Change brace style
BreakBeforeBraces: Attach  # Options: Attach, Allman, GNU, Stroustrup

# Change pointer alignment
PointerAlignment: Left  # Options: Left, Right, Middle
```

After changing `.clang-format`, reformat all files to apply the new style.

---

## Git Integration

### Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(cpp|h)$'); do
    clang-format -i "$file"
    git add "$file"
done
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

This automatically formats changed C++ files before each commit.

---

## CI/CD Integration (Future)

For GitHub Actions, add this step:

```yaml
- name: Check C++ formatting
  run: |
    find godotmark/src -name '*.cpp' -o -name '*.h' | xargs clang-format --dry-run --Werror
```

This will fail CI if any files don't match the style guide.

---

## Quick Reference

```powershell
# Format single file
clang-format -i src/file.cpp

# Format all C++ files
Get-ChildItem -Recurse -Include *.cpp,*.h | ForEach-Object { clang-format -i $_.FullName }

# Check without modifying
clang-format --dry-run --Werror src/file.cpp

# Show diff (what would change)
clang-format src/file.cpp | diff - src/file.cpp
```

---

## Summary

1. ✅ **Install:** clang-format (via VS, LLVM, or package manager)
2. ✅ **Configure:** `.clang-format` file already created (LLVM-based)
3. ✅ **Format:** Use `format_cpp.ps1` script or manual commands
4. ✅ **IDE:** Enable clang-format in your editor for auto-formatting
5. ✅ **Consistency:** All new code should follow the style guide

---

**Happy coding with consistent C++ style!** 🎨✨


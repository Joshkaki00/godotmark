# Large Assets Excluded from Repository

## 📦 What's Not Included

To keep the repository size manageable (~750 MB), the following large binary files from the nature benchmark are **excluded** via `.gitignore`:

### Excluded Files

| File | Size | Reason |
|------|------|--------|
| `art/nature-benchmark/*.bin` | Various | Too large for Git |

Specifically, these large files are not tracked:
- `pine_tree_01.bin` (~905 MB) - Too large
- `pine_sapling_medium.bin` (~251 MB) - Too large
- `fir_tree_01.bin` (~456 MB) - Large
- And ~84 other nature benchmark binary files

**Total excluded:** ~2.5 GB of binary mesh data

---

## ✅ What IS Included

The repository contains everything needed for the **Model Showcase**:
- ✅ C++ GDExtension source code
- ✅ GDScript controllers and UI
- ✅ All textures and materials (HDR, normal maps, etc.)
- ✅ Scene files and shaders
- ✅ Model showcase assets (marble bust with textures)
- ✅ Build scripts and documentation

---

## 🎮 What Works

### Without Excluded Files:
- ✅ **Model Showcase** - Full 1-minute marble bust benchmark
- ✅ **Core Framework** - Performance monitoring, adaptive quality
- ✅ **Platform Detection** - Hardware identification
- ✅ **Debug Controls** - All keyboard shortcuts
- ✅ **Results Export** - JSON output

### Requires Excluded Files:
- ❌ **Nature Benchmark** - Full vegetation stress test (if implemented)

---

## 📥 Getting the Excluded Files

If you need the nature benchmark binary files:

### Option 1: Download from Source
The assets are from **Poly Haven** (CC0 license):
- Visit: https://polyhaven.com/
- Search for the specific models
- Download as glTF 2.0 format
- Place `.bin` files in `art/nature-benchmark/`

### Option 2: Contact Project Owner
For the exact asset pack used in this project, contact the repository owner.

---

## 🔧 Technical Details

### Why Excluded?

1. **GitHub Limits** - Large files slow down Git operations
2. **Bandwidth** - Saves bandwidth for Raspberry Pi users
3. **Development** - Most development doesn't need 2.5 GB of assets
4. **Optional** - Nature benchmark is supplementary

### How Excluded?

The `.gitignore` file contains:
```gitignore
# Large glTF binary files (nature benchmark assets)
art/nature-benchmark/*.bin
```

This prevents these files from being tracked by Git.

---

## 📊 Repository Size

| Configuration | Size |
|---------------|------|
| **Current repository** | ~750 MB |
| **With excluded files** | ~3.2 GB |
| **Savings** | ~2.5 GB (78%) |

---

## 🚀 Quick Start

You can clone and use this repository immediately:

```bash
git clone https://github.com/Joshkaki00/godotmark.git
cd godotmark
./build_native_rpi5.sh template_release rpi5 yes
```

The model showcase will work out of the box!

---

**Note:** The `.bin` files are **not required** for the core benchmark functionality. The project is fully functional without them.


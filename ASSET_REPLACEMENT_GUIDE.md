# Low Poly Asset Replacement Guide

This guide explains how to replace the high-poly photogrammetry GLTF assets with optimized low-poly assets.

---

## Why Replace Assets?

The original assets are **photogrammetry scans** with:
- **500K-1M triangles per model** (way too high for ARM devices)
- **Unoptimized for real-time rendering**
- **Large file sizes** (18-35 MB per model)

Low-poly assets provide:
- **<500 triangles per model** (60× reduction)
- **Optimized for game engines**
- **Smaller file sizes** (<1 MB per model)
- **Better performance** on Raspberry Pi

---

## Automated Replacement

### Step 1: Run the Replacement Script

```powershell
cd godotmark
pwsh -ExecutionPolicy Bypass -File replace_assets.ps1
```

**What it does:**
1. Archives current assets to `art/nature-benchmark-archive-<timestamp>/`
2. Copies new low poly assets from `C:\Users\mehew\Downloads\low poly assets`
3. Preserves all import settings and textures
4. Shows summary and next steps

### Step 2: Clear Godot Import Cache

```powershell
Remove-Item .godot -Recurse -Force
```

Or manually delete the `.godot` folder in the godotmark directory.

### Step 3: Reopen Project in Godot

Godot will automatically import the new assets. This may take 2-5 minutes.

### Step 4: Optimize for Raspberry Pi

```powershell
.\optimize_for_raspberry_pi.ps1
```

This applies:
- VRAM texture compression
- Texture downscaling (1K → 512×512)
- Mipmap generation
- LOD generation

### Step 5: Test Benchmarks

```bash
# Run Nature Island benchmark
./godotmark --benchmark nature-island

# Check FPS and performance
```

---

## Manual Replacement

If you prefer manual control:

### 1. Archive Current Assets

```powershell
$archiveDir = "art/nature-benchmark-archive-$(Get-Date -Format 'yyyyMMdd')"
New-Item -ItemType Directory -Path $archiveDir
Move-Item art/nature-benchmark/* $archiveDir
```

### 2. Copy New Assets

```powershell
Copy-Item "C:\Users\mehew\Downloads\low poly assets\*" art/nature-benchmark -Recurse
```

### 3. Follow Steps 2-5 Above

---

## Asset Requirements

Low poly assets should follow this structure:

```
low poly assets/
├── tree_01/
│   ├── tree_01.gltf
│   ├── tree_01.bin
│   └── textures/
│       ├── tree_01_diffuse.jpg
│       └── tree_01_normal.jpg
├── rock_01/
│   ├── rock_01.gltf
│   ├── rock_01.bin
│   └── textures/
│       └── rock_01_diffuse.jpg
...
```

**Key requirements:**
- GLTF format (not GLB)
- Textures in separate folder
- Triangle count: <500 per model
- Texture resolution: 512×512 or 1024×1024

---

## Updating Script References

The benchmark script auto-detects GLTF files, but you may need to update asset categories in `scripts/nature_island.gd`:

### Current Asset Loading

```gdscript
var asset_paths = {
    "trees": [
        "res://art/nature-benchmark/island_tree_01_1k.gltf/island_tree_01_1k.gltf",
        "res://art/nature-benchmark/island_tree_02_1k.gltf/island_tree_02_1k.gltf",
        "res://art/nature-benchmark/island_tree_03_1k.gltf/island_tree_03_1k.gltf"
    ],
    "rocks": [
        # Now using procedural rocks (no GLTF needed)
    ],
    "vegetation": [
        "res://art/nature-benchmark/shrub_01_1k.gltf/shrub_01_1k.gltf",
        ...
    ]
}
```

### Auto-Detection Alternative

To make the script auto-detect assets by naming convention:

```gdscript
func scan_assets_directory() -> Dictionary:
    var dir = DirAccess.open("res://art/nature-benchmark")
    var assets = {
        "trees": [],
        "rocks": [],
        "vegetation": []
    }
    
    if dir:
        dir.list_dir_begin()
        var folder_name = dir.get_next()
        while folder_name != "":
            if dir.current_is_dir() and folder_name.ends_with(".gltf"):
                # Categorize by naming convention
                if "tree" in folder_name.to_lower():
                    assets["trees"].append("res://art/nature-benchmark/" + folder_name + "/" + folder_name)
                elif "rock" in folder_name.to_lower() or "stone" in folder_name.to_lower():
                    assets["rocks"].append("res://art/nature-benchmark/" + folder_name + "/" + folder_name)
                elif "shrub" in folder_name.to_lower() or "plant" in folder_name.to_lower():
                    assets["vegetation"].append("res://art/nature-benchmark/" + folder_name + "/" + folder_name)
            folder_name = dir.get_next()
    
    return assets
```

---

## Verification

### Check Asset Counts

```powershell
# Count new assets
(Get-ChildItem art/nature-benchmark -Directory).Count

# List asset names
Get-ChildItem art/nature-benchmark -Directory | Select-Object Name
```

### Check Triangle Counts

Use Godot's Scene > Import tab or check the mesh inspector after importing.

**Target counts:**
- Trees: 200-400 triangles
- Rocks: 50-100 triangles
- Vegetation: 50-150 triangles

---

## Rollback

If you need to restore the original assets:

```powershell
# Find your archive
Get-ChildItem art -Directory -Filter "nature-benchmark-archive-*"

# Restore (replace with your archive timestamp)
$archive = "art/nature-benchmark-archive-20260208_143022"
Remove-Item art/nature-benchmark/* -Recurse -Force
Move-Item "$archive/*" art/nature-benchmark -Force

# Clear import cache
Remove-Item .godot -Recurse -Force

# Reopen in Godot
```

---

## Expected Performance Improvements

### Before (High-Poly Photogrammetry)
- **Triangle count:** 5,000,000+ (6 rocks × 500K+ each)
- **VRAM:** 150+ MB
- **FPS:** 4.5 (Raspberry Pi 5)
- **Status:** ❌ Unusable

### After (Low-Poly Optimized)
- **Triangle count:** ~5,500 (60 FPS target budget)
- **VRAM:** 74 MB (with compression)
- **FPS:** 30-45 (Raspberry Pi 5)
- **Status:** ✅ Working

**Improvement:** ~10× better performance!

---

## Troubleshooting

### "Assets not appearing in Godot"
- Ensure `.godot` folder was deleted
- Reopen project to force reimport
- Check Godot console for import errors

### "Import errors for textures"
- Verify textures are in correct format (JPG/PNG)
- Check texture paths in GLTF files
- Ensure textures are in `textures/` subfolder

### "Models look different/wrong"
- Check materials are applied correctly
- Verify normal maps are loaded
- Ensure per-vertex lighting is enabled

### "FPS still low"
- Run `optimize_for_raspberry_pi.ps1` script
- Check triangle counts with Godot inspector
- Verify VRAM compression is applied
- Use `--verbose` flag to see debug info

---

## Asset Sources (Examples)

### Where to Find Low-Poly Assets

**Free Resources:**
- **Poly Pizza** - https://poly.pizza/ (CC0 license)
- **Quaternius** - https://quaternius.com/ (CC0 license)
- **Kenney** - https://kenney.nl/assets (CC0 license)
- **Blender Kit** - Free low-poly category
- **Sketchfab** - Filter by low-poly + free downloads

**Paid Resources:**
- **Synty Studios** - Low Poly Asset Packs
- **Kay Lousberg** - Low Poly Nature Pack
- **Unity Asset Store** - Low poly environment packs

**Create Your Own:**
- **Blender** - Model from scratch or decimate existing models
- **Decimate modifier** - Reduce triangle count of high-poly models

---

## See Also

- [`MYSTERY_SOLVED_ROCKS.md`](MYSTERY_SOLVED_ROCKS.md) - Why we replaced the rocks
- [`RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`](RASPBERRY_PI_4_MODEL_OPTIMIZATION.md) - Triangle budget analysis
- [`OPTIMIZATION_COMPLETE_GUIDE.md`](OPTIMIZATION_COMPLETE_GUIDE.md) - Full optimization guide

---

**Last Updated:** February 8, 2026  
**Script:** `replace_assets.ps1`  
**Archive Location:** `art/nature-benchmark-archive-<timestamp>/`

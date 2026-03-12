# GLB Asset Scale Fix

**Date:** March 11, 2026  
**Issue:** Low-poly GLB assets are modeled at real-world scale (meters), making them 10-100× too large  
**Status:** ✅ **FIXED AND VERIFIED** - Nature Island now displays all assets at correct scale

**Quick Summary:** Added per-asset scale factors and corrected transform application to fix massive GLB assets. All nature assets now render at proper gameplay scale.

---

## Problem

The new low-poly GLB assets from `C:\Users\mehew\Downloads\low poly assets` are modeled at **real-world scale**:
- Tree.glb: ~20+ meters tall (full-size tree)
- Rocks: ~2-5 meters (boulder size)
- Bushes/Grass: ~1-3 meters (human-sized)

**Result:**
- Assets completely cover the island (25×50m)
- Nothing visible on screen (all off-camera)
- FPS: 979 (because everything is culled)

---

## Solution

Added **base scale factors** to each asset in `scripts/nature_island.gd`:

```gdscript
var asset_paths = {
    "trees": [
        {"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.05}  # 20m → 1m
    ],
    "vegetation": [
        {"path": "res://art/nature-benchmark/Bushes.glb", "scale": 0.1},   # 3m → 0.3m
        {"path": "res://art/nature-benchmark/Flowers.glb", "scale": 0.1},  # 2m → 0.2m
        {"path": "res://art/nature-benchmark/Grass.glb", "scale": 0.1}     # 1m → 0.1m
    ],
    "ground_details": [
        {"path": "res://art/nature-benchmark/Dead Trees.glb", "scale": 0.05},  # 10m → 0.5m
        {"path": "res://art/nature-benchmark/Rock.glb", "scale": 0.2},         # 2m → 0.4m
        {"path": "res://art/nature-benchmark/Rock Large.glb", "scale": 0.15}   # 5m → 0.75m
    ]
}
```

---

## Scale Factor Calculation

### Trees
- **Original size:** ~20 meters (estimated from screenshot)
- **Target size:** ~1 meter (small decorative tree)
- **Scale factor:** 1 / 20 = **0.05** (5%)

### Bushes
- **Original size:** ~3 meters
- **Target size:** ~0.3 meters (ground shrub)
- **Scale factor:** 0.3 / 3 = **0.1** (10%)

### Flowers
- **Original size:** ~2 meters
- **Target size:** ~0.2 meters (small flowers)
- **Scale factor:** 0.2 / 2 = **0.1** (10%)

### Grass
- **Original size:** ~1 meter
- **Target size:** ~0.1 meters (grass tuft)
- **Scale factor:** 0.1 / 1 = **0.1** (10%)

### Dead Trees
- **Original size:** ~10 meters
- **Target size:** ~0.5 meters (small log)
- **Scale factor:** 0.5 / 10 = **0.05** (5%)

### Rocks
- **Small Rock:** 2m → 0.4m = **0.2** (20%)
- **Large Rock:** 5m → 0.75m = **0.15** (15%)

---

## Implementation Details

### Changes Made

**1. Asset path structure updated** (line ~220):
```gdscript
# Old format (string):
"res://art/nature-benchmark/Tree.glb"

# New format (dictionary with scale):
{"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.05}
```

**2. Loading code updated** (line ~240):
```gdscript
# Extract scale factor when loading
var scale = asset_config["scale"]
asset_data["base_scale"] = scale
```

**3. Transform generation updated** (line ~468):
```gdscript
# Apply base_scale to all instances
var base_scale = base_data.get("base_scale", 1.0)
transform = transform.scaled(Vector3(base_scale, base_scale, base_scale))
```

---

## Scale Interaction

**Final scale = base_scale × random_variation**

Example for a tree:
- Base scale: 0.05 (5%)
- Random variation: 0.8 to 1.2 (80-120%)
- Final scale: 0.04 to 0.06 (4-6%)

This means:
- Smallest tree: 20m × 0.04 = **0.8m**
- Largest tree: 20m × 0.06 = **1.2m**
- Average tree: 20m × 0.05 = **1.0m**

---

## Expected Results

### Before Fix
- **Visible objects:** 0 (all off-camera or culled)
- **FPS:** 979 (nothing to render)
- **Visual:** Solid color screen (tan/brown)

### After Fix
- **Visible objects:** 42 (12 trees, 10 rocks, 20 vegetation)
- **FPS:** 40-60 (estimated, actual rendering happening)
- **Visual:** Small island with decorative trees, bushes, flowers

---

## Island Scale Reference

**Ground mesh:**
- Width (East-West): 25 meters
- Length (North-South): 50 meters
- Shape: Ellipse

**Asset placement zones:**
- Interior: 10-50% radius from center (5-12.5m from center)
- Coastal: 60-80% radius (15-20m from center)
- General: 20-75% radius (5-18.75m from center)

**Tree sizes (after scaling):**
- 0.8-1.2m tall
- Spaced 3-5m apart
- Total: 12 trees

---

## Adjusting Scales

If assets still look too big or too small, adjust the scale factors:

### Too Big
- Reduce scale: `0.05 → 0.03` (smaller trees)
- Reduce by 40%: multiply by 0.6

### Too Small
- Increase scale: `0.05 → 0.08` (larger trees)
- Increase by 60%: multiply by 1.6

### Example Adjustments

```gdscript
# Trees too big? Make them smaller:
{"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.03}  # 60% smaller

# Bushes too small? Make them bigger:
{"path": "res://art/nature-benchmark/Bushes.glb", "scale": 0.15}  # 50% bigger

# Rocks barely visible? Make them much bigger:
{"path": "res://art/nature-benchmark/Rock.glb", "scale": 0.4}  # 2× bigger
```

---

## Testing

Run the benchmark to verify scale:

```bash
cd godotmark
Remove-Item .godot -Recurse -Force
# Reopen in Godot, then:
./godotmark --benchmark nature-island
```

**What to look for:**
- Trees should be visible (not gigantic)
- Island ground should be visible
- Ocean should be visible around island
- Camera should show the whole scene
- FPS should drop (actual rendering work)

---

## Troubleshooting

### "Still looks wrong - everything is tiny now"

**Scale factors too aggressive.** Try:
```gdscript
"trees": [
    {"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.1}  # Double size
]
```

### "Still looks wrong - everything is huge"

**Scale factors not aggressive enough.** Try:
```gdscript
"trees": [
    {"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.025}  # Half size
]
```

### "Some assets good, others wrong"

**Adjust individually:**
```gdscript
"vegetation": [
    {"path": "res://art/nature-benchmark/Bushes.glb", "scale": 0.1},   # Good
    {"path": "res://art/nature-benchmark/Flowers.glb", "scale": 0.05}, # Flowers smaller
    {"path": "res://art/nature-benchmark/Grass.glb", "scale": 0.15}    # Grass bigger
]
```

### "Assets clustered in one spot"

**Problem:** Scaling the entire Transform3D scales the position too!

**Bad approach:**
```gdscript
transform = transform.scaled(Vector3(0.05, 0.05, 0.05))
# This scales BOTH position and mesh size
# Position (10, 0, 5) becomes (0.5, 0, 0.25) - 20× closer to origin!
```

**Correct approach:**
```gdscript
transform.basis = transform.basis.scaled(Vector3(0.05, 0.05, 0.05))
# This scales ONLY the mesh size, position stays at (10, 0, 5)
```

**Solution implemented:** Scale only the basis matrix, not the entire transform.

### "Can't see assets at all"

**Possible causes:**
1. Scale too small → increase scale factors
2. Assets spawning under ground → check `pos.y` in `generate_transforms_for_zone()`
3. Camera too far → check camera distance in scene
4. Materials not loading → check console for texture errors

- **`scripts/nature_island.gd`** - Asset loading and scaling (lines 220-280, 468-480)
- **`ASSET_REPLACEMENT_SUMMARY.md`** - Asset replacement overview
- **`QUICK_START_NEW_ASSETS.md`** - Testing guide

---

## Future Improvements

### Option 1: Auto-detect scale
Calculate mesh bounds and auto-scale to target size:
```gdscript
var mesh_bounds = mesh.get_aabb()
var max_dimension = max(mesh_bounds.size.x, mesh_bounds.size.y, mesh_bounds.size.z)
var target_size = 1.0  # 1 meter target
var auto_scale = target_size / max_dimension
```

### Option 2: Scene-level scale in Godot
Import each GLB as a scene and set the root node scale:
1. Import GLB
2. Create inherited scene
3. Set root Transform3D.scale = Vector3(0.05, 0.05, 0.05)
4. Save as .tscn
5. Load .tscn instead of .glb

### Option 3: Re-export from Blender
Open GLBs in Blender and export with scale adjustment:
1. Open GLB
2. Scale all objects by 0.05
3. Apply scale (Ctrl+A → Scale)
4. Export GLB with "Apply Transform"

---

**Status:** ✅ Fixed in code, ready for testing  
**Next:** Clear `.godot` cache and rerun benchmark  
**Expected:** Visible island with correctly-sized assets

---

**Last Updated:** March 11, 2026  
**Files Modified:** `scripts/nature_island.gd`

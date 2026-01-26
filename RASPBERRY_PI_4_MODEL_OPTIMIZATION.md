# Raspberry Pi 4 Model Optimization Guide

## Research-Based Specifications

### Triangle Throughput (from testing):
- **At 720p with basic lighting:** 16 million triangles/second
- **19,000 triangle model:** ~12 copies @ 60 FPS
- **500 triangle model (optimal):** 132 models @ 60 FPS (4M tri/sec)
- **6,000 triangle model:** 130 FPS (but only 1 model)

### Optimal Model Complexity:
- **Low-poly models:** 500-1000 triangles per model
- **Total scene budget:** <10,000 triangles for 60 FPS
- **Per-vertex lighting:** Much better than per-pixel (already using ✅)

### Memory Constraints:
- **GPU memory:** 256-384 MB (via gpu_mem setting)
- **Texture budget:** Must fit in VRAM with compression
- **Max texture size:** 4096×4096 (but use 1024×1024 for RPi)

## Current Nature Benchmark Analysis

### Current Object Counts (Phase 5):
- 40 trees
- 25 rocks
- 65 vegetation
- 35 ground details
- **Total: 165 objects**

### Estimated Triangle Counts (1K PolyHaven models):
Based on typical PolyHaven photogrammetry assets at 1K resolution:

| Asset Type | Est. Triangles | Count | Total Triangles |
|------------|----------------|-------|-----------------|
| Trees (large) | 3,000-8,000 | 40 | ~200,000 |
| Rocks | 2,000-5,000 | 25 | ~75,000 |
| Vegetation | 1,000-3,000 | 65 | ~130,000 |
| Ground details | 500-2,000 | 35 | ~52,500 |
| Ocean plane | 32 (4×4×2) | 1 | 32 |
| Ground plane | 8 (1×1×2) | 1 | 8 |
| **TOTAL** | | **166** | **~457,540 triangles** |

**Problem:** This is **45× over budget!**

Target: <10,000 triangles @ 60 FPS  
Current: ~457,540 triangles  
**Need to reduce by 97.8%**

## Optimization Strategy

### Option 1: Reduce Object Counts (Extreme)
Keep current models, drastically reduce instances:

- 5 trees (500 tri each) = 2,500 tri
- 3 rocks (500 tri each) = 1,500 tri
- 10 vegetation (300 tri each) = 3,000 tri
- 10 ground details (200 tri each) = 2,000 tri
- **Total: 28 objects, ~9,000 triangles**

**Problem:** Scene looks empty and defeats benchmark purpose.

### Option 2: Use LOD Models (Recommended)
Create/use low-poly versions of models:

**Trees:**
- Current: 3,000-8,000 triangles
- Target: 200-500 triangles (stylized low-poly tree)
- Count: 20 trees × 350 tri = 7,000 tri

**Rocks:**
- Current: 2,000-5,000 triangles
- Target: 50-150 triangles (simple rock shapes)
- Count: 15 rocks × 100 tri = 1,500 tri

**Vegetation:**
- Current: 1,000-3,000 triangles
- Target: 20-100 triangles (crossed quads with alpha)
- Count: 30 vegetation × 50 tri = 1,500 tri

**Ground Details:**
- Current: 500-2,000 triangles
- Target: 10-50 triangles (simple debris)
- Count: 0 (remove to save budget)

**Total: 65 objects, ~10,000 triangles** ✅

### Option 3: Import Settings Optimization (Apply Immediately)
Use Godot's built-in mesh simplification on import:

**For existing GLTF models:**
1. Open Advanced Import Settings
2. Enable **Generate LODs**
3. Set aggressive LOD levels
4. Let Godot auto-simplify meshes

**Expected reduction:** 50-70% triangles with minimal visual impact

## Implementation Plan

### Phase 1: Import Settings (Quick Win)
Update GLTF import settings to enable mesh LOD:

```gdscript
# In nature_island.gd, during asset loading:
# Enable LOD generation on all GLTF imports
```

### Phase 2: Asset Selection (Medium Effort)
Choose lower-poly models from PolyHaven:
- Look for "low poly" or "game ready" variants
- Prefer 512×512 texture versions
- Target <1000 triangles per asset

### Phase 3: Custom LOD (Long Term)
Create simplified meshes manually:
- Use Blender's Decimate modifier
- Target 80-95% reduction
- Export as separate LOD meshes

## Adjusted Object Counts for RPi 4

Based on **500 triangle average** per model:

| Phase | Object Type | Count | Avg Tri/Model | Total Triangles | Cumulative |
|-------|-------------|-------|---------------|-----------------|------------|
| 1 | Trees | 10 | 400 | 4,000 | 4,000 |
| 2 | Rocks | 6 | 100 | 600 | 4,600 |
| 3 | Vegetation | 20 | 50 | 1,000 | 5,600 |
| 4 | Ground Details | 0 | - | 0 | 5,600 |
| 5 | Ocean Effects | - | - | 0 | 5,600 |

**Total: 36 objects, ~5,600 triangles** (well under 10K budget)

### Phase Progression:
- **Phase 1 (0-12s):** 10 trees = 4,000 tri → **Target: 60 FPS**
- **Phase 2 (12-24s):** +6 rocks = 4,600 tri → **Target: 55 FPS**
- **Phase 3 (24-36s):** +20 vegetation = 5,600 tri → **Target: 50 FPS**
- **Phase 4 (36-48s):** Tree wind shaders = 5,600 tri → **Target: 45 FPS**
- **Phase 5 (48-60s):** Ocean complexity = 5,600 tri → **Target: 40 FPS**

## Mesh Simplification Settings

### For GLTF Import:
```
Meshes > Generate LODs: Enabled
LODs > Normal Merge Angle: 60° (aggressive)
LODs > Quality: 0.5 (50% reduction)
```

### Script-Based LOD:
```gdscript
func simplify_mesh(mesh: ArrayMesh, target_ratio: float = 0.2) -> ArrayMesh:
    # Use Godot's mesh simplification
    # Target 20% of original triangles
    var simplified = mesh.create_simplified(target_ratio)
    return simplified
```

## Texture Optimization for RPi 4

With **256-384 MB GPU memory budget:**

### Current Texture Memory (with VRAM compression):
- 225 textures × 1.33 MiB = ~299 MB
- **Status:** Just within budget but tight

### Optimized Texture Memory:
**Downscale to 512×512:**
- 225 textures × 0.33 MiB = ~74 MB
- **Savings:** 225 MB freed for geometry

**Settings for 512×512:**
```
Process > Size Limit: 512
compress/mode: 2 (VRAM Compressed)
compress/high_quality: false
mipmaps/generate: true
```

## Expected Performance

### Before Optimization:
- **Triangle count:** ~457,540
- **Expected FPS:** <5 FPS (completely unplayable)
- **GPU:** Completely saturated

### After Optimization (Target):
- **Triangle count:** ~5,600 (98.7% reduction)
- **Expected FPS:** 45-60 FPS
- **GPU:** Reasonable utilization

### Performance Formula:
```
Max models @ 60 FPS = (10,000 triangles budget) / (avg triangles per model)

Current: 10,000 / 3,000 = 3 models (not viable)
Optimized: 10,000 / 150 = 66 models (viable!)
```

## Verification Checklist

After optimization:

- [ ] Total scene triangles < 10,000
- [ ] Individual models < 1,000 triangles (preferably <500)
- [ ] Texture memory < 200 MB (with compression)
- [ ] Per-vertex lighting enabled (no per-pixel)
- [ ] LOD generation enabled on all meshes
- [ ] No expensive post-processing (SSAO/Glow disabled)
- [ ] MultiMesh used for all instanced objects
- [ ] FPS target: 40-60 FPS on RPi 4

## Tools for Analysis

### Check Triangle Count in Godot:
```gdscript
func count_scene_triangles() -> int:
    var total = 0
    for node in get_tree().get_nodes_in_group("meshes"):
        if node is MeshInstance3D:
            var mesh = node.mesh
            if mesh:
                for i in range(mesh.get_surface_count()):
                    var arrays = mesh.surface_get_arrays(i)
                    if arrays and arrays[Mesh.ARRAY_INDEX]:
                        total += arrays[Mesh.ARRAY_INDEX].size() / 3
    return total
```

### Monitor Performance:
```gdscript
func _process(delta):
    var info = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
    print("Triangles this frame: ", info)
```

## Summary

✅ **Triangle budget identified:** <10,000 for 60 FPS  
✅ **Current overage:** 45× too many triangles  
✅ **Solution:** Reduce to 36 objects with <500 tri/model  
✅ **Expected result:** 5,600 triangles = 40-60 FPS  
✅ **Texture optimization:** Downscale to 512×512 = 225 MB saved  

The benchmark must use **low-poly models** (500 triangles or less) to run properly on Raspberry Pi 4! 🎯

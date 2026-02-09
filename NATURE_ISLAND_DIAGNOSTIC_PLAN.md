# Nature Island 4.5 FPS - Systematic Diagnostic Plan

## Ocean Shader Test: FAILED ❌

Replacing the ocean's custom shader with StandardMaterial3D **did not improve FPS**.

**Conclusion:** Ocean shader is NOT the bottleneck.

---

## New Investigation Strategy: Isolation Testing

We need to systematically isolate components to find the real bottleneck.

### Critical Discovery

**`wind_vegetation.gdshader` was completely empty (0 bytes)** when tested.

This could have caused:
- Pink "missing shader" error material
- Expensive fallback rendering
- Godot error handling overhead

**Status:** Shader has been restored. Re-test required.

---

## Three-Phase Test Plan

### PHASE 1: Test Base Scene Only ⭐ START HERE

**Run:**
```bash
cd godotmark
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island_minimal_test.tscn
```

**What it tests:**
- Ocean: 80×80m plane, 4×4 subdiv, StandardMaterial3D (25 vertices)
- Ground: 30×60m plane, 1×1 subdiv, StandardMaterial3D (4 vertices)
- Camera with cinematic path
- DirectionalLight3D
- ProceduralSkyMaterial
- **NO nature assets whatsoever**

**Expected results:**

| FPS Result | Conclusion | Next Action |
|------------|------------|-------------|
| **30+ FPS** ✅ | Base scene is fine | → Go to PHASE 2 |
| **4.5 FPS** ❌ | Base scene has problem | → Investigate camera/sky/ocean size |

**Duration:** 10 seconds (auto-exits)

---

### PHASE 2: Test Full Benchmark (With Restored Shader)

**Run:**
```bash
cd godotmark
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island.tscn
```

**What it tests:**
- Everything from PHASE 1
- **+ 36 nature assets** (10 trees, 6 rocks, 20 vegetation)
- **+ Wind shaders** (trees, vegetation)
- **+ Restored wind_vegetation.gdshader**

**Expected results:**

| FPS Result | Conclusion | Next Action |
|------------|------------|-------------|
| **30+ FPS** ✅ | Empty shader was the problem! | → VICTORY! Update docs |
| **4.5 FPS** ❌ | Nature assets or shaders are problem | → Go to PHASE 3 |

**Duration:** 60 seconds (full benchmark)

---

### PHASE 3: Test Without Wind Shaders

**Only run if PHASE 2 shows 4.5 FPS.**

**Modify:** `godotmark/scripts/nature_island.gd`

**Line 562-578** (transition_to_phase_3): Comment out wind shader application for vegetation
```gdscript
# Apply wind shader to vegetation
# var wind_shader = load("res://shaders/wind_vegetation.gdshader")
# if multimesh_groups.has("all_vegetation"):
#     var mmi = multimesh_groups["all_vegetation"]
#     var shader_mat = ShaderMaterial.new()
#     shader_mat.shader = wind_shader
#     ... (rest of shader setup)
#     mmi.material_override = shader_mat
#     print("[Phase 3] Applied wind animation to vegetation")
```

**Line 598-614** (transition_to_phase_4): Comment out wind shader application for trees
```gdscript
# Apply wind shader to trees
# var tree_wind_shader = load("res://shaders/wind_trees.gdshader")
# if multimesh_groups.has("all_trees"):
#     var mmi = multimesh_groups["all_trees"]
#     var shader_mat = ShaderMaterial.new()
#     shader_mat.shader = tree_wind_shader
#     ... (rest of shader setup)
#     mmi.material_override = shader_mat
#     print("[Phase 4] Applied wind animation to trees")
```

**Re-run:**
```bash
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island.tscn
```

**Expected results:**

| FPS Result | Conclusion | Root Cause |
|------------|------------|------------|
| **30+ FPS** ✅ | Wind shaders are the bottleneck | Vertex math too expensive |
| **4.5 FPS** ❌ | GLTF assets themselves are problem | Mesh complexity or texture loading |

---

## Possible Outcomes & Root Causes

### Outcome A: PHASE 1 shows 4.5 FPS
**Root cause:** Base scene rendering issue

**Suspects:**
- Ocean mesh too large (80×80m = huge screen coverage)
- Ground mesh has hidden complexity
- Camera far plane (100m) rendering too much
- ProceduralSkyMaterial expensive on VideoCore VII
- DirectionalLight shadow calculations (should be disabled though)

### Outcome B: PHASE 1 shows 30+ FPS, PHASE 2 shows 4.5 FPS
**Root cause:** Nature assets are the problem

**Suspects:**
- Empty `wind_vegetation.gdshader` caused fallback rendering
- Wind shaders too expensive (vertex math)
- GLTF meshes not simplified as expected
- Texture loading/caching issue
- MultiMesh instance overhead

### Outcome C: PHASE 2 shows 30+ FPS after shader restore
**Root cause:** Empty shader file

**Solution:** ✅ Already fixed by restoring `wind_vegetation.gdshader`

### Outcome D: PHASE 3 shows 30+ FPS (shaders disabled)
**Root cause:** Wind shaders too expensive

**Solution:** Simplify vertex shader math:
- Remove trigonometric functions
- Use pre-baked animation textures
- Reduce per-instance calculations

### Outcome E: All tests show 4.5 FPS
**Root cause:** Something fundamental we haven't considered

**Next steps:**
- Profile with Godot's built-in profiler
- Check RenderingServer statistics
- Compare against Model Showcase's rendering code
- Ask for expert help with full profiling data

---

## Comparison: Model Showcase vs Nature Island

### Model Showcase (80 FPS ✅)

```
Scene:
- 1 marble bust (static mesh, ~2K triangles)
- StandardMaterial3D (no custom shaders)
- Particle effects (Phase 5 only)
- Camera path
- Light

Rendering:
- Single draw call
- Per-vertex lighting
- No animation
- Simple PBR materials
```

### Nature Island (4.5 FPS ❌)

```
Scene:
- Ocean (80×80m plane, 25 vertices)
- Ground (30×60m plane, 4 vertices)
- 36 nature assets (~5,600 triangles total)
- Camera path
- Light

Rendering:
- 4 draw calls (MultiMesh batching)
- Per-vertex lighting
- Wind animation (vertex shaders)
- StandardMaterial3D (ocean, ground, rocks)
- ShaderMaterial (trees, vegetation with wind)
```

**Key difference:** Nature Island uses **vertex shader animation** on 30 instances.

---

## Expected Timeline

| Phase | Duration | Total Time |
|-------|----------|------------|
| PHASE 1 (Minimal test) | 10 seconds | 10s |
| PHASE 2 (Full benchmark) | 60 seconds | 70s |
| PHASE 3 (No wind shaders) | 60 seconds | 130s |

**Total testing time:** ~3 minutes

---

## Files Created for This Investigation

1. **`scenes/nature_island_minimal_test.tscn`** - Minimal test scene (base only, no assets)
2. **`scripts/nature_island_minimal_test.gd`** - Test script with 10-second timer
3. **`INVESTIGATION_OCEAN_SHADER_FAILED.md`** - Ocean shader test results
4. **`NATURE_ISLAND_DIAGNOSTIC_PLAN.md`** - This file (systematic test plan)

**Files Fixed:**
1. **`shaders/wind_vegetation.gdshader`** - Was empty, now restored

---

## Next Steps

1. ⭐ **RUN PHASE 1 TEST** - This is the most critical test
2. Report FPS result here
3. Follow decision tree based on result
4. Continue to PHASE 2 or PHASE 3 as needed

---

**Status:** Ready for systematic testing  
**Current Hypothesis:** Empty wind_vegetation.gdshader caused fallback rendering  
**Confidence:** 60% (moderate - needs testing to confirm)  
**Alternative Hypothesis:** Wind shaders' vertex math is too expensive  
**Confidence:** 30%

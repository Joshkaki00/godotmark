# Investigation: Nature Island 4.5 FPS - Ocean Shader Ruled Out

## Test Results

**Ocean shader test FAILED to improve FPS.**

- **Before:** 4.5 FPS with `ShaderMaterial` + `water_ocean.gdshader`
- **After:** 4.5 FPS with `StandardMaterial3D`
- **Conclusion:** Ocean shader is **NOT** the bottleneck

---

## What This Means

The ocean shader hypothesis was wrong. The bottleneck is elsewhere.

### Suspects Remaining

1. **GLTF Asset Loading/Rendering**
   - Maybe the GLTF meshes aren't simplified as expected
   - Possible hidden complexity in the imported assets
   
2. **Wind Shaders on MultiMesh Instances**
   - `wind_trees.gdshader` applied to 10 tree instances
   - `wind_vegetation.gdshader` applied to 20 vegetation instances (was EMPTY - just fixed)
   - Vertex shader math might still be expensive
   
3. **Ground Mesh Complexity**
   - 30×60 meter ground plane (only 1×1 subdivision though)
   - StandardMaterial3D with per-vertex lighting
   
4. **Camera Rendering Distance**
   - Far plane: 100m
   - Could be rendering too much geometry
   
5. **Hidden Rendering State**
   - Shadow casting enabled on objects?
   - Transparency/alpha testing?
   - Material complexity in imported GLTF assets?

---

## Next Investigation Steps

### Step 1: Test with ZERO MultiMesh Objects

Create a minimal test scene:
- Ocean (StandardMaterial3D) ← Already tested, not the problem
- Ground plane
- Camera
- Light
- **NO nature assets at all**

If FPS is still 4.5, the problem is in the base scene.  
If FPS jumps to 30+, the problem is in the nature assets.

### Step 2: Profile the Wind Shaders

Test wind shaders individually:
- Disable wind shaders (use StandardMaterial3D for all MultiMesh instances)
- Re-test FPS
- If FPS improves, wind shaders are the problem

### Step 3: Check GLTF Asset Complexity

Examine imported GLTF assets:
- Check actual triangle counts (might be higher than expected)
- Check if LODs were generated correctly
- Check if texture compression was applied

### Step 4: Rendering Statistics

Use `RenderingServer.get_rendering_info()` to check:
- Actual triangle count being rendered
- Draw calls
- Shader compilation time
- Texture memory usage

---

## Hypothesis: Wind Shaders on MultiMesh

**New prime suspect:** The wind shaders (`wind_trees.gdshader`, `wind_vegetation.gdshader`) might be more expensive than expected on VideoCore VII.

### Why This Could Be It

The wind shaders do **vertex-level math** with:
- Trigonometric functions (`sin`, `cos`) in vertex shader
- Per-instance calculations (30 instances total)
- Height-based displacement
- Time-based animation

**On mobile GPUs:**
- Vertex shaders are generally cheaper than fragment shaders
- BUT: If the meshes have high vertex counts, even vertex math adds up
- **Example:** If each tree has 1,000 vertices, and there are 10 trees...
  - That's 10,000 vertices × 2 trig functions per frame = 20,000 trig operations per frame
  - At 60 FPS target: 1.2 million trig operations per second

### Test This Hypothesis

Temporarily disable wind shaders by replacing them with simple StandardMaterial3D:

```gdscript
# In transition_to_phase_3() and transition_to_phase_4()
# Comment out the shader application code
# var shader_mat = ShaderMaterial.new()
# shader_mat.shader = wind_shader
# mmi.material_override = shader_mat

# Instead, just use the existing per-vertex lit material
# (Do nothing - material_lit is already applied)
```

---

## Critical Discovery: wind_vegetation.gdshader Was Empty

**BREAKING:** I just discovered that `wind_vegetation.gdshader` was completely empty (0 bytes).

This means:
- Phase 3 vegetation had **no shader at all** (defaulted to pink error material?)
- This could have caused rendering errors or fallback behavior
- Might explain the 4.5 FPS (error handling is expensive)

**I've restored the shader content.** Re-test to see if this fixes anything.

---

## Action Items

### TEST 1: Minimal Base Scene (CRITICAL - RUN THIS FIRST)
```bash
cd godotmark
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island_minimal_test.tscn
```

This tests **just** the base scene:
- Ocean (80×80m, StandardMaterial3D)
- Ground (30×60m, StandardMaterial3D)
- Camera
- Light
- **NO nature assets**

**Expected results:**
- **If 30+ FPS:** Base scene is fine, problem is in nature assets → Run TEST 2
- **If 4.5 FPS:** Problem is in base scene itself (ocean/ground/camera) → Investigate further

### TEST 2: Nature Island (Full Benchmark)
```bash
cd godotmark
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island.tscn
```

Re-test with restored `wind_vegetation.gdshader` to see if the empty shader was causing issues.

**Expected results:**
- **If 30+ FPS:** Empty wind shader was the problem! ✅
- **If 4.5 FPS:** Wind shaders or nature assets are the problem → Run TEST 3

### TEST 3: Disable Wind Shaders
If TEST 2 still shows 4.5 FPS, modify `nature_island.gd`:

Comment out shader application in `transition_to_phase_3()` and `transition_to_phase_4()`:

```gdscript
# Line 562-578: Comment out wind shader for vegetation
# var shader_mat = ShaderMaterial.new()
# shader_mat.shader = wind_shader
# ...

# Line 600-614: Comment out wind shader for trees
# var shader_mat = ShaderMaterial.new()
# shader_mat.shader = tree_wind_shader
# ...
```

Re-run and measure FPS. If it improves, wind shaders are the problem.

---

**Status:** Ocean shader hypothesis REJECTED. Minimal test scene created. Ready for systematic testing.

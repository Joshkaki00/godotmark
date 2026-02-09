# Ocean Shader Performance Test

## The 4.5 FPS Mystery - First Suspect

Based on expert analysis, we've identified the **ocean shader** as the most likely culprit for the Nature Island benchmark's abysmal 4.5 FPS on Raspberry Pi 5.

---

## What We Changed

### Before (Suspect Code)
The ocean was using `water_ocean.gdshader` with:
- **Fragment shader math** running for every pixel (thousands of calculations per frame)
- Expensive trigonometric operations: `fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453)`
- Per-pixel color mixing: `mix(water_color.rgb, deep_water_color.rgb, UV.y)`
- Conditional branching in both vertex and fragment shaders (`if (phase >= 4)`)

### After (Test Fix)
The ocean now uses a simple `StandardMaterial3D` with:
- **No fragment shader** - just Godot's built-in per-vertex lighting
- Static blue color: `Color(0.1, 0.3, 0.5, 0.9)`
- `shading_mode = 2` (per-vertex, same as all other materials)
- Same mesh size: 80×80 meters, 4×4 subdivision (25 vertices)

---

## Expected Results

### If the Ocean Shader Was the Culprit ✅
**FPS should jump from 4.5 to 30+ FPS** on Raspberry Pi 5.

This would confirm that the shader's per-pixel math was saturating the VideoCore VII GPU, and we need to:
1. **Drastically simplify** the ocean shader (remove foam noise, reduce color blending)
2. **Reduce ocean mesh size** from 80×80 to 40×40 meters
3. **Use vertex displacement only** (no fragment shader effects)

### If FPS Is Still ~4.5 FPS ❌
Then the bottleneck is elsewhere:
- **Possible suspects:**
  - GLTF asset loading/caching issue
  - MultiMesh instance count still too high
  - Texture compression not applied correctly
  - Driver overhead from too many material swaps
  - Hidden post-processing effects

---

## How to Test

### On Raspberry Pi 5
```bash
cd godotmark
./Godot_v4.4-stable_rpi.exe --path . res://scenes/nature_island.tscn
```

Watch the FPS counter. If it jumps to 30+ FPS in Phase 1, **we've found the culprit**.

### On PC (Validation)
```bash
cd godotmark
C:\Godot_v4.4-stable_win64.exe\Godot_v4.4-stable_win64.exe --path . res://scenes/nature_island.tscn
```

Should see 60 FPS (VSync limit). This confirms the ocean shader is lightweight enough.

---

## The "Silent Killer" Pattern

This is a **classic Raspberry Pi GPU bottleneck**:
- CPU usage: 1-4% (idle)
- GPU usage: Low (but **saturated per-pixel**)
- FPS: 4.5 (GPU stalled on fragment shader math)

The VideoCore VII GPU is a **mobile-class GPU** optimized for:
- **Vertex processing** (good at moving vertices)
- **Texture sampling** (good at reading textures)

But **terrible at**:
- **Per-pixel math** (trigonometric functions, noise, complex blending)
- **Conditional branching** in fragment shaders

---

## Next Steps

### If This Fixes It
1. Create a "Raspberry Pi Safe" ocean shader with:
   - Vertex displacement only (no fragment shader math)
   - Pre-baked foam texture (no procedural noise)
   - Simple UV scrolling
2. Update `COMPLETE_OPTIMIZATION_STORY.md` with this finding
3. Add a "Shader Performance Guidelines" section to `CONTRIBUTING.md`

### If This Doesn't Fix It
1. Run this test on PC to verify FPS is 60+
2. Profile the Nature Island benchmark on RPi with `--verbose` flag
3. Check `RenderingServer.get_rendering_info()` for draw calls, vertices, etc.
4. Post detailed profiling data to GitHub Issues asking for expert help

---

## Files Modified

1. `scenes/nature_island.tscn`:
   - Replaced `ShaderMaterial` with `StandardMaterial3D` for ocean
2. `scripts/nature_island.gd`:
   - Removed all `set_shader_parameter()` calls for ocean
   - Added logging to track shader state

---

## Theory: Why This Might Be It

Looking at the Model Showcase benchmark (which runs at **80 FPS**):
- It uses a **static marble bust** with no custom shaders
- All materials are `StandardMaterial3D` with per-vertex lighting
- No per-pixel effects at all

Meanwhile, Nature Island has:
- The **only custom fragment shader** in the entire benchmark suite
- Running on the **largest mesh** (80×80 meters = huge screen coverage)
- Per-pixel math **every single frame**

**This is the smoking gun.**

---

## Community Call-Out

If you're a **Godot shader expert** or have experience optimizing for **Raspberry Pi / mobile GPUs**, we need your help!

Even if this test fixes the FPS issue, we still need:
- A performant ocean shader that works on mobile-class GPUs
- Guidelines for shader complexity budgets on RPi 4/5
- Profiling tools to catch these issues earlier

**See:** `COMPLETE_OPTIMIZATION_STORY.md` for the full context of this 4.5 FPS mystery.

---

## Test Results

### Raspberry Pi 5 (8GB)
- **Before:** 4.5 FPS with `water_ocean.gdshader`
- **After:** ??? FPS with `StandardMaterial3D` *(awaiting test results)*

### Desktop PC
- **Before:** Unknown (likely 60 FPS, shader was cheap on desktop GPU)
- **After:** ??? FPS with `StandardMaterial3D` *(awaiting test results)*

---

**Last Updated:** February 8, 2026  
**Test Status:** READY FOR DEPLOYMENT  
**Next Action:** Run benchmark on RPi 5 and report FPS

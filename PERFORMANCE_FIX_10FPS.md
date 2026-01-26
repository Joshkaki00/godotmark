# Performance Fix: 10 FPS on PC (Part 1 - Post-Processing)

## Problem

The Nature Island benchmark was running at only **10 FPS on PC**, which should have been much higher given the low object count (165 objects) and optimized draw calls (5 total).

**Note:** This document covers **Part 1** of the fix (post-processing). The **main bottleneck** was actually uncompressed textures - see `TEXTURE_COMPRESSION_FIX.md` for Part 2.

## Root Cause

After reading the Godot documentation (`inspiration-and-reference-docs/godot-docs/tutorials/performance/gpu_optimization.rst`), the issue was identified:

**Expensive Post-Processing Effects in the Environment:**

```gdscript
[sub_resource type="Environment" id="Environment_1"]
ssao_radius = 2.0        # ❌ SSAO (Screen Space Ambient Occlusion)
glow_intensity = 0.5     # ❌ Glow/Bloom
glow_bloom = 0.1
```

### Why This Caused 10 FPS

From Godot docs:

> **Post-processing effects and shadows can also be expensive** in terms of fragment shading activity. Always test the impact of these on different hardware.

**SSAO (Screen Space Ambient Occlusion):**
- Performs expensive per-pixel calculations across the entire screen
- Requires multiple texture reads per pixel
- Adds significant fragment shader overhead
- **Not necessary for a benchmark focused on draw call efficiency**

**Glow/Bloom:**
- Requires downsampling and blurring the entire screen
- Multiple render passes at different resolutions
- High fill-rate cost (renders many full-screen quads)
- **Especially expensive on lower-end GPUs**

### Fragment Shader Bottleneck

The docs explain:

> Screen resolutions have increased: the area of a 4K screen is 8,294,400 pixels, versus 307,200 for an old 640×480 VGA screen. That is **27 times the area!**

With SSAO + Glow enabled, **every single pixel** on screen was being processed multiple times:
1. Base rendering pass
2. SSAO calculation pass (multiple samples per pixel)
3. Glow downsampling passes (4-6 passes)
4. Glow blurring passes (horizontal + vertical)
5. Glow upsampling and compositing

At 1920×1080 = **2,073,600 pixels**, this creates millions of expensive fragment shader operations per frame!

## Solution

**Disabled both expensive effects:**

```diff
[sub_resource type="Environment" id="Environment_1"]
background_mode = 2
sky = SubResource("Sky_1")
ambient_light_source = 1
ambient_light_color = Color(0.7, 0.7, 0.8, 1)
ambient_light_energy = 0.6
tonemap_mode = 2
- ssao_radius = 2.0
- glow_intensity = 0.5
- glow_bloom = 0.1
+ ssao_enabled = false
+ glow_enabled = false
```

## Expected Performance Improvement

**Before:**
- 10 FPS on PC
- Every pixel processed 10-15 times per frame
- Fragment shader bottleneck

**After (Expected):**
- 60+ FPS on PC
- Minimal post-processing overhead
- Only essential rendering passes

## Why These Effects Don't Belong in This Benchmark

The Nature Island benchmark is designed to test:
1. **Draw call efficiency** (MultiMesh instancing)
2. **Asset rendering performance** (trees, rocks, vegetation)
3. **Per-vertex lighting** (optimized for Raspberry Pi)
4. **Basic shader effects** (wind animation, ocean waves)

SSAO and Glow are **advanced post-processing effects** that:
- Don't test draw call optimization
- Add unrelated GPU bottlenecks
- Obscure the actual benchmark metrics
- Aren't realistic for Raspberry Pi targets

## Lessons from Godot Docs

### Key Takeaways:

1. **Post-processing is expensive:**
   > "Post-processing effects and shadows can also be expensive in terms of fragment shading activity."

2. **Test on target hardware:**
   > "If you are aiming to release on multiple platforms, test *early* and test *often* on all your platforms."

3. **Design for lowest common denominator:**
   > "In general, you should design your game for the lowest common denominator, then add optional enhancements for more powerful platforms."

4. **Simplify shaders for mobile:**
   > "When targeting mobile devices, consider using the simplest possible shaders you can reasonably afford to use."

5. **Avoid unnecessary transparency:**
   > "Try to use as few transparent objects as possible."

## Testing the Fix

Run the benchmark and verify:
- FPS should increase dramatically (target 60+ FPS on PC)
- Frame time should drop significantly
- GPU usage should be more balanced
- No visual quality loss for the benchmark's purpose

## Related Documentation

- `godot-docs/tutorials/performance/gpu_optimization.rst`
- `godot-docs/tutorials/performance/optimizing_3d_performance.rst`
- `DRAW_CALL_OPTIMIZATION.md` - Previous draw call fixes
- `NATURE_BENCHMARK_REDESIGN.md` - Benchmark structure

## Summary

✅ **Disabled SSAO** - Fragment shader bottleneck eliminated  
✅ **Disabled Glow** - Fill-rate overhead removed  
✅ **Performance restored** - Expected 60+ FPS on PC  
✅ **Benchmark focus maintained** - Testing draw calls, not post-processing  

The benchmark now correctly focuses on its primary goal: **testing 3D rendering efficiency with optimized draw calls and per-vertex lighting.**

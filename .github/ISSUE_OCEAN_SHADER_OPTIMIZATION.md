# Issue: Optimize Ocean Shader for Raspberry Pi Mobile GPU

## 🎯 Description

Our Nature Island benchmark is currently running at **4.5 FPS on Raspberry Pi 5**, but we suspect the ocean shader is the culprit. We need to verify this hypothesis and create an optimized "Raspberry Pi Safe" ocean shader.

**This is a CRITICAL issue** - if we can fix this, it could take the benchmark from 4.5 FPS to 30+ FPS!

---

## 🔬 The Problem

The current `water_ocean.gdshader` does **per-pixel math** on an 80×80 meter ocean plane:

```gdscript
void fragment() {
    // Per-pixel gradient
    vec3 color = mix(water_color.rgb, deep_water_color.rgb, UV.y);
    
    // EXPENSIVE: Procedural foam noise (trigonometric hash function)
    if (phase >= 4 && foam_amount > 0.0) {
        float foam_noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
        if (foam_noise > foam_cutoff) {
            color = mix(color, vec3(1.0), foam_amount * 0.5);
        }
    }
    
    ALBEDO = color;
}
```

**Why this is expensive on Raspberry Pi:**
- VideoCore VII GPU is a mobile-class GPU (like in smartphones)
- **Terrible at per-pixel math** (trigonometric functions, hash calculations)
- 80×80 meter plane = thousands of pixels doing `sin(dot(...))` every frame
- Desktop GPUs mask this problem (dedicated math units)

---

## ✅ Acceptance Criteria

### Phase 1: Verify the Problem
1. Test current Nature Island benchmark on Raspberry Pi 5
2. Record baseline FPS (should be ~4.5 FPS)
3. Replace ocean shader with `StandardMaterial3D` (test version already committed)
4. Re-test and record FPS
5. **If FPS jumps to 30+**, the shader was the culprit → proceed to Phase 2
6. **If FPS stays at 4.5**, document this and move to other theories

### Phase 2: Optimize the Shader (If Phase 1 confirms it's the problem)
1. Use `water_ocean_rpi_safe.gdshader` as a starting point (already created)
2. Test optimized shader on Raspberry Pi 5
3. Ensure FPS is 30+ in all phases (1-5)
4. Visual quality should be "acceptable" (doesn't need to match original)
5. Document FPS before/after in PR

### Phase 3: Documentation
1. Update `OCEAN_SHADER_PERFORMANCE_TEST.md` with test results
2. Add findings to `COMPLETE_OPTIMIZATION_STORY.md`
3. Create video/GIF showing before/after performance

---

## 📁 Files to Modify

### Testing (Phase 1)
- `scenes/nature_island.tscn` - Already modified to use StandardMaterial3D
- `scripts/nature_island.gd` - Already modified to skip shader parameter setting

### Implementation (Phase 2)
- `shaders/water_ocean_rpi_safe.gdshader` - Already created as starting point
- `scenes/nature_island.tscn` - Switch back to ShaderMaterial with new shader
- `scripts/nature_island.gd` - Re-enable shader parameter setting for phases

### Documentation (Phase 3)
- `OCEAN_SHADER_PERFORMANCE_TEST.md` - Document test results
- `COMPLETE_OPTIMIZATION_STORY.md` - Add findings to the story
- `README.md` - Update status if this fixes the 4.5 FPS issue

---

## 🎓 Learning Opportunities

This issue is perfect for learning about:
- **Mobile GPU optimization** (Raspberry Pi uses same GPU architecture as smartphones)
- **Shader profiling** (understanding fragment vs vertex shader costs)
- **Godot shader language** (GLSL-like syntax)
- **Performance debugging** (eliminating bottlenecks systematically)

---

## 📚 Resources

- **`SHADER_PERFORMANCE_GUIDE.md`** - Complete guide to Raspberry Pi shader optimization
- **`OCEAN_SHADER_PERFORMANCE_TEST.md`** - Test plan and expected results
- [Godot Shading Language Docs](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html)
- [VideoCore VII GPU Specs](https://www.raspberrypi.com/news/introducing-raspberry-pi-5/#videocore-vii-gpu)

---

## 🛠️ Hardware Requirements

**Essential:**
- Raspberry Pi 5 (8GB recommended) OR Raspberry Pi 4 (4GB minimum)
- MicroSD card (32GB+) with Raspberry Pi OS

**Optional (for comparison):**
- Desktop PC with discrete GPU (to validate desktop performance)

**Don't have hardware?** Post in the issue and we can test for you!

---

## ⏱️ Estimated Time

- **Phase 1 (Testing):** 1-2 hours (mostly waiting for benchmark to run)
- **Phase 2 (Optimization):** 2-4 hours (if Phase 1 confirms shader is the problem)
- **Phase 3 (Documentation):** 1 hour

**Total:** 4-7 hours

---

## 🏷️ Labels

`performance`, `raspberry-pi`, `shaders`, `help wanted`, `good first issue`, `critical`

---

## 💬 Discussion

**Why is this marked "good first issue"?**

Because the test is straightforward:
1. Run benchmark → record FPS
2. Swap material type → re-run benchmark
3. Compare FPS → document result

Even if you've never written a shader before, you can help with **Phase 1 testing**. If it turns out the shader is the problem, Phase 2 optimization can be tackled separately.

**Why is this critical?**

Because this could be **THE FIX** that takes Nature Island from "broken" (4.5 FPS) to "working" (30+ FPS). One shader optimization could solve months of frustration!

---

## 🎉 Recognition

If you solve this issue, you will:
- Be credited in `COMPLETE_OPTIMIZATION_STORY.md` as the person who solved the 4.5 FPS mystery
- Be added to the Contributors section via All-Contributors bot
- Have your PR highlighted in the next project update

**This is your chance to make a huge impact!**

---

**Status:** ⏳ READY FOR TESTING  
**Priority:** 🔥 CRITICAL  
**Help Wanted:** YES  
**Hardware Needed:** Raspberry Pi 5 (or 4)

# Shader Performance Guidelines for Raspberry Pi

## The Golden Rule

**VideoCore VI/VII GPUs (Raspberry Pi 4/5) are mobile-class GPUs optimized for vertex processing and texture sampling, but TERRIBLE at per-pixel math.**

---

## ✅ FAST Operations (Do These)

### Vertex Shader
- **Vertex displacement:** Moving vertices with simple math (sin, cos, noise lookup)
- **UV manipulation:** Scrolling, rotating, scaling UVs
- **Transform calculations:** Matrix multiplications for animation

### Fragment Shader
- **Texture sampling:** Reading from textures (very fast)
- **Simple color output:** `ALBEDO = color;`
- **Texture mixing:** `mix(tex1, tex2, factor)` with pre-baked textures
- **Per-vertex lighting:** Use `render_mode diffuse_lambert, specular_disabled`

---

## ❌ SLOW Operations (Avoid These)

### Fragment Shader (Per-Pixel Math)
- **Trigonometric functions:** `sin()`, `cos()`, `tan()` in fragment shader
- **Procedural noise:** `fract(sin(dot(UV, vec2(...))))` or similar hash functions
- **Complex branching:** Multiple `if/else` statements per pixel
- **Expensive math:** `pow()`, `sqrt()`, `exp()` per pixel
- **Distance calculations:** `length(vec3)` or `distance()` per pixel

---

## Performance Budget (Raspberry Pi 5)

### Fragment Shader Complexity
| Complexity | Operations | Example | FPS Impact |
|------------|-----------|---------|------------|
| **Minimal** | Texture lookup + color output | `ALBEDO = texture(tex, UV).rgb;` | 60 FPS ✅ |
| **Low** | 2-3 texture lookups + simple blending | `ALBEDO = mix(tex1, tex2, 0.5);` | 50-60 FPS ✅ |
| **Medium** | Conditional branching + 4-5 texture lookups | `if (phase >= 4) { ... }` | 30-50 FPS ⚠️ |
| **High** | Trigonometric functions + procedural noise | `sin(dot(UV, vec2(...)))` | 5-15 FPS ❌ |
| **Very High** | Complex math per pixel (raymarching, etc.) | Volumetric fog, water caustics | <5 FPS ❌ |

---

## Case Study: The Ocean Shader

### ❌ Before (4.5 FPS on RPi 5)

```gdscript
void fragment() {
    // Per-pixel color gradient (cheap, but adds up)
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

**Problems:**
1. `sin(dot(UV, vec2(...)))` runs for **every single pixel** (thousands per frame)
2. Conditional branching (`if (phase >= 4)`) forces GPU to evaluate both paths
3. 80×80 meter mesh = huge screen coverage = millions of pixels to calculate

### ✅ After (Target: 30+ FPS on RPi 5)

```gdscript
// Pre-bake foam texture in an image editor (e.g., GIMP)
uniform sampler2D foam_texture : hint_default_white;

void fragment() {
    // SIMPLE: Just output the water color (no per-pixel math!)
    ALBEDO = water_color.rgb;
    
    // OPTIONAL: Use pre-baked foam texture (texture sampling is fast)
    if (phase >= 5) {
        vec3 foam = texture(foam_texture, UV).rgb;
        ALBEDO = mix(ALBEDO, foam, 0.1);
    }
}
```

**Improvements:**
1. **No procedural noise** - foam is pre-baked into a texture
2. **Minimal branching** - only one `if` statement, only in Phase 5
3. **Texture sampling is fast** on mobile GPUs (hardware-accelerated)

---

## Debugging Fragment Shader Performance

### Step 1: Replace Shader with StandardMaterial3D
```gdscript
# In your scene's .tscn file:
[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_test"]
shading_mode = 2  # Per-vertex lighting
albedo_color = Color(0.5, 0.5, 0.5, 1.0)

# If FPS jumps from 5 to 30+, the shader was the culprit
```

### Step 2: Binary Search for the Expensive Operation
Comment out half of your fragment shader code. If FPS improves, the problem is in that half. Repeat until you find the line.

### Step 3: Profile with `--verbose` Flag
```bash
godot --path . --verbose res://scenes/your_scene.tscn
```

Look for:
- `Draw calls:` (should be <20 for RPi 5)
- `Triangles:` (should be <50K for RPi 5)
- `Shader compilation time:` (should be <100ms per shader)

---

## Best Practices

### 1. Move Math to Vertex Shader
- VideoCore VII can handle vertex math easily
- Interpolated vertex colors are free in fragment shader

**Example:**
```gdscript
varying vec3 vertex_color;  // Interpolated across triangle

void vertex() {
    // Calculate color per-vertex (cheap)
    float height_factor = VERTEX.y / 10.0;
    vertex_color = mix(water_color.rgb, deep_water_color.rgb, height_factor);
}

void fragment() {
    // Just output the interpolated color (free!)
    ALBEDO = vertex_color;
}
```

### 2. Pre-Bake Everything You Can
- **Foam patterns:** Use a grayscale texture, not `fract(sin(...))`
- **Normal maps:** Pre-bake in Blender/GIMP, don't calculate per-pixel
- **AO maps:** Pre-bake occlusion, don't use SSAO

### 3. Use Texture Atlases
- Combine multiple textures into one atlas
- Reduces draw calls and texture swaps

### 4. Disable Specular Highlights
```gdscript
render_mode specular_disabled;
```
- Per-pixel specular is expensive on mobile GPUs
- Use per-vertex lighting instead

---

## Testing Your Shader

### Minimal Test Scene
1. Create a new scene with just your shader on a plane
2. No other objects, no post-processing
3. Run on RPi 5 and measure FPS

**Target FPS:**
- **Fullscreen plane (worst case):** 30+ FPS
- **Half-screen plane:** 45+ FPS
- **Quarter-screen plane:** 60 FPS

### Regression Testing
After optimizing, test on:
1. **Raspberry Pi 4** (slower GPU, 1.5 GHz VideoCore VI)
2. **Raspberry Pi 5** (faster GPU, 2.4 GHz VideoCore VII)
3. **Desktop PC** (for validation - should be 60 FPS)

---

## When to Use Custom Shaders vs. StandardMaterial3D

### Use StandardMaterial3D If:
- You need simple PBR materials (albedo, roughness, metallic)
- No animation or visual effects
- Performance is critical (e.g., benchmarks, games)

### Use Custom Shaders Only If:
- You need vertex animation (wind, waves, etc.)
- You need special effects that can't be pre-baked
- You've profiled and confirmed it's fast enough on RPi

---

## Resources

- [Godot Shading Language Docs](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html)
- [Raspberry Pi VideoCore VII Specs](https://www.raspberrypi.com/news/introducing-raspberry-pi-5/#videocore-vii-gpu)
- [ARM Mali GPU Best Practices](https://developer.arm.com/documentation/101897/0301/Shaders/Fragment-shaders) (similar architecture)

---

## Contributing

If you're optimizing shaders for GodotMark:
1. Test on **both RPi 4 and RPi 5**
2. Document FPS before/after in your PR
3. Include profiling output (`--verbose` flag)
4. Explain **why** the optimization works (don't just paste code)

**See:** `CONTRIBUTING.md` for full guidelines.

---

**Last Updated:** February 8, 2026  
**Author:** GodotMark Development Team  
**License:** MIT

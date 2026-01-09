# GodotMark Shader Reference Guide

**Source:** GDQuest Godot Shaders (MIT License)  
**Location:** `res://shaders/gdquest/`  
**Assets:** `res://addons/gdquest-shaders/`

---

## Benchmark Scene Usage Plan

### Scene 1: GPU Basics
**Shaders:** Basic PBR materials (Godot built-in)
- No custom shaders
- Focus: Geometry rendering, lighting, shadows

### Scene 2: Physics Test
**Shaders:** Simple unlit materials
- `unlit_directional_tint.gdshader` - Optional for visual variety
- Focus: Physics simulation, not shader complexity

### Scene 3: Shader Challenge (20 Materials)
**Primary Benchmark Shaders:**

1. **Dissolve Effect** - `dissolve.gdshader`
   - Complexity: Medium
   - Features: Animated dissolve with edge glow
   - Assets: `addons/gdquest-shaders/dissolve/noise_tex.tres`

2. **Water Surface** - `water_3d.gdshader`
   - Complexity: High
   - Features: Animated waves, reflections, foam
   - Assets: `addons/gdquest-shaders/water3d/` (diffuse, normal, specular)

3. **Stylized Fire** - `stylized_fire.gdshader`
   - Complexity: High
   - Features: Animated flames, gradient-based
   - Assets: `addons/gdquest-shaders/fire/` (gradients, noise, masks)

4. **Force Field** - `force_field.gdshader`
   - Complexity: Medium
   - Features: Hexagonal grid, Fresnel effect
   - Assets: `addons/gdquest-shaders/forcefield/hexagon_grid.png`

5. **Crystal/Hologram** - `fresnel_crystal.gdshader`
   - Complexity: Medium
   - Features: Fresnel-based transparency, rim lighting

6. **3D Outline** - `outline3D_smooth_normals_color.gdshader`
   - Complexity: Medium
   - Features: Smooth outline rendering

7. **Matcap Shading** - `matcap.gdshader`
   - Complexity: Low
   - Features: Image-based lighting

8. **Gaussian Blur** - `gaussian_blur_optimized.gdshader`
   - Complexity: High (post-process)
   - Features: Multi-pass blur

9. **Shockwave** - `shockwave_3d.gdshader`
   - Complexity: Medium
   - Features: Distortion effect

10. **Interactive Snow** - `interactive_snow.gdshader`
    - Complexity: Very High
    - Features: Deformation, displacement mapping

11. **Perlin Noise** - `perlin_noise.gdshader`
    - Complexity: High
    - Features: Procedural noise generation

12. **Voronoi Noise** - `voronoi_noise.gdshader`
    - Complexity: High
    - Features: Cellular noise pattern

13. **Stylized Liquid** - `stylized_liquid.gdshader`
    - Complexity: Medium
    - Features: Animated liquid surface

14. **Wind Grass** - `wind_grass.gdshader`
    - Complexity: Medium
    - Features: Vertex animation, wind simulation

15. **Flag Animation** - `flag_3d.gdshader`
    - Complexity: Medium
    - Features: Cloth simulation via vertex shader

16. **X-Ray Effect** - `xray_3d_mask.gdshader`
    - Complexity: Medium
    - Features: Depth-based transparency

17. **Sphere Mask** - `sphere_mask.gdshader`
    - Complexity: Low
    - Features: Spherical masking

18. **Clouds 2D** - `clouds2D.gdshader`
    - Complexity: High
    - Features: Procedural cloud generation

19. **Stylized Waterfall** - `stylized_waterfall.gdshader`
    - Complexity: High
    - Features: Animated waterfall with foam

20. **Particle Bridge** - `particle_bridge_spatial.gdshader`
    - Complexity: Medium
    - Features: Particle-based effects

### Scene 4: The Gauntlet
**Shaders:** Combination of all above + additional effects
- All Scene 3 shaders
- Plus post-processing: glow, bloom, SSAO (if enabled)

---

## Shader Complexity Tiers

### Low Complexity (1-2 texture lookups, simple math)
- `unlit_directional_tint.gdshader`
- `matcap.gdshader`
- `sphere_mask.gdshader`
- `rim_control.gdshader`
- `SpecularControl.gdshader`

### Medium Complexity (3-5 texture lookups, moderate math)
- `dissolve.gdshader`
- `force_field.gdshader`
- `fresnel_crystal.gdshader`
- `outline3D.gdshader`
- `shockwave_3d.gdshader`
- `stylized_liquid.gdshader`
- `wind_grass.gdshader`
- `flag_3d.gdshader`
- `xray_3d_mask.gdshader`
- `particle_bridge_spatial.gdshader`

### High Complexity (6+ texture lookups, heavy math)
- `water_3d.gdshader`
- `stylized_fire.gdshader`
- `gaussian_blur_optimized.gdshader`
- `interactive_snow.gdshader`
- `perlin_noise.gdshader`
- `voronoi_noise.gdshader`
- `clouds2D.gdshader`
- `stylized_waterfall.gdshader`

### Very High Complexity (Multiple passes, compute-heavy)
- `interactive_snow.gdshader` (displacement mapping)
- `gaussian_blur.gdshader` (multi-pass)
- `glow_prepass.gdshader` (post-processing)

---

## Quality Preset Shader Configuration

### Potato Preset
- Disable all custom shaders
- Use unlit materials only
- No post-processing

### Low Preset
- Enable 5 simple shaders (Low Complexity tier)
- No post-processing
- Reduced texture resolution

### Medium Preset
- Enable 10 shaders (Low + Medium Complexity)
- Basic post-processing (bloom only)
- Medium texture resolution

### High Preset
- Enable 15 shaders (Low + Medium + some High)
- Full post-processing (bloom, SSAO)
- High texture resolution

### Ultra Preset
- Enable all 20 shaders
- Maximum post-processing
- Full texture resolution
- Additional effects (motion blur, depth of field)

---

## Shader Performance Characteristics

### GPU Bottlenecks
- **Texture Bandwidth:** Water, Fire, Interactive Snow
- **ALU Operations:** Perlin Noise, Voronoi, Gaussian Blur
- **Fragment Overdraw:** Dissolve, X-Ray, Force Field
- **Vertex Processing:** Wind Grass, Flag, Interactive Snow

### ARM-Specific Considerations
- **Mali GPUs:** Prefer texture lookups over ALU operations
- **VideoCore (RPi4):** Limited texture units, prefer simple shaders
- **Tegra (Jetson):** Excellent at compute, can handle complex shaders

---

## Shader Integration Example

```gdscript
# Scene 3: Shader Challenge Controller (GDScript - Visual Only)
extends Node3D

var shader_controller: ShaderChallengeController  # C++ class

func _ready():
    shader_controller = ShaderChallengeController.new()
    
    # C++ handles all logic
    shader_controller.setup_shaders()
    shader_controller.start_benchmark()
    
    # Display C++ formatted status
    $StatusLabel.text = shader_controller.get_status_formatted()

func _process(delta):
    # C++ updates shader parameters
    $StatusLabel.text = shader_controller.get_status_formatted()
```

```cpp
// Scene 3: Shader Challenge Controller (C++ - All Logic)
class ShaderChallengeController : public RefCounted {
    GDCLASS(ShaderChallengeController, RefCounted)
    
private:
    Array shader_materials;
    int active_shader_count = 0;
    
public:
    void setup_shaders() {
        // Load all 20 shader materials
        shader_materials.push_back(load_shader("res://shaders/gdquest/dissolve.gdshader"));
        shader_materials.push_back(load_shader("res://shaders/gdquest/water_3d.gdshader"));
        // ... load all shaders
        
        active_shader_count = shader_materials.size();
    }
    
    String get_status_formatted() {
        return String("Active Shaders: {0}/20 | FPS: {1}")
            .format(Array::make(active_shader_count, get_fps()));
    }
    
    void start_benchmark() {
        // Benchmark logic here
    }
};
```

---

## Asset Dependencies

### Required Textures
- **Dissolve:** `addons/gdquest-shaders/dissolve/noise_tex.tres`
- **Water:** `addons/gdquest-shaders/water3d/*.png`
- **Fire:** `addons/gdquest-shaders/fire/*.png`
- **Force Field:** `addons/gdquest-shaders/forcefield/hexagon_grid.png`

### Optional Textures (for enhanced effects)
- Noise textures for procedural effects
- Normal maps for water/liquid shaders
- Gradient textures for fire/dissolve

---

## Performance Testing Strategy

### Baseline Test (No Shaders)
1. Render 20 spheres with unlit materials
2. Measure FPS (baseline)

### Progressive Shader Loading
1. Add 1 shader at a time
2. Measure FPS after each addition
3. Identify performance bottlenecks

### Shader Complexity Scaling
1. Start with Low Complexity shaders
2. Progress to Medium, then High
3. Track FPS degradation

### Quality Preset Validation
1. Test each preset on target hardware
2. Ensure FPS targets are met:
   - **Potato:** 60+ FPS (RPi4)
   - **Low:** 30+ FPS (RPi4)
   - **Medium:** 20+ FPS (RPi4)
   - **High:** 15+ FPS (RPi5/Orange Pi 5)
   - **Ultra:** 30+ FPS (Jetson Orin)

---

## Shader Modification Guidelines

### DO NOT modify original shaders
- Keep GDQuest shaders intact
- Create copies if modifications needed
- Maintain MIT license attribution

### Custom Benchmark Shaders
- Create in `res://shaders/benchmark/`
- Follow naming convention: `benchmark_*.gdshader`
- Document performance characteristics

### Shader Parameters
- Expose key parameters to C++ (via ShaderMaterial)
- Allow runtime adjustment for quality presets
- Document parameter ranges and effects

---

## License Attribution

All shaders in `res://shaders/gdquest/` are from:
- **Project:** GDQuest Godot Shaders
- **Repository:** https://github.com/gdquest-demos/godot-shaders
- **License:** MIT
- **Copyright:** © GDQuest

**Attribution Required:** Yes (include in credits and documentation)

---

## References

- **GDQuest Shaders Repository:** https://github.com/gdquest-demos/godot-shaders
- **Godot Shading Language:** https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html
- **Vulkan SPIR-V:** https://www.khronos.org/spir/

---

**Last Updated:** January 6, 2026  
**Status:** Ready for integration into benchmark scenes


# GodotMark Asset Inventory

**Last Updated:** January 6, 2026  
**Total Asset Size:** ~150 MB (uncompressed)

---

## Overview

This document catalogs all art assets in the GodotMark project, including textures, models, HDR environment maps, and audio files. All assets are sourced from Poly Haven (CC0 license) and optimized for ARM single-board computers.

---

## Directory Structure

```
art/
├── nature-benchmark/        # glTF models + HDR environment maps
│   ├── *.gltf              # 87 nature models (trees, plants, rocks)
│   ├── *.bin               # 87 binary mesh data files
│   ├── blue_grotto_2k.hdr  # 7.2 MB - Cave/grotto lighting
│   └── sunflowers_puresky_2k.hdr  # 5.7 MB - Outdoor sunny lighting
├── textures/                # 330 PBR texture sets (2K resolution)
│   └── *.jpg               # Diffuse, Normal, ARM (AO+Rough+Metal)
└── sounds/
    ├── nature-benchmark/    # Background music
    │   └── Forest Glass (nature benchmark).ogg
    └── ui/                  # UI sound effects
        ├── ui confirm.ogg
        ├── ui return.ogg
        ├── ui select.ogg
        └── ui_wrong_button4.ogg
```

---

## HDR Environment Maps

### 1. Blue Grotto (2K)
- **File:** `nature-benchmark/blue_grotto_2k.hdr`
- **Size:** 7.2 MB (7,193,972 bytes)
- **Resolution:** 2048x1024 (equirectangular)
- **Source:** Poly Haven
- **License:** CC0 (Public Domain)
- **Use Case:** Indoor/cave lighting, low-key ambient lighting
- **Lighting Characteristics:**
  - Cool blue tones
  - Low intensity
  - Simulates cave/grotto environment
  - Good for testing low-light performance

### 2. Sunflowers Pure Sky (2K)
- **File:** `nature-benchmark/sunflowers_puresky_2k.hdr`
- **Size:** 5.7 MB (5,658,712 bytes)
- **Resolution:** 2048x1024 (equirectangular)
- **Source:** Poly Haven
- **License:** CC0 (Public Domain)
- **Use Case:** Outdoor lighting, high-key ambient lighting
- **Lighting Characteristics:**
  - Warm sunny tones
  - High intensity
  - Clear sky with sun
  - Good for testing bright outdoor scenes

**Total HDR Size:** 12.9 MB (uncompressed)

---

## 3D Models (glTF)

### Nature Benchmark Collection
- **Count:** 87 models
- **Format:** glTF 2.0 (.gltf + .bin)
- **Source:** Poly Haven
- **License:** CC0 (Public Domain)

**Categories:**
1. **Trees & Saplings:**
   - Fir trees (multiple LODs)
   - Dead tree trunks
   - Quiver trees
   - Branches and twigs

2. **Plants & Flowers:**
   - Anthurium
   - Calathea Orbifolia
   - Celandine
   - Cheiridopsis Succulent
   - Crystalline Iceplant
   - Dandelion
   - Ferns
   - Gazania, Heliophila, Ursinia flowers

3. **Terrain Elements:**
   - Boulders and rocks
   - Coast rocks
   - Forest floor debris
   - Bark debris

**Estimated Total Size:** ~50 MB (87 models + binary data)

---

## PBR Textures (2K Resolution)

### Texture Sets
- **Count:** 110 texture sets (330 individual textures)
- **Resolution:** 2048x2048 (2K)
- **Format:** JPEG (will be converted to ASTC for ARM)
- **Source:** Poly Haven
- **License:** CC0 (Public Domain)

**Texture Channels:**
- **Diffuse/Albedo:** Base color (_diff_2k.jpg)
- **Normal Map:** Surface detail (_nor_gl_2k.jpg, OpenGL format)
- **ARM Map:** Combined AO + Roughness + Metallic (_arm_2k.jpg)
- **Roughness:** Separate roughness maps (_rough_2k.jpg)
- **Specular:** Separate specular maps (_spec_2k.jpg)

**Categories:**

### 1. Ground/Terrain (30+ sets)
- Brown mud (dry, wet variants)
- Burned ground
- Coast sand
- Forest floor
- Forest ground
- Forest leaves

### 2. Rocks & Stones (15+ sets)
- Boulders
- Coast rocks
- Coast land rocks

### 3. Plants & Vegetation (40+ sets)
- Anthurium botany
- Calathea orbifolia
- Celandine
- Cheiridopsis succulent
- Crystalline iceplant
- Dandelion
- Ferns
- Fir tree bark, trunks, twigs
- Flowers (Empodium, Gazania, Heliophila, Stinkkruid, Ursinia)

### 4. Tree Bark & Wood (25+ sets)
- Dead tree trunks
- Dead quiver trunk
- Dry branches
- Fir tree bark and trunks
- Fir sapling branches and twigs

**Estimated Total Size:** ~80 MB (330 JPEGs at 2K)

---

## Audio Assets

### Background Music
- **File:** `sounds/nature-benchmark/Forest Glass (nature benchmark).ogg`
- **Format:** OGG Vorbis (compressed)
- **Use Case:** Background music for nature benchmark scene
- **Estimated Size:** ~3-5 MB

### UI Sound Effects
- **ui confirm.ogg** - Confirmation/accept sound
- **ui return.ogg** - Back/cancel sound
- **ui select.ogg** - Selection/hover sound
- **ui_wrong_button4.ogg** - Error/invalid action sound
- **Total Count:** 4 UI sounds
- **Estimated Total Size:** <1 MB

---

## Optimization Strategy for ARM SBCs

### Current State (Uncompressed)
- **HDR Maps:** 12.9 MB (2K resolution)
- **3D Models:** ~50 MB (glTF + binary)
- **Textures:** ~80 MB (JPEG 2K)
- **Audio:** ~5 MB (OGG Vorbis)
- **Total:** ~150 MB

### Optimized State (Target)

#### 1. HDR Environment Maps
**Strategy:** Keep at 2K, use Radiance RGBE format (already optimal)
- **Current:** 12.9 MB (2K HDR)
- **Optimized:** 12.9 MB (no change, already efficient)
- **Rationale:** HDR maps are used for environment lighting and reflections. 2K is the minimum for acceptable quality.

**Quality Presets:**
- **Potato/Low:** Disable HDR environment, use solid color skybox (0 MB)
- **Medium:** Use downsampled 1K HDR (3-4 MB)
- **High/Ultra:** Use full 2K HDR (12.9 MB)

#### 2. PBR Textures
**Strategy:** ASTC compression + mipmaps + quality-based resolution

**ASTC Compression Ratios:**
- **ASTC 8x8:** 16:1 compression (best for ARM)
- **ASTC 6x6:** 10.67:1 compression
- **ASTC 4x4:** 8:1 compression

**Optimized Sizes:**

| Quality | Resolution | Compression | Size per Texture | Total (330 textures) |
|---------|-----------|-------------|------------------|---------------------|
| Potato  | 512x512   | ASTC 8x8    | 16 KB            | 5.3 MB              |
| Low     | 1024x1024 | ASTC 8x8    | 64 KB            | 21 MB               |
| Medium  | 2048x2048 | ASTC 6x6    | 256 KB           | 84 MB               |
| High    | 2048x2048 | ASTC 4x4    | 512 KB           | 169 MB              |
| Ultra   | 4096x4096 | ASTC 4x4    | 2 MB             | 660 MB              |

**Recommended:** Start at **Low** (21 MB), scale up with adaptive quality

#### 3. 3D Models
**Strategy:** LOD generation + mesh optimization

**LOD Levels:**
- **LOD0:** Original mesh (100% triangles)
- **LOD1:** 50% triangle reduction
- **LOD2:** 75% triangle reduction
- **LOD3:** 90% triangle reduction (billboard fallback)

**Optimized Sizes:**
- **Current:** ~50 MB (87 models, single LOD)
- **With LODs:** ~80 MB (87 models × 4 LODs, but only load as needed)
- **Runtime Memory:** ~15-30 MB (only visible LODs loaded)

**Quality Presets:**
- **Potato:** LOD3 only (5-10 MB)
- **Low:** LOD2 + LOD3 (10-15 MB)
- **Medium:** LOD1 + LOD2 (20-25 MB)
- **High:** LOD0 + LOD1 (30-40 MB)
- **Ultra:** All LODs (50 MB)

#### 4. Audio
**Strategy:** Keep OGG Vorbis (already compressed)
- **Current:** ~5 MB
- **Optimized:** ~5 MB (no change)
- **Rationale:** OGG Vorbis is already efficient for ARM

---

## Memory Budget by Quality Preset

### Potato (Target: 150 MB total, <32 MB VRAM)
- **HDR:** 0 MB (disabled)
- **Textures:** 5 MB (512px ASTC 8x8)
- **Models:** 10 MB (LOD3 only)
- **Audio:** 2 MB (UI sounds only)
- **Shaders:** 5 MB (unlit only)
- **Engine Overhead:** 50 MB
- **Total:** ~72 MB

### Low (Target: 200 MB total, <64 MB VRAM)
- **HDR:** 4 MB (1K downsampled)
- **Textures:** 21 MB (1K ASTC 8x8)
- **Models:** 15 MB (LOD2+LOD3)
- **Audio:** 5 MB (all sounds)
- **Shaders:** 10 MB (basic shaders)
- **Engine Overhead:** 50 MB
- **Total:** ~105 MB

### Medium (Target: 250 MB total, <128 MB VRAM)
- **HDR:** 13 MB (2K full)
- **Textures:** 84 MB (2K ASTC 6x6)
- **Models:** 25 MB (LOD1+LOD2)
- **Audio:** 5 MB
- **Shaders:** 15 MB (medium complexity)
- **Engine Overhead:** 50 MB
- **Total:** ~192 MB

### High (Target: 400 MB total, <256 MB VRAM)
- **HDR:** 13 MB (2K full)
- **Textures:** 169 MB (2K ASTC 4x4)
- **Models:** 40 MB (LOD0+LOD1)
- **Audio:** 5 MB
- **Shaders:** 20 MB (high complexity)
- **Engine Overhead:** 50 MB
- **Total:** ~297 MB

### Ultra (Target: 600 MB total, <512 MB VRAM)
- **HDR:** 13 MB (2K full)
- **Textures:** 660 MB (4K ASTC 4x4)
- **Models:** 50 MB (all LODs)
- **Audio:** 5 MB
- **Shaders:** 25 MB (all shaders)
- **Engine Overhead:** 50 MB
- **Total:** ~803 MB

**Note:** Ultra preset is for high-end SBCs (Jetson Orin 8GB, Orange Pi 5 Plus)

---

## Asset Loading Strategy

### Progressive Loading
1. **Startup:** Load only UI assets (<5 MB)
2. **Scene Init:** Load base quality (Potato/Low)
3. **Adaptive Upgrade:** Stream higher quality as performance allows
4. **Adaptive Downgrade:** Unload high-quality assets if thermal throttling

### Streaming
- **Textures:** Load lower mip levels first, stream higher mips
- **Models:** Load LOD3 first, stream LOD2/LOD1/LOD0 as needed
- **HDR:** Load solid color skybox, stream HDR if performance allows

### Unloading
- **Aggressive:** Unload unused assets every 30 seconds
- **Thermal-Aware:** Unload high-quality assets when temp >75°C
- **Memory-Aware:** Unload if RAM usage >80%

---

## Asset Preparation Checklist

### Phase 1: HDR Environment Maps ✅
- [x] Add blue_grotto_2k.hdr (7.2 MB)
- [x] Add sunflowers_puresky_2k.hdr (5.7 MB)
- [ ] Configure Godot import settings (Radiance HDR format)
- [ ] Generate 1K downsampled versions for Low preset
- [ ] Test in benchmark scenes

### Phase 2: Texture Optimization
- [ ] Convert all JPEGs to ASTC compression
- [ ] Generate mipmaps for all textures
- [ ] Create quality preset variants (512px, 1K, 2K, 4K)
- [ ] Test VRAM usage on target hardware
- [ ] Verify visual quality at each preset

### Phase 3: Model Optimization
- [ ] Generate LOD levels for all 87 models
- [ ] Optimize mesh topology (remove duplicate vertices)
- [ ] Bake ambient occlusion for static models
- [ ] Test triangle count vs FPS on RPi4
- [ ] Verify LOD switching distances

### Phase 4: Audio Optimization
- [ ] Verify OGG Vorbis compression quality
- [ ] Test audio playback on ARM (CPU usage)
- [ ] Implement audio streaming for background music
- [ ] Add audio quality presets (if needed)

---

## Benchmark Scene Asset Usage

### Scene 1: GPU Basics
**Assets:**
- 10-20 models (boulders, rocks, simple plants)
- 20-30 texture sets (rock, ground)
- 1 HDR environment (sunflowers_puresky_2k)
- **Target VRAM:** 32-128 MB (depending on quality)

### Scene 2: Physics Test
**Assets:**
- 50-2000 physics bodies (simple shapes + some models)
- 10-20 texture sets (minimal)
- No HDR (solid skybox)
- **Target VRAM:** 20-50 MB

### Scene 3: Shader Challenge
**Assets:**
- 10-15 models (showcase shader effects)
- 30-40 texture sets (variety for shader testing)
- 1 HDR environment (blue_grotto_2k for reflections)
- **Target VRAM:** 64-256 MB

### Scene 4: The Gauntlet
**Assets:**
- 30-50 models (combined GPU + Physics)
- 50-80 texture sets (full variety)
- 1 HDR environment (alternating)
- **Target VRAM:** 100-400 MB

---

## Source Attribution

All assets are sourced from **Poly Haven** (https://polyhaven.com/)
- **License:** CC0 (Public Domain)
- **Attribution:** Not required, but appreciated
- **Commercial Use:** Allowed
- **Modification:** Allowed

**Recommended Attribution:**
```
3D Assets, Textures, and HDR Maps by Poly Haven (CC0)
https://polyhaven.com/
```

---

## Asset Validation

### Quality Checks
- [ ] All textures have matching Normal + ARM/Roughness maps
- [ ] All models have valid UVs
- [ ] All HDR maps are equirectangular 2:1 ratio
- [ ] All audio files are OGG Vorbis format
- [ ] No missing texture references in models

### Performance Checks
- [ ] Texture sizes are power-of-2 (512, 1024, 2048, 4096)
- [ ] Models have reasonable triangle counts (<10K per model)
- [ ] HDR maps are 2K or lower (not 4K/8K)
- [ ] Audio files are compressed (not WAV)

### Compatibility Checks
- [ ] glTF models load correctly in Godot 4.4+
- [ ] HDR maps display correctly in Environment
- [ ] Textures import with ASTC compression on ARM
- [ ] Audio plays correctly on Linux ARM64

---

## Future Asset Additions

### Potential Additions
1. **More HDR Environments:**
   - Indoor lighting (warehouse, studio)
   - Night lighting (moonlight, city lights)
   - Extreme lighting (sunset, overcast)

2. **Particle Textures:**
   - Smoke, fire, sparks
   - Dust, leaves, petals
   - Water splashes, rain

3. **UI Assets:**
   - Custom fonts (optimized for readability)
   - Icons and buttons
   - Progress bars and meters

4. **Benchmark-Specific Models:**
   - High-poly stress test models (100K+ triangles)
   - Animated characters (for skinning tests)
   - Transparent objects (for alpha blending tests)

---

## Conclusion

The current asset collection provides a solid foundation for GodotMark's benchmark scenes. With 87 nature models, 110 PBR texture sets, 2 HDR environment maps, and audio assets, we have sufficient variety to create visually impressive and performance-challenging benchmark scenarios.

**Key Strengths:**
- ✅ All assets are CC0 (no licensing issues)
- ✅ High-quality PBR materials (2K resolution)
- ✅ Diverse nature theme (cohesive visual style)
- ✅ HDR environment maps for realistic lighting
- ✅ Optimized audio (OGG Vorbis)

**Next Steps:**
1. Configure Godot import settings for ASTC compression
2. Generate LOD levels for all models
3. Create quality preset variants
4. Test memory usage on target hardware (RPi4, RPi5, Jetson)
5. Integrate assets into benchmark scenes

---

**Total Current Asset Size:** ~150 MB (uncompressed)  
**Target Optimized Size:** 20-200 MB (depending on quality preset)  
**Status:** Ready for optimization and integration


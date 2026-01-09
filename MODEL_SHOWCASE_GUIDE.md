# Model Showcase - 1-Minute GPU Benchmark

## Overview

The Model Showcase is a cinematic 1-minute GPU stress test that progressively adds rendering features to a marble bust model, synchronized to the "Excelsior In Aeternum" soundtrack.

## Quick Start

### From Main Scene
1. Launch GodotMark (run `main.tscn`)
2. Press **M** to launch Model Showcase
3. Sit back and watch the 60-second benchmark

### Direct Launch
- Open `scenes/model_showcase.tscn` in Godot Editor
- Press F6 to run the scene

## Timeline Structure

The benchmark is divided into 5 phases, each lasting 12 seconds:

### Phase 1: Basic PBR (0-12s)
**Features:**
- Single marble bust with basic PBR material
- Simple directional light
- No shadows, no HDR, no post-processing

**Camera:** Slow dolly-in from distance

**Purpose:** Establish baseline performance

**Expected FPS:**
- RPi5: 50-60 FPS
- Windows: 100+ FPS

---

### Phase 2: HDR Lighting + Shadows (12-24s)
**Features:**
- HDR environment (`sunflowers_puresky_2k.hdr`)
- Shadow casting enabled
- Environment reflections on marble

**Camera:** Begin orbital rotation (90° arc)

**Purpose:** Test HDR environment and shadow rendering

**Expected FPS:**
- RPi5: 40-50 FPS
- Windows: 80-100 FPS

---

### Phase 3: Enhanced Materials + Reflections (24-36s)
**Features:**
- Screen-space reflections (SSR)
- Ambient occlusion (SSAO)
- Enhanced material quality

**Camera:** Continue orbit, slight zoom out

**Purpose:** Test advanced material rendering

**Expected FPS:**
- RPi5: 35-45 FPS
- Windows: 60-80 FPS

**Quality Gate:** Skipped on Potato preset

---

### Phase 4: Particles + Glow (36-48s)
**Features:**
- GPU particle system (500-2000 particles)
- Glow/bloom post-processing
- Dust motes around bust

**Camera:** Orbit from opposite side, dolly in

**Purpose:** Test particle rendering and post-processing

**Expected FPS:**
- RPi5: 30-40 FPS
- Windows: 50-70 FPS

**Quality Gate:** Skipped on Low/Potato presets

---

### Phase 5: Maximum Complexity (48-60s)
**Features:**
- All effects enabled
- Maximum particle count (quality-dependent)
- Depth of field (DOF)
- Increased glow intensity

**Camera:** Final dramatic orbit, end on hero shot

**Purpose:** Maximum GPU stress test

**Expected FPS:**
- RPi5: 25-35 FPS
- Windows: 40-60 FPS

**Quality Gate:** Reduced effects on Medium/Low/Potato presets

---

## Quality Preset Behavior

The showcase respects the current quality preset:

### Potato (RPi4 2GB)
- **Phases:** 1-2 only
- **Shadows:** Disabled
- **HDR:** Disabled (solid color background)
- **Particles:** Disabled
- **Post-processing:** Disabled

### Low (RPi4 4GB)
- **Phases:** 1-3
- **Shadows:** Basic
- **HDR:** Enabled
- **SSR/SSAO:** Enabled
- **Particles:** Disabled

### Medium (RPi5)
- **Phases:** 1-4
- **Shadows:** Medium quality
- **HDR:** Full 2K
- **SSR/SSAO:** Enabled
- **Particles:** 500
- **Glow:** Enabled

### High (RPi5 / Orange Pi 5)
- **Phases:** 1-5
- **Shadows:** High quality
- **HDR:** Full 2K
- **SSR/SSAO:** Enabled
- **Particles:** 2000
- **Glow:** Enhanced
- **DOF:** Enabled

### Ultra (Jetson Orin)
- **Phases:** 1-5
- **Shadows:** Maximum quality
- **HDR:** Full 2K
- **SSR/SSAO:** Maximum
- **Particles:** 5000
- **Glow:** Maximum
- **DOF:** Enabled

---

## Performance Metrics

The showcase tracks performance throughout all phases:

### Metrics Collected
- Average FPS per phase
- Minimum FPS per phase
- Maximum FPS per phase
- Average frame time (ms)
- GPU temperature

### Results Export

Results are automatically exported to:
```
user://model_showcase_results.json
```

**Location on Windows:**
```
%APPDATA%\Godot\app_userdata\GodotMark\model_showcase_results.json
```

**Location on Linux:**
```
~/.local/share/godot/app_userdata/GodotMark/model_showcase_results.json
```

### JSON Format

```json
{
  "benchmark": "Model Showcase",
  "duration": 60.0,
  "timestamp": "2026-01-07T12:34:56",
  "phases": {
    "phase_1": {
      "avg_fps": 55.2,
      "min_fps": 48.3,
      "max_fps": 60.0,
      "avg_frame_time_ms": 18.1,
      "avg_temperature": 47.5
    },
    ...
  }
}
```

---

## Controls

### During Showcase
- **ESC** - Exit to main scene (early exit)

### Before Launch (from main scene)
- **Q/E** - Adjust quality preset
- **V** - Enable verbose logging
- **M** - Launch showcase

---

## Cinematic Camera

The camera uses keyframe-based animation with smooth easing:

**Keyframes:**
1. `0s` - Wide shot (10 units away)
2. `12s` - Medium shot (5 units away)
3. `24s` - Right side orbit (5 units, elevated)
4. `36s` - Left side orbit (5 units, higher elevation)
5. `48s` - Close-up (3 units, lower angle)
6. `60s` - Hero shot (4 units, centered)

**Easing:** Cubic ease-in-out for smooth, cinematic motion

---

## Assets Used

### Model
- **File:** `art/model-test/marble_bust_01_2k.gltf`
- **Vertices:** 9,746
- **Triangles:** 52,368
- **Textures:**
  - Diffuse (2K)
  - Normal map (2K)
  - Roughness (2K)

### Environment
- **File:** `art/model-test/sunflowers_puresky_2k.hdr`
- **Resolution:** 2048x1024
- **Format:** Radiance HDR

### Audio
- **File:** `art/model-test/Excelsior In Aeternum.ogg`
- **Duration:** Exactly 60 seconds
- **Format:** OGG Vorbis

---

## Technical Details

### Scene Structure
```
ModelShowcase (Node3D)
├── MarbleBust (imported glTF)
├── Camera3D (cinematic controller)
├── DirectionalLight3D (dynamic shadows)
├── WorldEnvironment (HDR + post-processing)
├── Particles (GPUParticles3D)
└── AudioStreamPlayer (soundtrack)
```

### Scripts
- `scripts/model_showcase.gd` - Main controller, timeline, effects
- `scripts/cinematic_camera.gd` - Keyframe animation system

---

## Troubleshooting

### Audio Not Playing
- Check that `art/model-test/Excelsior In Aeternum.ogg` exists
- Verify audio import settings in Godot

### HDR Not Loading
- Ensure `art/model-test/sunflowers_puresky_2k.hdr` is imported
- Check Godot import settings (should be Radiance HDR)

### Low FPS Throughout
- Check current quality preset (press Q to lower)
- Verify GPU drivers are up to date
- Check thermal throttling (press V for verbose temps)

### Particles Not Visible
- Particles only appear in Phase 4+ (36 seconds in)
- Disabled on Low/Potato quality presets
- Check that particles are emitting (verbose logging)

### Camera Not Moving
- Verify `cinematic_camera.gd` is attached to Camera3D
- Check console for script errors
- Ensure timeline is advancing (check audio playback)

---

## Performance Expectations

### Windows Desktop (GTX 1060 / RX 580)
- **Phase 1:** 100-120 FPS
- **Phase 2:** 80-100 FPS
- **Phase 3:** 60-80 FPS
- **Phase 4:** 50-70 FPS
- **Phase 5:** 40-60 FPS

### Raspberry Pi 5 (Medium Quality)
- **Phase 1:** 50-60 FPS
- **Phase 2:** 40-50 FPS
- **Phase 3:** 35-45 FPS
- **Phase 4:** 30-40 FPS
- **Phase 5:** 25-35 FPS (reduced effects)

### Raspberry Pi 4 (Low Quality)
- **Phase 1:** 30-40 FPS
- **Phase 2:** 25-35 FPS
- **Phase 3:** 20-30 FPS
- **Phase 4:** Skipped
- **Phase 5:** Skipped

---

## Future Enhancements

Potential additions:
- Multiple bust instances in Phase 5 (Ultra only)
- Dynamic lighting changes
- Material parameter animation
- Volumetric fog
- Ray-traced reflections (Jetson Orin)
- Frame time graph export (PNG)

---

## Credits

**Model:** Marble Bust by Poly Haven (CC0)  
**HDR:** Sunflowers Pure Sky by Poly Haven (CC0)  
**Music:** Excelsior In Aeternum (source TBD)  
**Benchmark:** GodotMark Project

---

**Enjoy the show!** 🎭


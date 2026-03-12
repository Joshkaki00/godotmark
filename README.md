# GodotMark - 3D Gaming Benchmark for ARM SBCs

[![Version](https://img.shields.io/badge/version-0.1.0--alpha-blue.svg)](https://github.com/yourusername/godotmark/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Godot](https://img.shields.io/badge/godot-4.4--stable-478cbf.svg)](https://godotengine.org/)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%20%7C%20ARM%20SBCs-c51a4a.svg)](https://www.raspberrypi.com/)

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](BUILD_AND_RUN.md)
[![ARM64](https://img.shields.io/badge/ARM64-optimized-orange.svg)](OPTIMIZATION_COMPLETE_GUIDE.md)
[![OpenGL ES 3.0](https://img.shields.io/badge/OpenGL%20ES-3.0-blue.svg)](https://www.khronos.org/opengles/)
[![Performance](https://img.shields.io/badge/performance-60%20FPS%20target-success.svg)](COMPLETE_OPTIMIZATION_STORY.md)

[![Contributors](https://img.shields.io/badge/contributors-welcome-blueviolet.svg)](CONTRIBUTING.md)
[![Good First Issues](https://img.shields.io/badge/good%20first%20issues-available-yellow.svg)](.github/GOOD_FIRST_ISSUES_GUIDE.md)
[![Discussions](https://img.shields.io/badge/discussions-open-brightgreen.svg)](https://github.com/Joshkaki00/godotmark/discussions)
[![Documentation](https://img.shields.io/badge/docs-comprehensive-informational.svg)](DOCS_QUICK_REFERENCE.md)
[![Changelog](https://img.shields.io/badge/changelog-maintained-success.svg)](CHANGELOG.md)

**Version 0.1.0-alpha** | Open-source benchmark for Raspberry Pi, Orange Pi, Rock 5B, and other ARM single-board computers

Built with **Godot 4.4-stable**, **C++ GDExtension**, and optimized for low-power ARM hardware

📖 **READ:** [`CHANGELOG.md`](CHANGELOG.md) - Complete project history, fixes, and optimizations

✅ **FULLY WORKING:** All benchmarks now operational and optimized! Both Model Showcase and Nature Island running at target FPS.

✅ **SOLVED:** Nature Island performance issues completely resolved! All shaders re-enabled (wind, ocean waves), metrics displaying correctly, full feature parity achieved.

💬 **COMMUNITY:** Join the discussion! Questions, ideas, and feedback welcome at [GitHub Discussions](https://github.com/Joshkaki00/godotmark/discussions)

---

## 💬 Community & Support

**Got questions? Want to share results? Have ideas?**

👉 **[Join the Discussion](https://github.com/Joshkaki00/godotmark/discussions)** 👈

### Discussion Categories

- **📣 Announcements** - Project updates and news
- **💬 General** - General discussion about GodotMark
- **💡 Ideas** - Feature requests and suggestions
- **🗳️ Polls** - Community polls and voting
- **🙏 Q&A** - Get help and ask questions
- **🙌 Show and Tell** - Share your benchmark results!

### Quick Links

- 🐛 [Report a Bug](https://github.com/Joshkaki00/godotmark/issues)
- 🚀 [Request a Feature](https://github.com/Joshkaki00/godotmark/discussions/categories/ideas)
- 📖 [Read the Docs](DOCS_QUICK_REFERENCE.md)
- 🤝 [Contributing Guide](CONTRIBUTING.md)
- 📊 [View Changelog](CHANGELOG.md)

---

## 🎯 Overview

GodotMark is a **comprehensive 3D gaming benchmark** designed specifically for ARM single-board computers (SBCs). It pushes hardware to its limits while remaining efficient and lean for embedded systems.

**Two Benchmarks (Both Fully Operational!):**
1. **Model Showcase** - ✅ GPU stress test with PBR materials and particle effects (fully optimized)
2. **Nature Island** - ✅ Draw call efficiency test with procedural outdoor environment (fully optimized, all features enabled)

---

## 📊 Quick Stats

### Model Showcase Benchmark

- **Duration:** 60 seconds (5 progressive phases)
- **Status:** ✅ Fully functional and optimized
- **FPS:** Smooth performance on Raspberry Pi 4/5

### Nature Island Benchmark

- **Duration:** 60 seconds (5 progressive phases)
- **Objects:** 125 nature assets (40 trees, 15 rocks, 50 vegetation, 20 ground details)
- **Triangles:** ~5,600 (under RPi 4's 10K budget)
- **Draw Calls:** 4 total (MultiMesh instancing)
- **VRAM:** 74 MB (compressed textures)
- **Status:** ✅ Fully operational and optimized (40+ FPS on Raspberry Pi 5, all features enabled)
- **Features:** Wind shaders (trees + vegetation), ocean waves, Jolt Physics, real-time GPU/temp metrics
- **Shape:** Elliptical island (106.5m × 213m, ~4.5 acres visual scale)

---

## 🚀 Quick Start (Raspberry Pi)

### 1. Install V3D Driver Stack (Required)

**For optimal performance, you MUST configure the V3D graphics driver first!**

```bash
cd godotmark
sudo ./install_v3d_stack.sh
```

This automated script will:
- ✅ Enable V3D KMS driver in `/boot/config.txt`
- ✅ Install Mesa Vulkan drivers
- ✅ Install Vulkan tools for verification
- ✅ Verify your configuration
- ✅ Guide you through rebooting if needed

**Time:** ~5 minutes + reboot

<details>
<summary>Manual Installation (Advanced Users)</summary>

If you prefer to configure manually:

1. Edit `/boot/config.txt` (or `/boot/firmware/config.txt` on newer OS):
   ```bash
   sudo nano /boot/config.txt
   ```

2. Add under `[pi4]` or `[pi5]`:
   ```
   dtoverlay=vc4-kms-v3d
   max_framebuffers=2
   gpu_mem=384
   ```

3. Install Mesa and Vulkan packages:
   ```bash
   sudo apt update
   sudo apt install mesa-vulkan-drivers libvulkan1 vulkan-tools
   ```

4. Reboot:
   ```bash
   sudo reboot
   ```

5. Verify installation:
   ```bash
   cd godotmark
   ./check_v3d_setup.sh
   ```

</details>

**Why is this important?**
- Without V3D, you'll use software rendering (10x slower!)
- GodotMark will detect missing drivers and show a warning
- Benchmark results will be inaccurate without proper GPU acceleration

---

### 2. Optimize Assets for Raspberry Pi (REQUIRED)

**This step is critical for Raspberry Pi 4/5!**

```powershell
cd godotmark
.\optimize_for_raspberry_pi.ps1
```

This script will:
1. ✅ Enable mesh LOD generation on all 60+ GLTF models
2. ✅ Apply VRAM compression to 225+ textures
3. ✅ Downscale textures from 1024×1024 to 512×512
4. ✅ Generate mipmaps for better distance rendering
5. ✅ Calculate expected performance improvements
6. ✅ Optionally delete import cache for you

**Expected time:** 2-5 minutes for Godot to reimport all assets

**Results:**
- Triangle count: 457,000 → 5,600 (98.7% reduction)
- VRAM usage: 299 MB → 74 MB (75% reduction)
- FPS improvement: <5 FPS → 40-60 FPS

---

### 3. Build the Benchmark (If Using Native Build)

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```

**Build time:** ~10-20 minutes (first time)

**Clean Build:**
```bash
# Remove all build artifacts
python clean.py

# Rebuild from scratch
./build_native_rpi5.sh template_release rpi5 yes
```

**See:** [`CLEAN_BUILD_GUIDE.md`](CLEAN_BUILD_GUIDE.md) for detailed clean build procedures

---

### 4. Run the Benchmark

**GUI Mode (Normal):**
```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**Headless Mode (CLI):**
```bash
# Run specific benchmark
./godotmark --benchmark nature-island

# Custom output path
./godotmark --benchmark model-showcase --output-path ./results/test.json

# Quality presets
./godotmark --benchmark nature-island --quality low

# Show help
./godotmark --help
```

**See:** [`CLI_GUIDE.md`](CLI_GUIDE.md) for complete CLI documentation

**Note:** GodotMark will automatically check your driver configuration on startup!

---

### 5. Use Debug Controls

| Key | Action |
|-----|--------|
| **Space** | Pause/Resume |
| **Q / E** | Quality Down / Up |
| **T** | Toggle Quick Test (10s/60s) |
| **V** | Verbose Logging |
| **R** | Reset |
| **Esc** | Exit to Menu |

---

## 🎮 The Optimization Story: Why Godot 4.4?

### The Question: "Should We Have Used Godot 3.6?"

During development, we asked: **Would Godot 3.6 have been better for Raspberry Pi?**

**TL;DR: No. Godot 4.4 with proper optimization is the right choice.**

### Godot 3.6 vs 4.4 Comparison

| Factor | Godot 3.6 | Godot 4.4 (Optimized) |
|--------|-----------|------------------------|
| **Base FPS (minimal)** | ~90 FPS | ~75 FPS |
| **Memory overhead** | ~200 MB | ~300 MB |
| **RPi driver support** | Excellent (GLES3) | Good (GLES3) |
| **Development status** | Maintenance only | Active development |
| **Future relevance** | Legacy (2024+) | Modern standard |
| **Our benchmark FPS** | 50-70 FPS | 40-60 FPS |
| **Difference** | **10-15% faster** | **Future-proof** ✅ |

### Why We Chose Godot 4.4

**1. Future-Proofing**
- Godot 3.x is in maintenance mode (no new features)
- Godot 4.x is the active development branch
- People want to know how **modern Godot** performs on Pi

**2. Better Benchmark Representation**
- Tests what new projects will actually use (2024+)
- More advanced rendering features to stress-test
- Realistic workload for "real" games

**3. Optimization Brings Them Close**
The 10-15% performance gap was closed through aggressive optimization:
- ✅ GLES3 renderer (not Vulkan)
- ✅ VRAM texture compression
- ✅ Mesh LOD generation
- ✅ Physics server disabled
- ✅ Per-vertex lighting
- ✅ MultiMesh instancing

**Conclusion:** The small performance difference isn't worth using a legacy engine. Godot 4.4 is the right choice for benchmarking modern game performance on Raspberry Pi.

---

## 🔬 The Complete Optimization Journey

### Problem #1: 7.5 FPS on Raspberry Pi (Initial Test)

**Symptoms:**
- Minimal test scene (5 trees + ocean) running at 7.5 FPS
- CPU time: 26.1ms per frame
- Physics time: 15.7ms per frame (67% of CPU!)

**Root Causes Identified:**
1. **Physics Server Running** - Despite having no physics bodies
2. **Vulkan Renderer** - High driver overhead on ARM
3. **Unoptimized Models** - 3,000-8,000 triangles each

**Solutions Applied:**

**Fix #1: Disable Physics Server**
```gdscript
func _ready():
    PhysicsServer3D.set_active(false)
    print("[Benchmark] Physics server disabled (no physics bodies)")
```
- **Result:** 15.7ms physics overhead eliminated
- **FPS improvement:** 7.5 → 42 FPS

**Fix #2: Switch to GLES3 Renderer**
```ini
# project.godot
[rendering]
renderer/rendering_method="opengl3"
```
- **Result:** Lower driver overhead on ARM
- **FPS improvement:** 42 → 75 FPS on minimal test

See: `PHYSICS_BOTTLENECK_FIX.md`

---

### Problem #2: 10 FPS on Desktop PC

**Symptoms:**
- Nature Island running at 10 FPS on a powerful desktop PC
- Should be 60+ FPS with only 36 objects
- GPU heavily utilized

**Root Causes Identified:**
1. **Post-Processing Effects** - SSAO and Glow enabled
2. **Uncompressed Textures** - 1.25 GB VRAM usage!

**Solutions Applied:**

**Fix #1: Disable Post-Processing**
```gdscript
# nature_island.tscn WorldEnvironment
ssao_enabled = false     # Screen-space ambient occlusion
glow_enabled = false     # Bloom/glow
```
- **Why:** These effects process every pixel multiple times
- **Result:** Slight FPS improvement but still bottlenecked

**Fix #2: Aggressive Texture Compression** (The Real Fix!)

**The Problem:**
- 225 textures × 1024×1024 × Lossless compression = **1.25 GB VRAM**
- GPU memory bandwidth completely saturated
- Texture sampling became the bottleneck

**The Solution:**
```ini
# Applied via optimize_for_raspberry_pi.ps1
compress/mode=2                    # VRAM Compressed (S3TC/ETC2)
compress/lossy_quality=0.6          # Aggressive compression
process/size_limit=512              # Downscale to 512×512
mipmaps/generate=true               # Better distance rendering
```

**The Math:**
```
Before: 225 textures × 5.33 MiB = 1,279 MiB (1.25 GB)
After:  225 textures × 0.33 MiB = 74 MiB (74 MB)
Savings: 1,205 MiB (94% reduction!)
```

- **Result:** 10 → 60+ FPS on desktop PC
- **Bonus:** Raspberry Pi can now actually run it!

See: `TEXTURE_COMPRESSION_FIX.md` and `PERFORMANCE_FIX_10FPS.md`

---

### Problem #3: Triangle Count Too High for Raspberry Pi 4

**Research Findings:**

From actual Raspberry Pi 4 testing:
- **Triangle throughput:** 16 million triangles/second @ 720p
- **500 triangle model:** Can render 132 instances @ 60 FPS
- **Total scene budget:** <10,000 triangles for 60 FPS
- **Per-vertex lighting:** Required (per-pixel too slow)

**Our Initial Benchmark:**
- 165 objects with PolyHaven photogrammetry models
- Average 3,000-8,000 triangles per model
- **Total: ~457,000 triangles (45× over budget!)**

**The Math:**
```
Target:  10,000 triangles @ 60 FPS
Current: 457,000 triangles
Overage: 45× too many triangles!

Expected FPS: 60 / 45 = 1.3 FPS 😱
```

**Solutions Applied:**

**Step 1: Reduce Object Counts**
```
Trees: 40 → 10 (×400 tri target = 4,000 tri)
Rocks: 25 → 6 (×100 tri target = 600 tri)
Vegetation: 65 → 20 (×50 tri target = 1,000 tri)
Ground details: 35 → 0 (removed)
Total: 165 → 36 objects
```

**Step 2: Enable Mesh LOD Generation**
```
# Applied via optimize_for_raspberry_pi.ps1
meshes/generate_lods=true           # Auto mesh simplification
meshes/create_shadow_meshes=true    # Optimized shadow rendering
```

**Step 3: Add Runtime Simplification**
```gdscript
# nature_island.gd
func extract_gltf_asset(gltf_scene, asset_name):
    # ... mesh extraction ...
    mesh.simplify(0.2)  # Reduce to 20% of original triangles
    return mesh
```

**Final Result:**
```
Estimated triangles: ~5,600 (under 10K budget)
Expected FPS: 40-60 FPS on RPi 4
Actual FPS: 40-60 FPS on RPi 4 ✅
```

See: `RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`

---

### Problem #4: Too Many Draw Calls

**The Issue:**
- Each asset type created a separate MultiMeshInstance3D
- 15+ draw calls for a small scene
- Driver overhead on ARM GPUs

**The Solution:**
```gdscript
func create_combined_multimesh(asset_library, placement_rules):
    # Combine all instances of similar assets into ONE MultiMesh
    var combined_mesh = MultiMeshInstance3D.new()
    var multimesh = MultiMesh.new()
    
    # Set transforms for all instances at once
    for i in range(total_instances):
        multimesh.set_instance_transform(i, random_transform)
    
    return combined_mesh
```

**Result:**
- 15 draw calls → 4 draw calls (73% reduction)
- Lower driver overhead
- Better GPU utilization

See: `NATURE_BENCHMARK_REDESIGN.md`

---

### Problem #5: Visibility Range Popping

**The Issue:**
- Objects using `visibility_range_begin/end` for LOD
- Caused ugly "popping" as objects appeared/disappeared
- User feedback: "defeats the purpose. just focus on lod distance"

**The Solution:**
```gdscript
# Removed from create_combined_multimesh():
# multimesh_instance.visibility_range_begin = 0.0
# multimesh_instance.visibility_range_end = 40.0
# multimesh_instance.visibility_range_fade_mode = 1

# Increased camera far plane instead:
camera.far = 100.0  # From 50.0
```

**Result:**
- No more popping artifacts
- Smooth continuous rendering
- LOD handled by mesh simplification, not visibility culling

---

## 📐 Raspberry Pi 4 Technical Specifications

### Research-Based Performance Targets

**Triangle Throughput:**
- 16 million triangles/second @ 720p with basic lighting
- 19,000 triangle model: ~12 copies @ 60 FPS
- **500 triangle model (optimal):** 132 models @ 60 FPS
- 6,000 triangle model: 130 FPS (but only 1 model)

**Optimal Model Complexity:**
- **Low-poly models:** 500-1000 triangles per model
- **Total scene budget:** <10,000 triangles for 60 FPS
- **Per-vertex lighting:** Much faster than per-pixel

**Memory Constraints:**
- **GPU memory:** 256-384 MB (via `gpu_mem` setting)
- **Texture budget:** Must fit in VRAM with compression
- **Max texture size:** 4096×4096 (but use 512×512 for RPi)

**OpenGL Capabilities:**
- Max uniform components: 16,384
- Max varying floats: 64
- Max vertex texture units: 16
- Max combined texture units: 64
- Max cubemap size: 4,096
- Shader support: GLSL 1.20 (fragment + vertex)

**Performance Formula:**
```
Max objects @ 60 FPS = (Triangle budget) / (Avg triangles per object)

Before optimization: 10,000 / 3,000 = 3 models (not viable)
After optimization:  10,000 / 150 = 66 models (viable!) ✅
```

**Sources:**
- Big Mess o' Wires (RPi GPU testing)
- Raspberry Pi Forums (OpenGL specs)
- Official VideoCore VI documentation

---

## 🎨 Nature Island Benchmark Details

### Island Environment

**Size:** 0.5 acre (~20,000 sq ft) = 30m × 60m

```
                 60m (length)
    ┌───────────────────────────┐
    │                           │
30m │    0.5 Acre Island        │
    │    (Ground Plane)         │
    │                           │
    └───────────────────────────┘

Ocean: 80m × 80m (surrounds island)
Camera: 180° orbit, 25-40m distance, 10-16m height
```

### Phase Structure (60 seconds)

| Phase | Time    | Objects | Triangles | Draw Calls | Features                        | Target FPS (RPi 4) |
|-------|---------|---------|-----------|------------|---------------------------------|--------------------|
| 1     | 0-12s   | 10      | ~4,000    | 2          | Forest, per-vertex lit          | **60+**            |
| 2     | 12-24s  | 16      | ~4,600    | 3          | + 6 rocks, ocean waves          | **55+**            |
| 3     | 24-36s  | 36      | ~5,600    | 4          | + 20 vegetation, wind shader    | **50+**            |
| 4     | 36-48s  | 36      | ~5,600    | 4          | Tree wind (no new geometry)     | **45+**            |
| 5     | 48-60s  | 36      | ~5,600    | 4          | Maximum ocean waves             | **40+**            |

### Asset Distribution

**Total: 36 objects, ~5,600 triangles (under RPi 4's 10K budget)**

- **Trees (10):** 6 interior + 4 coastal (~400 tri each = 4,000 tri)
- **Rocks (6):** 4 coastal + 2 general (~100 tri each = 600 tri)
- **Vegetation (20):** 12 interior + 5 coastal + 3 general (~50 tri each = 1,000 tri)
- **Ground Details (0):** Removed to stay under triangle budget

### Shader Effects

**Wind Animation (GPU-based, zero CPU cost):**

**Phase 3: Vegetation**
```glsl
shader: wind_vegetation.gdshader
wind_speed: 2.0
wind_strength: 0.15
max_height: 2.0
```

**Phase 4: Trees**
```glsl
shader: wind_trees.gdshader
wind_speed: 0.8
wind_strength: 0.4
max_height: 5.0
```

**Ocean Waves:**
| Phase | wave_height | Effect           |
|-------|-------------|------------------|
| 1     | 0.0         | Calm, color only |
| 2     | 0.3         | Gentle waves     |
| 4     | 0.5         | Moderate waves   |
| 5     | 0.8         | Maximum waves    |

### Camera Path

**60-second orbit showcasing 0.5-acre island:**

```
Start (0s): South view, high angle (16m)
  ↓
Southeast (12s): Descending, showing rocks (12m)
  ↓
East (24s): Side view of island length (10m)
  ↓
Northeast (36s): Ground detail perspective (12m)
  ↓
North (48s): Wide final view (14m)
  ↓
Northwest (60s): Completion (16m)
```

---

## 📊 Performance Expectations

### Raspberry Pi 5 (GLES3, Optimized)
- **FPS:** 45-60+ (High/Ultra)
- **Temperature:** 50-60°C
- **CPU Usage:** 40-60%
- **GPU Usage:** 70-85%

### Raspberry Pi 4 (GLES3, Optimized)
- **FPS:** 40-60 (Phase-dependent)
- **Temperature:** 55-70°C
- **CPU Usage:** 50-70%
- **GPU Usage:** 80-95%

### Desktop PC (Vulkan, Unoptimized Assets)
- **FPS:** 60+ (locked)
- **VRAM:** ~100 MB (with optimization)
- **CPU Usage:** 10-20%
- **GPU Usage:** 30-50%

---

## 🔧 Optimization Techniques Applied

### 1. Rendering Backend
```ini
# project.godot
[rendering]
renderer/rendering_method="opengl3"  # GLES3 for ARM compatibility
```
**Why:** Vulkan has high driver overhead on ARM. GLES3 is more mature on Raspberry Pi.

### 2. Physics Disabled
```gdscript
PhysicsServer3D.set_active(false)
```
**Why:** Benchmark has no physics bodies. Eliminates 15.7ms CPU overhead.

### 3. Texture Compression
```ini
compress/mode=2                     # VRAM Compressed (S3TC/ETC2)
compress/lossy_quality=0.6          # Aggressive compression
process/size_limit=512              # Downscale to 512×512
mipmaps/generate=true               # Better distance rendering
```
**Why:** Reduces VRAM from 1.25 GB to 74 MB. Eliminates memory bandwidth bottleneck.

### 4. Mesh LOD Generation
```ini
meshes/generate_lods=true           # Auto mesh simplification
meshes/create_shadow_meshes=true    # Optimized shadow rendering
```
**Why:** Reduces triangles from 457K to 5.6K (98.7% reduction).

### 5. Runtime Mesh Simplification
```gdscript
mesh.simplify(0.2)  # 80% triangle reduction
```
**Why:** Further reduces polygon count for ultra-low-poly targets.

### 6. MultiMesh Instancing
```gdscript
multimesh_groups["all_trees"] = create_combined_multimesh(trees, placements)
```
**Why:** Reduces 15 draw calls to 4. Lower driver overhead on ARM.

### 7. Per-Vertex Lighting
```gdscript
material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
```
**Why:** Per-pixel lighting is too expensive on VideoCore VI GPU.

### 8. Post-Processing Disabled
```gdscript
ssao_enabled = false  # Screen-space ambient occlusion
glow_enabled = false  # Bloom/glow
```
**Why:** Fragment shader bottleneck. Processes every pixel multiple times.

### 9. Threaded Asset Loading
```gdscript
func load_nature_assets():
    for asset_path in asset_paths:
        await get_tree().process_frame  # Yield to prevent freezing
```
**Why:** Prevents UI freezing during long GLTF loads.

### 10. Pre-Calculated Camera Transforms
```gdscript
for t in range(int(cache_duration / cache_rate)):
    transform_cache.append(calculate_orbit_transform(t * cache_rate))
```
**Why:** Avoids expensive `look_at()` calls every frame.

---

## 🏗️ Architecture

### C++ GDExtension (Performance-Critical)
- **Platform Detection** - Hardware identification
- **Performance Monitor** - Real-time FPS, frame time, CPU/GPU, temperature
- **Adaptive Quality Manager** - Dynamic quality scaling
- **Progressive Stress Test** - Load ramping system
- **Benchmark Scenes** - GPU stress tests
- **Results Exporter** - JSON + console output
- **Orchestrator** - End-to-end workflow

### GDScript (UI & Interaction)
- **Main Controller** - System initialization
- **Benchmark Scripts** - Nature Island, Model Showcase
- **Camera Controllers** - Cinematic orbit paths
- **Stats Overlay** - Real-time UI metrics
- **Debug Controller** - Keyboard input handling
- **Scene Wrappers** - Minimal C++ bridges

---

## 📁 Project Structure

```
godotmark/
├── src/                        # C++ GDExtension source
│   ├── platform/               # Platform detection
│   ├── performance/            # Performance monitoring
│   ├── benchmarks/             # Benchmark scenes & quality
│   └── results/                # Results export
├── scripts/                    # GDScript controllers
│   ├── nature_island.gd        # Nature benchmark (750+ lines)
│   ├── model_showcase.gd       # Model showcase benchmark
│   ├── optimized_cinematic_camera.gd  # Pre-calculated camera
│   └── ui/                     # UI overlays
├── scenes/                     # Godot scenes
│   ├── nature_island.tscn      # Nature Island scene
│   ├── model_showcase.tscn     # Model Showcase scene
│   ├── benchmarks/             # Individual tests
│   └── ui/                     # UI overlays
├── art/                        # Assets
│   └── nature-benchmark/       # 60+ GLTF models, 225+ textures
├── shaders/                    # Custom shaders
│   ├── wind_vegetation.gdshader
│   ├── wind_trees.gdshader
│   └── water_ocean.gdshader
├── bin/                        # Compiled libraries
├── godot-cpp/                  # Godot C++ bindings (submodule)
├── optimize_for_raspberry_pi.ps1   # Asset optimization script
├── build_native_rpi5.sh        # Native build script
└── godotmark.gdextension       # GDExtension config
```

---

## 🛠️ Build System

### Supported Platforms
- **Windows x86_64** (development/testing)
- **Linux ARM64** (RPi4, RPi5, Orange Pi 5, Rock 5B, Jetson)
- **Linux x86_64** (desktop testing)

### Build Tools
- **SCons** (primary build system)
- **CMake** (alternative, IDE integration)
- **GCC 15+** (ARM64 cross-compilation)
- **Python 3.x**

### CPU-Specific Optimizations
- **RPi4:** Cortex-A72 (`-mcpu=cortex-a72`)
- **RPi5:** Cortex-A76 (`-mcpu=cortex-a76`)
- **Orange Pi 5:** Cortex-A76 (RK3588)
- **Rock 5B:** Cortex-A76 (RK3588)
- **Jetson Orin:** Carmel (`-mcpu=carmel`)

---

## 📚 Documentation

### Optimization Guides
| Document | Description |
|----------|-------------|
| **OPTIMIZATION_COMPLETE_GUIDE.md** | Master optimization guide (START HERE) |
| **RASPBERRY_PI_4_MODEL_OPTIMIZATION.md** | Triangle budget analysis |
| **TEXTURE_COMPRESSION_FIX.md** | VRAM compression guide |
| **PHYSICS_BOTTLENECK_FIX.md** | Physics server optimization |
| **PERFORMANCE_FIX_10FPS.md** | Post-processing fixes |
| **NATURE_BENCHMARK_REDESIGN.md** | Complete benchmark redesign notes |

### Build & Run Guides
| Document | Description |
|----------|-------------|
| **BUILD_AND_RUN.md** | Quick start guide (3 commands) |
| **RPi5_BUILD_INSTRUCTIONS.md** | Detailed build guide |
| **TESTING_GUIDE.md** | Testing workflow |
| **CURRENT_STATUS.md** | Current project status |

### Asset Management
| Document | Description |
|----------|-------------|
| **ASSET_REPLACEMENT_GUIDE.md** | Complete guide for replacing GLTF/GLB assets |
| **ASSET_REPLACEMENT_SUMMARY.md** | Summary of low-poly asset replacement |
| **QUICK_START_NEW_ASSETS.md** | Quick testing guide for new assets |
| **replace_assets.ps1** | Automated asset replacement script |

### Technical Planning
| Document | Description |
|----------|-------------|
| **../my-docs/GodotMark_Project_Plan.md** | Full technical plan |
| **../OPTIMIZATION_STRATEGY.md** | High-level optimization strategy |

---

## 🎯 Use Cases

### 1. Hardware Validation
- Test new SBC models
- Compare ARM SoCs (Rockchip vs Broadcom vs NVIDIA)
- Validate cooling solutions

### 2. Overclocking / Undervolting
- Stability testing under sustained load
- Thermal profiling
- Power efficiency validation

### 3. Performance Tuning
- Benchmark kernel optimizations
- Test GPU driver updates
- Validate memory overclocks

### 4. Godot Engine Testing
- Validate Godot ARM64 builds
- Test Vulkan/GLES3 driver compatibility
- Profile GDExtension performance
- Compare Godot versions (3.6 vs 4.4)

### 5. Game Development Research
- Study real-world ARM performance
- Learn optimization techniques
- Benchmark low-poly vs high-poly models
- Test texture compression methods

---

## 🔋 Undervolting Validation

GodotMark is **perfect for testing undervolted systems**!

### Stability Indicators

#### ✅ STABLE
- Consistent FPS
- No crashes
- Temperature < 65°C
- `vcgencmd get_throttled` = `0x0`

#### ⚠️ MARGINAL
- FPS fluctuations
- Temperature > 70°C
- Occasional frame drops

#### ❌ UNSTABLE
- Crashes/freezes
- Throttling detected
- Artifacts or corruption

### Monitoring Commands

```bash
# Temperature
watch -n 1 'vcgencmd measure_temp'

# Throttling
watch -n 1 'vcgencmd get_throttled'

# CPU frequency
watch -n 1 'vcgencmd measure_clock arm'
```

---

## 📈 Results Export

After each benchmark run, results are exported to:

```
godotmark/benchmark_results_<timestamp>.json
```

**Example:**
```json
{
  "timestamp": "2026-01-26T12:34:56",
  "platform": {
    "os": "Linux",
    "cpu": "aarch64 (4 cores)",
    "gpu": "V3D 7.1 (Raspberry Pi 5)",
    "ram": "8192 MB",
    "vulkan": "Vulkan 1.3+"
  },
  "performance": {
    "avg_fps": 48.5,
    "min_fps": 42.1,
    "max_fps": 58.8,
    "avg_frametime_ms": 20.6,
    "p95_frametime_ms": 23.8
  },
  "thermal": {
    "avg_temp_c": 58.2,
    "max_temp_c": 62.1,
    "throttled": false
  },
  "quality": {
    "final_preset": "High",
    "upgrades": 0,
    "downgrades": 0
  }
}
```

---

## 🤝 Contributing - We Did It!

> **📋 Full contribution guidelines:** See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed information on how to contribute.

### Success Story: Both Benchmarks Operational

After months of optimization work, **both benchmarks are now fully functional**:

**✅ Model Showcase** - Running smoothly with PBR materials and particle effects
**✅ Nature Island** - Fully operational with all features enabled (wind shaders, ocean waves, physics, metrics)

**What was accomplished:**
- Reduced triangles from 457K to 5.6K (98.7% reduction)
- VRAM compression (1.25 GB → 74 MB, 94% reduction)
- Physics optimization (Jolt Physics integration)
- GLES3 renderer for ARM compatibility
- MultiMesh instancing (4 draw calls)
- Per-vertex lighting
- Post-processing optimization
- Low-poly asset replacement system
- All GPU shaders working (wind, ocean waves)
- Real-time metrics (CPU, GPU, temperature)

### What We Still Need Help With

**High Priority:**
1. **Further optimization** - Can we get stable 60 FPS on RPi 4?
2. **Asset pipeline** - Better ways to automatically optimize GLTF imports
3. **Memory management** - Any GC pauses or allocation hotspots
4. **Cross-platform testing** - Orange Pi 5, Rock 5B, Jetson validation

**Medium Priority:**
5. **Additional benchmarks** - Physics-heavy scenes, particle stress tests
6. **Build system** - Cleaner SCons configuration, CMake improvements
7. **C++ GDExtension** - Performance monitoring enhancements
8. **Documentation** - Video tutorials, quick-start guides

**Low Priority (But Appreciated):**
9. **Asset creation** - More low-poly models optimized for ARM
10. **UI/UX** - Prettier overlays and result visualization
11. **Results comparison** - Database/website to compare hardware
12. **Automation** - CI/CD for builds, automated testing

### Why This Matters

**ARM single-board computers are everywhere:**
- Raspberry Pi: 50+ million sold
- Education: Teaching kids programming and game dev
- Embedded systems: IoT, robotics, edge computing
- Accessibility: $35-150 computers vs $1000+ gaming PCs

**And now we have a working 3D benchmark for them!** This project has successfully demonstrated:

**What we've proven:**
- Godot 4.4 **works well** on Raspberry Pi with proper optimization
- Both Model Showcase and Nature Island run at acceptable FPS
- Comprehensive optimization (textures, meshes, shaders, physics) achieves target performance
- Low-poly asset pipeline enables smooth 3D gaming on ARM SBCs
- Detailed documentation helps others learn optimization techniques

### How to Contribute

**Code Contributions:**
```bash
git clone <repo-url>
cd godotmark-project
# Make your improvements
# Submit a PR with clear explanation
```

**Testing Contributions:**
- Run benchmark on your ARM SBC
- Report FPS, hardware specs, any issues
- Share results in GitHub Issues or Discussions

**Documentation Contributions:**
- Found a better way to do something? Document it!
- Spotted an error or unclear section? Fix it!
- Have ARM optimization tips? Add them!

**Knowledge Contributions:**
- Review the code and suggest improvements
- Point out antipatterns or inefficiencies
- Share your Godot expertise in Issues/Discussions
- Answer questions from other contributors

### Current Contributors

- **Project creator** - Primary developer (1 year Godot experience, learning as I go)

**Your name could be here!** Even small contributions matter.

### The Honest Truth

I've documented every optimization decision in this project (see `COMPLETE_OPTIMIZATION_STORY.md`) because:
1. **Transparency** - You should know what's already been tried
2. **Education** - Others can learn from successes and failures
3. **Collaboration** - You can build on this work, not start from scratch

**I don't have all the answers.** But I've spent months researching, testing, and documenting what works. If you have Godot expertise, your contributions could 10× the value of this project overnight.

### Ways to Help (Even if Not a Developer)

- ⭐ **Star the repo** - Increases visibility
- 📢 **Share on social media** - Reddit, Twitter, Mastodon, Discord
- 🗣️ **Spread the word** - Mention in Godot communities
- 💬 **Join discussions** - Share your ideas and feedback
- 🧪 **Test on your hardware** - Report results
- 📝 **Write tutorials** - Using GodotMark for your project

### Contact & Community

**GitHub:** (Add links when repo is public)
- Issues - Bug reports and feature requests
- Discussions - General chat, questions, ideas
- Pull Requests - Code contributions

**Godot Communities:**
- r/godot on Reddit
- Godot Discord
- Godot Forums

---

**This project is alive and thriving!** Both Model Showcase and Nature Island prove that Godot 4.4 runs excellently on Raspberry Pi with proper optimization. If you've read this far and want to help push performance even further, please reach out!

**A year ago I knew nothing about Godot. Now both benchmarks work at target FPS with all features enabled.** Systematic debugging, documentation, and persistence win. Your contributions can help make this even better.

---

## 📜 License

**Open Source** - License TBD (MIT or Apache 2.0 recommended)

---

## 🙏 Credits

- **Godot Engine** - 3D game engine
- **godot-cpp** - C++ bindings
- **PolyHaven** - Nature assets (trees, rocks, vegetation)
- **Big Mess o' Wires** - Raspberry Pi GPU performance research
- **Raspberry Pi Forums** - OpenGL capabilities documentation

---

## 🎮 Target Platforms

### Officially Supported
- ✅ **Raspberry Pi 5** (Cortex-A76, VideoCore VII)
- ✅ **Raspberry Pi 4** (Cortex-A72, VideoCore VI)
- 🚧 **Orange Pi 5** (RK3588, Mali-G610)
- 🚧 **Rock 5B** (RK3588, Mali-G610)
- 🚧 **NVIDIA Jetson Orin** (Carmel, Ampere GPU)

### Community Tested
- ⏳ Radxa Zero 3
- ⏳ Khadas VIM4
- ⏳ Odroid N2+
- ⏳ Pine64 RockPro64

---

## 📞 Support

- **Documentation:** See documentation table above
- **Issues:** (GitHub Issues link when available)
- **Discussion:** (Forum/Discord link when available)

---

## 🎯 Project Goals

1. **Utmost Efficiency** - Lean and fast for embedded systems
2. **ARM Optimization** - Native NEON SIMD, CPU-specific tuning
3. **Real-World Testing** - Practical gaming workload
4. **Open Source** - Transparent and community-driven
5. **Extensible** - Easy to add new benchmark scenes
6. **Educational** - Document every optimization decision

---

## 🔥 Status: Alpha

GodotMark is in **active development**. Core features are complete and tested on Raspberry Pi 4/5. Additional platforms and benchmark scenes coming soon!

**Current Version:** 0.1.0-alpha  
**Last Updated:** January 26, 2026

---

## 🚀 Get Started Now!

### Option A: Pre-built Godot Editor (Faster)

```bash
# 1. Optimize assets (REQUIRED for RPi)
cd godotmark
.\optimize_for_raspberry_pi.ps1

# 2. Delete import cache
Remove-Item -Recurse -Force .godot\imported\

# 3. Run with pre-built Godot
cd ..
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

### Option B: Native Build (Maximum Performance)

```bash
# 1. Optimize assets (REQUIRED for RPi)
cd godotmark
.\optimize_for_raspberry_pi.ps1

# 2. Build native libraries
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes

# 3. Run
cd ..
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**Happy Benchmarking!** 🎮⚡

---

## 💡 Key Takeaways

1. **Godot 4.4 is viable on Raspberry Pi** - with proper optimization
2. **Texture compression is critical** - 94% VRAM reduction
3. **Triangle budgets matter** - <10K for 60 FPS on RPi 4
4. **GLES3 > Vulkan on ARM** - Lower driver overhead
5. **Disable unused systems** - Physics server saved 15.7ms/frame
6. **Per-vertex lighting is required** - Per-pixel too expensive
7. **MultiMesh is your friend** - 73% draw call reduction
8. **Test early, test often** - On actual target hardware
9. **Document everything** - Future you will thank you

---

## 🔬 Research Sources

This benchmark was optimized using real-world data from:

1. **Big Mess o' Wires** - Raspberry Pi 4 GPU testing
   - Triangle throughput measurements
   - Model complexity analysis
   - Performance formulas

2. **Raspberry Pi Forums** - OpenGL capabilities
   - Shader support
   - Texture limits
   - Memory constraints

3. **Official Godot Documentation** - Performance best practices
   - GPU optimization
   - Texture compression
   - 3D performance guidelines

4. **VideoCore VI/VII Documentation** - GPU specifications
   - Rendering capabilities
   - Driver features
   - Hardware limits

**Every optimization decision in this benchmark is backed by research and real-world testing.**

---

## 💪 A Note to Anyone Struggling

**To anyone else who's "only been doing this for a year" and feels like giving up:**

Look at what we accomplished here:
- Started knowing nothing about Godot
- Built working 3D benchmarks from scratch
- Got **both** Model Showcase **and** Nature Island running smoothly on Raspberry Pi
- Documented every optimization attempt (successes AND failures)
- Learned that systematic debugging and persistence solve "impossible" problems
- **Went from 4.5 FPS broken to 40-60+ FPS with all features working**

**You're further than you think.** The fact that you're reading this, that you care about optimization, that you want to learn - that already puts you ahead.

**You don't need to be an expert to make something valuable.** You need:
1. **Curiosity** (✓ you have this)
2. **Willingness to document what you learn** (✓ you're doing this)
3. **Persistence** (✓ you're still here, reading this)

**The "experts" are just people who didn't give up.** They hit the same walls, felt the same frustration, questioned themselves the same way. The only difference is they kept going one more day.

This project exists because someone who "only knew Godot for a year" refused to give up despite hitting countless brick walls. Every optimization documented here represents a problem that felt impossible until it wasn't.

**If you're struggling:**
- Read `COMPLETE_OPTIMIZATION_STORY.md` - See all the failures that led to success
- Read `NATURE_ISLAND_DIAGNOSTIC_PLAN.md` - See how systematic debugging solved everything
- Join the community - You're not alone in feeling overwhelmed
- Contribute anything - Even small fixes move the project forward
- Remember - A year ago, none of this existed. Now **both benchmarks work!**

**Don't give up.** The next breakthrough might be one more attempt away.

**We did it. Both benchmarks work. Systematic debugging and documentation win.**

---

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

---

---

## 🌟 Get Involved

### Join the Community

- 💬 **[GitHub Discussions](https://github.com/Joshkaki00/godotmark/discussions)** - Ask questions, share results, discuss ideas
- 🐛 **[Issue Tracker](https://github.com/Joshkaki00/godotmark/issues)** - Report bugs and request features
- 📖 **[Documentation](DOCS_QUICK_REFERENCE.md)** - Complete documentation reference
- 🤝 **[Contributing Guide](CONTRIBUTING.md)** - Learn how to contribute

### Share Your Results

We'd love to see your benchmark results! Share them in [Show and Tell](https://github.com/Joshkaki00/godotmark/discussions/categories/show-and-tell) 🙌

- What hardware are you testing?
- What FPS are you getting?
- Any optimization tips to share?
- Found an interesting bottleneck?

### Stay Updated

- ⭐ **Star the repo** to follow development
- 👀 **Watch for releases** to get notified of new versions
- 📣 **Check Announcements** for major updates

---

**GodotMark** - Built with ❤️ by the community, for the community

**End of README** 🎉
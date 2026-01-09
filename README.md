# GodotMark - 3D Gaming Benchmark for ARM SBCs

**Open-source benchmark for Raspberry Pi, Orange Pi, Rock 5B, and other ARM single-board computers**

Built with **Godot 4.4**, **C++ GDExtension**, and **Jolt Physics**

---

## 🎯 Overview

GodotMark is a **comprehensive 3D gaming benchmark** designed specifically for ARM single-board computers (SBCs). It pushes hardware to its limits while remaining efficient and lean for embedded systems.

**Key Features:**
- ✅ Real-time performance monitoring (FPS, CPU, GPU, temperature)
- ✅ Adaptive quality scaling (5 presets: Potato → Ultra)
- ✅ Platform detection (CPU, GPU, RAM, Vulkan version)
- ✅ Progressive stress testing (60-second default, 10s quick mode)
- ✅ Results export (JSON + console)
- ✅ Hardware-specific optimizations (RPi4, RPi5, Orange Pi 5, etc.)
- ✅ Undervolting validation (thermal + stability testing)

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

### 2. Build the Benchmark

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```

**Build time:** ~10-20 minutes (first time)

### 3. Run the Benchmark

```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**Note:** GodotMark will automatically check your driver configuration on startup!

### 4. Use Debug Controls

| Key | Action |
|-----|--------|
| **Space** | Pause/Resume |
| **Q / E** | Quality Down / Up |
| **T** | Toggle Quick Test (10s/60s) |
| **V** | Verbose Logging |
| **R** | Reset |
| **Esc** | Exit |

---

## 📊 Performance Expectations

### Raspberry Pi 5 (Undervolted)
- **FPS:** 20-35 (High/Ultra)
- **Temperature:** 50-60°C
- **CPU Usage:** 70-90%
- **GPU Usage:** 80-95%

### Raspberry Pi 5 (Stock)
- **FPS:** 25-40 (Ultra)
- **Temperature:** 60-70°C
- **CPU Usage:** 70-90%
- **GPU Usage:** 85-100%

### Raspberry Pi 4
- **FPS:** 15-25 (Medium/High)
- **Temperature:** 55-70°C
- **CPU Usage:** 90-100%
- **GPU Usage:** 95-100%

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
- **Stats Overlay** - Real-time UI metrics
- **Debug Controller** - Keyboard input handling
- **Scene Wrappers** - Minimal C++ bridges

---

## 🎮 Quality Presets

| Preset | Texture | Shadows | Particles | Physics | FPS Target |
|--------|---------|---------|-----------|---------|------------|
| **Potato** | 512px | Off | 200 | 50 | 60+ |
| **Low** | 1024px | Low | 500 | 100 | 45+ |
| **Medium** | 2048px | Medium | 2000 | 500 | 30+ |
| **High** | 2048px | High | 5000 | 1000 | 25+ |
| **Ultra** | 4096px | High | 10000 | 2000 | 20+ |

**Adaptive Quality:** Automatically adjusts preset based on sustained FPS over 2 seconds.

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

## 📁 Project Structure

```
godotmark/
├── src/                        # C++ GDExtension source
│   ├── platform/               # Platform detection
│   ├── performance/            # Performance monitoring
│   ├── benchmarks/             # Benchmark scenes & quality
│   └── results/                # Results export
├── scripts/                    # GDScript UI controllers
│   ├── main.gd                 # Main entry point
│   ├── debug_controller.gd     # Keyboard controls
│   └── ui/stats_overlay.gd     # Stats UI
├── scenes/                     # Godot scenes
│   ├── main.tscn               # Main scene
│   ├── benchmarks/             # Benchmark scenes
│   └── ui/                     # UI overlays
├── bin/                        # Compiled libraries
├── godot-cpp/                  # Godot C++ bindings (submodule)
├── SConstruct                  # SCons build config
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

| Document | Description |
|----------|-------------|
| **BUILD_AND_RUN.md** | Quick start guide (3 commands) |
| **RPi5_BUILD_INSTRUCTIONS.md** | Detailed build guide |
| **TESTING_GUIDE.md** | Testing workflow |
| **CURRENT_STATUS.md** | Current project status |
| **../my-docs/GodotMark_Project_Plan.md** | Full technical plan |

---

## 🧪 Benchmark Scenes (Roadmap)

1. ✅ **GPU Basics** - Geometry and PBR materials
2. 🚧 **Physics Simulation** - Jolt Physics stress test
3. 🚧 **Particle Systems** - GPU particle effects
4. 🚧 **Lighting & Shadows** - Dynamic lights + shadowmaps
5. 🚧 **Post-Processing** - Bloom, SSAO, depth of field
6. 🚧 **Combined Stress** - All systems at once

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
- Test Vulkan driver compatibility
- Profile GDExtension performance

---

## 🔧 Advanced Configuration

### Custom Build Flags

```bash
# Maximum performance (larger binary)
./build_native_rpi5.sh template_release rpi5 no

# Debug build (verbose logging)
./build_native_rpi5.sh template_debug rpi5 no

# Generic ARM64 (non-RPi)
scons platform=linux arch=arm64 target=template_release cpu=generic -j4
```

### Verbose Logging

Press **V** in-game or set in code:

```cpp
PlatformDetector::set_verbose_logging(true);
PerformanceMonitor::set_verbose_logging(true);
AdaptiveQualityManager::set_verbose_logging(true);
```

### Quick Test Mode

Press **T** in-game or set programmatically:

```cpp
stress_test->set_quick_test_mode(true, 10.0);  // 10-second test
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
  "timestamp": "2026-01-07T12:34:56",
  "platform": {
    "os": "Linux",
    "cpu": "aarch64 (4 cores)",
    "gpu": "V3D 7.1 (Raspberry Pi 5)",
    "ram": "8192 MB",
    "vulkan": "Vulkan 1.3+"
  },
  "performance": {
    "avg_fps": 28.5,
    "min_fps": 22.1,
    "max_fps": 35.8,
    "avg_frametime_ms": 35.1,
    "p95_frametime_ms": 45.2
  },
  "thermal": {
    "avg_temp_c": 58.2,
    "max_temp_c": 62.1,
    "throttled": false
  },
  "quality": {
    "final_preset": "High",
    "upgrades": 2,
    "downgrades": 0
  }
}
```

---

## 🤝 Contributing

GodotMark is **open source**! Contributions welcome:

- 🐛 Bug reports
- 🎮 New benchmark scenes
- 🔧 Hardware-specific optimizations
- 📝 Documentation improvements
- 🧪 Testing on new platforms

---

## 📜 License

**Open Source** - License TBD (MIT or Apache 2.0 recommended)

---

## 🙏 Credits

- **Godot Engine** - 3D game engine
- **godot-cpp** - C++ bindings
- **Jolt Physics** - ARM64-optimized physics
- **PolyHaven** - HDR environment maps and textures (if used)

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

- **Documentation:** See `docs/` folder
- **Issues:** (GitHub Issues link when available)
- **Discussion:** (Forum/Discord link when available)

---

## 🎯 Project Goals

1. **Utmost Efficiency** - Lean and fast for embedded systems
2. **ARM Optimization** - Native NEON SIMD, CPU-specific tuning
3. **Real-World Testing** - Practical gaming workload
4. **Open Source** - Transparent and community-driven
5. **Extensible** - Easy to add new benchmark scenes

---

## 🔥 Status: Alpha

GodotMark is in **active development**. Core features are complete and tested on Raspberry Pi 5. Additional platforms and benchmark scenes coming soon!

**Current Version:** 0.1.0-alpha  
**Last Updated:** January 7, 2026

---

## 🚀 Get Started Now!

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```

**Then run:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**Happy Benchmarking!** 🎮⚡


# GodotMark - Build & Run Guide for RPi5

## 🚀 Quick Start (4 Steps)

**On your Raspberry Pi 5, run these commands:**

```bash
# 0. Install V3D driver stack (REQUIRED - do this first!)
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
sudo ./install_v3d_stack.sh
# Follow prompts, reboot if requested, then continue:

# 1. Navigate to project
cd /mnt/exfat_drive/dev/godotmark-project/godotmark

# 2. Build the ARM64 library (10-20 min first time)
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes

# 3. Run the benchmark
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**That's it!** 🎉

### ⚠️ IMPORTANT: V3D Driver Stack Required!

**Step 0 is CRITICAL!** Without the V3D driver stack:
- ❌ You'll use software rendering (10x slower)
- ❌ Benchmark results will be inaccurate
- ❌ FPS will be < 5 instead of 20-40
- ✅ GodotMark will detect this and warn you automatically

**Verify your driver setup:**
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
./check_v3d_setup.sh
```

---

## 📋 What Each Step Does

### Step 1: Navigate to Project
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
```
- Goes to the GodotMark source directory
- This is where the C++ code and build scripts live

### Step 2: Build the ARM64 Library
```bash
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```
- Installs dependencies if needed (scons, g++, python3)
- Initializes godot-cpp submodule
- Compiles C++ code optimized for RPi5 Cortex-A76
- Creates: `bin/libgodotmark.linux.template_release.arm64.so`
- **Build time:** ~10-20 minutes (first time), ~1-2 min (incremental)

### Step 3: Run the Benchmark
```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```
- Launches Godot Engine with the GodotMark project
- Loads the ARM64 GDExtension library
- Starts the benchmark automatically

---

## 🎮 Using the Benchmark

### Debug Controls (Keyboard)

| Key | Action | Description |
|-----|--------|-------------|
| **Space** | Pause/Resume | Pause the benchmark to inspect stats |
| **Q** | Quality Down | Manually decrease quality preset |
| **E** | Quality Up | Manually increase quality preset |
| **T** | Quick Test | Toggle 10s quick test (default: 60s) |
| **V** | Verbose | Toggle verbose logging for debugging |
| **R** | Reset | Reset the benchmark to start over |
| **Esc** | Exit | Close the benchmark |

### Quality Presets

The benchmark will automatically adjust quality based on performance:

| Preset | Texture | Shadows | Particles | Physics | Target FPS |
|--------|---------|---------|-----------|---------|------------|
| **Potato** | 512px | Off | 200 | 50 | 60+ |
| **Low** | 1024px | Low | 500 | 100 | 45+ |
| **Medium** | 2048px | Medium | 2000 | 500 | 30+ |
| **High** | 2048px | High | 5000 | 1000 | 25+ |
| **Ultra** | 4096px | High | 10000 | 2000 | 20+ |

---

## 📊 What to Expect (Undervolted RPi5)

### Performance
- **Initial FPS:** 30-40 FPS (Medium quality)
- **Stable FPS:** 20-35 FPS (will auto-adjust to Ultra)
- **Frame Time:** 30-50ms
- **Quality:** Should settle on High or Ultra

### Thermals
- **Idle:** 40-45°C
- **Under Load:** 50-60°C (with active cooling)
- **Throttle Point:** ~80°C (should NOT reach this)

### Monitoring
The UI overlay shows real-time stats:
- **FPS** (green = good, yellow = marginal, red = poor)
- **Frame Time** (milliseconds per frame)
- **CPU Usage** (%)
- **GPU Usage** (%)
- **Temperature** (°C)
- **Throttling Warning** (if detected)
- **Current Quality Preset**
- **Progress Bar** (60-second test)

---

## 🔍 Verification

### Check Build Success
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x check_build.sh
./check_build.sh
```

**Expected output:**
```
✅ Release library found:
-rwxr-xr-x 1 pi pi 1.5M Jan  7 12:34 bin/libgodotmark.linux.template_release.arm64.so

File type:
bin/libgodotmark.linux.template_release.arm64.so: ELF 64-bit LSB shared object, ARM aarch64

✅ Ready to run!
```

### Check Godot Output (First Run)

**Good output:**
```
[GodotMark] Extension initialized
[PlatformDetector] Initializing...

========================================
GodotMark System Information
========================================
Platform: Linux
CPU: aarch64 (4 cores)
RAM: 8192 MB
GPU: V3D 7.1 (Raspberry Pi 5)
Vulkan: Vulkan 1.3+
========================================

[PerformanceMonitor] FPS: 35.2 (avg: 34.8)
[AdaptiveQuality] Applied preset: Medium
```

**Bad output (library not built):**
```
ERROR: GDExtension dynamic library not found
```
→ **Solution:** Run step 2 again (build script)

---

## 🛠️ Troubleshooting

### Build Issues

#### "scons: command not found"
```bash
sudo apt update
sudo apt install -y scons build-essential python3 git
```

#### "godot-cpp not found"
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
git submodule update --init --recursive
```

#### "Out of memory" during build
```bash
# Option 1: Reduce parallel jobs
scons platform=linux arch=arm64 target=template_release cpu=rpi5 optimize_size=yes -j2

# Option 2: Enable more swap
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile  # Set CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Then retry build
./build_native_rpi5.sh template_release rpi5 yes
```

### Runtime Issues

#### "GDExtension dynamic library not found"
**Cause:** Library not built or in wrong location

**Solution:**
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
./check_build.sh  # Verify build
./build_native_rpi5.sh template_release rpi5 yes  # Rebuild if needed
```

#### Black Screen or Crash
**Cause:** Insufficient memory or GPU driver issue

**Solution:**
- Close other programs
- Check GPU memory allocation: `sudo raspi-config` → Performance Options → GPU Memory → Set to 256MB
- Update system: `sudo apt update && sudo apt upgrade`

#### Low FPS (< 15 FPS)
**Cause:** Undervolting too aggressive, thermal throttling, or background processes

**Solution:**
- Check temperature: `vcgencmd measure_temp`
- Check throttling: `vcgencmd get_throttled` (should be `0x0`)
- Kill background processes: `top` (press `k` to kill)
- Reduce undervolt slightly

#### ALSA Audio Warnings
```
ALSA lib pcm.c:8772:(snd_pcm_recover) underrun occurred
```
**Status:** Harmless warnings, audio buffer underruns (don't affect benchmark)
**Solution:** Ignore or disable audio in Godot project settings

---

## 🔋 Undervolting Validation

This benchmark is **perfect** for testing your undervolt stability!

### What to Watch For

#### ✅ STABLE (Good undervolt)
- FPS stays consistent
- No crashes or freezes
- Temperature below 65°C
- `vcgencmd get_throttled` returns `0x0`
- Completes full 60-second test

#### ⚠️ MARGINAL (On the edge)
- FPS fluctuates significantly
- Occasional frame drops
- Temperature spikes above 70°C
- Warning: "under-voltage detected"

#### ❌ UNSTABLE (Undervolt too aggressive)
- Crashes or freezes
- Black screen
- `vcgencmd get_throttled` shows `0x50000` (throttled)
- System reboots
- Corruption or artifacts

### Monitoring Commands

```bash
# Temperature (run in another terminal)
watch -n 1 'vcgencmd measure_temp'

# Throttling status
watch -n 1 'vcgencmd get_throttled'

# CPU frequency
watch -n 1 'vcgencmd measure_clock arm'

# Voltage
vcgencmd measure_volts
```

---

## 📈 Results Export

After the benchmark completes, check for results:

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
cat benchmark_results_*.json
```

**Example output:**
```json
{
  "timestamp": "2026-01-07T12:34:56",
  "platform": {
    "os": "Linux",
    "cpu": "aarch64 (4 cores)",
    "gpu": "V3D 7.1",
    "ram": "8192 MB"
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
  }
}
```

---

## 🎯 Next Steps

After running successfully:

1. ✅ **Run multiple times** to confirm stability
2. 📊 **Compare results** at different undervolt levels
3. 🔧 **Adjust undervolt** based on results
4. 🌡️ **Test different cooling solutions**
5. ⚡ **Measure power consumption** (if you have tools)

---

## 📚 Additional Documentation

- **Detailed Build Guide:** `RPi5_BUILD_INSTRUCTIONS.md`
- **Testing Guide:** `TESTING_GUIDE.md`
- **Current Status:** `CURRENT_STATUS.md`
- **Project Plan:** `../my-docs/GodotMark_Project_Plan.md`

---

## ✅ Summary Checklist

```
□ Navigate to project directory
□ Run build script (./build_native_rpi5.sh)
□ Verify build success (./check_build.sh)
□ Run benchmark
□ Monitor temperature and FPS
□ Complete 60-second test
□ Check for crashes or throttling
□ Export results (JSON)
```

---

## 💡 Pro Tips

1. **First Run:** Use quick test mode (press `T`) for 10-second tests
2. **Verbose Logging:** Press `V` to see detailed C++ logs
3. **Manual Quality:** Press `Q`/`E` to test specific quality presets
4. **Thermal Testing:** Run multiple consecutive tests to check heat soak
5. **Comparison:** Run at stock voltage first, then with undervolt

---

## 🚀 Ready to Build!

**Copy-paste this into your RPi5 terminal:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark && \
chmod +x build_native_rpi5.sh && \
./build_native_rpi5.sh template_release rpi5 yes
```

**Then run:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project && \
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

---

**Good luck with your undervolting validation!** 🔋⚡🎮


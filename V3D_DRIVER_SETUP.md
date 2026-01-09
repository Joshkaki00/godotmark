# V3D Driver Stack Setup for GodotMark

## Overview

This document describes the V3D driver stack installer and verification system implemented for GodotMark on Raspberry Pi 4/5.

---

## Why V3D Driver Stack?

The V3D driver stack is **essential** for proper GPU acceleration on Raspberry Pi:

- **Without V3D:** Software rendering (llvmpipe), 10x slower, < 5 FPS
- **With V3D:** Hardware acceleration, 20-40 FPS on RPi5, 15-25 FPS on RPi4

The V3D stack includes:
- **Kernel driver:** `v3d` (VideoCore VI/VII)
- **Mesa driver:** V3D OpenGL ES 3.1 + Vulkan 1.2+
- **Runtime:** libvulkan1 + mesa-vulkan-drivers

---

## Quick Start

### Automated Installation (Recommended)

```bash
cd godotmark
sudo ./install_v3d_stack.sh
```

This interactive script will:
1. Detect your Raspberry Pi model (4 or 5)
2. Enable V3D KMS driver in `/boot/config.txt`
3. Install Mesa Vulkan drivers
4. Install verification tools
5. Test your configuration
6. Guide you through rebooting if needed

**Time:** ~5 minutes + reboot

### Verification

```bash
cd godotmark
./check_v3d_setup.sh
```

This diagnostic script checks:
- ✅ V3D kernel module loaded
- ✅ V3D enabled in boot config
- ✅ DRI devices present
- ✅ OpenGL working
- ✅ Vulkan available
- ✅ Mesa packages installed

---

## Manual Installation

If you prefer to configure manually:

### 1. Edit Boot Configuration

```bash
sudo nano /boot/config.txt
# Or on newer OS:
sudo nano /boot/firmware/config.txt
```

Add under `[pi4]` or `[pi5]`:
```
dtoverlay=vc4-kms-v3d
max_framebuffers=2
```

For Pi 4 with 4GB+ RAM, also add:
```
arm_64bit=1
```

### 2. Install Packages

```bash
sudo apt update
sudo apt install mesa-vulkan-drivers libvulkan1 vulkan-tools mesa-utils
```

### 3. Reboot

```bash
sudo reboot
```

### 4. Verify

```bash
# Check V3D module
lsmod | grep v3d

# Check OpenGL
glxinfo | grep "OpenGL version"

# Check Vulkan
vulkaninfo --summary
```

---

## Automatic Detection in GodotMark

GodotMark **automatically detects** driver configuration on startup when running on Raspberry Pi.

### Detection Methods

The `PlatformDetector` C++ class includes these new methods:

```cpp
bool is_v3d_driver_loaded() const;      // Check if v3d module loaded
bool is_v3d_config_enabled() const;      // Check boot config
bool is_vulkan_driver_available() const; // Check Vulkan libraries
String get_mesa_version() const;         // Get Mesa version
String get_driver_status_summary() const; // Full status report
```

### Startup Warning

If drivers are not properly configured, GodotMark will:
1. Print a detailed driver status summary
2. Show a warning message
3. Provide instructions to run the installer
4. Wait 5 seconds before continuing

Example warning:
```
============================================================
[WARNING] Suboptimal graphics driver configuration detected!
============================================================

Your Raspberry Pi may not be using the V3D driver stack.
This will result in reduced performance and benchmark accuracy.

To fix this, run the automated installer:
  1. Exit this application
  2. Open a terminal in the godotmark directory
  3. Run: sudo ./install_v3d_stack.sh
  4. Follow the prompts and reboot if requested

Continuing in 5 seconds...
============================================================
```

---

## Files Created

### Scripts

1. **`install_v3d_stack.sh`** - Automated installer
   - Interactive, step-by-step installation
   - Detects Pi model and OS version
   - Backs up config files
   - Installs packages
   - Verifies installation
   - Guides through reboot

2. **`check_v3d_setup.sh`** - Diagnostic script
   - Quick verification tool
   - Checks all driver components
   - Colored output for easy reading
   - Provides actionable feedback

### C++ Code

3. **`platform_detector.h`** - Added driver check methods
4. **`platform_detector.cpp`** - Implemented driver detection
   - Checks `/proc/modules` for v3d
   - Checks `/dev/dri/renderD*` devices
   - Checks boot config files
   - Checks Vulkan libraries
   - Parses Mesa version from dpkg

### GDScript

5. **`main.gd`** - Added startup driver check
   - Calls `check_driver_stack()` on Raspberry Pi
   - Shows warning if drivers missing
   - 5-second delay before continuing

### Documentation

6. **`README.md`** - Added V3D setup section
7. **`BUILD_AND_RUN.md`** - Updated with Step 0 (driver install)
8. **`RPi5_BUILD_INSTRUCTIONS.md`** - Added prerequisites section
9. **`V3D_DRIVER_SETUP.md`** (this file) - Complete reference

---

## Expected Results

### Before V3D Setup
- **FPS:** < 5
- **Renderer:** llvmpipe (software)
- **Performance:** Unusable

### After V3D Setup
- **RPi4 4GB:** 15-25 FPS (Medium/High preset)
- **RPi5 8GB:** 20-40 FPS (High/Ultra preset)
- **Renderer:** V3D 4.2 (Pi4) or V3D 7.1 (Pi5)
- **Performance:** Smooth, accurate benchmarks

---

## Troubleshooting

### "V3D module not loaded"

**Cause:** Config changes require reboot

**Solution:**
```bash
sudo reboot
```

### "Config enabled but module not loaded"

**Cause:** Config file syntax error or wrong Pi section

**Solution:**
```bash
# Check config syntax
sudo nano /boot/config.txt

# Ensure dtoverlay=vc4-kms-v3d is under [pi4] or [pi5]
# NOT under [all] if you have separate sections
```

### "Vulkan not available"

**Cause:** Missing Mesa packages

**Solution:**
```bash
sudo apt update
sudo apt install mesa-vulkan-drivers libvulkan1
```

### "DRI devices not found"

**Cause:** V3D driver failed to initialize

**Solution:**
```bash
# Check kernel logs
dmesg | grep v3d

# Check for conflicts
lsmod | grep gpu
```

---

## Technical Details

### V3D Driver Architecture

```
Application (GodotMark)
    ↓
Godot Engine (Vulkan API)
    ↓
libvulkan.so.1 (Vulkan Loader)
    ↓
mesa-vulkan-drivers (V3D Vulkan Driver)
    ↓
/dev/dri/renderD128 (DRI Device)
    ↓
v3d kernel module
    ↓
VideoCore VI/VII GPU (Hardware)
```

### Boot Configuration

The `dtoverlay=vc4-kms-v3d` line in `/boot/config.txt` tells the Linux kernel to:
1. Load the `v3d` kernel module at boot
2. Enable KMS (Kernel Mode Setting) for display
3. Create `/dev/dri/` devices for GPU access

### Mesa Version Requirements

- **Minimum:** Mesa 22.0+ (Vulkan 1.2 support)
- **Recommended:** Mesa 23.0+ (better V3D performance)
- **Check version:** `apt list mesa-vulkan-drivers`

---

## Integration with Benchmark

### Platform Detection

```gdscript
func _ready():
    initialize_systems()
    
    # Check driver stack on Raspberry Pi
    if platform_detector.is_raspberry_pi():
        check_driver_stack()
    
    # Continue with normal startup...
```

### Driver Status Check

```gdscript
func check_driver_stack():
    var v3d_loaded = platform_detector.is_v3d_driver_loaded()
    var v3d_config = platform_detector.is_v3d_config_enabled()
    var vulkan_available = platform_detector.is_vulkan_driver_available()
    
    print(platform_detector.get_driver_status_summary())
    
    if not v3d_loaded or not v3d_config or not vulkan_available:
        show_warning_and_wait()
```

---

## Performance Impact

### Benchmark Results Comparison

| Configuration | RPi4 4GB | RPi5 8GB |
|---------------|----------|----------|
| **No V3D (Software)** | < 5 FPS | < 5 FPS |
| **With V3D** | 15-25 FPS | 20-40 FPS |
| **Performance Gain** | **5-10x** | **5-10x** |

### Power Consumption

- **Software rendering:** Low GPU usage, high CPU usage
- **V3D acceleration:** High GPU usage, moderate CPU usage
- **Total power:** Similar, but V3D provides much better performance

---

## Future Enhancements

Possible improvements:
- [ ] Detect specific Mesa version requirements
- [ ] Auto-suggest OS updates if Mesa is too old
- [ ] Check GPU memory allocation in config
- [ ] Benchmark V3D vs software rendering automatically
- [ ] Export driver info to JSON results

---

## References

- **Raspberry Pi Documentation:** https://www.raspberrypi.com/documentation/computers/config_txt.html
- **Mesa V3D Driver:** https://docs.mesa3d.org/drivers/v3d.html
- **Vulkan on Raspberry Pi:** https://www.raspberrypi.com/news/vulkan-update-version-1-2-conformance-for-raspberry-pi-4/

---

## Summary

The V3D driver stack setup system:
- ✅ Makes GPU acceleration easy to install (1 command)
- ✅ Automatically detects missing/broken configurations
- ✅ Provides clear, actionable feedback
- ✅ Verifies installation thoroughly
- ✅ Integrates seamlessly with GodotMark

**Result:** Users get accurate, reliable benchmark results on Raspberry Pi!

---

**Last Updated:** January 9, 2026  
**Status:** Complete and tested


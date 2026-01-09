# Building GodotMark Natively on Raspberry Pi 5

## Quick Start (On Your RPi5)

### 1. Navigate to Project
```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
```

### 2. Make Build Script Executable
```bash
chmod +x build_native_rpi5.sh
```

### 3. Build (Recommended for Undervolted RPi5)
```bash
./build_native_rpi5.sh template_release rpi5 yes
```

**This will:**
- ✅ Check and install dependencies (scons, g++, python3)
- ✅ Initialize godot-cpp submodule
- ✅ Build optimized for RPi5 Cortex-A76
- ✅ Size optimization enabled (best for undervolted systems)
- ✅ Use all CPU cores for faster build

---

## Build Options

### Option 1: Release Build (Recommended)
**Best for benchmarking and stability testing:**
```bash
./build_native_rpi5.sh template_release rpi5 yes
```

**Produces:**
- `bin/libgodotmark.linux.template_release.arm64.so`
- ~1.5 MB (with size optimization)
- Maximum performance + thermal efficiency
- Perfect for undervolted RPi5

---

### Option 2: Debug Build
**For troubleshooting issues:**
```bash
./build_native_rpi5.sh template_debug rpi5 no
```

**Produces:**
- `bin/libgodotmark.linux.template_debug.arm64.so`
- ~5-6 MB (includes debug symbols)
- Verbose logging available
- Slower performance (~50% slower than release)

---

### Option 3: Maximum Performance (No Size Optimization)
**For standard RPi5 with adequate cooling:**
```bash
./build_native_rpi5.sh template_release rpi5 no
```

**Produces:**
- `bin/libgodotmark.linux.template_release.arm64.so`
- ~2-3 MB
- Maximum FPS, higher power draw
- May generate more heat

---

## Build Time

| CPU Cores | Clean Build Time | Incremental Build |
|-----------|------------------|-------------------|
| 4 cores (RPi5) | ~10-20 minutes | ~1-2 minutes |

**Tips:**
- First build takes longer (compiles godot-cpp)
- Subsequent builds are much faster
- Use `ccache` to speed up repeated builds

---

## Clean Build

**If you need to rebuild everything:**
```bash
./build_native_rpi5.sh clean
scons -c
rm -rf bin/*.so
```

**Then rebuild:**
```bash
./build_native_rpi5.sh template_release rpi5 yes
```

---

## Troubleshooting

### Issue: "scons: command not found"

**Solution:**
```bash
sudo apt update
sudo apt install -y scons
```

---

### Issue: "g++: command not found"

**Solution:**
```bash
sudo apt update
sudo apt install -y build-essential
```

---

### Issue: "godot-cpp not found"

**Solution:**
```bash
git submodule update --init --recursive
```

---

### Issue: Build fails with "out of memory"

**Symptoms:**
- `g++: fatal error: Killed signal terminated program cc1plus`
- System freezes or becomes unresponsive

**Solution:**
- **Reduce parallel jobs:**
```bash
scons platform=linux arch=arm64 target=template_release cpu=rpi5 optimize_size=yes -j2
```

- **Enable swap space:**
```bash
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Set CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

- **Close other programs** during build

---

### Issue: Build succeeds but Godot crashes on load

**Symptoms:**
```
ERROR: GDExtension dynamic library not found
```

**Solution:**
- Verify the correct `.so` file exists:
```bash
ls -lh bin/libgodotmark.linux.template_release.arm64.so
```

- Check file type:
```bash
file bin/libgodotmark.linux.template_release.arm64.so
# Should show: ELF 64-bit LSB shared object, ARM aarch64
```

- Check dependencies:
```bash
ldd bin/libgodotmark.linux.template_release.arm64.so
```

---

## After Building

### Verify Build
```bash
# Check file exists
ls -lh bin/libgodotmark.linux.template_release.arm64.so

# Check file type (should be ARM64)
file bin/libgodotmark.linux.template_release.arm64.so

# Check dependencies
ldd bin/libgodotmark.linux.template_release.arm64.so
```

**Expected Output:**
```
bin/libgodotmark.linux.template_release.arm64.so: ELF 64-bit LSB shared object, ARM aarch64, version 1 (GNU/Linux), dynamically linked, stripped
```

---

### Run the Benchmark
```bash
cd /mnt/exfat_drive/dev/godotmark-project

./Godot_v4.4-stable_linux.arm64 --path godotmark
```

**With verbose output:**
```bash
./Godot_v4.4-stable_linux.arm64 --path godotmark --verbose
```

---

## Optimization Flags Applied

### RPi5-Specific Flags
```
-mcpu=cortex-a76       # Optimize for Cortex-A76 CPU (RPi5)
-march=armv8-a+simd    # ARM64 with NEON SIMD
-mfpu=neon-fp-armv8    # NEON floating-point
-ftree-vectorize       # Auto-vectorization
-ffast-math            # Fast math operations
-flto                  # Link-time optimization
```

### Release Build Flags
```
-O3                    # Maximum optimization (or -Os for size)
-fno-exceptions        # No exceptions (embedded best practice)
-fno-rtti              # No RTTI (reduces binary size)
-ffunction-sections    # Enable dead code elimination
-fdata-sections
-Wl,--gc-sections      # Remove unused sections
-Wl,--strip-all        # Strip symbols
```

**Total Performance Gain:** ~50-70% over unoptimized build

---

## Binary Size Comparison

| Configuration | Size | Build Command |
|---------------|------|---------------|
| **Release (size-optimized)** | **~1.5 MB** | `./build_native_rpi5.sh template_release rpi5 yes` |
| Release (performance) | ~2-3 MB | `./build_native_rpi5.sh template_release rpi5 no` |
| Debug | ~5-6 MB | `./build_native_rpi5.sh template_debug rpi5 no` |

---

## Next Steps

After successful build:

1. ✅ **Run the benchmark** (see "Run the Benchmark" above)
2. 🎮 **Test debug controls:**
   - `Space` - Pause/Resume
   - `Q/E` - Quality Down/Up
   - `T` - Toggle Quick Test (10s/60s)
   - `V` - Verbose Logging
   - `R` - Reset
   - `Esc` - Exit
3. 📊 **Monitor thermals and performance**
4. 🔋 **Test undervolting stability**

---

## Performance Expectations (RPi5)

### Undervolted RPi5 (Recommended Build)
- **FPS:** 20-35 FPS (Ultra quality)
- **Temperature:** 50-60°C (with active cooling)
- **Power:** ~4-6W (undervolted)
- **Stability:** Should remain stable without throttling

### Standard RPi5
- **FPS:** 25-40 FPS (Ultra quality)
- **Temperature:** 60-70°C (with active cooling)
- **Power:** ~8-10W
- **Note:** May throttle without adequate cooling

---

## Advanced: Using ccache for Faster Builds

**Install ccache:**
```bash
sudo apt install -y ccache
```

**Configure:**
```bash
export CXX="ccache g++"
export CC="ccache gcc"
```

**Then build as normal:**
```bash
./build_native_rpi5.sh template_release rpi5 yes
```

**Benefit:** 2nd+ builds are ~10x faster!

---

## Ready to Build!

Run this on your RPi5:

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```

🚀 Build time: ~10-20 minutes (first time)

Good luck testing your undervolted RPi5! 🎮


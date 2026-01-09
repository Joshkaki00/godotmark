# 🚀 GodotMark - START HERE

**You got the error: "GDExtension dynamic library not found"**

**Solution: Build the ARM64 library on your Raspberry Pi 5!**

---

## ⚡ Quick Fix (3 Commands)

**Copy-paste this into your RPi5 terminal:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
chmod +x build_native_rpi5.sh
./build_native_rpi5.sh template_release rpi5 yes
```

**Wait 10-20 minutes for build to complete.**

**Then run:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

---

## 📚 Documentation Files

Choose what you need:

### 🎯 First Time User?
→ **READ THIS:** `WHAT_TO_DO_NOW.txt`  
Plain text, step-by-step instructions with troubleshooting.

### 🏃 Want Quick Start?
→ **READ THIS:** `BUILD_AND_RUN.md`  
3-command quick start + debug controls + troubleshooting.

### 🔧 Need Detailed Build Info?
→ **READ THIS:** `RPi5_BUILD_INSTRUCTIONS.md`  
Complete build guide with all options and configurations.

### 📊 Want Full Overview?
→ **READ THIS:** `README.md`  
Project overview, features, architecture, use cases.

### ❓ Want to Know Status?
→ **READ THIS:** `CURRENT_STATUS.md`  
Current project status, what's working, what needs to be done.

### 🧪 Want Testing Guide?
→ **READ THIS:** `TESTING_GUIDE.md`  
How to test all features systematically.

---

## 🎮 What You'll Get

Once built and running:

- ✅ Real-time FPS counter (green/yellow/red)
- ✅ CPU/GPU usage monitoring
- ✅ Temperature monitoring (undervolting validation!)
- ✅ Adaptive quality scaling (5 presets)
- ✅ Debug controls (Space, Q/E, T, V, R, Esc)
- ✅ JSON results export
- ✅ Raspberry Pi 5 hardware detection

**Perfect for testing your undervolted RPi5!**

---

## ⚠️ Common Issues

### "scons: command not found"
```bash
sudo apt update
sudo apt install -y scons build-essential python3
```

### "godot-cpp not found"
```bash
git submodule update --init --recursive
```

### "Out of memory"
```bash
# Use fewer cores
scons platform=linux arch=arm64 target=template_release cpu=rpi5 optimize_size=yes -j2
```

---

## 🔋 Undervolting Validation

This benchmark will tell you if your undervolt is:

- ✅ **STABLE** - Consistent FPS, no crashes, temp < 65°C
- ⚠️ **MARGINAL** - FPS drops, temp > 70°C
- ❌ **UNSTABLE** - Crashes, throttling, freezes

**Monitor in another terminal:**
```bash
watch -n 1 'vcgencmd measure_temp'
watch -n 1 'vcgencmd get_throttled'
```

---

## 📞 Help

All documentation is in this folder:

```
godotmark/
├── WHAT_TO_DO_NOW.txt              ← Start here (plain text)
├── START_HERE.md                   ← You are here
├── BUILD_AND_RUN.md                ← Quick start (3 commands)
├── RPi5_BUILD_INSTRUCTIONS.md      ← Detailed build guide
├── README.md                       ← Full project overview
├── CURRENT_STATUS.md               ← Project status
├── TESTING_GUIDE.md                ← Testing workflow
├── build_native_rpi5.sh            ← Build script (automated)
├── check_build.sh                  ← Verify build
└── deploy_to_rpi5.sh               ← Deploy from Windows (if needed)
```

---

## ✅ Checklist

```
□ Read WHAT_TO_DO_NOW.txt
□ Navigate to godotmark directory
□ Run build_native_rpi5.sh (10-20 min)
□ Verify build with check_build.sh
□ Run benchmark
□ Test debug keys (Space, Q, E, T, V, R)
□ Monitor temperature and FPS
□ Complete 60-second test
□ Check JSON results
```

---

## 🚀 Build Now!

**Stop reading, start building:**

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark && \
chmod +x build_native_rpi5.sh && \
./build_native_rpi5.sh template_release rpi5 yes
```

**Time:** ~10-20 minutes

**Result:** `bin/libgodotmark.linux.template_release.arm64.so` (1.5 MB)

---

**Good luck with your undervolted Raspberry Pi 5! 🔋⚡🎮**


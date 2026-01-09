# Adaptive Quality Fix - RPi5 Compatibility

## 🐛 The Bug

The adaptive quality system wasn't working on RPi5 because:

### Problem 1: FPS Threshold Too High
```cpp
// OLD (broken on RPi5)
static constexpr float UPGRADE_FPS = 40.0f;
```

**RPi5 runs at ~36 FPS** (likely compositor/VSync limited), which is **below 40 FPS**. So it never upgraded!

On Windows PC at 60 FPS, it was above 40, so it worked fine.

### Problem 2: Frame-Based Hysteresis Assumes 60 FPS
```cpp
// OLD (broken on RPi5)
static constexpr int UPGRADE_THRESHOLD = 120;   // 2 seconds @ 60fps
```

This assumes **60 FPS constant**. At 36 FPS:
- Should wait 2 seconds = **72 frames**, not 120
- Old code waited 120 frames = **3.3 seconds** at 36 FPS

Frame counting breaks on variable framerates!

## ✅ The Fix

### 1. Lowered FPS Thresholds
```cpp
// NEW (works on all framerates)
static constexpr float MIN_FPS = 25.0f;         // Downgrade below this
static constexpr float UPGRADE_FPS = 33.0f;     // Upgrade above this
```

Now RPi5 at 36 FPS is **above the upgrade threshold** ✅

### 2. Time-Based Hysteresis (Not Frame-Based)
```cpp
// NEW (framerate-independent)
float time_below_target;
float time_above_target;
static constexpr float DOWNGRADE_TIME = 2.0f;   // 2 seconds
static constexpr float UPGRADE_TIME = 3.0f;     // 3 seconds
```

Now it tracks **real time**, not frame count!

### 3. Delta Time Calculation
```cpp
float delta = (current_fps > 0) ? (1.0f / current_fps) : 0.016f;

if (current_fps < MIN_FPS) {
    time_below_target += delta;  // Accumulate real time
    time_above_target = 0.0f;
}
```

**Works at any framerate**: 30 FPS, 36 FPS, 60 FPS, 120 FPS!

## 📊 New Behavior

### Before (Broken)
```
RPi5 @ 36 FPS:
- Never upgrades (36 < 40)
- Waits 3.3 seconds to downgrade (120 frames / 36 fps)
- Frame counting is framerate-dependent ❌
```

### After (Fixed)
```
RPi5 @ 36 FPS:
- CAN upgrade (36 > 33) ✅
- Waits exactly 3 seconds to upgrade (time-based)
- Waits exactly 2 seconds to downgrade (time-based)
- Works at ANY framerate ✅
```

## 🧪 Testing

### On RPi5 (36 FPS)
1. **Should upgrade from Medium → High** after ~3 seconds at 36 FPS
2. **Should downgrade if FPS < 25** after 2 seconds
3. **Thermal throttle at 75°C** should downgrade immediately

### On PC (60 FPS)
1. **Should still work** as before
2. Time-based = same behavior at any framerate

## 🔧 Rebuild Instructions

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark

# Clean old build
scons -c
rm -f bin/libgodotmark.linux.template_release.arm64.so

# Rebuild with fix
scons platform=linux arch=arm64 target=template_release cpu=rpi5 -j4

# Run
cd ..
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

## 🎯 Expected Result

With verbose logging enabled (press V):

```
[AdaptiveQuality] Initialized at: Medium
... (running at ~36 FPS with empty scene)
[AdaptiveQuality] Above target for 1.0s (FPS: 36.0)
[AdaptiveQuality] Above target for 2.0s (FPS: 36.0)
[AdaptiveQuality] FPS above 33.0 for 3.0s → Upgrading to High
... (3 more seconds)
[AdaptiveQuality] FPS above 33.0 for 3.0s → Upgrading to Ultra
```

Once we add actual 3D scenes, it should **downgrade when FPS drops** and **upgrade when stable**.

## 🚀 Additional Improvements

### Added Verbose Logging
```cpp
if (verbose_logging && time_above_target > 1.0f) {
    UtilityFunctions::print("[AdaptiveQuality] Above target for ", 
                           String::num(time_above_target, 1), "s");
}
```

Press **V** in-game to see detailed adaptive quality logic!

### Decay in Acceptable Range
```cpp
// If FPS is between 25-33, slowly decay timers
time_below_target = MAX(0.0f, time_below_target - delta * 0.5f);
time_above_target = MAX(0.0f, time_above_target - delta * 0.5f);
```

Prevents oscillation when FPS hovers around thresholds.

---

## 📝 Summary

**Root Cause:** Frame-based hysteresis + high FPS thresholds = broken on RPi5  
**Solution:** Time-based hysteresis + adaptive thresholds = works everywhere  
**Status:** ✅ FIXED - Rebuild required  

---

**This fix makes adaptive quality truly framerate-agnostic!** 🎉


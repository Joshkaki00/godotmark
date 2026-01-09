# GodotMark - Editor Testing Guide

## Prerequisites
- Godot 4.4+ installed
- GDExtension already built (✅ `bin/libgodotmark.windows.template_debug.x86_64.dll`)

## How to Test in Godot Editor

### Step 1: Open Project
```bash
# Open Godot Editor
godot --editor --path D:\dev\godotmark-project\godotmark
```

Or use Godot Project Manager:
1. Click "Import"
2. Browse to `D:\dev\godotmark-project\godotmark`
3. Click "Import & Edit"

---

### Step 2: Verify GDExtension Loading

**Expected Output in Editor Console:**
```
[GodotMark] Extension initialized
Available classes:
  - PlatformDetector
  - PerformanceMonitor
  - AdaptiveQualityManager
  - ProgressiveStressTest
  - GPUBasicsScene
  - ResultsExporter
  - BenchmarkOrchestrator
```

**If classes don't load:**
- Check `godotmark.gdextension` paths
- Verify DLL exists: `bin/libgodotmark.windows.template_debug.x86_64.dll`
- Rebuild: `scons platform=windows target=template_debug -j4`

---

### Step 3: Run Main Scene

Click **Play** button (F5) or select `scenes/main.tscn` and press F6.

**Expected Behavior:**
1. **Console Output:**
   ```
   ========================================
   [GodotMark] Initializing...
   ========================================
   
   [PlatformDetector] Detecting platform...
   Platform: Windows
   CPU: [Your CPU Model]
   RAM: [Your RAM] MB
   GPU: [Your GPU]
   
   [PerformanceMonitor] Monitoring started
   [AdaptiveQuality] Initialized at: Medium
   [main.gd] Core systems initialized
   
   [main.gd] Ready! Use debug keys to control:
     Space - Pause/Resume
     Q/E   - Quality Down/Up
     T     - Toggle Quick Test (10s/60s)
     V     - Verbose Logging
     Esc   - Exit
   ```

2. **UI Overlay (Top-Left):**
   - FPS Counter (updating in real-time, color-coded)
   - Frame Time
   - Quality Preset
   - CPU Usage
   - Temperature (Windows: may show 0°C)
   - Status

3. **Debug Controls (Top-Right):**
   - Key hints displayed

---

### Step 4: Test Debug Controls

| Key | Action | Expected Result |
|-----|--------|-----------------|
| **Space** | Pause/Resume | Console shows "PAUSED" / "RESUMED", FPS stops updating |
| **Q** | Quality Down | Quality changes (Ultra→High→Medium→Low→Potato), console logs change |
| **E** | Quality Up | Quality increases, console logs change |
| **T** | Quick Test | Toggle between 10s and 60s benchmark duration |
| **V** | Verbose | Enable detailed logging in console |
| **Esc** | Exit | Application exits |

---

### Step 5: Monitor Performance

**Watch for:**
- **FPS Counter Color:**
  - 🟢 **Green** (>40 FPS) = Good
  - 🟡 **Yellow** (25-40 FPS) = Moderate
  - 🔴 **Red** (<25 FPS) = Poor

- **Adaptive Quality:**
  - Should automatically adjust quality based on FPS
  - Console logs: `[AdaptiveQuality] Downgraded to: Low` (if FPS drops)

- **Temperature Warning:**
  - Red "⚠ THERMAL THROTTLING" appears if temp > 75°C
  - (On Windows, temp monitoring may not work)

---

### Step 6: Test Quick Benchmark (10 seconds)

1. Press **T** to enable Quick Test mode
2. Console shows: `[DebugController] Quick test mode: ON (10s)`
3. Run a benchmark (currently systems are initialized but no GPU test running yet)
4. Benchmark should complete in 10 seconds

---

### Step 7: Test Quality Presets

**Manual Quality Testing:**
1. Start with Medium quality
2. Press **E** repeatedly to increase quality
3. Observe FPS changes
4. Press **Q** to decrease quality

**Quality Levels:**
- **Potato**: 512px textures, no shadows, minimal effects
- **Low**: 1024px textures, basic shadows
- **Medium**: 2048px textures, good shadows (default)
- **High**: 4096px textures, high-quality shadows
- **Ultra**: 4096px textures, all effects enabled

---

### Step 8: Enable Verbose Logging

1. Press **V** to enable verbose logging
2. Console shows: `[DebugController] Verbose logging: ON`
3. Watch for detailed `[Verbose]` messages
4. Useful for debugging issues

**Expected Verbose Output:**
```
[Verbose] Starting platform detection
[Verbose] Platform detection complete
[Verbose] Quick test mode: enabled (10.0s)
[Verbose] Spawning 50 objects (5000 triangles)
[Verbose] Load: 5000/100000 (5%)
```

---

## Troubleshooting

### Issue: GDExtension Not Loading

**Symptoms:**
- No console output from C++ classes
- Errors: `Can't create instance of type 'PlatformDetector'`

**Solutions:**
1. Verify DLL exists: `bin/libgodotmark.windows.template_debug.x86_64.dll`
2. Check `godotmark.gdextension` paths:
   ```ini
   [libraries]
   windows.debug.x86_64 = "res://bin/libgodotmark.windows.template_debug.x86_64.dll"
   ```
3. Rebuild: `scons platform=windows target=template_debug -j4`
4. Restart Godot Editor

---

### Issue: Low FPS in Editor

**Symptoms:**
- FPS < 20 even at Potato quality

**Solutions:**
1. **This is normal for debug builds!**
2. Debug builds are ~50% slower than release builds
3. For performance testing, build release:
   ```bash
   scons platform=windows target=template_release -j4
   ```
4. Update `godotmark.gdextension`:
   ```ini
   windows.release.x86_64 = "res://bin/libgodotmark.windows.template_release.x86_64.dll"
   ```

---

### Issue: No Platform Info

**Symptoms:**
- Platform shows "Unknown"
- CPU/RAM shows 0

**Solutions:**
- On Windows, some detection is limited
- Linux ARM platforms have better detection
- Check console for error messages

---

### Issue: Temperature Shows 0°C

**Symptoms:**
- Temp always shows 0°C or --°C

**Solutions:**
- **This is expected on Windows!**
- Temperature monitoring primarily targets Linux ARM SBCs
- Uses `/sys/class/thermal/` which doesn't exist on Windows
- RPi5 will show correct temperatures

---

### Issue: UI Not Showing

**Symptoms:**
- Black screen, no UI overlay

**Solutions:**
1. Check `scenes/main.tscn` has `UI/StatsOverlay` node
2. Verify `stats_overlay.tscn` exists
3. Check console for errors
4. Try F5 (run main scene) instead of F6

---

## What to Look For (Success Criteria)

✅ **GDExtension Loads:**
- No errors in console
- All C++ classes available

✅ **Systems Initialize:**
- Platform detected (Windows)
- Performance monitor updates
- Quality manager functional

✅ **UI Works:**
- FPS counter updates smoothly
- Color coding works (green/yellow/red)
- Debug controls visible

✅ **Debug Controls Work:**
- All keys respond (Space, Q, E, T, V, Esc)
- Console logs show actions
- Quality changes reflected in UI

✅ **Performance Stable:**
- No crashes
- No memory leaks (check Task Manager)
- FPS consistent for quality level

---

## Next Steps After Editor Testing

Once editor testing is complete and all systems work:

1. ✅ **Fix any issues found**
2. ✅ **Document any quirks**
3. 🚀 **Build for RPi5:**
   ```bash
   scons platform=linux arch=arm64 target=template_release cpu=rpi5 optimize_size=yes
   ```
4. 🚀 **Deploy to RPi5** (see `BUILDING.md`)
5. 🚀 **Test on actual hardware**

---

## Performance Targets

**Windows (Editor - Debug Build):**
- **Potato**: 40+ FPS
- **Low**: 30+ FPS
- **Medium**: 25+ FPS
- **High**: 20+ FPS
- **Ultra**: 15+ FPS

**Windows (Standalone - Release Build):**
- **Potato**: 60+ FPS
- **Low**: 50+ FPS
- **Medium**: 40+ FPS
- **High**: 30+ FPS
- **Ultra**: 25+ FPS

**RPi5 (Undervolted - Release Build):**
- **Potato**: 30+ FPS (target)
- **Low**: 25+ FPS (target)
- **Medium**: 20+ FPS (target)
- **High**: 15+ FPS (best effort)
- **Ultra**: 10+ FPS (stress test only)

---

## Tips for Effective Testing

1. **Start with Quick Test (T key)**: 10-second tests are faster for iteration
2. **Enable Verbose (V key)**: See detailed system behavior
3. **Monitor Task Manager**: Check CPU/RAM usage and memory leaks
4. **Test all quality presets**: Ensure each level is distinct
5. **Try manual quality control**: Q/E keys should work smoothly
6. **Watch adaptive quality**: Should auto-adjust based on FPS
7. **Test pause/resume**: Space key should freeze everything
8. **Check console for errors**: Any errors should be investigated

---

## Known Limitations (Windows Testing)

- **No temperature monitoring** (Linux-only feature)
- **No GPU throttling detection** (ARM SBC-specific)
- **Limited platform-specific optimization** (designed for ARM)
- **Debug build is slow** (use release build for performance testing)

These limitations are expected and won't affect RPi5 deployment!

---

## Ready for Testing!

Open Godot Editor, run `scenes/main.tscn`, and start testing! 🚀

Report any issues or unexpected behavior for refinement before RPi5 deployment.


# Model Showcase - Testing Instructions

## Windows Editor Testing

### Prerequisites
- Godot 4.4.0 installed
- GodotMark project open in editor
- All assets imported (marble bust, HDR, audio)

### Test Procedure

#### 1. Verify Asset Import

Check that these files are properly imported:

```
✓ art/model-test/marble_bust_01_2k.gltf/marble_bust_01_2k.gltf
✓ art/model-test/sunflowers_puresky_2k.hdr
✓ art/model-test/Excelsior In Aeternum.ogg
```

**How to check:**
- Open each file in Godot Editor
- Verify no import errors in Output panel
- For HDR: Should show as Texture2D in Inspector
- For audio: Should show as AudioStreamOggVorbis

#### 2. Test from Main Scene

1. Open `scenes/main.tscn`
2. Press F5 to run
3. Wait for initialization messages
4. Press **M** key
5. Verify scene transition to Model Showcase

**Expected Output:**
```
[main.gd] Ready! Use debug keys to control:
  M     - Launch Model Showcase (1-minute benchmark)
[DebugController] Launching Model Showcase...
[ModelShowcase] Starting 1-Minute Benchmark
```

#### 3. Test Direct Scene Launch

1. Open `scenes/model_showcase.tscn`
2. Press F6 to run current scene
3. Verify audio starts immediately
4. Watch for phase transitions

**Expected Output:**
```
[ModelShowcase] Starting 1-Minute Benchmark
[ModelShowcase] Quality preset: Medium
[ModelShowcase] Audio started - 60 second timer begins

[Phase 1] Basic PBR (0-12s)
  - No shadows, no HDR, no post-processing

[Phase 2] HDR Lighting + Shadows (12-24s)
  - Enabling HDR environment and shadow casting
  ✓ HDR environment loaded

[Phase 3] Enhanced Materials + Reflections (24-36s)
  - Enabling SSR and SSAO
  ✓ SSR and SSAO enabled

[Phase 4] Particles + Glow (36-48s)
  - Enabling particles and bloom
  ✓ Particles (500) and glow enabled

[Phase 5] Maximum Complexity (48-60s)
  - Maximum effects and particle count
  ✓ Particle count increased to 2000
  ✓ Maximum effects enabled

[ModelShowcase] Benchmark Complete!
Performance Summary:
-------------------
Phase 1: Avg 98.5 FPS (min: 85.2, max: 120.0)
Phase 2: Avg 76.3 FPS (min: 68.1, max: 85.2)
Phase 3: Avg 62.1 FPS (min: 55.4, max: 68.1)
Phase 4: Avg 48.7 FPS (min: 42.3, max: 55.4)
Phase 5: Avg 38.2 FPS (min: 32.1, max: 42.3)

✓ Results exported to: user://model_showcase_results.json
```

#### 4. Verify Visual Effects

Watch for these visual changes at each phase transition:

**0-12s (Phase 1):**
- ✓ Marble bust visible
- ✓ Basic lighting
- ✓ Gray background
- ✓ No shadows
- ✓ Camera dolly-in

**12-24s (Phase 2):**
- ✓ HDR sky appears (sunny outdoor)
- ✓ Shadows appear under bust
- ✓ Environment reflections on marble
- ✓ Camera begins orbit

**24-36s (Phase 3):**
- ✓ Reflections become sharper (SSR)
- ✓ Subtle darkening in crevices (SSAO)
- ✓ Camera continues orbit

**36-48s (Phase 4):**
- ✓ Particles appear (dust motes)
- ✓ Glow/bloom on bright areas
- ✓ Camera orbits from opposite side

**48-60s (Phase 5):**
- ✓ More particles (2000)
- ✓ Stronger glow
- ✓ Background blur (DOF)
- ✓ Final hero shot

#### 5. Test Quality Presets

Test at different quality levels:

**Potato:**
```
1. Run main.tscn
2. Press Q repeatedly until "Potato"
3. Press M to launch
4. Verify: Only Phase 1-2, no advanced effects
```

**Low:**
```
1. Set quality to Low
2. Launch showcase
3. Verify: Phase 1-3, no particles
```

**Medium:**
```
1. Set quality to Medium
2. Launch showcase
3. Verify: Phase 1-4, 500 particles
```

**High:**
```
1. Set quality to High
2. Launch showcase
3. Verify: All phases, 2000 particles, DOF
```

#### 6. Test Camera Animation

Verify smooth camera movement:
- ✓ No stuttering or jerky motion
- ✓ Smooth transitions between keyframes
- ✓ Always looking at bust
- ✓ Completes full orbit by end

#### 7. Test Audio Sync

Verify audio is synced with phases:
- ✓ Audio starts immediately
- ✓ Phase transitions at 12, 24, 36, 48 seconds
- ✓ Benchmark ends at 60 seconds (audio end)
- ✓ No audio crackling or stuttering

#### 8. Test Results Export

After benchmark completes:

1. Check console for export message
2. Navigate to results location:
   - Windows: `%APPDATA%\Godot\app_userdata\GodotMark\`
3. Open `model_showcase_results.json`
4. Verify JSON structure is valid
5. Check all 5 phases have data

**Expected JSON:**
```json
{
  "benchmark": "Model Showcase",
  "duration": 60.0,
  "timestamp": "2026-01-07T...",
  "phases": {
    "phase_1": { "avg_fps": ..., "min_fps": ..., ... },
    "phase_2": { ... },
    "phase_3": { ... },
    "phase_4": { ... },
    "phase_5": { ... }
  }
}
```

#### 9. Test Early Exit

1. Launch showcase
2. Press ESC during playback
3. Verify: Returns to main scene
4. Check console for cancellation message

---

## RPi5 Deployment & Testing

### Prerequisites
- RPi5 with Godot 4.4 installed
- GodotMark project copied to RPi5
- Adaptive quality fix applied (rebuilt C++ extension)

### Deployment Steps

#### 1. Copy Assets to RPi5

From Windows, copy the entire project:

```bash
# Using SCP (adjust paths as needed)
scp -r D:\dev\godotmark-project\godotmark user@rpi5:/mnt/exfat_drive/dev/godotmark-project/
```

Or use your preferred method (USB drive, network share, etc.)

#### 2. Verify File Permissions

On RPi5:

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark

# Check that all files are readable
ls -la art/model-test/
ls -la scenes/model_showcase.tscn
ls -la scripts/model_showcase.gd
```

#### 3. Test Asset Loading

```bash
# Launch Godot and check for import errors
./Godot_v4.4-stable_linux.arm64 --path godotmark --editor
```

Check Output panel for any import errors.

#### 4. Run Benchmark from Main Scene

```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark
```

Then press **M** to launch showcase.

#### 5. Run Benchmark Directly

```bash
cd /mnt/exfat_drive/dev/godotmark-project
./Godot_v4.4-stable_linux.arm64 --path godotmark scenes/model_showcase.tscn
```

### Expected Performance (RPi5 @ Medium)

**Phase 1 (Basic PBR):**
- Target: 50-60 FPS
- Acceptable: 45+ FPS

**Phase 2 (HDR + Shadows):**
- Target: 40-50 FPS
- Acceptable: 35+ FPS

**Phase 3 (SSR + SSAO):**
- Target: 35-45 FPS
- Acceptable: 30+ FPS

**Phase 4 (Particles + Glow):**
- Target: 30-40 FPS
- Acceptable: 25+ FPS

**Phase 5 (Maximum):**
- Target: 25-35 FPS
- Acceptable: 20+ FPS

### RPi5 Testing Checklist

- [ ] Assets load without errors
- [ ] Audio plays correctly
- [ ] HDR environment loads (Phase 2)
- [ ] Shadows render correctly
- [ ] SSR/SSAO visible (Phase 3)
- [ ] Particles appear (Phase 4)
- [ ] Camera animation is smooth
- [ ] No thermal throttling (check temps)
- [ ] Results export successfully
- [ ] FPS meets acceptable targets

### Troubleshooting on RPi5

**Audio Issues:**
```bash
# Check ALSA configuration
aplay -l

# Test audio playback
aplay /usr/share/sounds/alsa/Front_Center.wav
```

**Low FPS:**
```bash
# Check CPU frequency
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Check temperature
vcgencmd measure_temp

# Monitor during benchmark
watch -n 1 vcgencmd measure_temp
```

**HDR Not Loading:**
- Check file exists: `ls -la art/model-test/sunflowers_puresky_2k.hdr`
- Check file size: Should be ~5.7 MB
- Re-import in Godot Editor if needed

**Particles Not Visible:**
- Verify quality is Medium or higher
- Check console for Phase 4 message
- Ensure 36+ seconds have elapsed

---

## Performance Comparison

After testing on both platforms, compare results:

### Metrics to Compare
1. Average FPS per phase
2. FPS drop between phases
3. Minimum FPS (performance floor)
4. Temperature stability
5. Visual quality differences

### Expected Differences

**Windows (GTX 1060) vs RPi5:**
- Windows: 2-3x higher FPS
- RPi5: Better thermal stability
- RPi5: May skip Phase 5 effects at Medium quality

**Quality Scaling:**
- Potato → Low: +30-40% FPS
- Low → Medium: +20-30% FPS
- Medium → High: +15-20% FPS
- High → Ultra: +10-15% FPS

---

## Success Criteria

### Windows Testing ✓
- [ ] All phases complete without errors
- [ ] Audio synced with phase transitions
- [ ] Camera animation smooth
- [ ] Visual effects appear as expected
- [ ] Results export successfully
- [ ] No crashes or freezes

### RPi5 Testing ✓
- [ ] Benchmark runs to completion
- [ ] FPS meets acceptable targets
- [ ] No thermal throttling
- [ ] Audio plays correctly
- [ ] Effects scale with quality preset
- [ ] Results export successfully

---

## Next Steps After Testing

1. **Document Results:**
   - Save JSON results from both platforms
   - Take screenshots of each phase
   - Record FPS graphs if possible

2. **Optimize if Needed:**
   - Adjust particle counts for RPi5
   - Tune shadow quality
   - Optimize HDR loading

3. **Create Comparison Report:**
   - Windows vs RPi5 performance
   - Quality preset scaling
   - Thermal behavior

4. **Share Results:**
   - Add to project documentation
   - Create performance baseline
   - Update README with benchmarks

---

**Ready to test!** 🚀


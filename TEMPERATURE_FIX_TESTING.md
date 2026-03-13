# Temperature Monitoring Fix - Testing Checklist

**Status:** ⚠️ **UNTESTED** - Community contribution needs runtime verification  
**Date:** February 8, 2026  
**Issue:** [#6 - Temperature monitoring reports 0°C on some platforms](https://github.com/Joshkaki00/godotmark/issues/6)

---

## What Was Fixed

A community contributor implemented comprehensive multi-platform temperature detection in `src/performance/performance_monitor.cpp`. The fix tries multiple thermal sources in order:

1. **ARM SBC thermal zones** (`/sys/class/thermal/thermal_zone0-1/temp`)
2. **Desktop Linux hwmon** (glob patterns: `/sys/class/hwmon/hwmon*/temp*_input`)
3. **Raspberry Pi vcgencmd** (`vcgencmd measure_temp`)
4. **Graceful fallback** (returns -1.0f, displays "N/A")

**However, the contributor stated:**
> "I could not run a local build from this environment because the local clone path was unreliable, so this is submitted with bounded source changes but without a full runtime verification pass."

**This means the code compiles but has NOT been tested in a real runtime environment!**

---

## Testing Checklist

### Prerequisites
- [ ] Build GodotMark with native C++ GDExtension
- [ ] Enable verbose logging: `PerformanceMonitor::set_verbose_logging(true)`

### Platform Testing

#### ✅ Raspberry Pi 5
- [ ] Run Model Showcase benchmark
- [ ] Run Nature Island benchmark
- [ ] Check console logs for thermal path used
- [ ] Verify temperature matches `vcgencmd measure_temp`
- [ ] Expected: Real temperature (e.g., 55-65°C under load)

**Console should show:**
```
[PerformanceMonitor] Trying thermal path: /sys/class/thermal/thermal_zone0/temp
[PerformanceMonitor] Temperature: 58.3°C
```

#### ⚠️ Raspberry Pi 4
- [ ] Run Model Showcase benchmark
- [ ] Run Nature Island benchmark
- [ ] Check console logs for thermal path used
- [ ] Verify temperature matches `vcgencmd measure_temp`
- [ ] Expected: Real temperature (e.g., 60-75°C under load)

**Possible paths:**
- `/sys/class/thermal/thermal_zone0/temp`
- `/sys/devices/virtual/thermal/thermal_zone0/temp`
- Fallback to `vcgencmd`

#### ⚠️ Desktop Linux (x86_64)
- [ ] Run Model Showcase benchmark
- [ ] Check console logs for thermal path used
- [ ] Verify temperature with `sensors` command
- [ ] Expected: Real CPU temperature (e.g., 40-70°C)

**Console should show:**
```
[PerformanceMonitor] Trying thermal path: /sys/class/hwmon/hwmon0/temp1_input
[PerformanceMonitor] Temperature: 52.0°C
```

**If "N/A" displayed:**
- Check if hwmon paths exist: `ls /sys/class/hwmon/hwmon*/temp*_input`
- Manually read a thermal file: `cat /sys/class/hwmon/hwmon0/temp1_input`
- Report which paths exist on your system

#### ✅ Windows
- [ ] Run Model Showcase benchmark
- [ ] Expected: "Temp: N/A" displayed
- [ ] No crashes or errors

**Console should show:**
```
[PerformanceMonitor] Windows: Temperature not available
```

---

## Known Issues to Watch For

### Issue 1: Glob Pattern Not Working
**Symptom:** Desktop Linux shows "N/A" despite hwmon files existing  
**Cause:** `glob()` might not be linking correctly  
**Debug:** Check compile output for `glob.h` errors

### Issue 2: Wrong Thermal Zone Selected
**Symptom:** Temperature reads incorrectly (e.g., 20°C when system is hot)  
**Cause:** Multiple thermal zones, wrong one selected first  
**Fix:** Reorder `thermal_paths[]` array to prioritize correct zone

### Issue 3: Permission Denied
**Symptom:** Thermal files exist but return empty string  
**Cause:** Some hwmon files require root permissions  
**Workaround:** Run with sudo (not recommended) or skip those paths

### Issue 4: Temperature Scaling Wrong
**Symptom:** Shows 52000°C instead of 52°C  
**Cause:** `parse_sysfs_temperature()` division logic error  
**Check:** Line 32-33 in `performance_monitor.cpp`

---

## Verification Steps

### 1. Check Console Output
Run with verbose logging and verify temperature detection:

```bash
# Enable verbose in GDScript before benchmark starts
perf_monitor.set_verbose_logging(true)
```

Look for these lines in console:
```
[PerformanceMonitor] Trying thermal path: ...
[PerformanceMonitor] Temperature: X.X°C
```

### 2. Compare with System Tools

**Raspberry Pi:**
```bash
vcgencmd measure_temp
# Should match GodotMark within ±2°C
```

**Desktop Linux:**
```bash
sensors
# Should match GodotMark within ±5°C
```

### 3. Stress Test
Run full 60-second benchmark and verify:
- [ ] Temperature increases during benchmark
- [ ] No crashes or freezes
- [ ] Temperature updates every second
- [ ] Throttling detection works (>75°C)

---

## Reporting Results

### If It Works ✅
Comment on [Issue #6](https://github.com/Joshkaki00/godotmark/issues/6):

```
Tested on [Platform]:
- Temperature displayed: [X.X°C]
- System temperature: [X.X°C via sensors/vcgencmd]
- Thermal path used: [path from console log]
- Status: ✅ Working correctly
```

### If It Fails ❌
Comment on [Issue #6](https://github.com/Joshkaki00/godotmark/issues/6):

```
Tested on [Platform]:
- Temperature displayed: [N/A / 0°C / wrong value]
- System temperature: [X.X°C via sensors/vcgencmd]
- Console output: [paste relevant logs]
- Thermal files found: [output of ls /sys/class/thermal/thermal_zone*/temp]
- Status: ❌ Not working
```

---

## Next Steps After Testing

### If All Tests Pass
1. Update `TEMPERATURE_FIX_TESTING.md` with test results
2. Close Issue #6 on GitHub
3. Thank the contributor in the issue comments
4. Update CHANGELOG.md to remove "untested" note
5. Add contributor to README credits

### If Tests Fail
1. Document which platforms fail
2. Investigate console logs for errors
3. Check which thermal paths actually exist on failing systems
4. Fix the C++ code in `performance_monitor.cpp`
5. Rebuild and retest

---

## Code Review Notes

### Good Practices Used ✅
- Multiple fallback paths (ARM SBC → desktop Linux → vcgencmd)
- Glob pattern matching for wildcards
- Proper error handling (empty reads don't crash)
- Verbose logging for debugging
- Parse validation before using temperature values
- Platform-specific `#ifdef __linux__` guards

### Potential Issues ⚠️
- `glob()` requires `#include <glob.h>` (only available on Linux)
- Glob matches might return *any* temp sensor (not necessarily CPU)
- No way to verify which sensor is the "main" CPU temp
- Desktop systems may have 20+ temp sensors (GPU, motherboard, etc.)
- First matching hwmon file might not be the CPU

### Suggested Improvements
1. **Sensor filtering** - Skip GPU/disk temps, prefer CPU temps
2. **Sensor priority** - Check `hwmon*/name` files to identify CPU sensors
3. **Multi-sensor display** - Show multiple temps if available
4. **Caching** - Save working path after first successful read

---

## Files Modified

### C++ Source
- ✅ `src/performance/performance_monitor.cpp` (lines 295-385)

### GDScript UI
- ✅ `scripts/ui/model_showcase_overlay.gd` (added "N/A" handling)
- ✅ `scripts/ui/stats_overlay.gd` (already had "N/A" handling)

### Documentation
- ✅ `CHANGELOG.md` (documented fix)
- ✅ `TEMPERATURE_FIX_TESTING.md` (this file)

---

## Credits

**Fix submitted by:** Community contributor (GitHub Issue #6)  
**Testing coordination:** Project maintainers  
**Issue reporter:** Original bug report on Issue #6

---

**Last Updated:** February 8, 2026  
**Status:** ⚠️ Awaiting runtime verification on real hardware

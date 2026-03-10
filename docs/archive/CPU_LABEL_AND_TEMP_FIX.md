# CPU Label and Temperature Fix - Implementation Complete

## Overview

Added missing CPU label to the UI overlay and enabled verbose logging to diagnose temperature reading issues on both Windows and Raspberry Pi.

---

## Changes Made

### 1. Added CPU Label to UI

**File:** `scenes/ui/model_showcase_overlay.tscn`

Added new `CPULabel` node after `FrameTimeLabel`:

```
[node name="CPULabel" type="Label" parent="Panel/MarginContainer/VBoxContainer"]
layout_mode = 2
theme_override_constants/outline_size = 2
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_font_sizes/font_size = 16
text = "CPU: --.-%%"
```

**File:** `scripts/ui/model_showcase_overlay.gd`

- Added `@onready var cpu_label = $Panel/MarginContainer/VBoxContainer/CPULabel`
- Updated `update_metrics()` signature to include `cpu_usage` parameter
- Added `cpu_label.text = "CPU: %.1f%%" % cpu_usage` to display CPU usage

### 2. Added CPU to Metrics Collection

**File:** `scripts/model_showcase.gd`

**Metrics Dictionary:**
```gdscript
var metrics = {
    "phase_1": {"fps": [], "frame_times": [], "cpu": [], "temps": [], "gpu": [], "timestamps": []},
    // ... all phases updated
}
```

**Current Second Data:**
```gdscript
var current_second_data = {"fps": [], "frame_times": [], "cpu": [], "temps": [], "gpu": []}
```

**Metrics Collection in _process():**
```gdscript
var cpu_usage = 0.0
if perf_monitor:
    cpu_usage = perf_monitor.get_cpu_usage()
else:
    cpu_usage = 0.0  # Not available
```

**Storage:**
```gdscript
metrics[current_phase_key]["cpu"].append(cpu_usage)
current_second_data["cpu"].append(cpu_usage)
```

**UI Update:**
```gdscript
metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
```

### 3. Updated Aggregation Functions

**aggregate_second_data():**
- Added `avg_cpu` calculation
- Added `cpu` field to per_second_metrics
- Updated clear statement to include `cpu` array

**export_results():**
- Added `var cpu_data = metrics[phase_key]["cpu"]` to phase processing

### 4. Enabled Verbose Logging

**File:** `scripts/model_showcase.gd`

When creating standalone performance monitor:
```gdscript
perf_monitor = PerformanceMonitor.new()
perf_monitor.set_verbose_logging(true)  # Force verbose for debugging
```

This ensures debug output is always shown when running the model showcase.

---

## UI Layout (Final)

```
MODEL SHOWCASE BENCHMARK
─────────────────────────
FPS: 35.2
Frame: 28.45 ms
CPU: 44.5%          ← NEW!
GPU: 35.6%
Temp: 0.0°C (Windows) or 52.3°C (RPi)
─────────────────────────
Phase 1: Basic PBR
[Progress Bar]
00:03 / 01:00
```

---

## Expected Console Output

### Windows

```
[ModelShowcase] WARNING: Main scene not found, creating standalone systems
[ModelShowcase] Standalone systems created
[PerformanceMonitor] Windows CPU calc: frametime=28.45ms
[PerformanceMonitor] CPU usage set to: 44.5%
[PerformanceMonitor] GPU usage set to: 35.6%
[PerformanceMonitor] Windows: Temperature not available
```

### Raspberry Pi (If Working)

```
[ModelShowcase] WARNING: Main scene not found, creating standalone systems
[ModelShowcase] Standalone systems created
[PerformanceMonitor] Trying thermal path: /sys/class/thermal/thermal_zone0/temp
[PerformanceMonitor] Temperature read: 52300
[PerformanceMonitor] Temperature: 52.3°C
[PerformanceMonitor] /proc/stat read: SUCCESS
[PerformanceMonitor] CPU usage set to: 67.8%
[PerformanceMonitor] GPU usage set to: 54.2%
```

### Raspberry Pi (If Temperature Fails)

```
[ModelShowcase] WARNING: Main scene not found, creating standalone systems
[ModelShowcase] Standalone systems created
[PerformanceMonitor] Trying thermal path: /sys/class/thermal/thermal_zone0/temp
[PerformanceMonitor] Trying thermal path: /sys/class/thermal/thermal_zone1/temp
[PerformanceMonitor] Trying thermal path: /sys/devices/virtual/thermal/thermal_zone0/temp
[PerformanceMonitor] WARNING: No thermal zones found
[PerformanceMonitor] /proc/stat read: SUCCESS
[PerformanceMonitor] CPU usage set to: 67.8%
[PerformanceMonitor] GPU usage set to: 54.2%
```

---

## JSON Export (Updated)

```json
{
    "benchmark": "Model Showcase",
    "version": "1.1",
    "per_second": [
        {
            "second": 3,
            "phase": 0,
            "fps": 60.0,
            "frame_time": 16.67,
            "cpu": 44.5,     ← NEW!
            "temp": 0.0,
            "gpu": 35.6
        }
    ],
    "phases": {
        "phase_1": {
            "fps": {...},
            "frame_time": {...},
            "cpu": {...},    ← NEW!
            "temp": {...},
            "gpu": {...}
        }
    }
}
```

---

## Troubleshooting Temperature Issues

### If Temperature Shows 0 on Raspberry Pi

**Step 1: Check Console Output**

Look for these messages:
- "Trying thermal path: ..." - Shows which paths are being tried
- "Temperature read: XXXXX" - Shows raw value if found
- "Temperature: XX.X°C" - Shows converted value
- "WARNING: No thermal zones found" - All paths failed

**Step 2: Verify Thermal Files Exist**

On Raspberry Pi, run:
```bash
ls -la /sys/class/thermal/thermal_zone0/temp
cat /sys/class/thermal/thermal_zone0/temp
```

Expected output: `52300` (52.3°C in millidegrees)

**Step 3: Check vcgencmd**

```bash
which vcgencmd
vcgencmd measure_temp
```

Expected output: `temp=52.3'C`

**Step 4: Check Permissions**

```bash
groups
# Should include 'video' or similar group for hardware access
```

If permission denied:
```bash
sudo usermod -aG video $USER
# Log out and back in
```

**Step 5: Install vcgencmd (if missing)**

```bash
sudo apt install libraspberrypi-bin
```

---

## What's Fixed

✅ **CPU Label Added** - Now displays in UI overlay  
✅ **CPU Metrics Collected** - Tracked per-frame and per-second  
✅ **CPU in JSON Export** - Included in all output  
✅ **Verbose Logging Enabled** - Always shows debug output  
✅ **Temperature Diagnostics** - Can see exactly what's happening  

---

## What to Check Next

### Windows

1. Run model showcase (press M)
2. Check console for:
   - "Windows CPU calc: frametime=X.XXms"
   - "CPU usage set to: XX.X%"
   - "GPU usage set to: XX.X%"
3. Check UI shows:
   - CPU: 30-80%
   - GPU: 24-64%
   - Temp: 0.0°C (expected)

### Raspberry Pi

1. Run model showcase
2. Check console for:
   - Thermal path attempts
   - Temperature reading (or failure messages)
   - CPU/GPU calculations
3. Check UI shows:
   - CPU: 40-90%
   - GPU: 32-72%
   - Temp: 45-75°C (or 0.0°C if failed)

### If Temperature Still 0 on Raspberry Pi

**Provide this information:**
1. Full console output (especially thermal path messages)
2. Output of `cat /sys/class/thermal/thermal_zone0/temp`
3. Output of `vcgencmd measure_temp`
4. Output of `ls -la /sys/class/thermal/`

This will help diagnose if it's:
- Permission issue
- Wrong file paths
- vcgencmd not available
- Hardware not exposing temperature

---

## Files Modified

1. **scenes/ui/model_showcase_overlay.tscn** - Added CPULabel node
2. **scripts/ui/model_showcase_overlay.gd** - Added cpu_label reference and updated signature
3. **scripts/model_showcase.gd** - Added CPU to metrics collection, storage, aggregation, and export; enabled verbose logging

---

**Implementation Date:** January 13, 2026  
**Status:** Complete and ready for testing  
**Result:** CPU now displays in UI and verbose logging will help diagnose temperature issues! 🎉


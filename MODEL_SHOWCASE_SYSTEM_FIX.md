# Model Showcase System Access Fix - Implementation Complete

## Overview

Fixed model showcase showing `gpu: 0.0` and `temp: 0.0` by changing from scene switching to scene adding, preserving the Main scene and its performance monitoring systems.

---

## Problem Diagnosed

### Root Cause

**File:** `scripts/debug_controller.gd` line 87

```gdscript
func launch_model_showcase():
    get_tree().change_scene_to_file("res://scenes/model_showcase.tscn")
```

**Issue:** `change_scene_to_file()` **destroys the Main scene** and all its systems:
- `perf_monitor` (PerformanceMonitor) - destroyed
- `quality_manager` (AdaptiveQualityManager) - destroyed
- `platform_detector` (PlatformDetector) - destroyed

When model_showcase tried to access these systems:
```gdscript
var main = get_tree().root.get_node_or_null("Main")
if main:
    perf_monitor = main.perf_monitor  # Main is gone, returns null
```

Result: Falls back to `gpu_usage = 0.0` and `temp = 0.0`

---

## Solution Implemented

Changed from **scene switching** (destroying Main) to **scene adding** (preserving Main).

### Changes Made

#### 1. Updated launch_model_showcase()

**File:** `scripts/debug_controller.gd`

**Before:**
```gdscript
func launch_model_showcase():
    print("[DebugController] Launching Model Showcase...")
    get_tree().change_scene_to_file("res://scenes/model_showcase.tscn")
```

**After:**
```gdscript
func launch_model_showcase():
    print("[DebugController] Launching Model Showcase...")
    
    # Load the scene
    var showcase_scene = load("res://scenes/model_showcase.tscn")
    var showcase_instance = showcase_scene.instantiate()
    
    # Hide main scene UI
    var main = get_tree().root.get_node("Main")
    if main:
        # Hide UI elements
        if main.has_node("UI"):
            main.get_node("UI").visible = false
        if main.has_node("DebugController"):
            main.get_node("DebugController").visible = false
        
        # Add showcase as child of root (so it's at same level as Main)
        get_tree().root.add_child(showcase_instance)
        
        print("[DebugController] Model Showcase launched (Main scene preserved)")
    else:
        print("[DebugController] ERROR: Could not find Main scene")
```

**Key Changes:**
- Load scene with `load()` and `instantiate()` instead of `change_scene_to_file()`
- Hide Main's UI elements (not destroy them)
- Add showcase as sibling to Main (both children of root)
- Main scene and its systems remain active

#### 2. Added _exit_tree() Cleanup

**File:** `scripts/model_showcase.gd`

```gdscript
func _exit_tree():
    """Cleanup when showcase ends - restore Main scene UI"""
    print("[ModelShowcase] Cleaning up...")
    
    var main = get_tree().root.get_node_or_null("Main")
    if main:
        # Restore UI elements
        if main.has_node("UI"):
            main.get_node("UI").visible = true
        if main.has_node("DebugController"):
            main.get_node("DebugController").visible = true
        
        print("[ModelShowcase] Main scene UI restored")
```

**Purpose:**
- Automatically called when showcase is removed from tree
- Restores Main's UI visibility
- Ensures clean transition back to Main

#### 3. Updated export_results() to Return

**File:** `scripts/model_showcase.gd`

**Added at end of function:**
```gdscript
    print("[ModelShowcase] Benchmark complete - returning to Main scene")
    
    # Remove ourselves from the tree (triggers _exit_tree)
    queue_free()
```

**Purpose:**
- Automatically returns to Main after benchmark completes
- Triggers `_exit_tree()` for cleanup
- User sees Main scene UI again

#### 4. Updated ESC Handler

**File:** `scripts/model_showcase.gd`

**Before:**
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        print("\n[ModelShowcase] Cancelled by user")
        get_tree().change_scene_to_file("res://scenes/main.tscn")
```

**After:**
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        print("\n[ModelShowcase] Cancelled by user")
        queue_free()
```

**Purpose:**
- ESC key now properly returns to Main
- Uses `queue_free()` instead of scene switching
- Triggers cleanup via `_exit_tree()`

---

## How It Works Now

### Scene Hierarchy

**Before (scene switching):**
```
Root
└── Main (destroyed when M pressed)
    ├── perf_monitor
    ├── quality_manager
    └── platform_detector

After M pressed:
Root
└── ModelShowcase (Main is gone, systems destroyed)
```

**After (scene adding):**
```
Root
├── Main (preserved, systems still active)
│   ├── perf_monitor ✓
│   ├── quality_manager ✓
│   ├── platform_detector ✓
│   ├── UI (hidden)
│   └── DebugController (hidden)
└── ModelShowcase (can access Main's systems)
```

### System Access Flow

1. **Launch (M key pressed):**
   - Main scene UI hidden
   - ModelShowcase added to root
   - Main scene remains active

2. **During Benchmark:**
   ```gdscript
   var main = get_tree().root.get_node_or_null("Main")
   if main:
       perf_monitor = main.perf_monitor  # ✓ Found!
       gpu_usage = perf_monitor.get_gpu_usage()  # ✓ Works!
       temp = perf_monitor.get_temperature()  # ✓ Works!
   ```

3. **After Benchmark:**
   - `export_results()` calls `queue_free()`
   - `_exit_tree()` restores Main's UI
   - User sees Main scene again

---

## Expected Results

### Console Output

**Before Fix:**
```
[ModelShowcase] Starting 1-Minute Benchmark
[ModelShowcase] WARNING: Main scene not found, using fallback metrics
```

**After Fix:**
```
[DebugController] Launching Model Showcase...
[DebugController] Model Showcase launched (Main scene preserved)
[ModelShowcase] Starting 1-Minute Benchmark
[ModelShowcase] Systems found: perf=true, quality=true, platform=true
[ModelShowcase] Quality preset: Medium
[PerformanceMonitor] Windows CPU calc: frametime=17.65ms
[PerformanceMonitor] CPU usage set to: 44.5%
[PerformanceMonitor] GPU usage set to: 35.6%
```

### JSON Output

**Before Fix:**
```json
{
    "per_second": [
        {
            "second": 1,
            "fps": 56.79,
            "gpu": 0.0,  ← Always 0
            "temp": 0.0  ← Always 0
        }
    ]
}
```

**After Fix (Windows):**
```json
{
    "per_second": [
        {
            "second": 1,
            "fps": 56.79,
            "gpu": 35.6,  ← Real value!
            "temp": 0.0   ← 0 on Windows (expected)
        }
    ]
}
```

**After Fix (Raspberry Pi):**
```json
{
    "per_second": [
        {
            "second": 1,
            "fps": 45.23,
            "gpu": 54.2,  ← Real value!
            "temp": 52.3  ← Real temperature!
        }
    ]
}
```

### UI Overlay

**Before Fix:**
- FPS: 56.8 (works)
- Frame: 17.65 ms (works)
- Temp: 0.0°C (broken)
- GPU: 0.0% (broken)

**After Fix:**
- FPS: 56.8 ✓
- Frame: 17.65 ms ✓
- Temp: 0.0°C (Windows) or 52.3°C (RPi) ✓
- GPU: 35.6% ✓

---

## Testing Instructions

### Quick Test

1. **Launch GodotMark:**
   ```bash
   cd godotmark
   # Open in Godot editor and run Main scene
   ```

2. **Press M to launch model showcase**

3. **Check console output:**
   - Should see: `[DebugController] Model Showcase launched (Main scene preserved)`
   - Should see: `[ModelShowcase] Systems found: perf=true, quality=true, platform=true`
   - Should see: `[PerformanceMonitor] CPU usage set to: XX.X%`
   - Should see: `[PerformanceMonitor] GPU usage set to: XX.X%`

4. **Watch UI overlay (top-left):**
   - CPU should update every 100ms (not stuck at 0%)
   - GPU should update every 100ms (not stuck at 0%)
   - Temperature should show 0.0°C on Windows (expected)

5. **Wait for benchmark to complete (60 seconds)**

6. **Check exported JSON:**
   ```bash
   # Windows: %APPDATA%\Godot\app_userdata\GodotMark\results\
   # Linux: ~/.local/share/godot/app_userdata/GodotMark/results/
   ```
   - Open latest `model_showcase_YYYYMMDD_HHMMSS.json`
   - Verify `gpu` values are non-zero
   - Verify `temp` values match platform

7. **Verify return to Main:**
   - After 60 seconds, should see Main scene UI again
   - Should see: `[ModelShowcase] Cleaning up...`
   - Should see: `[ModelShowcase] Main scene UI restored`

### ESC Key Test

1. Launch model showcase (press M)
2. Press ESC during benchmark
3. Should return to Main scene immediately
4. Should see cleanup messages

---

## Platform-Specific Expected Values

### Windows

| Metric | Expected Value | Source |
|--------|---------------|--------|
| **CPU** | 30-80% | Frame time approximation |
| **GPU** | 24-64% | 80% of CPU |
| **Temperature** | 0.0°C | Not available (expected) |

### Raspberry Pi

| Metric | Expected Value | Source |
|--------|---------------|--------|
| **CPU** | 40-90% | Real from `/proc/stat` |
| **GPU** | 32-72% | 80% of CPU |
| **Temperature** | 45-75°C | Real from `/sys` or `vcgencmd` |

---

## Troubleshooting

### Issue: Still Showing 0 for GPU/Temp

**Check console for:**
```
[ModelShowcase] Systems found: perf=false, quality=false, platform=false
```

**Solution:** Main scene wasn't found. Verify:
1. You're running from Main scene (not model_showcase directly)
2. Main scene is named "Main" in the scene tree
3. You pressed M (not running model_showcase.tscn directly)

### Issue: UI Doesn't Return After Benchmark

**Check console for:**
```
[ModelShowcase] Benchmark complete - returning to Main scene
[ModelShowcase] Cleaning up...
[ModelShowcase] Main scene UI restored
```

**Solution:** If messages are missing:
1. Check if `export_results()` is being called
2. Verify `queue_free()` is at end of `export_results()`
3. Verify `_exit_tree()` function exists

### Issue: Main Scene UI Still Visible During Benchmark

**Check console for:**
```
[DebugController] Model Showcase launched (Main scene preserved)
```

**Solution:** If Main UI is still visible:
1. Verify Main has "UI" and "DebugController" nodes
2. Check node names match exactly (case-sensitive)
3. Manually hide them in `launch_model_showcase()` if needed

---

## Benefits of This Approach

### 1. Preserves Performance Monitoring
- perf_monitor continues running
- Real-time CPU/GPU/temperature data
- Accurate metrics in exported JSON

### 2. Maintains Quality Management
- Adaptive quality system still active
- Can adjust settings during benchmark
- Consistent quality presets

### 3. Platform Detection Available
- Can query platform info
- Driver status checks work
- Platform-specific optimizations enabled

### 4. Clean Transitions
- No scene reload overhead
- Smooth UI transitions
- Automatic cleanup on exit

### 5. Better User Experience
- Returns to Main after benchmark
- ESC key works properly
- No manual scene navigation needed

---

## Files Modified

1. **scripts/debug_controller.gd**
   - Changed `launch_model_showcase()` to add scene instead of switching
   - Hides Main UI during benchmark
   - Preserves Main scene and systems

2. **scripts/model_showcase.gd**
   - Added `_exit_tree()` cleanup function
   - Added `queue_free()` at end of `export_results()`
   - Updated ESC handler to use `queue_free()`

---

**Implementation Date:** January 13, 2026  
**Status:** Complete and ready for testing  
**Result:** Model showcase now has full access to performance monitoring systems with proper GPU and temperature readings!


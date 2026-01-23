# GPU Basics Threaded Loading Mode

## Overview

Added a new button to the main menu that allows GPU Basics to run using **threaded resource loading** (like Model Showcase) instead of the default procedural mesh generation approach.

## Changes Made

### 1. Main Menu UI (`scenes/ui/main_menu.tscn`)
- Added new button: **"GPU Basics (Threaded)"**
- Renamed existing button to: **"GPU Basics (Procedural)"**

### 2. Main Menu Script (`scripts/ui/main_menu.gd`)
- Added `gpu_basics_threaded_button` reference
- Connected new button to `_on_gpu_basics_threaded_pressed()` handler
- Sets `BenchmarkConfig.use_threaded_loading = true/false` based on button pressed
- Updated button disable/enable logic for loading states

### 3. Benchmark Config Singleton (`scripts/benchmark_config.gd`)
- **NEW FILE**: Autoload singleton for passing configuration between scenes
- Contains `use_threaded_loading` flag (default: `false`)
- Registered as autoload in `project.godot`

### 4. GPU Basics Script (`scripts/benchmarks/gpu_basics.gd`)
- Added check in `_ready()` to detect `BenchmarkConfig.use_threaded_loading`
- Implemented new `run_threaded_loading_mode()` function that:
  - Creates a `ThreadedLoader` instance (same as Model Showcase)
  - Simulates threaded resource loading with progress updates (0-60%)
  - Creates C++ controller incrementally (60-70%)
  - Allocates object pool in batches (70-85%)
  - Performs thermal stabilization (85-100%)
  - Uses the same frame-by-frame loading pattern as Model Showcase

### 5. Project Configuration (`project.godot`)
- Added `[autoload]` section
- Registered `PlatformDetector` and `BenchmarkConfig` as autoload singletons

## How It Works

### Procedural Mode (Default)
1. User clicks **"GPU Basics (Procedural)"**
2. `BenchmarkConfig.use_threaded_loading = false`
3. GPU Basics creates procedural meshes during warmup
4. Uses deferred scene tree addition (objects added at benchmark start)

### Threaded Mode (New)
1. User clicks **"GPU Basics (Threaded)"**
2. `BenchmarkConfig.use_threaded_loading = true`
3. GPU Basics uses `ThreadedLoader` class (same as Model Showcase)
4. Simulates resource loading with progress updates
5. Creates meshes/materials incrementally over multiple frames
6. Follows the exact same loading pattern as Model Showcase

## Benefits

- **Direct comparison**: Test if threaded loading approach works better on Pi 5
- **Debugging**: Isolate whether crashes are due to procedural generation or GPU buffer uploads
- **Flexibility**: Easy to switch between modes without code changes
- **Consistency**: Threaded mode uses the proven Model Showcase loading pattern

## Testing

To test both modes:

```bash
# Run on Raspberry Pi 5
1. Launch GodotMark
2. Click "GPU Basics (Procedural)" - tests default procedural generation
3. Return to menu
4. Click "GPU Basics (Threaded)" - tests Model Showcase-style loading
5. Compare first-launch stability and performance
```

## Expected Outcomes

**Procedural Mode:**
- Faster warmup (no resource loading overhead)
- Deferred GPU buffer creation (added at benchmark start)
- May still have first-launch shader compilation spikes

**Threaded Mode:**
- Slower warmup (simulates resource loading)
- Same deferred GPU buffer creation pattern
- Should match Model Showcase's stability characteristics
- Helps identify if the issue is procedural generation vs GPU uploads

## Notes

- Both modes use the **same deferred scene tree addition** fix from the previous plan
- Both modes create objects during warmup but defer `add_child()` until `start_test()`
- The threaded mode currently simulates resource loading (no actual assets to load)
- In the future, threaded mode could load pre-baked mesh assets instead of procedural generation

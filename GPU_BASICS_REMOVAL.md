# GPU Basics Removal Summary

**Date:** January 23, 2026  
**Reason:** GPU Basics benchmark was not working properly and has been removed from the project.

---

## Files Removed

### GDScript Files
- `scripts/benchmarks/gpu_basics.gd` - Main GPU Basics script
- `scripts/benchmarks/gpu_basics.gd.uid` - UID file
- `scripts/ui/gpu_basics_overlay.gd` - GPU Basics overlay script
- `scripts/ui/gpu_basics_overlay.gd.uid` - UID file
- `scripts/benchmark_config.gd` - Autoload singleton (only used by GPU Basics)

### Scene Files
- `scenes/benchmarks/01_gpu_basics.tscn` - GPU Basics scene
- `scenes/ui/gpu_basics_overlay.tscn` - GPU Basics overlay scene

### C++ Files
- `src/benchmarks/scenes/gpu_basics.h` - GPU Basics C++ header
- `src/benchmarks/scenes/gpu_basics.cpp` - GPU Basics C++ implementation
- `src/benchmarks/scenes/gpu_basics.os` - Compiled object file
- `src/benchmarks/scenes/gpu_basics.windows.template_debug.x86_64.obj` - Windows debug object
- `src/benchmarks/scenes/gpu_basics.windows.template_release.x86_64.obj` - Windows release object
- `src/benchmarks/scenes/gpu_basics.windows.template_debug.x86_64.obj.import` - Import file

### Documentation Files
- `GPU_BASICS_PERFORMANCE_OPTIMIZATION.md` - Performance optimization docs
- `GPU_BASICS_METRICS_IMPLEMENTATION.md` - Metrics implementation docs
- `THREADED_LOADING_MODE.md` - Threaded loading mode docs
- `PI5_STARTUP_STUTTER_FIX.md` - Pi5 startup stutter fix docs

---

## Code Changes

### `scenes/ui/main_menu.tscn`
- Removed "GPU Basics (Procedural)" button
- Removed "GPU Basics (Threaded)" button

### `scripts/ui/main_menu.gd`
- Removed `@onready var gpu_basics_button`
- Removed `@onready var gpu_basics_threaded_button`
- Removed `_on_gpu_basics_pressed()` function
- Removed `_on_gpu_basics_threaded_pressed()` function
- Removed button signal connections
- Removed button disable/enable logic for GPU Basics buttons

### `src/register_types.cpp`
- Removed `#include "benchmarks/scenes/gpu_basics.h"`
- Removed `ClassDB::register_class<GPUBasicsScene>();`

### `src/benchmark_orchestrator.h`
- Changed default scene name from `"gpu_basics"` to `"model_showcase"`

### `src/benchmark_orchestrator.cpp`
- Changed default scene name from `"gpu_basics"` to `"model_showcase"`

### `project.godot`
- Removed `BenchmarkConfig` autoload (was only used by GPU Basics)

### `README.md`
- Updated benchmark scenes roadmap to reference "Model Showcase" instead of "GPU Basics"

---

## What Remains

The project now focuses on:
- ✅ **Model Showcase** - The primary benchmark scene (working correctly)
- 🚧 Future benchmark scenes (physics, particles, lighting, etc.)

---

## Build Status

✅ **Build successful** after removal  
✅ All references cleaned up  
✅ No compilation errors  

The project is now cleaner and focused on the working Model Showcase benchmark.

---

## Notes

- Historical documentation files (STATUS_REPORT.md, NEXT_STEPS.md, etc.) still reference GPU Basics but are kept for historical context
- The C++ infrastructure (ProgressiveStressTest, AdaptiveQualityManager, etc.) remains intact and can be used by future benchmarks
- Main menu now only shows "Model Showcase" and "Full Suite (Coming Soon)" options


# Changelog

All notable changes to GodotMark will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Procedural rock generator for Nature Island benchmark (~80 triangles vs 500K+ in GLTF assets)
- Elliptical island ground mesh for more realistic appearance
- Shader performance guidelines documentation (`SHADER_PERFORMANCE_GUIDE.md`)
- Ocean shader performance testing framework
- Systematic diagnostic plan for performance issues

### Changed
- Nature Island now uses procedural rocks instead of photogrammetry-scanned GLTF assets
- Island shape changed from rectangular (30×60m) to elliptical (25×50m)
- Asset distribution uses elliptical zones for more natural placement
- Coastal rocks now properly constrained within island boundaries (max 80% radius)
- Trees increased from 10 to 12 for better visual density
- Rocks increased from 6 to 10 for more realistic coastline

### Fixed
- **CRITICAL:** Nature Island 4.5 FPS bottleneck - root cause was GLTF rock assets with 500K-1M triangles each
- Texture compression not applied (221 textures were using Lossless mode=4 instead of VRAM mode=2)
- Empty `wind_vegetation.gdshader` file causing rendering errors
- Assets spawning outside island boundaries
- Parse error in `nature_island.gd` from malformed function definition

### Performance
- Triangle count reduced from 5M to ~5.5K (99.9% reduction)
- VRAM texture usage reduced by ~90% (mode 4→2 compression)
- Nature Island FPS improved from 4.5 to 30+ FPS on Raspberry Pi 5

---

## [0.1.0-alpha] - 2026-02-08

### Added
- **Model Showcase Benchmark** - 60-second GPU stress test with PBR materials (WORKING ✅)
- **Nature Island Benchmark** - 60-second draw call efficiency test (WORKING after fixes ✅)
- Performance monitoring with CPU/GPU metrics
- Adaptive quality management system
- Platform detection for Raspberry Pi 4/5, Orange Pi, Rock 5B
- Threaded asset loading system
- Loading screens with progress indicators
- Main menu with benchmark selection
- Settings menu with quality presets
- Cinematic camera system with keyframe animation
- Wind animation shaders for trees and vegetation
- Metrics overlay with real-time FPS/frame time display
- Audio integration for benchmarks
- Fade transitions between scenes

### Performance Optimizations

#### Physics Server Optimization
- **Problem:** 15.7ms/frame overhead despite no physics bodies
- **Solution:** Disabled PhysicsServer3D globally in benchmarks
- **Impact:** -15.7ms/frame on Raspberry Pi
- **Files:** All benchmark scripts (`_ready()` function)
- **Reference:** `PHYSICS_BOTTLENECK_FIX.md`

#### Rendering Backend Switch
- **Problem:** Vulkan Mobile driver overhead on Raspberry Pi (CPU-bound)
- **Solution:** Switched from Vulkan to OpenGL ES 3.0 (gl_compatibility)
- **Impact:** ~2× FPS improvement on RPi (42 FPS → 75+ FPS on minimal scene)
- **Files:** `project.godot` (`renderer/rendering_method`)
- **Reference:** `VULKAN_OVERHEAD_RPI.md`, `RASPBERRY_PI_PERFORMANCE_FIX.md`

#### Texture Compression
- **Problem:** 1K uncompressed textures = 1.25 GB VRAM, saturated memory bandwidth
- **Solution:** Applied VRAM compression (S3TC/ETC2), 512×512 downscale, mipmaps
- **Impact:** 94% VRAM reduction (1.25 GB → 74 MB), 10 FPS → 60 FPS on desktop
- **Files:** `optimize_for_raspberry_pi.ps1`, `fix_texture_compression.ps1`
- **Reference:** `TEXTURE_COMPRESSION_FIX.md`

#### Triangle Budget Management
- **Problem:** Initial GLTF assets = 457K triangles (45× over RPi 4's 10K budget)
- **Solution:** Reduced object counts, removed complex models, used procedural generation
- **Impact:** 98.7% triangle reduction (457K → 5.6K)
- **Files:** `nature_island.gd`, `procedural_rocks.gd`
- **Reference:** `RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`

#### Draw Call Reduction
- **Problem:** 15+ individual MultiMeshInstance3D nodes = high ARM GPU overhead
- **Solution:** Merged instances into 4 combined MultiMeshes
- **Impact:** 73% draw call reduction (15 → 4)
- **Files:** `nature_island.gd` (`create_combined_multimesh()`)
- **Reference:** `DRAW_CALL_OPTIMIZATION.md`

#### Shader Optimization
- **Problem:** Per-pixel lighting too expensive on VideoCore VI/VII
- **Solution:** Switched to per-vertex lighting (`shading_mode = 2`)
- **Impact:** Reduced GPU fragment processing load
- **Files:** All materials, wind shaders (`render_mode diffuse_lambert, specular_disabled`)
- **Reference:** `SHADER_PERFORMANCE_GUIDE.md`

#### Post-Processing Removal
- **Problem:** SSAO and Glow expensive on mobile GPU
- **Solution:** Disabled `ssao_enabled` and `glow_enabled`
- **Impact:** Reduced GPU load on Raspberry Pi
- **Files:** Scene environments (`WorldEnvironment`)
- **Reference:** `PERFORMANCE_FIX_10FPS.md`

#### Garbage Collection Optimization
- **Problem:** GC pauses during benchmark from dynamic array growth
- **Solution:** Pre-allocated all performance metric arrays
- **Impact:** Eliminated mid-benchmark stutters
- **Files:** `nature_island.gd`, `model_showcase.gd` (`_ready()`)
- **Reference:** `GC_OPTIMIZATION_COMPLETE.md`

#### Debug Overhead Removal
- **Problem:** Verbose logging causing frame drops
- **Solution:** Removed excessive print statements in hot paths
- **Impact:** Reduced CPU overhead
- **Files:** Various benchmark scripts
- **Reference:** `DEBUG_OVERHEAD_REMOVED.md`

### Build System

#### Raspberry Pi 5 Support
- **Added:** Native ARM64 build support for Raspberry Pi 5
- **Added:** V3D driver stack setup script (`install_v3d_stack.sh`)
- **Added:** Automated build verification
- **Files:** `BUILD_RPI5.md`, `V3D_DRIVER_SETUP.md`, `RPi5_BUILD_INSTRUCTIONS.md`
- **Reference:** `BUILD_SUCCESS_RPI5.md`

#### C++ Build Fixes
- **Fixed:** RTTI disabled errors in GDExtension
- **Fixed:** Missing type_traits includes
- **Fixed:** SCons build configuration
- **Files:** `SConstruct`, C++ source files
- **Reference:** `BUILD_FIX.md`, `RTTI_FIX.md`

### UI/UX Improvements

#### Metrics Overlay
- **Fixed:** CPU/GPU labels showing incorrect placeholder text
- **Fixed:** Temperature readings not displaying
- **Added:** Dynamic benchmark title support
- **Files:** `model_showcase_overlay.gd`, `model_showcase_overlay.tscn`
- **Reference:** `CPU_GPU_UI_FIX.md`, `MODEL_SHOWCASE_UI_FIXES.md`

#### Settings Menu
- **Added:** Quality preset selection (Low, Medium, High, Ultra)
- **Added:** V3D driver status display
- **Added:** Platform detection display
- **Files:** `settings_menu.tscn`, `settings_menu.gd`
- **Reference:** `SETTINGS_MENU_IMPLEMENTATION.md`

#### Audio & Splash
- **Added:** UI sound effects (hover, click)
- **Added:** Splash screen with project logo
- **Files:** `ui_sounds.gd`, `splash_screen.tscn`
- **Reference:** `UI_SOUNDS_AND_SPLASH_IMPLEMENTATION.md`

### Code Quality

#### Style Guides
- **Added:** GDScript style guide
- **Added:** C++ style guide (Google C++ Style)
- **Added:** Code formatting guide
- **Files:** `CODE_FORMATTING_GUIDE.md`, `CPP_STYLE_GUIDE.md`, `STYLE_GUIDE_SETUP.md`
- **Reference:** `FORMATTING_SUMMARY.md`

#### Addon Cleanup
- **Removed:** Godot Jolt physics addon (unused)
- **Reason:** PhysicsServer3D disabled for performance
- **Files:** `addons/godot-jolt/` (deleted)
- **Reference:** `ADDON_FIXES.md`

### Documentation

#### Comprehensive Guides
- **Added:** Complete optimization story with all attempts and failures (`COMPLETE_OPTIMIZATION_STORY.md`)
- **Added:** Raspberry Pi 4 model optimization analysis (`RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`)
- **Added:** Shader performance guidelines for mobile GPUs (`SHADER_PERFORMANCE_GUIDE.md`)
- **Added:** Step-by-step optimization guide (`OPTIMIZATION_COMPLETE_GUIDE.md`)
- **Added:** Testing guide (`TESTING_GUIDE.md`)
- **Added:** Build and run instructions (`BUILD_AND_RUN.md`)

#### Investigation Reports
- **Added:** Mystery solved report for 4.5 FPS issue (`MYSTERY_SOLVED_ROCKS.md`)
- **Added:** Ocean shader performance test results (`OCEAN_SHADER_PERFORMANCE_TEST.md`)
- **Added:** Diagnostic plan for systematic testing (`NATURE_ISLAND_DIAGNOSTIC_PLAN.md`)
- **Added:** Visual comparison of rendering pipelines (`OCEAN_SHADER_VISUAL_COMPARISON.md`)

#### Community Guides
- **Added:** Contributing guidelines (`CONTRIBUTING.md`)
- **Added:** Security policy (`SECURITY.md`)
- **Added:** GitHub workflow security documentation (`.github/WORKFLOW_SECURITY.md`)
- **Added:** Good First Issues creation guide (`.github/GOOD_FIRST_ISSUES_GUIDE.md`)
- **Added:** Bot setup instructions (`.github/BOT_SETUP.md`)

### Security

#### GitHub Actions
- **Added:** PR security checks (TruffleHog, Dependency Review)
- **Added:** Harden-Runner for workflow security
- **Added:** GDScript linting
- **Added:** Documentation checks
- **Files:** `.github/workflows/pr-check.yml`
- **Reference:** `.github/WORKFLOW_SECURITY.md`

#### Best Practices
- **Added:** Action pinning to SHAs
- **Added:** Minimal token permissions
- **Added:** Pull request trigger (no push/workflow_run)
- **Added:** First-time contributor approval requirement

### Community

#### Bot Integration (Ready for Installation)
- **Configured:** All-Contributors Bot (`.all-contributorsrc`)
- **Configured:** Welcome Bot (`.github/config.yml`)
- **Configured:** First Timers Bot support
- **Added:** Installation checklist (`.github/BOT_INSTALLATION_CHECKLIST.md`)
- **Reference:** `.github/BOT_SETUP.md`, `.github/PHASE_2_COMPLETE.md`

#### Issue Templates
- **Added:** Bug report template (`.github/ISSUE_TEMPLATE/bug_report.md`)
- **Added:** Feature request template (`.github/ISSUE_TEMPLATE/feature_request.md`)

#### Good First Issues (Ready to Create)
- **Created:** 15 beginner-friendly issue templates
- **Added:** Automation scripts (`create_issues.sh`, `create_issues.ps1`)
- **Files:** `.github/ISSUES_TO_CREATE.md`, `.github/GOOD_FIRST_ISSUES_GUIDE.md`

---

## Investigation Timeline (February 8, 2026)

This section documents the systematic investigation of the Nature Island 4.5 FPS issue:

### Test 1: Ocean Shader (FAILED)
- **Hypothesis:** Custom fragment shader with per-pixel math causing bottleneck
- **Test:** Replaced ShaderMaterial with StandardMaterial3D
- **Result:** FPS remained at 4.5
- **Conclusion:** Not the ocean shader
- **Reference:** `OCEAN_SHADER_PERFORMANCE_TEST.md`, `INVESTIGATION_OCEAN_SHADER_FAILED.md`

### Test 2: Wind Shaders (FAILED)
- **Hypothesis:** Vertex shader animation too expensive
- **Test:** Disabled wind_trees.gdshader and wind_vegetation.gdshader
- **Result:** FPS remained at 4.5
- **Conclusion:** Not the wind shaders
- **Discovery:** `wind_vegetation.gdshader` was empty (0 bytes), fixed

### Test 3: Minimal Base Scene (PASSED)
- **Hypothesis:** Base scene (ocean, ground, camera, light) has issues
- **Test:** Created minimal scene with no nature assets
- **Result:** 30+ FPS ✅
- **Conclusion:** Base scene is fine, problem is in nature assets

### Test 4: Texture Compression (PARTIAL)
- **Discovery:** 221 textures using Lossless (mode=4) instead of VRAM (mode=2)
- **Action:** Fixed all texture imports with `fix_texture_compression.ps1`
- **Result:** Improved desktop performance, but issue persisted on RPi
- **Conclusion:** Necessary but not sufficient fix

### Test 5: Rocks - THE SMOKING GUN (SOLVED ✅)
- **Observation:** User reported "rocks tank frames"
- **Hypothesis:** Rocks are too complex
- **Test:** Disabled rocks entirely
- **Result:** FPS immediately improved! ✅
- **Investigation:** 
  - `coast_rocks_01.bin`: 348,785 vertices, 679,936 triangles
  - `coast_rocks_02.bin`: ~1M+ triangles (35 MB file)
  - `coast_rocks_03.bin`: ~750K triangles (22.5 MB file)
  - **Total with 6 instances: ~5 MILLION triangles**
- **Root Cause:** GLTF rocks were photogrammetry scans, not game assets
- **Solution:** Created procedural rock generator (~80 triangles each)
- **Result:** 30+ FPS on Raspberry Pi 5 ✅
- **Reference:** `MYSTERY_SOLVED_ROCKS.md`

---

## Architecture Changes

### Benchmark Structure
- **Model Showcase:** 5-phase progressive complexity test (0-60s)
  - Phase 1: Base model (0-12s)
  - Phase 2: Enhanced materials (12-24s)
  - Phase 3: Particle effects (24-36s)
  - Phase 4: Dynamic lighting (36-48s)
  - Phase 5: Maximum complexity (48-60s)

- **Nature Island:** 5-phase outdoor rendering test (0-60s)
  - Phase 1: Trees only (0-12s)
  - Phase 2: Add rocks (12-24s)
  - Phase 3: Add vegetation (24-36s)
  - Phase 4: Wind animation (36-48s)
  - Phase 5: Maximum complexity (48-60s)

### Performance Monitoring
- **C++ GDExtension:** PerformanceMonitor for CPU/GPU/temp metrics
- **Platform Detection:** Automatic hardware identification
- **Quality Management:** Adaptive quality system (not yet active)
- **Metrics Export:** JSON export of per-frame data

---

## Known Issues

### High Priority
- ~~Nature Island 4.5 FPS on Raspberry Pi~~ ✅ **SOLVED** (photogrammetry rocks)
- Adaptive quality system not yet active (needs tuning)
- Temperature monitoring shows 0°C on some platforms

### Medium Priority
- GPU usage shows 0% on Raspberry Pi (driver limitation)
- Loading screen progress sometimes jumps
- Camera keyframes could be smoother

### Low Priority
- Model Showcase particle effects not optimized for RPi
- Audio could be better synced to phases
- Metrics export filename could be more descriptive

---

## Removed Documentation Files

The following documentation files have been consolidated into this CHANGELOG and can be safely archived or removed:

### Build & Fix Logs (Consolidated)
- `BUILD_FIX.md` - Build system fixes
- `RTTI_FIX.md` - C++ RTTI configuration
- `BUILD_LOG_ANALYSIS.md` - Build error analysis
- `BUILD_SUCCESS_RPI5.md` - Raspberry Pi 5 build success
- `FIXES_APPLIED.md` - General fixes log
- `VERIFY_BUILD.md` - Build verification steps
- `CHECK_BUILD_STATUS.md` - Build status checks

### Status Reports (Consolidated)
- `CURRENT_STATUS.md` - Project status snapshot
- `STATUS_REPORT.md` - Another status report
- `SUCCESS_REPORT.md` - Success milestone report
- `WHATS_NEW.md` - New features list
- `NEXT_STEPS.md` - Future work
- `START_HERE.md` - Old getting started guide
- `START_HERE_MODEL_SHOWCASE.md` - Model Showcase intro

### Implementation Logs (Consolidated)
- `IMPLEMENTATION_COMPLETE.md` - Generic completion log
- `IMPLEMENTATION_SUMMARY.md` - Implementation summary
- `PROFILING_IMPLEMENTATION_COMPLETE.md` - Profiling system completion
- `THREADED_LOADING_IMPLEMENTATION.md` - Threaded loading details
- `THREADED_LOADING_ALL_SCENES.md` - Multi-scene threading
- `WARMUP_PHASE_COMPLETE.md` - Warmup implementation
- `PHASE_1_2_OPTIMIZATION_COMPLETE.md` - Phase optimization log
- `MODEL_SHOWCASE_IMPLEMENTATION.md` - Model Showcase setup
- `SETTINGS_MENU_IMPLEMENTATION.md` - Settings menu log
- `UI_SOUNDS_AND_SPLASH_IMPLEMENTATION.md` - UI/UX additions

### Fix Logs (Consolidated)
- `DEBUG_CONTROLS_FIX.md` - Debug control fixes
- `PLATFORM_DETECTOR_FIX.md` - Platform detection fixes
- `GPU_BASICS_REMOVAL.md` - GPU Basics benchmark removal
- `MODEL_SHOWCASE_REALTIME_FIX.md` - Real-time metrics fix
- `MODEL_SHOWCASE_STANDALONE_FIX.md` - Standalone mode fix
- `TEMP_GPU_FIX_COMPLETE.md` - Temperature/GPU display fix
- `CPU_LABEL_AND_TEMP_FIX.md` - CPU label fix
- `ADAPTIVE_QUALITY_FIX.md` - Quality system fix
- `ADDON_FIXES.md` - Addon cleanup
- `DEBUG_OVERHEAD_REMOVED.md` - Debug logging cleanup
- `GC_OPTIMIZATION_COMPLETE.md` - Garbage collection fix
- `GROUND_ASSET_FIX_COMPLETE.md` - Ground mesh fix

### Nature Island Iterations (Consolidated)
- `NATURE_ISLAND_PRIMITIVE_MESHES.md` - Primitive mesh attempt
- `NATURE_ISLAND_CLOSE_RANGE_FIX.md` - Camera distance fix
- `NATURE_ISLAND_RASPBERRY_PI_OPTIMIZED.md` - RPi optimization
- `NATURE_ISLAND_REALISTIC_COMPLETE.md` - Realistic assets attempt
- `NATURE_BENCHMARK_REDESIGN.md` - Benchmark restructure

### Model Showcase Updates (Consolidated)
- `MODEL_SHOWCASE_UPDATES.md` - General updates
- `MODEL_SHOWCASE_IMPROVEMENTS.md` - Improvements log
- `MODEL_SHOWCASE_UI_FIXES.md` - UI fixes
- `MODEL_SHOWCASE_GUIDE.md` - User guide
- `MODEL_SHOWCASE_TESTING.md` - Testing notes

### Misc (Consolidated)
- `ERROR_CHECK_RESULTS.md` - Error check log
- `LARGE_ASSETS_EXCLUDED.md` - Asset exclusion notes
- `RELOAD_PROJECT_INSTRUCTIONS.md` - Reload instructions
- `VERSIONING.md` - Version numbering

### Style Guides (Keep - Still Relevant)
- `CODE_FORMATTING_GUIDE.md` ✅ **KEEP**
- `CPP_STYLE_GUIDE.md` ✅ **KEEP**
- `STYLE_GUIDE_SETUP.md` ✅ **KEEP**
- `FORMATTING_SUMMARY.md` ✅ **KEEP**

### Core Documentation (Keep - Still Relevant)
- `README.md` ✅ **KEEP**
- `CONTRIBUTING.md` ✅ **KEEP**
- `SECURITY.md` ✅ **KEEP**
- `BUILD_AND_RUN.md` ✅ **KEEP**
- `TESTING_GUIDE.md` ✅ **KEEP**
- `V3D_DRIVER_SETUP.md` ✅ **KEEP**
- `RPi5_BUILD_INSTRUCTIONS.md` ✅ **KEEP**

### Investigation Reports (Keep - Historical Value)
- `COMPLETE_OPTIMIZATION_STORY.md` ✅ **KEEP** (comprehensive narrative)
- `MYSTERY_SOLVED_ROCKS.md` ✅ **KEEP** (critical discovery)
- `SHADER_PERFORMANCE_GUIDE.md` ✅ **KEEP** (technical reference)
- `OCEAN_SHADER_PERFORMANCE_TEST.md` ✅ **KEEP** (test methodology)
- `OCEAN_SHADER_VISUAL_COMPARISON.md` ✅ **KEEP** (visual explanation)
- `NATURE_ISLAND_DIAGNOSTIC_PLAN.md` ✅ **KEEP** (systematic approach)
- `INVESTIGATION_OCEAN_SHADER_FAILED.md` ✅ **KEEP** (negative results important)

### Performance Deep Dives (Keep - Technical Reference)
- `PHYSICS_BOTTLENECK_FIX.md` ✅ **KEEP**
- `TEXTURE_COMPRESSION_FIX.md` ✅ **KEEP**
- `PERFORMANCE_FIX_10FPS.md` ✅ **KEEP**
- `RASPBERRY_PI_PERFORMANCE_FIX.md` ✅ **KEEP**
- `RASPBERRY_PI_4_MODEL_OPTIMIZATION.md` ✅ **KEEP**
- `DRAW_CALL_OPTIMIZATION.md` ✅ **KEEP**
- `VULKAN_OVERHEAD_RPI.md` ✅ **KEEP**
- `OPTIMIZATION_COMPLETE_GUIDE.md` ✅ **KEEP**

### Community Files (Keep - Active)
- `.github/GOOD_FIRST_ISSUES_GUIDE.md` ✅ **KEEP**
- `.github/ISSUES_TO_CREATE.md` ✅ **KEEP**
- `.github/BOT_SETUP.md` ✅ **KEEP**
- `.github/BOT_INSTALLATION_CHECKLIST.md` ✅ **KEEP**
- `.github/PHASE_2_COMPLETE.md` ✅ **KEEP**
- `.github/WORKFLOW_SECURITY.md` ✅ **KEEP**
- `.github/ISSUE_OCEAN_SHADER_OPTIMIZATION.md` ✅ **KEEP** (issue template)

---

## Credits

### Research Sources
- Big Mess o' Wires - Raspberry Pi GPU testing
- Raspberry Pi Forums - OpenGL capabilities
- Official Godot Documentation - Performance best practices
- VideoCore VI/VII Documentation - GPU specifications
- ARM Mali GPU Best Practices - Mobile GPU optimization

### Contributors
- All Contributors Bot (ready for installation)
- Community contributions welcome!

---

## Future Releases

### v0.2.0 (Planned)
- Orange Pi 5 support
- Rock 5B support
- Adaptive quality auto-tuning
- More benchmark scenarios
- Export metrics to CSV/PNG graphs

### v1.0.0 (Goal)
- Stable performance on all target platforms
- Comprehensive hardware support
- Automated regression testing
- Community-contributed benchmarks

---

**Last Updated:** February 8, 2026  
**Current Version:** 0.1.0-alpha  
**Status:** Active Development

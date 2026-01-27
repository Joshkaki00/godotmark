# Good First Issues to Create

This document contains 15 beginner-friendly issues to create on GitHub. Copy each one into a new GitHub Issue.

---

## Issue #1: [good first issue] Add FPS counter to Main Menu

**Labels:** `good first issue`, `UI`, `beginner friendly`, `GDScript`

**Title:** Add FPS counter to Main Menu screen

**Description:**

Currently, the Main Menu doesn't show FPS. It would be helpful to see the FPS even before starting a benchmark.

**What needs to be done:**
1. Open `godotmark/scenes/ui/main_menu.tscn` in Godot
2. Add a Label node to display FPS (top-right corner suggested)
3. Open `godotmark/scripts/ui/main_menu.gd`
4. Add FPS calculation in `_process(delta)`:
   ```gdscript
   func _process(delta):
       var fps = Engine.get_frames_per_second()
       $FPSLabel.text = "FPS: " + str(fps)
   ```

**Files to modify:**
- `scenes/ui/main_menu.tscn` (add Label node)
- `scripts/ui/main_menu.gd` (add FPS logic)

**Difficulty:** ⭐ Easy  
**Estimated time:** 30 minutes - 1 hour  
**Skills needed:** Basic GDScript, Godot editor familiarity  
**Good for:** First-time Godot contributors  

**Acceptance criteria:**
- [ ] FPS displays in top-right corner of Main Menu
- [ ] Updates every frame
- [ ] Doesn't block other UI elements

**Resources:**
- [Godot FPS Counter Tutorial](https://docs.godotengine.org/en/stable/tutorials/performance/using_fps_counter.html)
- See `model_showcase_overlay.gd` for example FPS calculation

---

## Issue #2: [documentation] Create Troubleshooting Guide

**Labels:** `good first issue`, `documentation`, `no code required`

**Title:** Create TROUBLESHOOTING.md with common issues and solutions

**Description:**

We have lots of scattered information about problems and solutions. Let's consolidate it into one easy-to-find troubleshooting guide!

**What needs to be done:**
1. Create `godotmark/TROUBLESHOOTING.md`
2. Read through these existing docs and extract common issues:
   - `COMPLETE_OPTIMIZATION_STORY.md` (has many "what went wrong" sections)
   - `PERFORMANCE_FIX_10FPS.md`
   - `RASPBERRY_PI_PERFORMANCE_FIX.md`
   - GitHub Issues (search for "error", "crash", "slow")
3. Organize into categories:
   - Installation Issues
   - Performance Issues
   - Hardware-Specific Issues
   - Build Errors
   - Runtime Errors

**Example structure:**
```markdown
# Troubleshooting Guide

## Installation Issues

### Problem: Missing dependencies on Raspberry Pi
**Symptoms:** Build fails with "library not found"
**Solution:** Run `sudo apt-get install libgl1-mesa-dev...`

## Performance Issues

### Problem: Nature Island runs at 4.5 FPS
**Symptoms:** Very low FPS despite low CPU/GPU usage
**Status:** Known issue, under investigation
**Workarounds:** Run Model Showcase instead (works great!)
```

**Files to create:**
- `godotmark/TROUBLESHOOTING.md`

**Difficulty:** ⭐ Easy  
**Estimated time:** 2-3 hours  
**Skills needed:** Reading comprehension, Markdown  
**Good for:** People who want to contribute without coding  

**Acceptance criteria:**
- [ ] Document covers at least 10 common issues
- [ ] Each issue has: Symptoms, Cause (if known), Solution/Workaround
- [ ] Organized into clear categories
- [ ] Links to relevant detailed docs where applicable

**Bonus points:**
- Add a "Quick Diagnosis" flowchart
- Include terminal commands that can be copy-pasted

---

## Issue #3: [good first issue] Add temperature monitoring for Orange Pi 5

**Labels:** `good first issue`, `hardware: orange-pi`, `C++`, `help wanted`

**Title:** Add CPU/GPU temperature monitoring for Orange Pi 5

**Description:**

GodotMark currently monitors temperature on Raspberry Pi, but not on Orange Pi 5. The code is mostly the same!

**What needs to be done:**
1. Open `godotmark/src/platform/platform_detector.cpp`
2. Find the Raspberry Pi temperature reading code (around line 150-200)
3. Add Orange Pi detection:
   ```cpp
   // Orange Pi 5 detection
   std::ifstream cpuinfo("/proc/cpuinfo");
   std::string line;
   while (std::getline(cpuinfo, line)) {
       if (line.find("Rockchip RK3588") != std::string::npos) {
           return PlatformType::ORANGE_PI_5;
       }
   }
   ```
4. Add temperature reading for Orange Pi (thermal zones might be different paths)
5. Test on Orange Pi 5 (or document that testing is needed)

**Files to modify:**
- `src/platform/platform_detector.cpp`

**Difficulty:** ⭐⭐ Easy-Medium  
**Estimated time:** 1-2 hours  
**Skills needed:** Basic C++, Linux file system knowledge  
**Good for:** Contributors with C++ experience wanting an easy first task  

**Acceptance criteria:**
- [ ] Detects Orange Pi 5 correctly
- [ ] Reads CPU temperature from correct thermal zone
- [ ] Reads GPU temperature if available
- [ ] Falls back gracefully if sensors not available

**Testing needed:**
⚠️ **We need someone with Orange Pi 5 hardware to test this!** If you don't have the hardware, mark in PR that testing is needed.

**Resources:**
- Orange Pi thermal zones: `/sys/class/thermal/thermal_zone*/temp`
- See Raspberry Pi implementation as reference

---

## Issue #4: [good first issue] Fix typos and formatting in README.md

**Labels:** `good first issue`, `documentation`, `typos`

**Title:** Fix typos, improve formatting in README.md

**Description:**

The README.md is a living document and probably has some typos, awkward phrasing, or formatting inconsistencies. Let's clean it up!

**What needs to be done:**
1. Read through `godotmark/README.md` carefully
2. Fix any typos you find
3. Improve formatting:
   - Ensure consistent heading levels
   - Fix any broken links
   - Ensure code blocks have proper language tags
   - Check that lists are consistently formatted
4. Improve clarity:
   - Simplify overly complex sentences
   - Fix awkward phrasing
   - Ensure technical terms are used consistently

**Files to modify:**
- `godotmark/README.md`

**Difficulty:** ⭐ Very Easy  
**Estimated time:** 30 minutes - 1 hour  
**Skills needed:** English, attention to detail, Markdown  
**Good for:** Absolute beginners, non-coders  

**Acceptance criteria:**
- [ ] At least 3 improvements made (typos, formatting, or clarity)
- [ ] All links tested and working
- [ ] Markdown renders correctly on GitHub

**Pro tip:** Use a markdown preview tool or GitHub's preview tab to check your changes!

---

## Issue #5: [help wanted] Test Nature Island on Raspberry Pi 5 and report results

**Labels:** `help wanted`, `testing needed`, `hardware: raspberry-pi-5`, `performance`

**Title:** Test Nature Island benchmark on Raspberry Pi 5 and report detailed results

**Description:**

Nature Island is currently broken (4.5 FPS on Godot 4.5), but we don't have enough data points from different hardware configs. **We need your help testing!**

**What we need from you:**
1. Hardware specs:
   - Raspberry Pi model (4 or 5?)
   - RAM amount
   - Storage type (SD card or SSD?)
   - Cooling solution (passive, fan, liquid?)
   - Display resolution
2. Software setup:
   - OS and version (Raspberry Pi OS? Ubuntu?)
   - Godot version
   - Vulkan vs GLES3 renderer
3. Run the benchmark:
   - Clone the repo
   - Follow BUILD_AND_RUN.md
   - Run Nature Island benchmark
   - Let it complete all phases (60 seconds)
4. Report results:
   - FPS for each phase
   - CPU/GPU temperature throughout
   - Any throttling detected?
   - System monitor screenshots if possible
   - Terminal output (copy-paste)

**Template for reporting:**
```markdown
## Hardware
- **Model:** Raspberry Pi 5 8GB
- **Storage:** Samsung 256GB SSD
- **Cooling:** Active fan (Argon ONE case)
- **Display:** 1920x1080 HDMI

## Software
- **OS:** Raspberry Pi OS Bookworm (64-bit)
- **Godot:** 4.5-stable
- **Renderer:** Vulkan

## Results: Nature Island
- Phase 1 (Warmup): 12 FPS
- Phase 2: 8 FPS
- Phase 3: 6 FPS
- Phase 4: 4.5 FPS
- Average temp: 65°C
- Throttling: Yes, at 80°C

## Observations
- Model Showcase runs fine at 45-60 FPS
- Nature Island causes immediate throttling
```

**Files to modify:**
- None! Just create an issue comment with your results

**Difficulty:** ⭐ Easy (if you have hardware)  
**Estimated time:** 30 minutes  
**Skills needed:** Following build instructions, running commands  
**Good for:** Hardware enthusiasts, Raspberry Pi users  

**What you get:**
- Your name in the contributors list! 🎉
- Recognition in release notes
- Eternal gratitude from the maintainers 🙏
- Helping make GodotMark better for everyone!

---

## Issue #6: [good first issue] Add keyboard shortcut display to benchmarks

**Labels:** `good first issue`, `UI`, `quality of life`, `GDScript`

**Title:** Display keyboard shortcuts on benchmark overlay

**Description:**

Users might not know they can press ESC to quit or F to toggle fullscreen. Let's show the shortcuts on screen!

**What needs to be done:**
1. Open `godotmark/scenes/ui/model_showcase_overlay.tscn` (or nature_island_overlay)
2. Add a small Label node in the bottom-left corner
3. Display available shortcuts:
   ```
   [ESC] Quit  [F] Fullscreen
   ```
4. Style it so it's visible but not distracting:
   - Small font size (12-14pt)
   - Semi-transparent background
   - White or light gray text

**Files to modify:**
- `scenes/ui/model_showcase_overlay.tscn`
- `scenes/ui/nature_island_overlay.tscn` (if it exists)

**Difficulty:** ⭐ Easy  
**Estimated time:** 30 minutes  
**Skills needed:** Basic Godot UI editing  
**Good for:** First-time contributors  

**Acceptance criteria:**
- [ ] Shortcuts displayed in bottom-left corner
- [ ] Doesn't overlap with other UI elements
- [ ] Text is readable on both light and dark backgrounds
- [ ] Works in both Model Showcase and Nature Island

**Mockup:**
```
┌──────────────────────────────────────┐
│                                      │
│         Benchmark Running...         │
│                                      │
│                                      │
│  [ESC] Quit  [F] Fullscreen          │
└──────────────────────────────────────┘
```

---

## Issue #7: [documentation] Document how to add a new benchmark

**Labels:** `good first issue`, `documentation`, `developer guide`

**Title:** Create guide: "How to Add a New Benchmark"

**Description:**

We have two benchmarks (Model Showcase, Nature Island), but no guide on how to create a third one. Let's document the process!

**What needs to be done:**
1. Create `godotmark/docs/ADDING_NEW_BENCHMARK.md`
2. Study the existing benchmarks:
   - `scripts/model_showcase.gd`
   - `scripts/nature_island.gd`
   - `scenes/benchmarks/model_showcase.tscn`
3. Document the process step-by-step:
   - File structure
   - Required functions (`_ready()`, `_process()`, phases)
   - Scene setup (Camera, WorldEnvironment, lights)
   - Metrics integration
   - Adding to main menu
4. Provide a template script
5. List best practices and common pitfalls

**Example outline:**
```markdown
# How to Add a New Benchmark

## Overview
Benchmarks in GodotMark follow a 5-phase structure...

## Step 1: Create the Scene
1. Create `scenes/benchmarks/your_benchmark.tscn`
2. Add these required nodes:
   - Camera3D (use OptimizedCinematicCamera script)
   - WorldEnvironment
   - DirectionalLight3D
   - BenchmarkMetricsOverlay (UI)

## Step 2: Create the Script
Use this template: ...

## Step 3: Implement Phases
Each benchmark has 5 phases...

## Step 4: Add to Main Menu
1. Open `scenes/ui/main_menu.tscn`
2. Add a button...
```

**Files to create:**
- `godotmark/docs/ADDING_NEW_BENCHMARK.md`

**Difficulty:** ⭐⭐ Easy-Medium  
**Estimated time:** 2-4 hours  
**Skills needed:** Reading code, technical writing, GDScript understanding  
**Good for:** People who want to deeply understand the codebase  

**Acceptance criteria:**
- [ ] Complete step-by-step guide
- [ ] Template benchmark script provided
- [ ] Explains phase system
- [ ] Covers metrics integration
- [ ] Lists at least 5 best practices

---

## Issue #8: [good first issue] Add benchmark duration indicator

**Labels:** `good first issue`, `UI`, `GDScript`, `quality of life`

**Title:** Add progress bar or timer showing benchmark duration

**Description:**

Users don't know how long benchmarks will take. Let's add a visual indicator!

**What needs to be done:**
1. Choose approach:
   - **Option A:** Progress bar (0% to 100%)
   - **Option B:** Timer (e.g., "25s / 60s")
   - **Option C:** Both!
2. Add to the overlay UI
3. Calculate progress based on `current_phase_time` and `benchmark_duration`
4. Update every frame in `_process(delta)`

**Example implementation:**
```gdscript
# In model_showcase_overlay.gd
func update_progress(current_time: float, total_duration: float):
    var progress = (current_time / total_duration) * 100
    $ProgressBar.value = progress
    $TimerLabel.text = "%d / %d seconds" % [int(current_time), int(total_duration)]
```

**Files to modify:**
- `scenes/ui/model_showcase_overlay.tscn` (add ProgressBar/Label)
- `scripts/ui/model_showcase_overlay.gd` (add update function)
- `scripts/model_showcase.gd` (call update function)

**Difficulty:** ⭐⭐ Easy-Medium  
**Estimated time:** 1-2 hours  
**Skills needed:** GDScript, Godot UI  
**Good for:** Contributors familiar with Godot's UI system  

**Acceptance criteria:**
- [ ] Progress indicator visible during benchmark
- [ ] Updates smoothly
- [ ] Shows time remaining or elapsed
- [ ] Doesn't interfere with other metrics

---

## Issue #9: [help wanted] Test on Rock 5B and report results

**Labels:** `help wanted`, `testing needed`, `hardware: rock-5b`, `performance`

**Title:** Test GodotMark on Radxa Rock 5B and report results

**Description:**

Rock 5B is another popular ARM SBC with RK3588 chip. We want to know how GodotMark performs on it!

**What we need:**
Similar to Issue #5 (Raspberry Pi 5 testing), but for Rock 5B.

**Hardware specs to report:**
- Rock 5B model (which RAM variant?)
- Storage (eMMC, SD, NVMe SSD?)
- Cooling solution
- Display resolution

**Benchmarks to test:**
1. Model Showcase
2. Nature Island (might be slow, that's expected)

**Report template:**
Use the same template as Issue #5 (Raspberry Pi 5 testing).

**Difficulty:** ⭐ Easy (if you have hardware)  
**Estimated time:** 30-45 minutes  
**Skills needed:** Linux command line, following build instructions  
**Good for:** Rock 5B owners, hardware enthusiasts  

**Bonus:**
If you have both RPi 5 AND Rock 5B, a comparison would be amazing! Both use similar ARM chips.

---

## Issue #10: [good first issue] Improve error messages when assets are missing

**Labels:** `good first issue`, `error handling`, `GDScript`, `quality of life`

**Title:** Add helpful error messages when benchmark assets are missing

**Description:**

When GLTF models or textures are missing, the benchmarks crash with cryptic errors. Let's make this more user-friendly!

**What needs to be done:**
1. In `nature_island.gd` and `model_showcase.gd`, add checks before loading assets:
   ```gdscript
   func load_nature_assets():
       var asset_paths = [
           "res://godotmark-assets/nature/oak_tree_01.gltf",
           "res://godotmark-assets/nature/rock_01.gltf"
       ]
       
       for path in asset_paths:
           if not ResourceLoader.exists(path):
               push_error("❌ Missing asset: " + path)
               push_error("💡 Did you run the asset download script?")
               push_error("💡 See ASSETS_SETUP.md for instructions")
               return false
       
       # Continue loading...
       return true
   ```

2. If assets are missing, show a user-friendly popup instead of crashing
3. Direct users to the asset download instructions

**Files to modify:**
- `scripts/nature_island.gd`
- `scripts/model_showcase.gd`

**Difficulty:** ⭐ Easy  
**Estimated time:** 1 hour  
**Skills needed:** Basic GDScript, error handling  
**Good for:** First-time contributors  

**Acceptance criteria:**
- [ ] Checks for missing assets before loading
- [ ] Displays helpful error message with solution
- [ ] Doesn't crash, returns to main menu gracefully
- [ ] Points to documentation for asset setup

---

## Issue #11: [good first issue] Add "--version" command line flag

**Labels:** `good first issue`, `C++`, `CLI`, `quality of life`

**Title:** Add `--version` command line argument to print version info

**Description:**

When running GodotMark from command line, there's no way to check the version. Let's add a `--version` flag!

**What needs to be done:**
1. Open `src/main.cpp` (or wherever command-line args are parsed)
2. Add version argument handling:
   ```cpp
   if (args.has("--version") || args.has("-v")) {
       print_line("GodotMark v" + VERSION);
       print_line("Godot Engine v" + Engine::get_version_info());
       print_line("Platform: " + OS::get_name());
       return 0; // Exit after printing
   }
   ```
3. Define VERSION constant in `project.godot` or a config file

**Files to modify:**
- `src/main.cpp` (or GDScript main entry point)
- `project.godot` (add version constant)

**Difficulty:** ⭐ Easy  
**Estimated time:** 30 minutes  
**Skills needed:** Basic C++ or GDScript, command-line args  
**Good for:** Contributors wanting to dip their toes into codebase  

**Acceptance criteria:**
- [ ] `./godotmark --version` prints version information
- [ ] Includes GodotMark version
- [ ] Includes Godot engine version
- [ ] Includes platform information
- [ ] Short flag `-v` also works

**Expected output:**
```bash
$ ./godotmark --version
GodotMark v0.1.0
Godot Engine v4.5.0.stable
Platform: Linux (Raspberry Pi OS)
```

---

## Issue #12: [documentation] Create video recording guide

**Labels:** `good first issue`, `documentation`, `no code required`

**Title:** Document how to record benchmark videos for bug reports

**Description:**

When reporting performance issues, videos are incredibly helpful. Let's create a guide on how to record them!

**What needs to be done:**
1. Create `godotmark/docs/RECORDING_BENCHMARKS.md`
2. Document multiple recording methods:
   - OBS Studio (cross-platform)
   - SimpleScreenRecorder (Linux)
   - Built-in tools (Windows Game Bar, macOS Screenshot)
   - Command-line tools (ffmpeg)
3. Provide specific settings for each method:
   - Resolution
   - FPS
   - Encoding
   - File size considerations
4. Include tips:
   - Don't record at higher FPS than benchmark runs
   - Keep file sizes reasonable for GitHub
   - What to include in video (full benchmark run vs excerpt)

**Example outline:**
```markdown
# How to Record Benchmark Videos

## Why Record Videos?

Videos help maintainers understand:
- Visual artifacts
- Performance issues
- Unexpected behavior

## Method 1: OBS Studio (Recommended)

1. Download OBS: https://obsproject.com/
2. Settings:
   - Output > Video Bitrate: 2500 Kbps
   - Video > Base Resolution: Your screen resolution
   - Video > Output Resolution: 1920x1080 (or lower)
   - Video > FPS: 30 (benchmark runs at low FPS anyway)
3. Scene setup: ...

## Method 2: SimpleScreenRecorder (Linux)
...
```

**Files to create:**
- `godotmark/docs/RECORDING_BENCHMARKS.md`

**Difficulty:** ⭐ Easy  
**Estimated time:** 1-2 hours  
**Skills needed:** Screen recording experience, technical writing  
**Good for:** Content creators, people familiar with recording tools  

**Acceptance criteria:**
- [ ] At least 3 recording methods documented
- [ ] Specific settings provided for each
- [ ] File size optimization tips
- [ ] What to include in benchmark videos

---

## Issue #13: [good first issue] Add "Benchmark Complete" screen

**Labels:** `good first issue`, `UI`, `GDScript`, `quality of life`

**Title:** Show results summary when benchmark completes

**Description:**

When a benchmark finishes, it just returns to the main menu. Let's show a results summary first!

**What needs to be done:**
1. Create `scenes/ui/benchmark_results.tscn`
2. Design a simple results screen showing:
   - Benchmark name
   - Average FPS
   - Min/Max FPS
   - Average temperature
   - Hardware detected
   - "Back to Menu" button
3. Modify benchmark scripts to show this scene before returning to menu
4. Add option to export results as JSON or CSV

**Example mockup:**
```
┌─────────────────────────────────────────┐
│       BENCHMARK COMPLETE! 🎉            │
│                                         │
│  Nature Island                          │
│  ═══════════════════════════            │
│                                         │
│  Average FPS: 4.5                       │
│  Min FPS: 3.8                           │
│  Max FPS: 12.0                          │
│  Average CPU Temp: 68°C                 │
│                                         │
│  Hardware: Raspberry Pi 5 (8GB)         │
│  Renderer: Vulkan                       │
│                                         │
│  [Export Results]  [Back to Menu]       │
└─────────────────────────────────────────┘
```

**Files to create:**
- `scenes/ui/benchmark_results.tscn`
- `scripts/ui/benchmark_results.gd`

**Files to modify:**
- `scripts/nature_island.gd` (show results before returning)
- `scripts/model_showcase.gd` (show results before returning)

**Difficulty:** ⭐⭐ Medium  
**Estimated time:** 2-3 hours  
**Skills needed:** GDScript, Godot UI, JSON export  
**Good for:** Contributors comfortable with Godot's UI system  

**Acceptance criteria:**
- [ ] Results screen displays after benchmark completes
- [ ] Shows all key metrics
- [ ] Has "Back to Menu" button
- [ ] Optional: Export results to JSON file
- [ ] Works for both benchmarks

---

## Issue #14: [help wanted] Compare Godot 4.4 vs 4.5 performance

**Labels:** `help wanted`, `testing needed`, `performance`, `investigation`

**Title:** Benchmark performance difference between Godot 4.4 and 4.5

**Description:**

Nature Island runs at 4.5 FPS on Godot 4.5. Was it better on 4.4? Let's find out!

**What we need:**
Someone to test GodotMark on BOTH Godot 4.4 and 4.5 and compare results.

**Testing process:**
1. Build/run GodotMark with Godot 4.4:
   - Install Godot 4.4-stable
   - Open GodotMark project
   - Run Model Showcase and Nature Island
   - Record FPS for each phase
2. Build/run GodotMark with Godot 4.5:
   - Install Godot 4.5-stable
   - Open same GodotMark project
   - Run same benchmarks
   - Record FPS for each phase
3. Report comparison

**Report template:**
```markdown
## Hardware
- Device: [Your hardware]
- OS: [Your OS]
- Renderer: [Vulkan/GLES3]

## Godot 4.4 Results
### Model Showcase
- Phase 1: XX FPS
- Phase 2: XX FPS
...

### Nature Island
- Phase 1: XX FPS
- Phase 2: XX FPS
...

## Godot 4.5 Results
### Model Showcase
- Phase 1: XX FPS
- Phase 2: XX FPS
...

### Nature Island
- Phase 1: XX FPS
- Phase 2: XX FPS
...

## Comparison
- Model Showcase: 4.4 vs 4.5: [Better/Worse/Same]
- Nature Island: 4.4 vs 4.5: [Better/Worse/Same]

## Observations
[Any notes about differences, behavior changes, etc.]
```

**Difficulty:** ⭐⭐ Easy-Medium  
**Estimated time:** 1 hour  
**Skills needed:** Installing different Godot versions, running benchmarks  
**Good for:** Testers, people investigating performance regressions  

**Why this matters:**
If 4.4 is significantly faster, it might indicate a Godot regression we should report upstream!

---

## Issue #15: [good first issue] Add platform badges to README

**Labels:** `good first issue`, `documentation`, `markdown`, `design`

**Title:** Add platform support badges and hardware compatibility table to README

**Description:**

Let's make it immediately clear which platforms are supported!

**What needs to be done:**
1. Open `godotmark/README.md`
2. Add platform badges near the top (after project description):
   ```markdown
   ## Platform Support
   
   ![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-4%2F5-C51A4A?logo=raspberrypi)
   ![Orange Pi](https://img.shields.io/badge/Orange%20Pi-5-FFA500)
   ![Rock 5B](https://img.shields.io/badge/Rock-5B-00ADD8)
   ![Linux](https://img.shields.io/badge/Linux-x86__64-FCC624?logo=linux&logoColor=black)
   ![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows)
   ```

3. Create a hardware compatibility table:
   ```markdown
   ## Hardware Compatibility
   
   | Hardware | Model Showcase | Nature Island | Status |
   |----------|----------------|---------------|--------|
   | Raspberry Pi 4 (4GB+) | ✅ 45-60 FPS | ⚠️ 7-12 FPS | Tested |
   | Raspberry Pi 5 (8GB) | ✅ 50-60 FPS | ❌ 4.5 FPS | Known Issue |
   | Orange Pi 5 | ❓ Not tested | ❓ Not tested | Need testers! |
   | Rock 5B | ❓ Not tested | ❓ Not tested | Need testers! |
   | Linux PC (mid-range) | ✅ 60 FPS | ✅ 60 FPS | Tested |
   | Windows PC | ❓ Not tested | ❓ Not tested | Need testers! |
   ```

4. Add a "Legend" explaining the symbols:
   - ✅ Works well
   - ⚠️ Works but slow
   - ❌ Known issues
   - ❓ Not tested yet

**Files to modify:**
- `godotmark/README.md`

**Difficulty:** ⭐ Very Easy  
**Estimated time:** 30 minutes  
**Skills needed:** Markdown, basic design sense  
**Good for:** First-time contributors, designers  

**Acceptance criteria:**
- [ ] Platform badges added with correct colors/logos
- [ ] Compatibility table shows tested hardware
- [ ] Clear status indicators
- [ ] Legend explains symbols
- [ ] Renders correctly on GitHub

**Resources:**
- Shields.io badge generator: https://shields.io/
- Simple Icons for logos: https://simpleicons.org/

---

# Creating These Issues

**How to create these on GitHub:**

1. Go to your repository: `https://github.com/your-username/GodotMark`
2. Click "Issues" tab
3. Click "New Issue"
4. Copy-paste the content from above
5. Add the appropriate labels (create labels if they don't exist)
6. Click "Submit new issue"

**Labels to create first:**
- `good first issue` (green)
- `help wanted` (blue)
- `documentation` (blue)
- `UI` (purple)
- `GDScript` (yellow)
- `C++` (red)
- `testing needed` (orange)
- `hardware: raspberry-pi-5` (gray)
- `hardware: orange-pi` (gray)
- `hardware: rock-5b` (gray)
- `performance` (red)
- `quality of life` (green)
- `beginner friendly` (green)

**Pro tips:**
- Pin the most important issues (Issue #5, #9, #14)
- Use GitHub Projects to organize (if you decide to use it later)
- Respond quickly when someone claims an issue
- Be encouraging and helpful in your responses!

---

**Created:** January 27, 2026  
**Last Updated:** January 27, 2026

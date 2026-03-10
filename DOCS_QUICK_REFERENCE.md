# Documentation Quick Reference

**Where to find information in the new consolidated structure**

---

## 📖 Start Here

| What You Need | Where to Find It |
|---------------|------------------|
| **Project overview** | [`README.md`](README.md) |
| **Complete history** | [`CHANGELOG.md`](CHANGELOG.md) |
| **How the 4.5 FPS was solved** | [`MYSTERY_SOLVED_ROCKS.md`](MYSTERY_SOLVED_ROCKS.md) |
| **How to contribute** | [`CONTRIBUTING.md`](CONTRIBUTING.md) |

---

## 🏗️ Building & Running

| Task | File |
|------|------|
| Build on Raspberry Pi 5 | [`RPi5_BUILD_INSTRUCTIONS.md`](RPi5_BUILD_INSTRUCTIONS.md) |
| General build instructions | [`BUILD_AND_RUN.md`](BUILD_AND_RUN.md) |
| Setup V3D drivers | [`V3D_DRIVER_SETUP.md`](V3D_DRIVER_SETUP.md) |
| Testing the build | [`TESTING_GUIDE.md`](TESTING_GUIDE.md) |

---

## ⚡ Performance Optimization

| Topic | File |
|-------|------|
| **Complete story** | [`COMPLETE_OPTIMIZATION_STORY.md`](COMPLETE_OPTIMIZATION_STORY.md) |
| Physics bottleneck | [`PHYSICS_BOTTLENECK_FIX.md`](PHYSICS_BOTTLENECK_FIX.md) |
| Texture compression | [`TEXTURE_COMPRESSION_FIX.md`](TEXTURE_COMPRESSION_FIX.md) |
| Vulkan vs GLES3 | [`VULKAN_OVERHEAD_RPI.md`](VULKAN_OVERHEAD_RPI.md) |
| Triangle budget | [`RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`](RASPBERRY_PI_4_MODEL_OPTIMIZATION.md) |
| Draw call reduction | [`DRAW_CALL_OPTIMIZATION.md`](DRAW_CALL_OPTIMIZATION.md) |
| Shader optimization | [`SHADER_PERFORMANCE_GUIDE.md`](SHADER_PERFORMANCE_GUIDE.md) |
| Step-by-step guide | [`OPTIMIZATION_COMPLETE_GUIDE.md`](OPTIMIZATION_COMPLETE_GUIDE.md) |

---

## 🔬 Investigation Reports

| Investigation | File |
|---------------|------|
| **4.5 FPS Mystery (SOLVED)** | [`MYSTERY_SOLVED_ROCKS.md`](MYSTERY_SOLVED_ROCKS.md) |
| Ocean shader test | [`OCEAN_SHADER_PERFORMANCE_TEST.md`](OCEAN_SHADER_PERFORMANCE_TEST.md) |
| Visual comparison | [`OCEAN_SHADER_VISUAL_COMPARISON.md`](OCEAN_SHADER_VISUAL_COMPARISON.md) |
| Diagnostic plan | [`NATURE_ISLAND_DIAGNOSTIC_PLAN.md`](NATURE_ISLAND_DIAGNOSTIC_PLAN.md) |
| Ocean shader failure | [`INVESTIGATION_OCEAN_SHADER_FAILED.md`](INVESTIGATION_OCEAN_SHADER_FAILED.md) |

---

## 💻 Code Style

| Topic | File |
|-------|------|
| GDScript formatting | [`CODE_FORMATTING_GUIDE.md`](CODE_FORMATTING_GUIDE.md) |
| C++ style guide | [`CPP_STYLE_GUIDE.md`](CPP_STYLE_GUIDE.md) |
| Style tool setup | [`STYLE_GUIDE_SETUP.md`](STYLE_GUIDE_SETUP.md) |
| Formatting summary | [`FORMATTING_SUMMARY.md`](FORMATTING_SUMMARY.md) |

---

## 🤝 Community

| Topic | File |
|-------|------|
| Creating good first issues | [`.github/GOOD_FIRST_ISSUES_GUIDE.md`](.github/GOOD_FIRST_ISSUES_GUIDE.md) |
| Issue templates | [`.github/ISSUES_TO_CREATE.md`](.github/ISSUES_TO_CREATE.md) |
| Bot setup | [`.github/BOT_SETUP.md`](.github/BOT_SETUP.md) |
| Bot installation | [`.github/BOT_INSTALLATION_CHECKLIST.md`](.github/BOT_INSTALLATION_CHECKLIST.md) |
| Phase 2 complete | [`.github/PHASE_2_COMPLETE.md`](.github/PHASE_2_COMPLETE.md) |

---

## 🔒 Security

| Topic | File |
|-------|------|
| Security policy | [`SECURITY.md`](SECURITY.md) |
| Workflow security | [`.github/WORKFLOW_SECURITY.md`](.github/WORKFLOW_SECURITY.md) |

---

## 📦 Assets

| Topic | File |
|-------|------|
| Asset inventory | [`art/ASSET_INVENTORY.md`](art/ASSET_INVENTORY.md) |
| Shader reference | [`shaders/SHADER_REFERENCE.md`](shaders/SHADER_REFERENCE.md) |

---

## 🗂️ Historical Documentation

**Archived files** (consolidated into CHANGELOG.md):
- Location: `docs/archive/`
- Count: 57 files
- Status: Historical reference only

To restore: `Move-Item docs\archive\*.md .`

---

## 📋 Common Tasks

### "I want to know what changed"
→ [`CHANGELOG.md`](CHANGELOG.md)

### "I want to understand the 4.5 FPS issue"
→ [`MYSTERY_SOLVED_ROCKS.md`](MYSTERY_SOLVED_ROCKS.md)

### "I want to optimize for Raspberry Pi"
→ [`COMPLETE_OPTIMIZATION_STORY.md`](COMPLETE_OPTIMIZATION_STORY.md)  
→ [`SHADER_PERFORMANCE_GUIDE.md`](SHADER_PERFORMANCE_GUIDE.md)

### "I want to contribute"
→ [`CONTRIBUTING.md`](CONTRIBUTING.md)  
→ [`.github/GOOD_FIRST_ISSUES_GUIDE.md`](.github/GOOD_FIRST_ISSUES_GUIDE.md)

### "I want to build for Raspberry Pi 5"
→ [`RPi5_BUILD_INSTRUCTIONS.md`](RPi5_BUILD_INSTRUCTIONS.md)  
→ [`V3D_DRIVER_SETUP.md`](V3D_DRIVER_SETUP.md)

### "I want to understand shader performance"
→ [`SHADER_PERFORMANCE_GUIDE.md`](SHADER_PERFORMANCE_GUIDE.md)  
→ [`OCEAN_SHADER_VISUAL_COMPARISON.md`](OCEAN_SHADER_VISUAL_COMPARISON.md)

### "I want to see all fixes"
→ [`CHANGELOG.md`](CHANGELOG.md) → [0.1.0-alpha] → Fixed

### "I want to see all performance optimizations"
→ [`CHANGELOG.md`](CHANGELOG.md) → Performance Optimizations  
→ [`OPTIMIZATION_COMPLETE_GUIDE.md`](OPTIMIZATION_COMPLETE_GUIDE.md)

---

## 📊 Documentation Stats

- **Active docs:** 42 files
- **Archived docs:** 57 files
- **Total history preserved:** 100%
- **CHANGELOG entries:** 200+
- **Investigation reports:** 7 files
- **Performance deep dives:** 10 files
- **Community guides:** 5 files

---

**Quick Tip:** Use your IDE's search feature (`Ctrl+Shift+F` or `Cmd+Shift+F`) to find specific topics across all documentation!

---

**Last Updated:** February 8, 2026

# 🎭 Model Showcase - Start Here!

## Quick Navigation

### 🚀 Want to Run It Now?
**→ [RUN_MODEL_SHOWCASE.txt](RUN_MODEL_SHOWCASE.txt)** - Copy-paste instructions

### 📖 Want the Full Guide?
**→ [MODEL_SHOWCASE_GUIDE.md](MODEL_SHOWCASE_GUIDE.md)** - Complete user guide

### 🧪 Want to Test It?
**→ [MODEL_SHOWCASE_TESTING.md](MODEL_SHOWCASE_TESTING.md)** - Testing procedures

### 🔧 Want Technical Details?
**→ [MODEL_SHOWCASE_IMPLEMENTATION.md](MODEL_SHOWCASE_IMPLEMENTATION.md)** - Implementation summary

### ✅ Want to See What's Done?
**→ [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)** - Status report

### ⚡ Want Quick Reference?
**→ [MODEL_SHOWCASE_QUICKSTART.txt](MODEL_SHOWCASE_QUICKSTART.txt)** - One-page cheat sheet

---

## What Is This?

A **1-minute cinematic GPU benchmark** featuring:
- Marble bust model (52K triangles)
- Progressive rendering effects (5 phases)
- Smooth camera animation
- Epic soundtrack ("Excelsior In Aeternum")
- Performance metrics & JSON export

---

## How to Launch

### From Main Scene
```
1. Run main.tscn (F5)
2. Press M key
3. Enjoy 60 seconds!
```

### Direct Launch
```
1. Open scenes/model_showcase.tscn
2. Press F6
3. Watch the show!
```

---

## What to Expect

| Phase | Time | Features | FPS (Windows) | FPS (RPi5) |
|-------|------|----------|---------------|------------|
| 1 | 0-12s | Basic PBR | 100-120 | 50-60 |
| 2 | 12-24s | HDR + Shadows | 80-100 | 40-50 |
| 3 | 24-36s | SSR + SSAO | 60-80 | 35-45 |
| 4 | 36-48s | Particles + Glow | 50-70 | 30-40 |
| 5 | 48-60s | Maximum | 40-60 | 25-35 |

---

## Files You Need

All assets are already in place:
- ✅ `art/model-test/marble_bust_01_2k.gltf` (model)
- ✅ `art/model-test/sunflowers_puresky_2k.hdr` (environment)
- ✅ `art/model-test/Excelsior In Aeternum.ogg` (music)
- ✅ `scenes/model_showcase.tscn` (scene)
- ✅ `scripts/model_showcase.gd` (controller)
- ✅ `scripts/cinematic_camera.gd` (camera)

---

## Documentation Map

```
START_HERE_MODEL_SHOWCASE.md ← You are here!
│
├── RUN_MODEL_SHOWCASE.txt (Quick start)
├── MODEL_SHOWCASE_QUICKSTART.txt (Cheat sheet)
│
├── MODEL_SHOWCASE_GUIDE.md (Full user guide)
│   ├── Timeline structure
│   ├── Quality presets
│   ├── Performance metrics
│   ├── Controls
│   └── Troubleshooting
│
├── MODEL_SHOWCASE_TESTING.md (Testing guide)
│   ├── Windows testing
│   ├── RPi5 deployment
│   ├── Performance expectations
│   └── Success criteria
│
├── MODEL_SHOWCASE_IMPLEMENTATION.md (Technical)
│   ├── Implementation details
│   ├── Code structure
│   ├── Integration points
│   └── Future enhancements
│
└── IMPLEMENTATION_COMPLETE.md (Status)
    ├── What was built
    ├── How to test
    ├── Next steps
    └── Celebration! 🎉
```

---

## Related Documentation

### Adaptive Quality Fix (for RPi5)
- `ADAPTIVE_QUALITY_FIX.md` - Fix details
- `ADAPTIVE_FIX_APPLY.txt` - Rebuild instructions
- `REBUILD_WITH_FIX.sh` - Automated rebuild script

### General Project
- `README.md` - Project overview
- `TESTING_GUIDE.md` - General testing
- `BUILD_RPI5.md` - RPi5 build guide

---

## Quick Troubleshooting

**Audio not playing?**
→ Check `art/model-test/Excelsior In Aeternum.ogg` exists

**HDR not loading?**
→ Re-import `art/model-test/sunflowers_puresky_2k.hdr` in editor

**Low FPS?**
→ Press Q to lower quality before launching (M key)

**Particles not visible?**
→ Wait until 36 seconds (Phase 4), check quality is Medium+

---

## Ready to Go!

**Everything is implemented and ready to test.**

Just press **M** and enjoy the show! 🎬

---

**Questions?** Check the documentation above or look for console output during the benchmark.

**Have fun!** 🎭✨


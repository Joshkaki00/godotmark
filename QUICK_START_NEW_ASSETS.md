# Quick Start - Testing New Low-Poly Assets

**Last Updated:** February 8, 2026  
**Status:** Assets replaced, ready for testing

---

## ⚡ Quick Commands

### 1. Clear Import Cache (REQUIRED)

```powershell
cd godotmark
Remove-Item .godot -Recurse -Force
```

### 2. Open in Godot

```powershell
# Windows (adjust path to your Godot executable)
& "C:\Godot_v4.4-stable_win64.exe\Godot_v4.4-stable_win64.exe" --path . --editor

# Or just open Godot and select the godotmark folder
```

### 3. Wait for Import (~30 seconds)

Godot will import the 7 new GLB files. Watch the console for errors.

### 4. Optimize Textures

```powershell
.\optimize_for_raspberry_pi.ps1
```

### 5. Test Nature Island

```bash
# Run benchmark
./godotmark --benchmark nature-island --verbose

# Or press F5 in Godot editor
```

---

## 📊 Expected Results

### Triangle Counts (per asset)

**Before (Photogrammetry):**
- Trees: 500K-1M triangles each
- Rocks: 500K-1M triangles each
- Total: ~5,000,000 triangles

**After (Low-Poly):**
- Tree.glb: 200-400 triangles
- Bushes.glb: 50-100 triangles
- Flowers.glb: 20-50 triangles
- Grass.glb: 30-60 triangles
- Dead Trees.glb: 100-150 triangles
- Rock.glb: 30-50 triangles
- Rock Large.glb: 80-120 triangles
- **Total: ~5,600 triangles**

### Performance Targets

| Platform | Expected FPS | Frame Time | Status |
|----------|--------------|------------|--------|
| **Raspberry Pi 5** | 40-60 FPS | 16-25ms | ⏳ Testing |
| **Raspberry Pi 4** | 30-45 FPS | 22-33ms | ⏳ Testing |
| **Desktop PC** | 60 FPS | <16ms | ⏳ Testing |

### Phase-by-Phase

| Phase | Objects | Triangles | Target FPS (RPi 5) |
|-------|---------|-----------|-------------------|
| **Phase 1: Trees** | 12 trees | ~3,600 | 60 |
| **Phase 2: + Rocks** | + 10 rocks | ~4,400 | 55 |
| **Phase 3: + Vegetation** | + 20 plants | ~5,600 | 50 |
| **Phase 4: + Wind** | (no new geo) | ~5,600 | 45 |
| **Phase 5: Maximum** | (all features) | ~5,600 | 40-45 |

---

## ✅ Verification Checklist

### In Godot Editor

- [ ] **Assets imported successfully**
  - Check `res://art/nature-benchmark/` for 7 GLB files
  - No red error icons
  - Click each GLB to preview in Inspector
  
- [ ] **Materials load correctly**
  - Each GLB has materials assigned
  - Textures appear in Material preview
  - No pink "missing texture" placeholders

- [ ] **Triangle counts are low**
  - Open GLB in Scene tab
  - Select mesh node
  - Check Inspector > Geometry > Faces/Triangles
  - Should be <500 for most assets

- [ ] **Textures are compressed**
  - Click texture in FileSystem
  - Check Import tab
  - `compress/mode` should be `2` (VRAM Compressed)
  - `compress/lossy_quality` should be `0.6`

### During Benchmark Run

- [ ] **No import errors in console**
- [ ] **Assets appear in scene**
  - Trees, bushes, flowers, grass visible
  - Not giant or tiny (scale issues)
  - Not pink/magenta (material issues)

- [ ] **Performance meets targets**
  - Phase 1: 60 FPS (trees)
  - Phase 2: 55 FPS (+ rocks)
  - Phase 3: 50 FPS (+ vegetation)
  - Phase 4: 45 FPS (+ wind)
  - Phase 5: 40-45 FPS (maximum)

- [ ] **No crashes or freezes**
- [ ] **Audio plays correctly**
- [ ] **Camera movement smooth**
- [ ] **Wind animation works** (Phase 4-5)

---

## 🐛 Troubleshooting

### "Assets not appearing in Godot"

**Solution:**
```powershell
# Force reimport
Remove-Item .godot -Recurse -Force

# Reopen project in Godot
```

### "Import errors for GLB files"

**Check console for specific error messages.**

**Common issues:**
- Missing textures → Ensure textures are embedded in GLB or in correct folder
- Invalid format → Verify GLB files are valid (open in Blender to test)
- File path issues → Check for spaces in filenames (GLB files have spaces!)

**File names with spaces:**
```
"Dead Trees.glb"
"Rock Large.glb"
```

These may need special handling in GDScript. If issues occur, rename to:
```
DeadTrees.glb
RockLarge.glb
```

### "Models are giant or tiny"

**Scale issues.** Check the GLB scale in Blender:
- Trees should be ~3-5 meters tall
- Bushes should be ~0.5-1 meter
- Rocks should be ~0.5-2 meters

**Fix in Godot:**
```gdscript
# In extract_gltf_asset() or when instantiating:
instance.scale = Vector3(0.5, 0.5, 0.5)  # Scale down by 50%
```

### "Materials are pink/missing"

**Texture paths incorrect.**

**Solution 1: Check GLB texture embedding**
- Open GLB in Blender
- File > External Data > Pack All Into .blend
- Export as GLB with "Embed Textures" option

**Solution 2: Manual texture assignment in Godot**
- Open GLB scene
- Select mesh node
- In Inspector > Material > Albedo, drag texture from FileSystem

### "FPS still low (< 30)"

**Possible causes:**
1. **Triangle counts higher than expected**
   - Verify with Godot Inspector
   - Each asset should be <500 triangles
   
2. **Textures not compressed**
   - Run `.\optimize_for_raspberry_pi.ps1` again
   - Check Import settings (mode=2, size_limit=512)

3. **Too many instances**
   - Check `nature_island.gd` instance counts
   - Current: 12 trees, 10 rocks, 20 vegetation = 42 objects
   - If FPS low, reduce counts

4. **Wind shaders too expensive**
   - Disable in Phase 4 test
   - Simplify shader code

**Debug command:**
```bash
./godotmark --benchmark nature-island --verbose
```

This shows:
- Triangle counts per phase
- Draw call counts
- VRAM usage
- Bottleneck identification

---

## 🔄 Rollback Procedure

If new assets don't work:

```powershell
cd godotmark

# Remove new assets
Remove-Item art/nature-benchmark/* -Recurse -Force

# Restore old assets (check exact timestamp in your folder)
$archive = "art/nature-benchmark-archive-20260311_173846"
Move-Item "$archive/*" art/nature-benchmark -Force

# Clear import cache
Remove-Item .godot -Recurse -Force

# Reopen in Godot
```

---

## 📝 Reporting Results

### If It Works ✅

**Share results in [GitHub Discussions](https://github.com/Joshkaki00/godotmark/discussions):**

```markdown
## Low-Poly Assets Working! 🎉

**Platform:** [Raspberry Pi 5 / PC / etc.]
**Triangle Count:** [from Godot Inspector]
**Performance:**
- Phase 1: [FPS]
- Phase 2: [FPS]
- Phase 3: [FPS]
- Phase 4: [FPS]
- Phase 5: [FPS]

**Screenshot:** [attach if possible]

Assets look great and performance is excellent!
```

### If It Doesn't Work ❌

**Open an issue or post in Discussions:**

```markdown
## Low-Poly Assets Issue

**Problem:** [describe what's wrong]

**Platform:** [Raspberry Pi 5 / PC / etc.]

**Error Messages:** [paste console output]

**Screenshots:** [attach if helpful]

**Steps Taken:**
1. Cleared .godot cache
2. Ran optimize_for_raspberry_pi.ps1
3. [etc.]

**Request:** Help debugging or consider rollback
```

---

## 📚 Related Documentation

- [`ASSET_REPLACEMENT_GUIDE.md`](ASSET_REPLACEMENT_GUIDE.md) - Full replacement guide
- [`ASSET_REPLACEMENT_SUMMARY.md`](ASSET_REPLACEMENT_SUMMARY.md) - Detailed summary
- [`MYSTERY_SOLVED_ROCKS.md`](MYSTERY_SOLVED_ROCKS.md) - Why we replaced assets
- [`RASPBERRY_PI_4_MODEL_OPTIMIZATION.md`](RASPBERRY_PI_4_MODEL_OPTIMIZATION.md) - Triangle budget
- [`CHANGELOG.md`](CHANGELOG.md) - Project history

---

## ⏱️ Time Estimate

- **Clear cache:** 5 seconds
- **Open Godot:** 10 seconds
- **Import assets:** 30-60 seconds
- **Optimize textures:** 2-3 minutes
- **Run benchmark:** 1 minute
- **Total:** ~5 minutes

---

**Ready to test? Start with Step 1!** 🚀

```powershell
Remove-Item .godot -Recurse -Force
```

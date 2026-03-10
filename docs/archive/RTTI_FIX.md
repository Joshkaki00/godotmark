# RTTI Error Fix - godot-cpp 4.4 Requires RTTI

## Error

```
godot-cpp/src/classes/wrapped.cpp:63:23: error: 'dynamic_cast' not permitted with '-fno-rtti'
   63 |         Object *obj = dynamic_cast<Object *>(this);
      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## Root Cause

**godot-cpp 4.4 uses `dynamic_cast` internally**, which requires RTTI (Run-Time Type Information) to be enabled.

Our build was passing `-fno-rtti` to reduce binary size, but this conflicts with godot-cpp's requirements.

### The Offending Code (godot-cpp)

```cpp
// godot-cpp/src/classes/wrapped.cpp:63
void Wrapped::_postinitialize() {
    Object *obj = dynamic_cast<Object *>(this);  // ❌ Requires RTTI
    if (obj) {
        obj->notification(Object::NOTIFICATION_POSTINITIALIZE);
    }
}
```

## Fix Applied

**File:** `SConstruct`

**Removed the `-fno-rtti` flag:**

```python
# OLD (BREAKS godot-cpp 4.4)
optimization_flags = [
    "-O3",
    "-flto",
    "-ffast-math",
    "-fno-exceptions",
    "-fno-rtti",              # ❌ Conflicts with godot-cpp
    "-ffunction-sections",
    "-fdata-sections",
    "-fomit-frame-pointer",
]
```

```python
# NEW (CORRECT)
optimization_flags = [
    "-O3",
    "-flto",
    "-ffast-math",
    "-fno-exceptions",
    # NOTE: -fno-rtti removed - godot-cpp 4.4 requires RTTI
    "-ffunction-sections",
    "-fdata-sections",
    "-fomit-frame-pointer",
]
```

## Why This Is Correct

1. **godot-cpp 4.4 requires RTTI** - uses `dynamic_cast` internally
2. **Small binary size impact** - RTTI overhead is minimal (~few KB)
3. **Standard practice** - Most GDExtensions keep RTTI enabled
4. **Performance** - RTTI has negligible runtime cost for our use case

## Binary Size Impact

| Flag | Binary Size Impact |
|------|-------------------|
| `-fno-rtti` | Saves ~10-50 KB |
| **RTTI enabled** | Slightly larger, but necessary |

For a benchmark, this is acceptable. The **functional correctness** is more important than a few KB.

## Rebuild Now

```bash
cd /mnt/exfat_drive/dev/godotmark-project/godotmark
./build_native_rpi5.sh template_release rpi5 yes
```

**Build should now succeed!** ✅

## Previous Fixes Applied

1. ✅ Removed `-mfpu=neon-fp-armv8` (ARM32 only, not for ARM64)
2. ✅ Removed `-fno-rtti` (godot-cpp 4.4 requires RTTI)

## Expected Result

- **Build time:** ~5-10 minutes (godot-cpp partially compiled)
- **Output:** `bin/libgodotmark.linux.template_release.arm64.so`
- **Status:** Ready to run!

---

**Fix Status:** ✅ Applied  
**Next Step:** Rebuild with RTTI enabled


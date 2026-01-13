# Addon Fixes - Disabled Incompatible Addons

## Issue

The Godot editor was showing annoying warnings and errors from incompatible addons:

### GDQuest Shaders
```
ERROR: Failed parse script res://addons/gdquest-shaders/dissolve/Dissolve2D/Dissolve2DControls.gd
ERROR: Annotation "@export" requires at most 0 arguments, but 3 were given.
ERROR: Failed parse script res://addons/gdquest-shaders/dissolve/Dissolve2D/DissolveController.gd
ERROR: Cannot assign a value of type Node to variable "_tween" with specified type Tween.
ERROR: Failed parse script res://addons/gdquest-shaders/dissolve/Dissolve2D/Particles2D.gd
ERROR: Cannot infer the type of "data" variable because the value doesn't have a set type.
```

**Cause:** GDQuest Shaders addon is written for Godot 4.0/4.1 and uses deprecated syntax.

### Godot Jolt Examples
```
WARNING: editor/editor_file_system.cpp:3354 - Detected another project.godot at res://addons/godot-jolt/examples. The folder will be ignored.
ERROR: Failed parse script res://addons/godot-jolt/examples/scenes/common/scripts/free_look_camera.gd
ERROR: Could not find type "JoltGeneric6DOFJoint3D" in the current scope.
```

**Cause:** The Godot Jolt examples folder contains its own `project.godot` file, causing conflicts.

---

## Solution

Created `.gdignore` files to tell Godot to completely ignore these folders:

### 1. Disabled GDQuest Shaders
**File:** `addons/gdquest-shaders/.gdignore`

This prevents Godot from parsing any scripts in the entire gdquest-shaders addon.

### 2. Disabled Godot Jolt Examples
**File:** `addons/godot-jolt/examples/.gdignore`

This prevents Godot from treating the examples folder as a sub-project.

---

## What is `.gdignore`?

`.gdignore` is a special file in Godot that tells the editor to completely ignore a folder and all its contents:
- ✅ Scripts won't be parsed
- ✅ Resources won't be imported
- ✅ No warnings or errors from that folder
- ✅ The folder is completely invisible to Godot

---

## Results

### Before (Errors)
```
WARNING: Detected another project.godot at res://addons/godot-jolt/examples
ERROR: Failed parse script (x5 errors from gdquest-shaders)
ERROR: Could not find type "JoltGeneric6DOFJoint3D" 
```

### After (Clean)
```
(No warnings or errors from these addons)
```

---

## Why Keep These Addons?

Even though they're disabled, we keep them in the repository because:

1. **GDQuest Shaders** - Might be useful in the future if updated for Godot 4.4+
2. **Godot Jolt** - The main Jolt physics integration is functional; we just disabled the examples

If you need these addons in the future:
- **GDQuest Shaders:** Wait for a Godot 4.4-compatible update
- **Godot Jolt Examples:** Remove the `.gdignore` file if you want to run them separately

---

## Alternative Solutions Considered

### 1. Delete the Addons ❌
- Decided against this to preserve potentially useful code

### 2. Update GDQuest Shaders ❌
- Would require significant refactoring for Godot 4.4 compatibility
- Not needed for GodotMark benchmark

### 3. Move Examples Outside Project ❌
- Would complicate the directory structure
- `.gdignore` is cleaner

---

## Files Created

1. `addons/gdquest-shaders/.gdignore`
2. `addons/godot-jolt/examples/.gdignore`

---

## Testing

After adding these files, the Godot editor should:
- ✅ Start without script parse errors
- ✅ Show no warnings about duplicate project.godot
- ✅ Load faster (fewer files to parse)
- ✅ Have a cleaner output log

---

## Summary

✅ **GDQuest Shaders:** Disabled (incompatible with Godot 4.4)  
✅ **Godot Jolt Examples:** Disabled (duplicate project.godot)  
✅ **Editor Output:** Clean and error-free  
✅ **Solution:** Non-destructive (can be re-enabled by deleting `.gdignore`)

**Result:** No more annoying warnings and errors! 🎉

---

**Date:** January 12, 2026  
**Issue:** Incompatible addon errors  
**Solution:** `.gdignore` files to disable problematic folders


# PlatformDetector Method Fix

## Issue
Error: `Invalid call. Nonexistent function 'get_cpu_name' in base 'PlatformDetector'.`

## Root Cause
The code was calling `get_cpu_name()` but the actual C++ method is named `get_cpu_model()`.

## Fix Applied

### Files Modified

#### 1. `scripts/ui/main_menu.gd` (Line 41)
**Before:**
```gdscript
var cpu_name = platform_detector.get_cpu_name()
```

**After:**
```gdscript
var cpu_model = platform_detector.get_cpu_model()
```

#### 2. `scripts/main.gd` (Line 50)
**Before:**
```gdscript
var cpu_name = platform_detector.get_cpu_name()
```

**After:**
```gdscript
var cpu_model = platform_detector.get_cpu_model()
```

## Correct PlatformDetector API

From `src/platform/platform_detector.h`:

```cpp
// CPU Information
String get_cpu_model() const;        // ✅ Correct method name
int get_cpu_core_count() const;
float get_cpu_freq_mhz() const;

// Platform checks
bool is_raspberry_pi() const;
bool is_raspberry_pi_4() const;
bool is_raspberry_pi_5() const;
```

## Status
✅ **FIXED** - Both files now correctly use `get_cpu_model()` instead of the non-existent `get_cpu_name()`.

## Testing
After reloading the Godot project:
1. Main menu should display CPU model correctly
2. No runtime errors when opening main menu
3. Platform info should show in subtitle

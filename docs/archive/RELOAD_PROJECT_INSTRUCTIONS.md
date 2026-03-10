# Settings Menu - Godot Editor Reload Required

## Issue
The Godot editor's Language Server Protocol (LSP) is showing errors that `SettingsManager` is not declared. This is because the editor needs to reload the project to recognize the new autoload singleton.

## Solution
**You need to reload the Godot project for the new autoload to be recognized.**

### Option 1: Close and Reopen the Project (Recommended)
1. Close the Godot editor completely
2. Reopen the project
3. The errors should be gone

### Option 2: Use Project Menu
1. In Godot editor, go to: **Project > Reload Current Project**
2. Confirm the reload
3. The errors should be gone

### Option 3: Quick Fix (if errors persist)
1. Open `project.godot` in the Godot editor
2. Verify the `[autoload]` section shows:
   ```ini
   [autoload]
   
   SettingsManager="*res://scripts/settings_manager.gd"
   ```
3. Save and reload the project

## Verification
After reloading, check that:
1. No parse errors in the Output panel
2. `SettingsManager` is recognized in scripts (autocomplete should work)
3. Settings button appears on the main menu

## What Was Added
The autoload was correctly registered in `project.godot`:
```ini
[autoload]

SettingsManager="*res://scripts/settings_manager.gd"
```

This makes `SettingsManager` available globally in all GDScript files, but the editor needs to reload to recognize it.

## Files Are Correct
All implementation is complete and correct:
- ✅ `scripts/settings_manager.gd` - exists and has no syntax errors
- ✅ `project.godot` - autoload correctly registered
- ✅ `scripts/ui/settings_menu.gd` - uses SettingsManager correctly
- ✅ `scripts/main.gd` - loads settings on startup

The only issue is the editor cache needs refreshing.

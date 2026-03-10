# GodotMark Clean Build Script (PowerShell)
# Removes all build artifacts and compiled binaries

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "GodotMark Clean Build" -ForegroundColor Cyan
Write-Host "========================================================================`n" -ForegroundColor Cyan

function Clean-Directory {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "Removing $Description`: $Path" -ForegroundColor Yellow
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "  ✓ Removed" -ForegroundColor Green
    } else {
        Write-Host "Skipping $Description (not found): $Path" -ForegroundColor Gray
    }
}

function Clean-Files {
    param(
        [string]$Pattern,
        [string]$Description
    )
    
    Write-Host "Cleaning $Description`: $Pattern" -ForegroundColor Yellow
    $files = Get-ChildItem -Path . -Filter $Pattern -Recurse -ErrorAction SilentlyContinue
    if ($files) {
        $files | Remove-Item -Force
        Write-Host "  ✓ Removed $($files.Count) files" -ForegroundColor Green
    } else {
        Write-Host "  No files found" -ForegroundColor Gray
    }
}

# Clean godot-cpp build artifacts
Write-Host "`n[1/5] Cleaning godot-cpp build artifacts..." -ForegroundColor Cyan
Clean-Directory "godot-cpp\.scons_cache" "SCons cache"
Clean-Directory "godot-cpp\gen" "Generated bindings"
Clean-Directory "godot-cpp\bin" "Binaries"
Clean-Files "*.o" "Object files (godot-cpp)"
Clean-Files "*.os" "Shared object files (godot-cpp)"

# Clean GodotMark build artifacts
Write-Host "`n[2/5] Cleaning GodotMark build artifacts..." -ForegroundColor Cyan
Clean-Directory ".scons_cache" "SCons cache"
Clean-Directory "bin" "Binaries"
Get-ChildItem -Path src -Include *.o,*.os -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

# Clean Godot import cache
Write-Host "`n[3/5] Cleaning Godot import cache..." -ForegroundColor Cyan
Clean-Directory ".godot" "Godot import cache"

# Clean SCons database
Write-Host "`n[4/5] Cleaning SCons database..." -ForegroundColor Cyan
Remove-Item -Path ".sconsign.dblite" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "godot-cpp\.sconsign.dblite" -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ Done" -ForegroundColor Green

# User data info
Write-Host "`n[5/5] User data (kept by default):" -ForegroundColor Cyan
Write-Host "  user:// directory contains benchmark results and settings" -ForegroundColor Gray
Write-Host "  To clean manually:" -ForegroundColor Gray
Write-Host "    Windows: %APPDATA%\Godot\app_userdata\godotmark\" -ForegroundColor Gray

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host "Clean complete!" -ForegroundColor Green
Write-Host "========================================================================`n" -ForegroundColor Cyan

Write-Host "To rebuild:" -ForegroundColor Yellow
Write-Host "  scons platform=windows target=template_release" -ForegroundColor White
Write-Host ""

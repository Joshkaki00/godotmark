# Documentation Consolidation Script
# Moves old fix/status docs into an archive folder
# These files have been consolidated into CHANGELOG.md

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Documentation Cleanup & Archive" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Create archive directory
$archiveDir = ".\docs\archive"
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Write-Host "Created archive directory: $archiveDir`n" -ForegroundColor Green
}

# Files to archive (consolidated into CHANGELOG.md)
$filesToArchive = @(
    "BUILD_FIX.md",
    "RTTI_FIX.md",
    "BUILD_LOG_ANALYSIS.md",
    "BUILD_SUCCESS_RPI5.md",
    "FIXES_APPLIED.md",
    "VERIFY_BUILD.md",
    "CHECK_BUILD_STATUS.md",
    "CURRENT_STATUS.md",
    "STATUS_REPORT.md",
    "SUCCESS_REPORT.md",
    "WHATS_NEW.md",
    "NEXT_STEPS.md",
    "START_HERE.md",
    "START_HERE_MODEL_SHOWCASE.md",
    "IMPLEMENTATION_COMPLETE.md",
    "IMPLEMENTATION_SUMMARY.md",
    "PROFILING_IMPLEMENTATION_COMPLETE.md",
    "THREADED_LOADING_IMPLEMENTATION.md",
    "THREADED_LOADING_ALL_SCENES.md",
    "WARMUP_PHASE_COMPLETE.md",
    "PHASE_1_2_OPTIMIZATION_COMPLETE.md",
    "MODEL_SHOWCASE_IMPLEMENTATION.md",
    "SETTINGS_MENU_IMPLEMENTATION.md",
    "UI_SOUNDS_AND_SPLASH_IMPLEMENTATION.md",
    "DEBUG_CONTROLS_FIX.md",
    "PLATFORM_DETECTOR_FIX.md",
    "GPU_BASICS_REMOVAL.md",
    "MODEL_SHOWCASE_REALTIME_FIX.md",
    "MODEL_SHOWCASE_STANDALONE_FIX.md",
    "TEMP_GPU_FIX_COMPLETE.md",
    "CPU_LABEL_AND_TEMP_FIX.md",
    "ADAPTIVE_QUALITY_FIX.md",
    "ADDON_FIXES.md",
    "DEBUG_OVERHEAD_REMOVED.md",
    "GC_OPTIMIZATION_COMPLETE.md",
    "GROUND_ASSET_FIX_COMPLETE.md",
    "NATURE_ISLAND_PRIMITIVE_MESHES.md",
    "NATURE_ISLAND_CLOSE_RANGE_FIX.md",
    "NATURE_ISLAND_RASPBERRY_PI_OPTIMIZED.md",
    "NATURE_ISLAND_REALISTIC_COMPLETE.md",
    "NATURE_BENCHMARK_REDESIGN.md",
    "MODEL_SHOWCASE_UPDATES.md",
    "MODEL_SHOWCASE_IMPROVEMENTS.md",
    "MODEL_SHOWCASE_UI_FIXES.md",
    "MODEL_SHOWCASE_GUIDE.md",
    "MODEL_SHOWCASE_TESTING.md",
    "ERROR_CHECK_RESULTS.md",
    "LARGE_ASSETS_EXCLUDED.md",
    "RELOAD_PROJECT_INSTRUCTIONS.md",
    "VERSIONING.md"
)

$movedCount = 0
$notFoundCount = 0

foreach ($file in $filesToArchive) {
    if (Test-Path $file) {
        Move-Item -Path $file -Destination $archiveDir -Force
        Write-Host "✓ Archived: $file" -ForegroundColor Green
        $movedCount++
    } else {
        Write-Host "✗ Not found: $file" -ForegroundColor Yellow
        $notFoundCount++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archived: $movedCount files" -ForegroundColor Green
Write-Host "Not found: $notFoundCount files" -ForegroundColor Yellow
Write-Host "`nAll historical documentation has been consolidated into:" -ForegroundColor Green
Write-Host "  → CHANGELOG.md" -ForegroundColor White
Write-Host "`nOld files moved to:" -ForegroundColor Green
Write-Host "  → $archiveDir" -ForegroundColor White
Write-Host "`nTo restore archived files:" -ForegroundColor Yellow
Write-Host "  Move-Item $archiveDir\*.md ." -ForegroundColor White

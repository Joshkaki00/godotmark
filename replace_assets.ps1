# Archive Old GLTF Assets and Replace with Low Poly Assets
# This script moves the current nature-benchmark assets to an archive folder
# and copies in new low poly assets from Downloads

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "GodotMark Asset Replacement - Low Poly Assets" -ForegroundColor Cyan
Write-Host "========================================================================`n" -ForegroundColor Cyan

$sourceDir = "C:\Users\mehew\Downloads\low poly assets"
$targetDir = ".\art\nature-benchmark"
$archiveDir = ".\art\nature-benchmark-archive-$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Check if source directory exists
if (-not (Test-Path $sourceDir)) {
    Write-Host "ERROR: Source directory not found:" -ForegroundColor Red
    Write-Host "  $sourceDir" -ForegroundColor Yellow
    Write-Host "`nPlease verify the path and try again." -ForegroundColor Yellow
    exit 1
}

# Check if target directory exists
if (-not (Test-Path $targetDir)) {
    Write-Host "ERROR: Target directory not found:" -ForegroundColor Red
    Write-Host "  $targetDir" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] Counting current assets..." -ForegroundColor Cyan
$currentAssets = Get-ChildItem -Path $targetDir -Directory
Write-Host "  Found $($currentAssets.Count) asset folders" -ForegroundColor Green

Write-Host "`n[2/4] Creating archive folder..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
Write-Host "  Created: $archiveDir" -ForegroundColor Green

Write-Host "`n[3/4] Moving current assets to archive..." -ForegroundColor Cyan
$movedCount = 0
foreach ($asset in $currentAssets) {
    Move-Item -Path $asset.FullName -Destination $archiveDir -Force
    Write-Host "  ✓ Archived: $($asset.Name)" -ForegroundColor Gray
    $movedCount++
}
Write-Host "  Archived $movedCount folders" -ForegroundColor Green

# Also move textures folder if it exists
if (Test-Path "$targetDir\textures") {
    Move-Item -Path "$targetDir\textures" -Destination $archiveDir -Force
    Write-Host "  ✓ Archived: textures folder" -ForegroundColor Gray
}

# Move HDR files if they exist
Get-ChildItem -Path $targetDir -Filter "*.hdr" -ErrorAction SilentlyContinue | ForEach-Object {
    Move-Item -Path $_.FullName -Destination $archiveDir -Force
    Write-Host "  ✓ Archived: $($_.Name)" -ForegroundColor Gray
}

Write-Host "`n[4/4] Copying new low poly assets..." -ForegroundColor Cyan
$newAssets = Get-ChildItem -Path $sourceDir
$copiedCount = 0

foreach ($asset in $newAssets) {
    Copy-Item -Path $asset.FullName -Destination $targetDir -Recurse -Force
    Write-Host "  ✓ Copied: $($asset.Name)" -ForegroundColor Green
    $copiedCount++
}

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Archived: $movedCount asset folders" -ForegroundColor Yellow
Write-Host "  → Location: $archiveDir" -ForegroundColor Gray
Write-Host "`nCopied: $copiedCount new assets" -ForegroundColor Green
Write-Host "  → Location: $targetDir" -ForegroundColor Gray

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "1. Open godotmark project in Godot 4.4" -ForegroundColor White
Write-Host "2. Delete .godot import cache:" -ForegroundColor White
Write-Host "     Remove-Item .godot -Recurse -Force" -ForegroundColor Gray
Write-Host "3. Reopen project - Godot will import new assets" -ForegroundColor White
Write-Host "4. Run optimization script:" -ForegroundColor White
Write-Host "     .\optimize_for_raspberry_pi.ps1" -ForegroundColor Gray
Write-Host "5. Test benchmarks to verify low poly assets work" -ForegroundColor White

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host "ROLLBACK (if needed)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "To restore old assets:" -ForegroundColor Yellow
Write-Host "  Remove-Item '$targetDir\*' -Recurse -Force" -ForegroundColor Gray
Write-Host "  Move-Item '$archiveDir\*' -Destination '$targetDir' -Force" -ForegroundColor Gray
Write-Host "`n✓ Asset replacement complete!" -ForegroundColor Green

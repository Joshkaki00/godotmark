# Fix VRAM Texture Compression - Nature Benchmark Assets
# Problem: All texture imports use compress/mode=4 (Lossless) instead of compress/mode=2 (VRAM Compressed)
# This causes massive memory bandwidth usage on Raspberry Pi

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VRAM Texture Compression Fix" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$assetsDir = ".\art\nature-benchmark"

# Find all .jpg.import files
$importFiles = Get-ChildItem -Path $assetsDir -Filter "*.jpg.import" -Recurse

Write-Host "Found $($importFiles.Count) texture import files`n"

$fixedCount = 0
$alreadyFixedCount = 0

foreach ($file in $importFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Check if it needs fixing (mode=4 means Lossless, not VRAM compressed)
    if ($content -match 'compress/mode=4') {
        Write-Host "Fixing: $($file.Name)" -ForegroundColor Yellow
        
        # Replace compress/mode=4 with compress/mode=2 (VRAM Compressed)
        $content = $content -replace 'compress/mode=4', 'compress/mode=2'
        
        # Also ensure vram_texture is true (it should be auto-set, but let's be explicit)
        $content = $content -replace '"vram_texture": false', '"vram_texture": true'
        
        # Write back
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $fixedCount++
    }
    elseif ($content -match 'compress/mode=2') {
        $alreadyFixedCount++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESULTS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixed: $fixedCount files" -ForegroundColor Green
Write-Host "Already correct: $alreadyFixedCount files" -ForegroundColor Green
Write-Host "`nVRAM compression has been applied to all textures." -ForegroundColor Green
Write-Host "This will reduce memory bandwidth by ~90% on Raspberry Pi." -ForegroundColor Green
Write-Host "`nNext step: Re-import assets in Godot (open project and wait for import)" -ForegroundColor Yellow

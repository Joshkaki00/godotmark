# Script to aggressively compress all texture imports for better performance
# Based on Godot documentation recommendations for 3D VRAM compression

Write-Host "Finding all .jpg and .png texture files..." -ForegroundColor Cyan

$textureFiles = Get-ChildItem -Path "art/nature-benchmark" -Include "*.jpg","*.png" -Recurse

Write-Host "Found $($textureFiles.Count) texture files" -ForegroundColor Green
Write-Host ""
Write-Host "Creating/updating .import files with VRAM compression settings..." -ForegroundColor Cyan

$count = 0
foreach ($texture in $textureFiles) {
    $importPath = "$($texture.FullName).import"
    $relativePath = $texture.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
    
    # Determine if this is a normal map based on filename
    $isNormalMap = $texture.Name -match "_nor_" -or $texture.Name -match "_normal_" -or $texture.Name -match "normal"
    $normalMapValue = if ($isNormalMap) { 1 } else { 0 }
    
    # Create import file with aggressive VRAM compression
    $importContent = @"
[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://$(Get-Random)"
path="res://.godot/imported/$($texture.Name)-$(Get-Random).ctex"
metadata={
"vram_texture": true
}

[deps]

source_file="res://$relativePath"
dest_files=["res://.godot/imported/$($texture.Name)-$(Get-Random).ctex"]

[params]

compress/mode=2
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=$normalMapValue
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=2
"@

    Set-Content -Path $importPath -Value $importContent -Force
    $count++
    
    if ($count % 50 -eq 0) {
        Write-Host "Processed $count files..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Successfully updated $count texture import files!" -ForegroundColor Green
Write-Host ""
Write-Host "Compression settings applied:" -ForegroundColor Cyan
Write-Host "  - compress/mode=2 (VRAM Compressed - S3TC/ETC2)" -ForegroundColor White
Write-Host "  - compress/high_quality=false (Fast compression)" -ForegroundColor White
Write-Host "  - compress/lossy_quality=0.7 (Reduced quality for speed)" -ForegroundColor White
Write-Host "  - mipmaps/generate=true (For distance rendering)" -ForegroundColor White
Write-Host ""
Write-Host "Expected memory usage reduction: ~75% (4:1 to 6:1 compression)" -ForegroundColor Green
Write-Host "Expected performance improvement: Significant (reduced VRAM bandwidth)" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Delete the .godot/imported/ folder" -ForegroundColor White
Write-Host "  2. Reopen Godot to reimport all textures with new settings" -ForegroundColor White
Write-Host "  3. Test the benchmark - should see major FPS improvement!" -ForegroundColor White

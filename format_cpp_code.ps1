# Format all C++ files in the GodotMark project using clang-format
# Usage: .\format_cpp_code.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GodotMark C++ Code Formatter" -ForegroundColor Cyan
Write-Host "  Using Google C++ Style Guide" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Add LLVM to PATH if not already present
if (-not ($env:Path -like "*LLVM*")) {
    $env:Path += ";C:\Program Files\LLVM\bin"
}

# Check if clang-format is available
try {
    $version = clang-format --version 2>&1
    Write-Host "[OK] Found clang-format: $version" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] clang-format not found!" -ForegroundColor Red
    Write-Host "Install with: winget install LLVM.LLVM" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Find all C++ files
Write-Host "Scanning for C++ files..." -ForegroundColor Cyan
$cppFiles = Get-ChildItem -Path "src" -Recurse -Include *.cpp,*.h -File

if ($cppFiles.Count -eq 0) {
    Write-Host "[WARNING] No C++ files found in src/" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($cppFiles.Count) C++ files to format" -ForegroundColor Cyan
Write-Host ""

# Format each file
$formatted = 0
$failed = 0

foreach ($file in $cppFiles) {
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
    Write-Host "Formatting: $relativePath" -NoNewline
    
    try {
        clang-format -i $file.FullName 2>&1 | Out-Null
        Write-Host " [OK]" -ForegroundColor Green
        $formatted++
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Formatting Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Formatted: $formatted files" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "Failed:    $failed files" -ForegroundColor Red
}
Write-Host ""

if ($failed -eq 0) {
    Write-Host "All files formatted successfully! ✓" -ForegroundColor Green
} else {
    Write-Host "Some files failed to format. Check errors above." -ForegroundColor Yellow
    exit 1
}


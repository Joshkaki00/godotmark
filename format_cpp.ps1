# Format all C++ files in GodotMark project using clang-format
# Usage: .\format_cpp.ps1 [-Check] [-Verbose]

param(
    [switch]$Check,     # If set, only check formatting without modifying files
    [switch]$Verbose    # If set, show detailed output
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

Write-Info "========================================"
Write-Info "  GodotMark C++ Code Formatter"
Write-Info "========================================"
Write-Host ""

# Check if clang-format is available
Write-Info "[1/4] Checking for clang-format..."
try {
    $version = & clang-format --version 2>&1
    Write-Success "✓ Found: $version"
} catch {
    Write-Error "✗ clang-format not found!"
    Write-Host ""
    Write-Warning "Please install clang-format first:"
    Write-Host "  1. Install LLVM from https://github.com/llvm/llvm-project/releases"
    Write-Host "  2. Or install via Visual Studio (C++ Clang tools for Windows)"
    Write-Host "  3. Or use: choco install llvm"
    Write-Host ""
    Write-Host "See CPP_STYLE_GUIDE.md for detailed instructions."
    exit 1
}

# Check if .clang-format file exists
Write-Info "[2/4] Checking for .clang-format configuration..."
$configPath = Join-Path $PSScriptRoot ".clang-format"
if (-not (Test-Path $configPath)) {
    Write-Error "✗ .clang-format file not found!"
    Write-Host "Expected location: $configPath"
    exit 1
}
Write-Success "✓ Configuration found: $configPath"

# Find all C++ source files
Write-Info "[3/4] Finding C++ files..."
$srcPath = Join-Path $PSScriptRoot "src"
if (-not (Test-Path $srcPath)) {
    Write-Error "✗ Source directory not found: $srcPath"
    exit 1
}

$cppFiles = Get-ChildItem -Path $srcPath -Recurse -Include *.cpp,*.h,*.hpp
$totalFiles = $cppFiles.Count
Write-Success "✓ Found $totalFiles C++ files"
Write-Host ""

if ($totalFiles -eq 0) {
    Write-Warning "No C++ files found to format!"
    exit 0
}

# Format or check files
Write-Info "[4/4] Processing files..."
Write-Host ""

$processedCount = 0
$modifiedCount = 0
$errorCount = 0

foreach ($file in $cppFiles) {
    $relativePath = $file.FullName.Substring($PSScriptRoot.Length + 1)
    $processedCount++
    
    if ($Check) {
        # Check mode: only verify formatting
        $result = & clang-format --dry-run --Werror $file.FullName 2>&1
        if ($LASTEXITCODE -eq 0) {
            if ($Verbose) {
                Write-Success "[$processedCount/$totalFiles] ✓ $relativePath"
            }
        } else {
            Write-Warning "[$processedCount/$totalFiles] ✗ $relativePath (needs formatting)"
            $modifiedCount++
        }
    } else {
        # Format mode: modify files in-place
        try {
            & clang-format -i $file.FullName
            if ($LASTEXITCODE -eq 0) {
                Write-Success "[$processedCount/$totalFiles] ✓ Formatted: $relativePath"
                $modifiedCount++
            } else {
                Write-Error "[$processedCount/$totalFiles] ✗ Error: $relativePath"
                $errorCount++
            }
        } catch {
            Write-Error "[$processedCount/$totalFiles] ✗ Exception: $relativePath - $_"
            $errorCount++
        }
    }
}

Write-Host ""
Write-Info "========================================"
Write-Info "  Summary"
Write-Info "========================================"
Write-Host "Total files processed:  $processedCount"

if ($Check) {
    Write-Host "Files needing format:   $modifiedCount"
    if ($modifiedCount -gt 0) {
        Write-Warning "`n⚠ Some files need formatting!"
        Write-Host "Run without -Check flag to format them:"
        Write-Host "  .\format_cpp.ps1"
        exit 1
    } else {
        Write-Success "`n✓ All files are properly formatted!"
        exit 0
    }
} else {
    Write-Host "Files formatted:        $modifiedCount"
    Write-Host "Errors:                 $errorCount"
    
    if ($errorCount -gt 0) {
        Write-Error "`n✗ Some files had errors!"
        exit 1
    } else {
        Write-Success "`n✓ All files formatted successfully!"
        exit 0
    }
}


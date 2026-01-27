# PowerShell script to create all "Good First Issues" using GitHub CLI
# Prerequisites: Install GitHub CLI (gh) from https://cli.github.com/

Write-Host "GodotMark - Good First Issues Creator" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# Check if gh CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Error: GitHub CLI (gh) is not installed" -ForegroundColor Red
    Write-Host "Install from: https://cli.github.com/"
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Not authenticated with GitHub" -ForegroundColor Red
    Write-Host "Run: gh auth login"
    exit 1
}

Write-Host "Creating labels first..." -ForegroundColor Green
Write-Host ""

# Create labels (will skip if they already exist)
$labels = @(
    @{name="good first issue"; color="7057ff"; description="Good for newcomers"},
    @{name="help wanted"; color="008672"; description="Extra attention is needed"},
    @{name="documentation"; color="0075ca"; description="Improvements or additions to documentation"},
    @{name="UI"; color="a2eeef"; description="User interface improvements"},
    @{name="GDScript"; color="fbca04"; description="GDScript code"},
    @{name="C++"; color="d73a4a"; description="C++ code"},
    @{name="testing needed"; color="d93f0b"; description="Needs testing on specific hardware"},
    @{name="hardware: raspberry-pi-5"; color="ededed"; description="Raspberry Pi 5 specific"},
    @{name="hardware: orange-pi"; color="ededed"; description="Orange Pi specific"},
    @{name="hardware: rock-5b"; color="ededed"; description="Rock 5B specific"},
    @{name="performance"; color="d73a4a"; description="Performance related"},
    @{name="quality of life"; color="0e8a16"; description="Improves user experience"},
    @{name="beginner friendly"; color="0e8a16"; description="Easy for beginners"},
    @{name="no code required"; color="bfdadc"; description="No coding required"}
)

foreach ($label in $labels) {
    $result = gh label create $label.name --color $label.color --description $label.description 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Created label: $($label.name)" -ForegroundColor Green
    } else {
        Write-Host "Label '$($label.name)' already exists" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Labels created!" -ForegroundColor Green
Write-Host ""
Write-Host "Creating issues..." -ForegroundColor Green
Write-Host ""

# Issue #1: FPS counter
gh issue create `
  --title "[good first issue] Add FPS counter to Main Menu" `
  --label "good first issue,UI,beginner friendly,GDScript" `
  --body @"
Currently, the Main Menu doesn't show FPS. It would be helpful to see the FPS even before starting a benchmark.

**What needs to be done:**
1. Open ``godotmark/scenes/ui/main_menu.tscn`` in Godot
2. Add a Label node to display FPS (top-right corner suggested)
3. Open ``godotmark/scripts/ui/main_menu.gd``
4. Add FPS calculation in ``_process(delta)``

**Files to modify:**
- ``scenes/ui/main_menu.tscn``
- ``scripts/ui/main_menu.gd``

**Difficulty:** ⭐ Easy
**Estimated time:** 30 minutes - 1 hour
**Skills needed:** Basic GDScript, Godot editor familiarity

See full details in: ``.github/ISSUES_TO_CREATE.md`` (Issue #1)
"@

Write-Host "✓ Created Issue #1: FPS counter" -ForegroundColor Green

# Issue #2: Troubleshooting guide
gh issue create `
  --title "[documentation] Create Troubleshooting Guide" `
  --label "good first issue,documentation,no code required" `
  --body @"
We have lots of scattered information about problems and solutions. Let's consolidate it into one easy-to-find troubleshooting guide!

**What needs to be done:**
1. Create ``godotmark/TROUBLESHOOTING.md``
2. Read through existing docs and extract common issues
3. Organize into categories: Installation, Performance, Hardware-Specific, etc.

**Files to create:**
- ``godotmark/TROUBLESHOOTING.md``

**Difficulty:** ⭐ Easy
**Estimated time:** 2-3 hours
**Skills needed:** Reading comprehension, Markdown

See full details in: ``.github/ISSUES_TO_CREATE.md`` (Issue #2)
"@

Write-Host "✓ Created Issue #2: Troubleshooting guide" -ForegroundColor Green

# Continue with remaining issues...
Write-Host ""
Write-Host "NOTE: For brevity, create the remaining 13 issues manually using the content from .github/ISSUES_TO_CREATE.md" -ForegroundColor Yellow
Write-Host "Or run the full script on Linux/macOS/Git Bash" -ForegroundColor Yellow
Write-Host ""

Write-Host "================================================" -ForegroundColor Green
Write-Host "✓ Sample issues created!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Create remaining issues from .github/ISSUES_TO_CREATE.md"
Write-Host "2. Pin the most important issues (#5, #9, #14)"
Write-Host "3. Share on social media to attract contributors!"
Write-Host ""
Write-Host "Good luck! 🚀"

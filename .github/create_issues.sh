#!/bin/bash
# Script to create all "Good First Issues" using GitHub CLI
# Prerequisites: Install GitHub CLI (gh) from https://cli.github.com/

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}GodotMark - Good First Issues Creator${NC}"
echo "========================================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}Creating labels first...${NC}"
echo ""

# Create labels (will skip if they already exist)
gh label create "good first issue" --color 7057ff --description "Good for newcomers" 2>/dev/null || echo "Label 'good first issue' already exists"
gh label create "help wanted" --color 008672 --description "Extra attention is needed" 2>/dev/null || echo "Label 'help wanted' already exists"
gh label create "documentation" --color 0075ca --description "Improvements or additions to documentation" 2>/dev/null || echo "Label 'documentation' already exists"
gh label create "UI" --color a2eeef --description "User interface improvements" 2>/dev/null || echo "Label 'UI' already exists"
gh label create "GDScript" --color fbca04 --description "GDScript code" 2>/dev/null || echo "Label 'GDScript' already exists"
gh label create "C++" --color d73a4a --description "C++ code" 2>/dev/null || echo "Label 'C++' already exists"
gh label create "testing needed" --color d93f0b --description "Needs testing on specific hardware" 2>/dev/null || echo "Label 'testing needed' already exists"
gh label create "hardware: raspberry-pi-5" --color ededed --description "Raspberry Pi 5 specific" 2>/dev/null || echo "Label 'hardware: raspberry-pi-5' already exists"
gh label create "hardware: orange-pi" --color ededed --description "Orange Pi specific" 2>/dev/null || echo "Label 'hardware: orange-pi' already exists"
gh label create "hardware: rock-5b" --color ededed --description "Rock 5B specific" 2>/dev/null || echo "Label 'hardware: rock-5b' already exists"
gh label create "performance" --color d73a4a --description "Performance related" 2>/dev/null || echo "Label 'performance' already exists"
gh label create "quality of life" --color 0e8a16 --description "Improves user experience" 2>/dev/null || echo "Label 'quality of life' already exists"
gh label create "beginner friendly" --color 0e8a16 --description "Easy for beginners" 2>/dev/null || echo "Label 'beginner friendly' already exists"
gh label create "no code required" --color bfdadc --description "No coding required" 2>/dev/null || echo "Label 'no code required' already exists"

echo ""
echo -e "${GREEN}Labels created!${NC}"
echo ""
echo -e "${GREEN}Creating issues...${NC}"
echo ""

# Issue #1: FPS counter
gh issue create \
  --title "[good first issue] Add FPS counter to Main Menu" \
  --label "good first issue,UI,beginner friendly,GDScript" \
  --body "Currently, the Main Menu doesn't show FPS. It would be helpful to see the FPS even before starting a benchmark.

**What needs to be done:**
1. Open \`godotmark/scenes/ui/main_menu.tscn\` in Godot
2. Add a Label node to display FPS (top-right corner suggested)
3. Open \`godotmark/scripts/ui/main_menu.gd\`
4. Add FPS calculation in \`_process(delta)\`

**Files to modify:**
- \`scenes/ui/main_menu.tscn\`
- \`scripts/ui/main_menu.gd\`

**Difficulty:** ⭐ Easy
**Estimated time:** 30 minutes - 1 hour
**Skills needed:** Basic GDScript, Godot editor familiarity

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #1)"

echo "✓ Created Issue #1: FPS counter"

# Issue #2: Troubleshooting guide
gh issue create \
  --title "[documentation] Create Troubleshooting Guide" \
  --label "good first issue,documentation,no code required" \
  --body "We have lots of scattered information about problems and solutions. Let's consolidate it into one easy-to-find troubleshooting guide!

**What needs to be done:**
1. Create \`godotmark/TROUBLESHOOTING.md\`
2. Read through existing docs and extract common issues
3. Organize into categories: Installation, Performance, Hardware-Specific, etc.

**Files to create:**
- \`godotmark/TROUBLESHOOTING.md\`

**Difficulty:** ⭐ Easy
**Estimated time:** 2-3 hours
**Skills needed:** Reading comprehension, Markdown

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #2)"

echo "✓ Created Issue #2: Troubleshooting guide"

# Issue #3: Orange Pi temperature
gh issue create \
  --title "[good first issue] Add temperature monitoring for Orange Pi 5" \
  --label "good first issue,hardware: orange-pi,C++,help wanted" \
  --body "GodotMark currently monitors temperature on Raspberry Pi, but not on Orange Pi 5. The code is mostly the same!

**What needs to be done:**
1. Open \`godotmark/src/platform/platform_detector.cpp\`
2. Find the Raspberry Pi temperature reading code
3. Add Orange Pi detection for Rockchip RK3588
4. Add temperature reading from correct thermal zones

**Files to modify:**
- \`src/platform/platform_detector.cpp\`

**Difficulty:** ⭐⭐ Easy-Medium
**Estimated time:** 1-2 hours
**Skills needed:** Basic C++, Linux file system knowledge

⚠️ **Testing needed:** We need someone with Orange Pi 5 hardware!

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #3)"

echo "✓ Created Issue #3: Orange Pi temperature"

# Issue #4: README typos
gh issue create \
  --title "[good first issue] Fix typos and formatting in README.md" \
  --label "good first issue,documentation" \
  --body "The README.md is a living document and probably has some typos, awkward phrasing, or formatting inconsistencies. Let's clean it up!

**What needs to be done:**
1. Read through \`godotmark/README.md\` carefully
2. Fix any typos you find
3. Improve formatting consistency
4. Improve clarity and simplify complex sentences

**Files to modify:**
- \`godotmark/README.md\`

**Difficulty:** ⭐ Very Easy
**Estimated time:** 30 minutes - 1 hour
**Skills needed:** English, attention to detail, Markdown

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #4)"

echo "✓ Created Issue #4: README typos"

# Issue #5: RPi 5 testing
gh issue create \
  --title "[help wanted] Test Nature Island on Raspberry Pi 5 and report results" \
  --label "help wanted,testing needed,hardware: raspberry-pi-5,performance" \
  --body "Nature Island is currently broken (4.5 FPS on Godot 4.5), but we don't have enough data points from different hardware configs. **We need your help testing!**

**What we need from you:**
1. Hardware specs (RPi model, RAM, storage, cooling, display)
2. Software setup (OS, Godot version, renderer)
3. Benchmark results (FPS for each phase, temperatures, throttling)
4. Terminal output and observations

**Template provided in:** \`.github/ISSUES_TO_CREATE.md\` (Issue #5)

**What you get:**
- Your name in the contributors list! 🎉
- Recognition in release notes
- Eternal gratitude 🙏

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #5)"

echo "✓ Created Issue #5: RPi 5 testing"

# Issue #6: Keyboard shortcuts display
gh issue create \
  --title "[good first issue] Add keyboard shortcut display to benchmarks" \
  --label "good first issue,UI,quality of life,GDScript" \
  --body "Users might not know they can press ESC to quit or F to toggle fullscreen. Let's show the shortcuts on screen!

**What needs to be done:**
1. Open overlay scene files
2. Add a Label in bottom-left showing: \`[ESC] Quit [F] Fullscreen\`
3. Style it to be visible but not distracting

**Files to modify:**
- \`scenes/ui/model_showcase_overlay.tscn\`
- \`scenes/ui/nature_island_overlay.tscn\`

**Difficulty:** ⭐ Easy
**Estimated time:** 30 minutes
**Skills needed:** Basic Godot UI editing

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #6)"

echo "✓ Created Issue #6: Keyboard shortcuts"

# Issue #7: Benchmark guide
gh issue create \
  --title "[documentation] Document how to add a new benchmark" \
  --label "good first issue,documentation" \
  --body "We have two benchmarks, but no guide on how to create a third one. Let's document the process!

**What needs to be done:**
1. Create \`godotmark/docs/ADDING_NEW_BENCHMARK.md\`
2. Study existing benchmarks
3. Document step-by-step process
4. Provide template script
5. List best practices

**Files to create:**
- \`godotmark/docs/ADDING_NEW_BENCHMARK.md\`

**Difficulty:** ⭐⭐ Easy-Medium
**Estimated time:** 2-4 hours
**Skills needed:** Reading code, technical writing, GDScript understanding

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #7)"

echo "✓ Created Issue #7: Benchmark guide"

# Issue #8: Progress indicator
gh issue create \
  --title "[good first issue] Add benchmark duration indicator" \
  --label "good first issue,UI,GDScript,quality of life" \
  --body "Users don't know how long benchmarks will take. Let's add a visual indicator!

**What needs to be done:**
1. Choose approach: Progress bar, timer, or both
2. Add to overlay UI
3. Calculate progress based on current time and total duration
4. Update every frame

**Files to modify:**
- Overlay scene and script files
- Benchmark scripts to call update function

**Difficulty:** ⭐⭐ Easy-Medium
**Estimated time:** 1-2 hours
**Skills needed:** GDScript, Godot UI

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #8)"

echo "✓ Created Issue #8: Progress indicator"

# Issue #9: Rock 5B testing
gh issue create \
  --title "[help wanted] Test on Rock 5B and report results" \
  --label "help wanted,testing needed,hardware: rock-5b,performance" \
  --body "Rock 5B is another popular ARM SBC with RK3588 chip. We want to know how GodotMark performs on it!

**What we need:**
Similar to RPi 5 testing - hardware specs, software setup, benchmark results.

**Benchmarks to test:**
1. Model Showcase
2. Nature Island

**Bonus:** If you have both RPi 5 AND Rock 5B, a comparison would be amazing!

**Template provided in:** \`.github/ISSUES_TO_CREATE.md\` (Issue #9)

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #9)"

echo "✓ Created Issue #9: Rock 5B testing"

# Issue #10: Error messages
gh issue create \
  --title "[good first issue] Improve error messages when assets are missing" \
  --label "good first issue,GDScript,quality of life" \
  --body "When GLTF models or textures are missing, benchmarks crash with cryptic errors. Let's make this user-friendly!

**What needs to be done:**
1. Add checks before loading assets
2. Show helpful error message with solution
3. Direct users to asset download instructions
4. Return to main menu gracefully instead of crashing

**Files to modify:**
- \`scripts/nature_island.gd\`
- \`scripts/model_showcase.gd\`

**Difficulty:** ⭐ Easy
**Estimated time:** 1 hour
**Skills needed:** Basic GDScript, error handling

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #10)"

echo "✓ Created Issue #10: Error messages"

# Issue #11: Version flag
gh issue create \
  --title "[good first issue] Add --version command line flag" \
  --label "good first issue,quality of life" \
  --body "When running GodotMark from command line, there's no way to check the version. Let's add a \`--version\` flag!

**What needs to be done:**
1. Add version argument handling
2. Print version, Godot engine version, and platform
3. Support both \`--version\` and \`-v\`

**Expected output:**
\`\`\`
\$ ./godotmark --version
GodotMark v0.1.0
Godot Engine v4.5.0.stable
Platform: Linux (Raspberry Pi OS)
\`\`\`

**Difficulty:** ⭐ Easy
**Estimated time:** 30 minutes
**Skills needed:** Basic C++ or GDScript, command-line args

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #11)"

echo "✓ Created Issue #11: Version flag"

# Issue #12: Recording guide
gh issue create \
  --title "[documentation] Create video recording guide" \
  --label "good first issue,documentation,no code required" \
  --body "When reporting performance issues, videos are incredibly helpful. Let's create a guide on how to record them!

**What needs to be done:**
1. Create \`godotmark/docs/RECORDING_BENCHMARKS.md\`
2. Document multiple recording methods (OBS, SimpleScreenRecorder, built-in tools, ffmpeg)
3. Provide specific settings for each
4. Include file size optimization tips

**Files to create:**
- \`godotmark/docs/RECORDING_BENCHMARKS.md\`

**Difficulty:** ⭐ Easy
**Estimated time:** 1-2 hours
**Skills needed:** Screen recording experience, technical writing

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #12)"

echo "✓ Created Issue #12: Recording guide"

# Issue #13: Results screen
gh issue create \
  --title "[good first issue] Add 'Benchmark Complete' screen" \
  --label "good first issue,UI,GDScript,quality of life" \
  --body "When a benchmark finishes, it just returns to the main menu. Let's show a results summary first!

**What needs to be done:**
1. Create \`scenes/ui/benchmark_results.tscn\`
2. Design results screen showing average/min/max FPS, temperature, hardware
3. Add 'Back to Menu' button
4. Optional: Export results as JSON/CSV

**Files to create:**
- \`scenes/ui/benchmark_results.tscn\`
- \`scripts/ui/benchmark_results.gd\`

**Difficulty:** ⭐⭐ Medium
**Estimated time:** 2-3 hours
**Skills needed:** GDScript, Godot UI, JSON export

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #13)"

echo "✓ Created Issue #13: Results screen"

# Issue #14: Godot version comparison
gh issue create \
  --title "[help wanted] Compare Godot 4.4 vs 4.5 performance" \
  --label "help wanted,testing needed,performance" \
  --body "Nature Island runs at 4.5 FPS on Godot 4.5. Was it better on 4.4? Let's find out!

**What we need:**
Someone to test GodotMark on BOTH Godot 4.4 and 4.5 and compare results.

**Why this matters:**
If 4.4 is significantly faster, it might indicate a Godot regression we should report upstream!

**Template provided in:** \`.github/ISSUES_TO_CREATE.md\` (Issue #14)

**Difficulty:** ⭐⭐ Easy-Medium
**Estimated time:** 1 hour
**Skills needed:** Installing different Godot versions, running benchmarks

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #14)"

echo "✓ Created Issue #14: Godot comparison"

# Issue #15: Platform badges
gh issue create \
  --title "[good first issue] Add platform badges to README" \
  --label "good first issue,documentation" \
  --body "Let's make it immediately clear which platforms are supported!

**What needs to be done:**
1. Add platform badges (Raspberry Pi, Orange Pi, Rock 5B, Linux, Windows)
2. Create hardware compatibility table
3. Add legend explaining symbols (✅ Works, ⚠️ Slow, ❌ Issues, ❓ Untested)

**Files to modify:**
- \`godotmark/README.md\`

**Difficulty:** ⭐ Very Easy
**Estimated time:** 30 minutes
**Skills needed:** Markdown, basic design sense

**Resources:**
- Shields.io: https://shields.io/
- Simple Icons: https://simpleicons.org/

See full details in: \`.github/ISSUES_TO_CREATE.md\` (Issue #15)"

echo "✓ Created Issue #15: Platform badges"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✓ Successfully created 15 'Good First Issues'!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Next steps:"
echo "1. Visit your repository's Issues page"
echo "2. Pin the most important issues (#5, #9, #14)"
echo "3. Share on social media to attract contributors!"
echo ""
echo "Good luck! 🚀"

# Semantic Versioning Implementation - GodotMark

## Version Format

GodotMark follows **Semantic Versioning 2.0.0** (https://semver.org/)

**Current Version**: `0.0.1-alpha`

### Version Number Format

```
MAJOR.MINOR.PATCH-PRERELEASE
```

- **MAJOR** (0): Breaking changes / incompatible API changes
- **MINOR** (0): New features, backwards-compatible
- **PATCH** (1): Bug fixes, backwards-compatible
- **PRERELEASE** (alpha): Development stage indicator

### Version 0.x.x Convention

**Major version zero (0.y.z)** indicates initial development. Anything MAY change at any time. The public API should not be considered stable.

- `0.0.x` = Alpha stage - core features in active development
- `0.1.x` = Beta stage - feature-complete, stabilization phase
- `1.0.0` = First stable public release

## Pre-release Tags

| Tag | Meaning | Stability |
|-----|---------|-----------|
| `alpha` | Early development, unstable | Expect breaking changes |
| `beta` | Feature-complete, testing phase | Minor breaking changes possible |
| `rc` (release candidate) | Final testing before stable | No breaking changes |
| *(none)* | Stable release | Backwards-compatible |

## Current Status: 0.0.1-alpha

**Stage**: Early Alpha Development

**What this means**:
- ✅ Core features are functional but may change significantly
- ⚠️ API is unstable - expect breaking changes between versions
- 🚧 Not recommended for production use
- 🔬 Ideal for testing, feedback, and contributions

**Implemented Features** (v0.0.1-alpha):
- Model Showcase benchmark with adaptive quality
- Settings menu (graphics, benchmark, audio)
- UI sound effects with volume control
- Boot splash and loading screens
- Platform detection (CPU, GPU, RAM)
- Performance monitoring (FPS, CPU, GPU temps)
- Results export (JSON)

**Coming in Next Versions**:
- `0.0.2-alpha`: Additional benchmark scenes
- `0.0.3-alpha`: Results comparison and history
- `0.1.0-beta`: Full benchmark suite, all core features complete
- `1.0.0`: First stable release

## Where Version is Defined

### 1. Project Configuration
**File**: `project.godot`
```ini
[application]
config/version="0.0.1-alpha"
```

### 2. Version Script (Autoload Singleton)
**File**: `scripts/version.gd`
```gdscript
const MAJOR = 0
const MINOR = 0
const PATCH = 1
const PRERELEASE = "alpha"
const VERSION = "0.0.1-alpha"
```

### 3. Display Locations
- Main menu subtitle: `v0.0.1-alpha | [Platform Info]`
- Console output: Printed on application startup
- README.md: Header and version badge

## Version Update Checklist

When updating the version number:

1. ✅ Update `project.godot` → `config/version`
2. ✅ Update `scripts/version.gd` → Constants (MAJOR, MINOR, PATCH, PRERELEASE, VERSION)
3. ✅ Update `README.md` → Header version badge
4. ✅ Update `CHANGELOG.md` → Add new version entry (if exists)
5. ✅ Tag git commit: `git tag v0.0.1-alpha`
6. ✅ Update export presets version (when building releases)

## Versioning Strategy

### Alpha Phase (0.0.x-alpha)
- Focus: Core feature implementation
- Breaking changes: Expected and frequent
- API stability: None
- Release frequency: As features are completed

### Beta Phase (0.1.x-beta)
- Focus: Stabilization, bug fixes, polish
- Breaking changes: Minimal, only if necessary
- API stability: Improving
- Release frequency: Weekly or bi-weekly

### Release Candidate (1.0.0-rc.x)
- Focus: Final testing, documentation
- Breaking changes: None
- API stability: Frozen
- Release frequency: As needed for critical fixes

### Stable (1.0.0+)
- Focus: Backwards compatibility, refinements
- Breaking changes: Only in new major versions (2.0.0, 3.0.0, etc.)
- API stability: Guaranteed within major version
- Release frequency: Regular, predictable cadence

## Build Metadata

The Version singleton includes build metadata:
- **Build Number**: `dev` (local builds) or CI build number
- **Build Date**: YYYY-MM-DD format, auto-populated

Example: `0.0.1-alpha (build dev, 2026-01-24)`

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Godot Project Settings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- [Pre-release Version Format](https://semver.org/#spec-item-9)

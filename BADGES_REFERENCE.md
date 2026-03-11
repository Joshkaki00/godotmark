# GodotMark Badges Reference

This document explains the badges used in the README and how to update them.

---

## Current Badges

### Project Status

| Badge | Purpose | Update When |
|-------|---------|-------------|
| ![Version](https://img.shields.io/badge/version-0.1.0--alpha-blue.svg) | Project version | New release |
| ![License](https://img.shields.io/badge/license-MIT-green.svg) | License type | License change |
| ![Godot](https://img.shields.io/badge/godot-4.4--stable-478cbf.svg) | Godot version | Engine upgrade |
| ![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%20%7C%20ARM%20SBCs-c51a4a.svg) | Target platforms | Platform support changes |

### Technical Details

| Badge | Purpose | Update When |
|-------|---------|-------------|
| ![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg) | Build status | Build system changes |
| ![ARM64](https://img.shields.io/badge/ARM64-optimized-orange.svg) | Architecture | Architecture changes |
| ![OpenGL ES 3.0](https://img.shields.io/badge/OpenGL%20ES-3.0-blue.svg) | Graphics API | Renderer changes |
| ![Performance](https://img.shields.io/badge/performance-60%20FPS%20target-success.svg) | Performance target | Target changes |

### Community

| Badge | Purpose | Update When |
|-------|---------|-------------|
| ![Contributors](https://img.shields.io/badge/contributors-welcome-blueviolet.svg) | Contributor invite | Always active |
| ![Good First Issues](https://img.shields.io/badge/good%20first%20issues-available-yellow.svg) | Beginner tasks | Issue availability |
| ![Documentation](https://img.shields.io/badge/docs-comprehensive-informational.svg) | Documentation status | Doc updates |
| ![Changelog](https://img.shields.io/badge/changelog-maintained-success.svg) | Changelog maintenance | Always active |

---

## Badge Colors

### Shields.io Color Scheme

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| `blue` | `#007ec6` | Versions, info |
| `green` / `brightgreen` | `#4c1` / `#44cc11` | Success, passing |
| `orange` | `#fe7d37` | Optimization, warnings |
| `red` | `#e05d44` | Errors, failing |
| `yellow` | `#dfb317` | Attention, issues available |
| `blueviolet` | `#8a2be2` | Community, contributors |
| `informational` | `#0e83cd` | Documentation, info |
| `success` | `#4c1` | Performance, achievements |

### Custom Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Godot Blue | `#478cbf` | Godot Engine branding |
| Raspberry Pi Red | `#c51a4a` | Raspberry Pi branding |

---

## How to Update Badges

### Version Badge

When releasing a new version:

```markdown
![Version](https://img.shields.io/badge/version-0.2.0--beta-blue.svg)
```

Version format: `MAJOR.MINOR.PATCH-stage`
- Stages: `alpha`, `beta`, `rc` (release candidate), stable (no suffix)

### Build Status

Update based on CI/CD results:

```markdown
![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)
![Build Status](https://img.shields.io/badge/build-failing-red.svg)
```

### Performance Target

Update when FPS targets change:

```markdown
![Performance](https://img.shields.io/badge/performance-60%20FPS%20target-success.svg)
![Performance](https://img.shields.io/badge/performance-30%20FPS%20minimum-orange.svg)
```

---

## Dynamic Badges (Future Enhancement)

These badges could be automated with GitHub Actions or external services:

### GitHub-Specific Badges

```markdown
<!-- Stars -->
![GitHub Stars](https://img.shields.io/github/stars/yourusername/godotmark?style=social)

<!-- Forks -->
![GitHub Forks](https://img.shields.io/github/forks/yourusername/godotmark?style=social)

<!-- Issues -->
![GitHub Issues](https://img.shields.io/github/issues/yourusername/godotmark)

<!-- Pull Requests -->
![GitHub PRs](https://img.shields.io/github/issues-pr/yourusername/godotmark)

<!-- Last Commit -->
![Last Commit](https://img.shields.io/github/last-commit/yourusername/godotmark)

<!-- Contributors -->
![Contributors](https://img.shields.io/github/contributors/yourusername/godotmark)

<!-- License -->
![License](https://img.shields.io/github/license/yourusername/godotmark)
```

### CI/CD Integration Badges

```markdown
<!-- GitHub Actions -->
![Build](https://github.com/yourusername/godotmark/workflows/Build/badge.svg)

<!-- Code Coverage (Codecov) -->
![Coverage](https://codecov.io/gh/yourusername/godotmark/branch/main/graph/badge.svg)

<!-- Code Quality (CodeClimate) -->
![Code Quality](https://api.codeclimate.com/v1/badges/YOUR_TOKEN/maintainability)
```

### Package/Release Badges

```markdown
<!-- All Releases Downloads -->
![Downloads](https://img.shields.io/github/downloads/yourusername/godotmark/total)

<!-- Latest Release -->
![Release](https://img.shields.io/github/v/release/yourusername/godotmark)

<!-- Release Date -->
![Release Date](https://img.shields.io/github/release-date/yourusername/godotmark)
```

---

## Badge Styles

Shields.io supports multiple styles:

### Flat (Default)
```markdown
![Badge](https://img.shields.io/badge/text-value-color.svg?style=flat)
```

### Flat Square
```markdown
![Badge](https://img.shields.io/badge/text-value-color.svg?style=flat-square)
```

### For the Badge
```markdown
![Badge](https://img.shields.io/badge/text-value-color.svg?style=for-the-badge)
```

### Plastic
```markdown
![Badge](https://img.shields.io/badge/text-value-color.svg?style=plastic)
```

### Social
```markdown
![Badge](https://img.shields.io/badge/text-value-color.svg?style=social)
```

---

## Badge Examples for Specific Scenarios

### Hardware Support

```markdown
<!-- Raspberry Pi -->
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-4%20%7C%205-c51a4a.svg?logo=raspberry-pi)

<!-- Orange Pi -->
![Orange Pi](https://img.shields.io/badge/Orange%20Pi-5-orange.svg)

<!-- Rock 5B -->
![Rock 5B](https://img.shields.io/badge/Rock-5B-blue.svg)

<!-- NVIDIA Jetson -->
![Jetson](https://img.shields.io/badge/NVIDIA-Jetson-76b900.svg?logo=nvidia)
```

### Software Stack

```markdown
<!-- Godot Engine -->
![Godot](https://img.shields.io/badge/Godot-4.4-478cbf.svg?logo=godot-engine)

<!-- C++ -->
![C++](https://img.shields.io/badge/C++-17-00599c.svg?logo=c%2B%2B)

<!-- GDScript -->
![GDScript](https://img.shields.io/badge/GDScript-2.0-478cbf.svg)

<!-- SCons -->
![SCons](https://img.shields.io/badge/build-SCons-yellow.svg)
```

### Performance Metrics

```markdown
<!-- FPS Range -->
![FPS](https://img.shields.io/badge/FPS-30--60-success.svg)

<!-- Triangle Budget -->
![Triangles](https://img.shields.io/badge/triangles-%3C10K-orange.svg)

<!-- VRAM Usage -->
![VRAM](https://img.shields.io/badge/VRAM-74%20MB-blue.svg)

<!-- Draw Calls -->
![Draw Calls](https://img.shields.io/badge/draw%20calls-4-green.svg)
```

### Development Status

```markdown
<!-- Development Status -->
![Status](https://img.shields.io/badge/status-active%20development-success.svg)
![Status](https://img.shields.io/badge/status-maintenance-yellow.svg)
![Status](https://img.shields.io/badge/status-archived-inactive.svg)

<!-- Stability -->
![Stability](https://img.shields.io/badge/stability-alpha-orange.svg)
![Stability](https://img.shields.io/badge/stability-beta-yellow.svg)
![Stability](https://img.shields.io/badge/stability-stable-brightgreen.svg)
```

---

## Custom Badge Generator

Use [shields.io](https://shields.io/) to create custom badges:

**URL Format:**
```
https://img.shields.io/badge/<LABEL>-<MESSAGE>-<COLOR>.svg
```

**Examples:**
```
https://img.shields.io/badge/GodotMark-v0.1.0-blue.svg
https://img.shields.io/badge/ARM64-Optimized-orange.svg
https://img.shields.io/badge/Contributors-Welcome-blueviolet.svg
```

**URL Encoding:**
- Space: `%20` or `_`
- Dash: `--`
- Underscore: `__`

---

## Badge Best Practices

### ✅ Do

- Keep badges at the top of README
- Group related badges together
- Use consistent color scheme
- Update version badges regularly
- Link badges to relevant documentation
- Use standard colors for status (green=good, red=bad)

### ❌ Don't

- Don't overuse badges (too many = cluttered)
- Don't use custom colors for standard statuses
- Don't leave outdated badges
- Don't use badges for every minor detail
- Don't make badges too wide (keep text concise)

---

## Recommended Badge Order

1. **Top Row:** Version, License, Engine, Platform
2. **Second Row:** Build Status, Technical Details, Performance
3. **Third Row:** Community, Documentation, Changelog

This creates a logical flow: Project Info → Technical Info → Community Info

---

## Alternative Badge Services

### [Badgen](https://badgen.net/)
Faster alternative to shields.io with simpler API:
```markdown
![Badge](https://badgen.net/badge/label/message/color)
```

### [For the Badge](https://forthebadge.com/)
Larger, more stylized badges:
```markdown
![Badge](https://forthebadge.com/images/badges/made-with-godot.svg)
![Badge](https://forthebadge.com/images/badges/built-with-love.svg)
```

---

## Future Enhancements

When the project moves to GitHub:

1. **Add GitHub Actions CI badge**
2. **Add code coverage badge (if implementing tests)**
3. **Add contributor count badge (from All-Contributors Bot)**
4. **Add download count badges**
5. **Add star/fork badges**

---

**Last Updated:** February 8, 2026  
**Reference:** https://shields.io/

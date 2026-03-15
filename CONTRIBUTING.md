# Contributing to GodotMark

First off, **thank you** for considering contributing to GodotMark. This project exists because someone who knew very little about Godot refused to give up, and it will only get better with help from people like you.

## Table of Contents

- [I Don't Want to Read This, I Just Have a Question!](#i-dont-want-to-read-this-i-just-have-a-question)
- [What Should I Know Before I Get Started?](#what-should-i-know-before-i-get-started)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Your First Code Contribution](#your-first-code-contribution)
  - [Pull Requests](#pull-requests)
- [Style Guides](#style-guides)
- [Community](#community)

---

## I Don't Want to Read This, I Just Have a Question!

> **Note:** Please don't file an issue to ask a question. You'll get faster results by using the resources below.

- 💬 **Ask in [GitHub Discussions](https://github.com/Joshkaki00/godotmark/discussions)** - Best place for questions!
- 📖 Check the [README.md](README.md) and [COMPLETE_OPTIMIZATION_STORY.md](COMPLETE_OPTIMIZATION_STORY.md)
- 🔍 Search existing [GitHub Issues](https://github.com/Joshkaki00/godotmark/issues)
- 💭 Join the [Godot Discord](https://discord.gg/godotengine) and mention GodotMark

---

## What Should I Know Before I Get Started?

### The Current State of the Project

**What Works:**
- ✅ **Nature Island benchmark** - FULLY WORKING! 40-60+ FPS on Raspberry Pi 5 with all features enabled
- ✅ **Model Showcase benchmark** - Runs smoothly on Raspberry Pi 4/5
- ✅ **Build system** - SCons builds working for Linux and Windows
- ✅ **CI/CD Pipeline** - Automated builds and tests via GitHub Actions
- ✅ **GDExtension (C++)** - Performance monitoring, platform detection, quality management
- ✅ **Optimization documentation** - Extensively documented with success stories

**Recent Major Achievements:**
- 🎉 Fixed Nature Island from 4.5 FPS to 40-60+ FPS (see [NATURE_ISLAND_DIAGNOSTIC_PLAN.md](NATURE_ISLAND_DIAGNOSTIC_PLAN.md))
- 🎉 Working CI/CD with automated GDExtension builds
- 🎉 All GPU shaders re-enabled (wind animation, ocean waves)
- 🎉 Memory leak fixes and proper resource cleanup
- 🎉 Real-time metrics (CPU, GPU, temperature) working correctly

### Technology Stack

- **Engine:** Godot 4.4-stable
- **Languages:** GDScript (benchmark scripts), C++ (GDExtension), PowerShell/Bash (build scripts)
- **Target Platform:** ARM single-board computers (Raspberry Pi 4/5, Orange Pi 5, Rock 5B, etc.)
- **Renderer:** GLES3 (OpenGL ES 3.0) for ARM compatibility

### Development Philosophy

1. **Performance first** - This is a benchmark, every millisecond counts
2. **Document everything** - Successes AND failures
3. **Target real hardware** - Optimize for Raspberry Pi, not desktop
4. **Be honest** - If something doesn't work, say so
5. **Learn together** - We're all figuring this out

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [existing issues](../../issues) to see if it's already reported
- Read [COMPLETE_OPTIMIZATION_STORY.md](COMPLETE_OPTIMIZATION_STORY.md) to see if it's a known problem
- Try to reproduce it on both Raspberry Pi (if available) and desktop

**How to submit a good bug report:**

Use this template:

```markdown
## Bug Description
[Clear description of what's wrong]

## Environment
- Hardware: [Raspberry Pi 4/5, Desktop PC, etc.]
- OS: [Raspberry Pi OS, Ubuntu, Windows, etc.]
- Godot Version: [Should be 4.4-stable]
- Renderer: [GLES3, Vulkan, etc.]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [And so on...]

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What actually happened]

## Performance Data (if applicable)
- FPS: [Number]
- Frame time: [Milliseconds]
- Console output: [Any errors or warnings]

## Additional Context
[Screenshots, logs, profiling data, anything else helpful]
```

### Suggesting Features

**We love new ideas, but please consider:**

This is a **benchmark project** with a specific goal: testing Godot 4.4 performance on ARM hardware. Features should align with this goal.

**Good feature suggestions:**
- New benchmark scenes (physics, particles, lighting, etc.)
- Additional optimization techniques
- Better performance profiling
- Cross-platform improvements
- Build system enhancements

**Features we're probably NOT looking for:**
- Gameplay features (this isn't a game)
- UI polish (functional > pretty for a benchmark)
- Features that hurt performance (defeats the purpose)

**How to suggest a feature:**

```markdown
## Feature Description
[What feature do you want?]

## Why This Feature?
[How does it help benchmark ARM hardware?]

## Proposed Implementation
[How might this work? Be specific if you can]

## Alternatives Considered
[Any other approaches you thought about?]

## Additional Context
[Links, examples, research, etc.]
```

### Your First Code Contribution

**Unsure where to start? Look for issues labeled:**

- `good first issue` - Beginner-friendly tasks
- `help wanted` - We need assistance on these
- `documentation` - Improve our docs
- `optimization` - Performance improvements

**🔥 High-Priority Contributions:**

1. **Test on other ARM SBCs** - Orange Pi 5, Rock 5B, Jetson, etc. (verify our optimizations work elsewhere)
2. **Add additional benchmarks** - Physics stress test, particles, complex lighting
3. **Improve CLI functionality** - Better command-line benchmark automation
4. **Optimize for Raspberry Pi 4** - Nature Island targets RPi5, can we get similar performance on RPi4?
5. **Cross-platform testing** - Verify builds work on Windows/Linux desktop
6. **Performance profiling tools** - Better real-time metrics and bottleneck detection

**Never contributed to open source before?**

No problem! Check these resources:
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [First Timers Only](https://www.firsttimersonly.com/)
- [GitHub's Guide to Contributing](https://docs.github.com/en/get-started/quickstart/contributing-to-projects)

**Working on assets?** Read [ASSET_GUIDELINES.md](ASSET_GUIDELINES.md) for triangle budgets, approved sources, and how to test meshes before you submit them.

### Pull Requests

**Before submitting a pull request:**

1. **Fork the repository** and create your branch from `main`
2. **Test your changes** on both desktop and Raspberry Pi (if possible)
3. **Document what you changed** and why
4. **Update relevant documentation** (README, optimization guides, etc.)
5. **Run the benchmarks** to ensure you didn't break anything

**Pull request template:**

```markdown
## What Does This PR Do?
[Brief description]

## Why Is This Needed?
[Explain the problem or improvement]

## How Was This Tested?
- [ ] Tested on Desktop PC (Specs: [Your specs])
- [ ] Tested on Raspberry Pi 4/5 (if available)
- [ ] Model Showcase benchmark still works
- [ ] Nature Island benchmark still works
- [ ] No performance regressions introduced

## Performance Impact
- Before: [FPS/metrics]
- After: [FPS/metrics]
- Change: [+X% improvement / -X% regression / no change]

## Changes Made
- [List of changes]
- [Be specific]

## Screenshots/Logs (if applicable)
[Add any relevant output]

## Related Issues
Closes #[issue number]
```

**What happens after you submit a PR?**

- We'll review it as soon as possible (usually within a week)
- We may ask questions or request changes
- Once approved, we'll merge it
- You'll be credited in the project (forever!)

---

## Style Guides

### GDScript Style

Follow [Godot's official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

```gdscript
# Good
func calculate_triangle_count(mesh: ArrayMesh) -> int:
    var total = 0
    for i in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(i)
        if arrays and arrays[Mesh.ARRAY_INDEX]:
            total += arrays[Mesh.ARRAY_INDEX].size() / 3
    return total

# Bad
func CalculateTriangleCount(mesh):
    var Total=0
    for i in range(mesh.get_surface_count()):
        var Arrays=mesh.surface_get_arrays(i)
        if Arrays and Arrays[Mesh.ARRAY_INDEX]:Total+=Arrays[Mesh.ARRAY_INDEX].size()/3
    return Total
```

**Key points:**
- Use `snake_case` for variables and functions
- Use `PascalCase` for class names
- Add type hints whenever possible
- Comment complex logic
- Keep functions focused and small

### C++ Style

Follow [Godot's C++ style guide](https://docs.godotengine.org/en/stable/contributing/development/code_style_guidelines.html):

```cpp
// Good
int32_t PerformanceMonitor::get_triangle_count() const {
    return RenderingServer::get_singleton()->get_rendering_info(
        RenderingServer::RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME
    );
}

// Bad
int32_t PerformanceMonitor::GetTriangleCount()
{
    return RenderingServer::get_singleton()->get_rendering_info(RenderingServer::RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME);
}
```

### Commit Messages

Write clear, descriptive commit messages:

```
Good:
- "Fix Nature Island 4.5 FPS by removing shader complexity"
- "Add profiling to identify bottleneck in GLTF loading"
- "Update README with current benchmark status"

Bad:
- "fix bug"
- "update"
- "asdfasdf"
```

**Format:**
```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain the problem this commit solves and why you chose
this solution.

Fixes #123
```

### Documentation Style

- **Be clear** - Assume the reader knows less than you
- **Be honest** - Document failures as well as successes
- **Be specific** - "4.5 FPS on RPi 4" not "slow"
- **Be helpful** - Include examples, commands, screenshots

---

## Ground Rules

### Code of Conduct

**Be respectful.** We're all learning here.

- **Be welcoming** - Encourage new contributors
- **Be patient** - Not everyone knows Godot as well as you
- **Be constructive** - Criticism should include suggestions
- **Be honest** - If you don't know, say so
- **Be collaborative** - We're in this together

**Unacceptable behavior:**
- Harassment, insults, or derogatory comments
- Trolling or inflammatory posts
- Sharing others' private information
- Anything illegal or unethical

**If you experience or witness unacceptable behavior:**
- Report it via GitHub Issues (mark as private if needed)
- Contact project maintainers directly
- We will address it promptly and respectfully

### Technical Responsibilities

**When contributing code:**

- ✅ Test on Raspberry Pi 4/5 (if possible) or desktop
- ✅ Ensure cross-platform compatibility (Windows, Linux, ARM)
- ✅ Document performance impact
- ✅ Keep optimizations focused and measurable
- ✅ Don't break existing benchmarks without good reason
- ✅ Add comments explaining complex logic

**When contributing documentation:**

- ✅ Check spelling and grammar
- ✅ Be accurate (don't make up numbers)
- ✅ Update related docs (README, guides, etc.)
- ✅ Include examples and context

---

## Community

### Where to Ask Questions

- **GitHub Discussions** - General discussion, ideas, help
- **GitHub Issues** - Bugs, feature requests, specific problems
- **Godot Discord** - Real-time chat about Godot + GodotMark
- **Email** - (Add email if you want direct contact)

### Response Times

**Realistic expectations:**
- Issues: Acknowledged within 1 week
- Pull requests: Initial review within 1-2 weeks
- Questions: Answered within a few days

**Why might responses be slow?**
- This is a hobby project maintained by someone with a day job
- Raspberry Pi testing requires physical hardware and time
- Debugging 4.5 FPS is genuinely difficult

**Your patience is appreciated!**

---

## Recognition

### Contributors Will Be:

- 📝 Listed in project credits
- 🏆 Acknowledged in release notes
- 🎉 Celebrated in the community
- 💼 Able to list this on their resume/portfolio

**Your contribution, no matter how small, makes a difference.**

---

## Final Thoughts

### Why Your Contribution Matters

**ARM single-board computers are everywhere:**
- 60+ million Raspberry Pis sold (as of 2026)
- Used in education, embedded systems, IoT, robotics, AI edge computing
- $35-150 vs $1000+ gaming PCs
- Growing market for affordable computing

**And now we have a working 3D benchmark for them!** Your contribution helps:
- Prove what Godot can do on low-power hardware (we did it - 40-60+ FPS!)
- Help others optimize their ARM projects
- Make game development more accessible
- Solve real problems for the community
- Push the boundaries of what's possible on affordable hardware

### A Note About Success

**We solved the "impossible" 4.5 FPS problem.**

After systematic debugging, profiling, and optimization, Nature Island now runs at 40-60+ FPS on Raspberry Pi 5 with ALL features enabled (GPU shaders, wind animation, ocean waves, Jolt physics).

**This proves that complex 3D scenes CAN run well on ARM SBCs** - and your contributions can help push it even further.

### A Note About Struggling

If you're reading this and feeling overwhelmed by contributing to open source:

**You're not alone.** Every contributor starts somewhere.

**You don't need to be an expert.** Small fixes, documentation improvements, testing on different hardware - it all helps.

**Start small.** Fix a typo, ask a question, test on your hardware, suggest an idea.

**The hardest part is starting.** After that first contribution, the next one is easier.

**Success takes persistence.** Nature Island went from "broken at 4.5 FPS" to "fully working at 40-60+ FPS" through systematic debugging and refusing to give up. Your contribution could be the next breakthrough.

### Thank You

Whether you're here to add a new benchmark, optimize for different hardware, improve documentation, or just report a bug - **thank you for being here.**

This project exists because people care enough to contribute.

**We proved that complex 3D can run well on ARM SBCs. Now let's see how much further we can push it.** 🚀

---

*Last updated: March 14, 2026*

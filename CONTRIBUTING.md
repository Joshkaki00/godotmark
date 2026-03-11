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
- ✅ **Model Showcase benchmark** - Runs smoothly on Raspberry Pi 4/5
- ✅ **Build system** - SCons and CMake builds working
- ✅ **Optimization documentation** - Extensively documented

**What's Broken:**
- ❌ **Nature Island benchmark** - Stuck at 4.5 FPS on Raspberry Pi despite "correct" optimizations
- ❌ We don't know why yet - **this is the #1 priority**

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

1. **Debug Nature Island 4.5 FPS issue** - The most critical problem
2. **Profile and compare Model Showcase vs Nature Island** - Why does one work and not the other?
3. **Test on other ARM SBCs** - Orange Pi 5, Rock 5B, Jetson, etc.
4. **Improve GLTF import optimization** - Can we simplify meshes better?
5. **Add additional benchmarks** - Physics, particles, lighting tests

**Never contributed to open source before?**

No problem! Check these resources:
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [First Timers Only](https://www.firsttimersonly.com/)
- [GitHub's Guide to Contributing](https://docs.github.com/en/get-started/quickstart/contributing-to-projects)

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
- [ ] Nature Island benchmark [works/still broken/improved]

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
- 50+ million Raspberry Pis sold
- Used in education, embedded systems, IoT, robotics
- $35-150 vs $1000+ gaming PCs

**But there's no good 3D benchmark for them.** Your contribution helps:
- Prove what Godot can do on low-power hardware
- Help others optimize their ARM projects
- Make game development more accessible
- Solve a real problem for the community

### A Note About Struggling

If you're reading this and feeling overwhelmed by contributing to open source:

**You're not alone.** The project creator felt the same way a year ago.

**You don't need to be an expert.** Small fixes, documentation improvements, testing on different hardware - it all helps.

**Start small.** Fix a typo, ask a question, test on your hardware, suggest an idea.

**The hardest part is starting.** After that first contribution, the next one is easier.

### Thank You

Whether you're here to fix the 4.5 FPS issue, add a new benchmark, improve documentation, or just report a bug - **thank you for being here.**

This project exists because people care enough to contribute.

**Now let's build something useful together.** 🚀

---

## 🤖 Contributor Recognition Bots

We use several GitHub bots to make contributing more welcoming and rewarding:

### All-Contributors Bot ✨
Automatically recognizes **all types of contributions** to the project!

**How to use:**
1. After someone contributes (code, docs, ideas, bug reports, etc.)
2. Comment on the PR or issue: `@all-contributors please add @username for <contribution-type>`
3. The bot will automatically update the README with their contribution

**Example:**
```
@all-contributors please add @johndoe for code, docs, bug
```

**Contribution types:**
- `code` - Code contributions
- `doc` - Documentation
- `bug` - Bug reports
- `ideas` - Ideas & suggestions
- `test` - Testing
- `review` - Code reviews
- `infra` - Infrastructure
- `design` - Design
- `question` - Answering questions
- ...and [many more](https://allcontributors.org/docs/en/emoji-key)!

### Welcome Bot 👋
Automatically welcomes new contributors when they:
- Open their first issue
- Create their first pull request
- Get their first PR merged

You don't need to do anything - the bot handles it automatically!

### First Timers Bot 🎯
**For Maintainers:** Create beginner-friendly issues by:
1. Creating a branch that starts with `first-timers-`
2. The bot will automatically generate a detailed issue for newcomers
3. Perfect for simple fixes like typos, formatting, or minor improvements

**For Contributors:** Look for issues labeled `first-timers-only` - they're specifically designed to be easy for newcomers!

---

## Questions?

If you have questions about contributing, please:
1. Check this document again
2. Search existing issues
3. Ask in GitHub Discussions
4. Open a new issue with the `question` label

**We're here to help you help us!**

---

*Last updated: January 27, 2026*

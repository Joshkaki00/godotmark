# Good First Issues - Quick Guide

This guide helps you create and manage "Good First Issues" to attract contributors.

## 📋 What You Have

### Files Created:
1. **`ISSUES_TO_CREATE.md`** - 15 ready-to-copy issue templates
2. **`create_issues.sh`** - Bash script to auto-create all issues (Linux/Mac/Git Bash)
3. **`create_issues.ps1`** - PowerShell script (Windows - partial)

---

## 🚀 Quick Start

### Option 1: Use GitHub CLI (Recommended)

**Prerequisites:**
```bash
# Install GitHub CLI
# Visit: https://cli.github.com/

# Authenticate
gh auth login

# Navigate to your project
cd godotmark

# Run the script
bash .github/create_issues.sh
```

This will automatically:
- ✅ Create all necessary labels
- ✅ Create all 15 issues with proper labels
- ✅ Save you hours of manual work!

---

### Option 2: Manual Creation (Copy-Paste)

If you prefer manual control or don't want to use GitHub CLI:

1. **Go to:** `https://github.com/your-username/godotmark-project/issues`
2. **Click:** "New Issue"
3. **Open:** `.github/ISSUES_TO_CREATE.md`
4. **Copy-paste** each issue's content
5. **Add labels** as specified
6. **Click:** "Submit new issue"

**Repeat for all 15 issues.**

---

## 🏷️ Labels to Create First

Before creating issues, create these labels:

| Label | Color | Description |
|-------|-------|-------------|
| `good first issue` | #7057ff (purple) | Good for newcomers |
| `help wanted` | #008672 (teal) | Extra attention needed |
| `documentation` | #0075ca (blue) | Docs improvements |
| `UI` | #a2eeef (light blue) | User interface |
| `GDScript` | #fbca04 (yellow) | GDScript code |
| `C++` | #d73a4a (red) | C++ code |
| `testing needed` | #d93f0b (orange) | Hardware testing |
| `hardware: raspberry-pi-5` | #ededed (gray) | RPi 5 specific |
| `hardware: orange-pi` | #ededed (gray) | Orange Pi specific |
| `hardware: rock-5b` | #ededed (gray) | Rock 5B specific |
| `performance` | #d73a4a (red) | Performance related |
| `quality of life` | #0e8a16 (green) | UX improvements |
| `beginner friendly` | #0e8a16 (green) | Easy for beginners |
| `no code required` | #bfdadc (light teal) | No coding needed |

**How to create labels:**
1. Go to Issues → Labels → "New label"
2. Enter name, color, and description
3. Click "Create label"

---

## 📌 Which Issues to Pin?

Pin these 3 issues to make them highly visible:

### 1. Issue #5: Test Nature Island on Raspberry Pi 5
- **Why:** Most critical - need real hardware data
- **Priority:** URGENT

### 2. Issue #14: Compare Godot 4.4 vs 4.5 performance
- **Why:** Could reveal if it's a Godot regression
- **Priority:** HIGH

### 3. Issue #9: Test on Rock 5B
- **Why:** Expand hardware support
- **Priority:** MEDIUM

**How to pin:**
1. Open the issue
2. Click "⋯" (three dots) in top-right
3. Click "Pin issue"

---

## 📊 The 15 Issues at a Glance

### Super Easy (Perfect for first-timers):
1. ⭐ **#1:** Add FPS counter to Main Menu
2. ⭐ **#4:** Fix typos in README
3. ⭐ **#6:** Add keyboard shortcut display
4. ⭐ **#15:** Add platform badges to README

### Easy (Coding required):
5. ⭐ **#3:** Orange Pi temperature monitoring
6. ⭐ **#10:** Better error messages
7. ⭐ **#11:** Add --version flag

### Documentation (No coding):
8. ⭐ **#2:** Create troubleshooting guide
9. ⭐ **#7:** Document adding benchmarks
10. ⭐ **#12:** Video recording guide

### Testing (Hardware needed):
11. 🧪 **#5:** Test on Raspberry Pi 5 ⚠️ CRITICAL
12. 🧪 **#9:** Test on Rock 5B
13. 🧪 **#14:** Compare Godot 4.4 vs 4.5 ⚠️ HIGH PRIORITY

### Medium (More involved):
14. ⭐⭐ **#8:** Add progress indicator
15. ⭐⭐ **#13:** Benchmark results screen

---

## 💡 Best Practices

### When Someone Claims an Issue:

**Respond quickly:**
```markdown
Hi @contributor! 🎉

Thanks for your interest! This issue is now assigned to you.

**Next steps:**
1. Fork the repository
2. Create a branch: `git checkout -b fix-issue-5`
3. Make your changes
4. Test thoroughly
5. Create a Pull Request

Need help? Just ask here or in our [Contributing Guide](CONTRIBUTING.md)!

Good luck! 🚀
```

### When Someone Submits a PR:

**Be encouraging:**
```markdown
@contributor This looks great! 🎉

I'll review it thoroughly today. Thank you for contributing!
```

**If changes needed:**
```markdown
@contributor Thanks for this! Just a few small suggestions:

1. Could you add a test for...
2. The formatting here could be...

No worries - these are minor! Let me know if you need help.
```

### When PR is Merged:

**Celebrate!**
```markdown
🎊 MERGED! 🎊

@contributor Your first contribution is now part of GodotMark!

Don't forget to add yourself to contributors:
@all-contributors please add @contributor for code

Want to tackle another issue? Check out our "help wanted" label!

Thank you! 🙏
```

---

## 🎯 Attracting Contributors

### Share on Social Media:

**Twitter/X:**
```
🚀 GodotMark now has 15 "Good First Issues"!

Looking for:
🐛 Bug fixers
📝 Tech writers
🎨 UI designers
🧪 Testers with ARM hardware

No experience needed for some issues!

Check them out: [link to issues]

#Godot #OpenSource #GoodFirstIssue
```

**Reddit (r/godot, r/raspberry_pi, r/opensource):**
```
Title: [Help Wanted] 15 Beginner-Friendly Issues in GodotMark (3D Benchmark)

Body:
Hi! I'm building GodotMark - a 3D gaming benchmark for ARM single-board computers (Raspberry Pi, Orange Pi, etc.)

I just created 15 "Good First Issues" - some require NO coding at all!

Perfect if you:
- Want to learn Godot
- Love Raspberry Pi/ARM SBCs
- Want to contribute to open source
- Enjoy documentation/testing

[Link to repository]

All contributors get recognized via @all-contributors bot!
```

**Discord/Forums:**
- Post in Godot community servers
- Post in Raspberry Pi forums
- Post in open source communities

---

## 📈 Tracking Progress

### Create a Project Board (Optional):

If issues start getting traction, create a GitHub Project:

**Columns:**
```
📋 To Do          → Issues that need work
🚧 In Progress    → Someone is working on it
👀 Review         → PR submitted, needs review
✅ Done           → Merged!
```

**How to set up:**
1. Go to Projects tab
2. Click "New project"
3. Choose "Board" template
4. Link issues to project

---

## 🎉 Celebrating Contributors

### When someone's first PR merges:

1. **Use All-Contributors bot:**
   ```
   @all-contributors please add @username for code
   ```

2. **Thank them publicly:**
   - Comment on PR
   - Mention in release notes
   - Tweet/share about it

3. **Invite them to tackle more:**
   - Suggest related issues
   - Ask if they want to be assigned something
   - Make them feel part of the team!

---

## 🔄 Maintaining Issues

### Weekly:
- [ ] Check for new comments on issues
- [ ] Respond to questions within 24 hours
- [ ] Update issue descriptions if needed
- [ ] Close stale issues (no activity for 30 days)

### Monthly:
- [ ] Review which issues are getting attention
- [ ] Create new "Good First Issues" as needed
- [ ] Update difficulty ratings based on feedback
- [ ] Thank active contributors publicly

---

## 📞 When Contributors Need Help

**Common Questions:**

**Q: "I'm new to open source, where do I start?"**
```markdown
Great question! Start here:

1. Read our [Contributing Guide](CONTRIBUTING.md)
2. Pick an issue labeled "beginner friendly"
3. Comment "I'd like to work on this!"
4. Fork the repo and create a branch
5. Make your changes
6. Submit a Pull Request

We're here to help at every step! 🙌
```

**Q: "I don't have a Raspberry Pi, can I still contribute?"**
```markdown
Absolutely! These issues don't require hardware:
- Issue #2: Troubleshooting guide
- Issue #4: Fix typos
- Issue #7: Document benchmark creation
- Issue #12: Video recording guide

Or test on your PC - we need that data too!
```

**Q: "I've never used Godot before"**
```markdown
Perfect time to learn! These issues are great for beginners:
- Issue #1: FPS counter (simple GDScript)
- Issue #6: Keyboard shortcuts (UI editing)
- Issue #15: Platform badges (just Markdown!)

Godot docs: https://docs.godotengine.org/
We're here to answer questions! 😊
```

---

## 🎯 Success Metrics

Track these to measure success:

- **Issue engagement:** Comments, reactions, assignments
- **PR submissions:** How many PRs from issues?
- **Contributor retention:** Do people come back?
- **Community growth:** GitHub stars, forks, watchers
- **Hardware coverage:** How many platforms tested?

**Goal for Month 1:**
- ✅ 5+ new contributors
- ✅ 10+ issues closed
- ✅ 3+ hardware platforms tested
- ✅ 100+ GitHub stars

---

## 🚀 Next Steps After Issues Are Created

1. **Announce on social media** (Twitter, Reddit, Discord)
2. **Add to README:** Link to "good first issue" label
3. **Monitor daily:** Respond to comments within 24 hours
4. **Be welcoming:** Every contributor was a beginner once!
5. **Iterate:** Create more issues as these get completed

---

## 📚 Resources

- [GitHub's Guide to Good First Issues](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/encouraging-helpful-contributions-to-your-project-with-labels)
- [How to Write a Perfect Good First Issue](https://kentcdodds.com/blog/first-timers-only)
- [The Art of the First Issue](https://www.freecodecamp.org/news/how-to-make-your-first-contribution-to-open-source/)

---

**Good luck attracting contributors! 🎉**

Remember: Every expert was once a beginner. Your job is to make that first contribution as smooth and rewarding as possible!

**Questions?** Open an issue or discussion on GitHub!

---

*Created: January 27, 2026*

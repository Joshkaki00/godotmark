# GitHub Bots Setup & Usage Guide

This document explains how to set up and use the three GitHub bots configured for GodotMark.

## 📋 Table of Contents

- [All-Contributors Bot](#all-contributors-bot-)
- [Welcome Bot](#welcome-bot-)
- [First Timers Bot](#first-timers-bot-)
- [Installation Steps](#installation-steps)
- [Troubleshooting](#troubleshooting)

---

## All-Contributors Bot ✨

**Purpose:** Automatically recognizes all types of contributions to your project.

### Features
- Recognizes 20+ contribution types (code, docs, bugs, ideas, design, etc.)
- Automatically updates README with contributor gallery
- Creates pull requests with contributor additions
- Works via comment commands

### How to Use

**Basic Command:**
```
@all-contributors please add @username for <contribution-type>
```

**Examples:**

Add a code contributor:
```
@all-contributors please add @johndoe for code
```

Add multiple contribution types:
```
@all-contributors please add @janedoe for code, docs, test, review
```

Add a bug reporter:
```
@all-contributors please add @bugfinder for bug
```

Add someone who helped with ideas:
```
@all-contributors please add @thinker for ideas
```

### All Contribution Types

| Emoji | Type | Description |
|-------|------|-------------|
| 💻 | `code` | Code contributions |
| 📖 | `doc` | Documentation |
| 🐛 | `bug` | Bug reports |
| 🤔 | `ideas` | Ideas & Planning |
| 🎨 | `design` | Design |
| 👀 | `review` | Reviewing Pull Requests |
| ⚠️ | `test` | Writing Tests |
| 🚇 | `infra` | Infrastructure (CI/CD, builds) |
| 💬 | `question` | Answering Questions |
| 🌍 | `translation` | Translation |
| 📹 | `video` | Videos |
| 📢 | `talk` | Talks |
| 🔌 | `plugin` | Plugin/utility libraries |
| 🔧 | `tool` | Tools |
| 📝 | `blog` | Blogposts |
| 💡 | `example` | Examples |
| 🚧 | `maintenance` | Maintenance |
| 📆 | `eventOrganizing` | Event Organizing |
| 💵 | `financial` | Financial Support |
| 🔍 | `fundingFinding` | Funding Finding |
| 🖋 | `content` | Content (blog posts, podcasts) |

**Full list:** https://allcontributors.org/docs/en/emoji-key

### Configuration

The bot is configured via `.all-contributorsrc`:

```json
{
  "projectName": "GodotMark",
  "projectOwner": "mehewz",
  "repoType": "github",
  "files": ["README.md"],
  "contributorsPerLine": 7,
  "commit": true,
  "commitConvention": "angular",
  "skipCi": true
}
```

**Key settings:**
- `files: ["README.md"]` - Where contributors are added
- `contributorsPerLine: 7` - Number of avatars per row
- `commit: true` - Bot creates commits automatically
- `skipCi: true` - Doesn't trigger CI on contributor updates

### When to Use

**Always recognize:**
- ✅ Code contributions (PRs merged)
- ✅ Good bug reports (with reproduction steps)
- ✅ Documentation improvements
- ✅ Helping answer questions in issues
- ✅ Reviewing PRs
- ✅ Testing on different hardware
- ✅ Design suggestions
- ✅ Ideas that get implemented

**Examples from real scenarios:**

Someone fixes a typo:
```
@all-contributors please add @typoFixer for doc
```

Someone reports a critical bug with full details:
```
@all-contributors please add @bugReporter for bug
```

Someone suggests a great optimization idea:
```
@all-contributors please add @ideaPerson for ideas
```

Someone tests on Raspberry Pi and reports results:
```
@all-contributors please add @tester for test
```

Someone reviews multiple PRs thoroughly:
```
@all-contributors please add @reviewer for review
```

---

## Welcome Bot 👋

**Purpose:** Automatically welcomes new contributors and celebrates milestones.

### Features
- Welcomes first-time issue creators
- Welcomes first-time PR creators  
- Celebrates first merged PR
- Fully automatic (no commands needed)

### What It Does

**When someone opens their first issue:**
```
👋 Hey there, thanks for opening your first issue in GodotMark!

We're a small team trying to build something meaningful...
[custom welcome message]
```

**When someone opens their first PR:**
```
🎉 Woah, your first pull request to GodotMark! This is awesome! 🎉

Thank you so much for taking the time to contribute...
[custom welcome message]
```

**When someone's first PR gets merged:**
```
🎊 CONGRATULATIONS! Your first contribution has been merged! 🎊

[celebration GIF]

You're officially a GodotMark contributor now! 🏆
[custom celebration message]
```

### Configuration

The bot is configured via `.github/config.yml`:

```yaml
# Configuration for Welcome Bot
newIssueWelcomeComment: >
  [Custom welcome message for new issue creators]

newPRWelcomeComment: >
  [Custom welcome message for new PR creators]

firstPRMergeComment: >
  [Custom celebration message for first merged PR]
```

### Customizing Messages

To update welcome messages, edit `.github/config.yml`:

1. Keep messages warm and encouraging
2. Include next steps
3. Link to CONTRIBUTING.md
4. Be specific about what makes this project special
5. Add relevant emojis/GIFs to celebrate

### Best Practices

**Do:**
- ✅ Be genuinely welcoming and encouraging
- ✅ Explain what happens next
- ✅ Link to relevant documentation
- ✅ Show enthusiasm (emojis, GIFs)
- ✅ Make contributors feel valued

**Don't:**
- ❌ Use generic corporate language
- ❌ Make it too long (keep it skimmable)
- ❌ Forget to update when project changes
- ❌ Be condescending or overly formal

---

## First Timers Bot 🎯

**Purpose:** Automatically creates beginner-friendly issues from simple code changes.

### Features
- Converts simple changes into detailed issues
- Perfect for onboarding new contributors
- Automatically labels as `first-timers-only`
- Creates step-by-step instructions

### How to Use

**For Maintainers:**

1. Find a simple fix (typo, formatting, simple refactor)
2. Create a branch starting with `first-timers-`
3. Make the change in that branch
4. Push the branch
5. The bot will automatically:
   - Create a detailed issue
   - Add `first-timers-only` label
   - Include step-by-step instructions
   - Link to the branch with the fix

**Example:**

```bash
# Found a typo in README
git checkout -b first-timers-fix-readme-typo
# Make the change
echo "Fixed typo: 'teh' -> 'the'" >> README.md
git commit -am "Fix typo in README"
git push origin first-timers-fix-readme-typo
```

Bot creates an issue:
```
Title: Fix typo in README (first-timers-only)

This issue has been created for first-time contributors!

**What needs to be done:**
Fix a typo in README.md: change "teh" to "the"

**Step-by-step instructions:**
1. Comment on this issue to claim it
2. Fork the repository
3. Create a new branch: `git checkout -b fix-readme-typo`
4. Make the change shown below
5. Commit: `git commit -am "Fix typo in README"`
6. Push and create a Pull Request

**The change needed:**
[Shows exact diff]

Labels: first-timers-only, documentation
```

### What Makes Good First-Timers Issues

**Perfect for beginners:**
- ✅ Typo fixes
- ✅ Adding comments to code
- ✅ Formatting improvements
- ✅ Updating documentation
- ✅ Adding missing docstrings
- ✅ Simple refactoring (renaming variables)
- ✅ Adding test cases for existing code

**Not suitable:**
- ❌ Complex logic changes
- ❌ Architecture changes
- ❌ Performance optimizations
- ❌ Anything requiring deep domain knowledge
- ❌ Security-sensitive changes

### Tips for Creating Good First-Timers Issues

1. **Keep it simple** - One small, clear change
2. **Be specific** - Exact file, line number, what to change
3. **Explain why** - Help them understand the purpose
4. **Link to docs** - Contributing guide, code of conduct
5. **Be available** - Monitor the issue, answer questions quickly

---

## Installation Steps

### Prerequisites
- Repository must be public (or have GitHub Apps enabled for private repos)
- You must be a repository admin/owner

### 1. Install All-Contributors Bot

1. Go to https://github.com/apps/allcontributors
2. Click "Install"
3. Select "Only select repositories" and choose your repo
4. Approve permissions
5. Bot is now active!

**Verify installation:**
- Create a test issue
- Comment: `@all-contributors please add @your-username for doc`
- Bot should respond and create a PR

### 2. Install Welcome Bot

1. Go to https://github.com/apps/welcome
2. Click "Install"
3. Select your repository
4. Approve permissions
5. Bot is now active!

**Verify installation:**
- Create a test issue from a new account
- Check if welcome message appears
- (Or wait for first real new contributor)

### 3. Install First Timers Bot

1. Go to https://github.com/apps/first-timers
2. Click "Install"
3. Select your repository
4. Approve permissions
5. Bot is now active!

**Verify installation:**
- Create a branch: `first-timers-test`
- Make a simple change
- Push the branch
- Check if an issue was created automatically

---

## Troubleshooting

### All-Contributors Bot Not Responding

**Problem:** Bot doesn't respond to `@all-contributors` commands

**Solutions:**
1. Check if bot is installed: https://github.com/apps/allcontributors/installations
2. Verify you're using correct syntax: `@all-contributors please add @username for type`
3. Check bot has write permissions to your repo
4. Look for bot response in notifications (might be a PR instead of comment)
5. Check `.all-contributorsrc` file exists and is valid JSON

### Welcome Bot Not Posting

**Problem:** No welcome messages appearing

**Solutions:**
1. Check if bot is installed: https://github.com/apps/welcome/installations
2. Verify `.github/config.yml` exists and has correct YAML syntax
3. Test with a truly new contributor (bot won't welcome someone who already contributed)
4. Check repository settings: Settings → Features → Issues/PRs must be enabled
5. Messages might be delayed (wait a few minutes)

### First Timers Bot Not Creating Issues

**Problem:** No issues created from `first-timers-*` branches

**Solutions:**
1. Check if bot is installed: https://github.com/apps/first-timers/installations
2. Branch MUST start with `first-timers-` (case-sensitive)
3. Change must be simple (single file, small change)
4. Bot needs issues enabled on repository
5. Check bot permissions include "Issues: Write"

### General Debugging

**Check bot permissions:**
1. Go to repo Settings
2. Go to "Integrations" → "GitHub Apps"
3. Find the bot
4. Click "Configure"
5. Verify permissions are correct

**Check bot status:**
- Visit bot's GitHub App page
- Check for status/downtime notices
- Look at bot's repo for known issues

**Test in a sandbox:**
- Create a test repository
- Install bots there first
- Verify they work before deploying to main repo

---

## Best Practices

### For All Bots

1. **Monitor regularly** - Check bot responses weekly
2. **Customize messages** - Make them personal to your project
3. **Keep config updated** - When project changes, update bot messages
4. **Be responsive** - When bot welcomes someone, follow up personally
5. **Use consistently** - Always recognize contributions, not just sometimes

### For Growing Your Community

1. **Combine bots with human touch** - Bots welcome, you engage deeply
2. **Recognize all contribution types** - Not just code (use all-contributors for this!)
3. **Create first-timers issues regularly** - Always have easy entry points
4. **Celebrate publicly** - When someone contributes, make it visible
5. **Thank contributors** - Beyond bots, personal thanks go far

---

## References

- [All-Contributors Documentation](https://allcontributors.org/docs/en/overview)
- [All-Contributors GitHub App](https://github.com/all-contributors/app)
- [Welcome Bot Documentation](https://probot.github.io/apps/welcome/)
- [First Timers Bot Documentation](https://probot.github.io/apps/first-timers/)
- [Probot Framework](https://probot.github.io/)

---

*Last updated: January 27, 2026*

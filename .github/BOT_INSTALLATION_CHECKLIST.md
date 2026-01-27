# Bot Installation Checklist

Quick checklist for installing the three GitHub bots configured for GodotMark.

## ✅ Pre-Installation

- [ ] Repository is public (or has GitHub Apps enabled)
- [ ] You have admin/owner access to the repository
- [ ] Configuration files are committed:
  - [ ] `.all-contributorsrc`
  - [ ] `.github/config.yml`
  - [ ] `.github/BOT_SETUP.md`

## 🤖 All-Contributors Bot

- [ ] Visit https://github.com/apps/allcontributors
- [ ] Click "Install" or "Configure"
- [ ] Select your repository: `mehewz/GodotMark`
- [ ] Approve permissions (Read: metadata, Write: contents, issues, pull requests)
- [ ] **Test:** Comment `@all-contributors please add @your-username for doc` on any issue
- [ ] Verify bot responds and creates a PR

**Expected result:** Bot creates a PR adding you to README contributors section.

---

## 👋 Welcome Bot

- [ ] Visit https://github.com/apps/welcome
- [ ] Click "Install" or "Configure"
- [ ] Select your repository: `mehewz/GodotMark`
- [ ] Approve permissions (Read: metadata, Write: issues, pull requests)
- [ ] **Test:** Wait for first new contributor OR create test account
- [ ] Verify welcome message appears on first issue/PR

**Expected result:** Bot posts welcome message when new contributor opens issue/PR.

---

## 🎯 First Timers Bot

- [ ] Visit https://github.com/apps/first-timers
- [ ] Click "Install" or "Configure"
- [ ] Select your repository: `mehewz/GodotMark`
- [ ] Approve permissions (Read: metadata, Write: contents, issues)
- [ ] **Test:** Create branch `first-timers-test`, make simple change, push
- [ ] Verify bot creates a `first-timers-only` issue

**Expected result:** Bot creates detailed beginner-friendly issue with step-by-step instructions.

---

## 🔍 Verification Steps

After installing all three bots:

### 1. Check Installations
- [ ] Go to your GitHub profile → Settings → Applications → Installed GitHub Apps
- [ ] Verify all three bots are listed:
  - All Contributors
  - Welcome
  - First Timers

### 2. Check Repository Settings
- [ ] Go to repository Settings → Integrations → GitHub Apps
- [ ] Verify all three bots are installed
- [ ] Click "Configure" for each and verify permissions

### 3. Test All-Contributors Bot
```bash
# Create a test issue
gh issue create --title "Test All-Contributors Bot" --body "Testing bot installation"

# Comment on the issue
gh issue comment <issue-number> --body "@all-contributors please add @your-username for doc"

# Wait 30 seconds

# Check for bot response
gh issue view <issue-number>

# Check for PR created by bot
gh pr list --author "allcontributors[bot]"
```

**Expected:** Bot creates PR adding you to README.

### 4. Test Welcome Bot
**Option A: New Contributor**
- Ask a friend to open an issue/PR from their account
- Check if welcome message appears

**Option B: Manual Verification**
- Check `.github/config.yml` exists
- File has valid YAML syntax
- Contains `newIssueWelcomeComment`, `newPRWelcomeComment`, `firstPRMergeComment`
- Bot is installed

**Expected:** Bot posts welcome message on new contributor's first issue/PR.

### 5. Test First Timers Bot
```bash
# Create a first-timers branch
git checkout -b first-timers-fix-typo-in-readme

# Make a simple change
echo "# Fixed typo test" >> README.md

# Commit and push
git add README.md
git commit -m "Test: Fix typo for first-timers bot"
git push origin first-timers-fix-typo-in-readme

# Wait 1-2 minutes

# Check for created issue
gh issue list --label "first-timers-only"
```

**Expected:** Bot creates issue with `first-timers-only` label containing step-by-step instructions.

---

## 🐛 Troubleshooting

### All-Contributors Bot Not Working
- Check you used `@all-contributors` (not `@allcontributors`)
- Syntax: `@all-contributors please add @username for type`
- Bot needs write access to repository
- Check notifications for bot's response
- Verify `.all-contributorsrc` is valid JSON

### Welcome Bot Not Working
- Bot only welcomes truly NEW contributors
- Must be their FIRST issue/PR ever in this repo
- Check `.github/config.yml` has correct YAML syntax
- Issues/PRs must be enabled in repository settings
- Messages can be delayed by 1-2 minutes

### First Timers Bot Not Working
- Branch MUST start with `first-timers-` (case-sensitive, plural)
- Change should be simple (single file, small change)
- Bot needs issues enabled
- Check bot has "Issues: Write" permission
- Can take 1-2 minutes to create issue

---

## 📝 Post-Installation Tasks

After successful installation:

- [ ] Update README to mention bot usage (already done!)
- [ ] Update CONTRIBUTING.md with bot instructions (already done!)
- [ ] Create 2-3 `first-timers-` branches for easy starter issues
- [ ] Add "good first issue" and "help wanted" labels to repository
- [ ] Announce bot availability in project discussions/social media
- [ ] Train team members on how to use `@all-contributors` command
- [ ] Set calendar reminder to check bot health monthly

---

## 🎯 Usage Examples

### Recognizing Different Contributions

**Someone fixes a bug:**
```
@all-contributors please add @bugfixer for bug, code
```

**Someone improves documentation:**
```
@all-contributors please add @docwriter for doc
```

**Someone suggests a great idea:**
```
@all-contributors please add @thinker for ideas
```

**Someone tests on Raspberry Pi:**
```
@all-contributors please add @tester for test
```

**Someone reviews PRs thoroughly:**
```
@all-contributors please add @reviewer for review
```

**Multiple contributions:**
```
@all-contributors please add @supercontributor for code, doc, review, test
```

---

## 📚 Additional Resources

- [Bot Setup Guide](.github/BOT_SETUP.md) - Comprehensive documentation
- [All-Contributors Emoji Key](https://allcontributors.org/docs/en/emoji-key) - All contribution types
- [Welcome Bot Examples](https://probot.github.io/apps/welcome/) - Message customization ideas
- [First Timers Bot Guide](https://probot.github.io/apps/first-timers/) - Creating good first issues

---

## ✅ Installation Complete!

Once all checkboxes are checked:

🎉 **All three bots are now active!**

Your repository is now:
- ✅ Welcoming to new contributors (Welcome Bot)
- ✅ Recognizing all types of contributions (All-Contributors Bot)
- ✅ Creating easy entry points for beginners (First Timers Bot)

**Next steps:**
1. Create 2-3 `first-timers-` branches with simple fixes
2. Wait for first contributor and watch the magic happen!
3. Remember to recognize contributors with `@all-contributors`
4. Keep config files updated as project evolves

---

*Installation Date: _________*  
*Installed By: _________*  
*Last Verified: _________*

# GitHub Actions Security Documentation

This document explains the security measures in place for GodotMark's GitHub Actions workflows.

## Security Philosophy

**Balance:** Make contributing easy while preventing malicious actions.

**Approach:**
1. **Trust but verify** - First-time contributors require approval
2. **Minimal permissions** - Workflows only get what they need
3. **Monitor everything** - Harden-Runner tracks network activity
4. **Pin dependencies** - Actions pinned to commit SHAs
5. **Defense in depth** - Multiple layers of security

## Workflow Security Features

### 1. Minimal Token Permissions

```yaml
permissions:
  contents: read       # Can read repository code
  pull-requests: read  # Can read PR information
  # NO write permissions unless explicitly needed
```

**Why:** Default permissions are read-only. Write permissions granted only for specific jobs that need them.

**Reference:** [GitHub's security hardening guide](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)

### 2. Action Pinning to Commit SHAs

```yaml
# ❌ BAD - Tags can be replaced
uses: actions/checkout@v4

# ✅ GOOD - Pinned to immutable commit
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

**Why:** Git tags can be moved to point to malicious code. Commit SHAs cannot be changed.

**How to find SHAs:**
```bash
# Look up the commit SHA for a release
git ls-remote --tags https://github.com/actions/checkout
```

**Reference:** [GitGuardian security cheat sheet](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)

### 3. StepSecurity Harden-Runner

```yaml
- name: Harden Runner
  uses: step-security/harden-runner@17d0e2bd7d51742c71671bd19fa12bdc9d40a3d6 # v2.8.1
  with:
    egress-policy: audit
```

**What it does:**
- Monitors outbound network connections
- Detects unusual file access patterns
- Tracks process execution
- Creates baseline of normal behavior
- Alerts on anomalies

**Why:** Prevents credential exfiltration, detects malware, spots supply chain attacks.

**Dashboard:** https://app.stepsecurity.io/github/{org}/{repo}/actions/runs/{run_id}

**Reference:** [Harden-Runner documentation](https://docs.stepsecurity.io/harden-runner)

### 4. Pull Request Trigger (Not pull_request_target)

```yaml
on:
  pull_request:  # ✅ Safe - runs with PR's permissions
    branches: [main]

  # pull_request_target:  # ❌ Dangerous - runs with repo's permissions
```

**Why:**
- `pull_request` runs code from PR with limited permissions
- `pull_request_target` runs with write access (dangerous for external PRs)

**When to use pull_request_target:**
- Never for external contributions
- Only for internal workflows that need write access
- Must be carefully reviewed

**Reference:** [GitHub pull request security](https://docs.github.com/en/actions/managing-workflow-runs/approving-workflow-runs-from-public-forks)

### 5. Dependency Review Action

```yaml
- name: Dependency Review
  uses: actions/dependency-review-action@5bbc3ba658137598168acb2ab73b21c432dd411b # v4.2.5
```

**What it checks:**
- New dependencies added in PR
- Known vulnerabilities in dependencies
- License compatibility issues
- Dependency version changes

**Why:** Catches vulnerable dependencies before they're merged.

**Reference:** [About dependency review](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)

### 6. Secret Scanning (TruffleHog)

```yaml
- name: Check for secrets in code
  uses: trufflesecurity/trufflehog@4c56c9ea0346f5f21ea49699c87d98f33c3b8c06 # v3.63.2
```

**What it detects:**
- API keys
- Passwords
- Private keys
- Access tokens
- Database credentials

**Why:** Prevents accidental secret commits.

**Reference:** [TruffleHog documentation](https://github.com/trufflesecurity/trufflehog)

### 7. First-Time Contributor Approval

**Repository Setting:** "Require approval for first-time contributors"

**What happens:**
1. First-time contributor opens PR
2. Workflows don't run automatically
3. Maintainer reviews code
4. Maintainer clicks "Approve and run workflows"
5. Workflows execute

**Why:** Prevents malicious actors from executing code on our runners.

**How to approve:**
1. Review the PR code carefully
2. Check for suspicious changes
3. Go to "Checks" tab
4. Click "Approve and run workflows"

**Reference:** [Managing GitHub Actions settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)

## Security Checks in Our Workflows

### pr-check.yml

**Jobs:**

1. **security-check**
   - Scans for secrets with TruffleHog
   - Reviews dependencies for vulnerabilities
   - Checks file structure for suspicious files
   - Validates GDScript for dangerous patterns
   - Flags large files

2. **gdscript-lint**
   - Runs gdlint for style issues
   - Non-blocking (suggestions only)

3. **documentation-check**
   - Checks if docs were updated with code
   - Non-blocking (reminder only)

4. **pr-comment**
   - Welcomes first-time contributors
   - Links to contribution guidelines
   - Only runs for first-time contributors

**Permissions:** Read-only except pr-comment (needs write for commenting)

## Attack Vectors We Protect Against

### 1. Malicious Pull Requests

**Attack:** Contributor submits PR with malicious code in workflow

**Protection:**
- First-time contributors require approval
- Workflows use `pull_request` trigger (limited permissions)
- Actions pinned to commit SHAs
- Harden-Runner monitors execution

### 2. Dependency Poisoning

**Attack:** Vulnerable or malicious dependency added to project

**Protection:**
- Dependency review action blocks vulnerable deps
- Dependabot alerts on known vulnerabilities
- Manual review required before merge

### 3. Credential Exfiltration

**Attack:** Workflow modified to steal GITHUB_TOKEN or secrets

**Protection:**
- Minimal token permissions (read-only default)
- Harden-Runner monitors network egress
- TruffleHog scans for hardcoded secrets
- No self-hosted runners for public PRs

### 4. Tag Replacement Attacks

**Attack:** Attacker replaces action tag with malicious code

**Protection:**
- All actions pinned to immutable commit SHAs
- Dependabot updates pins when vulnerabilities found

### 5. Supply Chain Attacks

**Attack:** Compromised action or dependency

**Protection:**
- Use well-known, audited actions only
- Monitor with Harden-Runner
- Review dependency changes manually
- GitHub Advisory Database integration

## Maintaining Workflow Security

### Regular Updates

**Dependabot handles:**
- Action version updates (via commit SHAs)
- Dependency vulnerability patches
- Opens PRs automatically

**Manual review needed:**
- Breaking changes in action updates
- New security features to enable
- Workflow logic changes

### Monitoring

**Check regularly:**
- Harden-Runner dashboard for anomalies
- Dependabot alerts for vulnerabilities
- Failed security checks in PRs
- Suspicious contributor activity

**Where to look:**
- Repository "Security" tab
- Repository "Insights" → "Dependency graph"
- StepSecurity dashboard (when workflows run)
- GitHub audit log

### Incident Response

**If malicious PR detected:**

1. **Don't approve workflow** - Leave it pending
2. **Comment on PR** - Ask for explanation
3. **Close PR if confirmed malicious** - Block user if needed
4. **Report to GitHub** - Use "Report abuse" feature
5. **Review other PRs from user** - Check for similar issues

**If action compromised:**

1. **Pin to last known good commit** - Update workflow immediately
2. **Check Harden-Runner logs** - See what action tried to do
3. **Report to action maintainer** - Via security advisory
4. **Consider alternatives** - Switch to different action if needed

## References & Resources

### Official Documentation
- [GitHub Actions security hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
- [Approving workflow runs from forks](https://docs.github.com/en/actions/managing-workflow-runs/approving-workflow-runs-from-public-forks)
- [Managing GitHub Actions settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)

### Security Guides
- [GitGuardian security cheat sheet](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)
- [StepSecurity best practices](https://www.stepsecurity.io/blog/github-actions-security-best-practices)
- [GitHub Blog: Four tips to keep workflows secure](https://github.blog/security/supply-chain-security/four-tips-to-keep-your-github-actions-workflows-secure/)
- [OpenSSF mitigating attack vectors](https://openssf.org/blog/2024/08/12/mitigating-attack-vectors-in-github-workflows/)

### Tools
- [StepSecurity Harden-Runner](https://github.com/step-security/harden-runner)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [Dependency Review Action](https://github.com/actions/dependency-review-action)
- [GitHub Advisory Database](https://github.com/advisories)

## Questions?

- **Security concerns:** See [SECURITY.md](../../SECURITY.md)
- **General questions:** See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Workflow issues:** Open an issue with `workflow` label

---

**Last updated:** January 26, 2026

**This is a living document.** As we learn more about security, we'll update these practices.

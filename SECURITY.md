# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via:

1. **GitHub Security Advisories** (preferred)
   - Go to the [Security tab](../../security/advisories)
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email** (if you prefer)
   - **Email:** [godotmarkinquiries@gmail.com](mailto:godotmarkinquiries@gmail.com)
   - Subject: "[SECURITY] GodotMark vulnerability report"

### What to include in your report

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

### What to expect

- **Acknowledgment:** Within 3 business days
- **Updates:** We'll keep you informed of progress
- **Disclosure:** We'll work with you on responsible disclosure
- **Credit:** You'll be credited for the discovery (unless you prefer anonymity)

## Security Best Practices for Contributors

### When Submitting Code

✅ **DO:**
- Review [CONTRIBUTING.md](godotmark/CONTRIBUTING.md) for guidelines
- Pin action versions to commit SHAs in workflows
- Use minimal permissions in workflows
- Test on Raspberry Pi hardware when possible
- Document security implications of changes

❌ **DON'T:**
- Include secrets, API keys, or credentials in code
- Add binaries without explanation
- Use `eval()` or similar dangerous functions
- Bypass security checks in workflows
- Add dependencies without security review

### GitHub Actions Security

Our workflows follow security best practices from:
- [GitHub's security hardening guide](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
- [GitGuardian's security cheat sheet](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)
- [StepSecurity's best practices](https://www.stepsecurity.io/blog/github-actions-security-best-practices)

**Key security measures:**
- Actions pinned to commit SHAs (not tags)
- Minimal GITHUB_TOKEN permissions
- Harden-Runner for network monitoring
- Dependency review for all PRs
- Secret scanning enabled
- First-time contributor approval required

### For Maintainers

**Before merging a PR:**
- [ ] Review automated security checks
- [ ] Verify action pins are full commit SHAs
- [ ] Check for secrets or credentials
- [ ] Review dependency changes
- [ ] Test on actual hardware if code changes
- [ ] Verify documentation is updated

**Repository security settings:**
- Dependabot enabled for security updates
- Branch protection on `main`
- Required status checks before merge
- Require PR reviews
- Dismiss stale reviews when new commits

## Security Features

### Automated Scanning

- **Dependabot:** Monitors dependencies for vulnerabilities
- **Secret scanning:** Detects committed secrets
- **Dependency review:** Reviews dependency changes in PRs
- **TruffleHog:** Scans for credentials in code
- **Harden-Runner:** Monitors workflow network activity

### Manual Review

First-time contributors require manual approval before workflows run. This prevents:
- Malicious code execution on our runners
- Credential theft via modified workflows
- Resource abuse (crypto mining, etc.)
- Supply chain attacks

## Known Security Considerations

### Self-Hosted Runners

⚠️ **We do NOT use self-hosted runners for public PRs**

Self-hosted runners would expose infrastructure to untrusted code. All CI/CD uses GitHub-hosted runners.

### Raspberry Pi Testing

Testing on Raspberry Pi hardware happens **manually after approval**, not automatically in CI. This prevents:
- Exposure of physical hardware to untrusted code
- Network attacks on local infrastructure
- Resource exhaustion on limited hardware

### GLTF Asset Loading

Loading GLTF files is inherently complex and could have vulnerabilities:
- We validate GLTF structure before loading
- We don't auto-execute scripts in assets
- We limit texture sizes to prevent memory exhaustion
- We use Godot's built-in import system (trusted code path)

## Security Update Process

### For Dependencies

1. Dependabot opens PR with vulnerability fix
2. Automated tests run
3. Manual review by maintainer
4. Merge and release if tests pass

### For Project Code

1. Security advisory created (private)
2. Patch developed in temporary private fork
3. Tests run on patch
4. Advisory published with patch
5. Users notified via GitHub releases

## Vulnerability Disclosure Policy

We follow **coordinated disclosure**:

1. **Report received** → acknowledged within 3 days
2. **Validation** → confirm vulnerability exists
3. **Fix developed** → in private, with reporter collaboration
4. **Testing** → verify fix works and doesn't break things
5. **Release** → publish fix
6. **Disclosure** → publish advisory 7 days after fix release

**Timeline:** We aim to fix critical vulnerabilities within 30 days.

## Security Hall of Fame

Contributors who responsibly disclose security issues:

- *(No vulnerabilities reported yet)*

Thank you to all researchers who help keep GodotMark secure!

## Questions?

- Security questions: See above for reporting methods
- General questions: [CONTRIBUTING.md](godotmark/CONTRIBUTING.md)
- Discussion: [GitHub Discussions](../../discussions)

---

**Last updated:** January 26, 2026

**References:**
- [GitHub Security Best Practices](https://docs.github.com/en/actions/security-for-github-actions)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/)

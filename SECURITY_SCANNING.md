# Security Scanning Documentation

**Last Updated**: November 2025  
**Purpose**: Guide to understanding and using security scanning in this repository

---

## Overview

This repository uses automated security scanning to detect vulnerabilities in code and Docker images. The scanning is **non-blocking**, meaning it reports findings but doesn't prevent deployments or merges.

---

## Security Scanning Tools

### 1. CodeQL Analysis

**What it does**:  
CodeQL is GitHub's semantic code analysis engine that finds security vulnerabilities, bugs, and code quality issues in your source code.

**When it runs**:
- Automatically on all pull requests targeting `develop`, `uat`, or `main` branches
- Weekly scheduled scans (every Sunday)
- Can be manually triggered via workflow dispatch

**What it scans**:
- JavaScript/TypeScript code
- YAML configuration files
- Helm charts and Kubernetes manifests
- Security patterns and anti-patterns

**Where to view results**:
1. **GitHub Security Tab**: Repository → Security → Code scanning alerts
2. **Pull Request**: Security findings appear as annotations in PR checks
3. **Workflow Artifacts**: Downloadable results in workflow run artifacts

**Workflow File**: `.github/workflows/codeql-analysis.yml`

---

### 2. Trivy Docker Image Scanning

**What it does**:  
Trivy scans Docker images for vulnerabilities in:
- Operating system packages (Alpine, Debian, Ubuntu, etc.)
- Application dependencies (npm, pip, etc.)
- Configuration files (Dockerfile, Kubernetes manifests)
- Secrets and sensitive data

**When it runs**:
- Automatically on every push to `develop`, `uat`, or `main` branches
- Runs as part of the CI/CD pipeline after image build, before push

**What it scans**:
- Built Docker image: `n8n-custom:<branch-name>`
- Base image vulnerabilities (from `n8nio/n8n:latest`)
- Any packages installed in the image

**Where to view results**:
1. **GitHub Security Tab**: Repository → Security → Code scanning alerts
2. **Workflow Logs**: Detailed scan output in CI/CD workflow logs
3. **SARIF Report**: Uploaded to GitHub Security tab

**Workflow File**: Integrated into `.github/workflows/ci-cd.yaml`

---

## Viewing Security Findings

### GitHub Security Tab

1. Navigate to your repository on GitHub
2. Click the **Security** tab
3. Select **Code scanning alerts**
4. View all findings from CodeQL and Trivy

### In Pull Requests

Security findings automatically appear in pull requests:
- **Annotations**: Inline comments on code with issues
- **Check Status**: Security scan status in PR checks
- **Summary**: Overview of findings in PR description

### Workflow Artifacts

1. Go to **Actions** tab
2. Select the workflow run
3. Scroll to **Artifacts** section
4. Download `codeql-results-*` or `trivy-results.sarif`

---

## Understanding Scan Results

### Severity Levels

Both tools use standard severity classifications:

- **CRITICAL**: Immediate action required, serious security risk
- **HIGH**: Should be addressed soon, significant security risk
- **MEDIUM**: Should be addressed, moderate security risk
- **LOW**: Consider addressing, minor security risk
- **INFO**: Informational, no immediate action needed

### Common Findings

#### CodeQL Findings

- **SQL Injection**: Unsanitized database queries
- **XSS (Cross-Site Scripting)**: Unsanitized user input in web output
- **Path Traversal**: Insecure file path handling
- **Hardcoded Secrets**: Passwords or API keys in code
- **Insecure Dependencies**: Vulnerable third-party packages

#### Trivy Findings

- **CVE (Common Vulnerabilities and Exposures)**: Known security vulnerabilities in packages
- **Outdated Packages**: Packages with available security updates
- **Misconfigurations**: Insecure Docker or Kubernetes configurations
- **Exposed Secrets**: Sensitive data in image layers

---

## Addressing Security Findings

### For CodeQL Findings

1. **Review the finding**: Click on the alert in GitHub Security tab
2. **Understand the issue**: Read the description and code location
3. **Fix the vulnerability**: Update code to address the issue
4. **Re-run scan**: Push changes and CodeQL will re-analyze
5. **Verify fix**: Check that the alert is resolved

### For Trivy Findings

1. **Identify the package**: Note which package has the vulnerability
2. **Check CVE details**: Click through to CVE database for details
3. **Update base image**: If vulnerability is in base image, update Dockerfile
4. **Update packages**: If in application dependencies, update package versions
5. **Rebuild and rescan**: Push changes to trigger new scan

### Example: Updating Base Image

If Trivy finds vulnerabilities in the base image:

```dockerfile
# Before
FROM n8nio/n8n:latest

# After (use specific version with fixes)
FROM n8nio/n8n:1.19.0
```

### Example: Fixing CodeQL Finding

If CodeQL finds a hardcoded secret:

```yaml
# Before (insecure)
apiKey: "sk-1234567890abcdef"

# After (secure - use secrets)
apiKey: ${{ secrets.API_KEY }}
```

---

## Configuration

### CodeQL Configuration

The CodeQL workflow is configured in `.github/workflows/codeql-analysis.yml`:

- **Languages**: Auto-detected (JavaScript/TypeScript)
- **Queries**: `security-extended,security-and-quality` (comprehensive security checks)
- **Blocking**: No (non-blocking, reports only)

### Trivy Configuration

Trivy is configured in `.github/workflows/ci-cd.yaml`:

- **Scan Type**: Image scanning
- **Severity**: All levels (CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN)
- **Scanners**: Vulnerabilities, config issues, secrets
- **Blocking**: No (exit-code: 0, non-blocking)

### Making Scans Blocking (Optional)

If you want to make scans block deployments:

**For CodeQL**: Remove `continue-on-error: true` from workflow steps

**For Trivy**: Change `exit-code: '0'` to `exit-code: '1'` in Trivy step

**Warning**: This will prevent deployments if any vulnerabilities are found, even low-severity ones.

---

## Best Practices

### 1. Regular Review

- Review security findings weekly
- Prioritize CRITICAL and HIGH severity issues
- Address findings before they accumulate

### 2. Keep Dependencies Updated

- Regularly update base Docker images
- Keep application dependencies up to date
- Use `docker pull` to get latest base images

### 3. Use Secrets Management

- Never hardcode secrets in code or config files
- Use GitHub Secrets for CI/CD
- Use Kubernetes Secrets for runtime configuration

### 4. Review Before Merging

- Check security scan results in pull requests
- Address high-severity findings before merging
- Document why low-severity findings are acceptable (if applicable)

### 5. Monitor Base Images

- Subscribe to security advisories for base images
- Update base images when security patches are released
- Test updates in dev environment first

---

## Troubleshooting

### CodeQL Not Running

**Problem**: CodeQL workflow doesn't trigger on PRs

**Solutions**:
- Check that PR targets `develop`, `uat`, or `main` branch
- Verify workflow file is in `.github/workflows/` directory
- Check GitHub Actions permissions in repository settings

### Trivy Scan Fails

**Problem**: Trivy step fails in CI/CD workflow

**Solutions**:
- Check Docker image was built successfully
- Verify image tag matches: `n8n-custom:${{ github.ref_name }}`
- Check Trivy action version is up to date
- Review workflow logs for specific error

### No Results in Security Tab

**Problem**: Scans run but no results appear in Security tab

**Solutions**:
- Wait a few minutes for results to process
- Check that `security-events: write` permission is set
- Verify SARIF upload step completed successfully
- Check repository has GitHub Advanced Security enabled (for some features)

### Too Many False Positives

**Problem**: Many findings that aren't actual security issues

**Solutions**:
- Review and dismiss false positives in Security tab
- Adjust CodeQL query configuration
- Add custom query exclusions
- Document acceptable patterns in code comments

---

## Additional Resources

- **CodeQL Documentation**: https://codeql.github.com/docs/
- **Trivy Documentation**: https://aquasecurity.github.io/trivy/
- **GitHub Security Features**: https://docs.github.com/en/code-security
- **CVE Database**: https://cve.mitre.org/

---

## Support

For questions or issues with security scanning:

1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Consult tool-specific documentation (links above)
4. Open an issue in the repository

---

**Note**: Security scanning is a tool to help identify potential issues. It's important to review findings in context and use your judgment when addressing them. Not all findings may be applicable to your specific use case.


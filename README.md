# WAFtester Action

Test, fingerprint, and bypass Web Application Firewalls
directly in your GitHub Actions workflows.

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-WAFtester-blue?logo=github)](https://github.com/marketplace/actions/waftester-waf-security-testing)
[![Website](https://img.shields.io/badge/website-waftester.com-3b82f6)](https://waftester.com)
[![CLI Version](https://img.shields.io/badge/CLI-v2.9.37-00ADD8?logo=go&logoColor=white)](https://github.com/waftester/waftester/releases/tag/v2.9.37) <!-- x-cli-version -->
[![License](https://img.shields.io/badge/License-BSL%201.1-blue.svg)](LICENSE)
[![CI](https://github.com/waftester/waftester-action/actions/workflows/test-action.yml/badge.svg)](https://github.com/waftester/waftester-action/actions/workflows/test-action.yml)

> **This action wraps the
> [WAFtester CLI](https://github.com/waftester/waftester)**
> — the most comprehensive WAF testing platform with 2,800+
> payloads, 197 vendor signatures, and 70+ tamper scripts.
> Results appear in the **Security → Code scanning** tab via
> SARIF integration.

---

## Quick Start

```yaml
permissions:
  security-events: write    # Required for SARIF upload to Security tab

steps:
  - uses: waftester/waftester-action@v1
    with:
      target: https://app.example.com
```

That's it. The action downloads the binary, runs a scan,
generates a SARIF report, and uploads it to
**Security → Code scanning** automatically.

---

## What It Does

1. **Downloads** the WAFtester Go binary from the latest
   [GitHub Release](https://github.com/waftester/waftester/releases).
2. **Verifies** the SHA-256 checksum of the downloaded archive.
3. **Runs** the selected scan type against your target URL.
4. **Generates** a SARIF report with ruleId, CWE, severity,
   and location for every finding.
5. **Uploads** the SARIF file to GitHub Code Scanning
   (Security tab) — configurable.
6. **Writes** a rich Markdown job summary with findings table,
   status emoji, and collapsible remediation guidance.
7. **Sets outputs** (`exit-code`, `bypass-count`, `sarif-file`,
   `summary`, `version`) for downstream steps.

Supported on **Linux**, **macOS**, and **Windows** runners
(x86_64 and ARM64).

---

## Usage Examples

### Basic Scan

```yaml
name: WAF Security Scan
on: [push, pull_request]

permissions:
  security-events: write

jobs:
  waf-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: waftester/waftester-action@v1
        with:
          target: https://app.example.com
```

### Full Autonomous Assessment

```yaml
- uses: waftester/waftester-action@v1
  id: waf
  with:
    target: https://app.example.com
    scan-type: auto
    fail-on-bypass: true

- if: steps.waf.outputs.bypass-count != '0'
  run: |
    echo "::error::${{ steps.waf.outputs.bypass-count }} WAF bypasses found"
    echo "${{ steps.waf.outputs.summary }}"
```

### WAF Vendor Detection

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    scan-type: vendor
```

### Specific Attack Categories

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    args: '-types sqli,xss,cmdi --smart'
```

### Bypass Discovery

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    scan-type: bypass
    args: '--smart --tamper-auto'
    fail-on-bypass: true
```

### API Spec Scanning (v2.9.1)

Scan every endpoint defined in an OpenAPI, Swagger, Postman, HAR, AsyncAPI, gRPC, or GraphQL spec:

```yaml
# OpenAPI / Swagger
- uses: waftester/waftester-action@v1
  with:
    target: https://api.example.com
    args: '--spec openapi.yaml'

# Postman Collection with environment
- uses: waftester/waftester-action@v1
  with:
    target: https://api.example.com
    args: '--spec collection.postman_collection.json --env staging.postman_environment.json'

# HAR recording from DevTools
- uses: waftester/waftester-action@v1
  with:
    target: https://api.example.com
    args: '--spec recording.har --intensity high'

# Dry-run to preview what would be scanned
- uses: waftester/waftester-action@v1
  with:
    target: https://api.example.com
    args: '--spec openapi.yaml --dry-run'
```

### Scheduled Weekly Audit

```yaml
name: Weekly WAF Audit
on:
  schedule:
    - cron: '0 6 * * 1'    # Every Monday 06:00 UTC

permissions:
  security-events: write

jobs:
  audit:
    strategy:
      matrix:
        include:
          - name: app
            url: https://app.example.com
          - name: api
            url: https://api.example.com
    runs-on: ubuntu-latest
    steps:
      - uses: waftester/waftester-action@v1
        with:
          target: ${{ matrix.url }}
          scan-type: assess
          sarif-category: 'waf-${{ matrix.name }}'
          args: '-fp'
```

### PR Gate with Comment

```yaml
- uses: waftester/waftester-action@v1
  id: waf
  with:
    target: https://staging.example.com
    scan-type: auto
    fail-on-bypass: true

- if: always() && github.event_name == 'pull_request'
  uses: actions/github-script@v7
  env:
    BYPASS_COUNT: ${{ steps.waf.outputs.bypass-count }}
    WAF_SUMMARY: ${{ steps.waf.outputs.summary }}
  with:
    script: |
      const count = process.env.BYPASS_COUNT;
      const summary = process.env.WAF_SUMMARY;
      const status = count === '0' ? ':white_check_mark:' : ':red_circle:';
      github.rest.issues.createComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        body: `## ${status} WAF Scan Results\n\n` +
              `**Bypasses:** ${count}\n\n` +
              summary
      });
```

### JSON Output (No SARIF)

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    format: json
    output: results.json
    upload-sarif: false
```

### Multi-Target Matrix

```yaml
jobs:
  scan:
    strategy:
      fail-fast: false
      matrix:
        include:
          - target: https://staging.example.com
            env: staging
          - target: https://prod.example.com
            env: production
    runs-on: ubuntu-latest
    steps:
      - uses: waftester/waftester-action@v1
        with:
          target: ${{ matrix.target }}
          sarif-category: 'waf-${{ matrix.env }}'
```

### Informational Only (Never Fails)

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    fail-on-bypass: false
    fail-on-error: false
```

---

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `target` | Target URL to scan | **Yes** | — |
| `scan-type` | Scan type (see table below) | No | `scan` |
| `version` | WAFtester version to install | No | `latest` |
| `format` | Output format (`sarif`, `json`, `jsonl`, `csv`, `md`, `html`, `pdf`). For JUnit/CycloneDX/SonarQube/GitLab SAST use `args` with dedicated export flags. | No | `sarif` |
| `output` | Output file path | No | `waftester-results.sarif` |
| `args` | Extra CLI flags (e.g., `--smart --tamper-auto -types sqli,xss`) | No | — |
| `fail-on-bypass` | Fail the step when bypasses are found (exit code 1) | No | `false` |
| `fail-on-error` | Fail the step on infrastructure errors (exit codes 2–6) | No | `true` |
| `upload-sarif` | Upload SARIF to GitHub Code Scanning (Security tab) | No | `true` |
| `sarif-category` | Category for SARIF upload — groups results in the Security tab | No | `waftester` |
| `token` | GitHub token for downloading releases and uploading SARIF. The default `GITHUB_TOKEN` is used for API rate limiting on release downloads and SARIF upload. Override with a PAT only if the WAFtester releases repository becomes private or restricted. | No | `${{ github.token }}` |

### Scan Types

| `scan-type` | CLI Command | Description |
|-------------|-------------|-------------|
| `scan` | `waf-tester scan` | Standard payload scan (default) |
| `auto` | `waf-tester auto` | Full autonomous assessment |
| `bypass` | `waf-tester bypass` | Bypass discovery with tampers |
| `assess` | `waf-tester assess` | Enterprise metrics (F1, MCC, FPR) |
| `vendor` | `waf-tester vendor` | WAF fingerprinting (197 signatures) |
| `discover` | `waf-tester discover` | Endpoint discovery & crawl |
| `fuzz` | `waf-tester fuzz` | Content/directory fuzzing |
| `nuclei` | `waf-tester template` | Nuclei-compatible template scan |
| `custom` | (from `args`) | Pass full command via `args` |

---

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `exit-code` | WAFtester exit code (see table below) | `0` |
| `bypass-count` | Number of WAF bypasses found | `12` |
| `sarif-file` | Path to the generated SARIF file | `waftester-results.sarif` |
| `summary` | One-line human-readable summary | `WAFtester found 12 WAF bypass(es)...` |
| `version` | Installed WAFtester version | `2.9.37` |

---

## Exit Codes

The action preserves WAFtester's 7 semantic exit codes:

| Code | Meaning | `fail-on-bypass` | `fail-on-error` |
|------|---------|:-:|:-:|
| 0 | Clean — no issues found | Pass | Pass |
| 1 | Bypasses found | **Fail** (if true) | Pass |
| 2 | Too many errors (threshold exceeded) | Pass | **Fail** (if true) |
| 3 | Configuration error | Pass | **Fail** (if true) |
| 4 | Target unreachable | Pass | **Fail** (if true) |
| 5 | Interrupted (timeout/signal) | Pass | **Fail** (if true) |
| 6 | License violation | Pass | **Fail** (if true) |

By default, `fail-on-bypass` is `false` (informational) and
`fail-on-error` is `true` (fail on infra issues). Set both to
`true` for a strict quality gate.

---

## SARIF Integration

When `upload-sarif` is `true` (the default) and `format` is
`sarif`, the action automatically uploads results to
**GitHub Code Scanning** using
[`github/codeql-action/upload-sarif@v4`](https://github.com/github/codeql-action).

Results appear under **Security → Code scanning alerts** with:

- Rule IDs (e.g., `sqli-SQLI003`, `xss-XSS001`)
- CWE references (18 mapped categories)
- Severity levels (error, warning, note)
- Finding locations with request/response excerpts
- Fingerprints for deduplication across runs

### Requirements

- Repository must have **GitHub Advanced Security** enabled
  (free for public repos; requires GHAS license for private).
- Workflow must declare `permissions: security-events: write`.
- SARIF file must be under **10 MB**. Large scans
  (2,800+ payloads with full response bodies) may exceed
  this limit. Mitigate by limiting payload types with
  `-types sqli,xss` or using `--smart` mode.

### Authenticated Targets

For targets behind authentication, pass headers via `args`:

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    args: '-H "Authorization: Bearer ${{ secrets.TARGET_TOKEN }}"'
```

> **Note:** Use repository secrets for credentials — never
> hardcode tokens in workflow files.

### Disabling SARIF Upload

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    upload-sarif: false
```

### Without GitHub Code Scanning

SARIF upload requires
[GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
(GHAS). Public repos get this free. Private repos need a
GHAS license — without it, SARIF upload silently fails.

**If your repo does NOT have Code Scanning enabled:**

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: https://app.example.com
    upload-sarif: false       # disable SARIF upload
    format: sarif             # still generates the file
    fail-on-bypass: true      # fail the workflow on bypasses
```

Results are still available through:

- **Job Summary** — always written to the workflow run page
  (visible under Actions → run → Summary)
- **SARIF artifact** — download the raw file for local review
  or import into third-party tools
- **Output variables** — `exit-code`, `bypass-count`,
  `summary` for use in downstream steps

To save the SARIF as a downloadable artifact:

```yaml
- uses: waftester/waftester-action@v1
  id: waf
  with:
    target: https://app.example.com
    upload-sarif: false

- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: waf-results
    path: ${{ steps.waf.outputs.sarif-file }}
```

---

## Version Pinning

```yaml
# Recommended: floating major tag (gets latest v1.x.x)
- uses: waftester/waftester-action@v1

# Pin to exact action release
- uses: waftester/waftester-action@v1.0.45

# Pin WAFtester binary version (action auto-downloads)
- uses: waftester/waftester-action@v1
  with:
    version: '2.9.37'

# Pin to commit SHA (highest security)
# Replace with actual SHA from: git rev-parse v1.0.45
- uses: waftester/waftester-action@<commit-sha>
```

---

## Supported Runners

| Runner | Architecture | Status |
|--------|-------------|--------|
| `ubuntu-latest` | x86_64 | Fully tested |
| `ubuntu-24.04` | x86_64 | Fully tested |
| `macos-latest` | ARM64 | Fully tested |
| `macos-13` | x86_64 | Supported |
| `windows-latest` | x86_64 | Fully tested |
| Self-hosted Linux | x86_64, ARM64 | Supported |
| Self-hosted macOS | ARM64 | Supported |
| Self-hosted Windows | x86_64 | Supported |

**Requirements:** `bash`, `curl`, `sha256sum` (or `shasum`).
All GitHub-hosted runners include these by default.

---

## Other Installation Methods

This GitHub Action is one of several ways to run WAFtester:

| Method | Command | Best For |
|--------|---------|----------|
| **GitHub Action** | `- uses: waftester/waftester-action@v1` | CI/CD pipelines |
| **npm** | `npx @waftester/cli scan -u URL` | Quick install, MCP server |
| **Docker** | `docker run ghcr.io/waftester/waftester scan -u URL` | Containers |
| **Binary** | [Download from Releases](https://github.com/waftester/waftester/releases) | Direct install |

---

## Links

- [**WAFtester CLI**](https://github.com/waftester/waftester)
  — main project with full documentation
- [**Examples**](./examples/) — 6 ready-to-use workflow files
- [**Changelog**](./CHANGELOG.md)
  — action release notes and version history
- [**Security Policy**](./SECURITY.md)
  — vulnerability reporting
- [**npm Package**](https://www.npmjs.com/package/@waftester/cli)
  — `npx @waftester/cli` alternative

---

## License

[BSL 1.1](LICENSE) — see the
[main project](https://github.com/waftester/waftester)
for full license terms. Changes to Apache 2.0 on
January 31, 2030.

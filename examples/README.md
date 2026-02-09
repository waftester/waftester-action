# WAFtester Action — Example Workflows

Copy any of these files into `.github/workflows/` and
customize the `target` input.

| File | Use Case |
|------|----------|
| [basic-scan.yml](basic-scan.yml) | Minimal scan + SARIF upload |
| [full-assessment.yml](full-assessment.yml) | Autonomous assessment + quality gate |
| [scheduled-scan.yml](scheduled-scan.yml) | Weekly audit across multiple targets |
| [pr-gate.yml](pr-gate.yml) | PR comment with findings summary |
| [multi-target.yml](multi-target.yml) | Matrix strategy for staging/prod |
| [sarif-only.yml](sarif-only.yml) | Informational scan (never fails) |

All examples require `permissions: security-events: write`
for SARIF upload.

See the [action README](../README.md) for full input/output
reference and exit code documentation.

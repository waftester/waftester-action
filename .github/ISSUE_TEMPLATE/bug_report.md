---
name: Bug Report
about: Report a problem with the GitHub Action
labels: bug
---

## Describe the bug

<!-- A clear description of the problem. -->

## Workflow snippet

```yaml
- uses: waftester/waftester-action@v1
  with:
    target: ...
    scan-type: ...
```

## Runner

- **OS:** (e.g., ubuntu-latest, macos-latest, windows-latest)
- **Self-hosted:** Yes / No
- **Action version:** (e.g., v1.0.0)
- **WAFtester version:** (e.g., 2.8.2 or latest)

## Expected behavior

<!-- What you expected to happen. -->

## Actual behavior

<!-- What actually happened. Include logs if possible. -->

## Additional context

## Triage routing (F55)

<!--
Before filing, determine if this is an action issue or a CLI issue:

**Action issues** (file HERE):
- Install failures, binary download problems
- SARIF upload not working, job summary broken
- Input validation, exit code handling
- Runner compatibility (OS, self-hosted)

**CLI/scanner issues** (file at waftester/waftester):
- Scan results incorrect, false positives
- WAF detection failures, payload issues
- CLI flags, output formatting, performance
- https://github.com/waftester/waftester/issues
-->

<!-- Stack traces, screenshots, related issues. -->

# Contributing to WAFtester Action

Thank you for your interest in contributing!

## Scope

This repository contains the **GitHub Action wrapper** for
[WAFtester](https://github.com/waftester/waftester). It includes:

- `action.yml` — action definition
- `install.sh` — binary download and verification
- `entrypoint.sh` — command builder and job summary
- Example workflows in `examples/`

## Where to Contribute

| Type | Repo |
|------|------|
| Action wrapper bugs/features | **This repo** |
| Scanner/CLI bugs/features | [waftester/waftester](https://github.com/waftester/waftester) |
| Payload additions | [waftester/waftester](https://github.com/waftester/waftester) |
| Documentation (CLI) | [waftester/waftester](https://github.com/waftester/waftester) |

## Development

### Prerequisites

- Bash 4+
- [ShellCheck](https://github.com/koalaman/shellcheck)
- A GitHub account for testing workflows

### Testing Locally

```bash
# Lint shell scripts
shellcheck install.sh entrypoint.sh

# Validate action.yml syntax
yamllint action.yml
```

### Testing in CI

Push to a branch and create a PR — the `test-action.yml`
workflow runs E2E tests on Linux, macOS, and Windows.

## Pull Requests

1. Fork this repo and create a feature branch.
2. Make your changes with clear commit messages.
3. Ensure ShellCheck passes with no new warnings.
4. Submit a PR against `main`.

## Contributor License Agreement

By submitting a pull request, you agree to license your
contribution under the same license as this project
(BSL-1.1).

## Code of Conduct

This project follows the
[Contributor Covenant](CODE_OF_CONDUCT.md). Please read
it before participating.

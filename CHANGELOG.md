# Changelog

All notable changes to the WAFtester GitHub Action
will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-XX-XX

### Added

- Initial Marketplace release of WAFtester Action
- Composite action for Linux, macOS, and Windows runners
- SHA-256 checksum verification of downloaded binaries
- Automatic SARIF upload to GitHub Security tab
- 11 configurable inputs (target, scan-type, version, etc.)
- 5 outputs (exit-code, bypass-count, sarif-file, summary, version)
- Rich Markdown job summary with findings table
- 7 semantic exit codes with configurable pass/fail
- `fail-on-bypass` and `fail-on-error` controls
- 9 scan types mapping to WAFtester CLI subcommands
- 6 example workflows included

[1.0.0]: https://github.com/waftester/waftester-action/releases/tag/v1.0.0

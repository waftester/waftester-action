# Changelog

All notable changes to the WAFtester GitHub Action
will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] — 2026-02-09

### Changed

- Bumped bundled CLI to WAFtester 2.8.2

## [1.0.1] — 2026-02-09

### Fixed

- Restored real CORS scan in test-sarif CI job
- Fixed vendor subcommand flag compatibility

## [1.0.0] — 2026-02-09

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

[1.0.2]: https://github.com/waftester/waftester-action/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/waftester/waftester-action/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/waftester/waftester-action/releases/tag/v1.0.0

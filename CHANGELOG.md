# Changelog

All notable changes to the WAFtester GitHub Action
will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.16] - 2026-02-16

### Changed

- Bump bundled CLI to WAFtester v2.9.6

## [v1.0.15] - 2026-02-15

### Changed

- Bump bundled CLI to WAFtester v2.9.5

## [v1.0.14] - 2026-02-15

### Changed

- Bump bundled CLI to WAFtester v2.9.4

## [v1.0.13] - 2026-02-15

### Changed

- Bump bundled CLI to WAFtester v2.9.3

## [v1.0.12] - 2026-02-14

### Changed

- Bump bundled CLI to WAFtester v2.9.2

## [v1.0.11] - 2026-02-14

### Changed

- Bump bundled CLI to WAFtester v2.9.1

## [v1.0.10] - 2026-02-14

### Changed

- Bump bundled CLI to WAFtester v2.9.0

## [v1.0.9] - 2026-02-14

### Changed

- Bump bundled CLI to WAFtester v2.9.0
- Add API spec scanning support (Postman, HAR, AsyncAPI, OpenAPI, Swagger, gRPC, GraphQL)

## [v1.0.8] - 2026-02-13

### Changed

- Bump bundled CLI to WAFtester v2.8.8

## [v1.0.7] - 2026-02-13

### Changed

- Bump bundled CLI to WAFtester v2.8.7

## [v1.0.6] - 2026-02-13

### Changed

- Bump bundled CLI to WAFtester v2.8.6

## [v1.0.5] - 2026-02-12

### Changed

- Bump bundled CLI to WAFtester v2.8.5

## [v1.0.4] - 2026-02-10

### Changed

- Bump bundled CLI to WAFtester v2.8.4

## [v1.0.3] - 2026-02-09

### Changed

- Bump bundled CLI to WAFtester v2.8.3

## [1.0.3] — 2026-02-10

### Security

- SHA-pin all third-party GitHub Actions across all workflows
- Migrate `${{ }}` expressions to `env:` blocks to prevent injection
- Replace `eval` with `xargs` for safe argument parsing in entrypoint
- Use PID-unique heredoc delimiters to prevent output injection
- Sanitize Markdown table output against content injection
- Add GITHUB_TOKEN anti-recursion guard in auto-update workflow
- Add concurrency groups to prevent parallel release races

### Fixed

- Fix SC2001 shellcheck violation in auto-update release notes (`echo|sed` → `printf`)
- Add `--retry-all-errors` to curl downloads for transient CDN failures
- Fix custom scan-type passthrough with explicit notice
- Fix process substitution in strict bash (`set -euo pipefail`)
- Add SARIF file existence validation before upload

### Changed

- Bumped bundled CLI to WAFtester 2.8.3
- Inline v1 tag float into release workflow (eliminate separate workflow)
- Add semver validation for version tags before release

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

[1.0.3]: https://github.com/waftester/waftester-action/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/waftester/waftester-action/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/waftester/waftester-action/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/waftester/waftester-action/releases/tag/v1.0.0

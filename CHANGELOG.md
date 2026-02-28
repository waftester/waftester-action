# Changelog

All notable changes to the WAFtester GitHub Action
will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.48] - 2026-02-28

### Changed

- Bump bundled CLI to WAFtester v2.9.40

## [v1.0.47] - 2026-02-28

### Changed

- Bump bundled CLI to WAFtester v2.9.39

## [v1.0.46] - 2026-02-27

### Changed

- Bump bundled CLI to WAFtester v2.9.38

## [v1.0.45] - 2026-02-26

### Changed

- Bump bundled CLI to WAFtester v2.9.37

## [v1.0.44] - 2026-02-26

### Changed

- Bump bundled CLI to WAFtester v2.9.36

## [v1.0.43] - 2026-02-26

### Changed

- Bump bundled CLI to WAFtester v2.9.35

## [v1.0.42] - 2026-02-26

### Changed

- Bump bundled CLI to WAFtester v2.9.34

## [v1.0.41] - 2026-02-26

### Changed

- Bump bundled CLI to WAFtester v2.9.33

## [v1.0.40] - 2026-02-25

### Changed

- Bump bundled CLI to WAFtester v2.9.32

## [v1.0.39] - 2026-02-25

### Changed

- Bump bundled CLI to WAFtester v2.9.31

## [v1.0.38] - 2026-02-24

### Changed

- Bump bundled CLI to WAFtester v2.9.30

## [v1.0.37] - 2026-02-24

### Changed

- Bump bundled CLI to WAFtester v2.9.29

## [v1.0.36] - 2026-02-23

### Changed

- Bump bundled CLI to WAFtester v2.9.28

## [v1.0.35] - 2026-02-23

### Changed

- Bump bundled CLI to WAFtester v2.9.27

## [v1.0.34] - 2026-02-22

### Changed

- Bump bundled CLI to WAFtester v2.9.26

## [v1.0.33] - 2026-02-22

### Changed

- Bump bundled CLI to WAFtester v2.9.25

## [v1.0.32] - 2026-02-21

### Changed

- Bump bundled CLI to WAFtester v2.9.24

## [v1.0.31] - 2026-02-21

### Changed

- Bump bundled CLI to WAFtester v2.9.23

## [v1.0.30] - 2026-02-20

### Changed

- Bump bundled CLI to WAFtester v2.9.22

## [v1.0.29] - 2026-02-20

### Changed

- Bump bundled CLI to WAFtester v2.9.21

## [v1.0.28] - 2026-02-20

### Changed

- Bump bundled CLI to WAFtester v2.9.20

## [v1.0.27] - 2026-02-19

### Changed

- Bump bundled CLI to WAFtester v2.9.19

## [v1.0.26] - 2026-02-18

### Changed

- Bump bundled CLI to WAFtester v2.9.17

## [v1.0.25] - 2026-02-18

### Changed

- Bump bundled CLI to WAFtester v2.9.16

## [v1.0.24] - 2026-02-18

### Changed

- Bump bundled CLI to WAFtester v2.9.14

## [v1.0.23] - 2026-02-18

### Changed

- Bump bundled CLI to WAFtester v2.9.13

## [v1.0.22] - 2026-02-18

### Changed

- Bump bundled CLI to WAFtester v2.9.12

## [v1.0.21] - 2026-02-17

### Changed

- Bump bundled CLI to WAFtester v2.9.11

## [v1.0.20] - 2026-02-17

### Changed

- Bump bundled CLI to WAFtester v2.9.10

## [v1.0.19] - 2026-02-17

### Changed

- Bump bundled CLI to WAFtester v2.9.9

## [v1.0.18] - 2026-02-17

### Changed

- Bump bundled CLI to WAFtester v2.9.8

## [v1.0.17] - 2026-02-16

### Changed

- Bump bundled CLI to WAFtester v2.9.7

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

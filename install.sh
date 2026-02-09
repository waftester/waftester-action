#!/usr/bin/env bash
# install.sh — Install WAFtester binary on GitHub Actions runner
#
# Downloads the pre-built Go binary from GitHub Releases,
# verifies SHA-256 checksum, and adds to PATH.
#
# Expects (set by action.yml):
#   INPUT_VERSION   — Version to install ("latest" or "2.8.2" or "v2.8.2")
#   GITHUB_TOKEN    — Token for GitHub API (rate limits + private repo access)
#
# Sets:
#   GITHUB_PATH     — Adds binary directory to PATH
#   GITHUB_ENV      — Exports WAF_TESTER_PAYLOAD_DIR, WAF_TESTER_TEMPLATE_DIR
#   GITHUB_OUTPUT   — Exports resolved version
#
set -euo pipefail

# ============================================================================
# Logging helpers (GitHub Actions annotations)
# ============================================================================

log_group()    { echo "::group::$1"; }
log_endgroup() { echo "::endgroup::"; }
log_info()     { echo "  $*"; }
log_warn()     { echo "::warning::$*"; }
log_error()    { echo "::error::$*"; exit 1; }

log_group "WAFtester Install"

# ============================================================================
# 1. Detect platform
# ============================================================================

# Prefer GitHub's RUNNER_OS / RUNNER_ARCH env vars (always set on hosted runners)
# Fall back to uname for self-hosted runners or local testing

detect_os() {
  if [[ -n "${RUNNER_OS:-}" ]]; then
    case "${RUNNER_OS}" in
      Linux)   echo "Linux" ;;
      macOS)   echo "Darwin" ;;
      Windows) echo "Windows" ;;
      *)       log_error "Unsupported RUNNER_OS: ${RUNNER_OS}" ;;
    esac
  else
    local os
    os="$(uname -s)"
    case "${os}" in
      Linux)                              echo "Linux" ;;
      Darwin)                             echo "Darwin" ;;
      MINGW*|MSYS*|CYGWIN*|Windows_NT)   echo "Windows" ;;
      *)                                  log_error "Unsupported OS: ${os}" ;;
    esac
  fi
}

detect_arch() {
  if [[ -n "${RUNNER_ARCH:-}" ]]; then
    case "${RUNNER_ARCH}" in
      X64)   echo "x86_64" ;;
      ARM64) echo "arm64" ;;
      *)     log_error "Unsupported RUNNER_ARCH: ${RUNNER_ARCH}" ;;
    esac
  else
    local arch
    arch="$(uname -m)"
    case "${arch}" in
      x86_64|amd64)   echo "x86_64" ;;
      aarch64|arm64)  echo "arm64" ;;
      *)              log_error "Unsupported architecture: ${arch}" ;;
    esac
  fi
}

PLATFORM_OS="$(detect_os)"
PLATFORM_ARCH="$(detect_arch)"

# Archive extension: zip for Windows, tar.gz for everything else
EXT="tar.gz"
if [[ "${PLATFORM_OS}" == "Windows" ]]; then
  EXT="zip"
fi

# Binary name: waf-tester on Unix, waf-tester.exe on Windows
BINARY_NAME="waf-tester"
if [[ "${PLATFORM_OS}" == "Windows" ]]; then
  BINARY_NAME="waf-tester.exe"
fi

# GoReleaser archive naming: waftester_<Os>_<Arch>.<ext>
ARCHIVE_NAME="waftester_${PLATFORM_OS}_${PLATFORM_ARCH}.${EXT}"

log_info "Platform: ${PLATFORM_OS}/${PLATFORM_ARCH}"
log_info "Archive:  ${ARCHIVE_NAME}"
log_info "Binary:   ${BINARY_NAME}"

# ============================================================================
# 2. Resolve version
# ============================================================================

VERSION="${INPUT_VERSION}"

# Strip leading 'v' if present
VERSION="${VERSION#v}"

# Validate version format (prevent path traversal and confusing errors)
if [[ "${VERSION}" != "latest" && -n "${VERSION}" ]]; then
  if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    log_error "Invalid version format: '${VERSION}'. Expected: X.Y.Z (e.g., 2.8.2)"
  fi
fi

if [[ "${VERSION}" == "latest" || -z "${VERSION}" ]]; then
  log_info "Resolving latest version from GitHub API..."

  # F50: Capture HTTP status for better error messages
  API_RESPONSE=$(curl -sSL -w "\n%{http_code}" \
    --max-time 30 --connect-timeout 10 \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/waftester/waftester/releases/latest" \
    2>/dev/null) || true

  HTTP_STATUS=$(echo "${API_RESPONSE}" | tail -1)
  LATEST_JSON=$(echo "${API_RESPONSE}" | sed '$d')

  # Detect total network failure (curl failed before getting any HTTP status)
  if [[ -z "${HTTP_STATUS}" || "${HTTP_STATUS}" == "000" ]]; then
    log_error "GitHub API unreachable (HTTP ${HTTP_STATUS:-none}). Check network connectivity and DNS."
  fi

  if [[ "${HTTP_STATUS}" != "200" ]]; then
    case "${HTTP_STATUS}" in
      403) log_error "GitHub API rate limited (HTTP 403). Set GITHUB_TOKEN or pin a version: version: '2.8.2'" ;;
      404) log_error "Release not found (HTTP 404). Verify the WAFtester releases repo exists." ;;
      *)   log_error "GitHub API request failed (HTTP ${HTTP_STATUS}). Try pinning a version: version: '2.8.2'" ;;
    esac
  fi

  VERSION=$(echo "${LATEST_JSON}" | grep '"tag_name"' | head -1 | sed -E 's/.*"v?([^"]+)".*/\1/')

  if [[ -z "${VERSION}" ]]; then
    log_error "Failed to parse latest version from GitHub API response. API may be rate-limited. Try pinning a version."
  fi
fi

TAG="v${VERSION}"

log_info "Version:  ${VERSION} (tag: ${TAG})"

# ============================================================================
# 3. Prepare install directory
# ============================================================================

# Use RUNNER_TEMP (GitHub-provided temp dir, cleaned after job)
# Falls back to /tmp for self-hosted runners or local testing
INSTALL_DIR="${RUNNER_TEMP:-/tmp}/waftester-${VERSION}"
BIN_DIR="${INSTALL_DIR}/bin"
mkdir -p "${BIN_DIR}"

log_info "Install:  ${INSTALL_DIR}"

# ============================================================================
# 4. Download archive and checksums
# ============================================================================

RELEASE_BASE="https://github.com/waftester/waftester/releases/download/${TAG}"
DOWNLOAD_URL="${RELEASE_BASE}/${ARCHIVE_NAME}"
CHECKSUMS_URL="${RELEASE_BASE}/checksums.txt"

log_info "Downloading ${ARCHIVE_NAME}..."
curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors -o "${INSTALL_DIR}/${ARCHIVE_NAME}" "${DOWNLOAD_URL}" \
  || log_error "Failed to download ${DOWNLOAD_URL}
  Verify that version ${TAG} exists: https://github.com/waftester/waftester/releases/tag/${TAG}
  Available releases: https://github.com/waftester/waftester/releases"

log_info "Downloading checksums.txt..."
curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors -o "${INSTALL_DIR}/checksums.txt" "${CHECKSUMS_URL}" \
  || log_error "Failed to download checksums.txt from ${CHECKSUMS_URL}"

# ============================================================================
# 5. Verify SHA-256 checksum
# ============================================================================

log_info "Verifying SHA-256 checksum..."

# Extract expected hash for our archive from checksums.txt
# GoReleaser format: "<64-char-hex>  <filename>" (sha256sum standard, two-space separator)
EXPECTED_HASH=$(grep -F "  ${ARCHIVE_NAME}" "${INSTALL_DIR}/checksums.txt" | awk '{print $1}')

if [[ -z "${EXPECTED_HASH}" ]]; then
  log_error "Archive '${ARCHIVE_NAME}' not found in checksums.txt.
  This usually means the platform ${PLATFORM_OS}/${PLATFORM_ARCH} is not supported for version ${TAG}.
  Available archives:
$(cat "${INSTALL_DIR}/checksums.txt")"
fi

# Compute actual hash
# - sha256sum available on Linux and Windows (Git Bash)
# - shasum available on macOS
if command -v sha256sum &>/dev/null; then
  ACTUAL_HASH=$(sha256sum "${INSTALL_DIR}/${ARCHIVE_NAME}" | awk '{print $1}' | tr -d '\\\\')
elif command -v shasum &>/dev/null; then
  ACTUAL_HASH=$(shasum -a 256 "${INSTALL_DIR}/${ARCHIVE_NAME}" | awk '{print $1}')
else
  log_error "Neither sha256sum nor shasum found on this runner. Cannot verify download integrity."
fi

if [[ "${EXPECTED_HASH}" != "${ACTUAL_HASH}" ]]; then
  log_error "Checksum verification FAILED!
  Expected: ${EXPECTED_HASH}
  Actual:   ${ACTUAL_HASH}
  The downloaded archive may be corrupted or tampered with.
  Try downloading again or report this issue."
fi

log_info "Checksum verified ✓ (${EXPECTED_HASH:0:16}...)"

# ============================================================================
# 6. Extract archive (flat structure — binary at root)
# ============================================================================

log_info "Extracting ${ARCHIVE_NAME}..."

EXTRACT_DIR="${INSTALL_DIR}/extracted"
mkdir -p "${EXTRACT_DIR}"

if [[ "${EXT}" == "zip" ]]; then
  unzip -q -o "${INSTALL_DIR}/${ARCHIVE_NAME}" -d "${EXTRACT_DIR}"
else
  tar xzf "${INSTALL_DIR}/${ARCHIVE_NAME}" -C "${EXTRACT_DIR}"
fi

# Verify binary exists in extracted content
if [[ ! -f "${EXTRACT_DIR}/${BINARY_NAME}" ]]; then
  log_error "Binary '${BINARY_NAME}' not found in archive.
  Archive contents:
$(ls -la "${EXTRACT_DIR}/")"
fi

# Move binary to bin/ directory
mv "${EXTRACT_DIR}/${BINARY_NAME}" "${BIN_DIR}/"
chmod +x "${BIN_DIR}/${BINARY_NAME}"

# Move supplemental directories (payloads, templates) if present
for dir in payloads templates; do
  if [[ -d "${EXTRACT_DIR}/${dir}" ]]; then
    mv "${EXTRACT_DIR}/${dir}" "${INSTALL_DIR}/"
    log_info "Extracted supplemental ${dir}/ directory"
  fi
done

# ============================================================================
# 7. Add to PATH and set environment variables
# ============================================================================

echo "${BIN_DIR}" >> "${GITHUB_PATH}"

# Set payload/template directories for WAFtester to find supplemental files
# These env vars are recognized by WAFtester (see cmd/cli/cmd_mcp.go)
if [[ -d "${INSTALL_DIR}/payloads" ]]; then
  echo "WAF_TESTER_PAYLOAD_DIR=${INSTALL_DIR}/payloads" >> "${GITHUB_ENV}"
fi

if [[ -d "${INSTALL_DIR}/templates" ]]; then
  echo "WAF_TESTER_TEMPLATE_DIR=${INSTALL_DIR}/templates" >> "${GITHUB_ENV}"
fi

# Export installed version as step output
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"

# ============================================================================
# 8. Verify installation
# ============================================================================

# NOTE: "waf-tester version" outputs to stderr via ui.PrintMiniBanner().
# Capture stderr; extract semver. Falls back to requested version on failure.
INSTALLED_VERSION=$( "${BIN_DIR}/${BINARY_NAME}" version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true )
if [[ -z "${INSTALLED_VERSION}" ]]; then
  INSTALLED_VERSION="${VERSION}"
  log_warn "Binary installed but 'version' output could not be parsed. The binary may be incompatible with this runner."
fi
log_info "Installed: WAFtester v${INSTALLED_VERSION}"
log_info "Binary:    ${BIN_DIR}/${BINARY_NAME}"
log_info "PATH entry added ✓"

# Cleanup — remove downloaded archive and extraction dir (keep binary + supplemental dirs)
rm -f "${INSTALL_DIR}/${ARCHIVE_NAME}" "${INSTALL_DIR}/checksums.txt"
rm -rf "${EXTRACT_DIR}"

log_endgroup

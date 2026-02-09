#!/usr/bin/env bash
# entrypoint.sh — Run WAFtester scan with configured inputs
#
# Required env vars (set by action.yml from inputs via INPUT_* pattern):
#   INPUT_TARGET         — Target URL
#   INPUT_SCAN_TYPE      — Scan type (scan, auto, bypass, assess, vendor, etc.)
#   INPUT_FORMAT         — Output format (sarif, json, html, etc.)
#   INPUT_OUTPUT         — Output file path
#   INPUT_ARGS           — Additional CLI arguments
#   INPUT_FAIL_ON_BYPASS — "true"/"false" — fail step on bypass detection
#   INPUT_FAIL_ON_ERROR  — "true"/"false" — fail step on infrastructure errors
#
# Sets GITHUB_OUTPUT:
#   exit-code, bypass-count, sarif-file, summary
# Sets GITHUB_STEP_SUMMARY:
#   Rich markdown table with results
#
set -uo pipefail
# NOTE: NOT set -e — we capture and handle exit codes ourselves

# ============================================================================
# Exit code constants (must match pkg/output/exitcode/exitcode.go)
# ============================================================================

export EXIT_SUCCESS=0
export EXIT_BYPASSES_DETECTED=1
export EXIT_TOO_MANY_ERRORS=2
export EXIT_INVALID_CONFIG=3
export EXIT_TARGET_UNREACHABLE=4
export EXIT_INTERRUPTED=5
export EXIT_LICENSE_ERROR=6

# Human-readable exit code descriptions
exit_code_description() {
  case "$1" in
    0) echo "All tests passed — no WAF bypasses detected" ;;
    1) echo "WAF bypasses detected" ;;
    2) echo "Too many errors during scan (threshold exceeded)" ;;
    3) echo "Invalid configuration" ;;
    4) echo "Target unreachable" ;;
    5) echo "Scan interrupted (timeout or signal)" ;;
    6) echo "License error" ;;
    *) echo "Unknown exit code: $1" ;;
  esac
}

# ============================================================================
# Derive output filename extension from format if using default name (F5)
# ============================================================================

# If user kept the default output name but changed format, fix the extension
if [[ "${INPUT_OUTPUT}" == "waftester-results.sarif" && "${INPUT_FORMAT}" != "sarif" ]]; then
  case "${INPUT_FORMAT}" in
    json)  INPUT_OUTPUT="waftester-results.json" ;;
    jsonl) INPUT_OUTPUT="waftester-results.jsonl" ;;
    csv)   INPUT_OUTPUT="waftester-results.csv" ;;
    md)    INPUT_OUTPUT="waftester-results.md" ;;
    html)  INPUT_OUTPUT="waftester-results.html" ;;
    pdf)   INPUT_OUTPUT="waftester-results.pdf" ;;
    *)     INPUT_OUTPUT="waftester-results.${INPUT_FORMAT}" ;;
  esac
  echo "::notice::Output filename auto-adjusted to '${INPUT_OUTPUT}' (format: ${INPUT_FORMAT})"
fi

# ============================================================================
# Build command
# ============================================================================

CMD=("waf-tester")

# Map scan-type input → CLI subcommand
case "${INPUT_SCAN_TYPE}" in
  scan)      CMD+=("scan") ;;
  auto)      CMD+=("auto") ;;
  bypass)    CMD+=("bypass") ;;
  assess)    CMD+=("assess") ;;
  vendor)    CMD+=("vendor") ;;
  discover)  CMD+=("discover") ;;
  fuzz)      CMD+=("fuzz") ;;
  nuclei)    CMD+=("template") ;;
  custom)
    # "custom" mode: INPUT_ARGS contains ALL arguments
    # Don't add subcommand, target, format, or output — user controls everything
    ;;
  *)
    echo "::error::Unknown scan-type '${INPUT_SCAN_TYPE}'. Valid values: scan, auto, bypass, assess, vendor, discover, fuzz, nuclei, custom"
    exit 1
    ;;
esac

# Add standard flags (except in custom mode where user provides everything)
if [[ "${INPUT_SCAN_TYPE}" != "custom" ]]; then
  # Target URL (required)
  CMD+=("-u" "${INPUT_TARGET}")

  # Output format
  if [[ -n "${INPUT_FORMAT}" ]]; then
    CMD+=("-format" "${INPUT_FORMAT}")
  fi

  # Output file
  if [[ -n "${INPUT_OUTPUT}" ]]; then
    CMD+=("-output" "${INPUT_OUTPUT}")
  fi

  # Supplemental payloads (WAF_TESTER_PAYLOAD_DIR env var is MCP-only;
  # scan/auto/bypass commands require the --payloads flag — see F1)
  if [[ -d "${WAF_TESTER_PAYLOAD_DIR:-}" ]]; then
    CMD+=("--payloads" "${WAF_TESTER_PAYLOAD_DIR}")
  fi
fi

# Extra arguments (word-split intentionally)
if [[ -n "${INPUT_ARGS}" ]]; then
  # Disable glob expansion to prevent * or ? in args from expanding to filenames
  set -f
  # shellcheck disable=SC2206
  CMD+=(${INPUT_ARGS})
  set +f
fi

# ============================================================================
# Run scan
# ============================================================================

echo "::group::WAFtester ${INPUT_SCAN_TYPE} scan"
echo ""
echo "  Target:    ${INPUT_TARGET}"
echo "  Scan Type: ${INPUT_SCAN_TYPE}"
echo "  Format:    ${INPUT_FORMAT}"
echo "  Output:    ${INPUT_OUTPUT}"
if [[ -n "${INPUT_ARGS}" ]]; then
  echo "  Extra:     ${INPUT_ARGS}"
fi
echo ""
echo "  Command:   ${CMD[*]}"
echo ""

# Execute and capture exit code (|| true prevents pipefail from killing script)
"${CMD[@]}" && SCAN_EXIT_CODE=0 || SCAN_EXIT_CODE=$?

echo ""
echo "  Exit Code: ${SCAN_EXIT_CODE} ($(exit_code_description "${SCAN_EXIT_CODE}"))"
echo "::endgroup::"

# ============================================================================
# Parse results
# ============================================================================

BYPASS_COUNT=0
FINDING_DETAILS=""

if [[ -f "${INPUT_OUTPUT}" ]]; then
  if command -v jq &>/dev/null; then
    case "${INPUT_FORMAT}" in
      sarif)
        # Count SARIF results (each result = one bypass/finding)
        BYPASS_COUNT=$(jq '[.runs[]?.results[]?] | length' "${INPUT_OUTPUT}" 2>/dev/null || echo "0")

        # Extract top finding categories for summary (e.g., "sqli-SQLI003: 5, xss-XSS001: 3")
        if [[ "${BYPASS_COUNT}" -gt 0 ]]; then
          FINDING_DETAILS=$(jq -r '
            [.runs[]?.results[]?.ruleId]
            | group_by(.)
            | map({key: .[0], count: length})
            | sort_by(-.count)
            | .[:5]
            | map("\(.key // "unknown"): \(.count)")
            | join(", ")
          ' "${INPUT_OUTPUT}" 2>/dev/null || echo "")
        fi
        ;;
      json)
        BYPASS_COUNT=$(jq '.summary.bypasses // .summary.findings // ([.results[]?] | length) // 0' "${INPUT_OUTPUT}" 2>/dev/null || echo "0")
        ;;
    esac
  else
    # Fallback without jq: grep-based approximation for SARIF
    echo "::notice::jq not found — using grep fallback for SARIF parsing (job summary will be less detailed). Install jq for richer output."
    if [[ "${INPUT_FORMAT}" == "sarif" ]]; then
      BYPASS_COUNT=$(grep -c '"ruleId"' "${INPUT_OUTPUT}" 2>/dev/null || echo "0")
    fi
  fi
fi

# Build summary line
if [[ ${BYPASS_COUNT} -gt 0 ]]; then
  SUMMARY="WAFtester found ${BYPASS_COUNT} WAF bypass(es) against ${INPUT_TARGET}"
  if [[ -n "${FINDING_DETAILS}" ]]; then
    SUMMARY="${SUMMARY} [${FINDING_DETAILS}]"
  fi
elif [[ ${SCAN_EXIT_CODE} -eq ${EXIT_SUCCESS} ]]; then
  SUMMARY="WAFtester scan completed — no WAF bypasses detected against ${INPUT_TARGET}"
else
  SUMMARY="WAFtester scan completed with exit code ${SCAN_EXIT_CODE}: $(exit_code_description "${SCAN_EXIT_CODE}")"
fi

# ============================================================================
# Set GitHub outputs
# ============================================================================

{
  echo "exit-code=${SCAN_EXIT_CODE}"
  echo "bypass-count=${BYPASS_COUNT}"
  echo "summary=${SUMMARY}"
} >> "${GITHUB_OUTPUT}"

if [[ -f "${INPUT_OUTPUT}" ]]; then
  echo "sarif-file=${INPUT_OUTPUT}" >> "${GITHUB_OUTPUT}"
fi

# ============================================================================
# Write job summary (rich Markdown in Actions UI)
# ============================================================================

# Determine status display
STATUS_ICON="✅"
STATUS_TEXT="Clean — No Bypasses"
if [[ ${BYPASS_COUNT} -gt 0 ]]; then
  STATUS_ICON="🔴"
  STATUS_TEXT="${BYPASS_COUNT} WAF Bypass(es) Found"
elif [[ ${SCAN_EXIT_CODE} -ne 0 ]]; then
  STATUS_ICON="⚠️"
  STATUS_TEXT="$(exit_code_description "${SCAN_EXIT_CODE}")"
fi

{
  echo "## ${STATUS_ICON} WAFtester Results"
  echo ""
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| **Status** | ${STATUS_TEXT} |"
  echo "| **Target** | \`${INPUT_TARGET}\` |"
  echo "| **Scan Type** | \`${INPUT_SCAN_TYPE}\` |"
  echo "| **WAF Bypasses** | **${BYPASS_COUNT}** |"
  echo "| **Exit Code** | \`${SCAN_EXIT_CODE}\` — $(exit_code_description "${SCAN_EXIT_CODE}") |"
  if [[ -f "${INPUT_OUTPUT}" ]]; then
    echo "| **Output** | \`${INPUT_OUTPUT}\` |"
  fi
  echo ""

  # Show top findings breakdown if any
  if [[ -n "${FINDING_DETAILS}" ]]; then
    echo "### Finding Categories"
    echo ""
    echo "| Category | Count |"
    echo "|----------|-------|"

    # Parse finding details into table rows
    IFS=',' read -ra CATEGORIES <<< "${FINDING_DETAILS}"
    for cat in "${CATEGORIES[@]}"; do
      cat_name=$(echo "${cat}" | sed 's/:.*//' | xargs)
      cat_count=$(echo "${cat}" | sed 's/.*://' | xargs)
      echo "| \`${cat_name}\` | ${cat_count} |"
    done
    echo ""
  fi

  # Remediation guidance for findings
  if [[ ${BYPASS_COUNT} -gt 0 ]]; then
    echo "<details>"
    echo "<summary>📋 What to do next</summary>"
    echo ""
    echo "1. **Review findings** in the [Security tab](../../security/code-scanning) (SARIF auto-uploaded)"
    echo "2. **Investigate bypasses** — each finding shows the exact payload that bypassed the WAF"
    echo "3. **Update WAF rules** — tighten rules for the bypassed attack categories"
    echo "4. **Re-scan** — run WAFtester again to verify your fixes work"
    echo ""
    echo "See [WAFtester documentation](https://github.com/waftester/waftester) for detailed remediation guidance."
    echo ""
    echo "</details>"
  fi

  # Configuration reference
  echo "<details>"
  echo "<summary>⚙️ Configuration</summary>"
  echo ""
  echo "| Setting | Value |"
  echo "|---------|-------|"
  echo "| fail-on-bypass | \`${INPUT_FAIL_ON_BYPASS}\` |"
  echo "| fail-on-error | \`${INPUT_FAIL_ON_ERROR}\` |"
  echo "| format | \`${INPUT_FORMAT}\` |"
  if [[ -n "${INPUT_ARGS}" ]]; then
    echo "| extra args | \`${INPUT_ARGS}\` |"
  fi
  echo ""
  echo "Command: \`${CMD[*]}\`"
  echo ""
  echo "</details>"
} >> "${GITHUB_STEP_SUMMARY}"

# ============================================================================
# Exit logic — map WAFtester exit codes to action pass/fail
# ============================================================================

# Exit 0: Success — always pass
if [[ ${SCAN_EXIT_CODE} -eq ${EXIT_SUCCESS} ]]; then
  exit 0
fi

# Exit 1: Bypasses detected — configurable via fail-on-bypass
if [[ ${SCAN_EXIT_CODE} -eq ${EXIT_BYPASSES_DETECTED} ]]; then
  if [[ "${INPUT_FAIL_ON_BYPASS}" == "true" ]]; then
    echo "::error::WAFtester found ${BYPASS_COUNT} WAF bypass(es) — failing step (fail-on-bypass=true)"
    exit 1
  else
    echo "::warning::WAFtester found ${BYPASS_COUNT} WAF bypass(es) — step passes (fail-on-bypass=false). Set fail-on-bypass: true to enforce."
    exit 0
  fi
fi

# Exit 2-6: Infrastructure/config errors — configurable via fail-on-error
if [[ ${SCAN_EXIT_CODE} -ge 2 && ${SCAN_EXIT_CODE} -le 6 ]]; then
  if [[ "${INPUT_FAIL_ON_ERROR}" == "true" ]]; then
    echo "::error::WAFtester exited with code ${SCAN_EXIT_CODE}: $(exit_code_description "${SCAN_EXIT_CODE}")"
    exit "${SCAN_EXIT_CODE}"
  else
    echo "::warning::WAFtester exited with code ${SCAN_EXIT_CODE}: $(exit_code_description "${SCAN_EXIT_CODE}") — step passes (fail-on-error=false)"
    exit 0
  fi
fi

# Unknown exit code — always fail
echo "::error::WAFtester exited with unexpected code ${SCAN_EXIT_CODE}"
exit "${SCAN_EXIT_CODE}"

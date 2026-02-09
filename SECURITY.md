# Security Policy

## Reporting Vulnerabilities

**For vulnerabilities in the WAFtester scanner/CLI**, report
to the main project:
[waftester/waftester Security Policy](https://github.com/waftester/waftester/security/policy)

**For vulnerabilities specific to this GitHub Action**
(install.sh, entrypoint.sh, action.yml), report via:

- **Email:** <security@waftester.com>
- **GitHub:** [Private vulnerability report](https://github.com/waftester/waftester-action/security/advisories/new)

## Response

- Acknowledgment within 48 hours.
- Fix or mitigation within 7 days for critical issues.
- Public disclosure after fix is released.

## Scope

In scope for **this action repository**:

- Shell injection in `install.sh` or `entrypoint.sh`
- Checksum verification bypass
- Insecure file permissions during install
- Token/secret exposure in logs or outputs
- Supply chain risks (binary download integrity)

Out of scope (report to main project instead):

- Scanner logic, payload handling, SARIF generation
- False positives/negatives in WAF detection
- License questions

## Supported Versions

| Version | Supported |
|---------|-----------|
| v1.x.x | Yes |
| < v1.0.0 | No |

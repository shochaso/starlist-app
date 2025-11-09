#!/usr/bin/env bash
set -euo pipefail

echo "== Extended Security Runner =="

SKIP_TRIVY_CONFIG="${SKIP_TRIVY_CONFIG:-1}"  # 1=skip, 0=run

HAS_GITLEAKS=$(command -v gitleaks >/dev/null && echo 1 || echo 0)
HAS_SEMGREP=$(command -v semgrep  >/dev/null && echo 1 || echo 0)
HAS_TRIVY=$(command -v trivy      >/dev/null && echo 1 || echo 0)
echo "[env] gitleaks=$HAS_GITLEAKS semgrep=$HAS_SEMGREP trivy=$HAS_TRIVY skip_trivy_config=$SKIP_TRIVY_CONFIG"

EXIT_CODE=0

if [ "$HAS_GITLEAKS" = "1" ]; then
  echo ">> gitleaks: scanning repo"
  gitleaks detect --no-banner --redact --source . --report-path gitleaks-report.json || EXIT_CODE=$?
else
  echo "!! gitleaks not found (skipping)."
fi

if [ "$HAS_SEMGREP" = "1" ]; then
  echo ">> semgrep: .semgrep.yml"
  semgrep --error --config ./.semgrep.yml --metrics=off --output semgrep.sarif --format sarif || EXIT_CODE=$?
else
  echo "!! semgrep not found (skipping)."
fi

if [ "$HAS_TRIVY" = "1" ]; then
  echo ">> trivy fs scan (CRITICAL,HIGH)"
  trivy fs --quiet --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore --format sarif --output trivy-results.sarif . || EXIT_CODE=$?
  if [ "$SKIP_TRIVY_CONFIG" = "0" ]; then
    echo ">> trivy config scan"
    trivy config --quiet --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore --format sarif --output trivy-config.sarif . || EXIT_CODE=$?
  else
    echo ">> trivy config scan SKIPPED (SKIP_TRIVY_CONFIG=1)"
  fi
else
  echo "!! trivy not found (skipping)."
fi

if [ "$EXIT_CODE" = "0" ]; then
  echo "== Extended Security: OK =="
else
  echo "== Extended Security: FAILED (exit=$EXIT_CODE) =="
fi
exit "$EXIT_CODE"

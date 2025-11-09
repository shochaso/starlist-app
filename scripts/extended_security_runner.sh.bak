#!/usr/bin/env bash
set -euo pipefail

echo "== Extended Security Runner =="

# 0) 環境チェック
HAS_GITLEAKS=$(command -v gitleaks >/dev/null && echo 1 || echo 0)
HAS_SEMGREP=$(command -v semgrep >/dev/null && echo 1 || echo 0)
HAS_TRIVY=$(command -v trivy >/dev/null && echo 1 || echo 0)

echo "[env] gitleaks=$HAS_GITLEAKS semgrep=$HAS_SEMGREP trivy=$HAS_TRIVY"

EXIT_CODE=0

# 1) gitleaks（なければスキップだがCI評価に影響させない）
if [ "$HAS_GITLEAKS" = "1" ]; then
  echo ">> gitleaks: scanning repo"
  gitleaks detect --no-banner --redact --source . --report-path gitleaks-report.json || EXIT_CODE=$?
else
  echo "!! gitleaks not found (skipping). Install: brew install gitleaks || curl -sSL https://git.io/gitleaks | bash"
fi

# 2) semgrep（ルールファイルは .semgrep.yml）
if [ "$HAS_SEMGREP" = "1" ]; then
  echo ">> semgrep: scanning with .semgrep.yml"
  semgrep --error --config ./.semgrep.yml --metrics=off || EXIT_CODE=$?
else
  echo "!! semgrep not found (skipping). Install: pipx install semgrep || pip install semgrep"
fi

# 3) trivy（FSスキャン＋設定スキャンの最小構成）
if [ "$HAS_TRIVY" = "1" ]; then
  echo ">> trivy fs scan"
  trivy fs --quiet --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore . || EXIT_CODE=$?
  echo ">> trivy config scan (IaC/CI/CD)"
  trivy config --quiet --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore . || EXIT_CODE=$?
else
  echo "!! trivy not found (skipping). Install: brew install trivy || sudo apt-get install -y trivy"
fi

# 4) まとめ
if [ "$EXIT_CODE" = "0" ]; then
  echo "== Extended Security: OK =="
else
  echo "== Extended Security: FAILED (exit=$EXIT_CODE) =="
fi
exit "$EXIT_CODE"

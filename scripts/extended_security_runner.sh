#!/usr/bin/env bash
# scripts/extended_security_runner.sh
set -euo pipefail

TS="$(TZ='Asia/Tokyo' date +%Y%m%d-%H%M%S)"
LOG_DIR="logs/security_${TS}"
REPORT_MD="docs/reports/OPS-SUMMARY-LOGS.md"
mkdir -p "$LOG_DIR" "docs/reports"

: "${DOCKER_CONFIG:=$(mktemp -d)}"
export DOCKER_CONFIG
: "${TRIVY_EXTRA_ARGS:=--skip-dirs apps/flutter --skip-dirs vendor --skip-dirs node_modules}"

note(){ echo "[$(date +%H:%M:%S)] $*"; }

note "env check"
command -v deno >/dev/null 2>&1 || { echo "deno not found"; exit 1; }
command -v semgrep >/dev/null 2>&1 || echo "WARN: semgrep not found (skip)"
command -v trivy   >/dev/null 2>&1 || echo "WARN: trivy not found (skip)"
command -v npx     >/dev/null 2>&1 || echo "WARN: npx not found (skip)"

note "deno fmt --check"
if deno fmt --check supabase/functions scripts tests >"$LOG_DIR/deno_fmt.log" 2>&1; then DENO_FMT="OK"; else DENO_FMT="FAIL"; fi
note "deno lint"
if deno lint supabase/functions scripts tests >"$LOG_DIR/deno_lint.log" 2>&1; then DENO_LINT="OK"; else DENO_LINT="FAIL"; fi
note "deno test -A"
if deno test -A supabase/functions/_tests >"$LOG_DIR/deno_test.log" 2>&1; then DENO_TEST="OK"; else DENO_TEST="FAIL"; fi

if command -v semgrep >/dev/null 2>&1; then
  note "semgrep"
  if semgrep --config ./.semgrep.yml >"$LOG_DIR/semgrep.log" 2>&1; then SEMGREP="OK"; else SEMGREP="FAIL"; fi
else SEMGREP="SKIP"; fi

if command -v trivy >/dev/null 2>&1; then
  note "trivy fs"
  TRIVY_EXTRA_ARGS="${TRIVY_EXTRA_ARGS:-}"
  TRIVY_DB_REPOSITORY="${TRIVY_DB_REPOSITORY:-ghcr.io/aquasecurity/trivy-db:2}" \
  TRIVY_JAVA_DB_REPOSITORY="${TRIVY_JAVA_DB_REPOSITORY:-ghcr.io/aquasecurity/trivy-java-db:1}" \
  trivy fs --exit-code 1 --ignore-unfixed --severity CRITICAL,HIGH \
    ${TRIVY_EXTRA_ARGS} . >"$LOG_DIR/trivy.log" 2>&1 \
  && TRIVY="OK" || TRIVY="FAIL"
else TRIVY="SKIP"; fi

if [ -n "${BASE_URL:-}" ]; then
  note "playwright (BASE_URL=$BASE_URL)"
  npx playwright install --with-deps >"$LOG_DIR/playwright_install.log" 2>&1 || true
  if BASE_URL="$BASE_URL" npx playwright test tests/e2e/csp.spec.ts >"$LOG_DIR/playwright.log" 2>&1; then PW="OK"; else PW="FAIL"; fi
else PW="SKIP"; fi

note "append summary"
{
  echo "### セキュリティ実行サマリ（${TS:-unknown}）"
  echo "- deno fmt: $DENO_FMT"
  echo "- deno lint: $DENO_LINT"
  echo "- deno test: $DENO_TEST"
  echo "- semgrep: $SEMGREP"
  echo "- trivy: $TRIVY"
  echo "- playwright: $PW"
  for f in deno_fmt deno_lint deno_test semgrep trivy playwright; do
    LOG="$LOG_DIR/${f}.log"; [ -f "$LOG" ] || continue
    echo ""
    echo "<details><summary><code>${f}.log</code>（先頭20行）</summary>"
    echo ""
    echo '```txt'
    head -n 20 "$LOG"
    echo '```'
    echo "</details>"
    echo ""
  done
  echo ""
} >>"$REPORT_MD"

note "done. logs=$LOG_DIR report=$REPORT_MD"

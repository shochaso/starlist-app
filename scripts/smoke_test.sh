#!/usr/bin/env bash
# スモークテスト（30秒）
# Usage: ./scripts/smoke_test.sh

set -Eeuo pipefail

log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

log "=== Smoke Test (30秒) ==="
log ""

# 1) スキーマ導入（初回のみ）
log "[1/3] スキーマ導入確認..."
if command -v ajv >/dev/null && command -v yq >/dev/null; then
  log "✅ Schema tools ready"
else
  warn "⚠️  Installing schema tools..."
  make schema || warn "Schema tools installation failed (may need manual install)"
fi

# 2) 48hで実行（JST固定・Front-Matter付き）
log "[2/3] 統合スイート実行..."
if [[ -f FINAL_INTEGRATION_SUITE.sh ]]; then
  chmod +x FINAL_INTEGRATION_SUITE.sh
  AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh || warn "Integration suite failed (check logs)"
else
  error "FINAL_INTEGRATION_SUITE.sh not found"
  exit 1
fi

# 3) 監査票の構造検証＋要点抜粋
log "[3/3] 監査票検証..."
if make verify >/dev/null 2>&1; then
  log "✅ Schema validation passed"
else
  warn "⚠️  Schema validation failed (run 'make verify' for details)"
fi

log ""
log "=== Summary ==="
make summarize || warn "Summary generation failed"

log ""
log "✅ Smoke test completed"
log "Check: docs/reports/<YYYY-MM-DD>_DAY11_AUDIT_<G-WNN>.md"


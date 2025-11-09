#!/usr/bin/env bash
# scripts/ops/create-audit-bundle.sh
# 監査用バンドル（1コマンドでZIP化）

set -euo pipefail

TS=$(date +%Y%m%d-%H%M%S)
AUDIT_DIR="out/audit"
BUNDLE_FILE="${AUDIT_DIR}/weekly-proof-${TS}.zip"

mkdir -p "$AUDIT_DIR"

echo "📦 Creating audit bundle: $BUNDLE_FILE"

zip -r "$BUNDLE_FILE" \
  out/logs/ \
  docs/reports/DAY12_SOT_DIFFS.md \
  docs/overview/STARLIST_OVERVIEW.md \
  docs/security/SEC_HARDENING_ROADMAP.md \
  2>/dev/null || {
  echo "⚠️  Some files may be missing, but bundle created"
}

if [ -f "$BUNDLE_FILE" ]; then
  ls -lh "$BUNDLE_FILE"
  echo "✅ Audit bundle created: $BUNDLE_FILE"
else
  echo "❌ Failed to create audit bundle"
  exit 1
fi


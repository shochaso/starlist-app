#!/usr/bin/env bash
# scripts/ops/verify-sot-ledger.sh
# SOT台帳の整合性チェック（壊れたら即Fail）

set -euo pipefail

f="docs/reports/DAY12_SOT_DIFFS.md"

if [ ! -f "$f" ]; then
  echo "❌ SOT ledger not found: $f"
  exit 1
fi

# 基本構造チェック
if ! grep -q -i 'day12' "$f"; then
  echo "❌ SOT ledger missing Day12 reference"
  exit 1
fi

# PR URL形式チェック
if ! grep -E -q 'https://github.com/[^/]+/[^/]+/pull/[0-9]+' "$f"; then
  echo "❌ SOT ledger missing valid PR URLs"
  exit 1
fi

# JST時刻表記チェック
if ! grep -E -q '\(20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} JST\)' "$f"; then
  echo "⚠️  SOT ledger may not have JST timestamps (non-fatal)"
fi

# マージ情報の存在チェック
if ! grep -E -q 'Merged At|Merge SHA' "$f"; then
  echo "⚠️  SOT ledger may be missing merge information (non-fatal)"
fi

echo "✅ SOT ledger looks good."
exit 0


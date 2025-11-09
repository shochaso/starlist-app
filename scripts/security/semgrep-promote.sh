#!/usr/bin/env bash
# scripts/security/semgrep-promote.sh
# SemgrepルールをWARNING→ERRORに段階復帰するヘルパースクリプト（強化版）
# Usage: ./scripts/security/semgrep-promote.sh <rule-id-1> [rule-id-2 ...]

set -euo pipefail

SEMGREP_FILE=".semgrep.yml"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <rule-id-1> [rule-id-2 ...]"
  echo "Example: $0 deno-fetch-no-http no-hardcoded-secret"
  exit 1
fi

rules=("$@")
BR="chore/semgrep-promote-$(date +%Y%m%d-%H%M%S)"

# ブランチ作成
git checkout -b "$BR" 2>/dev/null || {
  echo "⚠️  Branch $BR already exists or git error"
  exit 1
}

for r in "${rules[@]}"; do
  echo "🔄 Promoting rule: $r (WARNING → ERROR)"
  
  # perlでルール単位に処理（より確実）
  if command -v perl >/dev/null 2>&1; then
    perl -0777 -pe "BEGIN{undef \$/} s/(id:\\s*$r[\s\S]*?severity:\\s*)WARNING/\$1ERROR/gi" -i "$SEMGREP_FILE"
  else
    # perlがない場合はsedで代替
    sed -i.bak "s/\(id:\s*$r[^}]*severity:\s*\)WARNING/\1ERROR/gi" "$SEMGREP_FILE" 2>/dev/null || {
      echo "⚠️  Could not update rule $r (may need perl)"
      continue
    }
  fi
done

# 変更確認
if ! git diff --quiet "$SEMGREP_FILE"; then
  git add "$SEMGREP_FILE"
  git commit -m "sec(semgrep): promote to ERROR (${rules[*]})"
  
  echo "📤 Pushing branch: $BR"
  git push -u origin "$BR" || {
    echo "⚠️  Failed to push branch $BR"
    git checkout - 2>/dev/null || true
    exit 1
  }
  
  echo "✅ Creating PR..."
  gh pr create --fill --title "sec: semgrep promote ERROR (${rules[*]})" \
    --body "段階復帰（WARNING → ERROR）。

対象ルール: ${rules[*]}

DoD: CI green

関連Issue: #37" || {
    echo "⚠️  Failed to create PR"
    exit 1
  }
  
  echo "✅ PR created: $BR"
else
  echo "⚠️  No changes detected (rules may already be ERROR or not found)"
  git checkout - 2>/dev/null || true
fi

echo ""
echo "✅ Semgrep promotion completed"


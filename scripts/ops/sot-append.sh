#!/usr/bin/env bash
# scripts/ops/sot-append.sh
# SOT (Source of Truth) 差分ファイルにPR情報を追記するスクリプト
set -euo pipefail

SOT_FILE="docs/reports/DAY12_SOT_DIFFS.md"
JST_NOW=$(TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S %Z')

# 引数チェック
if [ $# -eq 0 ]; then
  echo "Usage: $0 <PR_NUMBER> [PR_NUMBER2 ...]"
  echo "Example: $0 30 31 32 33"
  exit 1
fi

# SOTファイルが存在しない場合は作成
if [ ! -f "$SOT_FILE" ]; then
  mkdir -p "$(dirname "$SOT_FILE")"
  cat > "$SOT_FILE" <<'EOF'
Status:: implemented
Source-of-Truth:: docs/reports/DAY12_SOT_DIFFS.md
Spec-State:: 確定済み（実装履歴・CodeRefs）
Last-Updated:: 2025-11-09

# DAY12_SOT_DIFFS — Day12 PRs Implementation Reality vs Spec

Status: implemented ✅  
Last-Updated: 2025-11-09  
Source-of-Truth: GitHub PRs (#30, #31, #32, #33)

---

## 🚀 STARLIST Day12 PR情報

### 📊 マージ済みPR一覧

EOF
fi

# 各PRの情報を取得して追記（重複防止付き）
for PR_NUM in "$@"; do
  echo "📝 Processing PR #$PR_NUM..."
  
  PR_INFO=$(gh pr view "$PR_NUM" --json number,title,mergedAt,mergeCommit,url,headRefName --jq '{
    number,
    title,
    mergedAt,
    mergeCommit: .mergeCommit.oid,
    url,
    branch: .headRefName
  }' 2>/dev/null || echo '{}')
  
  if [ "$PR_INFO" = "{}" ]; then
    echo "⚠️  PR #$PR_NUM not found or not accessible"
    continue
  fi
  
  PR_TITLE=$(echo "$PR_INFO" | jq -r '.title // "N/A"')
  PR_URL=$(echo "$PR_INFO" | jq -r '.url // "N/A"')
  PR_MERGED=$(echo "$PR_INFO" | jq -r '.mergedAt // "N/A"')
  PR_SHA=$(echo "$PR_INFO" | jq -r '.mergeCommit // "N/A"')
  PR_BRANCH=$(echo "$PR_INFO" | jq -r '.branch // "N/A"')
  
  # 重複チェック: PR_URLが既に存在する場合はスキップ
  if grep -q "$PR_URL" "$SOT_FILE" 2>/dev/null; then
    echo "⏭️  PR #$PR_NUM ($PR_URL) already recorded, skipping..."
    continue
  fi
  
  # JST時刻に変換（確実にJSTで記録）
  if [ "$PR_MERGED" != "N/A" ] && [ "$PR_MERGED" != "null" ]; then
    # macOS/BSD date コマンド対応
    if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$PR_MERGED" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
      PR_MERGED_JST=$(TZ='Asia/Tokyo' date -j -f "%Y-%m-%dT%H:%M:%SZ" "$PR_MERGED" '+%Y-%m-%d %H:%M:%S JST')
    # GNU date コマンド対応
    elif date -d "$PR_MERGED" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
      PR_MERGED_JST=$(TZ='Asia/Tokyo' date -d "$PR_MERGED" '+%Y-%m-%d %H:%M:%S JST')
    else
      PR_MERGED_JST="$PR_MERGED (UTC)"
    fi
  else
    PR_MERGED_JST="N/A"
  fi
  
  # Recorded Atも確実にJSTで記録
  RECORDED_JST=$(TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S JST')
  
  # SOTファイルに追記
  cat >> "$SOT_FILE" <<EOF

### PR #$PR_NUM: $PR_TITLE

- **URL**: $PR_URL
- **Merged At**: $PR_MERGED_JST
- **Merge SHA**: \`$PR_SHA\`
- **Branch**: \`$PR_BRANCH\`
- **Recorded At**: $RECORDED_JST

EOF
done

# 最終更新時刻を更新
sed -i.bak "s/^Last-Updated::.*/Last-Updated:: $(date '+%Y-%m-%d')/" "$SOT_FILE" 2>/dev/null || \
sed -i "s/^Last-Updated::.*/Last-Updated:: $(date '+%Y-%m-%d')/" "$SOT_FILE" 2>/dev/null || true

rm -f "${SOT_FILE}.bak" 2>/dev/null || true

echo "✅ SOT file updated: $SOT_FILE"
echo "📋 Recorded PRs: $*"


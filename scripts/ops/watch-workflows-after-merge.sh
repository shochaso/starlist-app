#!/usr/bin/env bash
# scripts/ops/watch-workflows-after-merge.sh
# main反映後のワークフロー起動＆ウォッチ用一括コマンド
set -euo pipefail

note() { echo "[$(date +%H:%M:%S)] $*"; }

note "🚀 Starting workflow watch after main merge"

# 1) ワークフロー起動
note "📋 Step 1: Triggering workflows"
gh workflow run weekly-routine.yml || echo "⚠️  weekly-routine.yml trigger failed"
gh workflow run allowlist-sweep.yml || echo "⚠️  allowlist-sweep.yml trigger failed"
gh workflow run extended-security.yml || echo "⚠️  extended-security.yml trigger failed"

sleep 10

# 2) RUN_ID取得
note "📋 Step 2: Getting RUN_IDs"
WEEKLY_RID=$(gh run list --workflow weekly-routine.yml --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")
ALLOWLIST_RID=$(gh run list --workflow allowlist-sweep.yml --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")
EXTSEC_RID=$(gh run list --workflow extended-security.yml --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")

echo "WEEKLY_RID: $WEEKLY_RID"
echo "ALLOWLIST_RID: $ALLOWLIST_RID"
echo "EXTSEC_RID: $EXTSEC_RID"

# 3) ウォッチ（最大8回×15秒 = 約2分）
note "📋 Step 3: Watching workflows (max 2 minutes)"
for i in {1..8}; do
  echo ""
  echo "== Tick $i =="
  
  if [ -n "$WEEKLY_RID" ] && [ "$WEEKLY_RID" != "null" ]; then
    gh run view "$WEEKLY_RID" --json status,conclusion --jq '"weekly-routine: \(.status) \(.conclusion // "N/A")"' 2>/dev/null || true
  fi
  
  if [ -n "$ALLOWLIST_RID" ] && [ "$ALLOWLIST_RID" != "null" ]; then
    gh run view "$ALLOWLIST_RID" --json status,conclusion --jq '"allowlist-sweep: \(.status) \(.conclusion // "N/A")"' 2>/dev/null || true
  fi
  
  if [ -n "$EXTSEC_RID" ] && [ "$EXTSEC_RID" != "null" ]; then
    gh run view "$EXTSEC_RID" --json status,conclusion --jq '"extended-security: \(.status) \(.conclusion // "N/A")"' 2>/dev/null || true
  fi
  
  sleep 15
done

# 4) 最終状態確認
note "📋 Step 4: Final status check"
gh run list --workflow weekly-routine.yml --limit 1
gh run list --workflow allowlist-sweep.yml --limit 1
gh run list --workflow extended-security.yml --limit 1

# 5) PR #22のチェック状態確認
note "📋 Step 5: PR #22 checks status"
gh pr view 22 --json statusCheckRollup --jq '.statusCheckRollup[]? | "\(.context): \(.state)"' 2>/dev/null || echo "PR #22 checks unavailable"

note "✅ Workflow watch completed"


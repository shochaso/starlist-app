#!/bin/bash
# Day11 失敗時の即時復旧テンプレート
# Usage: ./DAY11_RECOVERY_TEMPLATE.sh

set -euo pipefail

log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

: "${SUPABASE_URL:?Set SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY}"

log "=== Day11 失敗時の即時復旧テンプレート ==="
log ""

# 1) Slackに二重投稿が無いか（UI確認のみ／API権限が無ければスキップ）
log "📋 1) Slack到達確認"
log "Check Slack #ops-monitor: single message only"
log "（UI確認のみ。API権限が無ければスキップ）"
log ""

# 2) Edge Function の直近ログ
log "📋 2) Edge Function の直近ログ"
PROJECT_REF=$(basename "$SUPABASE_URL" .supabase.co)
if command -v supabase >/dev/null 2>&1; then
  log "Supabase Functions logs (last 2h):"
  supabase functions logs --project-ref "$PROJECT_REF" --function-name "ops-slack-summary" --since 2h | tail -n 200 || warn "ログ取得に失敗しました"
else
  warn "Supabase CLI が見つかりません"
  log "Supabase Dashboard → Edge Functions → ops-slack-summary → Logs で確認してください"
fi
log ""

# 3) ビュー再集計（DB側で最新化。READ ONLYでも安全な SELECT で傾向確認）
log "📋 3) ビュー再集計確認"
if [ -n "${DATABASE_URL:-}" ]; then
  log "v_ops_notify_stats の最新3件:"
  psql "$DATABASE_URL" -c "select * from v_ops_notify_stats order by day desc limit 3;" || warn "DB接続に失敗しました"
else
  warn "DATABASE_URL が設定されていません"
  log "Supabase Dashboard → SQL Editor で以下を実行:"
  echo ""
  cat <<'SQL'
select * from v_ops_notify_stats order by day desc limit 3;
SQL
fi
log ""

# 4) Secretsの再読込み（GH Actionsであれば再設定、ローカルなら再export）
log "📋 4) Secrets確認"
log "現在の環境変数:"
log "  SUPABASE_URL: ${SUPABASE_URL}"
log "  SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
log ""
log "再設定が必要な場合:"
log "  export SUPABASE_URL='https://<ref>.supabase.co'"
log "  export SUPABASE_ANON_KEY='<anon>'"
log ""

# 直近のsendを無効化対象としてマーキング（例: 冪等ログへ記録）
log "Marking recent send as invalid (if needed)..."
mkdir -p logs/day11
echo "$(date -Iseconds) mark send as invalid (manual)" >> logs/day11/recovery_marks.log

# Slack再送 or 削除はポリシーに従い運用側で判断（自動削除は原則しない）
PERMALINK_FILE=".day11_cache/permalink.txt"
if [ -f "$PERMALINK_FILE" ]; then
  PERMALINK=$(cat "$PERMALINK_FILE")
  log "Manual action required: Slack message at $PERMALINK"
else
  warn "Permalink not found in cache"
fi

log ""
log "=== 復旧テンプレート完了 ==="
log ""
log "📖 詳細な復旧手順:"
log "  DAY11_GO_LIVE_GUIDE.md のトラブルシューティングセクションを参照"
log ""
log "📋 典型失敗の切り分け表:"
log ""
log "  - Permalink未取得:"
log "    → logs/day11/*_send.json に Slack Webhook エラー/429/5xx を確認"
log "    → リトライ（指数バックオフ）、Webhook URL/Secret再確認"
log ""
log "  - Stripe抽出0件:"
log "    → イベントタイプ/Lookback不足/テスト環境を確認"
log "    → AUDIT_LOOKBACK_HOURS を+72h、STRIPE_API_KEY スコープ確認"
log ""
log "  - DB監査0出力:"
log "    → 接続/権限問題を確認"
log "    → supabase login や SUPABASE_ACCESS_TOKEN を再供給"
log ""


# Usage: ./DAY11_RECOVERY_TEMPLATE.sh

set -euo pipefail

log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

: "${SUPABASE_URL:?Set SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY}"

log "=== Day11 失敗時の即時復旧テンプレート ==="
log ""

# 1) Slackに二重投稿が無いか（UI確認のみ／API権限が無ければスキップ）
log "📋 1) Slack到達確認"
log "Check Slack #ops-monitor: single message only"
log "（UI確認のみ。API権限が無ければスキップ）"
log ""

# 2) Edge Function の直近ログ
log "📋 2) Edge Function の直近ログ"
PROJECT_REF=$(basename "$SUPABASE_URL" .supabase.co)
if command -v supabase >/dev/null 2>&1; then
  log "Supabase Functions logs (last 2h):"
  supabase functions logs --project-ref "$PROJECT_REF" --function-name "ops-slack-summary" --since 2h | tail -n 200 || warn "ログ取得に失敗しました"
else
  warn "Supabase CLI が見つかりません"
  log "Supabase Dashboard → Edge Functions → ops-slack-summary → Logs で確認してください"
fi
log ""

# 3) ビュー再集計（DB側で最新化。READ ONLYでも安全な SELECT で傾向確認）
log "📋 3) ビュー再集計確認"
if [ -n "${DATABASE_URL:-}" ]; then
  log "v_ops_notify_stats の最新3件:"
  psql "$DATABASE_URL" -c "select * from v_ops_notify_stats order by day desc limit 3;" || warn "DB接続に失敗しました"
else
  warn "DATABASE_URL が設定されていません"
  log "Supabase Dashboard → SQL Editor で以下を実行:"
  echo ""
  cat <<'SQL'
select * from v_ops_notify_stats order by day desc limit 3;
SQL
fi
log ""

# 4) Secretsの再読込み（GH Actionsであれば再設定、ローカルなら再export）
log "📋 4) Secrets確認"
log "現在の環境変数:"
log "  SUPABASE_URL: ${SUPABASE_URL}"
log "  SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
log ""
log "再設定が必要な場合:"
log "  export SUPABASE_URL='https://<ref>.supabase.co'"
log "  export SUPABASE_ANON_KEY='<anon>'"
log ""

# 直近のsendを無効化対象としてマーキング（例: 冪等ログへ記録）
log "Marking recent send as invalid (if needed)..."
mkdir -p logs/day11
echo "$(date -Iseconds) mark send as invalid (manual)" >> logs/day11/recovery_marks.log

# Slack再送 or 削除はポリシーに従い運用側で判断（自動削除は原則しない）
PERMALINK_FILE=".day11_cache/permalink.txt"
if [ -f "$PERMALINK_FILE" ]; then
  PERMALINK=$(cat "$PERMALINK_FILE")
  log "Manual action required: Slack message at $PERMALINK"
else
  warn "Permalink not found in cache"
fi

log ""
log "=== 復旧テンプレート完了 ==="
log ""
log "📖 詳細な復旧手順:"
log "  DAY11_GO_LIVE_GUIDE.md のトラブルシューティングセクションを参照"
log ""
log "📋 典型失敗の切り分け表:"
log ""
log "  - Permalink未取得:"
log "    → logs/day11/*_send.json に Slack Webhook エラー/429/5xx を確認"
log "    → リトライ（指数バックオフ）、Webhook URL/Secret再確認"
log ""
log "  - Stripe抽出0件:"
log "    → イベントタイプ/Lookback不足/テスト環境を確認"
log "    → AUDIT_LOOKBACK_HOURS を+72h、STRIPE_API_KEY スコープ確認"
log ""
log "  - DB監査0出力:"
log "    → 接続/権限問題を確認"
log "    → supabase login や SUPABASE_ACCESS_TOKEN を再供給"
log ""


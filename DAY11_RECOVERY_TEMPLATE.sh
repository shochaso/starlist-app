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

log "=== 復旧テンプレート完了 ==="
log ""
log "📖 詳細な復旧手順:"
log "  DAY11_GO_LIVE_GUIDE.md のトラブルシューティングセクションを参照"
log ""


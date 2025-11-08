#!/bin/bash
# Day11 ops-slack-summary デプロイ & 受け入れ確認 一括実行スクリプト
# Usage: ./DAY11_EXECUTE_ALL.sh

set -euo pipefail

echo "=== Day11 ops-slack-summary デプロイ & 受け入れ確認（一括実行） ==="
echo ""

# ① 環境変数をセット（Preflight）
echo "📋 ① 環境変数をセット（Preflight）"
echo ""

if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ Error: SUPABASE_URL is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Error: SUPABASE_ANON_KEY is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

# URL形式チェック
if ! echo "$SUPABASE_URL" | grep -qE '^https://[a-z0-9-]+\.supabase\.co$'; then
  echo "⚠️  Warning: SUPABASE_URL format may be incorrect"
  echo "   Expected: https://<project-ref>.supabase.co"
  echo "   Got: $SUPABASE_URL"
  read -p "続行しますか？ (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
else
  echo "✅ OK: URL形式"
fi

# jq の確認
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq がインストールされていません"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   macOSの場合: brew install jq"
  else
    echo "   Linuxの場合: sudo apt-get install jq または sudo yum install jq"
  fi
  read -p "jqをインストールしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq
    else
      echo "手動でインストールしてください"
      exit 1
    fi
  else
    echo "❌ jqが必要です。インストールしてから再実行してください"
    exit 1
  fi
fi

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""
echo "⚠️  Secrets確認（手動）:"
echo "  - Supabase Edge Function Secret: slack_webhook_ops_summary（小文字スネーク）"
echo "  - GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字スネーク）"
echo ""

# ② DBビューの作成確認
echo "📋 ② DBビューの作成確認"
echo ""
echo "⚠️  Supabase Dashboard → SQL Editor で以下を実行してください:"
echo "   supabase/migrations/20251108_v_ops_notify_stats.sql"
echo ""
read -p "DBビュー v_ops_notify_stats は作成済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ DBビューを作成してから再実行してください"
  exit 1
fi

# ③ Edge Functionデプロイ確認
echo ""
echo "📋 ③ Edge Functionデプロイ確認"
echo ""
echo "⚠️  Supabase Dashboard → Edge Functions → ops-slack-summary → Deploy"
echo "   Secrets設定: slack_webhook_ops_summary"
echo ""
read -p "Edge Function ops-slack-summary はデプロイ済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Edge Functionをデプロイしてから再実行してください"
  exit 1
fi

# ④ dryRun実行（自動検証つき）
echo ""
echo "📋 ④ dryRun実行（自動検証つき）"
echo ""

EDGE_URL="${SUPABASE_URL%/}/functions/v1/ops-slack-summary"
DRYRUN_URL="${EDGE_URL}?dryRun=true&period=14d"

echo "🚀 dryRun実行中..."
RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -X POST \
  "${DRYRUN_URL}" \
  -d '{}')

echo "${RESPONSE}" | tee /tmp/day11_dryrun.json | jq .

echo ""
echo "🔍 自動検証中..."

# ============ Validation Functions (impl-aligned) ============
validate_dryrun_json() {
  local f="$1"

  # 1) ベース必須
  if ! jq -e '
    .ok == true and
    (.stats | type) == "object" and
    (.weekly_summary | type) == "object" and
    (.message | type) == "string"
  ' "$f" >/dev/null 2>&1; then
    echo "❌ ベース必須フィールドが不正です"
    return 1
  fi
  echo "✅ ベース必須フィールドが正しいです"

  # 2) stats: 実装フィールド（数値必須）
  if ! jq -e '
    (.stats.mean_notifications      | type) == "number" and
    (.stats.std_dev                 | type) == "number" and
    (.stats.new_threshold           | type) == "number" and
    (.stats.critical_threshold      | type) == "number"
  ' "$f" >/dev/null 2>&1; then
    echo "❌ stats フィールドが不正です（数値必須）"
    return 1
  fi
  echo "✅ stats フィールドが正しいです（σ=0許容）"

  # 3) weekly_summary: 実装フィールド
  #    total系は number、変化率は string を許容（実装では文字列形式）
  if ! jq -e '
    ([.weekly_summary.normal,
      .weekly_summary.warning,
      .weekly_summary.critical] | all(type=="number")) and
    ([.weekly_summary.normal_change,
      .weekly_summary.warning_change,
      .weekly_summary.critical_change] | all(.==null or (type=="string")))
  ' "$f" >/dev/null 2>&1; then
    echo "❌ weekly_summary フィールドが不正です"
    return 1
  fi
  echo "✅ weekly_summary フィールドが正しいです（変化率は文字列形式）"

  # 4) 次回実行日時：message 内に含まれる想定
  #    「次回」「Next」の語を含むことだけをまず確認
  if ! jq -e '(.message | test("次回|Next"))' "$f" >/dev/null 2>&1; then
    echo "⚠️  message に次回実行日の記載がない可能性があります"
  else
    echo "✅ message に次回実行日が含まれています"
  fi

  # 5) 任意：message から YYYY-MM-DD と HH:MM を抽出して ISO 風に復元（jq 1.6+）
  #    失敗しても致命ではないため警告に留める
  local next_run_iso
  if next_run_iso="$(jq -r '
      .message
      | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
      | if . == {} then empty else (.date + "T" + .time + ":00+09:00") end
    ' "$f" 2>/dev/null)" && [[ -n "${next_run_iso:-}" ]]; then
    echo "[INFO] Next run (parsed): $next_run_iso"
  else
    echo "[WARN] Could not parse next run from .message (format OK なら問題ありません)"
  fi

  # 6) 統計の簡易レンジ検証（負のしきい値を弾く等）
  if jq -e '
    .stats.new_threshold      >= 0 and
    .stats.critical_threshold >= .stats.new_threshold
  ' "$f" >/dev/null 2>&1; then
    echo "[INFO] threshold range sanity: OK"
  else
    echo "[WARN] threshold range sanity check failed"
  fi

  echo "[INFO] dryRun JSON validation: OK ✅"
  return 0
}

validate_send_json() {
  local f="$1"
  if ! jq -e '.ok == true' "$f" >/dev/null 2>&1; then
    echo "❌ send JSON validation failed"
    return 1
  fi
  echo "[INFO] send JSON validation: OK ✅"
  return 0
}

# dryRun JSON検証実行
if ! validate_dryrun_json "/tmp/day11_dryrun.json"; then
  echo ""
  echo "❌ dryRun検証が失敗しました"
  exit 1
fi

echo ""
echo "📝 メッセージプレビュー:"
jq -r '.message' /tmp/day11_dryrun.json | head -15

echo ""
echo "✅ dryRun検証がすべて成功しました！"

# ⑤ 本送信テスト（Slack #ops-monitor）
echo ""
echo "📋 ⑤ 本送信テスト（Slack #ops-monitor）"
echo ""

read -p "本送信テストを実行しますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  本送信テストをスキップしました"
  echo "   後で手動実行してください:"
  echo "   curl -sS -X POST \"${EDGE_URL}?dryRun=false&period=14d\" \\"
  echo "     -H \"Authorization: Bearer \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"apikey: \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"Content-Type: application/json\" \\"
  echo "     -d '{}' | jq"
  exit 0
fi

SEND_URL="${EDGE_URL}?dryRun=false&period=14d"

echo "🚀 本送信実行中..."
SEND_RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -X POST \
  "${SEND_URL}" \
  -d '{}')

echo "${SEND_RESPONSE}" | tee /tmp/day11_send.json | jq .

# 本送信JSON検証実行
if ! validate_send_json "/tmp/day11_send.json"; then
  echo ""
  echo "❌ 本送信が失敗しました"
  exit 1
fi

echo ""
echo "✅ 本送信が成功しました"
echo "   Slack #ops-monitor チャンネルで確認してください"

# sent フィールドの確認
if jq -e '.sent == true' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "✅ Slackへの送信が完了しました"
elif jq -e '.sent == false' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "⚠️  Slackへの送信が失敗しました（エラーを確認してください）"
  jq -r '.error // empty' /tmp/day11_send.json
fi

# ⑥ ログ確認（成功トレイル）
echo ""
echo "📋 ⑥ ログ確認（成功トレイル）"
echo ""
echo "✅ ログ確認手順:"
echo "   - Supabase Functions Logs: Dashboard → Edge Functions → ops-slack-summary → Logs"
echo "   - HTTP 200 で完了していることを確認"
echo "   - 指数バックオフの再送が出ていないことを確認"
echo ""

# ⑦ 成果物の記録
echo ""
echo "📋 ⑦ 成果物の記録"
echo ""
echo "✅ 以下のファイルを更新してください:"
echo ""
echo "1. docs/reports/DAY11_SOT_DIFFS.md"
echo "   - dryRunレスポンス（/tmp/day11_dryrun.json）"
echo "   - 本送信レスポンス（/tmp/day11_send.json）"
echo "   - Slackスクショ（メッセージURL/時刻）"
echo ""
echo "2. docs/ops/OPS-MONITORING-V3-001.md"
echo "   - 稼働開始日"
echo "   - 運用責任者"
echo "   - 連絡先"
echo ""
echo "3. docs/Mermaid.md"
echo "   - Day11ノードをDay10直下に追加"
echo ""

# ⑧ Go/No-Go判定
echo ""
echo "📋 ⑧ Go/No-Go判定（4条件）"
echo ""
echo "✅ 判定基準:"
echo "   [ ] dryRun検証すべて合格"
echo "   [ ] Slack本送信が到達し体裁OK"
echo "   [ ] ログにエラー/再送痕跡なし"
echo "   [ ] 3文書更新（SOT/運用/Mermaid）"
echo ""
echo "すべての基準を満たしている場合、Day11は Go です！"
echo ""

# 実行結果サマリー
echo "=== 実行結果サマリー ==="
echo ""
echo "✅ dryRun結果: /tmp/day11_dryrun.json"
if [ -f /tmp/day11_send.json ]; then
  echo "✅ 本送信結果: /tmp/day11_send.json"
fi
echo ""
echo "📝 次のステップ:"
echo "   1. Slack #ops-monitor チャンネルで週次サマリを確認"
echo "   2. Supabase Functions Logs でログを確認"
echo "   3. 成果物を記録（DAY11_SOT_DIFFS.md など）"
echo "   4. Go/No-Go判定を実施"
echo ""


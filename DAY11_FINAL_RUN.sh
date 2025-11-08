#!/bin/bash
# Day11 最終ランブロック（確認→実行→記録を一気に流す）
# Usage: ./DAY11_FINAL_RUN.sh

set -euo pipefail

echo "=== Day11 最終ランブロック（確認→実行→記録） ==="
echo ""

# 0) 環境変数確認
echo "📋 0) 環境変数確認"
if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ SUPABASE_URL が設定されていません"
  echo ""
  echo "設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ SUPABASE_ANON_KEY が設定されていません"
  echo ""
  echo "設定してください:"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  exit 1
fi

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""

# 1) 仕上げチェック
echo "📋 1) 仕上げチェック"
chmod +x ./DAY11_FINAL_CHECK.sh ./DAY11_EXECUTE_ALL.sh ./DAY11_SMOKE_TEST.sh 2>/dev/null || true

if [ -f ./DAY11_FINAL_CHECK.sh ]; then
  echo "🚀 仕上げチェックスクリプトを実行します..."
  ./DAY11_FINAL_CHECK.sh
else
  echo "⚠️  DAY11_FINAL_CHECK.sh が見つかりません。スキップします。"
fi

echo ""

# 2) 一括実行
echo "📋 2) 一括実行（dryRun → 本送信 → 記録まで対話式で進みます）"
if [ -f ./DAY11_EXECUTE_ALL.sh ]; then
  echo "🚀 一括実行スクリプトを実行します..."
  ./DAY11_EXECUTE_ALL.sh
else
  echo "❌ DAY11_EXECUTE_ALL.sh が見つかりません"
  exit 1
fi

echo ""

# 3) スモークテスト（任意）
echo "📋 3) スモークテスト（任意：dryRun要点の再確認）"
read -p "スモークテストを実行しますか？ (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -f ./DAY11_SMOKE_TEST.sh ]; then
    ./DAY11_SMOKE_TEST.sh
  else
    echo "⚠️  DAY11_SMOKE_TEST.sh が見つかりません。スキップします。"
  fi
else
  echo "⚠️  スモークテストをスキップしました"
fi

echo ""

# 4) 重要ファイルの目視チェック
echo "📋 4) 重要ファイルの目視チェック（変更が入ったか）"
echo ""
CHANGED_FILES=$(git status --porcelain 2>/dev/null | grep -E "DAY11_SOT_DIFFS.md|OPS-MONITORING-V3-001.md|Mermaid.md" || true)

if [ -n "$CHANGED_FILES" ]; then
  echo "✅ 以下のファイルが変更されています:"
  echo "$CHANGED_FILES"
else
  echo "⚠️  重要ファイル（DAY11_SOT_DIFFS.md / OPS-MONITORING-V3-001.md / Mermaid.md）に変更がありません"
  echo "   手動で更新が必要な場合があります"
fi

echo ""

# 成功トレイルの確認ポイント
echo "📋 成功トレイル（合格の目印）"
echo ""
echo "✅ 確認ポイント:"
echo "  [ ] dryRun: validate_dryrun_json が OK（stats / weekly_summary / message 一致）"
echo "  [ ] 本送信: validate_send_json が OK、Slack #ops-monitor に1件のみ到達"
echo "  [ ] Logs: Supabase Functions 200、指数バックオフの再送なし"
echo "  [ ] 記録: DAY11_SOT_DIFFS.md 自動追記 + OPS-MONITORING-V3-001.md / Mermaid.md 更新済み"
echo ""

# 最終レポートの雛形
echo "📋 最終レポート（SOT追記の雛形）"
echo ""
echo "docs/reports/DAY11_SOT_DIFFS.md に以下の形式で追記してください:"
echo ""
cat <<'EOF'
### Day11 本番検証ログ（YYYY-MM-DD HH:mm JST）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: <メッセージURL>

- 次回実行（推定）: <YYYY-MM-DDT09:00:00+09:00>

- Logs: Supabase Functions=200（再送なし）, GHA=成功（実施時）
EOF

echo ""
echo "=== Day11 最終ランブロック完了 ==="
echo ""
echo "📝 次のステップ:"
echo "  1. Slack #ops-monitor チャンネルで週次サマリを確認"
echo "  2. Supabase Functions Logs でログを確認"
echo "  3. 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を手動更新"
echo "  4. Go/No-Go判定を実施"
echo ""


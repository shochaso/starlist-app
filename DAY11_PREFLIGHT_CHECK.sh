#!/bin/bash
# Day11 実行直前チェック（1分で完了）
# Usage: ./DAY11_PREFLIGHT_CHECK.sh

set -euo pipefail

echo "=== Day11 実行直前チェック ==="
echo ""

# 1) 必須環境変数確認
echo "📋 1) 必須環境変数確認"
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

# 2) 実行権限付与（冪等）
echo "📋 2) 実行権限付与（冪等）"
chmod +x ./DAY11_FINAL_CHECK.sh ./DAY11_EXECUTE_ALL.sh \
          ./DAY11_SMOKE_TEST.sh ./DAY11_FINAL_RUN.sh 2>/dev/null || true

if [ -f ./DAY11_FINAL_CHECK.sh ] && [ -f ./DAY11_EXECUTE_ALL.sh ] && \
   [ -f ./DAY11_SMOKE_TEST.sh ] && [ -f ./DAY11_FINAL_RUN.sh ]; then
  echo "✅ 実行権限付与完了"
else
  echo "⚠️  一部のスクリプトが見つかりません"
fi
echo ""

# 3) jq が無ければ導入（macOS の例）
echo "📋 3) jq インストール確認"
if command -v jq >/dev/null 2>&1; then
  echo "✅ jq がインストールされています: $(jq --version)"
else
  echo "❌ jq がインストールされていません"
  echo ""
  echo "macOSの場合:"
  echo "  brew install jq"
  echo ""
  echo "Linux (Ubuntu/Debian)の場合:"
  echo "  sudo apt-get update && sudo apt-get install -y jq"
  echo ""
  echo "jqをインストールしてから再実行してください"
  exit 1
fi
echo ""

# 4) Secrets命名の目視最終確認
echo "📋 4) Secrets命名の目視最終確認"
echo ""
echo "以下のSecretsが設定されていることを確認してください:"
echo ""
echo "  Supabase Edge Secret:  slack_webhook_ops_summary（小文字）"
echo "  GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字）"
echo ""
read -p "Secretsが設定済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  Secretsを設定してから実行してください"
  exit 1
fi
echo ""

# 5) DB View & Edge Function デプロイ確認
echo "📋 5) DB View & Edge Function デプロイ確認"
echo ""
echo "以下のデプロイが完了していることを確認してください:"
echo ""
echo "  [ ] DB View: v_ops_notify_stats"
echo "  [ ] Edge Function: ops-slack-summary"
echo ""
read -p "デプロイが完了していますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  デプロイを完了してから実行してください"
  echo ""
  echo "デプロイ手順:"
  echo "  1. Supabase Dashboard → SQL Editor で v_ops_notify_stats ビューを作成"
  echo "  2. Supabase Dashboard → Edge Functions → ops-slack-summary → Deploy"
  exit 1
fi
echo ""

echo "=== ✅ 実行直前チェック完了 ==="
echo ""
echo "次のコマンドで本番実行を開始できます:"
echo "  ./DAY11_FINAL_RUN.sh"
echo ""


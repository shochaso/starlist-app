#!/bin/bash
# Day11 仕上げチェックスクリプト（実行前の最小セット確認）
# Usage: ./DAY11_FINAL_CHECK.sh

set -euo pipefail

echo "=== Day11 仕上げチェック（実行前の最小セット） ==="
echo ""

# 環境変数確認
echo "📋 環境変数確認"
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

# 実行権限確認
echo "📋 実行権限確認"
if [ ! -x "./DAY11_EXECUTE_ALL.sh" ]; then
  echo "⚠️  DAY11_EXECUTE_ALL.sh に実行権限がありません"
  echo "   実行権限を付与します..."
  chmod +x ./DAY11_EXECUTE_ALL.sh
  echo "✅ 実行権限を付与しました"
else
  echo "✅ DAY11_EXECUTE_ALL.sh に実行権限があります"
fi
echo ""

# jq 確認
echo "📋 jq 確認"
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq がインストールされていません"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   macOSの場合: brew install jq"
    read -p "jqをインストールしますか？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      brew install jq
      echo "✅ jq をインストールしました"
    else
      echo "❌ jqが必要です。インストールしてから再実行してください"
      exit 1
    fi
  else
    echo "   Linuxの場合: sudo apt-get install jq または sudo yum install jq"
    echo "❌ jqが必要です。インストールしてから再実行してください"
    exit 1
  fi
else
  echo "✅ jq がインストールされています"
fi
echo ""

# Secrets命名の最終確認（目視）
echo "📋 Secrets命名の最終確認（目視）"
echo ""
echo "⚠️  以下のSecretsが設定されているか確認してください:"
echo ""
echo "  Supabase Edge Secret: slack_webhook_ops_summary（小文字スネーク）"
echo "  GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字スネーク）"
echo ""
read -p "Secrets設定は完了していますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  Secrets設定を完了してから再実行してください"
  exit 1
fi

echo ""
echo "✅ 仕上げチェック完了"
echo ""
echo "🚀 次のステップ:"
echo "  ./DAY11_EXECUTE_ALL.sh"
echo ""


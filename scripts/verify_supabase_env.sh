#!/usr/bin/env bash
# Supabase環境変数適用チェックスクリプト
# Usage: ./scripts/verify_supabase_env.sh

set -euo pipefail

: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${OPS_SERVICE_SECRET:?OPS_SERVICE_SECRET is required}"

PROJECT_REF=$(basename "$SUPABASE_URL" .supabase.co)
ENDPOINT="https://${PROJECT_REF}.functions.supabase.co/ops-alert"

echo "=== Supabase環境変数適用チェック ==="
echo ""
echo "プロジェクト: $PROJECT_REF"
echo "エンドポイント: $ENDPOINT"
echo ""

# 正常ケース（許可オリジン・正しいシークレット）
echo "1. 正常ケース（許可オリジン・正しいシークレット）"
echo "   Origin: https://app.starlist.jp"
echo "   Secret: ${OPS_SERVICE_SECRET:0:8}..."
echo ""

RESPONSE_GOOD=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_GOOD=$(echo "$RESPONSE_GOOD" | tail -n1)
BODY_GOOD=$(echo "$RESPONSE_GOOD" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_GOOD"
if [ "$HTTP_CODE_GOOD" = "200" ] || [ "$HTTP_CODE_GOOD" = "204" ]; then
  echo "   ✅ 正常（期待通り）"
else
  echo "   ❌ 異常（200/204を期待）"
  echo "   ボディ: $BODY_GOOD"
fi
echo ""

# 拒否ケース1（非許可オリジン）
echo "2. 拒否ケース1（非許可オリジン）"
echo "   Origin: https://evil.example.com"
echo "   Secret: ${OPS_SERVICE_SECRET:0:8}..."
echo ""

RESPONSE_BAD_ORIGIN=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://evil.example.com" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_BAD_ORIGIN=$(echo "$RESPONSE_BAD_ORIGIN" | tail -n1)
BODY_BAD_ORIGIN=$(echo "$RESPONSE_BAD_ORIGIN" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_BAD_ORIGIN"
if [ "$HTTP_CODE_BAD_ORIGIN" = "403" ]; then
  echo "   ✅ 正常（期待通り：403）"
else
  echo "   ⚠️  予期しないレスポンス（403を期待）"
  echo "   ボディ: $BODY_BAD_ORIGIN"
fi
echo ""

# 拒否ケース2（シークレット不一致）
echo "3. 拒否ケース2（シークレット不一致）"
echo "   Origin: https://app.starlist.jp"
echo "   Secret: BAD_SECRET"
echo ""

RESPONSE_BAD_SECRET=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: BAD_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_BAD_SECRET=$(echo "$RESPONSE_BAD_SECRET" | tail -n1)
BODY_BAD_SECRET=$(echo "$RESPONSE_BAD_SECRET" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_BAD_SECRET"
if [ "$HTTP_CODE_BAD_SECRET" = "403" ]; then
  echo "   ✅ 正常（期待通り：403）"
else
  echo "   ⚠️  予期しないレスポンス（403を期待）"
  echo "   ボディ: $BODY_BAD_SECRET"
fi
echo ""

# サマリ
echo "=== チェック結果サマリ ==="
if [ "$HTTP_CODE_GOOD" = "200" ] || [ "$HTTP_CODE_GOOD" = "204" ]; then
  if [ "$HTTP_CODE_BAD_ORIGIN" = "403" ] && [ "$HTTP_CODE_BAD_SECRET" = "403" ]; then
    echo "✅ すべてのチェックが正常です"
    exit 0
  else
    echo "⚠️  一部のチェックで予期しない結果があります"
    exit 1
  fi
else
  echo "❌ 正常ケースが失敗しています。環境変数の設定を確認してください"
  exit 1
fi

# Supabase環境変数適用チェックスクリプト
# Usage: ./scripts/verify_supabase_env.sh

set -euo pipefail

: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${OPS_SERVICE_SECRET:?OPS_SERVICE_SECRET is required}"

PROJECT_REF=$(basename "$SUPABASE_URL" .supabase.co)
ENDPOINT="https://${PROJECT_REF}.functions.supabase.co/ops-alert"

echo "=== Supabase環境変数適用チェック ==="
echo ""
echo "プロジェクト: $PROJECT_REF"
echo "エンドポイント: $ENDPOINT"
echo ""

# 正常ケース（許可オリジン・正しいシークレット）
echo "1. 正常ケース（許可オリジン・正しいシークレット）"
echo "   Origin: https://app.starlist.jp"
echo "   Secret: ${OPS_SERVICE_SECRET:0:8}..."
echo ""

RESPONSE_GOOD=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_GOOD=$(echo "$RESPONSE_GOOD" | tail -n1)
BODY_GOOD=$(echo "$RESPONSE_GOOD" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_GOOD"
if [ "$HTTP_CODE_GOOD" = "200" ] || [ "$HTTP_CODE_GOOD" = "204" ]; then
  echo "   ✅ 正常（期待通り）"
else
  echo "   ❌ 異常（200/204を期待）"
  echo "   ボディ: $BODY_GOOD"
fi
echo ""

# 拒否ケース1（非許可オリジン）
echo "2. 拒否ケース1（非許可オリジン）"
echo "   Origin: https://evil.example.com"
echo "   Secret: ${OPS_SERVICE_SECRET:0:8}..."
echo ""

RESPONSE_BAD_ORIGIN=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://evil.example.com" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_BAD_ORIGIN=$(echo "$RESPONSE_BAD_ORIGIN" | tail -n1)
BODY_BAD_ORIGIN=$(echo "$RESPONSE_BAD_ORIGIN" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_BAD_ORIGIN"
if [ "$HTTP_CODE_BAD_ORIGIN" = "403" ]; then
  echo "   ✅ 正常（期待通り：403）"
else
  echo "   ⚠️  予期しないレスポンス（403を期待）"
  echo "   ボディ: $BODY_BAD_ORIGIN"
fi
echo ""

# 拒否ケース2（シークレット不一致）
echo "3. 拒否ケース2（シークレット不一致）"
echo "   Origin: https://app.starlist.jp"
echo "   Secret: BAD_SECRET"
echo ""

RESPONSE_BAD_SECRET=$(curl -s -w "\n%{http_code}" -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: BAD_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "$ENDPOINT" 2>&1)

HTTP_CODE_BAD_SECRET=$(echo "$RESPONSE_BAD_SECRET" | tail -n1)
BODY_BAD_SECRET=$(echo "$RESPONSE_BAD_SECRET" | sed '$d')

echo "   レスポンス: HTTP $HTTP_CODE_BAD_SECRET"
if [ "$HTTP_CODE_BAD_SECRET" = "403" ]; then
  echo "   ✅ 正常（期待通り：403）"
else
  echo "   ⚠️  予期しないレスポンス（403を期待）"
  echo "   ボディ: $BODY_BAD_SECRET"
fi
echo ""

# サマリ
echo "=== チェック結果サマリ ==="
if [ "$HTTP_CODE_GOOD" = "200" ] || [ "$HTTP_CODE_GOOD" = "204" ]; then
  if [ "$HTTP_CODE_BAD_ORIGIN" = "403" ] && [ "$HTTP_CODE_BAD_SECRET" = "403" ]; then
    echo "✅ すべてのチェックが正常です"
    exit 0
  else
    echo "⚠️  一部のチェックで予期しない結果があります"
    exit 1
  fi
else
  echo "❌ 正常ケースが失敗しています。環境変数の設定を確認してください"
  exit 1
fi


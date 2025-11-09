#!/usr/bin/env bash
# Extended Security Checks 検証スクリプト
# Usage: ./scripts/verify_extended_security_checks.sh

set -euo pipefail

echo "=== Extended Security Checks 検証 ==="
echo ""

# 1) extended-security.yml ワークフローの最新実行状況
echo "📋 1) Extended Security ワークフロー最新実行状況:"
gh run list --workflow extended-security.yml --limit 5 --json name,status,conclusion,createdAt,headBranch \
  --jq '.[] | "\(.name): \(.status) \(.conclusion // "in_progress") (\(.createdAt)) [\(.headBranch)]"' || echo "  [warn] ワークフロー実行情報を取得できませんでした"
echo ""

# 2) セキュリティ関連ファイルの存在確認
echo "📋 2) セキュリティ関連ファイル存在確認:"
SECURITY_FILES=(
  ".github/workflows/extended-security.yml"
  ".github/workflows/security-audit.yml"
  ".semgrep.yml"
  ".gitleaks.toml"
  ".trivyignore"
  "scripts/extended_security_runner.sh"
)

for file in "${SECURITY_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (見つかりません)"
  fi
done
echo ""

# 3) セキュリティツールのインストール確認
echo "📋 3) セキュリティツールインストール確認:"
TOOLS=("gitleaks" "semgrep" "trivy" "pnpm")

for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    VERSION=$("$tool" --version 2>/dev/null | head -1 || echo "unknown")
    echo "  ✅ $tool: $VERSION"
  else
    echo "  ❌ $tool (インストールされていません)"
  fi
done
echo ""

# 4) package.json のセキュリティスクリプト確認
echo "📋 4) package.json セキュリティスクリプト確認:"
if [ -f package.json ]; then
  if grep -q '"security' package.json || grep -q '"audit' package.json; then
    echo "  ✅ セキュリティ関連スクリプトが定義されています"
    grep -E '"(security|audit)' package.json | head -5 || true
  else
    echo "  ⚠️  セキュリティ関連スクリプトが見つかりません"
  fi
else
  echo "  ❌ package.json が見つかりません"
fi
echo ""

# 5) 最新のセキュリティチェック実行結果（ローカル）
echo "📋 5) ローカルセキュリティチェック（オプション）:"
if command -v pnpm >/dev/null 2>&1 && [ -f package.json ]; then
  echo "  pnpm audit 実行中..."
  pnpm audit --audit-level=moderate 2>&1 | head -20 || echo "  [warn] pnpm audit 実行失敗"
else
  echo "  ⏭️  pnpm または package.json が見つかりません"
fi
echo ""

# 6) セキュリティ関連のGitHub Actions設定確認
echo "📋 6) GitHub Actions セキュリティ設定確認:"
if [ -f ".github/workflows/extended-security.yml" ]; then
  echo "  ✅ extended-security.yml 存在"
  if grep -q "schedule:" .github/workflows/extended-security.yml; then
    echo "  ✅ スケジュール実行が設定されています"
    grep -A 2 "schedule:" .github/workflows/extended-security.yml | head -3 || true
  else
    echo "  ⚠️  スケジュール実行が設定されていません"
  fi
else
  echo "  ❌ extended-security.yml が見つかりません"
fi
echo ""

echo "=== 検証完了 ==="


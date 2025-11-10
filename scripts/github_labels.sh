#!/usr/bin/env bash
set -euo pipefail

# GitHub ラベル作成スクリプト
# 実行前に: gh repo set-default shochaso/starlist-app

echo "→ GitHub ラベル作成"

create_label() {
  local name="$1"
  local color="$2"
  local desc="${3:-}"
  
  if gh label view "$name" &>/dev/null; then
    echo "  - $name (既に存在、スキップ)"
  else
    gh label create "$name" -c "$color" -d "$desc" 2>/dev/null || true
    echo "  - $name"
  fi
}

create_label "feature"      "#6E5AED" "新機能"
create_label "security"     "#EF4444" "セキュリティ"
create_label "ops"          "#0EA5E9" "運用/監視"
create_label "area/ui"      "#6E5AED" ""
create_label "area/api"     "#0EA5E9" ""
create_label "area/infra"   "#F59E0B" ""
create_label "risk/security" "#EF4444" ""
create_label "size/S"       "#10B981" ""
create_label "size/M"       "#84CC16" ""
create_label "size/L"       "#22C55E" ""
create_label "prio/P0"      "#DC2626" ""
create_label "prio/P1"      "#F97316" ""
create_label "prio/P2"      "#F59E0B" ""
create_label "blocked"      "#64748B" ""
create_label "regression"   "#9333EA" ""

echo "✓ GitHub ラベル作成 完了"


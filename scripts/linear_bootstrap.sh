#!/usr/bin/env bash
set -euo pipefail

# ==== 設定 ====
TEAM_KEY="SL"                         # ← Linear のチームキーに置き換え
LINEAR_API_KEY="lin_xxxxxxxxxxxxx"    # ← Linear のAPIキーに置き換え
API=https://api.linear.app/graphql

header() { echo -ne "Content-Type: application/json\r\nAuthorization: $LINEAR_API_KEY\r\n"; }

gql() {
  local q="$1"
  curl -sS "$API" -H "Content-Type: application/json" -H "Authorization: $LINEAR_API_KEY" \
    -d "{\"query\":$(jq -Rs . <<<"$q")}"
}

echo "→ Team ID 取得"
TEAM_ID=$(gql "
query { team(key:\"$TEAM_KEY\") { id name key } }
" | jq -r '.data.team.id')

if [[ "$TEAM_ID" == "null" || -z "$TEAM_ID" ]]; then
  echo "✗ Team key $TEAM_KEY が見つかりません。LinearのTeam Keyをご確認ください。"; exit 1
fi
echo "✓ TEAM_ID=$TEAM_ID"

# ---------- ラベル作成 ----------
echo "→ ラベル作成"
make_label() {
  local name="$1"; local color="$2"
  gql "
mutation {
  issueLabelCreate(input:{teamId:\"$TEAM_ID\", name:\"$name\", color:\"$color\"}) { issueLabel { id name } }
}" >/dev/null
  echo "  - $name"
}

# カラーパレットはLinearの16進（#なし）
make_label "area/ui"        "6E5AED"
make_label "area/api"       "0EA5E9"
make_label "area/infra"     "F59E0B"
make_label "risk/security"  "EF4444"
make_label "size/S"         "10B981"
make_label "size/M"         "84CC16"
make_label "size/L"         "22C55E"
make_label "prio/P0"        "DC2626"
make_label "prio/P1"        "F97316"
make_label "prio/P2"        "F59E0B"
make_label "blocked"        "64748B"
make_label "regression"     "9333EA"

# ---------- Issue テンプレ作成（3つ） ----------
echo "→ Issueテンプレ作成（Feature / Security / Ops）"
make_template() {
  local name="$1"; local body="$2"
  gql "
mutation {
  issueTemplateCreate(input:{
    teamId:\"$TEAM_ID\",
    name:\"$name\",
    description:\"STARLIST default template\",
    templateData:{
      title:\"$name: <短い要約>\",
      description:$(jq -Rs . <<<"$body")
    }
  }) { issueTemplate { id name } }
}" >/dev/null
  echo "  - $name"
}

TPL_DOD=$'-  [ ] 目的とスコープが明確\n-  [ ] 受け入れ基準(DoD)に沿った動作\n-  [ ] テレメトリ/監視追加または更新\n-  [ ] 影響範囲とロールバック手順をPRに記載'

TPL_FEATURE=$'# 目的\n\n# スコープ / 非対象\n\n# 受け入れ基準(DoD)\n'"$TPL_DOD"'\n\n# 設計メモ\n- UI/UX\n- API/RLS\n- 計測\n\n# 影響範囲\n\n# ロールバック\n'

TPL_SECURITY=$'# 背景\n\n# リスク/根拠\n\n# 対応方針\n- 設定/ポリシー差分\n- テスト(再現手順)\n\n# 受け入れ基準(DoD)\n'"$TPL_DOD"'\n\n# ロールバック\n'

TPL_OPS=$'# 目的(運用/KPI)\n\n# 実行・スケジュール\n\n# 監視/通知\n\n# 受け入れ基準(DoD)\n'"$TPL_DOD"'\n\n# ロールバック\n'

make_template "Feature"  "$TPL_FEATURE"
make_template "Security" "$TPL_SECURITY"
make_template "Ops"      "$TPL_OPS"

echo "✓ Linear 初期化 完了"


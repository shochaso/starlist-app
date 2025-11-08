#!/usr/bin/env bash
# ====================================================================
# STARLIST Final Integration Suite (Day11統合 + 監査票自動生成)
# - 実行順: Preflight → DAY11_GO_LIVE.sh → 監査票作成 → 監査用フォルダ整備
# - 依存: jq, git, date, awk, bash>=5 / Asia/Tokyo 固定
# - 機微情報は出力しません
# ====================================================================

set -Eeuo pipefail
export TZ="Asia/Tokyo"

# ---------- util ----------
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[ERR ]\033[0m %s\n"  "$*" 1>&2; }

require_cmd(){ command -v "$1" >/dev/null 2>&1 || { err "$1 not found"; exit 127; }; }
require_env(){ : "${!1:?ERR: env $1 is required}"; }

TS_ISO(){ date +'%Y-%m-%dT%H:%M:%S%z'; }
DAY(){ date +'%Y-%m-%d'; }
WEEK(){ date +'%G-W%V'; }

PROJECT_REF_FROM_URL(){
  # https://<ref>.supabase.co → <ref>
  basename "${SUPABASE_URL}" .supabase.co
}

# ---------- preflight ----------
require_cmd jq; require_cmd awk; require_cmd date; require_cmd git; require_cmd bash
require_env SUPABASE_URL; require_env SUPABASE_ANON_KEY

if ! [[ "$SUPABASE_URL" =~ ^https://[a-z0-9]{20}\.supabase\.co$ ]]; then
  err "SUPABASE_URL format invalid: $SUPABASE_URL"
  exit 2
fi

# 機密は出さない
set +x

# ---------- paths ----------
ROOT="$(pwd)"
CACHE_DIR="${ROOT}/.day11_cache"
LOG_DIR="${ROOT}/logs/day11"
REPORT_DIR="${ROOT}/docs/reports"
mkdir -p "$CACHE_DIR" "$LOG_DIR" "$REPORT_DIR"

COMMIT="$(git rev-parse --short HEAD || echo 'unknown')"
RUN_AT="$(TS_ISO)"
DATE="$(DAY)"
WEEKID="$(WEEK)"
PROJECT_REF="$(PROJECT_REF_FROM_URL)"

# ---------- 1) Go-Live 実行 ----------
info "Run DAY11_GO_LIVE.sh …"
chmod +x ./DAY11_GO_LIVE.sh
./DAY11_GO_LIVE.sh

# ---------- 2) 監査素材の収集 ----------
info "Collect artifacts for audit …"

# 最新ログファイル（dryrun/send）を検出
latest_json() { ls -1t "${LOG_DIR}"/"*_${1}.json" 2>/dev/null | head -n1 || true; }
DRY_JSON_FILE="$(latest_json dryrun)"
SEND_JSON_FILE="$(latest_json send)"

if [[ -z "$DRY_JSON_FILE" || -z "$SEND_JSON_FILE" ]]; then
  err "could not find latest dryrun/send json under ${LOG_DIR}"
  exit 1
fi

# Permalink（キャッシュ優先→ログから抽出）
PERMALINK_FILE="${CACHE_DIR}/permalink.txt"
if [[ -s "$PERMALINK_FILE" ]]; then
  PERMALINK="$(cat "$PERMALINK_FILE" || true)"
else
  PERMALINK="$(jq -r '.permalink? // .slack?.permalink? // .message_url? // empty' <"$SEND_JSON_FILE")"
  [[ -n "$PERMALINK" ]] && printf '%s\n' "$PERMALINK" > "$PERMALINK_FILE" || true
fi
[[ -z "$PERMALINK" ]] && warn "permalink not found; please attach Slack screenshot to the report."

# 合格ラインの自動判定（簡易）
OK_DRY="$(jq -e '.ok==true and (.stats|type=="object") and (.weekly_summary|type=="object") and (.message|type=="string") and (.stats.std_dev|numbers and .>=0) and (.stats.new_threshold|numbers and .>=0) and (.stats.critical_threshold|numbers and .>=0)' "$DRY_JSON_FILE" >/dev/null && echo OK || echo NG)"
OK_SEND="$(jq -e '.ok==true and (.stats|type=="object") and (.weekly_summary|type=="object") and (.message|type=="string")' "$SEND_JSON_FILE" >/dev/null && echo OK || echo NG)"

# ---------- 3) 監査票の自動作成 ----------
REPORT_FILE="${REPORT_DIR}/${DATE}_DAY11_AUDIT_${WEEKID}.md"
info "Generate audit report: ${REPORT_FILE}"

cat > "$REPORT_FILE" <<'EOF'
# Day11 監査レポート（Slack週次サマリ）

## メタ情報

- 実行日: __DATE__
- 環境: prod
- プロジェクト: __PROJECT_REF__
- コミット: __COMMIT__
- 実行者: （記入）
- 実行時刻: __RUN_AT__

## 合格ライン判定

- dryRun JSON 妥当性: __OK_DRY__
- 本送信 JSON 妥当性: __OK_SEND__
- Slack 到達: （1件のみ到達をUIで確認／スクショ添付）
- 関数ログ: HTTP 2xx・429/5xx は指数バックオフ内で回復、再送痕跡なし（別紙）

## 主要KPI抜粋（send）

- weekly_summary:  
> __WEEKLY_SUMMARY__

- stats: mean_notifications=__MEAN__, std_dev=__STD_DEV__, new_threshold=__NEW_THRESHOLD__, critical_threshold=__CRITICAL_THRESHOLD__

## 証跡リンク/ファイル

- Slack permalink: __PERMALINK__
- dryRun JSON: `__DRY_FILE__`
- send JSON: `__SEND_FILE__`
- Edge logs: `docs/reports/__DATE___edge_logs.txt`（任意）
- 参考: `.day11_cache/weekly.last`（冪等性キー）

## インシデント対処・ロールバック（要約）

- 二重投稿 → 関数/トリガー一時停止、キャッシュ確認、再送要因を除去後に再実行（dryRun→send）
- 429/5xx → 最大2回の指数バックオフで回復しない場合は停止、Edgeログ確認とSecrets再注入
- JSON不整合 → ビュー再集計・型崩れ修正後にdryRun再検証

## 署名

- 監査者: （記入） / 承認者: （記入）
EOF

# 置換埋め込み
WEEKLY_SUMMARY="$(jq -r '.weekly_summary | tostring' <"$SEND_JSON_FILE" | sed 's/[\/&]/\\&/g')"
MEAN="$(jq -r '.stats.mean_notifications // .stats.mean // "N/A"' <"$SEND_JSON_FILE")"
STD_DEV="$(jq -r '.stats.std_dev // "N/A"' <"$SEND_JSON_FILE")"
NEW_THRESHOLD="$(jq -r '.stats.new_threshold // "N/A"' <"$SEND_JSON_FILE")"
CRITICAL_THRESHOLD="$(jq -r '.stats.critical_threshold // "N/A"' <"$SEND_JSON_FILE")"

# sed 埋め込み（BSD/gnu互換）
sed -i.bak \
  -e "s|__DATE__|${DATE}|g" \
  -e "s|__PROJECT_REF__|${PROJECT_REF}|g" \
  -e "s|__COMMIT__|${COMMIT}|g" \
  -e "s|__RUN_AT__|${RUN_AT}|g" \
  -e "s|__OK_DRY__|${OK_DRY}|g" \
  -e "s|__OK_SEND__|${OK_SEND}|g" \
  -e "s|__WEEKLY_SUMMARY__|${WEEKLY_SUMMARY}|g" \
  -e "s|__MEAN__|${MEAN}|g" \
  -e "s|__STD_DEV__|${STD_DEV}|g" \
  -e "s|__NEW_THRESHOLD__|${NEW_THRESHOLD}|g" \
  -e "s|__CRITICAL_THRESHOLD__|${CRITICAL_THRESHOLD}|g" \
  -e "s|__PERMALINK__|${PERMALINK:-(手動添付)}|g" \
  -e "s|__DRY_FILE__|${DRY_JSON_FILE}|g" \
  -e "s|__SEND_FILE__|${SEND_JSON_FILE}|g" \
  "$REPORT_FILE" >/dev/null 2>&1 || true
rm -f "${REPORT_FILE}.bak" || true

info "Audit report created."
echo "-> ${REPORT_FILE}"

# ---------- 4) （任意）Edgeログ収集の雛形 ----------
if command -v supabase >/dev/null 2>&1; then
  info "Collecting last 2h Edge logs (optional)…"
  supabase functions logs --project-ref "$PROJECT_REF" --function-name "ops-slack-summary" --since 2h > "${REPORT_DIR}/${DATE}_edge_logs.txt" 2>&1 || warn "Edge logs collection failed"
fi

# ---------- 5) Pricing監査票（オプション） ----------
if [ -f ./PRICING_FINAL_SHORTCUT.sh ]; then
  info "Pricing E2E test available. Generate Pricing audit report? (y/n)"
  read -r -n 1 -p "" yn
  echo
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    generate_pricing_audit_report
  fi
fi

info "Final Integration Suite completed."

# ---------- Pricing監査票生成関数 ----------
generate_pricing_audit_report() {
  info "Generating Pricing audit report…"
  
  PRICING_REPORT_FILE="${REPORT_DIR}/${DATE}_PRICING_AUDIT.md"
  
  # Stripe Events収集
  STRIPE_EVENTS=""
  if command -v stripe >/dev/null 2>&1; then
    STRIPE_EVENTS=$(stripe events list --limit 10 2>/dev/null | jq -r '.data[] | "\(.created) \(.type) \(.id)"' || echo "")
  fi
  
  cat > "$PRICING_REPORT_FILE" <<EOF
# Pricing（推奨価格機能）監査レポート

## メタ情報

- 実行日: ${DATE}
- 環境: prod
- プロジェクト: ${PROJECT_REF}
- コミット: ${COMMIT}
- 実行者: （記入）
- 実行時刻: ${RUN_AT}

## 検証項目

- [ ] 学生プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] 成人プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] plan_price整数検証完了

## Stripe Events（直近10件）

$(if [ -n "$STRIPE_EVENTS" ]; then
  echo "| Created | Type | ID |"
  echo "|---------|------|-----|"
  echo "$STRIPE_EVENTS" | while IFS=' ' read -r created type id; do
    echo "| $created | $type | \`$id\` |"
  done
else
  echo "Stripe events not available"
  echo ""
  echo "手動で確認:"
  echo "\`\`\`bash"
  echo "stripe events list --limit 10"
  echo "\`\`\`"
fi)

## DB検証結果

\`\`\`sql
-- 直近のplan_price保存確認
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
where plan_price is not null
order by updated_at desc
limit 10;
\`\`\`

**結果**: 手動で確認してください（plan_priceが整数の円で保存されていること）

## 合格ライン（3+1）

- [ ] UI：推奨バッジ表示・刻み/上下限バリデーションOK
- [ ] Checkout→DB：plan_price が整数円で保存
- [ ] Webhook：checkout.* / subscription.* / invoice.* で価格更新反映
- [ ] Logs：Supabase Functions 200、例外なし／再送痕跡なし

## 証跡リンク/ファイル

- Stripe Events: Stripe Dashboard → Events
- Webhook Logs: Supabase Dashboard → Edge Functions → stripe-webhook → Logs
- DB Records: Supabase Dashboard → SQL Editor（上記SQL実行）

## インシデント対処・ロールバック（要約）

- plan_priceがNULL → 金額単位変換を確認（amount_total/unit_amountの基数）
- Webhook 400 → STRIPE_WEBHOOK_SECRET再設定
- Webhook 500 → SUPABASE_SERVICE_ROLE_KEY確認
- 価格入力が通る → UI側でvalidatePrice未結線を確認

## 署名

- 監査者: （記入） / 承認者: （記入）
EOF

  info "Pricing audit report created."
  echo "-> ${PRICING_REPORT_FILE}"
}

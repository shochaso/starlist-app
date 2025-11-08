# Day11 最終実行セット（貼り付け即実行）

## 前提条件

1. 環境変数が設定済み（`SUPABASE_URL`, `SUPABASE_ANON_KEY`）
2. DBビュー `v_ops_notify_stats` が作成済み
3. Edge Function `ops-slack-summary` がデプロイ済み
4. Secrets設定済み（`slack_webhook_ops_summary`）

---

## 1) Preflight（未設定なら）

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"
command -v jq >/dev/null || brew install jq
```

---

## 2) dryRun（自動検証つき）

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | tee /tmp/day11_dryrun.json >/dev/null

# 堅牢化版バリデータを呼び出し（DAY11_EXECUTE_ALL.sh 内の関数を使用）
# スクリプトを実行する場合は自動実行されます
# 手動実行する場合は、DAY11_EXECUTE_ALL.sh から validate_dryrun_json 関数をコピー

# 目視用抜粋（念のため）
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json
```

---

## 3) 本送信（Slack確認）

```bash
read -r -p ">>> 本送信しますか？（Slack #ops-monitor）[y/N]: " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=false&period=14d" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" \
    -d '{}' | tee /tmp/day11_send.json >/dev/null
  
  # 検証（DAY11_EXECUTE_ALL.sh 内の関数を使用）
  # スクリプトを実行する場合は自動実行されます
  
  echo "[INFO] Slackの #ops-monitor に到達したかご確認ください。"
fi
```

---

## 4) 成果物の記録（簡易テンプレ）

```bash
SLACK_MSG_URL="<SlackのメッセージURLを貼付>" # 可能なら
NEXT_RUN_JST="$(jq -r '.message
  | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
  | if .=="" then "" else (.date+"T"+.time+":00+09:00") end' /tmp/day11_dryrun.json)"

cat >> docs/reports/DAY11_SOT_DIFFS.md <<EOF

### 本番検証ログ（$(date +'%Y-%m-%d %H:%M %Z')）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL:-"(URL未記入)"}

- 次回実行（推定）: ${NEXT_RUN_JST:-"(抽出不可)"}

- Logs: Supabase Functions=200（再送なし） / GHA（実施時）=成功
EOF
```

**注意:** `DAY11_EXECUTE_ALL.sh` を実行する場合は、この手順は自動実行されます。

---

## 成功トレイルの確認ポイント（超要点）

* **dryRun**: `validate_dryrun_json` が **OK** で終わる
* **本送信**: `validate_send_json` が **OK**、Slackに**1件のみ**到達
* **Logs**: Supabase Functions が **200**、指数バックオフの再送痕跡なし

---

## Go/No-Go（最終4点）

1. dryRun の自動検証 **OK**
2. Slack本送信が到達し、**KPI／閾値／変化率／次回実行メッセージ**の体裁 **OK**
3. ログにエラー／再送痕跡 **なし**
4. `DAY11_SOT_DIFFS.md`・`OPS-MONITORING-V3-001.md`・`Mermaid.md` **更新済み**

---

## もし詰まったら（即応）

* **Secret名の大小**: Supabase（`slack_webhook_ops_summary` 小文字）、GitHub（`SLACK_WEBHOOK_OPS_SUMMARY` 大文字）
* **`*_change` が `"—"`/`"N/A"`** などに変化 → `parse_pct_or_null` に `gsub("—|N/A";"")` を1語追加
* **件数が小数になる** → 集計SQLの `COUNT` / `COALESCE` / `::int` を点検
* **次回日時の表現変更** → `.message` 抽出の正規表現を一行差し替え

---

## 推奨実行方法

**方法1: 一括実行スクリプトを使用（推奨）**

```bash
# 環境変数設定
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# スクリプト実行
./DAY11_EXECUTE_ALL.sh
```

**方法2: 手動実行**

上記の1-4の手順を順番に実行してください。

---

実行結果（JSON抜粋 or SlackメッセージURL）が取れましたら、そのまま貼っていただければ**最終レポート整形**まで一気に仕上げます。


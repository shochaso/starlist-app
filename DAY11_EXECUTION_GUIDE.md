# Day11 本番実行ガイド（最終版）

## ✅ 実行直前チェック（1分で完了）

```bash
# 1) 必須環境変数（置換）
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# 2) 実行権限付与（冪等）
chmod +x ./DAY11_PREFLIGHT_CHECK.sh ./DAY11_FINAL_CHECK.sh \
          ./DAY11_EXECUTE_ALL.sh ./DAY11_SMOKE_TEST.sh ./DAY11_FINAL_RUN.sh

# 3) jq が無ければ導入（macOS の例）
command -v jq >/dev/null || brew install jq

# 4) Secrets命名の目視最終確認
#   Supabase Edge Secret:  slack_webhook_ops_summary（小文字）
#   GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字）
```

---

## ▶️ 本番実行（最終ランブロック一発）

```bash
./DAY11_FINAL_RUN.sh
```

* スクリプトが自動で **実行直前チェック → 仕上げチェック → 一括実行（dryRun→本送信） → スモーク → 変更差分 → 成功トレイル表示 → レポート雛形表示** まで行います。

* 途中で **SlackメッセージURL** の入力を求められたら、その場で貼り付けてください（後追い入力でもOK）。

---

## 🏁 合格ライン（この3点が揃えば完了）

1. **dryRun**：`validate_dryrun_json` が **OK**
   * `stats / weekly_summary / message` の整合が取れていること

2. **本送信**：`validate_send_json` が **OK**
   * Slack `#ops-monitor` に **1件のみ** 到達（重複なし）

3. **ログ**：Supabase Functions が **200**、指数バックオフの**再送なし**

> 実行後は `DAY11_SOT_DIFFS.md` に自動追記されます。
> 併せて `OPS-MONITORING-V3-001.md`（稼働開始日・責任者）／`Mermaid.md`（Day11ノード）をご更新ください。

---

## 🧯 つまずいた時の即応（最短復旧）

| 症状 | 原因 | 対応 |
|------|------|------|
| **Missing Webhook / 400/404** | Webhook未設定/URL誤り | Webhook再発行 → `slack_webhook_ops_summary` を更新 → 再実行 |
| **σ・閾値が不正** | ビュー集計ロジック誤り | `v_ops_notify_stats` の 0 補完/集計ロジック（`COALESCE/CASE`）を再適用 |
| **変化率が `"—"` / `"N/A"`** | パース関数未対応 | `parse_pct_or_null` に `gsub("—|N/A";"")` を1語追加 |
| **件数が小数になる** | ビューCAST不足 | ビューの `COUNT(*)::int` / CAST を点検 |

---

## 🧾 最終レポート追記（必要なら手動で整形）

### 自動追記（推奨）

```bash
./DAY11_FINAL_REPORT.sh [SLACK_MSG_URL]
```

### 手動追記

```bash
SLACK_MSG_URL="<SlackメッセージURL>"  # 取得できたら差し込み
NEXT_RUN_JST="$(jq -r '.message
  | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
  | if .=="" then "" else (.date+"T"+.time+":00+09:00") end' /tmp/day11_dryrun.json)"

cat >> docs/reports/DAY11_SOT_DIFFS.md <<EOF

### Day11 本番検証ログ（$(date +'%Y-%m-%d %H:%M %Z')）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL:-"(URL未記入)"}

- 次回実行（推定）: ${NEXT_RUN_JST:-"(抽出不可)"}

- Logs: Supabase Functions=200（再送なし）, GHA=成功（実施時）
EOF
```

---

## 📋 実行フロー全体像

```
1. 実行直前チェック（DAY11_PREFLIGHT_CHECK.sh）
   ├─ 環境変数確認
   ├─ 実行権限付与
   ├─ jqインストール確認
   ├─ Secrets命名確認
   └─ DB View & Edge Functionデプロイ確認

2. 仕上げチェック（DAY11_FINAL_CHECK.sh）
   └─ 詳細チェック

3. 一括実行（DAY11_EXECUTE_ALL.sh）
   ├─ dryRun実行（自動検証付き）
   ├─ 本送信テスト（確認後実行）
   └─ 成果物記録（DAY11_SOT_DIFFS.md 自動追記）

4. スモークテスト（DAY11_SMOKE_TEST.sh、任意）
   └─ dryRun要点の再確認

5. 重要ファイルの変更確認
   └─ DAY11_SOT_DIFFS.md / OPS-MONITORING-V3-001.md / Mermaid.md

6. 最終レポート追記（DAY11_FINAL_REPORT.sh、オプション）
   └─ SlackメッセージURL入力 → 自動追記
```

---

## 🎯 成功の目印

- ✅ dryRun: `validate_dryrun_json` が **OK**
- ✅ 本送信: `validate_send_json` が **OK**、Slack `#ops-monitor` に1件のみ到達
- ✅ Logs: Supabase Functions 200、指数バックオフの再送なし
- ✅ 記録: `DAY11_SOT_DIFFS.md` 自動追記 + `OPS-MONITORING-V3-001.md` / `Mermaid.md` 更新済み

---

この状態で **Day11：本番デプロイ〜受け入れ完了**まで一直線で進められます。

実行結果（SlackメッセージURL・dryRun抜粋）がそろいましたらお送りください。最終レポートの体裁までこちらで整えます。


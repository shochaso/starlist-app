# Day11 Go-Live 最終手順ガイド

## ✅ Go-Live 最終ミニ手順

### 1) 実行直前チェック（1分）

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

./DAY11_PREFLIGHT_CHECK.sh
```

### 2) 本番実行（一括）

```bash
./DAY11_GO_LIVE.sh
```

* スクリプトが**dryRun → 自動検証 → 本送信 → スモーク → 変更差分 → 成功トレイル → レポート雛形**まで実行します。

### 3) 最終レポート追記（任意／URLが取れたら）

```bash
./DAY11_FINAL_REPORT.sh "https://<SlackメッセージURL>"
```

---

## 🎯 合格ライン（最終3点）

1. **dryRun**：`validate_dryrun_json` が **OK**（`stats / weekly_summary / message` 整合）

2. **本送信**：`validate_send_json` が **OK**、Slack **#ops-monitor** に**1件のみ到達**

3. **ログ**：Supabase Functions **200**、指数バックオフの**再送なし**

> 実行後は `DAY11_SOT_DIFFS.md` に自動追記済みです。併せて `OPS-MONITORING-V3-001.md`（稼働開始日・責任者）と `Mermaid.md`（Day11ノード）もご更新ください。

---

## 🧯 つまずき時の即応（最短復旧）

| 症状 | 原因 | 対応 |
|------|------|------|
| **Webhook 400/404** | Webhook未設定/URL誤り | Webhook再発行 → `slack_webhook_ops_summary` を更新 → 再実行 |
| **統計値/閾値が不正** | ビュー集計ロジック誤り | `v_ops_notify_stats` の 0 補完/集計（`COALESCE/CASE`）を再適用 |
| **変化率が `"—"`/`"N/A"`** | パース関数未対応 | `parse_pct_or_null` に `gsub("—|N/A";"")` を追加 |
| **件数が小数** | ビューCAST不足 | ビューの `COUNT(*)::int` / CAST を確認 |

---

## 🔍 追加のワンショット確認（任意）

### 自動実行

```bash
./DAY11_QUICK_VALIDATION.sh
```

### 手動実行

```bash
# dryRun 抜粋の目視
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json

# 次回実行日時の抽出（JST）
jq -r '.message
  | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
  | if .=="" then "N/A" else (.date+"T"+.time+":00+09:00") end' /tmp/day11_dryrun.json
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

2. 本番実行（DAY11_GO_LIVE.sh）
   ├─ 実行直前チェック実行
   ├─ 本番実行（DAY11_FINAL_RUN.sh）
   │   ├─ dryRun実行（自動検証付き）
   │   ├─ 本送信テスト（確認後実行）
   │   ├─ スモークテスト（任意）
   │   └─ 成果物記録（DAY11_SOT_DIFFS.md 自動追記）
   ├─ 合格ライン確認（3点）
   ├─ 追加のワンショット確認（任意）
   └─ 最終レポート追記（任意）

3. 重要ファイル更新
   ├─ OPS-MONITORING-V3-001.md（稼働開始日・責任者）
   └─ Mermaid.md（Day11ノード）
```

---

## 🏁 成功の目印

- ✅ dryRun: `validate_dryrun_json` が **OK**
- ✅ 本送信: `validate_send_json` が **OK**、Slack `#ops-monitor` に1件のみ到達
- ✅ Logs: Supabase Functions 200、指数バックオフの再送なし
- ✅ 記録: `DAY11_SOT_DIFFS.md` 自動追記 + `OPS-MONITORING-V3-001.md` / `Mermaid.md` 更新済み

---

## 📝 実行後の確認事項

1. **Slack #ops-monitor チャンネル**で週次サマリを確認
2. **Supabase Functions Logs**でログを確認（200、再送なし）
3. **重要ファイル**（`OPS-MONITORING-V3-001.md` / `Mermaid.md`）を更新
4. **最終レポート**（SlackメッセージURL）を追記

---

以上で、Day11 の**本番デプロイ～受け入れ確認**は完結可能です。

SlackメッセージURLまたはdryRunの抜粋をご共有いただければ、最終レポートの体裁まで私の方で仕上げます。


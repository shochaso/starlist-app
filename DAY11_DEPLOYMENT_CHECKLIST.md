# Day11「ops-slack-summary」本番デプロイ & 受け入れ確認チェックリスト（実行版）

## 0) 前提と環境変数（Preflight）

まずは実行端末で環境を揃えます。

```bash
# 置き換え必須：<project-ref> と <anon-key>
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# 既に設定済みのはずだが再確認（GitHubとSupabase両方）
# GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY
# Supabase Edge Secret: slack_webhook_ops_summary
```

**確認コマンド:**
```bash
echo "SUPABASE_URL: ${SUPABASE_URL}"
echo "SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..." # 最初の20文字のみ表示
```

---

## 1) DBビューの作成/更新（v_ops_notify_stats）

Supabase Dashboard → SQL Editor でマイグレーション内容を貼付・実行。CLI派は以下でもOKです。

```bash
# SQLファイルがある前提。直貼りでも可。
supabase db execute --file supabase/migrations/20251108_v_ops_notify_stats.sql
```

**確認ポイント:**
- [ ] 14日対象の集計が返ること（期間外がNULL/0補完）
- [ ] 欠損日の0埋めロジックがあること

**確認SQL:**
```sql
-- v_ops_notify_stats の存在確認
SELECT table_name
FROM information_schema.views
WHERE table_name = 'v_ops_notify_stats';

-- ビューの内容確認（サンプル）
SELECT * FROM v_ops_notify_stats
ORDER BY day DESC, level
LIMIT 10;
```

---

## 2) Edge Function デプロイ（ops-slack-summary）

ダッシュボードから Deploy。CLI派は：

```bash
supabase functions deploy ops-slack-summary
```

**Secrets 確認（Supabase側）**
- [ ] `slack_webhook_ops_summary` が設定済み（小文字スネークケース）
- [ ] `supabase_url` が設定済み
- [ ] `supabase_anon_key` が設定済み

**確認方法:**
- Supabase Dashboard → Edge Functions → `ops-slack-summary` → Settings → Secrets

---

## 3) dryRun 実行（JSON検証を自動チェック）

### 3-1. 直接 invoke（Supabase）

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | tee /tmp/day11_dryrun.json | jq
```

### 3-2. 受け入れの自動検証（jq）

```bash
# 必須フィールドの存在
jq -e 'has("ok") and has("period") and has("stats") and has("weekly_summary") and has("message")' /tmp/day11_dryrun.json

# 期待値：ok==true / σが数値 or 0 / 閾値（new_threshold, critical_threshold）存在
jq -e '.ok == true and (.stats.std_dev | type) == "number" and (.stats.new_threshold and .stats.critical_threshold)' /tmp/day11_dryrun.json

# WoWの0除算防御：前週0件でもNaNになっていないこと
jq -e '(.weekly_summary | objects) and (.weekly_summary.normal_change | (type=="string"))' /tmp/day11_dryrun.json

# メッセージの有無（実装で preview 等を返している場合）
jq -e 'has("message") and (.message | type == "string")' /tmp/day11_dryrun.json
```

**dryRun 合格条件（Acceptance）**
- [ ] `ok: true`
- [ ] `stats.mean_notifications`, `stats.std_dev`, `stats.new_threshold`, `stats.critical_threshold` が数値（σ=0許容）
- [ ] `weekly_summary` にNaN/Infinityがない（nullまたは数値/文字列）
- [ ] `message` が含まれ、週次サマリの形式が正しい

**実行結果ログ:**
```
Run ID: （実行後に追記）
実行時刻 (JST): （実行後に追記）
レスポンス: （/tmp/day11_dryrun.json を参照）
```

---

## 4) 本送信テスト（Slack #ops-monitor へ実送信）

### 4-1. SupabaseからInvoke

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=false&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | tee /tmp/day11_send.json | jq
```

### 4-2. GitHub Actionsから（任意）

```bash
gh workflow run ops-slack-summary.yml -f dryRun=false
```

**Slackメッセージの期待形**
- [ ] 見出し：対象週（例：2025-W45）
- [ ] 指標：正常通知/警告通知/重大通知の件数
- [ ] 前週比：WoW%（前週0件の項目は "±0" もしくは "+100%" 表示）
- [ ] 閾値：μ+2σ / μ+3σ
- [ ] 次回自動実行日：翌週月曜 09:00 JST

**実行結果ログ:**
```
Run ID: （実行後に追記）
実行時刻 (JST): （実行後に追記）
Slack投稿時刻: （実行後に追記）
メッセージサンプル: （実行後に追記）
```

---

## 5) ログ・トレース確認（成功トレイル）

**Supabase Logs**
- [ ] 200応答で完了、再送ロジック（指数バックオフ）が発火していない
- [ ] エラー時：Slack 4xx/5xx が無い

**GitHub Actions（使った場合）**
- [ ] `SLACK_WEBHOOK_OPS_SUMMARY` がマスクされている
- [ ] `dryRun=false` で 200 / `ok:true`

**確認コマンド:**
```bash
# GitHub Actions ログ確認
gh run list --workflow=ops-slack-summary.yml --limit 5

# Supabase Functions Logs は Dashboard で確認
# Supabase Dashboard → Edge Functions → ops-slack-summary → Logs
```

---

## 6) 失敗時の即応（主なシナリオと対処）

| 症状 | 典型原因 | 即時対処 |
|------|----------|----------|
| `Missing SLACK_WEBHOOK_OPS_SUMMARY` | Secret未設定/キー名誤り | GitHub: `Settings > Secrets > Actions` で再登録。Supabase側も `slack_webhook_ops_summary` を確認 |
| Slack 400/404 | Webhook URL無効/チャンネル権限 | Webhook再発行。Private CHならBot招待 or 新Webhook |
| σ=null | データ欠損/ビュー0補完漏れ | `v_ops_notify_stats`の0埋めSQLを確認し再デプロイ |
| WoW% NaN | 前週0件扱い漏れ | 実装の0除算防御（分母0 → null/"—"）が動作しているか確認 |

---

## 7) ロールバック

**Edge Function:**
- Supabase Dashboard → Edge Functions → `ops-slack-summary` → 直前バージョンにロールバック

**DB:**
```sql
-- 当該ビューを削除
DROP VIEW IF EXISTS v_ops_notify_stats;

-- 直前SQLで再作成（必要に応じて）
-- supabase/migrations/20251108_v_ops_notify_stats.sql を再実行
```

**GitHub Actions / Cron:**
- GitHub Actions: `.github/workflows/ops-slack-summary.yml` の `schedule` 行をコメントアウト
- Supabase: Edge Function の Invoke を一時停止

---

## 8) 成果物の記録（DoD充足）

**`docs/reports/DAY11_SOT_DIFFS.md`:**
- [ ] dryRunレスポンス（/tmp/day11_dryrun.json の要約）
- [ ] 本送信のHTTP 200ログ、Slackスクショ（メッセージID/時刻）

**`docs/ops/OPS-MONITORING-V3-001.md`:**
- [ ] 稼働開始日、オーナー、障害時連絡先

**`docs/Mermaid.md`:**
- [ ] Day11ノードをDay10直下に追加

---

## 9) Go/No-Go 判定基準（最終）

- [ ] dryRun 合格（上記jq検証がすべてパス）
- [ ] 本送信が #ops-monitor に到達（KPI/閾値/WoW%/次回日付の体裁OK）
- [ ] ログにエラー/再送痕跡なし（通常経路で200完了）
- [ ] ドキュメント3点の更新完了（SOT/運用/Mermaid）

---

## 📋 実行順序サマリー

1. **環境変数設定**（0）
2. **DBビュー作成**（1）
3. **Edge Functionデプロイ**（2）
4. **dryRun実行**（3）
5. **本送信テスト**（4）
6. **ログ確認**（5）
7. **成果物記録**（8）
8. **Go/No-Go判定**（9）

---

## 🚀 自動実行スクリプト

`DAY11_DEPLOY_EXECUTE.sh` を実行すると、上記の手順を自動で進めます：

```bash
# 環境変数設定
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# スクリプト実行
./DAY11_DEPLOY_EXECUTE.sh
```

スクリプトは各ステップで確認を求め、dryRun検証を自動実行します。

---

## 🚀 クイック実行コマンド（まとめ）

```bash
# 1. 環境変数設定
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# 2. DBビュー作成（Supabase Dashboard または CLI）
supabase db execute --file supabase/migrations/20251108_v_ops_notify_stats.sql

# 3. Edge Functionデプロイ（Supabase Dashboard または CLI）
supabase functions deploy ops-slack-summary

# 4. dryRun実行
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | tee /tmp/day11_dryrun.json | jq

# 5. dryRun検証
jq -e 'has("ok") and has("period") and has("stats") and has("weekly_summary") and has("message")' /tmp/day11_dryrun.json
jq -e '.ok == true and (.stats.std_dev | type) == "number"' /tmp/day11_dryrun.json

# 6. 本送信テスト
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=false&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | tee /tmp/day11_send.json | jq

# 7. Slackチャンネル #ops-monitor で確認
```

---

## 📝 注意事項

- Supabase Edge Function Secrets は小文字スネークケース（`slack_webhook_ops_summary`）
- GitHub Actions Secrets は大文字スネークケース（`SLACK_WEBHOOK_OPS_SUMMARY`）
- 両方の環境で設定が必要です
- dryRun実行時は`slack_webhook_ops_summary`が未設定でもエラーになりません（dryRunモードではSlack送信をスキップ）

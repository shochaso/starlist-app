# Day11「ops-slack-summary」本番デプロイ チェックリスト

## ✅ 事前チェック

- [ ] Secrets名称の統一確認（`SLACK_WEBHOOK_OPS_SUMMARY`）
- [ ] DBビュー `v_ops_notify_stats` の存在確認
- [ ] Edge Function `ops-slack-summary` のデプロイ準備

---

## 1) DBビューの適用（14日集計）

**Supabase SQL Editor で実行:**

```sql
-- v_ops_notify_stats の存在確認
SELECT table_name
FROM information_schema.views
WHERE table_name = 'v_ops_notify_stats';

-- 存在しない場合のみ、以下を実行
-- （supabase/migrations/20251108_v_ops_notify_stats.sql の内容）
```

**実行結果:**
- [ ] ビューが存在することを確認
- [ ] または、ビュー作成SQLが正常に実行されたことを確認

---

## 2) Edge Function デプロイ

**Supabase Dashboard → Edge Functions → `ops-slack-summary` → Deploy**

**確認事項:**
- [ ] Edge Function `ops-slack-summary` がデプロイされている
- [ ] Secrets設定が反映されている（`slack_webhook_ops_summary`）

---

## 3) Secrets 設定

**GitHub Actions Secrets:**
- [ ] `SLACK_WEBHOOK_OPS_SUMMARY` が設定されている

**Supabase Edge Function Secrets:**
- [ ] `slack_webhook_ops_summary` が設定されている（小文字スネークケース）

**注意:** 両方の環境で設定が必要です。

---

## 4) dryRun（計算ロジック検証）

**実行コマンド:**
```bash
curl -sS -X POST "https://<project-ref>.supabase.co/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
```

**期待値:**
```json
{
  "ok": true,
  "dryRun": true,
  "period": "14d",
  "stats": {
    "mean_notifications": 37.2,
    "std_dev": 4.8,
    "new_threshold": 46.8,
    "critical_threshold": 51.6
  },
  "weekly_summary": {
    "normal": 42,
    "warning": 3,
    "critical": 1,
    "normal_change": "+6.3%",
    "warning_change": "±0",
    "critical_change": "-50%"
  },
  "message": "📊 OPS Summary Report..."
}
```

**確認事項:**
- [ ] `ok: true` が返る
- [ ] `dryRun: true` が返る
- [ ] `stats` に `mean_notifications`, `std_dev`, `new_threshold`, `critical_threshold` が含まれる
- [ ] `weekly_summary` に `normal`, `warning`, `critical`, `normal_change`, `warning_change`, `critical_change` が含まれる
- [ ] `message` に週次サマリが含まれる
- [ ] σ=0 のデータでもエラーにならない（データが0件の場合）

**実行結果ログ:**
```
Run ID: （実行後に追記）
実行時刻 (JST): （実行後に追記）
レスポンス: （実行後に追記）
```

---

## 5) 本送信（手動実行）

**GitHub Actions から手動実行:**
```bash
gh workflow run ops-slack-summary.yml -f dryRun=false
```

**または、Supabase Dashboard → Edge Functions → `ops-slack-summary` → Invoke**

**確認事項:**
- [ ] Slack `#ops-monitor` に週次サマリが投稿される
- [ ] メッセージに正常通知・警告通知・重大通知の件数が表示される
- [ ] 前週比のパーセンテージが表示される
- [ ] 通知平均・標準偏差・新閾値が表示される
- [ ] 次回自動閾値再算出日（翌週月曜JST）が表示される

**実行結果ログ:**
```
Run ID: （実行後に追記）
実行時刻 (JST): （実行後に追記）
Slack投稿時刻: （実行後に追記）
メッセージサンプル: （実行後に追記）
```

---

## 6) 監査・ログ確認

**GitHub Actions:**
- [ ] `ops-slack-summary.yml` の最新 Job が成功（緑）

**Supabase Functions Logs:**
- [ ] `ops-slack-summary` の200到達を1行確認

**確認コマンド:**
```bash
# GitHub Actions ログ確認
gh run list --workflow=ops-slack-summary.yml --limit 5

# Supabase Functions Logs は Dashboard で確認
```

---

## 7) スケジュール稼働確認

**確認事項:**
- [ ] Cron設定: `0 0 * * 1`（毎週月曜09:00 JST）が正しく設定されている
- [ ] 直近の月曜の自動実行後、Slack到達とActionsの自動トリガー成功を確認

**注意:** 初回実行は次回月曜まで待つ必要があります。

---

## ✅ 受け入れ基準（Acceptance Criteria）

- [ ] `?dryRun=true` で JSON が返る（`mu/σ/threshold/WoW%` を含む）
- [ ] `?dryRun=false` で Slack に週次サマリが投稿される（HTTP 200）
- [ ] 欠損日の0補完・σ=0時の防御が効く（エラーにならない）
- [ ] WoW% が正しく算出される（分母ゼロ時は適切に処理される）
- [ ] 次回再算出日（**翌週月曜（JST）**）がメッセージに表示される
- [ ] Actions / Functions のログで成功判定が追跡できる

---

## 🧯 よくあるエラーと対処

| 症状 | 原因 | 対処 |
|------|------|------|
| 500: Missing SLACK_WEBHOOK_OPS_SUMMARY | Secrets未設定/キー名相違 | キー名を `SLACK_WEBHOOK_OPS_SUMMARY` に統一して再実行 |
| Slack 400/404 | Webhook URL間違い / 権限失効 | 正しいワークスペースの新規Webhookで差し替え |
| JSONでσが`null` | 集計0件／CAST漏れ | ビュー側で0補完＆CAST、関数側でε代入を確認 |
| WoW% がInfinity/NaN | 前週0件の割り算 | 分母0の分岐処理を実装どおりに（0% or N/A） |
| cronが走らない | UTC換算の取り違え | `0 0 * * 1` はJST 09:00、運用曜時の期待と一致を再確認 |

---

## 🔁 ロールバック手順（安全停止）

1. GitHub Actions：`ops-slack-summary.yml` の `schedule` 行をコメントアウト
2. Supabase：`ops-slack-summary` を前タグへロールバック or 一時無効化
3. DB：`v_ops_notify_stats` を旧定義に差し戻し（必要時のみ）

---

## 📝 ドキュメント反映（完了後）

- [ ] `docs/reports/DAY11_SOT_DIFFS.md`：dryRunレス・本送信スクショ・ログ断片を貼付
- [ ] `docs/ops/OPS-MONITORING-V3-001.md`：**稼働開始日／運用責任者／レビュー頻度** を追記
- [ ] `Mermaid.md`：Day11ノード確定（Day10直下）＆"自動閾値調整"の注記


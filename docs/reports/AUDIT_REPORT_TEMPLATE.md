# Day11 & Pricing 統合監査レポート テンプレート

**実行日時**: `<timestamp>`  
**実行者**: `<user>`  
**環境**: `<SUPABASE_URL>`

---

## 1. Preflight Check

- ✅ Environment Variables確認完了
- ✅ SUPABASE_URL形式検証完了（20桁ref）
- ✅ Preflightスクリプト実行完了

### Environment Matrix
```
SUPABASE_URL: <URL>
SUPABASE_ANON_KEY: <masked>
TZ: Asia/Tokyo
```

---

## 2. Day11 Execution

### dryRun結果
```json
{
  "ok": true,
  "stats": {
    "mean_notifications": <number>,
    "std_dev": <number>,
    "new_threshold": <number>,
    "critical_threshold": <number>
  },
  "weekly_summary": {
    "normal": <number>,
    "warning": <number>,
    "critical": <number>,
    "normal_change": "<string>",
    "warning_change": "<string>",
    "critical_change": "<string>"
  },
  "message": "<string>"
}
```

### 本送信結果
```json
{
  "ok": true,
  "permalink": "<Slack permalink>"
}
```

### Permalink
`<SlackメッセージURL>`

### 検証結果
- ✅ dryRun JSON検証OK（validate_stats_block）
- ✅ 本送信JSON検証OK（validate_stats_block）
- ✅ 冪等性チェック完了（重複送信なし）
- ✅ dryRun/send内容比較完了

---

## 3. Pricing E2E Test

### 検証項目
- [ ] 学生プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] 成人プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] plan_price整数検証完了

### DB検証結果
```sql
-- 直近のplan_price保存確認
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
where plan_price is not null
order by updated_at desc
limit 10;
```

**結果**: `<plan_priceが整数の円で保存されていることを確認>`

---

## 4. 合格ライン確認

### Day11（3点）
- ✅ dryRun：`ok=true` かつ `stats/weekly_summary/message` 妥当、`std_dev>=0`・`thresholds>=0`
- ✅ 本送信：JSON妥当、Slack `#ops-monitor` に**1件のみ**到達（permalink取得）
- ✅ ログ：HTTP 2xx、429/5xxは最大2回再試行内で回復、指数バックオフ再送**痕跡なし**

### Pricing（3+1）
- ✅ UI：推奨バッジ表示・刻み/上下限バリデーションOK
- ✅ Checkout→DB：plan_price が整数円で保存
- ✅ Webhook：checkout.* / subscription.* / invoice.* で価格更新反映
- ✅ Logs：Supabase Functions 200、例外なし／再送痕跡なし

---

## 5. ログファイル

### Day11
- dryRun JSON: `logs/day11/<timestamp>_dryrun.json`
- Send JSON: `logs/day11/<timestamp>_send.json`

### Pricing
- Webhook検証ログ: `<pricing logs>`
- E2Eテストログ: `<test logs>`

---

## 6. 次のステップ

1. ✅ Slack #ops-monitor チャンネルで週次サマリを確認
2. ✅ Supabase Functions Logs でログを確認
3. ✅ 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新
4. ✅ PR作成（付属テンプレート使用）

---

## 7. インシデント対処

### 失敗時の復旧手順
1. `DAY11_RECOVERY_TEMPLATE.sh` を実行
2. Slack到達確認（UI確認）
3. Edge Functionログ確認（`supabase functions logs`）
4. DBビュー再集計確認（`v_ops_notify_stats`）
5. Secrets再読込み確認

### ロールバック手順
1. GitHub Actions workflow を無効化
2. Supabase Edge Function を前バージョンにロールバック
3. DBビューを前バージョンにロールバック（必要に応じて）

---

**監査完了日時**: `<timestamp>`  
**監査者**: `<user>`  
**承認**: `<approver>`



**実行日時**: `<timestamp>`  
**実行者**: `<user>`  
**環境**: `<SUPABASE_URL>`

---

## 1. Preflight Check

- ✅ Environment Variables確認完了
- ✅ SUPABASE_URL形式検証完了（20桁ref）
- ✅ Preflightスクリプト実行完了

### Environment Matrix
```
SUPABASE_URL: <URL>
SUPABASE_ANON_KEY: <masked>
TZ: Asia/Tokyo
```

---

## 2. Day11 Execution

### dryRun結果
```json
{
  "ok": true,
  "stats": {
    "mean_notifications": <number>,
    "std_dev": <number>,
    "new_threshold": <number>,
    "critical_threshold": <number>
  },
  "weekly_summary": {
    "normal": <number>,
    "warning": <number>,
    "critical": <number>,
    "normal_change": "<string>",
    "warning_change": "<string>",
    "critical_change": "<string>"
  },
  "message": "<string>"
}
```

### 本送信結果
```json
{
  "ok": true,
  "permalink": "<Slack permalink>"
}
```

### Permalink
`<SlackメッセージURL>`

### 検証結果
- ✅ dryRun JSON検証OK（validate_stats_block）
- ✅ 本送信JSON検証OK（validate_stats_block）
- ✅ 冪等性チェック完了（重複送信なし）
- ✅ dryRun/send内容比較完了

---

## 3. Pricing E2E Test

### 検証項目
- [ ] 学生プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] 成人プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] plan_price整数検証完了

### DB検証結果
```sql
-- 直近のplan_price保存確認
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
where plan_price is not null
order by updated_at desc
limit 10;
```

**結果**: `<plan_priceが整数の円で保存されていることを確認>`

---

## 4. 合格ライン確認

### Day11（3点）
- ✅ dryRun：`ok=true` かつ `stats/weekly_summary/message` 妥当、`std_dev>=0`・`thresholds>=0`
- ✅ 本送信：JSON妥当、Slack `#ops-monitor` に**1件のみ**到達（permalink取得）
- ✅ ログ：HTTP 2xx、429/5xxは最大2回再試行内で回復、指数バックオフ再送**痕跡なし**

### Pricing（3+1）
- ✅ UI：推奨バッジ表示・刻み/上下限バリデーションOK
- ✅ Checkout→DB：plan_price が整数円で保存
- ✅ Webhook：checkout.* / subscription.* / invoice.* で価格更新反映
- ✅ Logs：Supabase Functions 200、例外なし／再送痕跡なし

---

## 5. ログファイル

### Day11
- dryRun JSON: `logs/day11/<timestamp>_dryrun.json`
- Send JSON: `logs/day11/<timestamp>_send.json`

### Pricing
- Webhook検証ログ: `<pricing logs>`
- E2Eテストログ: `<test logs>`

---

## 6. 次のステップ

1. ✅ Slack #ops-monitor チャンネルで週次サマリを確認
2. ✅ Supabase Functions Logs でログを確認
3. ✅ 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新
4. ✅ PR作成（付属テンプレート使用）

---

## 7. インシデント対処

### 失敗時の復旧手順
1. `DAY11_RECOVERY_TEMPLATE.sh` を実行
2. Slack到達確認（UI確認）
3. Edge Functionログ確認（`supabase functions logs`）
4. DBビュー再集計確認（`v_ops_notify_stats`）
5. Secrets再読込み確認

### ロールバック手順
1. GitHub Actions workflow を無効化
2. Supabase Edge Function を前バージョンにロールバック
3. DBビューを前バージョンにロールバック（必要に応じて）

---

**監査完了日時**: `<timestamp>`  
**監査者**: `<user>`  
**承認**: `<approver>`



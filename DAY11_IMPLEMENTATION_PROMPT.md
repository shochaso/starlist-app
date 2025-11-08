# Day11実装指示プロンプト（Mine向け）

## 🎯 タスク

Day11「OPS監視v3 — 自動閾値調整＋週次レポート可視化」の実装を完了してください。

---

## 📋 実装スコープ

### 1. DB View作成（完了済み）

✅ `supabase/migrations/20251108_v_ops_notify_stats.sql` は既に作成済み

**確認事項**:
- Supabase Dashboard → SQL Editor で実行済みか確認
- `SELECT * FROM v_ops_notify_stats LIMIT 10;` で動作確認

### 2. Edge Function実装（要実装）

**ファイル**: `supabase/functions/ops-slack-summary/index.ts`

**要件**:
- 通知履歴集計（`v_ops_notify_stats`から取得）
- 自動閾値計算（平均±標準偏差ベース）
- 週次サマリ生成
- dryRunモード対応
- Slack送信

**アルゴリズム**:
```typescript
// 直近14日間の通知統計を取得
const stats = await supabase.from("v_ops_notify_stats").select("*");

// 通知件数の平均と標準偏差を計算
const notifications = stats.map(s => s.notification_count);
const mean = notifications.reduce((a, b) => a + b, 0) / notifications.length;
const variance = notifications.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / notifications.length;
const stdDev = Math.sqrt(variance);

// 新閾値 = μ + 2σ、異常閾値 = μ + 3σ
const newThreshold = mean + 2 * stdDev;
const criticalThreshold = mean + 3 * stdDev;
```

**週次サマリ生成**:
- 前週比の計算（前週の通知件数と比較）
- Slackメッセージフォーマット（Markdown形式）
- 絵文字アイコン（✅/⚠️/🔥）の使用

**参考**: `supabase/functions/ops-slack-notify/index.ts` の実装パターンを参照

### 3. GitHub Actions実装（要実装）

**ファイル**: `.github/workflows/ops-slack-summary.yml`

**要件**:
- スケジュール実行: 毎週月曜09:00 JST（cron: `0 0 * * 1`）
- 手動実行: `workflow_dispatch`（dryRunオプション付き）
- Secrets検証: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SLACK_WEBHOOK_OPS_SUMMARY`
- URL形式検証・DNS解決（Day10と同様のパターン）

**参考**: `.github/workflows/ops-slack-notify.yml` の実装パターンを参照

---

## 🧩 実装プロンプト（Cursor用）

```
You are an expert TypeScript engineer for Supabase Edge Functions (Deno runtime).

### Task

Create a new Edge Function:

  supabase/functions/ops-slack-summary/index.ts

for Day11 feature "OPS Monitoring v3 — Automatic Threshold Adjustment + Weekly Summary".

### Runtime / APIs

- Supabase Edge Functions on Deno.
- Use the Web standard Request/Response.
- Use Deno.env.get() to read env vars.
- HTTP entry: handle GET/POST on the same endpoint.
- Return JSON. On errors, return { ok:false, error:string } with proper HTTP code.

### Purpose

Weekly OPS summary generator with automatic threshold calculation:

- Aggregate notification history from v_ops_notify_stats view (last 14 days).
- Calculate mean (μ) and standard deviation (σ) of notification counts.
- Compute new thresholds: newThreshold = μ + 2σ, criticalThreshold = μ + 3σ.
- Generate weekly summary message with notification counts by level (NORMAL/WARNING/CRITICAL).
- Compare with previous week (week-over-week change).
- Send to Slack via webhook (SLACK_WEBHOOK_OPS_SUMMARY).
- Support dryRun mode (preview only, no Slack post).

### Env (Supabase Functions: lower_snake_case)

- supabase_url                e.g. https://<project-ref>.supabase.co
- supabase_anon_key           anon public key
- slack_webhook_ops_summary   https://hooks.slack.com/services/... (weekly summary webhook)

### Constraints & Policies

- When dryRun=1 is present (query or JSON body), never send to Slack; return { ok:true, dryRun:true, stats:{...}, weekly_summary:{...}, message:string }.
- Calculate statistics from v_ops_notify_stats view (last 14 days).
- Use mean ± standard deviation algorithm for threshold calculation.
- Format Slack message with emoji indicators (✅/⚠️/🔥).
- Include week-over-week comparison (percentage change).

### DB

- View: v_ops_notify_stats
  - Columns: day, level, notification_count, avg_success_rate, avg_p95_ms, total_errors, delivered_count, failed_count
  - Aggregates ops_slack_notify_logs by day and level (last 14 days)

### Algorithm

1. Fetch stats from v_ops_notify_stats:
   ```sql
   SELECT * FROM v_ops_notify_stats
   WHERE day >= NOW() - INTERVAL '14 days'
   ORDER BY day DESC, level;
   ```

2. Calculate mean and standard deviation:
   ```typescript
   const notifications = stats.map(s => s.notification_count);
   const mean = notifications.reduce((a, b) => a + b, 0) / notifications.length;
   const variance = notifications.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / notifications.length;
   const stdDev = Math.sqrt(variance);
   ```

3. Compute thresholds:
   - newThreshold = mean + 2 * stdDev
   - criticalThreshold = mean + 3 * stdDev

4. Generate weekly summary:
   - Count notifications by level (NORMAL/WARNING/CRITICAL) for current week
   - Compare with previous week (calculate percentage change)
   - Format Slack message

### Slack Message Format

```
📊 OPS Summary Report（{report_week}）
────────────────────────────
✅ 正常通知：{normal_count}件（前週比 {normal_change}）
⚠ 警告通知：{warning_count}件（{warning_change}）
🔥 重大通知：{critical_count}件（{critical_change}）

📈 通知平均：{mean}件 / σ={stdDev}
🔧 新閾値：{newThreshold}件（μ+2σ）

📅 次回自動閾値再算出：{next_date}（月）
────────────────────────────
🧠 コメント：{comment}
```

### API contract

- GET /?dryRun=1   -> preview only
- POST with JSON { dryRun?: boolean } -> if dryRun=false, perform send

### Error handling

- At function start, validate required env: supabase_url, supabase_anon_key.
- If missing, return 500 with missing env: ... .
- Catch database/network errors and return 502 with { ok:false, error }.

### Implementation outline (write full code, not pseudo):

- util: env() reader with required/optional helpers.
- util: jstNow() and isoWeekJST() to compute report_week.
- fetchStats(): query v_ops_notify_stats view.
- calculateThresholds(stats): compute mean, stdDev, newThreshold, criticalThreshold.
- generateWeeklySummary(stats, thresholds): count by level, compare with previous week, format message.
- sendToSlack(webhookUrl, message): send with retry and exponential backoff (max 3 attempts).
- logResult(): save to ops_slack_notify_logs or new table if needed.

### Return shape examples

- DryRun OK:
  { ok: true, dryRun: true, period: "14d", stats: { mean_notifications, std_dev, new_threshold, critical_threshold }, weekly_summary: { normal, warning, critical, normal_change, warning_change, critical_change }, message: "..." }

- Sent OK:
  { ok: true, sent: true, period: "14d", stats: {...}, weekly_summary: {...}, message: "...", sent_at_utc: "...", sent_at_jst: "..." }

### Quality bar

- Strict TS, no any.
- Clear function boundaries.
- Defensive coding for missing configs.
- Small, dependency-free (no external imports besides what Deno/Supabase provides).
- Comments for critical logic.

Now, generate the full TypeScript file content for supabase/functions/ops-slack-summary/index.ts.
Make sure the code is complete and ready to deploy as-is.
```

---

## 📝 実装チェックリスト

- [ ] DB View `v_ops_notify_stats` がSupabase上に作成されている
- [ ] Edge Function `ops-slack-summary/index.ts` が実装されている
- [ ] 自動閾値計算ロジックが正しく動作する
- [ ] 週次サマリメッセージが正しく生成される
- [ ] dryRunモードが動作する
- [ ] GitHub Actionsワークフローが作成されている
- [ ] Secrets設定（`SLACK_WEBHOOK_OPS_SUMMARY`）が準備されている
- [ ] ドキュメントが更新されている

---

## 🚀 実装開始

上記の実装プロンプトをCursorに貼り付けて、Edge Function実装を開始してください。

実装完了後、dryRunテストと本送信テストを実行し、動作確認を行ってください。


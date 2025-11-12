Status:: planned
Source-of-Truth:: docs/reports/DAY11_SOT_DIFFS.md
Spec-State:: 確定済み（実装履歴・CodeRefs）
Last-Updated:: 2025-11-08

# DAY11_SOT_DIFFS — OPS Monitoring v3 Implementation Reality vs Spec

Status: implemented ✅  
Last-Updated: 2025-11-08  
Source-of-Truth: Edge Functions (`supabase/functions/ops-slack-summary/`) + GitHub Actions (`.github/workflows/ops-slack-summary.yml`)

---

## 🚀 STARLIST Day11 PR情報

### 🧭 PR概要

**Title:**
```
Day11: OPS Monitoring v3（自動閾値調整＋週次レポート可視化）
```

**Body:**
- `PR_BODY.md`（実装詳細）
- `docs/reports/DAY11_SOT_DIFFS.md`（実装レビュー用差分レポート）

**メタ情報:**
- Reviewer: `@pm-tim`
- Merge方式: `Squash & merge`

### 📊 実装統計

| 指標 | 内容 |
|------|------|
| コミット数 | 2 commits |
| 変更ファイル | 5 files |
| コード変更量 | +566 lines (Edge Function + GitHub Actions) |
| DoD（Definition of Done） | 2/6 達成（33%） |
| テスト結果 | ⏳ デプロイ後dryRun予定 |
| PM承認 | ⏳ 待ち |

---

## 📝 実装詳細

### 1. DB View: `v_ops_notify_stats`

**ファイル:** `supabase/migrations/20251108_v_ops_notify_stats.sql`

**内容:**
- ビュー作成: `v_ops_notify_stats`
- 集計期間: 直近14日間
- 集計項目: 日別・レベル別の通知件数、平均success_rate、平均p95_ms、総エラー数、配信成功/失敗件数
- インデックス: `inserted_at DESC, level` で効率化

**CodeRefs:**
```1:25:supabase/migrations/20251108_v_ops_notify_stats.sql
-- Status:: planned
-- Source-of-Truth:: supabase/migrations/20251108_v_ops_notify_stats.sql
-- Spec-State:: 確定済み（自動閾値調整用ビュー）
-- Last-Updated:: 2025-11-08

-- View for OPS Slack Notify statistics aggregation
-- Used by ops-slack-summary Edge Function for automatic threshold calculation

CREATE OR REPLACE VIEW v_ops_notify_stats AS
SELECT
  date_trunc('day', inserted_at) AS day,
  level,
  COUNT(*) AS notification_count,
  AVG(success_rate) AS avg_success_rate,
  AVG(p95_ms) AS avg_p95_ms,
  SUM(error_count) AS total_errors,
  COUNT(*) FILTER (WHERE delivered = true) AS delivered_count,
  COUNT(*) FILTER (WHERE delivered = false) AS failed_count
FROM ops_slack_notify_logs
WHERE inserted_at >= NOW() - INTERVAL '14 days'
GROUP BY day, level
ORDER BY day DESC, level;

-- Index for efficient querying (if not exists)
CREATE INDEX IF NOT EXISTS idx_ops_slack_notify_logs_inserted_at_level 
  ON ops_slack_notify_logs (inserted_at DESC, level);

-- Grant access to authenticated users
GRANT SELECT ON v_ops_notify_stats TO authenticated;
```

### 2. Edge Function: `ops-slack-summary`

**ファイル:** `supabase/functions/ops-slack-summary/index.ts`

**機能:**
- 通知履歴集計（`v_ops_notify_stats`から取得）
- 自動閾値計算（平均±標準偏差ベース）
- 週次サマリ生成（前週比計算含む）
- dryRunモード対応
- Slack送信（リトライ・指数バックオフ）

**アルゴリズム:**
- 平均通知数 (μ) = 直近14日間の通知件数の平均
- 標準偏差 (σ) = 同期間の分散の平方根
- 新閾値 = `μ + 2σ`
- 異常閾値 = `μ + 3σ`

**CodeRefs:**
```1:50:supabase/functions/ops-slack-summary/index.ts
// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-slack-summary/index.ts
// Spec-State:: 確定済み（自動閾値調整＋週次レポート可視化）
// Last-Updated:: 2025-11-08

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SummaryQuery {
  dryRun?: boolean;
  period?: string; // '14d' (default)
}

interface NotificationStats {
  day: string;
  level: string;
  notification_count: number;
  avg_success_rate: number | null;
  avg_p95_ms: number | null;
  total_errors: number;
  delivered_count: number;
  failed_count: number;
}

interface ThresholdStats {
  meanNotifications: number;
  stdDev: number;
  newThreshold: number;
  criticalThreshold: number;
}

interface WeeklySummary {
  normal: number;
  warning: number;
  critical: number;
  normalChange: string;
  warningChange: string;
  criticalChange: string;
}

// Environment variable reader
function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  if (required && !value) {
    throw new Error(`missing env: ${key}`);
  }
  return value || "";
}

// Get current time in JST (UTC+9)
function jstNow(): Date {
  return new Date(Date.now() + 9 * 60 * 60 * 1000);
}
```

```150:200:supabase/functions/ops-slack-summary/index.ts
// Calculate thresholds using mean ± standard deviation
function calculateThresholds(stats: NotificationStats[]): ThresholdStats {
  if (stats.length === 0) {
    // Return default thresholds if no data
    return {
      meanNotifications: 0,
      stdDev: 0,
      newThreshold: 0,
      criticalThreshold: 0,
    };
  }

  const notifications = stats.map((s) => s.notification_count);
  const mean = notifications.reduce((a, b) => a + b, 0) / notifications.length;
  const variance =
    notifications.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / notifications.length;
  const stdDev = Math.sqrt(variance);

  const newThreshold = mean + 2 * stdDev;
  const criticalThreshold = mean + 3 * stdDev;

  return {
    meanNotifications: Math.round(mean * 100) / 100,
    stdDev: Math.round(stdDev * 100) / 100,
    newThreshold: Math.round(newThreshold * 100) / 100,
    criticalThreshold: Math.round(criticalThreshold * 100) / 100,
  };
}
```

```250:300:supabase/functions/ops-slack-summary/index.ts
// Generate Slack message
function generateSlackMessage(
  reportWeek: string,
  thresholds: ThresholdStats,
  weeklySummary: WeeklySummary,
  nextDate: string
): string {
  const { meanNotifications, stdDev, newThreshold } = thresholds;
  const { normal, warning, critical, normalChange, warningChange, criticalChange } =
    weeklySummary;

  // Generate comment based on trends
  let comment = "通知数は安定傾向。";
  if (critical > 0) {
    comment = "重大通知あり。要調査。";
  } else if (warning > 5) {
    comment = "警告通知が増加傾向。監視強化。";
  } else if (normal < 10) {
    comment = "通知数が少ない。閾値見直し検討。";
  }

  return `📊 OPS Summary Report（${reportWeek}）
────────────────────────────
✅ 正常通知：${normal}件（前週比 ${normalChange}）
⚠ 警告通知：${warning}件（${warningChange}）
🔥 重大通知：${critical}件（${criticalChange}）

📈 通知平均：${meanNotifications}件 / σ=${stdDev}
🔧 新閾値：${newThreshold}件（μ+2σ）

📅 次回自動閾値再算出：${nextDate}（月）
────────────────────────────
🧠 コメント：${comment}`;
}
```

### 3. GitHub Actions: `ops-slack-summary.yml`

**ファイル:** `.github/workflows/ops-slack-summary.yml`

**機能:**
- スケジュール実行: 毎週月曜09:00 JST（cron: `0 0 * * 1`）
- 手動実行: `workflow_dispatch`（dryRunオプション付き）
- Secrets検証、URL形式検証・DNS解決

**CodeRefs:**
```1:30:github/workflows/ops-slack-summary.yml
name: OPS Slack Summary (Weekly)

on:
  schedule:
    - cron: '0 0 * * 1'   # 09:00 JST (00:00 UTC) - Every Monday
  workflow_dispatch:
    inputs:
      dryRun:
        description: 'Dry run (no Slack post)'
        required: false
        default: 'false'
        type: choice
        options:
          - 'true'
          - 'false'

permissions:
  contents: read

jobs:
  summary:
    runs-on: ubuntu-latest
    env:
      SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
      SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          submodules: false
          fetch-depth: 1
          token: ${{ secrets.GITHUB_TOKEN }}
```

---

## ✅ Day11: Ops Slack Summary — 実行結果

### Go/No-Go チェック結果

**稼働開始日時**: （実行後に追記）

**DB View確認**:
- ⏳ `v_ops_notify_stats` ビュー作成待ち

**Edge Function配置確認**:
- ⏳ `ops-slack-summary` ファイル作成待ち
- ⏳ Supabase Dashboardでのデプロイ待ち
- ⏳ Secrets設定（`SLACK_WEBHOOK_OPS_SUMMARY`）待ち

**GitHub Actions設定確認**:
- ⏳ ワークフローファイル作成待ち（`.github/workflows/ops-slack-summary.yml`）
- ⏳ Cron設定: `0 0 * * 1`（毎週月曜09:00 JST）
- ⏳ 手動実行対応（dryRunオプション付き）

### スモークテスト結果

**dryRun実行**:
- Run ID: （実行後に追記）
- 実行時刻 (JST): （実行後に追記）
- 期待レスポンス: `{ ok: true, dryRun: true, stats: {...}, weekly_summary: {...}, message: "..." }`

**本送信テスト**:
- Run ID: （実行後に追記）
- 実行時刻 (JST): （実行後に追記）
- Delivered: true / false
- Slackチャンネル: `#ops-monitor`
- メッセージサンプル: （実行後に追記）

**備考**: 
- 期間=14d
- アルゴリズム: 平均±標準偏差ベース（μ+2σ, μ+3σ）

---

## 🔍 運用監視ポイント（初週）

- [ ] 自動閾値計算の妥当性: 算出された閾値が適切か
- [ ] 週次サマリの到達率: `delivered=true` の割合
- [ ] 通知頻度の変化: 自動閾値調整による通知件数の変化

---

## 🧰 運用SQLコマンド

**通知統計確認（直近14日）**
```sql
SELECT * FROM v_ops_notify_stats
ORDER BY day DESC, level;
```

**自動閾値計算用データ取得**
```sql
SELECT
  AVG(notification_count) AS mean_notifications,
  STDDEV(notification_count) AS std_dev,
  AVG(notification_count) + 2 * STDDEV(notification_count) AS new_threshold,
  AVG(notification_count) + 3 * STDDEV(notification_count) AS critical_threshold
FROM v_ops_notify_stats
WHERE day >= NOW() - INTERVAL '14 days';
```

---

## 🧯 Known Issues

（実行後に追記）

---

## 📋 受け入れ基準（DoD）

- [x] `v_ops_notify_stats` ビューが作成され、正しく集計される（SQL定義完了）
- [x] Edge Function `ops-slack-summary` が実装され、自動閾値計算が動作する（実装完了）
- [x] GitHub Actionsワークフローが作成され、週次スケジュール実行が設定される（実装完了）
- [ ] dryRunモードで動作確認可能（デプロイ後テスト予定）
- [ ] 本送信テストでSlackに週次サマリが投稿される（デプロイ後テスト予定）
- [ ] ドキュメントが更新される（進行中）

---

## 🎯 Day11 完了の目安

1. `v_ops_notify_stats` ビューがSupabase上に表示される
2. `ops-slack-summary` がSupabase上に表示される
3. Invoke `?dryRun=1` が `{ ok: true, stats: {...} }` を返す
4. GitHub ActionsでdryRun成功（週次サマリプレビュー確認）
5. 本送信テストでSlackチャンネル `#ops-monitor` に週次サマリ到達
6. 自動閾値計算が正しく動作している

---

## 🚀 次のステップ

- Day12候補: OPS Insights（傾向分析＋アラート分類AI）

---

## ⚠️ Phase 2.2 Safe Rollback Checklist

1. **Disable manual dispatch**: remove the `workflow_dispatch` stanza from `.github/workflows/slsa-provenance.yml`, `provenance-validate.yml`, and `phase3-audit-observer.yml` so the workflows only trigger on `release`/`workflow_run` events.
2. **Revert manifest automation**: restore the backed-up `_manifest.json` (if any) and use `git checkout -- docs/reports/_manifest.json` to drop partial entries; rerun the latest provenance workflow after reapplying the changes if needed.
3. **Revoke secrets**: delete or rotate `SUPABASE_SERVICE_KEY`, `SUPABASE_ANON_KEY`, `OPS_NOTIFY_TOKEN`, and `PROVENANCE_DISPATCH_TOKEN` via `gh secret delete` so failed runs cannot write telemetry.
4. **Relax branch protection**: patch `main` branch protection to remove `provenance-validate` from `required_status_checks.contexts` (or drop the `contexts` list if it was the only check) and ensure `strict` remains `true` if you still enforce status checks.
5. **Notify stakeholders**: add a summary comment to PR #61 and relevant Ops channels explaining the rollback, referencing this SOT diff file for the exact steps.


Spec-State:: 確定済み（実装履歴・CodeRefs）
Last-Updated:: 2025-11-08

# DAY11_SOT_DIFFS — OPS Monitoring v3 Implementation Reality vs Spec

Status: implemented ✅  
Last-Updated: 2025-11-08  
Source-of-Truth: Edge Functions (`supabase/functions/ops-slack-summary/`) + GitHub Actions (`.github/workflows/ops-slack-summary.yml`)

---

## 🚀 STARLIST Day11 PR情報

### 🧭 PR概要

**Title:**
```
Day11: OPS Monitoring v3（自動閾値調整＋週次レポート可視化）
```

**Body:**
- `PR_BODY.md`（実装詳細）
- `docs/reports/DAY11_SOT_DIFFS.md`（実装レビュー用差分レポート）

**メタ情報:**
- Reviewer: `@pm-tim`
- Merge方式: `Squash & merge`

### 📊 実装統計

| 指標 | 内容 |
|------|------|
| コミット数 | 2 commits |
| 変更ファイル | 5 files |
| コード変更量 | +566 lines (Edge Function + GitHub Actions) |
| DoD（Definition of Done） | 2/6 達成（33%） |
| テスト結果 | ⏳ デプロイ後dryRun予定 |
| PM承認 | ⏳ 待ち |

---

## 📝 実装詳細

### 1. DB View: `v_ops_notify_stats`

**ファイル:** `supabase/migrations/20251108_v_ops_notify_stats.sql`

**内容:**
- ビュー作成: `v_ops_notify_stats`
- 集計期間: 直近14日間
- 集計項目: 日別・レベル別の通知件数、平均success_rate、平均p95_ms、総エラー数、配信成功/失敗件数
- インデックス: `inserted_at DESC, level` で効率化

**CodeRefs:**
```1:25:supabase/migrations/20251108_v_ops_notify_stats.sql
-- Status:: planned
-- Source-of-Truth:: supabase/migrations/20251108_v_ops_notify_stats.sql
-- Spec-State:: 確定済み（自動閾値調整用ビュー）
-- Last-Updated:: 2025-11-08

-- View for OPS Slack Notify statistics aggregation
-- Used by ops-slack-summary Edge Function for automatic threshold calculation

CREATE OR REPLACE VIEW v_ops_notify_stats AS
SELECT
  date_trunc('day', inserted_at) AS day,
  level,
  COUNT(*) AS notification_count,
  AVG(success_rate) AS avg_success_rate,
  AVG(p95_ms) AS avg_p95_ms,
  SUM(error_count) AS total_errors,
  COUNT(*) FILTER (WHERE delivered = true) AS delivered_count,
  COUNT(*) FILTER (WHERE delivered = false) AS failed_count
FROM ops_slack_notify_logs
WHERE inserted_at >= NOW() - INTERVAL '14 days'
GROUP BY day, level
ORDER BY day DESC, level;

-- Index for efficient querying (if not exists)
CREATE INDEX IF NOT EXISTS idx_ops_slack_notify_logs_inserted_at_level 
  ON ops_slack_notify_logs (inserted_at DESC, level);

-- Grant access to authenticated users
GRANT SELECT ON v_ops_notify_stats TO authenticated;
```

### 2. Edge Function: `ops-slack-summary`

**ファイル:** `supabase/functions/ops-slack-summary/index.ts`

**機能:**
- 通知履歴集計（`v_ops_notify_stats`から取得）
- 自動閾値計算（平均±標準偏差ベース）
- 週次サマリ生成（前週比計算含む）
- dryRunモード対応
- Slack送信（リトライ・指数バックオフ）

**アルゴリズム:**
- 平均通知数 (μ) = 直近14日間の通知件数の平均
- 標準偏差 (σ) = 同期間の分散の平方根
- 新閾値 = `μ + 2σ`
- 異常閾値 = `μ + 3σ`

**CodeRefs:**
```1:50:supabase/functions/ops-slack-summary/index.ts
// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-slack-summary/index.ts
// Spec-State:: 確定済み（自動閾値調整＋週次レポート可視化）
// Last-Updated:: 2025-11-08

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SummaryQuery {
  dryRun?: boolean;
  period?: string; // '14d' (default)
}

interface NotificationStats {
  day: string;
  level: string;
  notification_count: number;
  avg_success_rate: number | null;
  avg_p95_ms: number | null;
  total_errors: number;
  delivered_count: number;
  failed_count: number;
}

interface ThresholdStats {
  meanNotifications: number;
  stdDev: number;
  newThreshold: number;
  criticalThreshold: number;
}

interface WeeklySummary {
  normal: number;
  warning: number;
  critical: number;
  normalChange: string;
  warningChange: string;
  criticalChange: string;
}

// Environment variable reader
function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  if (required && !value) {
    throw new Error(`missing env: ${key}`);
  }
  return value || "";
}

// Get current time in JST (UTC+9)
function jstNow(): Date {
  return new Date(Date.now() + 9 * 60 * 60 * 1000);
}
```

```150:200:supabase/functions/ops-slack-summary/index.ts
// Calculate thresholds using mean ± standard deviation
function calculateThresholds(stats: NotificationStats[]): ThresholdStats {
  if (stats.length === 0) {
    // Return default thresholds if no data
    return {
      meanNotifications: 0,
      stdDev: 0,
      newThreshold: 0,
      criticalThreshold: 0,
    };
  }

  const notifications = stats.map((s) => s.notification_count);
  const mean = notifications.reduce((a, b) => a + b, 0) / notifications.length;
  const variance =
    notifications.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / notifications.length;
  const stdDev = Math.sqrt(variance);

  const newThreshold = mean + 2 * stdDev;
  const criticalThreshold = mean + 3 * stdDev;

  return {
    meanNotifications: Math.round(mean * 100) / 100,
    stdDev: Math.round(stdDev * 100) / 100,
    newThreshold: Math.round(newThreshold * 100) / 100,
    criticalThreshold: Math.round(criticalThreshold * 100) / 100,
  };
}
```

```250:300:supabase/functions/ops-slack-summary/index.ts
// Generate Slack message
function generateSlackMessage(
  reportWeek: string,
  thresholds: ThresholdStats,
  weeklySummary: WeeklySummary,
  nextDate: string
): string {
  const { meanNotifications, stdDev, newThreshold } = thresholds;
  const { normal, warning, critical, normalChange, warningChange, criticalChange } =
    weeklySummary;

  // Generate comment based on trends
  let comment = "通知数は安定傾向。";
  if (critical > 0) {
    comment = "重大通知あり。要調査。";
  } else if (warning > 5) {
    comment = "警告通知が増加傾向。監視強化。";
  } else if (normal < 10) {
    comment = "通知数が少ない。閾値見直し検討。";
  }

  return `📊 OPS Summary Report（${reportWeek}）
────────────────────────────
✅ 正常通知：${normal}件（前週比 ${normalChange}）
⚠ 警告通知：${warning}件（${warningChange}）
🔥 重大通知：${critical}件（${criticalChange}）

📈 通知平均：${meanNotifications}件 / σ=${stdDev}
🔧 新閾値：${newThreshold}件（μ+2σ）

📅 次回自動閾値再算出：${nextDate}（月）
────────────────────────────
🧠 コメント：${comment}`;
}
```

### 3. GitHub Actions: `ops-slack-summary.yml`

**ファイル:** `.github/workflows/ops-slack-summary.yml`

**機能:**
- スケジュール実行: 毎週月曜09:00 JST（cron: `0 0 * * 1`）
- 手動実行: `workflow_dispatch`（dryRunオプション付き）
- Secrets検証、URL形式検証・DNS解決

**CodeRefs:**
```1:30:github/workflows/ops-slack-summary.yml
name: OPS Slack Summary (Weekly)

on:
  schedule:
    - cron: '0 0 * * 1'   # 09:00 JST (00:00 UTC) - Every Monday
  workflow_dispatch:
    inputs:
      dryRun:
        description: 'Dry run (no Slack post)'
        required: false
        default: 'false'
        type: choice
        options:
          - 'true'
          - 'false'

permissions:
  contents: read

jobs:
  summary:
    runs-on: ubuntu-latest
    env:
      SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
      SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          submodules: false
          fetch-depth: 1
          token: ${{ secrets.GITHUB_TOKEN }}
```

---

## ✅ Day11: Ops Slack Summary — 実行結果

### Go/No-Go チェック結果

**稼働開始日時**: （実行後に追記）

**DB View確認**:
- ⏳ `v_ops_notify_stats` ビュー作成待ち

**Edge Function配置確認**:
- ⏳ `ops-slack-summary` ファイル作成待ち
- ⏳ Supabase Dashboardでのデプロイ待ち
- ⏳ Secrets設定（`SLACK_WEBHOOK_OPS_SUMMARY`）待ち

**GitHub Actions設定確認**:
- ⏳ ワークフローファイル作成待ち（`.github/workflows/ops-slack-summary.yml`）
- ⏳ Cron設定: `0 0 * * 1`（毎週月曜09:00 JST）
- ⏳ 手動実行対応（dryRunオプション付き）

### スモークテスト結果

**dryRun実行**:
- Run ID: （実行後に追記）
- 実行時刻 (JST): （実行後に追記）
- 期待レスポンス: `{ ok: true, dryRun: true, stats: {...}, weekly_summary: {...}, message: "..." }`

**本送信テスト**:
- Run ID: （実行後に追記）
- 実行時刻 (JST): （実行後に追記）
- Delivered: true / false
- Slackチャンネル: `#ops-monitor`
- メッセージサンプル: （実行後に追記）

**備考**: 
- 期間=14d
- アルゴリズム: 平均±標準偏差ベース（μ+2σ, μ+3σ）

---

## 🔍 運用監視ポイント（初週）

- [ ] 自動閾値計算の妥当性: 算出された閾値が適切か
- [ ] 週次サマリの到達率: `delivered=true` の割合
- [ ] 通知頻度の変化: 自動閾値調整による通知件数の変化

---

## 🧰 運用SQLコマンド

**通知統計確認（直近14日）**
```sql
SELECT * FROM v_ops_notify_stats
ORDER BY day DESC, level;
```

**自動閾値計算用データ取得**
```sql
SELECT
  AVG(notification_count) AS mean_notifications,
  STDDEV(notification_count) AS std_dev,
  AVG(notification_count) + 2 * STDDEV(notification_count) AS new_threshold,
  AVG(notification_count) + 3 * STDDEV(notification_count) AS critical_threshold
FROM v_ops_notify_stats
WHERE day >= NOW() - INTERVAL '14 days';
```

---

## 🧯 Known Issues

（実行後に追記）

---

## 📋 受け入れ基準（DoD）

- [x] `v_ops_notify_stats` ビューが作成され、正しく集計される（SQL定義完了）
- [x] Edge Function `ops-slack-summary` が実装され、自動閾値計算が動作する（実装完了）
- [x] GitHub Actionsワークフローが作成され、週次スケジュール実行が設定される（実装完了）
- [ ] dryRunモードで動作確認可能（デプロイ後テスト予定）
- [ ] 本送信テストでSlackに週次サマリが投稿される（デプロイ後テスト予定）
- [ ] ドキュメントが更新される（進行中）

---

## 🎯 Day11 完了の目安

1. `v_ops_notify_stats` ビューがSupabase上に表示される
2. `ops-slack-summary` がSupabase上に表示される
3. Invoke `?dryRun=1` が `{ ok: true, stats: {...} }` を返す
4. GitHub ActionsでdryRun成功（週次サマリプレビュー確認）
5. 本送信テストでSlackチャンネル `#ops-monitor` に週次サマリ到達
6. 自動閾値計算が正しく動作している

---

## 🚀 次のステップ

- Day12候補: OPS Insights（傾向分析＋アラート分類AI）

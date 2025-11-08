Status:: planned
Source-of-Truth:: docs/reports/DAY11_SOT_DIFFS.md
Spec-State:: 確定済み（実装履歴・CodeRefs）
Last-Updated:: 2025-11-08

# DAY11_SOT_DIFFS — OPS Monitoring v3 Implementation Reality vs Spec

Status: planned ⏳  
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
| コミット数 | （実行後に追記） |
| 変更ファイル | （実行後に追記） |
| コード変更量 | （実行後に追記） |
| DoD（Definition of Done） | 0/6 達成（0%） |
| テスト結果 | ⏳ 予定 |
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
- 週次サマリ生成
- dryRunモード対応
- Slack送信

**アルゴリズム:**
- 平均通知数 (μ) = 直近14日間の通知件数の平均
- 標準偏差 (σ) = 同期間の分散の平方根
- 新閾値 = `μ + 2σ`
- 異常閾値 = `μ + 3σ`

**CodeRefs:**
（実装後に追記）

### 3. GitHub Actions: `ops-slack-summary.yml`

**ファイル:** `.github/workflows/ops-slack-summary.yml`

**機能:**
- スケジュール実行: 毎週月曜09:00 JST（cron: `0 0 * * 1`）
- 手動実行: `workflow_dispatch`（dryRunオプション付き）
- Secrets検証、URL形式検証・DNS解決

**CodeRefs:**
（実装後に追記）

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

- [ ] `v_ops_notify_stats` ビューが作成され、正しく集計される
- [ ] Edge Function `ops-slack-summary` が実装され、自動閾値計算が動作する
- [ ] GitHub Actionsワークフローが作成され、週次スケジュール実行が設定される
- [ ] dryRunモードで動作確認可能
- [ ] 本送信テストでSlackに週次サマリが投稿される
- [ ] ドキュメントが更新される

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


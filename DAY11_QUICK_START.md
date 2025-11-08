# Day11 クイックスタートガイド

## 前提条件

1. Supabaseプロジェクトが作成済み
2. `ops_slack_notify_logs` テーブルにデータが存在（Day10で作成済み）
3. Slack Webhook URLが準備済み

## 実行手順

### 1. 環境変数設定

```bash
# 実際の値に置き換えてください
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"
```

### 2. DBビュー作成

**Supabase Dashboard で実行:**

1. Supabase Dashboard → SQL Editor
2. 以下のSQLを実行:

```sql
-- supabase/migrations/20251108_v_ops_notify_stats.sql の内容
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

CREATE INDEX IF NOT EXISTS idx_ops_slack_notify_logs_inserted_at_level 
  ON ops_slack_notify_logs (inserted_at DESC, level);

GRANT SELECT ON v_ops_notify_stats TO authenticated;
```

### 3. Edge Functionデプロイ

**Supabase Dashboard で実行:**

1. Supabase Dashboard → Edge Functions
2. `ops-slack-summary` を選択（存在しない場合は作成）
3. `supabase/functions/ops-slack-summary/index.ts` の内容をコピー＆ペースト
4. Deploy をクリック

**Secrets設定:**

1. Edge Functions → `ops-slack-summary` → Settings → Secrets
2. 以下を追加:
   - `slack_webhook_ops_summary`: Slack Webhook URL
   - `supabase_url`: Supabase URL（通常は自動設定）
   - `supabase_anon_key`: Supabase Anon Key（通常は自動設定）

### 4. dryRun実行

```bash
# 環境変数が設定済みの場合
./DAY11_DEPLOY_EXECUTE.sh

# または手動実行
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
```

### 5. 本送信テスト

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=false&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
```

Slack `#ops-monitor` チャンネルで週次サマリを確認してください。

### 6. 成果物記録

以下のファイルを更新してください:

- `docs/reports/DAY11_SOT_DIFFS.md`: dryRun/本送信結果を追記
- `docs/ops/OPS-MONITORING-V3-001.md`: 稼働開始日、運用責任者を追記
- `docs/Mermaid.md`: Day11ノードを追加

## トラブルシューティング

詳細は `DAY11_DEPLOYMENT_CHECKLIST.md` の「失敗時の即応対処」セクションを参照してください。


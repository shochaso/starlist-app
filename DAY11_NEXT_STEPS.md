# Day11 次のステップ実行ガイド

## 現在の状況

✅ Day11の実装とデプロイ準備は完了しています
⚠️  実際のデプロイには手動設定が必要です

## 実行手順（順番に実行）

### Step 1: 環境変数設定

```bash
# 実際の値に置き換えてください
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"
```

**取得方法:**
- Supabase Dashboard → Project Settings → API
- `Project URL` と `anon public` key をコピー

### Step 2: DBビュー作成（Supabase Dashboard）

1. Supabase Dashboard → SQL Editor
2. 以下のSQLを実行:

```sql
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

3. 実行結果を確認（エラーがないこと）

### Step 3: Edge Functionデプロイ（Supabase Dashboard）

1. Supabase Dashboard → Edge Functions
2. `ops-slack-summary` を選択（存在しない場合は「Create a new function」）
3. `supabase/functions/ops-slack-summary/index.ts` の内容をコピー＆ペースト
4. **Settings → Secrets** で以下を設定:
   - `slack_webhook_ops_summary`: Slack Webhook URL
   - `supabase_url`: （通常は自動設定）
   - `supabase_anon_key`: （通常は自動設定）
5. **Deploy** をクリック

### Step 4: dryRun実行

環境変数が設定済みの場合:

```bash
./DAY11_DEPLOY_EXECUTE.sh
```

または手動実行:

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=true&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
```

**期待される結果:**
- `ok: true`
- `dryRun: true`
- `stats` に統計情報が含まれる
- `weekly_summary` に週次サマリが含まれる
- `message` にSlackメッセージが含まれる

### Step 5: 本送信テスト

```bash
curl -sS -X POST "$SUPABASE_URL/functions/v1/ops-slack-summary?dryRun=false&period=14d" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
```

**確認事項:**
- Slack `#ops-monitor` チャンネルに週次サマリが投稿される
- メッセージに正常通知・警告通知・重大通知の件数が表示される
- 前週比のパーセンテージが表示される
- 通知平均・標準偏差・新閾値が表示される
- 次回自動閾値再算出日（翌週月曜JST）が表示される

### Step 6: 成果物記録

以下のファイルを更新してください:

1. **docs/reports/DAY11_SOT_DIFFS.md**
   - dryRunレスポンスを追記
   - 本送信結果を追記
   - Slackスクショを添付

2. **docs/ops/OPS-MONITORING-V3-001.md**
   - 稼働開始日を追記
   - 運用責任者を追記
   - 連絡先を追記

3. **docs/Mermaid.md**
   - Day11ノードをDay10直下に追加

### Step 7: Go/No-Go判定

以下の基準を満たしているか確認:

- [ ] dryRun検証すべて合格
- [ ] Slack本送信が到達し体裁OK
- [ ] ログにエラー/再送痕跡なし
- [ ] 3文書更新（SOT/運用/Mermaid）

すべて満たしている場合、Day11は **Go** です！

## トラブルシューティング

詳細は `DAY11_DEPLOYMENT_CHECKLIST.md` の「失敗時の即応対処」セクションを参照してください。


# 🚀 本番デプロイ実行ランブック（Day10 OPS Slack Notify）

**作成日**: 2025-11-08  
**ステータス**: ⏳ デプロイ待ち

---

## 0) 事前前提（再確認）

- [ ] Slack Webhook を **`#ops-monitor`** 用に発行済み
- [ ] `SLACK_WEBHOOK_OPS` を **Supabase Edge の Secrets** に登録予定
- [ ] `ops_slack_notify_logs` の **Migration SQL** が用意済み

**確認コマンド**:
```bash
# ファイル存在確認
ls -la supabase/functions/ops-slack-notify/index.ts
ls -la supabase/migrations/20251108_ops_slack_notify_logs.sql
```

---

## 1) DBマイグレーション

**Supabase Dashboard → SQL Editor** に貼付して実行

```sql
-- 既に実行済みならスキップOK
select to_regclass('public.ops_slack_notify_logs');

-- null なら未作成 → マイグレーションSQLを実行
```

**マイグレーションSQL実行**:
```sql
-- supabase/migrations/20251108_ops_slack_notify_logs.sql の内容をコピーして実行
-- または、Supabase CLI経由:
-- supabase db push
```

**確認**:
```sql
-- テーブル存在確認
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'ops_slack_notify_logs'
);

-- RLS有効確認
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'ops_slack_notify_logs';
```

---

## 2) Edge Function デプロイ

### デプロイ手順

1. **Supabase Dashboard → Edge Functions → Deploy new**
2. **Name**: `ops-slack-notify`
3. **Code**: `supabase/functions/ops-slack-notify/index.ts` の内容を貼付
4. **Save & Deploy**

### Secrets 登録

**Supabase Dashboard → Edge Functions → ops-slack-notify → Secrets**

```
Key: SLACK_WEBHOOK_OPS
Val: https://hooks.slack.com/services/xxx/yyy/zzz
```

**確認**:
- Secretsに `SLACK_WEBHOOK_OPS` が表示されていること
- 値が正しいWebhook URLであること

---

## 3) dryRun（Slack投稿なしの整形確認）

```bash
# 変数を設定
PROJECT_REF="<project-ref>"
ANON_KEY="<anon-key>"

# dryRun実行
curl -sS -X POST "https://${PROJECT_REF}.supabase.co/functions/v1/ops-slack-notify?dryRun=true" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
```

**期待レスポンス**:
```json
{
  "ok": true,
  "dryRun": true,
  "level": "NORMAL",
  "metrics": {
    "success_rate": 99.9,
    "p95_ms": 150,
    "error_count": 0
  },
  "message": "✅ OPS Monitor — 2025-11-08 09:00 JST\nStatus: NORMAL\n..."
}
```

**確認ポイント**:
- [ ] `ok: true`
- [ ] `dryRun: true`
- [ ] `level` が `NORMAL` / `WARNING` / `CRITICAL` のいずれか
- [ ] `metrics` に `success_rate`, `p95_ms`, `error_count` が含まれる
- [ ] `message` にSlackメッセージ本文が含まれる

---

## 4) 本送信テスト（手動）

### GitHub Actions経由（推奨）

1. **GitHub → Actions → Ops Slack Notify (Daily) → Run workflow**
2. **Input**: `dryRun=false`
3. **Branch**: `main`
4. **Run workflow** をクリック

### 直接curl実行（代替）

```bash
# 変数を設定
PROJECT_REF="<project-ref>"
ANON_KEY="<anon-key>"

# 本送信実行
curl -sS -X POST "https://${PROJECT_REF}.supabase.co/functions/v1/ops-slack-notify?range=24h" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
```

**確認ポイント**:
- [ ] Slackチャンネル `#ops-monitor` に通知到達
- [ ] 先頭アイコン（✅/⚠️/🔥）とメトリクス値が整合
- [ ] `ops_slack_notify_logs` にレコードが記録される

---

## 5) 監査ログ確認（コピペ）

### 直近10件

```sql
select level, delivered, response_status, inserted_at
from ops_slack_notify_logs
order by inserted_at desc
limit 10;
```

### 日別×重大度（7日）

```sql
select date_trunc('day', inserted_at) d, level, count(*)
from ops_slack_notify_logs
where inserted_at >= now() - interval '7 days'
group by 1,2
order by 1 desc, 2;
```

### 最新ペイロード

```sql
select payload
from ops_slack_notify_logs
order by inserted_at desc
limit 1;
```

### 送信失敗確認

```sql
select level, delivered, response_status, response_body, inserted_at
from ops_slack_notify_logs
where delivered = false
order by inserted_at desc
limit 10;
```

---

## 6) 受け入れ判定（DoD v2）

- [ ] dryRun の出力整形が仕様どおり
- [ ] 本送信が Slack に到達し、**ops_slack_notify_logs** に監査が残る
- [ ] `Critical/Warning/Normal` がしきい値どおりに判定
- [ ] `.github/workflows/ops-slack-notify.yml` が **09:00 JST** に自動実行（次週確認）

**しきい値確認**:
- Critical: `success_rate < 98.0%` OR `p95_ms >= 1500ms`
- Warning: `98.0% ≤ success_rate < 99.5%` OR `1000 ≤ p95_ms < 1500ms`
- Normal: 上記以外

---

## 7) 定常運用ルール（軽量）

- **初見者**: `👀` を付与
- **担当**: `🛠` を付与
- **解消**: `✅` を付与
- **スレッド**: 原因/対処/再発防止を1行ずつ残す
- **誤検知 > 3/週**: しきい値を ±(0.2pp / 100ms) 調整

---

## 🧯 トラブル時の即応（よくある3件）

### 1. Slack 403/400

**症状**: `response_status: 403` または `400`

**原因**: Webhook URL誤り or 失効

**対応**:
1. Supabase Dashboard → Edge Functions → ops-slack-notify → Secrets
2. `SLACK_WEBHOOK_OPS` の値を確認・再設定
3. Edge Functionを再デプロイ

**確認コマンド**:
```bash
# Webhook URLの形式確認
echo "$SLACK_WEBHOOK_OPS" | grep -E '^https://hooks\.slack\.com/services/[A-Z0-9]+/[A-Z0-9]+/[A-Z0-9]+$'
```

### 2. DB 取得エラー

**症状**: `v_ops_5min` 参照失敗

**原因**: 権限不足 or ビュー不存在

**対応**:
1. Supabase Dashboard → SQL Editor
2. ビュー存在確認:
   ```sql
   SELECT EXISTS (
     SELECT FROM information_schema.views 
     WHERE table_schema = 'public' 
     AND table_name = 'v_ops_5min'
   );
   ```
3. 権限付与（必要に応じて）:
   ```sql
   GRANT SELECT ON v_ops_5min TO authenticated;
   ```

### 3. RLS により INSERT 失敗

**症状**: `ops_slack_notify_logs` へのINSERT失敗

**原因**: RLSポリシーが不適切

**対応**:
1. Supabase Dashboard → SQL Editor
2. RLSポリシー確認:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'ops_slack_notify_logs';
   ```
3. Edge Function用ポリシー追加（必要に応じて）:
   ```sql
   -- 既存のマイグレーションSQLに含まれているはずだが、確認
   -- supabase/migrations/20251108_ops_slack_notify_logs.sql を参照
   ```

---

## 🔄 ロールバック（SRE最小手順）

### 1. GitHub Actions を Disable

```bash
# GitHub CLI経由
gh workflow disable ops-slack-notify.yml

# または、GitHub Dashboard → Actions → Ops Slack Notify → Disable workflow
```

### 2. Supabase Edge Function を Deactivate

**Supabase Dashboard → Edge Functions → ops-slack-notify → Deactivate**

または、前バージョンにロールバック:
- Supabase Dashboard → Edge Functions → ops-slack-notify → Versions → 前バージョンを選択

### 3. 監査テーブルは保持

- `ops_slack_notify_logs` テーブルは削除せず、事後分析に使用

---

## 📝 ドキュメント反映（今日中）

### DAY10_SOT_DIFFS.md に追記

- 稼働開始日時（JST）
- 最初の通知スクリーンショット/テキスト
- 監査SQL実行結果
- 既知の注意点

### DAY10_GONOGO_CHECKLIST.md に追記

- 実行実績に ✅ を付与
- スクリーンショット貼付
- 実行ログを記録

---

## ✅ 実行ログ

### DBマイグレーション

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **備考**: （実行後に追記）

### Edge Functionデプロイ

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **備考**: （実行後に追記）

### dryRun実行

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **レスポンス**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗

### 本送信テスト

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **Slack通知到達**: ✅ 到達 / ❌ 未到達
- **メッセージサンプル**: （実行後に追記）
- **監査ログ確認**: ✅ 記録済み / ❌ 未記録

### 受け入れ判定

- **判定日時**: （実行後に追記）
- **判定者**: （実行後に追記）
- **結果**: ✅ 承認 / ❌ 差し戻し
- **備考**: （実行後に追記）

---

## 🎯 完了の目安

1. ✅ DBマイグレーション完了
2. ✅ Edge Functionデプロイ完了
3. ✅ Secrets設定完了
4. ✅ dryRun成功
5. ✅ 本送信テスト成功
6. ✅ 監査ログ確認完了
7. ✅ 受け入れ基準（DoD v2）達成
8. ✅ ドキュメント反映完了

**全て完了したら、Day10は「本番運用クローズ」判定です。**



**作成日**: 2025-11-08  
**ステータス**: ⏳ デプロイ待ち

---

## 0) 事前前提（再確認）

- [ ] Slack Webhook を **`#ops-monitor`** 用に発行済み
- [ ] `SLACK_WEBHOOK_OPS` を **Supabase Edge の Secrets** に登録予定
- [ ] `ops_slack_notify_logs` の **Migration SQL** が用意済み

**確認コマンド**:
```bash
# ファイル存在確認
ls -la supabase/functions/ops-slack-notify/index.ts
ls -la supabase/migrations/20251108_ops_slack_notify_logs.sql
```

---

## 1) DBマイグレーション

**Supabase Dashboard → SQL Editor** に貼付して実行

```sql
-- 既に実行済みならスキップOK
select to_regclass('public.ops_slack_notify_logs');

-- null なら未作成 → マイグレーションSQLを実行
```

**マイグレーションSQL実行**:
```sql
-- supabase/migrations/20251108_ops_slack_notify_logs.sql の内容をコピーして実行
-- または、Supabase CLI経由:
-- supabase db push
```

**確認**:
```sql
-- テーブル存在確認
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'ops_slack_notify_logs'
);

-- RLS有効確認
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'ops_slack_notify_logs';
```

---

## 2) Edge Function デプロイ

### デプロイ手順

1. **Supabase Dashboard → Edge Functions → Deploy new**
2. **Name**: `ops-slack-notify`
3. **Code**: `supabase/functions/ops-slack-notify/index.ts` の内容を貼付
4. **Save & Deploy**

### Secrets 登録

**Supabase Dashboard → Edge Functions → ops-slack-notify → Secrets**

```
Key: SLACK_WEBHOOK_OPS
Val: https://hooks.slack.com/services/xxx/yyy/zzz
```

**確認**:
- Secretsに `SLACK_WEBHOOK_OPS` が表示されていること
- 値が正しいWebhook URLであること

---

## 3) dryRun（Slack投稿なしの整形確認）

```bash
# 変数を設定
PROJECT_REF="<project-ref>"
ANON_KEY="<anon-key>"

# dryRun実行
curl -sS -X POST "https://${PROJECT_REF}.supabase.co/functions/v1/ops-slack-notify?dryRun=true" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
```

**期待レスポンス**:
```json
{
  "ok": true,
  "dryRun": true,
  "level": "NORMAL",
  "metrics": {
    "success_rate": 99.9,
    "p95_ms": 150,
    "error_count": 0
  },
  "message": "✅ OPS Monitor — 2025-11-08 09:00 JST\nStatus: NORMAL\n..."
}
```

**確認ポイント**:
- [ ] `ok: true`
- [ ] `dryRun: true`
- [ ] `level` が `NORMAL` / `WARNING` / `CRITICAL` のいずれか
- [ ] `metrics` に `success_rate`, `p95_ms`, `error_count` が含まれる
- [ ] `message` にSlackメッセージ本文が含まれる

---

## 4) 本送信テスト（手動）

### GitHub Actions経由（推奨）

1. **GitHub → Actions → Ops Slack Notify (Daily) → Run workflow**
2. **Input**: `dryRun=false`
3. **Branch**: `main`
4. **Run workflow** をクリック

### 直接curl実行（代替）

```bash
# 変数を設定
PROJECT_REF="<project-ref>"
ANON_KEY="<anon-key>"

# 本送信実行
curl -sS -X POST "https://${PROJECT_REF}.supabase.co/functions/v1/ops-slack-notify?range=24h" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
```

**確認ポイント**:
- [ ] Slackチャンネル `#ops-monitor` に通知到達
- [ ] 先頭アイコン（✅/⚠️/🔥）とメトリクス値が整合
- [ ] `ops_slack_notify_logs` にレコードが記録される

---

## 5) 監査ログ確認（コピペ）

### 直近10件

```sql
select level, delivered, response_status, inserted_at
from ops_slack_notify_logs
order by inserted_at desc
limit 10;
```

### 日別×重大度（7日）

```sql
select date_trunc('day', inserted_at) d, level, count(*)
from ops_slack_notify_logs
where inserted_at >= now() - interval '7 days'
group by 1,2
order by 1 desc, 2;
```

### 最新ペイロード

```sql
select payload
from ops_slack_notify_logs
order by inserted_at desc
limit 1;
```

### 送信失敗確認

```sql
select level, delivered, response_status, response_body, inserted_at
from ops_slack_notify_logs
where delivered = false
order by inserted_at desc
limit 10;
```

---

## 6) 受け入れ判定（DoD v2）

- [ ] dryRun の出力整形が仕様どおり
- [ ] 本送信が Slack に到達し、**ops_slack_notify_logs** に監査が残る
- [ ] `Critical/Warning/Normal` がしきい値どおりに判定
- [ ] `.github/workflows/ops-slack-notify.yml` が **09:00 JST** に自動実行（次週確認）

**しきい値確認**:
- Critical: `success_rate < 98.0%` OR `p95_ms >= 1500ms`
- Warning: `98.0% ≤ success_rate < 99.5%` OR `1000 ≤ p95_ms < 1500ms`
- Normal: 上記以外

---

## 7) 定常運用ルール（軽量）

- **初見者**: `👀` を付与
- **担当**: `🛠` を付与
- **解消**: `✅` を付与
- **スレッド**: 原因/対処/再発防止を1行ずつ残す
- **誤検知 > 3/週**: しきい値を ±(0.2pp / 100ms) 調整

---

## 🧯 トラブル時の即応（よくある3件）

### 1. Slack 403/400

**症状**: `response_status: 403` または `400`

**原因**: Webhook URL誤り or 失効

**対応**:
1. Supabase Dashboard → Edge Functions → ops-slack-notify → Secrets
2. `SLACK_WEBHOOK_OPS` の値を確認・再設定
3. Edge Functionを再デプロイ

**確認コマンド**:
```bash
# Webhook URLの形式確認
echo "$SLACK_WEBHOOK_OPS" | grep -E '^https://hooks\.slack\.com/services/[A-Z0-9]+/[A-Z0-9]+/[A-Z0-9]+$'
```

### 2. DB 取得エラー

**症状**: `v_ops_5min` 参照失敗

**原因**: 権限不足 or ビュー不存在

**対応**:
1. Supabase Dashboard → SQL Editor
2. ビュー存在確認:
   ```sql
   SELECT EXISTS (
     SELECT FROM information_schema.views 
     WHERE table_schema = 'public' 
     AND table_name = 'v_ops_5min'
   );
   ```
3. 権限付与（必要に応じて）:
   ```sql
   GRANT SELECT ON v_ops_5min TO authenticated;
   ```

### 3. RLS により INSERT 失敗

**症状**: `ops_slack_notify_logs` へのINSERT失敗

**原因**: RLSポリシーが不適切

**対応**:
1. Supabase Dashboard → SQL Editor
2. RLSポリシー確認:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'ops_slack_notify_logs';
   ```
3. Edge Function用ポリシー追加（必要に応じて）:
   ```sql
   -- 既存のマイグレーションSQLに含まれているはずだが、確認
   -- supabase/migrations/20251108_ops_slack_notify_logs.sql を参照
   ```

---

## 🔄 ロールバック（SRE最小手順）

### 1. GitHub Actions を Disable

```bash
# GitHub CLI経由
gh workflow disable ops-slack-notify.yml

# または、GitHub Dashboard → Actions → Ops Slack Notify → Disable workflow
```

### 2. Supabase Edge Function を Deactivate

**Supabase Dashboard → Edge Functions → ops-slack-notify → Deactivate**

または、前バージョンにロールバック:
- Supabase Dashboard → Edge Functions → ops-slack-notify → Versions → 前バージョンを選択

### 3. 監査テーブルは保持

- `ops_slack_notify_logs` テーブルは削除せず、事後分析に使用

---

## 📝 ドキュメント反映（今日中）

### DAY10_SOT_DIFFS.md に追記

- 稼働開始日時（JST）
- 最初の通知スクリーンショット/テキスト
- 監査SQL実行結果
- 既知の注意点

### DAY10_GONOGO_CHECKLIST.md に追記

- 実行実績に ✅ を付与
- スクリーンショット貼付
- 実行ログを記録

---

## ✅ 実行ログ

### DBマイグレーション

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **備考**: （実行後に追記）

### Edge Functionデプロイ

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **備考**: （実行後に追記）

### dryRun実行

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **レスポンス**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗

### 本送信テスト

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **Slack通知到達**: ✅ 到達 / ❌ 未到達
- **メッセージサンプル**: （実行後に追記）
- **監査ログ確認**: ✅ 記録済み / ❌ 未記録

### 受け入れ判定

- **判定日時**: （実行後に追記）
- **判定者**: （実行後に追記）
- **結果**: ✅ 承認 / ❌ 差し戻し
- **備考**: （実行後に追記）

---

## 🎯 完了の目安

1. ✅ DBマイグレーション完了
2. ✅ Edge Functionデプロイ完了
3. ✅ Secrets設定完了
4. ✅ dryRun成功
5. ✅ 本送信テスト成功
6. ✅ 監査ログ確認完了
7. ✅ 受け入れ基準（DoD v2）達成
8. ✅ ドキュメント反映完了

**全て完了したら、Day10は「本番運用クローズ」判定です。**



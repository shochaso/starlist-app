# Day10 Go/No-Go チェックリスト

**作成日**: 2025-11-08  
**ステータス**: ⏳ デプロイ待ち

---

## ✅ Go/No-Go チェック（所要10分）

### 1. Edge Function 配置確認

- [x] `supabase/functions/ops-slack-notify/index.ts` ファイル作成済み
- [ ] Supabase Functions に `ops-slack-notify` が表示・最新版であること
- [ ] `SLACK_WEBHOOK_OPS` が**プロジェクト環境のSecrets**に設定済み（漏えい回避）

**確認方法**:
1. Supabase Dashboard → Edge Functions
2. `ops-slack-notify` が表示されているか確認
3. Secrets → `SLACK_WEBHOOK_OPS` が設定されているか確認

### 2. GitHub Actions 設定確認

- [x] `.github/workflows/ops-slack-notify.yml` ファイル作成済み
- [x] Cron設定: `0 0 * * *`（= 09:00 JST）
- [ ] リポジトリの Secrets に `SUPABASE_URL` / `SUPABASE_ANON_KEY` が設定済み

**確認方法**:
```bash
gh secret list
```

### 3. DB/RLS

- [x] `supabase/migrations/20251108_ops_slack_notify_logs.sql` ファイル作成済み
- [ ] `ops_slack_notify_logs` が作成済み・RLS有効
- [ ] 読み取り用ロール（管理者）でSELECT可能

**確認方法**:
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

## 🔎 スモークテスト（dryRun→実送）

### 1. dryRun（Slack未送信・整形のみ）

```bash
curl -sS -X POST "https://<project-ref>.supabase.co/functions/v1/ops-slack-notify?dryRun=true" \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{}'
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

### 2. 本送信（ステージング→本番）

```bash
# GitHub Actions経由（推奨）
gh workflow run ops-slack-notify.yml -f dryRun=false

# または直接curl
curl -sS -X POST "https://<project-ref>.supabase.co/functions/v1/ops-slack-notify?range=24h" \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**確認ポイント**:
- Slack `#ops-monitor` に通知到達
- 先頭アイコン（✅/⚠️/🔥）とメトリクス値が整合
- `ops_slack_notify_logs` にレコードが記録される

---

## 📊 監査・可観測性クエリ（コピペ）

### 直近10件の送信ログ

```sql
select level, delivered, response_status, inserted_at
from ops_slack_notify_logs
order by inserted_at desc
limit 10;
```

### 日別の重大度サマリ（直近7日）

```sql
select date_trunc('day', inserted_at) AS d, level, count(*) 
from ops_slack_notify_logs
where inserted_at >= now() - interval '7 days'
group by 1,2
order by 1 desc, 2;
```

### 最新1件のペイロード確認

```sql
select payload
from ops_slack_notify_logs
order by inserted_at desc
limit 1;
```

---

## 🎯 受け入れ基準（DoD v2 / Day10）

- [ ] 09:00 JST の自動実行で Slack 通知が**毎日**到達
- [ ] 失敗時でも `ops_slack_notify_logs` に**監査レコードが残る**（`delivered=false` で可視化）
- [ ] `Critical/Warning/Normal` の3段階が**閾値通りに振り分け**られる
- [ ] `dryRun=true` の結果が**PRプレビュー**で確認可能（手動実行OK）
- [x] SOT：`docs/reports/DAY10_SOT_DIFFS.md` に**稼働初日結果**・**しきい値**・**運用手順**を追記

---

## 🧭 運用ルール（Slack）

- **チャンネル**: `#ops-monitor`
- **重大度アイコン規約**: ✅Normal / ⚠️Warning / 🔥Critical
- **反応規約**: 初見者が `👀`、担当者が `🛠`、解消で `✅` を付与
- **スレッド**: 原因/対処/再発防止の3点メモを最低1行で残す
- **誤検知**: 3回/週を超えたら**しきい値見直し**（下記チューニング）

---

## 🔧 チューニング計画（1週間運用後）

- `success_rate` しきい値：`98.0% / 99.5%` を±0.2pp で再評価
- `p95_ms`：`1000/1500ms` をトラフィック帯に応じ±100ms 調整
- 主要エンドポイント別の重み付け（例：`/api/ocr` は警告閾値を厳しめ）をオプション化

---

## 🧯 ロールバック手順（失敗時）

1. **GitHub Actions を `Disable`**
   - GitHub → Actions → Ops Slack Notify → Disable workflow

2. **Supabase `ops-slack-notify` を前バージョンへロールバック or 無効化**
   - Supabase Dashboard → Edge Functions → ops-slack-notify → 前バージョンにロールバック
   - または、Secrets `SLACK_WEBHOOK_OPS` を削除して無効化

3. **`ops_slack_notify_logs` は保持して振り返り分析に活用**
   - ログテーブルは削除せず、事後分析に使用

4. **代替：Day9の週次メール運用のみで継続**
   - Day9の `ops-summary-email` は継続運用可能

---

## 📝 実行ログ

### DBマイグレーション

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **確認SQL**: `select to_regclass('public.ops_slack_notify_logs');`
- **備考**: （実行後に追記）

### Edge Functionデプロイ

- **実行日時**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **Secrets設定**: ✅ 完了 / ❌ 未完了
- **備考**: （実行後に追記）

### dryRun実行結果

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **レスポンス**: （実行後に追記）
- **結果**: ✅ 成功 / ❌ 失敗
- **スクリーンショット**: （実行後に追記）

### 本送信テスト結果

- **実行日時**: （実行後に追記）
- **Run ID**: （実行後に追記）
- **Slack通知到達**: ✅ 到達 / ❌ 未到達
- **メッセージサンプル**: （実行後に追記）
- **監査ログ確認**: ✅ 記録済み / ❌ 未記録
- **スクリーンショット**: （実行後に追記）

### 監査ログ確認

- **確認日時**: （実行後に追記）
- **直近10件**: （実行後に追記）
- **日別サマリ**: （実行後に追記）
- **最新ペイロード**: （実行後に追記）

---

## ✅ 最終承認

- [ ] 全てのチェック項目が完了
- [ ] dryRunが成功
- [ ] 本送信テストが成功
- [ ] 監査ログが正常に記録されている
- [ ] 運用ルールをチームに共有済み

**承認者**: （実行後に追記）  
**承認日時**: （実行後に追記）


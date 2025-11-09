# インシデントRunbook

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: Ops Team

---

## 目的

週次Ops配信（メール/Slack）の失敗を5分で切り分ける

---

## 手順（貼って実行）

### 1) Slack送信APIの疎通

```bash
curl -s -X POST -H 'Content-type: application/json' \
  --data '{"text":"probe"}' \
  "$SLACK_WEBHOOK_URL"
```

**期待値**: HTTP 200 OK

**失敗時**: `SLACK_WEBHOOK_URL`環境変数を確認

---

### 2) Resend APIキー/送信元の検証（dryRun）

```bash
curl -s https://api.resend.com/emails \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "noreply@starlist.jp",
    "to": "test@example.com",
    "subject": "Test",
    "html": "<p>Test</p>"
  }' | jq .
```

**期待値**: `id`フィールドが返る

**失敗時**: `RESEND_API_KEY`を確認、API制限を確認

---

### 3) Edge Function ログ

```bash
# Supabase Functions ログ確認
supabase functions logs \
  --project-ref <PROJECT_REF> \
  --name ops-summary-email \
  --since 1h

# または GitHub Actions ログ
gh run list --workflow ops-slack-summary.yml --limit 5
gh run view <RUN_ID> --log
```

**確認ポイント**:
- エラーメッセージの有無
- 実行時刻と頻度
- レスポンスステータス

---

### 4) データベース接続確認

```bash
# Supabase接続確認
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM ops_slack_notify_logs WHERE inserted_at > NOW() - INTERVAL '1 hour';"
```

**期待値**: レコード数が返る

**失敗時**: `DATABASE_URL`を確認、RLSポリシーを確認

---

### 5) 一時的な回避策

#### Slack通知のみ失敗

```bash
# 手動でSlack通知を送信
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Weekly OPS summary (manual)"}' \
  "$SLACK_WEBHOOK_URL"
```

#### メール送信のみ失敗

```bash
# Edge Functionを手動実行
curl -X POST \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "https://<PROJECT_REF>.supabase.co/functions/v1/ops-summary-email" \
  -H "Content-Type: application/json" \
  -d '{"dryRun": true}'
```

---

## エスカレーション

### Level 1: 自動復旧（5分以内）

- APIキーの再設定
- 環境変数の確認
- ログの確認

### Level 2: 手動介入（15分以内）

- Edge Functionの再デプロイ
- データベース接続の確認
- 外部サービス（Resend/Slack）のステータス確認

### Level 3: 緊急対応（30分以内）

- PM/SecOpsへの通知
- 代替手段での通知（手動Slack投稿など）
- インシデントレポートの作成

---

## 関連ドキュメント

- OPS Slack Notify実装: `docs/reports/DAY10_SOT_DIFFS.md`
- デプロイランブック: `DAY10_DEPLOYMENT_RUNBOOK.md`
- セキュリティロードマップ: `docs/security/SEC_HARDENING_ROADMAP.md`

---

**作成日**: 2025-11-09


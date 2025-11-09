# Supabase環境変数設定ガイド

## 必要な環境変数

以下の環境変数をSupabase DashboardまたはCI Secretsに設定してください。

### 1. OPS_ALLOWED_ORIGINS

**値**: `https://starlist.jp,https://app.starlist.jp`

**設定場所**:
- Supabase Dashboard → Project Settings → Edge Functions → Environment Variables
- GitHub Actions Secrets（CI/CD用）

**説明**: CORS許可オリジンの最小化。正規オリジンのみを許可します。

### 2. OPS_SERVICE_SECRET

**値**: `<long-random-string>`（長いランダム文字列を生成）

**生成方法**:
```bash
openssl rand -hex 32
# または
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**設定場所**:
- Supabase Dashboard → Project Settings → Edge Functions → Environment Variables
- GitHub Actions Secrets（CI/CD用）

**説明**: サービス間認証用のシークレット。Edge Functions間の通信で使用します。

## 設定手順

### Supabase Dashboard

1. Supabase Dashboardにログイン
2. プロジェクトを選択
3. Settings → Edge Functions → Environment Variables
4. 以下の変数を追加:
   - `OPS_ALLOWED_ORIGINS` = `https://starlist.jp,https://app.starlist.jp`
   - `OPS_SERVICE_SECRET` = `<生成したランダム文字列>`

### GitHub Actions Secrets

1. GitHubリポジトリ → Settings → Secrets and variables → Actions
2. New repository secret をクリック
3. 以下のシークレットを追加:
   - `OPS_ALLOWED_ORIGINS` = `https://starlist.jp,https://app.starlist.jp`
   - `OPS_SERVICE_SECRET` = `<生成したランダム文字列>`

## 確認方法

設定後、以下のコマンドで確認できます:

```bash
# Supabase CLI経由
supabase secrets list

# Edge Functionから確認（デバッグ用）
curl -X POST "https://<project-ref>.supabase.co/functions/v1/ops-slack-summary" \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"dryRun": true}'
```

## セキュリティ注意事項

- `OPS_SERVICE_SECRET`は絶対にGitにコミットしないでください
- 定期的にローテーション（3-6ヶ月ごと）を推奨
- 本番環境とステージング環境で異なる値を設定してください


## 必要な環境変数

以下の環境変数をSupabase DashboardまたはCI Secretsに設定してください。

### 1. OPS_ALLOWED_ORIGINS

**値**: `https://starlist.jp,https://app.starlist.jp`

**設定場所**:
- Supabase Dashboard → Project Settings → Edge Functions → Environment Variables
- GitHub Actions Secrets（CI/CD用）

**説明**: CORS許可オリジンの最小化。正規オリジンのみを許可します。

### 2. OPS_SERVICE_SECRET

**値**: `<long-random-string>`（長いランダム文字列を生成）

**生成方法**:
```bash
openssl rand -hex 32
# または
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**設定場所**:
- Supabase Dashboard → Project Settings → Edge Functions → Environment Variables
- GitHub Actions Secrets（CI/CD用）

**説明**: サービス間認証用のシークレット。Edge Functions間の通信で使用します。

## 設定手順

### Supabase Dashboard

1. Supabase Dashboardにログイン
2. プロジェクトを選択
3. Settings → Edge Functions → Environment Variables
4. 以下の変数を追加:
   - `OPS_ALLOWED_ORIGINS` = `https://starlist.jp,https://app.starlist.jp`
   - `OPS_SERVICE_SECRET` = `<生成したランダム文字列>`

### GitHub Actions Secrets

1. GitHubリポジトリ → Settings → Secrets and variables → Actions
2. New repository secret をクリック
3. 以下のシークレットを追加:
   - `OPS_ALLOWED_ORIGINS` = `https://starlist.jp,https://app.starlist.jp`
   - `OPS_SERVICE_SECRET` = `<生成したランダム文字列>`

## 確認方法

設定後、以下のコマンドで確認できます:

```bash
# Supabase CLI経由
supabase secrets list

# Edge Functionから確認（デバッグ用）
curl -X POST "https://<project-ref>.supabase.co/functions/v1/ops-slack-summary" \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"dryRun": true}'
```

## セキュリティ注意事項

- `OPS_SERVICE_SECRET`は絶対にGitにコミットしないでください
- 定期的にローテーション（3-6ヶ月ごと）を推奨
- 本番環境とステージング環境で異なる値を設定してください


# CSP本番反映 - トラブルシューティング結果

## 実行日時
2025-11-11 15:26 UTC

## 事実確認結果

### 検証対象URL
- **PROD (apex)**: `https://starlist.jp`
- **VERCEL alias**: `https://starlist-app.vercel.app`

### CSPヘッダーの検証結果

| URL | CSPヘッダー | 判定 |
|-----|------------|------|
| PROD (apex) | ❌ なし | Cloudflare経由でVercelから配信されているがCSPなし |
| VERCEL alias | ❌ なし | Vercel直でもCSPヘッダーなし |

### 検出された情報

#### PROD (apex)
- `server: cloudflare` - Cloudflareプロキシ経由
- `x-vercel-cache: HIT` - Vercelから配信
- DNS: Cloudflare IP（104.21.62.53, 172.67.220.105）

#### VERCEL alias
- `server: Vercel` - Vercel直配信
- `x-vercel-cache: HIT`
- `x-vercel-id: kix1::gckhv-1762874752877-42ec6c6fead6`

### 問題の特定

**判定**: `vercel.json`がデプロイに反映されていない（ルート①：Vercel由来の未反映）

**根拠**:
- Vercel aliasでもCSPヘッダーが出ていない
- `vercel.json`はリポジトリルート直下に存在し、設定も正しい
- mainブランチに空コミットをpushして再デプロイを試みたが、まだ反映されていない

## 原因の可能性

### 1. VercelプロジェクトのRoot Directory設定（最有力）
- VercelプロジェクトのRoot Directoryが`vercel.json`を含む階層に設定されていない可能性
- モノレポの場合、正しいディレクトリを指定する必要がある

### 2. Vercelプロジェクト設定
- ヘッダー設定が無効化されている可能性
- プロジェクト設定で確認が必要

### 3. デプロイキャッシュ
- 古いデプロイがキャッシュされている可能性
- Vercelダッシュボードから手動で再デプロイが必要

## 対処方法

### 即時対応（推奨）

1. **Vercelダッシュボードで確認**
   
   - Project → Settings → General → **Root Directory**
   - Root Directoryが空（ルート）または正しいディレクトリに設定されているか確認
   - モノレポの場合、`vercel.json`が存在するディレクトリを指定

2. **プロジェクト設定でヘッダー設定を確認**
   - Project → Settings → General
   - ヘッダー設定が有効になっているか確認

3. **最新コミットで手動再デプロイ**
   - Deployments → **Redeploy**（最新コミットを選択）
   - または、Vercel CLIで `vercel --prod` を実行

4. **再デプロイ後の確認**
   ```bash
   curl -sI https://starlist-app.vercel.app | grep -i '^content-security-policy:'
   ```

### 代替案：Cloudflare側でCSP設定

Vercel側で反映されない場合、Cloudflare側でCSPを設定する方法：

1. **Cloudflareダッシュボード → Rules → Transform Rules → HTTP Response Header Modification**
   - Action: **Set**
   - Header: `Content-Security-Policy`
   - Value: `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests`
   - Filter: `http.host eq "starlist.jp"`

## 次のステップ

1. ✅ 事実確認完了（Vercel aliasでもCSPなし）
2. ⏳ VercelダッシュボードでRoot Directory確認
3. ⏳ プロジェクト設定でヘッダー設定確認
4. ⏳ 最新コミットで手動再デプロイ
5. ⏳ 再デプロイ後、CSPヘッダー確認
6. ⏳ CSP確認後、CI検証ワークフロー再実行

## 関連ファイル

- `vercel.json` - Vercel設定（CSPヘッダー含む）
- `.github/workflows/csp-verify.yml` - CSP検証ワークフロー
- `docs/ops/CSP_VERIFICATION_REPORT.md` - 検証レポート



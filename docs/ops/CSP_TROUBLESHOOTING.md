---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# CSP検証 - トラブルシューティング結果

## 実行日時
2025-11-11 15:16 UTC

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
- `x-vercel-id: hnd1::bllp5-1762874149484-40088fc98017`
- DNS: Cloudflare IP（104.21.62.53, 172.67.220.105）

#### VERCEL alias
- `server: Vercel` - Vercel直配信
- `x-vercel-cache: HIT`
- `x-vercel-id: kix1::qthk8-1762874174210-24713d1d2e38`

### 問題の特定

**判定**: `vercel.json`がデプロイに反映されていない

**根拠**:
- Vercel aliasでもCSPヘッダーが出ていない
- `vercel.json`はリポジトリルート直下に存在し、設定も正しい
- これはVercelプロジェクト設定またはデプロイの問題を示唆

## 原因の可能性

### 1. VercelプロジェクトのRoot Directory設定
- VercelプロジェクトのRoot Directoryが`vercel.json`を含む階層に設定されていない可能性
- モノレポの場合、正しいディレクトリを指定する必要がある

### 2. デプロイが古い状態
- `vercel.json`を追加したコミットがデプロイに含まれていない可能性
- 最新コミットで再デプロイが必要

### 3. Vercelプロジェクト設定
- ヘッダー設定が無効化されている可能性
- プロジェクト設定で確認が必要

## 対処方法

### 即時対応（推奨）

1. **Vercelダッシュボードで確認**
   - Project → Settings → General → **Root Directory**
   - Root Directoryが空（ルート）または正しいディレクトリに設定されているか確認

2. **最新コミットで再デプロイ**
   - Deployments → **Redeploy**（最新コミットを選択）
   - または、mainブランチに空コミットをプッシュしてデプロイをトリガー

3. **再デプロイ後の確認**
   ```bash
   curl -sI https://starlist-app.vercel.app | grep -i '^content-security-policy:'
   ```

### 確認コマンド

```bash
# Vercel aliasでCSP確認
curl -sI https://starlist-app.vercel.app | tr -d '\r' | grep -i '^content-security-policy:'

# PROD (apex)でCSP確認
curl -sI https://starlist.jp | tr -d '\r' | grep -i '^content-security-policy:'
```

## 次のステップ

1. ✅ 事実確認完了（Vercel aliasでもCSPなし）
2. ⏳ VercelダッシュボードでRoot Directory確認
3. ⏳ 最新コミットで再デプロイ
4. ⏳ 再デプロイ後、CSPヘッダー確認
5. ⏳ CSP確認後、CI検証ワークフロー再実行

## 関連ファイル

- `vercel.json` - Vercel設定（CSPヘッダー含む）
- `.github/workflows/csp-verify.yml` - CSP検証ワークフロー
- `docs/ops/CSP_VERIFICATION_REPORT.md` - 検証レポート

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

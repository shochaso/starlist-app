---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# CSP検証結果レポート

## 実行日時
2025-11-11 15:10 UTC

## 検証結果

### ワークフロー実行結果
- **RUN_ID**: 19269913160
- **ステータス**: failure
- **URL**: https://github.com/shochaso/starlist-app/actions/runs/19269913160
- **結論**: CSPヘッダーが本番環境に設定されていない

### 詳細

#### 検証対象URL
- `https://starlist.jp` (CSP_VERIFY_URL Secretから取得)

#### 検証結果
- **CSPヘッダーの存在**: ❌ 見つかりませんでした
- **期待**: 1つのCSPヘッダー
- **実際**: 0個のCSPヘッダー

#### 検出されたヘッダー
- `content-type: text/html; charset=utf-8`
- `server: cloudflare`
- `x-vercel-cache: HIT`
- `x-vercel-id: sfo1::mzcs2-1762873817443-335d524a515d`
- その他のVercel/Cloudflareヘッダー

#### 問題点
1. **CSPヘッダーが設定されていない**
   - `vercel.json`にCSP設定は存在するが、デプロイに反映されていない可能性
   - または、デプロイがまだ完了していない可能性

2. **配信レイヤーの確認が必要**
   - Vercelから配信されていることを確認
   - Cloudflareがプロキシとして動作している可能性

## 次のアクション

### 1. デプロイ状況の確認
```bash
# Vercelデプロイ状況を確認
vercel ls

# 最新のデプロイを確認
vercel inspect <deployment-url>
```

### 2. CSP設定の再確認
- `vercel.json`の設定が正しいか確認
- `_headers`ファイルが正しくデプロイされているか確認
- Nginx設定（該当する場合）を確認

### 3. デプロイの再実行
CSP設定を反映するために、再デプロイが必要な可能性があります。

### 4. 検証の再実行
デプロイ完了後、再度ワークフローを実行：
```bash
gh workflow run csp-verify.yml
```

## 設定ファイル確認

### vercel.json
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; ..."
        }
      ]
    }
  ]
}
```

### _headers
```
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; ...
```

## 推奨事項

1. **デプロイの確認**: Vercelダッシュボードで最新のデプロイを確認
2. **設定の検証**: `vercel.json`と`_headers`の設定が一致しているか確認
3. **再デプロイ**: 必要に応じて手動で再デプロイを実行
4. **検証の再実行**: デプロイ完了後、CSP検証ワークフローを再実行

## 関連ドキュメント
- `.github/workflows/csp-verify.yml` - CSP検証ワークフロー
- `vercel.json` - Vercel設定（CSPヘッダー含む）
- `_headers` - Cloudflare Pages用ヘッダー設定

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

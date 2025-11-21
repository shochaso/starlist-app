---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Linear Smoke Test - 失敗時のプレイブック

## 60秒プレイブック

| 症状 | よくある原因 | いまやる対処 |
|------|------------|------------|
| GraphQL 401/403 | `LINEAR_API_KEY` 誤り/権限不足 | 新APIキー発行→Actions Secrets & ローカルを更新 |
| `errors[].message` が出る | TeamID/入力不整合 | `LINEAR_TEAM_ID` を Linear UI で再確認／jq入力のタイプ再点検 |
| 日本語・改行で壊れる | 引用符/改行の素直な混在 | `.envrc` は **$'...'** を基本に（例をガイドへ追記済） |
| CIだけ落ちる | Secrets未設定／Runner差 | Workflow の `env` と Secrets 名をP2Pで合わせる |

## 詳細トラブルシューティング

### GraphQL 401/403 エラー

**症状**: `Argument Validation Error` または `Unauthorized`

**原因**:
- `LINEAR_API_KEY` が無効または期限切れ
- APIキーの権限不足

**対処**:
1. Linear Personal API Keyを再発行
   - Linear → Settings → API → Personal API keys
   - 新しいキーを生成
2. 環境変数を更新
   - GitHub Actions Secrets: `LINEAR_API_KEY`
   - ローカル: `.envrc` または環境変数
3. 再実行

### `errors[].message` が表示される

**症状**: GraphQL APIからエラーメッセージが返る

**原因**:
- `LINEAR_TEAM_ID` が無効
- Issue作成時の入力値が不正

**対処**:
1. `LINEAR_TEAM_ID` を確認
   ```bash
   curl -sS -X POST https://api.linear.app/graphql \
     -H "Content-Type: application/json" \
     -H "Authorization: ${LINEAR_API_KEY}" \
     -d '{"query": "query { teams { nodes { id name key } } }"}' \
     | jq -r '.data.teams.nodes[] | "\(.key): \(.name) (ID: \(.id))"'
   ```
2. 正しい `LINEAR_TEAM_ID` を設定
3. 再実行

### 日本語・改行で壊れる

**症状**: 説明文が正しく保存されない、JSONエスケープエラー

**原因**:
- `.envrc` で通常の文字列リテラルを使用している
- 改行が正しく処理されていない

**対処**:
1. `.envrc` を `$'...'` 形式に変更
   ```bash
   # ✅ 推奨
   export LINEAR_ISSUE_DESCRIPTION=$'{{ISSUE_KEY}}: 🚀 Test issue\n- ✅ Check 1'
   
   # ❌ 非推奨
   export LINEAR_ISSUE_DESCRIPTION="Line 1
   Line 2"
   ```
2. `direnv allow` で再読み込み
3. 再実行

### CIだけ落ちる

**症状**: ローカルでは成功するが、GitHub Actionsで失敗

**原因**:
- GitHub Actions Secretsが設定されていない
- Secrets名がワークフローと不一致

**対処**:
1. GitHub Actions Secretsを確認
   - Settings → Secrets and variables → Actions
   - `LINEAR_API_KEY` と `LINEAR_TEAM_ID` が設定されているか確認
2. ワークフローの `env` セクションを確認
   - `.github/workflows/linear-smoke.yml` の `env` と一致しているか確認
3. 再実行

## ロールバック手順

**影響範囲**: LinearにIssueを1つ作るだけの無害系

**戻し方**:
1. `scripts/create-linear-issue.sh` のコミットを revert
2. `.github/workflows/linear-smoke.yml` のコミットを revert
3. Branch Protectionから `linear-smoke` を削除（UI）

**注意**: Revertはファイル2点のみで完了します。

## 関連ドキュメント

- `docs/ops/LINEAR_API_KEY_SETUP.md` - セットアップガイド
- `docs/reports/SECURITY/LINEAR_SMOKE/YYYY-MM-DD.md` - 監査ログ

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

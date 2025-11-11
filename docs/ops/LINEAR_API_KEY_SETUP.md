# Linear API Key セットアップガイド

## 概要

Linear Personal API Keyを取得して、環境変数として設定する手順です。

## 手順

### 1. Linear Personal API Keyの取得

1. Linearにログイン: https://linear.app
2. **Settings** → **API** → **Personal API keys**
3. **Create new key** をクリック
4. キー名を入力（例: `starlist-automation`）
5. 生成されたキーをコピー（**一度しか表示されません**）

### 2. 環境変数の設定

#### direnvを使用する場合（推奨）

`.envrc`ファイルを作成または編集:

```bash
export LINEAR_API_KEY='lin_api_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
export LINEAR_TEAM_ID='team_xxxxxxxxxxxxxxxxxxxxxxxx'  # オプション: チーム一覧問い合わせをスキップ
export LINEAR_ISSUE_DESCRIPTION=$'{{ISSUE_KEY}}: title here\n- bullet point'
```

`.envrc`を有効化:

```bash
direnv allow
```

#### シェルで直接設定する場合

```bash
export LINEAR_API_KEY='lin_api_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
export LINEAR_TEAM_ID='team_xxxxxxxxxxxxxxxxxxxxxxxx'  # オプション
export LINEAR_ISSUE_DESCRIPTION=$'{{ISSUE_KEY}}: title here\n- bullet point'
```

### 3. テンプレート安全化ガイド

`LINEAR_ISSUE_DESCRIPTION`に改行・引用符・絵文字を含める場合の注意点:

#### 改行を含む場合

**推奨**: `$'...'`形式を使用

```bash
export LINEAR_ISSUE_DESCRIPTION=$'{{ISSUE_KEY}}: title here\n- bullet point\n- another point'
```

**避ける**: 通常の文字列リテラル（改行が正しく処理されない可能性）

```bash
# ❌ 非推奨
export LINEAR_ISSUE_DESCRIPTION="Line 1
Line 2"
```

#### 引用符を含む場合

`jq`が自動的にJSONエスケープするため、そのまま使用可能:

```bash
export LINEAR_ISSUE_DESCRIPTION='Template test: {{ISSUE_KEY}} — JSON escape check: quotes " and newlines \n ok.'
```

#### 絵文字を含む場合

UTF-8エンコーディングでそのまま使用可能:

```bash
export LINEAR_ISSUE_DESCRIPTION=$'{{ISSUE_KEY}}: 🚀 Test issue\n- ✅ Check 1\n- ✅ Check 2'
```

### 4. 検証

スクリプトを実行して動作確認:

```bash
bash scripts/create-linear-issue.sh STA-TEST "Test issue title"
```

成功時の出力例:

```
✅ Linear: created STA-123 https://linear.app/starlist-app/issue/STA-123
```

### 5. トラブルシューティング

#### API Keyが無効な場合

エラーメッセージ: `Argument Validation Error`

対処:
1. Linear Personal API Keyが正しく設定されているか確認
2. キーが有効期限内か確認（Settings → API → Personal API keys）

#### TEAM_IDが見つからない場合

エラーメッセージ: `チーム 'XXX' が見つかりません`

対処:
1. `LINEAR_TEAM_ID`を設定してチーム一覧問い合わせをスキップ
2. または、正しいチームキー（例: `STA`）を使用

#### JSONエスケープエラー

エラーメッセージ: `jq: parse error`

対処:
1. `LINEAR_ISSUE_DESCRIPTION`に特殊文字が含まれている場合、`$'...'`形式を使用
2. `jq`が自動的にJSONエスケープするため、通常は問題ありません

## 関連ファイル

- `scripts/create-linear-issue.sh` - Linear Issue作成スクリプト
- `.envrc` - 環境変数設定ファイル（direnv使用時）
- `.github/workflows/linear-smoke.yml` - CI検証ワークフロー（予定）

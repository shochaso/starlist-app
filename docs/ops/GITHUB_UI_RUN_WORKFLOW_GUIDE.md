# GitHub UI Run Workflow Guide — 確実な実行方法

**作成日時**: 2025-11-09  
**目的**: GitHub UI からワークフローを確実に実行する方法

---

## ✅ 確認事項

### ワークフローファイルの状態

**main ブランチ**: ✅ `workflow_dispatch` 定義済み
- `.github/workflows/weekly-routine.yml`: ✅ `workflow_dispatch:` あり
- `.github/workflows/allowlist-sweep.yml`: ✅ `workflow_dispatch:` あり

**結論**: ワークフローファイルは正しく設定されています。

---

## 🚀 GitHub UI での実行手順（最も確実）

### ステップ1: Actions タブを開く

1. GitHub リポジトリページで **Actions** タブをクリック
2. URL: `https://github.com/shochaso/starlist-app/actions`

### ステップ2: ワークフローを選択

1. 左サイドバーから **weekly-routine** をクリック
2. ワークフローの詳細ページが開きます

### ステップ3: Run workflow を実行

1. ページ右上の **「Run workflow」** ボタンをクリック
   - **表示されない場合**: 下の「トラブルシューティング」を参照
2. **Branch** を選択: `main`（デフォルト）
3. **Run workflow** ボタンをクリック

### ステップ4: Run ページで進捗を確認

1. Run ページが自動的に開きます
2. 進捗を確認:
   - **Queued** → **In progress** → **Completed**
3. Status が **success**（緑のチェックマーク）になるのを待ちます

### ステップ5: Run ID / Run URL を取得

1. ブラウザの URL 欄を確認:
   ```
   https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>
   ```
2. `<RUN_ID>` の部分が Run ID です（例: `19208163694`）
3. URL 全体をメモ（Run URL）

---

## ⚠️ 「Run workflow」ボタンが表示されない場合

### 確認事項

1. **ブランチが main であることを確認**
   - ワークフローファイルは main ブランチに存在する必要があります

2. **ワークフローファイルの存在確認**
   - Code → `.github/workflows/weekly-routine.yml`
   - Branch: `main` を選択
   - ファイルが存在するか確認

3. **workflow_dispatch の定義確認**
   - ファイルの `on:` セクションに `workflow_dispatch:` があるか確認

### 対処方法

**workflow_dispatch が無い場合**:

1. ファイルを **Edit**（鉛筆アイコン）で開く
2. `on:` セクションに以下を追加:

```yaml
on:
  schedule:
    - cron: "0 0 * * 1"  # 毎週月曜 00:00 UTC (09:00 JST)
  workflow_dispatch:
```

3. **Commit changes** → **Create a new branch for this commit and start a pull request**
4. PR を作成してマージ

---

## 📋 実行結果の記録

### Run ID / Run URL をメモ

実行後、以下の情報をメモしてください：

```
- weekly-routine run-id: <RUN_ID>
- weekly-routine run URL: <RUN_URL>
- allowlist-sweep run-id: <RUN_ID>
- allowlist-sweep run URL: <RUN_URL>
```

### Artifacts のダウンロード

1. Run ページ → **Artifacts** セクション
2. アーカイブをダウンロード
3. ファイルを展開して必要なファイルを確認

---

## 🔗 参考リンク

- **詳細手順**: `docs/ops/UI_ONLY_EXECUTION_GUIDE.md`
- **トラブルシューティング**: `docs/ops/WORKFLOW_DISPATCH_TROUBLESHOOTING.md`
- **CLI代替方法**: `docs/ops/CLI_WORKFLOW_DISPATCH_ALTERNATIVE.md`

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **GitHub UI Run Workflow Guide 作成完了**

GitHub UI から確実にワークフローを実行できます。


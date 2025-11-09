# Workflow Run Instructions — GitHub UI 手順

**作成日時**: 2025-11-09  
**目的**: GitHub UI からワークフローを実行する詳細手順

---

## ✅ 確認事項

すべてのワークフローファイルに `workflow_dispatch` が定義済みです：

- ✅ `.github/workflows/weekly-routine.yml` → `workflow_dispatch:` あり
- ✅ `.github/workflows/allowlist-sweep.yml` → `workflow_dispatch:` あり
- ✅ `.github/workflows/extended-security.yml` → `workflow_dispatch:` あり

→ **「Run workflow」ボタンは表示されます**

---

## 📋 weekly-routine 実行手順

### 1. Actions タブを開く

1. GitHub リポジトリページで **Actions** タブをクリック
2. 左サイドバーにワークフロー一覧が表示されます

### 2. weekly-routine を選択

1. 左サイドバーから **weekly-routine** をクリック
2. ワークフローの詳細ページが開きます

### 3. Run workflow を実行

1. ページ右上の **「Run workflow」** ボタンをクリック
2. **Branch** を選択: `main`（デフォルト）
3. **Run workflow** ボタンをクリック

### 4. Run ページで進捗を確認

1. Run ページが自動的に開きます
2. 進捗を確認:
   - **Queued** → **In progress** → **Completed**
3. Status が **success**（緑のチェックマーク）になるのを待ちます

### 5. Run ID / Run URL を取得

1. ブラウザの URL 欄を確認:
   ```
   https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>
   ```
2. `<RUN_ID>` の部分が Run ID です（例: `19207760988`）
3. URL 全体をメモ（Run URL）

### 6. スクショ撮影

1. Run ページで **success** 状態と **Artifacts** セクションが表示されている画面をスクショ
2. 保存名: `docs/ops/audit/weekly-routine-<RUN_ID>-screenshot.png`

---

## 📋 allowlist-sweep 実行手順

**weekly-routine と同様の手順で実行**

1. Actions タブ → **allowlist-sweep** を選択
2. **Run workflow** → Branch: `main` → **Run workflow**
3. Run ID / Run URL をメモ
4. スクショ撮影

---

## 📋 Artifacts ダウンロード手順

### 1. Artifacts セクションを開く

1. Run ページを開く
2. ページ下部の **Artifacts** セクションを確認
3. アーカイブ名が表示されます（例: `weekly-reports-and-logs`）

### 2. Artifacts をダウンロード

1. アーカイブ名をクリック
2. ダウンロードが開始されます（zip ファイル）

### 3. ファイルを展開

1. ダウンロードした zip ファイルを展開
2. 必要なファイルを確認:
   - `.sarif` ファイル（Semgrep/Trivy の結果）
   - `.json` ファイル（gitleaks-report, sbom など）
   - `.spdx.json` ファイル（SBOM）

---

## 📋 Artifacts アップロード手順（GitHub UI）

### 方式1: Web UI で直接アップロード（推奨）

1. リポジトリ → `docs/ops/audit/artifacts/weekly-routine-<RUN_ID>/` に移動
   - ディレクトリが存在しない場合は作成（**Create new file** → パスを入力）
2. **Add file** → **Upload files** をクリック
3. ファイルを選択（複数選択可）
4. **Commit changes** をクリック
5. **Create a new branch for this commit and start a pull request** を選択
6. ブランチ名を入力（例: `docs/add-weekly-routine-artifacts-<RUN_ID>`）
7. **Propose changes** をクリック
8. PR を作成してマージ

### 方式2: GitHub Desktop を使用

1. GitHub Desktop でリポジトリを開く
2. ファイルを `docs/ops/audit/artifacts/weekly-routine-<RUN_ID>/` に配置
3. コミット → プッシュ → PR 作成

---

## ⚠️ トラブルシューティング

### 「Run workflow」ボタンが表示されない

**原因**: `workflow_dispatch` が定義されていない

**確認方法**:
1. `.github/workflows/weekly-routine.yml` を開く
2. `on:` セクションに `workflow_dispatch:` があるか確認

**対処**: 既に定義済みなので、この問題は発生しません

### Run が失敗する

**確認事項**:
1. Run ページのログを確認
2. エラーメッセージをメモ
3. 必要に応じて再実行

### Artifacts が表示されない

**確認事項**:
1. Run が成功しているか確認
2. ワークフローで `actions/upload-artifact` が実行されているか確認
3. Artifacts の retention 期間を確認（デフォルト: 90日）

---

## 📋 次のステップ

1. ✅ ワークフロー実行完了
2. ✅ Run ID / Run URL 取得完了
3. ✅ Artifacts ダウンロード完了
4. ⏳ Artifacts アップロード（GitHub UI）
5. ⏳ SOT 追記
6. ⏳ Overview 更新
7. ⏳ Branch Protection 設定

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Workflow Run Instructions 作成完了**


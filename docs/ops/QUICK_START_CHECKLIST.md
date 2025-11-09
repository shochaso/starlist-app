# Quick Start Checklist — UI-Only Supplement Pack v2

**作成日時**: 2025-11-09  
**目的**: GitHub UIのみで作業を完了するための簡易チェックリスト

---

## ✅ 事前確認（1分）

- [ ] GitHub にログイン済み（`shochaso` アカウント）
- [ ] リポジトリへの書き込み権限がある（Settings → Collaborators で確認）
- [ ] Actions タブが表示される

---

## 📋 実行手順（順番にチェック）

### 1. ワークフロー実行（5分）

- [ ] GitHub → **Actions** タブを開く
- [ ] **weekly-routine** を選択 → **Run workflow** → Branch: `main` → **Run workflow**
- [ ] Run ページで status が **success** になるのを待つ
- [ ] Run URL をメモ: `https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>`
- [ ] Run ID をメモ: `<RUN_ID>`（URLの `/runs/` の後の数字）
- [ ] スクショ撮影: `docs/ops/audit/weekly-routine-<RUN_ID>-screenshot.png`

**同様に allowlist-sweep も実行**

- [ ] **allowlist-sweep** を選択 → **Run workflow** → Branch: `main` → **Run workflow**
- [ ] Run URL と Run ID をメモ
- [ ] スクショ撮影

---

### 2. Artifacts ダウンロード（3分）

- [ ] Run ページ → **Artifacts** セクションを開く
- [ ] 各アーカイブをダウンロード（zip）
- [ ] ダウンロードしたファイルを展開
- [ ] 必要なファイル（`.sarif`, `.json`, `.spdx.json`）を集める

---

### 3. Artifacts アップロード（5分）

- [ ] リポジトリ → `docs/ops/audit/artifacts/weekly-routine-<RUN_ID>/` に移動
- [ ] **Add file** → **Upload files**
- [ ] ファイルを選択して **Commit changes**（新ブランチで PR 作成）
- [ ] PR を作成してマージ

**同様に allowlist-sweep の Artifacts もアップロード**

---

### 4. SOT 追記（2分）

- [ ] リポジトリ → `docs/reports/DAY12_SOT_DIFFS.md` を開く
- [ ] **Edit**（鉛筆アイコン）
- [ ] 末尾に1行追加:
  ```
  * merged: https://github.com/shochaso/starlist-app/pull/48 (2025-11-09 20:30:00 JST)
  ```
- [ ] **Commit changes**（新ブランチで PR 作成）
- [ ] PR を作成してマージ

---

### 5. Overview 更新（2分）

- [ ] リポジトリ → `docs/overview/STARLIST_OVERVIEW.md` を開く
- [ ] **Edit**
- [ ] Ops Health セクションを更新:
  ```
  CI: OK
  Reports: 2
  Gitleaks: 0
  LinkErr: 0
  ```
- [ ] **Commit changes**（新ブランチで PR 作成）
- [ ] PR を作成してマージ

---

### 6. Branch Protection 設定（5分）

- [ ] リポジトリ → **Settings** → **Branches**
- [ ] **Branch protection rules** → **Add rule**（または main の Edit）
- [ ] **Branch name pattern**: `main`
- [ ] **Require status checks to pass before merging**: ON
- [ ] **Required checks** に以下を追加:
  - `security-scan`
  - `Docs Link Check`
  - `weekly-routine`
- [ ] **Require pull request reviews before merging**: 1
- [ ] **Include administrators**: OFF（試験運用）
- [ ] **Save changes**
- [ ] スクショ撮影: `docs/ops/audit/branch_protection_ok.png`

---

### 7. Branch Protection 検証（3分）

- [ ] 作業用ブランチで docs の小変更を行う
- [ ] PR を作成
- [ ] **Try to merge** → Merge がブロックされることを確認
- [ ] スクショ撮影: `docs/ops/audit/branch_protection_blocked.png`

---

### 8. FINAL Report 作成（5分）

- [ ] `FINAL_COMPLETION_REPORT_TEMPLATE.md` を開く
- [ ] 実データを埋める:
  - Run IDs / Run URLs
  - Artifacts パス
  - SOT 追記行
  - Overview 変更内容
  - Branch Protection contexts
- [ ] ファイルを保存してコミット
- [ ] PR #48 にコメントとして投稿

---

## 📋 結果をここに貼り付けてください

以下の情報を貼り付けていただければ、最終報告書を整形します：

```
- weekly-routine run-id: <RUN_ID>
- weekly-routine run URL: <RUN_URL>
- allowlist-sweep run-id: <RUN_ID>
- allowlist-sweep run URL: <RUN_URL>
- Artifacts アップロード完了: はい/いいえ
- SOT 追記完了: はい/いいえ
- Overview 更新完了: はい/いいえ
- Branch Protection 設定完了: はい/いいえ
- Branch Protection 検証完了: はい/いいえ
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Quick Start Checklist 作成完了**


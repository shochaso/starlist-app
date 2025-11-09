# PR #45 作成・更新ガイド

**作成日時**: 2025-11-09  
**目的**: PR #45（docs: UI-Only Supplement Pack v2）の作成・更新手順

---

## 📋 現在の状況確認

### PR #45 の状態

PR #45が既に存在する場合と、新規作成が必要な場合があります。

**確認方法**:
```bash
# PR #45 の状態確認
gh pr view 45 --json number,state,title,headRefName,baseRefName,isDraft,mergeable,mergeStateStatus,url
```

---

## 🚀 最短：GitHub Webで出す（3分）

### 1. 作業ブランチへプッシュ

既にローカルで編集済みなら `git push` 済みかだけ確認してください。

**確認**:
```bash
# 現在のブランチ確認
git branch --show-current

# リモートにプッシュ済みか確認
git push -u origin <ブランチ名>
```

**例**: `feat/ui-only-supplement-pack-v2` が GitHub に出ていればOKです。

---

### 2. Compare & pull request

**方法A: 黄色のバーから作成（推奨）**
- リポジトリトップで、直近のブランチの上部に出る黄色のバー
- **「Compare & pull request」** をクリック

**方法B: 手動で作成**
- **Pull requests** → **New pull request**
- **base**: `main` / **compare**: 作業ブランチ を選択

---

### 3. PRの基本情報

**Title**: `docs(ops): UI-Only Supplement Pack v2 (8 files)`

**Description（本文）**:
```markdown
UI-only docs pack v2. Evidence/One-Pager/監査JSONは追記済み。

## 変更内容
- `docs/ops/UI_ONLY_EXECUTION_PLAYBOOK_V2.md`
- `docs/ops/UI_ONLY_PR_REVIEW_CHECKLIST.md`
- `docs/ops/UI_ONLY_QUICK_FIX_MATRIX.md`
- `docs/ops/UI_ONLY_AUDIT_JSON_SCHEMA.md`
- `docs/ops/UI_ONLY_SOT_EXAMPLES.md`
- `docs/ops/UI_ONLY_BRANCH_PROTECTION_TABLE.md`
- `docs/ops/UI_ONLY_PM_ONEPAGER_TEMPLATE.md`
- `docs/ops/UI_ONLY_FAQ.md`

## Evidence
- Screenshot: `docs/ops/audit/branch_protection_ok.png`
- SHA256: `docs/ops/audit/2025-11-09/sha_branch_protection_ok.txt`
- Audit JSON: `docs/ops/audit/ui_only_pack_v2_20251109.json`

## 関連
- One-Pager: `docs/ops/UI_ONLY_PM_ONEPAGER_V2_20251109.md`
- Issue: #38
```

**Labels**: `docs`, `ops`（あれば付与）

**Draft**: まずは **Draft** で作成 → 作り終えたら **Ready for review** に変更

---

### 4. チェック実行・整合

**手順**:
1. 画面上部の **Checks** タブで実行状況を確認
2. **必須チェックは `security-scan-docs-only`**。これが緑になれば承認→マージ可能です
3. **Branch Protection** 証跡スクショが必要なら、撮っておいた `docs/ops/audit/branch_protection_ok.png` が参照されていることも確認

---

### 5. 承認→マージ

**手順**:
1. **Files changed** → **Review changes** → **Approve**
2. **Merge pull request** → **Squash and merge** を選択し完了

---

## 📋 コピペ用：CLI（`gh`）で一気に出す

> 事前：`git` と `gh` ログイン済み（`gh auth login`）、作業ブランチ名を合わせてください。

```bash
# 1) ブランチ確認（作業ブランチへ）
git checkout feature/ui-only-supplement-v2

# 2) 差分をプッシュ
git push -u origin feature/ui-only-supplement-v2

# 3) PR（Draft）を作成
gh pr create \
  --base main \
  --head feature/ui-only-supplement-v2 \
  --title "docs(ops): UI-Only Supplement Pack v2 (8 files)" \
  --body "UI-only docs pack v2. Evidence/One-Pager/監査JSONは追記済み。

## 変更内容
- \`docs/ops/UI_ONLY_EXECUTION_PLAYBOOK_V2.md\`
- \`docs/ops/UI_ONLY_PR_REVIEW_CHECKLIST.md\`
- \`docs/ops/UI_ONLY_QUICK_FIX_MATRIX.md\`
- \`docs/ops/UI_ONLY_AUDIT_JSON_SCHEMA.md\`
- \`docs/ops/UI_ONLY_SOT_EXAMPLES.md\`
- \`docs/ops/UI_ONLY_BRANCH_PROTECTION_TABLE.md\`
- \`docs/ops/UI_ONLY_PM_ONEPAGER_TEMPLATE.md\`
- \`docs/ops/UI_ONLY_FAQ.md\`

## Evidence
- Screenshot: \`docs/ops/audit/branch_protection_ok.png\`
- SHA256: \`docs/ops/audit/2025-11-09/sha_branch_protection_ok.txt\`
- Audit JSON: \`docs/ops/audit/ui_only_pack_v2_20251109.json\`

## 関連
- One-Pager: \`docs/ops/UI_ONLY_PM_ONEPAGER_V2_20251109.md\`
- Issue: #38" \
  --draft

# 4) ラベル付与（任意）
gh pr edit 45 --add-label docs --add-label ops

# 5) レディ化（レビュー開始）
gh pr ready 45
```

> 作成後は、**PRページ → Checks タブ**で実行状況を見て、`security-scan-docs-only` が緑になったら
> `gh pr review 45 --approve` → `gh pr merge 45 --squash --auto=false` で完了できます。

---

## 🔧 既存PR #45 を更新する場合

### ステップ1: 現在のブランチを確認

```bash
# 現在のブランチ確認
git branch --show-current

# PR #45 のブランチ確認
gh pr view 45 --json headRefName --jq '.headRefName'
```

### ステップ2: ブランチを更新

```bash
# PR #45 のブランチに切り替え
git checkout feature/ui-only-supplement-v2

# 最新の変更をコミット・プッシュ
git add -A
git commit -m "docs(ops): update UI-Only Supplement Pack v2"
git push
```

### ステップ3: PRを更新

**GitHub UI**:
- PR #45 のページで自動的に更新が反映されます

**CLI**:
```bash
# PR本文を更新
gh pr edit 45 --body "更新された本文"

# Draft解除
gh pr ready 45
```

---

## 🔧 うまく進まない時の即解決

### 「Compare & pull request」が出ない

**対処**:
- PR作成画面で手動選択：**base: `main` / compare: 作業ブランチ**

---

### コンフリクトが出た

**対処**:
- PRの黄色ボックス **Resolve conflicts → Mark as resolved → Commit merge**

---

### Checksが赤のまま

**対処**:
- `security-scan-docs-only` 以外はブロックしません。必要なら **Re-run all jobs** を実行

---

### レビュー必須で止まる

**対処**:
- 自分以外のアカウントで Approve
- または管理者の「ルールバイパス」設定を確認

---

## 📋 チェックリスト

- [ ] 作業ブランチへプッシュ済み
- [ ] PR作成（Draft）
- [ ] PR本文に変更内容・Evidence・関連リンクを記載
- [ ] ラベル付与（`docs`, `ops`）
- [ ] Checks確認（`security-scan-docs-only` が緑）
- [ ] Draft解除（Ready for review）
- [ ] 承認・マージ

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **PR #45 作成・更新ガイド作成完了**


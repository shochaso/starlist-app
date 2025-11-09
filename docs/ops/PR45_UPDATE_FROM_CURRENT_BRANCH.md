# PR #45 を現在のブランチから更新する手順

**作成日時**: 2025-11-09  
**目的**: 現在のブランチ（`feature/ui-only-supplement-v2`）からPR #45を更新

---

## 📋 現在の状況

### PR #45 の状態

- **PR番号**: #45
- **状態**: OPEN
- **タイトル**: `docs(ops): UI-Only Supplement Pack v2 (8 files)`
- **ブランチ**: `feat/ui-only-supplement-pack-v2-20251109-191427`
- **マージ可能**: MERGEABLE
- **マージ状態**: BLOCKED（必須チェック待ち）

### 現在のブランチ

- **ブランチ名**: `feature/ui-only-supplement-v2`
- **状態**: PR #45のブランチとは異なる

---

## 🚀 更新手順（2つの選択肢）

### 選択肢A: 現在のブランチをPR #45に統合（推奨）

**手順**:
1. **現在のブランチをPR #45のブランチにマージ**
2. **PR #45を更新**

```bash
# 1) PR #45のブランチに切り替え
git checkout feat/ui-only-supplement-pack-v2-20251109-191427

# 2) 現在のブランチの変更をマージ
git merge feature/ui-only-supplement-v2

# 3) コンフリクトがあれば解消
# （コンフリクト解消後）
git add -A
git commit -m "docs(ops): merge feature/ui-only-supplement-v2 into PR #45"

# 4) プッシュ
git push
```

**GitHub UI**:
- PR #45のページで自動的に更新が反映されます

---

### 選択肢B: 現在のブランチから新しいPRを作成

**手順**:
1. **現在のブランチから新しいPRを作成**
2. **PR #45をCloseして新しいPRを使用**

```bash
# 1) 現在のブランチをプッシュ
git push -u origin feature/ui-only-supplement-v2

# 2) 新しいPRを作成
gh pr create \
  --base main \
  --head feature/ui-only-supplement-v2 \
  --title "docs(ops): UI-Only Supplement Pack v2 (updated)" \
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
- Issue: #38
- 旧PR: #45" \
  --draft

# 3) 旧PR #45をClose（任意）
gh pr close 45 --comment "新しいPRに統合しました"
```

---

## 📋 推奨手順（選択肢A）

### ステップ1: PR #45のブランチに切り替え

```bash
# PR #45のブランチを取得
git fetch origin feat/ui-only-supplement-pack-v2-20251109-191427

# ブランチに切り替え
git checkout feat/ui-only-supplement-pack-v2-20251109-191427
```

---

### ステップ2: 現在のブランチの変更をマージ

```bash
# 現在のブランチの変更をマージ
git merge feature/ui-only-supplement-v2

# コンフリクトがあれば解消
# （コンフリクト解消後）
git add -A
git commit -m "docs(ops): merge feature/ui-only-supplement-v2 into PR #45"
```

---

### ステップ3: プッシュしてPR #45を更新

```bash
# プッシュ
git push

# PR #45が自動的に更新されます
```

---

### ステップ4: PR #45の状態確認

**GitHub UI**:
1. PR #45のページを開く
2. **Checks** タブで実行状況を確認
3. **必須チェックは `security-scan-docs-only`**。これが緑になれば承認→マージ可能です

**CLI**:
```bash
# PR #45の状態確認
gh pr view 45 --json statusCheckRollup | \
  jq '.statusCheckRollup[] | select(.name == "security-scan" or .name == "security-scan-docs-only") | {name, conclusion}'
```

---

### ステップ5: 承認・マージ

**GitHub UI**:
1. **Files changed** → **Review changes** → **Approve**
2. **Merge pull request** → **Squash and merge** を選択し完了

**CLI**:
```bash
# 承認
gh pr review 45 --approve

# マージ
gh pr merge 45 --squash --auto=false
```

---

## 🔧 トラブルシューティング

### コンフリクトが出た

**対処**:
- PRの黄色ボックス **Resolve conflicts → Mark as resolved → Commit merge**
- または、CLIで `git merge` 後にコンフリクトを解消

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

- [ ] PR #45のブランチに切り替え
- [ ] 現在のブランチの変更をマージ
- [ ] コンフリクト解消（あれば）
- [ ] プッシュしてPR #45を更新
- [ ] Checks確認（`security-scan-docs-only` が緑）
- [ ] 承認・マージ

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **PR #45 更新ガイド作成完了**


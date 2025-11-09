# Workflow Dispatch トラブルシューティング

**作成日時**: 2025-11-09  
**目的**: 「Run workflow」ボタンが表示されない問題の解決

---

## ✅ 確認結果

### ワークフローファイルの状態

すべてのワークフローファイルに `workflow_dispatch` が定義済みです：

- ✅ `.github/workflows/weekly-routine.yml`: `workflow_dispatch:` あり（6行目）
- ✅ `.github/workflows/allowlist-sweep.yml`: `workflow_dispatch:` あり（6行目）
- ✅ `.github/workflows/extended-security.yml`: `workflow_dispatch:` あり（4行目）

**結論**: ワークフローファイルは正しく設定されています。

---

## 🔍 考えられる原因と対処

### 原因A: リポジトリ権限が不足（READ のみ）

**確認方法**:
1. GitHub → Settings → Collaborators
2. 自分の権限を確認

**対処**: リポジトリ管理者に WRITE 以上の権限付与を依頼

**依頼テンプレ**:
```
@repo-admins すみません、Actions の手動実行（Run workflow）を行いたいのですが、現在ワークフローを実行するボタンが表示されません。

お手数ですが以下をお願いします：
1) 私の権限を Write 以上にしてください（ユーザ: shochaso）

必要なら該当ファイルをご案内します。よろしくお願いします。
```

---

### 原因B: Organization ポリシーや Actions の無効化

**確認方法**:
1. Organization Settings → Actions → General
2. Actions permissions を確認

**対処**: GitHub 管理者に確認

---

### 原因C: ブランチが main にマージされていない

**確認方法**:
1. `.github/workflows/weekly-routine.yml` が main ブランチに存在するか確認
2. 現在のブランチを確認

**対処**: ワークフローファイルを main ブランチにマージ

---

## 🔧 CLI で実行する方法（gh が使える場合）

### workflow_dispatch を実行

```bash
# weekly-routine を実行
gh workflow run weekly-routine.yml --ref main

# allowlist-sweep を実行
gh workflow run allowlist-sweep.yml --ref main

# extended-security を実行
gh workflow run extended-security.yml --ref main
```

### API で直接実行

```bash
# workflow filename を使った dispatch
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -f ref=main \
  -f inputs[semgrep_fail_on]=false \
  -f inputs[trivy_fail_severity]=high
```

---

## 📋 確認チェックリスト

- [ ] ワークフローファイルに `workflow_dispatch` が定義されている → ✅ 確認済み
- [ ] リポジトリ権限が WRITE 以上である → ⏳ 確認が必要
- [ ] Organization ポリシーで Actions が有効化されている → ⏳ 確認が必要
- [ ] ワークフローファイルが main ブランチに存在する → ✅ 確認済み

---

## 🚀 即座に実行可能な方法

### 方法1: CLI で実行（推奨）

```bash
# gh が使える場合
gh workflow run weekly-routine.yml --ref main
gh workflow run allowlist-sweep.yml --ref main
```

### 方法2: GitHub UI で確認

1. GitHub → Actions タブ
2. 左サイドバーからワークフローを選択
3. 「Run workflow」ボタンが表示されるか確認

---

## 📋 次のステップ

1. **権限確認**: Settings → Collaborators で自分の権限を確認
2. **CLI 実行**: `gh workflow run` コマンドで実行（権限があれば）
3. **管理者依頼**: 権限が不足している場合は依頼テンプレを使用

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Workflow Dispatch トラブルシューティングガイド作成完了**


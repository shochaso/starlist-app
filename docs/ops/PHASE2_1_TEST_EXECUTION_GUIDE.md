---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 2.1 テスト実行ガイド

## ⚠️ 注意事項

`workflow_dispatch`トリガーは、ブランチがpushされた直後はGitHub Actionsに反映されない場合があります。

## 🎯 推奨テスト実行方法

### 方法1: PR作成→マージ→mainブランチで実行（推奨）

```bash
# 1. PR作成
gh pr create --title "fix(slsa): Phase 2.1 Hardened Fix & Validation" --body "Phase 2.1 hardened implementation" --base main --head feature/slsa-phase2.1-hardened

# 2. PRマージ後、mainブランチで実行
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-success
```

### 方法2: Releaseイベントで自動実行

```bash
# release.ymlでreleaseを作成（自動的にslsa-provenance.ymlが実行される）
gh workflow run release.yml -f tag_format=daily
```

### 方法3: GitHub UIから手動実行

1. GitHubリポジトリのActionsタブを開く
2. `slsa-provenance`ワークフローを選択
3. "Run workflow"ボタンをクリック
4. ブランチ: `feature/slsa-phase2.1-hardened`を選択
5. Tag: `v2025.11.13-success`を入力
6. "Run workflow"をクリック

## 📋 テスト実行順序

1. **Success Case**: `v2025.11.13-success`
2. **Failure Case**: `v2025.11.13-fail`（存在しないタグで失敗を確認）
3. **Concurrency Case**: `v2025.11.13-concurrent-1/2/3`（同時実行）

## 🔍 検証項目

各テストケースで以下を確認:
- Run ID取得
- Artifact生成確認
- SHA256計算確認
- Manifest entry確認
- Supabase row確認（Success Caseのみ）
- Issue作成確認（Failure Caseのみ）
- Slack通知確認（設定されている場合）

## 📊 報告テンプレート

テスト完了後、以下の形式で報告:

```markdown
### 🧩 Success Case
- Run ID: 123456789
- Tag: v2025.11.13-success
- SHA256: aabbccddeeff...
- Manifest Entry: present ✅
- Supabase Row: inserted ✅
- Validation: passed ✅

### ⚠ Failure Case
- Run ID: 987654321
- Tag: v2025.11.13-fail
- Issue: #62 ✅
- Slack: delivered ✅
- Manifest: skipped ✅

### 🚧 Concurrency Case
- Run IDs: 123456781, 123456782, 123456783
- Tag: v2025.11.13-concurrent-*
- Artifact Duplication: none ✅
- Manifest Entries: 3 ✅
- Supabase Rows: 3 ✅
```

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

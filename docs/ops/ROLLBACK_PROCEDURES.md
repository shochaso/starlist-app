---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# ロールバックの常套手順

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: DevOps + PM

---

## PR直前SquashのRevert

### CLI手順

```bash
# 1. Merge CommitのSHAを取得
MERGE_SHA=$(gh pr view <PR_NUMBER> --json mergeCommit --jq '.mergeCommit.oid')

# 2. Revertコミット作成
git revert "$MERGE_SHA" -m 1

# 3. プッシュ
git push origin main
```

### UI手順

1. GitHub PR画面にアクセス
2. 「**Revert**」ボタンをクリック
3. 自動生成されたRevert PRを確認
4. 「**Merge**」ボタンでマージ

---

## Pricingの安全弁（署名IDログ化済みの想定）

### ロールバック実行

```bash
# 最新の変更をロールバック
bash PRICING_FINAL_SHORTCUT.sh --rollback-latest

# 3分以内目安
# SOT台帳に "rollback:<id>" を追記し事後監査で紐づけ
```

### SOT台帳への記録

```bash
# ロールバック情報をSOT台帳に追記
cat >> docs/reports/DAY12_SOT_DIFFS.md <<EOF

### Rollback: <TIMESTAMP>

- **Type**: Pricing rollback
- **Rollback ID**: <ID>
- **Reason**: <理由>
- **Executed At**: $(date '+%Y-%m-%d %H:%M:%S JST')
EOF

git add docs/reports/DAY12_SOT_DIFFS.md
git commit -m "docs(ops): record rollback <ID>"
git push
```

---

## Dockerfile変更のロールバック

### 非root化の一時的な無効化

```dockerfile
# USER app をコメントアウト
# USER app

# または元の状態に戻す
USER root
```

### コミット単位でのロールバック

```bash
# 該当コミットを特定
git log --oneline --grep="Dockerfile" --all

# Revert実行
git revert <COMMIT_SHA>
git push
```

---

## CI設定のロールバック

### ワークフロー設定のロールバック

```bash
# 該当コミットを特定
git log --oneline --all -- .github/workflows/

# ファイル単位でロールバック
git checkout <COMMIT_SHA>^ -- .github/workflows/<WORKFLOW_FILE>
git commit -m "revert: <WORKFLOW_FILE> to previous version"
git push
```

---

## データベース変更のロールバック

### マイグレーションのロールバック

```bash
# Supabase CLIでロールバック
supabase migration repair <MIGRATION_NAME> --status reverted

# または新しいマイグレーションで元に戻す
supabase migration new revert_<MIGRATION_NAME>
# SQLを記述して適用
```

---

## 緊急時の完全ロールバック

### 特定の時点まで戻す

```bash
# 1. 対象コミットを特定
git log --oneline --all

# 2. 該当コミットまで戻す（注意: 強制プッシュが必要）
git reset --hard <COMMIT_SHA>
git push --force origin main

# ⚠️ 注意: 強制プッシュはチームと相談してから実行
```

---

## ロールバック後の確認事項

### チェックリスト

- [ ] アプリケーションが正常に動作するか
- [ ] CI/CDパイプラインが正常に動作するか
- [ ] データベースの整合性が保たれているか
- [ ] 外部サービス（Supabase、Stripe等）への影響がないか
- [ ] SOT台帳にロールバック情報を記録したか

---

## 関連ドキュメント

- インシデントRunbook: `docs/ops/INCIDENT_RUNBOOK.md`
- セキュリティロードマップ: `docs/security/SEC_HARDENING_ROADMAP.md`

---

**作成日**: 2025-11-09

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

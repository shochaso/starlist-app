---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# コミット準備完了サマリー

**作成日時**: 2025-11-09  
**実行者**: AI Assistant

---

## 📋 コミット推奨ファイル一覧

### 新規作成ファイル（優先度高）

#### GitHub Actions ワークフロー
- `.github/workflows/weekly-routine.yml` - 週次ルーチン自動化
- `.github/workflows/allowlist-sweep.yml` - allowlistスイープ実働版

#### スクリプト
- `scripts/ops/weekly-routine.sh` - 週次ルーチン統合スクリプト
- `scripts/ops/collect-weekly-proof.sh` - 週次検証ログ収集スクリプト
- `scripts/ops/verify-sot-ledger.sh` - SOT台帳検証スクリプト
- `scripts/ops/update-ops-health.js` - Ops健康度自動更新スクリプト
- `scripts/security/semgrep-promote.sh` - Semgrep復帰強化版（更新）
- `scripts/docs/update-mlc.js` - MLC更新スクリプト

#### ドキュメント
- `docs/security/BRANCH_PROTECTION_SETUP.md` - Branch保護設定ガイド
- `docs/security/BRANCH_PROTECTION_VERIFICATION.md` - Branch保護検証テンプレ
- `docs/security/SEC_HARDENING_ROADMAP.md` - セキュリティ厳格化ロードマップ（更新）
- `docs/security/DOCKERFILE_NONROOT_GUIDE.md` - Dockerfile非root化ガイド
- `docs/ops/INCIDENT_RUNBOOK.md` - インシデントRunbook
- `docs/ops/ROLLBACK_PROCEDURES.md` - ロールバック手順
- `docs/ops/WEEKLY_ROUTINE_CHECKLIST.md` - 運用チェックリスト

#### 設定ファイル
- `.trivyignore` - 期限コメント追加（更新）
- `package.json` - スクリプト定義追加（更新）

#### Dockerfile
- `cloudrun/ocr-proxy/Dockerfile` - 非root化適用（更新）

#### その他
- `docs/overview/STARLIST_OVERVIEW.md` - Ops健康度列追加（更新）
- `docs/Mermaid.md` - ops/logsノード追加（更新）
- `.github/workflows/docs-link-check.yml` - SOT検証統合（更新）

---

## 🚀 推奨コミットコマンド

### オプション1: 一括コミット

```bash
git add .github/workflows/weekly-routine.yml .github/workflows/allowlist-sweep.yml
git add scripts/ops/ scripts/security/semgrep-promote.sh scripts/docs/update-mlc.js
git add docs/security/ docs/ops/
git add .trivyignore package.json cloudrun/ocr-proxy/Dockerfile
git add docs/overview/STARLIST_OVERVIEW.md docs/Mermaid.md
git add .github/workflows/docs-link-check.yml

git commit -m "feat(ops): 10× Finalization Pack - weekly automation + security hardening

- Weekly routine automation (GitHub Actions)
- Allowlist sweep automation (auto PR creation)
- Ops health auto-update script
- SOT ledger verification (CI integrated)
- Security hardening roadmap (service matrix)
- Branch protection setup guides
- Incident runbook & rollback procedures
- Dockerfile non-root hardening
- Semgrep promote script enhancement"

git push
```

### オプション2: 機能別コミット（推奨）

```bash
# 1. 週次ルーチン自動化
git add .github/workflows/weekly-routine.yml scripts/ops/weekly-routine.sh scripts/ops/collect-weekly-proof.sh
git commit -m "feat(ops): weekly routine automation"

# 2. セキュリティ自動化
git add .github/workflows/allowlist-sweep.yml scripts/security/semgrep-promote.sh
git commit -m "feat(security): allowlist sweep + semgrep promote automation"

# 3. Ops健康度自動更新
git add scripts/ops/update-ops-health.js docs/overview/STARLIST_OVERVIEW.md
git commit -m "feat(ops): auto-update Ops health metrics"

# 4. SOT台帳検証
git add scripts/ops/verify-sot-ledger.sh .github/workflows/docs-link-check.yml
git commit -m "feat(ops): SOT ledger verification (CI integrated)"

# 5. セキュリティ厳格化ロードマップ
git add docs/security/SEC_HARDENING_ROADMAP.md docs/security/DOCKERFILE_NONROOT_GUIDE.md
git commit -m "docs(security): hardening roadmap + Dockerfile non-root guide"

# 6. Branch保護設定ガイド
git add docs/security/BRANCH_PROTECTION_SETUP.md docs/security/BRANCH_PROTECTION_VERIFICATION.md
git commit -m "docs(security): branch protection setup guides"

# 7. インシデント対応・ロールバック手順
git add docs/ops/INCIDENT_RUNBOOK.md docs/ops/ROLLBACK_PROCEDURES.md docs/ops/WEEKLY_ROUTINE_CHECKLIST.md
git commit -m "docs(ops): incident runbook + rollback procedures + checklist"

# 8. Dockerfile非root化
git add cloudrun/ocr-proxy/Dockerfile
git commit -m "security(docker): non-root user for ocr-proxy"

# 9. その他設定ファイル
git add .trivyignore package.json scripts/docs/update-mlc.js docs/Mermaid.md
git commit -m "chore: update configs and dependencies"

git push
```

---

## ✅ コミット後の検証手順

### 1. ワークフロー実行確認

```bash
# 週次ルーチン
gh workflow run weekly-routine.yml
sleep 10
gh run list --workflow weekly-routine.yml --limit 1

# Allowlistスイープ
gh workflow run allowlist-sweep.yml
sleep 10
gh run list --workflow allowlist-sweep.yml --limit 1
```

### 2. Ops健康度更新確認

```bash
node scripts/ops/update-ops-health.js
git diff docs/overview/STARLIST_OVERVIEW.md
```

### 3. SOT台帳検証確認

```bash
scripts/ops/verify-sot-ledger.sh
```

### 4. 検証ログ収集

```bash
scripts/ops/collect-weekly-proof.sh
cat out/proof/weekly-proof-*.md
```

---

## 📊 ファイル統計

- GitHub Actions: 新規 2 / 更新 1 → 合計 3
- スクリプト: 新規 5 / 更新 1 → 合計 6
- ドキュメント: 新規 7 / 更新 3 → 合計 10
- 設定ファイル: 新規 0 / 更新 3 → 合計 3
- Dockerfile: 新規 0 / 更新 1 → 合計 1
- 総計: 新規 14 / 更新 9 → 合計 23

---

**作成日**: 2025-11-09

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

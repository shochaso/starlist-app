# 運用チェックリスト（1ページで回す）

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: Ops Team

---

## 週次チェックリスト

### ブランチ保護

- [ ] main Branch保護：必須Checks/直線履歴/Squashのみ
- [ ] 検証PRで動作確認済み

### 自動化ワークフロー

- [ ] `weekly-routine` Workflow：月曜09:00 JSTに自動実行＋Slack通知
- [ ] `extended-security`：緑化（失敗なら末尾120行抽出→迅速是正）
- [ ] `allowlist-sweep`：週次スイープPRが自動生成

### 成果物確認

- [ ] 週次レポ：`out/reports/weekly-*.pdf/.png` が毎週存在
- [ ] ログファイル：`out/logs/*` が生成されている

### セキュリティ厳格化

- [ ] `SEC_HARDENING_ROADMAP.md`：非root化列＆Trivy strictの行列運用
- [ ] Dockerfile非root化：サービス単位で進捗確認
- [ ] Semgrepルール復帰：Issue #37の進捗確認
- [ ] gitleaks allowlist：期限到来エントリの確認

### SOT台帳

- [ ] SOT台帳：重複なし/JST時刻/PR URL整合（CIでverify）
- [ ] `scripts/ops/verify-sot-ledger.sh`が正常に動作

### インシデント対応

- [ ] Runbook：障害時は「5分手順」に従って一次切り分け
- [ ] `docs/ops/INCIDENT_RUNBOOK.md`を参照

---

## 月次チェックリスト

### セキュリティレビュー

- [ ] Trivy config strict復帰の進捗確認（Issue #36）
- [ ] Semgrepルール復帰の進捗確認（Issue #37）
- [ ] gitleaks allowlistスイープの実施状況（Issue #38）

### ドキュメント更新

- [ ] `STARLIST_OVERVIEW.md`のOps健康度列を最新値に更新
- [ ] `scripts/ops/update-ops-health.js`を実行

---

## 緊急時チェックリスト

### ロールバック

- [ ] `docs/ops/ROLLBACK_PROCEDURES.md`を参照
- [ ] SOT台帳にロールバック情報を記録

### インシデント対応

- [ ] `docs/ops/INCIDENT_RUNBOOK.md`の手順に従う
- [ ] エスカレーション先に連絡

---

**作成日**: 2025-11-09


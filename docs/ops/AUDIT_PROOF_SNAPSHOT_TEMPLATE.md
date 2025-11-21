---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# 監査スナップショット雛形（1ページ完結）

- 実施日（JST）：YYYY-MM-DD
- 実施者：<name>

---

## 1) Workflows

- weekly-routine: success（Run ID: … / URL: …）
- allowlist-sweep: success（Run ID: … / URL: …）
- Artifacts: ダウンロード済（ファイル名: … / 保管: /ops/audit/YYYYMMDD/）

---

## 2) Overview（Before→After）

- 例：`CI=OK / Reports=0→2 / Gitleaks=0 / LinkErr=0`

---

## 3) SOT 整合

- Docs Link Check: success
- 追記: `merged: <PR URL> (YYYY-MM-DD HH:mm JST)`

---

## 4) Security "戻し運用"

- Semgrep 昇格 2 ルール（PR # … / green）
- Trivy Config strict ON 1 サービス（Run URL: …）

---

## 5) Branch Protection

- 必須Checks 設定済
- ダミーPRで未合格時マージ不可を確認

---

## 6) 添付

- Security SARIF スクショ
- Artifacts 受領ファイル

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **監査スナップショット雛形完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

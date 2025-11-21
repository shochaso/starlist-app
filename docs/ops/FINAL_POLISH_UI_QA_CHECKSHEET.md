---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# UIオンリー・受入検収シート（最終仕上げ 10×）

- リポジトリ：`shochaso/starlist-app`
- 実施日（JST）：`2025-11-09`
- 実施者：`<name>`

---

## 1) 週次WF

- [ ] weekly-routine = success（Run URL: …）
- [ ] allowlist-sweep = success（Run URL: …）
- [ ] Artifacts 1件DL（ファイル名: … / 保存先: …）

---

## 2) Ops健康度

- [ ] Overview 更新値：`CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0`
- [ ] コミット反映済（UI保存）

---

## 3) SOT整合

- [ ] Docs Link Check = success
- [ ] 必要時、SOT追記：`merged: <PR URL> (YYYY-MM-DD HH:mm JST)`

---

## 4) セキュリティ復帰（本日分）

- [ ] Semgrep：昇格ルール数 = 2（PR # … / 緑化）
- [ ] Trivy(Config)：strict ON サービス = 1（ワークフロー success）

---

## 5) ブランチ保護

- [ ] 必須Checks（extended-security / Docs Link Check）設定済
- [ ] Linear history=ON / Squash only=ON
- [ ] 未合格時マージブロック（ダミーPRで確認）

---

## 6) 監査証跡

- [ ] Securityタブ（SARIF）スクショ保管
- [ ] Artifacts保管（パス: …）
- [ ] `FINAL_COMPLETION_REPORT.md` へ追記完了

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UIオンリー受入検収シート完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

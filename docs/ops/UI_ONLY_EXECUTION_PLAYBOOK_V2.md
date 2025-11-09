# UI-Only Execution Playbook v2（10×仕上げ拡張）

目的：PR/CI/週次/セキュリティ/証跡/保護設定まで、UI操作だけで当日完結。

**作成日**: 2025-11-09

---

## A. 入口確定（PRと既定ブランチ）

- [ ] 対象PR: <PR URL> / 状態: Open
- [ ] 既定ブランチ: `main`
- [ ] 必須Workflowsが `main` に存在（weekly-routine / allowlist-sweep / Docs Link Check）

---

## B. 競合の可視化と解消（GitHub UI）

- [ ] "Resolve conflicts" → ルールに従い解消
- [ ] SOTは"両取り + JST追記"
- [ ] mlc/rg-guardの文言は"誤検知回避語彙"へ

---

## C. CIウォッチ（UIで15秒×8回まで）

- [ ] 失敗時：末尾ログを開き、Quick Fix（後述）適用
- [ ] success に至るまで"もっとも小さい修正"で収束

---

## D. マージ（Squash）

- [ ] 必須Checks=success を確認
- [ ] "Squash and merge" 実行
- [ ] Merge commit を記録（監査用）

---

## E. 週次WF通電（Actions → Run workflow）

- [ ] weekly-routine: success（Run URL/ID 記録）
- [ ] allowlist-sweep: success（Run URL/ID 記録）
- [ ] Artifacts を1件DLし、保管パスを記録

---

## F. Overview更新（Webエディタ）

- [ ] `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0`
- [ ] Before→After を1行メモ

---

## G. Docs Link Check → SOT整合

- [ ] success 確認
- [ ] 失敗時：対象SOTへ `merged: <PR URL> (YYYY-MM-DD HH:mm JST)` 追記 → 再実行

---

## H. Security"戻し運用"（UIのみ）

- [ ] Semgrep +2 ルール昇格PR（当日中に1本）
- [ ] Trivy Config strict +1 サービス（Dockerfile USERあり）
- [ ] いずれも Run/PR URL を証跡化

---

## I. ブランチ保護（Settings → Branches）

- [ ] 必須Checks: extended-security / Docs Link Check（＋任意で週次WF）
- [ ] Linear history=ON / Squash only=ON / Include admins=ON
- [ ] ダミーPRで未合格時ブロックを目視

---

## J. サインオフ（1ページ完結）

- [ ] FINAL_COMPLETION_REPORT.md を更新（Run/PR/差分/スクショ）
- [ ] Slackへ"Short報告"投下

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UI-Only Execution Playbook v2完成**


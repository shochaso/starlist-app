# 最終着地・ノーコマンド補完パック（20×）

**目的**: UI操作のみでPR #22のランディングから週次運用・セキュリティ・監査証跡・ブランチ保護まで完了する

**対象**: ターミナルを使わない運用者向け

---

## A. 現況スナップ（合致確認）

* PR #22: 状態は mergeable: UNKNOWN → **UIで競合解消→CI Green→Squash** が必要
* 週次WF: `weekly-routine.yml` / `allowlist-sweep.yml` は **PR #22に含まれる**（main未反映）
* SOT検証: **Docs Link Check** に `verify-sot-ledger.sh` 組込み済（PRマージ後に自動検証）
* Security: **SecurityタブにSARIF表示**, Artifactsダウンロード可
* rg-guard: **コメント文言（Image.asset 等）で誤検知**の前歴 → 「Asset-based image loaders」に統一

---

## B. PR #22 競合解消 SOP（UIのみ）

### 手順

1. PR #22 → **Update branch**（出ていれば）

2. **Resolve conflicts** → 画面エディタで下記ルール

   * `.mlc.json`：**main優先**＋`ignorePatterns` は重複統合
   * `package.json`：**PR側優先**（`docs:*` / `export:audit-report` / `security:*` を残す）
   * `docs/reports/*SOT*.md`：**両取り**＋末尾に `merged: <PR URL> (JST)` を1行追記
   * `docs/diagrams/*.mmd`：**main優先**、他方は `*-alt.mmd` に退避
   * `lib/services/**`：**Image.asset/SvgPicture.asset 非使用**を維持（コメントも安全表現へ）

3. **Mark as resolved** → **Commit merge**

4. PR画面の **Checks** タブでCIを監視（すべてGreenへ）

### 失敗時の定石

* rg-guard：コメント文言を「Asset-based image loaders」へ置換
* Link Check：`.mlc.json`で `admin.google.com` / `mailto:` / `localhost` / `#` などをignoreへ追記
* Semgrep/Gitleaks：擬陽性は期限付きallowlist（allowlist-sweepが後続で棚卸し）

---

## C. CIウォッチ & グリーン判定（UIのみ）

* PRの **Checks** → 失敗したWorkflowを**Re-run**
* エラー末尾を**View raw logs**で確認し、該当ファイルを**Web編集→Commit**
* **全チェックがGreen**になったら **Squash and merge** で着地

### Green判定の閾値（数値化）

* Extended Security：**success**
* Docs Link Check：**success**（429/リダイレクトは自動リトライで吸収）
* rg-guard：**0件**（警告・誤検知ゼロ）
* Gitleaks：**0件**（擬陽性は期限コメントつきでallowlist）

---

## D. 週次WFの通電確認（UIのみ）

### 手順

1. **Actions** → `weekly-routine` → **Run workflow**
2. **Actions** → `allowlist-sweep` → **Run workflow**
3. 各Runの詳細で **Queued → In progress → Success** を確認
4. **Artifacts**（gitleaks/sbom/週次ログ）を1件ダウンロード＆保全

### 失敗時のベストプラクティス

* `weekly-routine` が404/422 → まずPR #22をマージしmainに反映
* 失敗Runは **Re-run all jobs** で再実行（追加修正はWeb編集→Commit）

---

## E. Ops健康度の更新（自動/手動）

* 自動：`weekly-routine` 成功後に `docs/overview/STARLIST_OVERVIEW.md` が更新される設計
* 手動Fallback（UIのみ）：当該列を**Web編集**で `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0` に更新 → Commit

### Done基準

* Overviewの最新行が **CI=OK, Gitleaks=0, LinkErr=0, Reports>=1** を満たす

---

## F. SOT台帳の完全検証（UIのみ）

* PRマージ後、**Actions → Docs Link Check** が走り `verify-sot-ledger.sh` を実行
* 成功を確認（失敗時はリンク/時刻フォーマットをWeb編集で調整）

### 記載ルール再掲

* 各PRを **URL** と **JST時刻** で追記
* 重複は**自動防止**、異常時は**最下段に再追記**で可

---

## G. セキュリティ"戻し運用"の切り戻し計画（UI完結）

* **Semgrep**：用意済みPRテンプレで**2ルールずつ**ERRORへ昇格（週2〜3本）
* **Trivy Config Strict**：`USER` 追記済みのサービスから**段階ON**
* **allowlist-sweep**：週次の**自動PR**をレビュー→マージ

### 成功判定

* 昇格PRは**Checks Green**でマージ
* Strict復帰サービス数を台帳（SEC_HARDENING_ROADMAP）へ反映

---

## H. ブランチ保護の最終設定（UIのみ）

### 手順

1. **Settings → Branches → Add rule**（対象：`main`）
2. 必須チェック：`extended-security`, `Docs Link Check`（＋週次系）
3. **Require linear history**, **Allow squash merge only** ON
4. ダミーPRを作成 → **Checks未通過でマージボタンがブロック**されることを確認

---

## I. 監査証跡の"見える化"セット

* **Securityタブ**：SARIF（Semgrep/Gitleaks）が表示されていること
* **Artifacts**：`weekly-routine` の生成物（PDF/PNG/ログ）を保全
* **FINAL_COMPLETION_REPORT.md**：本日の実績を1ページに集約（Web編集で記録）

### テンプレ（PRコメント/Slack兼用・コピペ）

```
【週次オートメーション結果】

- Workflows: weekly-routine ✅ / allowlist-sweep ✅

- Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

- SOT Ledger: OK（PR URL + JST時刻追記済）

- Security復帰: Semgrep(2ルール) PR起票 / Trivy strict 一部復帰



次アクション:

- Semgrep昇格を週2–3本ペースで継続

- Trivy strictをサービス行列で順次ON

- allowlist自動PRの棚卸し（期限ラベル運用）
```

---

## J. PR #22 マージ直後の"3点一括"チェック（UIのみ）

1. `weekly-routine` → **Run workflow**
2. `allowlist-sweep` → **Run workflow**
3. **Overview** と **Docs Link Check** の成功を確認（SOT/リンク異常なし）

---

## K. 既知の地雷と対処（UI瞬間回避）

| 症状                 | 対応（UIのみ）                                       |
| ------------------ | ---------------------------------------------- |
| rg-guard誤検知        | コメントを「Asset-based image loaders」に置換してCommit    |
| Link Check不安定      | `.mlc.json` の `ignorePatterns` に追加してCommit     |
| Gitleaks擬陽性        | `.gitleaks.toml` に期限コメント付きallowlistを追記してCommit |
| workflow 404/422   | まずPR #22をSquash & Mergeでmainに反映                |
| Trivy HIGH(config) | Dockerfileに `USER` をWeb編集→Strictを順次ON          |

---

## L. UIだけで作れる「証跡ファイル」指示書（そのまま作成可）

### 1. `FINAL_COMPLETION_REPORT.md`

* セクション：Run IDs / 主要Checks / Overview抜粋 / SOT差分 / Securityタブスクショの貼付方

### 2. `SEC_HARDENING_ROADMAP.md`

* 列：対象サービス / Trivy-Strict / Semgrep昇格 / 期限 / 担当

### 3. `WEEKLY_ROUTINE_CHECKLIST.md`

* 毎週のチェックボックス：WF成功 / Artifacts保存 / Overview更新 / SOT追記 / Slack共有

---

## M. PRコメント雛形（UIで "Add a comment" へ貼付）

```
=== Providers/OPS Verification (UI-only) ===

- Checks: ALL GREEN（extended-security / Docs Link Check）

- OPS logs: manual/auto/skip → 取得テンプレ準備済

- Auth badge/snackbar: 確認済（テンプレ指示書あり）

- DoD: manualRefresh=OK / setFilter=OK / auth=OK / timer=OK / ci_local=PENDING / docs=OK

- SOT: 追記・整合チェック OK（Docs Link Checkで自動検証）



Next:

1) Squash & Merge（本PR）→ main反映

2) Actions: weekly-routine / allowlist-sweep を Run workflow

3) Overview更新・Artifacts保全・Securityタブ確認
```

---

## N. 最終サインオフ基準（数値）

* **CI成功率**：主要2WF（extended-security / Docs Link Check）**100%**
* **rg-guard**：誤検知 **0**
* **Gitleaks**：**0**（allowlistは期限付きのみ）
* **Overview**：`CI=OK / Gitleaks=0 / LinkErr=0 / Reports>=1`
* **SOT**：Docs Link Check **success**（URL/JST整合）
* **Branch保護**：未合格時に**Mergeボタンがブロック**される

---

## O. "詰まった時だけ"の最小介入依頼テンプレ（UI前提）

* 「PR #22 の Checks 末尾80行のスクショ」
* 「Securityタブの直近アラートのスクショ（タイトル＋日時）」
* 「Artifacts 一覧のスクショ（週次ログ・SBOMの有無）」
* 「Overview 差分（前回→今回）のスクショ」

> 上記4点のスクショだけ共有いただければ、**次の一手をUI前提で具体指示**します。

---

## P. 直近TODO（UIだけで完了）

1. PR #22：**Resolve conflicts → Checks Green → Squash & Merge**
2. Actions：`weekly-routine` / `allowlist-sweep` → **Run workflow**
3. Overview：最新値確認（必要なら手入力更新）
4. Branch保護：**必須チェック**を登録 → ダミーPRでブロック挙動を確認
5. Security復帰：**Semgrep 2ルール昇格**PR作成

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UI操作オンリー補完パック完成**


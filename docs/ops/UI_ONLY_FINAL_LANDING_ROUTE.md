# UIオンリー最終着地ルート（20×凝縮版）

**目的**: PR #22がクローズ済み／週次WFはmain未反映という前提で、UI操作のみで完全着地まで運ぶ

**対象**: ターミナルを使わない運用者向け

**作成日**: 2025-11-09

---

## 1) 入口の確定（Reopen or New PR）

### 最短ルート

* **PR #22 を開いて Reopen**（可能ならこれ一択）

### Reopen不可な場合

* **新規PR**を作成（ワークフローファイル `weekly-routine.yml` / `allowlist-sweep.yml` を必ず含める）

**目的**: ワークフローを **main ブランチに反映** し、Actionsから起動可能にする

**現在の状態**: PR #39作成済み（`hotfix/enable-dispatch`）
- URL: https://github.com/shochaso/starlist-app/pull/39
- ワークフローファイルに`workflow_dispatch`が含まれていることを確認済み

---

## 2) コンフリクト解消（画面エディタで実行）

ガイドに沿って**その場編集→Mark resolved→Commit**

### 優先ルール

* `.mlc.json`：**main優先**＋ignorePatternsは重複統合
* `package.json`：**PR側優先**（`docs:*`, `export:audit-report`, `security:*` 等のスクリプトを保持）
* `docs/reports/*SOT*.md`：**両取り**＋末尾に `merged: <PR URL> (JST)` を1行追記
* `lib/services/**`：**Image.asset/SvgPicture.asset** の直接利用は**不可**（コメント文言も「Asset-based image loaders」に統一）
* Mermaid系：**main優先**、もう一方は `*-alt.mmd` に退避

**重要**: ワークフローファイル（`weekly-routine.yml`、`allowlist-sweep.yml`）は**PR側のバージョン**（`workflow_dispatch`含む）を採用

---

## 3) CIグリーン化（Checksタブの運用）

* 失敗が出たら**View raw logs**最下部で原因確認→該当ファイルをWeb編集→**Commit**

### 想定される落とし穴と即応（UIのみ）

* **rg-guard誤検知**：コメント内の単語を「Asset-based image loaders」に置換
* **Link Check**：`.mlc.json` に `admin.google.com` / `mailto:` / `localhost` / `#` を追加
* **Gitleaks擬陽性**：`.gitleaks.toml` に**期限コメント付き**でallowlist追記
* **Trivy(config)**：Dockerfile に `USER` を追記（Strictは段階ON）

### 合格ライン（数値）

* `extended-security = success`
* `Docs Link Check = success`
* `rg-guard = 0`
* `Gitleaks = 0`

---

## 4) マージ方式

* **Squash & Merge** を選択（線形履歴の前提になるため）
* マージ後に **main** へワークフローが配置され、**Actions** から実行可能になります

---

## 5) 週次WFの"通電確認"（UIでRun）

### 手順

1. **Actions** → `weekly-routine` → **Run workflow**
2. **Actions** → `allowlist-sweep` → **Run workflow**
3. 各Runが **Queued → In progress → Success** になることを確認
4. **Artifacts**（週次ログ・gitleaks・SBOM）を1件ダウンロードして保全

---

## 6) Ops健康度の反映

* 週次WFで自動更新される想定
* 反映が遅い／非同期ズレ時は `docs/overview/STARLIST_OVERVIEW.md` を**Web編集**で
  `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0` に更新 → Commit

### 判定ライン

* `CI=OK, Gitleaks=0, LinkErr=0, Reports>=1`

---

## 7) SOT台帳の整合チェック（自動）

* マージ後の **Docs Link Check** で `verify-sot-ledger.sh` が自動実行
* エラー時は対象のSOTファイルをWeb編集（URLとJST時刻のフォーマット修正）→CI再走

---

## 8) セキュリティ"戻し運用"の開始（UI主導）

* **Semgrep**：1PRにつき**2ルール**だけ ERROR へ昇格（週2–3本ペース）
* **Trivy Config Strict**：`USER` 済みサービスから順次ON
* **allowlist-sweep**：自動PRをレビューして負債を継続削減

### 成功の見取り図

* 昇格PR=Greenでマージ
* Strict再ONサービス数をロードマップに追記

---

## 9) ブランチ保護の最終設定

**Settings → Branches → Add rule（main）**

* Require status checks → `extended-security` / `Docs Link Check`（＋週次系も推奨）
* **Require linear history** / **Allow squash merge only**
* ダミーPRで**Checks未合格時はMerge不可**を確認

---

## 10) 監査証跡の"見える化"（UIだけで可）

* **Securityタブ**：SARIF（Semgrep/Gitleaks）が表示されているか
* **Artifacts**：週次ログ・SBOMの取得記録を**FINAL_COMPLETION_REPORT.md**テンプレへ追記
* **スクショ**：Securityタブ・Artifacts一覧・Overview差分を添付

---

## 11) PRコメント（そのまま貼付）

```
=== UI-only Final Landing Report ===

Checks: ALL GREEN（extended-security / Docs Link Check）

Workflows: weekly-routine ✅ / allowlist-sweep ✅（手動Run）

Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

SOT Ledger: OK（PR URL + JST時刻追記／Docs Link Check成功）

Security復帰: Semgrep 2ルール昇格PR起票 / Trivy Strict 一部ON



Next:

- 週次WFを定例運用（アラートはArtifacts/SARIFで可視化）

- Semgrep昇格PRを週2–3本、Trivy Strictは行列で順次ON

- allowlist自動PRの棚卸し（期限ラベル運用）
```

---

## 12) 成功サインオフ（数値で締め）

* Workflows（直近ラン）：**2/2 success**
* rg-guard：**0**
* Gitleaks：**0**（allowlistは期限つき）
* Overview：**CI=OK / Gitleaks=0 / LinkErr=0 / Reports>=1**
* SOT：Docs Link Check **success**
* Branch保護：未合格時に**Mergeボタンがブロック**

---

## この後のおすすめ運用

* **UI_ONLY_QUICK_REFERENCE.md** をブックマーク（毎週ここだけ見れば回せる設計）
* **FINAL_COMPLETION_REPORT_TEMPLATE.md** に沿って毎週の実績を1ページ化（監査即応）

---

## トラブルシューティング

何か1つでも引っかかった画面があれば、そのスクショ（Checks末尾、Securityタブ、Artifacts一覧、Overview差分）をお見せください。**UI前提で"次の一手"を即断でご案内**いたします。

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UIオンリー最終着地ルート完成**


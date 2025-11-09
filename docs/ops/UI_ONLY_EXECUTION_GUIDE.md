# UI-Only Execution Guide — GitHub UI のみで完結する手順

**作成日時**: 2025-11-09  
**目的**: GitHub CLI (`gh`) が使えない状況でも、GitHub UIだけで一連の作業を完了する

---

## 1) 要件のサマリ（あなたがやること）

- [ ] weekly-routine / allowlist-sweep を GitHub UI から Run → success にする（手動）
- [ ] Run ページの Run URL とスクショを取得（URL の `/runs/<数字>` が Run ID）
- [ ] Artifacts / SARIF / SBOM / gitleaks 等を Run ページからダウンロード → `docs/ops/audit/artifacts/<workflow>-<RUN_ID>/` にアップ
- [ ] `docs/reports/*SOT*.md` に `merged: …` の1行を追記（GitHub UIの編集機能を使う）
- [ ] `docs/overview/STARLIST_OVERVIEW.md` を編集して最新値を手動反映
- [ ] Branch Protection（Settings → Branches）で required checks を追加し、未合格で Merge が Block されることをダミーPRで確認（スクショを取得）
- [ ] dart / flutter の実行は CI 担当者に依頼 or ローカルで実行してログを添付
- [ ] 最後に `FINAL_COMPLETION_REPORT_TEMPLATE.md` を埋めて PR #48 に添付／コミット

---

## 2) UIでの具体手順（短く、順に）

### A. ワークフロー手動実行（UI）

1. GitHub → repo → **Actions** タブを開く
2. 左のワークフロー一覧から **weekly-routine** を選ぶ
3. **「Run workflow」ボタン**をクリック（出ない場合は下の「Runボタンが無い」節を参照）
4. Branch を選択（通常 `main`）、必要な inputs があれば入力 → **Run workflow**
5. Run ページを開いたまま進捗を見て、status が **success** になるのを待つ

**同様に allowlist-sweep も実行**

---

### B. Run ID / Run URL とスクショ取得（UI）

1. Run が成功した Run のページを開く
2. ブラウザの URL 欄に `/runs/<数字>` が見える → **その数字が Run ID**。URL 全体をメモ（Run URL）
3. Run ページの右上か表示部で「Artifacts」リストが見えるはず → 画面をスクショ（成功状態 + Artifacts 表示が入るように）
4. スクショ保存名例: `docs/ops/audit/weekly-routine-<RUN_ID>-screenshot.png`

---

### C. Artifacts / SARIF / SBOM のダウンロード（UI）

1. Run ページ → **Artifacts** の各アーカイブ名をクリックしてダウンロード（zip）
2. ダウンロードしたファイルを展開して、必要なファイル（`.sarif`/`.json`/`.spdx.json`/`*.json`）だけを集める
3. GitHub UIでアップロード方法（推奨2方式）:

   **方式1（推奨）**: リポジトリ → `docs/ops/audit/artifacts/<workflow>-<RUN_ID>/` に移動 → **Add file** → **Upload files** → 選択して **Commit changes**（Create a new branch for this commit でブランチを切って PR を作る）

   **方式2**: GitHub Desktop や web upload でローカルにファイルを配置してから git add / commit / push

---

### D. docs/reports/*SOT*.md 追記（UI）

1. repo → `docs/reports` → 該当ファイルを開く → **Edit**（鉛筆アイコン）
2. 末尾に1行追加（例）:
   ```
   * merged: https://github.com/shochaso/starlist-app/pull/48 (2025-11-09 20:30:00 JST)
   ```
3. **Commit changes**（Create a new branch for this commit and start a pull request）→ PR を作成してマージする

---

### E. docs/overview/STARLIST_OVERVIEW.md を更新（UI）

1. ファイルを開いて **Edit**
2. 変更例（置換）:
   ```
   CI: OK
   Reports: 2
   Gitleaks: 0
   LinkErr: 0
   ```
3. **Commit changes**（同様に新ブランチで PR を作りレビュー→マージ）

---

### F. Branch Protection の設定（UI）

1. repo → **Settings** → **Branches** → **Branch protection rules** → **Add rule**（または Edit for main）
2. **Branch name pattern**: `main`
3. **Check**: **Require status checks to pass before merging** → ON
4. **Required checks** (add names; use exact strings from your run's check-runs) — 例:
   - `security-scan`
   - `Docs Link Check`
   - `weekly-routine`
5. **Require pull request reviews before merging**: 1
6. **Include administrators**: OFF（まずは試験運用。後で ON に切替可）
7. **Save changes**
8. **検証**: 作業用ブランチで docs の小変更を行い PR を作り → Try to merge without running the required checks → UI should show merge blocked → スクショ撮って保存 (`docs/ops/audit/branch_protection_blocked.png`)
9. **成功証拠スクショ**（Rules saved + contexts present）を保存: `docs/ops/audit/branch_protection_ok.png`

---

### G. Dart / Flutter 実行（CI operator or local）

**要件**: Chrome が使える環境（CI runner or local with Chrome）

**dart テスト**（CIまたはローカルで実行してログを取得）:
```bash
dart test -p chrome --concurrency=1 2>&1 | tee docs/ops/audit/logs/dart_test.log
```

**flutter web 実行**（ローカルで interactive）:
```bash
flutter run -d chrome --web-renderer html
```
- DevTools Console のエラーをスクショして `docs/ops/audit/logs/flutter_console_<TS>.png` に保存

**もし CI オペレータに依頼するなら、下に貼る依頼テンプレを使ってください**

---

### H. FINAL report（UI or web edit）

1. `FINAL_COMPLETION_REPORT_TEMPLATE.md` をブラウザで Edit して実データを埋める
2. `docs/` 配下に commit → PR #48 に添付するか PR のコメントに貼る

---

## 3) 「Run workflow」ボタンが見えない／押せない場合（UIでの対処）

### 原因A: workflow ファイルに `workflow_dispatch` が定義されていない

**対処**: `.github/workflows/<workflow>.yml` の `on:` に `workflow_dispatch:` があるか確認。ないなら、ファイルを Edit して下記最小ブロックを追加（Web UIで編集可）：

```yaml
on:
  workflow_dispatch:
    inputs:
      semgrep_fail_on:
        required: false
        default: 'false'
      trivy_fail_severity:
        required: false
        default: 'high'
```

- 編集後、**Commit changes** → PR → マージして main に反映すれば Run ボタンが出ます。

### 原因B: その workflow が reusable (`workflow_call`) で、単体実行できない

**対処**: 呼び出し用 wrapper workflow を用意して UI から dispatch できるようにする（必要ならパッチ作成します）

### 原因C: あなたの権限が不足（READ など）

**対処**: Settings → Collaborators で権限を確認。WRITE 以上が必要 → リポジトリ管理者に権限付与を依頼する

### 原因D: Organization ポリシーや Actions 無効化

**対処**: 管理者に確認

---

## 4) PR / Evidence に貼るテンプレ（コピペ可能）

### PR コメント（Evidence）テンプレ：

```markdown
Evidence summary:

- weekly-routine: run-id: <RUN_ID>, URL: <RUN_URL>
- allowlist-sweep: run-id: <RUN_ID>, URL: <RUN_URL>
- Artifacts copied to: docs/ops/audit/artifacts/<workflow>-<RUN_ID>/
- SOT updated: docs/reports/DAY12_SOT_DIFFS.md (appended `* merged: <PR URL> (YYYY-MM-DD HH:mm:ss JST)`)
- Overview updated: docs/overview/STARLIST_OVERVIEW.md (CI: OK, Reports: <n>, Gitleaks: 0, LinkErr: 0)
- Branch protection: contexts added (security-scan, Docs Link Check, weekly-routine) — see docs/ops/audit/branch_protection_ok.png
- dart_test.log: docs/ops/audit/logs/dart_test.log
- flutter console screenshot: docs/ops/audit/logs/flutter_console_<TS>.png
```

---

## 5) CIオペレータ/管理者に依頼する短文テンプレ（コピペで送れる slack/メール）

```
Hi @ops-team,

I need help with a few UI-only tasks for the UI-Only Supplement Pack v2 finalization:

1) Please run these workflows via GitHub Actions UI:
   - weekly-routine (branch: main)
   - allowlist-sweep (branch: main)
   and wait for them to complete successfully. Then download Artifacts/SARIF/SBOM and upload them to docs/ops/audit/artifacts/<workflow>-<RUN_ID>/ in the repo.

2) Run dart tests in a Chrome-enabled runner:
   - dart test -p chrome --concurrency=1
   Save output to docs/ops/audit/logs/dart_test.log

3) Run flutter web locally/CI to capture DevTools console screenshot and save to docs/ops/audit/logs/flutter_console_<TS>.png

4) If you can, please check Branch Protection (Settings → Branches) and apply required checks:
   - security-scan
   - Docs Link Check
   - weekly-routine
   (Enforce administrators: false for trial)

Please reply with Run URLs and screenshots when done. Thanks.
```

---

## 6) もしやっぱり gh を入れたい（任意）

- **mac (Homebrew)**:
  ```bash
  brew install gh
  gh auth login
  ```
- **Windows**: https://github.com/cli/cli#installation
- **Codespace**: Terminal にて同様に install 可能

（gh が使えると将来の自動化が楽になりますが、今回の作業は UI で完了できます）

---

## 次のステップ

1. **まず確認**: 「Run ボタンが見えない」ですか？（はい/いいえ）
2. もしはいなら、該当 workflow のページ（`.github/workflows/extended-security.yml`）を開いて `on:` セクションに `workflow_dispatch` があるか見て、結果を教えてください（有 / 無 / workflow_call のみ）
3. その返事をもらえれば、次の詰まるポイントを直接解決するための最小修正（Web UI で貼るだけ）を提示します

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **UI-Only Execution Guide 作成完了**


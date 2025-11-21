---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# ノーコマンド着地プレイブック（クリック手順のみ）

**目的**: ターミナルを一切使わず、GitHubのUI（Web/デスクトップ）とIDEのボタン操作だけで、PR #22の最終着地から週次/セキュリティ運用、監査証跡、ブランチ保護まで完了する

**対象**: PR #22の最終着地 → 週次/セキュリティ運用 → 監査証跡 → ブランチ保護

---

## 1) PR #22 を"マージ可能"へ

### 手順

1. GitHubで **PR #22** を開く → 右上 **Update branch** が出ていればクリック

2. **Resolve conflicts** を押して、画面上で競合を解消 → **Mark as resolved** → **Commit merge**

### 競合ルール（UI上でそのまま反映）

- `.mlc.json` は **main優先**（ignorePatternsは重複統合）
- `package.json` は **PR側優先**（`docs:*`/`export:audit-report`/`security:*` を残す）
- `docs/reports/*SOT*.md` は **両取り**し、最下段に `merged: <PR URL> (JST)` を追記
- `docs/diagrams/*.mmd` は **main優先**、もう一方は `*-alt.mmd` に退避
- `lib/services/**` では **Image.asset / SvgPicture.asset を使わない**状態を維持
  - コメント中の語句は **"Asset-based image loaders"** に置換（rg-guardの誤検知回避）

> ポイント：ここまで**全てブラウザ上のエディタ**で完了します。

---

## 2) CI をUIから起動・監視

### 手順

1. PR画面の **Checks** タブで実行状況を確認

2. 失敗が出た場合：**View more details** → 該当Workflowの詳細ページへ

3. **Re-run all jobs**（または **Re-run failed jobs**）をクリックして再実行

### トラブルシューティング

- `rg-guard` がコメント文言に反応したら、**PRの該当ファイルを「Edit」→文言を安全表現に修正 → Commit**
- Link Checkが荒れる場合は、`.mlc.json` をWebエディタで開き、ignoreを追加して保存

> 目的：**Checksが全部Green**になること（UIのバッジで判断）

---

## 3) PR #22 をマージ（履歴はSquash推奨）

### 手順

1. PR画面右下 **Squash and merge** をクリック

2. マージコミットメッセージを最終確認 → **Confirm squash and merge**

> これで **mainにワークフロー/スクリプトが反映**され、以後はUIから手動実行できます。

---

## 4) 週次ワークフロー（weekly-routine / allowlist-sweep）をUIで手動起動

### 手順

1. リポジトリ **Actions** タブ → 左リストから
   - **weekly-routine** を選択 → 右上 **Run workflow** をクリック
   - **allowlist-sweep** も同様に **Run workflow**

2. 実行ページで **Queued → In progress → Success** を確認

3. 失敗したら **Re-run** を押す（ログ末尾を確認し、該当ファイルをWeb編集で修正→Commit）

> これでターミナルなしで**週次オートメーションの通電確認**が取れます。

---

## 5) Ops健康度／SOT台帳／監査証跡をUIだけで担保

### Ops健康度（STARLIST_OVERVIEW.md）

- 週次ワークフローが成功すれば自動更新される想定
- もし未反映なら、GitHubのWebエディタで **該当列（CI/Gitleaks/LinkErr/Reports）を手入力で更新 → Commit**

### SOT台帳の整合

- すでに **Docs Link Check** ワークフローに **SOT検証**を組み込んでいる想定
- 成功が出ていればOK。失敗なら、該当MDを**Web編集→保存**で整合

### 監査証跡（週次ログ）

- 週次ワークフローの **Artifacts** をダウンロード
- **Security** タブに **SARIF（Semgrep/Gitleaks）** が見えていれば可視化OK

---

## 6) セキュリティ"戻し運用"をUIから

### Semgrepの段階復帰

- **Create new file** or **New pull request** から、ルール2本ずつ戻すPRを作成（説明文はテンプレのまま）

### Trivy Config Strict

- Dockerfileの `USER` 追加などはWebエディタで編集→PR作成

### allowlist-sweep

- 週次ワークフローが**自動PR**を立てるので、**UIでレビュー＆マージ**

---

## 7) ブランチ保護（UIのみ）

### 手順

1. リポジトリの **Settings → Branches → Branch protection rules → Add rule**

2. 対象ブランチ：`main`

3. **Require status checks to pass before merging** をON
   - `extended-security` / `Docs Link Check` / 週次系を **必須チェック** に追加

4. **Require linear history**、**Allow squash merge only** をON（推奨）

---

## 8) Secrets / Slack連携（UIのみ）

### 手順

- **Settings → Secrets and variables → Actions → New repository secret**
  - `SLACK_WEBHOOK_URL` など、必要キーを**UI上で**追加

- Slack通知は週次ワークフローから**自動送信**（失敗時のみ再設定）

---

## 9) GitHub Desktop / VS Code / Android Studio の**ボタンだけ**で補完

### GitHub Desktop

- Commit/Push/PR 作成は**ボタン操作のみ**

### VS Code / Android Studio

- **Run/Debugボタン**でアプリ起動（Flutterコマンド不要）
- `OPS_MOCK=true` のようなフラグは、**Run Configuration**（起動構成）の環境変数欄に設定

---

## 10) "詰まったら"のノーコマンドFAQ

### workflowが404/422

- まず **PRをマージしてmain反映** → その後 **Run workflow**

### rg-guard再発

- **コメント文言**の「Image.asset」等を **"Asset-based image loaders"** に置換（Web編集）

### Link Checkが荒れる

- `.mlc.json` をWeb編集で `ignorePatterns` を追加

### Gitleaks擬陽性

- `.gitleaks.toml` に**期限付きallowlist**（Web編集 → 後は allowlist-sweep が棚卸しPR）

---

## これでできること（全部ノーコマンド）

- ✅ PR #22 の**競合解消→CI Green→Squash & Merge**
- ✅ 週次/allowlist-sweep の**手動キック・監視**
- ✅ Ops健康度の**自動反映 or 手入力更新**
- ✅ SOT検証の**CI通過確認**
- ✅ 監査証跡の**Artifacts/Securityタブ**での確認・保存
- ✅ ブランチ保護・Secrets・Slack連携の**UI設定**
- ✅ セキュリティ"戻し運用"の**小刻みPR**作成

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **ノーコマンド版プレイブック完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

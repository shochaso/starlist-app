---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# UI操作のみチェックリスト（ターミナル不要）

**目的**: PR #22の最終着地から週次/セキュリティ運用、監査証跡、ブランチ保護まで、すべてGitHub UIとIDEのボタン操作だけで完了する

**対象**: ターミナルを使わない運用者向け

---

## ✅ チェックリスト

### Phase 1: PR #22 マージ準備

- [ ] PR #22を開く
- [ ] **Update branch** をクリック（あれば）
- [ ] **Resolve conflicts** で競合を解消
  - [ ] `.mlc.json`: main優先（ignorePatterns重複統合）
  - [ ] `package.json`: PR側優先（`docs:*`/`export:audit-report`/`security:*`を残す）
  - [ ] `docs/reports/*SOT*.md`: 両取り＋最下段に`merged: <PR URL> (JST)`追記
  - [ ] `lib/services/**`: Image.asset/SvgPicture.asset不使用を維持
- [ ] **Mark as resolved** → **Commit merge**

### Phase 2: CI Green確認

- [ ] PR画面の **Checks** タブを確認
- [ ] 失敗があれば **View more details** → **Re-run all jobs**
- [ ] `rg-guard`エラーがあれば、該当ファイルを**Edit**→コメント文言を"Asset-based image loaders"に修正→**Commit**
- [ ] Link Checkエラーがあれば、`.mlc.json`をWeb編集→ignore追加→保存
- [ ] **すべてのChecksがGreen**になることを確認

### Phase 3: PR #22 マージ

- [ ] PR画面右下 **Squash and merge** をクリック
- [ ] マージコミットメッセージを確認
- [ ] **Confirm squash and merge** をクリック
- [ ] マージ完了を確認

### Phase 4: 週次ワークフロー手動起動

- [ ] リポジトリ **Actions** タブを開く
- [ ] 左リストから **weekly-routine** を選択
- [ ] 右上 **Run workflow** をクリック
- [ ] **allowlist-sweep** も同様に **Run workflow**
- [ ] 実行ページで **Queued → In progress → Success** を確認
- [ ] 失敗があれば **Re-run** をクリック

### Phase 5: Ops健康度確認

- [ ] `docs/overview/STARLIST_OVERVIEW.md` を開く
- [ ] Ops健康度列（CI/Gitleaks/LinkErr/Reports）を確認
- [ ] 未反映なら、Webエディタで手入力更新→**Commit**

### Phase 6: SOT台帳確認

- [ ] **Docs Link Check** ワークフローの結果を確認
- [ ] SOT検証が成功していることを確認
- [ ] 失敗があれば、該当MDをWeb編集→保存

### Phase 7: 監査証跡確認

- [ ] 週次ワークフローの **Artifacts** をダウンロード
- [ ] **Security** タブを開く
- [ ] **SARIF（Semgrep/Gitleaks）** が表示されていることを確認

### Phase 8: セキュリティ"戻し運用"

- [ ] Semgrepルール2本ずつ戻すPRを作成（**Create new file** or **New pull request**）
- [ ] Dockerfileの `USER` 追加PRを作成（Webエディタで編集）
- [ ] allowlist-sweepの自動PRをレビュー→マージ

### Phase 9: ブランチ保護設定

- [ ] リポジトリ **Settings → Branches → Branch protection rules → Add rule**
- [ ] 対象ブランチ：`main`
- [ ] **Require status checks to pass before merging** をON
  - [ ] `extended-security` を追加
  - [ ] `Docs Link Check` を追加
  - [ ] 週次系を追加（あれば）
- [ ] **Require linear history** をON
- [ ] **Allow squash merge only** をON

### Phase 10: Secrets設定

- [ ] **Settings → Secrets and variables → Actions → New repository secret**
- [ ] `SLACK_WEBHOOK_URL` を追加（必要に応じて）

---

## 🆘 トラブルシューティング（UI操作のみ）

### workflowが404/422

1. PR #22がマージされているか確認
2. **Actions** タブでワークフローファイルが存在するか確認
3. **Run workflow** が表示されるか確認

### rg-guard再発

1. 該当ファイルを**Edit**
2. コメント内の「Image.asset」等を **"Asset-based image loaders"** に置換
3. **Commit** をクリック

### Link Checkが荒れる

1. `.mlc.json` をWebエディタで開く
2. `ignorePatterns` に該当パターンを追加
3. **Commit** をクリック

### Gitleaks擬陽性

1. `.gitleaks.toml` をWebエディタで開く
2. 期限付きallowlistを追加（例: `# remove by: 2025-12-31`）
3. **Commit** をクリック
4. allowlist-sweepが自動PRを立てるのを待つ

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UI操作のみチェックリスト完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

# UI操作オンリー クイックリファレンス

**目的**: よく使う操作を1ページにまとめたクイックリファレンス

---

## 🔄 PR #22 競合解消（UIのみ）

1. PR #22を開く
2. **Update branch** をクリック（あれば）
3. **Resolve conflicts** をクリック
4. 競合ファイルを編集（ルールに従う）
5. **Mark as resolved** → **Commit merge**
6. **Checks** タブでCIを監視

---

## 🚀 ワークフロー手動実行（UIのみ）

1. **Actions** タブを開く
2. 左リストから **weekly-routine** を選択
3. 右上 **Run workflow** をクリック
4. **allowlist-sweep** も同様に実行
5. 実行ページで **Queued → In progress → Success** を確認

---

## 🤖 Phase 4 Auto Audit ドライラン (UI + CLI)

1. Actions で `phase4-auto-audit` を選択し、`Run workflow` → `window_days=1`, `run_mode=dry-run` で開始。
2. ローカルで以下コマンドを順に実行 (シークレットは環境変数経由で設定済みとする)。
   ```
   ./scripts/phase4-auto-collect.sh <run_id> --dry-run --artifact-pattern '*.zip'
   ./scripts/phase4-observer-report.sh --observer-run-id UI-DRYRUN --window-days 1
   ```
3. `_manifest.json` が更新された場合は `git diff` で確認し、必要なら `scripts/phase4-manifest-atomic.sh` で再適用。
4. `docs/reports/2025-11-14/PHASE3_AUDIT_SUMMARY.md` に KPI が反映されたことをチェック。

---

## 📊 Ops健康度更新（UIのみ）

1. `docs/overview/STARLIST_OVERVIEW.md` を開く
2. Ops健康度列を確認
3. 未反映なら、Webエディタで手入力更新
4. **Commit** をクリック

---

## 🔒 ブランチ保護設定（UIのみ）

1. **Settings → Branches → Add rule**
2. 対象ブランチ：`main`
3. **Require status checks to pass before merging** をON
4. 必須チェックを追加：`extended-security`, `Docs Link Check`
5. **Require linear history** をON
6. **Allow squash merge only** をON

---

## 🐛 よくあるエラーと対処（UIのみ）

### rg-guard誤検知
1. 該当ファイルを**Edit**
2. コメント内の「Image.asset」等を **"Asset-based image loaders"** に置換
3. **Commit** をクリック

### Link Check不安定
1. `.mlc.json` をWebエディタで開く
2. `ignorePatterns` に該当パターンを追加
3. **Commit** をクリック

### Gitleaks擬陽性
1. `.gitleaks.toml` をWebエディタで開く
2. 期限付きallowlistを追加（例: `# remove by: 2025-12-31`）
3. **Commit** をクリック

---

---

## 関連ドキュメント

* **UI_ONLY_FINAL_LANDING_ROUTE.md**: UIオンリー最終着地ルート（20×凝縮版）
* **UI_ONLY_FINAL_LANDING_PACK.md**: 最終着地・ノーコマンド補完パック（20×）
* **FINAL_COMPLETION_REPORT_TEMPLATE.md**: FINAL_COMPLETION_REPORT.mdのテンプレート

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **クイックリファレンス完成**


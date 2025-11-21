---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

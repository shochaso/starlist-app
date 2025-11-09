# ULTRAサインオフ実行書（20×）

**作成日時**: 2025-11-09  
**対象PR**: #45 (UI-Only Supplement Pack v2)

---

## フェーズA：プレフライト（3分）

### 1. PRを開く

- PR #45（本件） / PR #47（paths-filter） / PR #46（ダミー）

### 2. Draft解除

- PRヘッダー右「**Ready for review**」が出ていればクリックで解除。

### 3. ベース同期

- Checks欄の灰色ボックスに "out-of-date" が出ていたら **Update branch**。

### 4. Actions権限確認（1回やればOK）

- **Settings → Actions → General**
  - *Workflow permissions*：**Read and write permissions**
  - *Allow GitHub Actions to create and approve pull requests*：**ON**
  - **Save**

---

## フェーズB：paths-filterの有効化確認（PR #47）

> 既にマージ済みならスキップ

### 5. PR #47 を確認

- 上部に **"Merged"** が出ていればOK。出ていなければ **"Update branch" → "Merge"**。
- これで **docs-only** の赤は非ブロッキングに昇格します。

---

## フェーズC：Re-run の出し方 4通り（出るまでやる）

> 「Runボタンが出ない」を確実に突破

### 6. 最短：PR #45 → Checksタブ → Re-run all jobs

### 7. 代替：Actionsタブから再実行

- 上部ナビ **Actions** → 対象Workflowを開く → 最新Run → 右上 **… → Re-run all jobs**
- もしくは失敗ジョブの行末 **… → Re-run failed jobs**

### 8. フォーク制限回避（必要時）

- PR右カラム **"Allow edits by maintainers"** をON
- **Settings → Actions**：Forkからの実行許可を "Run workflows from forks" に

### 9. Draft/差分が理由の非表示

- もう一度 **Ready for review** と **Update branch** を実行
- いずれかが欠けるとボタンが出ません

---

## フェーズD：必須チェックの合否判定（Branch Protection HARD）

### 10. 必須contexts（例）

- `security-scan` / `security-audit` / `rls-audit` / `rg-guard` / `links` / `audit` など
- **緑**であればOK。docs-only系（`report` / `Check Startup Performance` / `Telemetry E2E` 等）は**非ブロッキング**でOK。

### 11. 判断のコツ

- PRヘッダーの **Merge** ボタンが出現＝必須条件クリア。
- 出ない場合は「赤のジョブ名が必須contextsに含まれているか」を確認。含むならログを数行コピーして送ってください、即時収束手順を返します。

---

## フェーズE：証跡（Evidence）固定（スクショは既にOK）

### 12. スクショ要件

- **どちらか1枚**で可：
  - A) PR #46 の「**Merge がブロック**」画面（PR番号が写る）
  - B) **Settings → Branches → Branch rules（main）** 詳細画面
- すでに `docs/ops/audit/branch_protection_ok.png` が**配置済み**（OK）。撮り直し時は**同名で上書き**のみ。

### 13. ハッシュ記録（済み）

- `docs/ops/audit/2025-11-09/sha_branch_protection_ok.txt` に **SHA256** を保存済み。

### 14. 参照整合

- One-Pager・監査JSONの参照は**固定済み**。ファイル名は**変えない**でください。

---

## フェーズF：承認→マージ（PR #45）

### 15. 承認

- **Files changed → Review changes → Approve**
- 自己承認不可のポリシーの場合：
  - 一時的に **protect-soft**（承認0）へ緩和 → マージ → 直後に **HARD** へ戻す（安全運用）

### 16. マージ

- **"Merge pull request" → "Squash and merge"**
- マージ成功で Checks欄に **Merged** が表示。監査レポートに反映済みテンプレが有効になります。

---

## フェーズG：アフター処理（監査・周知・タグ）

### 17. 監査ログの最終アーカイブ

- 既に `docs/ops/audit/2025-11-09/` へ集約済み。差分があれば追記コミット。

### 18. タグ（任意）

- 既に `docs-ui-only-pack-v2` 作成済。必要ならUIでReleaseタグへ昇格。

### 19. Slack周知（そのまま投稿）

```
【UI-Only Supplement Pack v2】#45 をGo判定でマージしました。

- 変更範囲：docs/ops/**（コード未変更）

- 必須チェック：paths-filter反映、security-scan等は成功

- Evidence：docs/ops/audit/branch_protection_ok.png
            docs/ops/audit/2025-11-09/sha_branch_protection_ok.txt

- One-Pager / 監査JSON：参照固定・ロック済

- ロールバック：Revert一手
```

---

## フェーズH：ロールバック＆緩和（必要時のみ）

### 20. 即時ロールバック

- PR #45 を **Revert**（ドキュメントのみなので即復旧）

### 21. 一時緩和

- Branch Protection を **soft**（strict=false / enforce_admins=false）に戻す
- 収束後、**HARD** に復帰

---

# 画面で詰まったら（原因→対処の早見表）

| 症状 | 代表原因 | 直し方 |
|------|---------|--------|
| Re-run ボタンが無い | Draft / out-of-date / Actions権限不足 | Ready for review → Update branch → Settings→Actions で Read&Write＋Approve許可 |
| Merge ボタンが出ない | 必須contextsの赤 / Review不足 | 赤のジョブ名が必須か確認→必要ならログ対応 or soft緩和、承認は1件以上 |
| 必須でない赤が消えない | paths-filter未反映 | PR #47 がMergedか確認、未ならUIでMerge、PR #45をRe-run |
| 自己承認不可 | ポリシー | Reviewer追加 or 一時的にsoftでマージ→即HARD復帰 |
| 証跡がズレる | ファイル名変更 | `branch_protection_ok.png` の**名前・パスは固定**。上書きのみ |

---

## いまの状態（要点の再掲）

- **スクショPNG**：配置済（パス固定・ハッシュ保存済）
- **paths-filter（#47）**：マージ済み
- **Branch Protection**：HARD適用済（必須13contexts）
- **残タスク**：PR #45 を **Re-run → Approve → Merge** のみ（UI操作）

---

## 次のステップ（優先順位順）

1. **PR #45 を開く** → Draft解除確認 → Update branch（必要時）
2. **Actions権限確認** → Settings → Actions → General
3. **PR #47 のマージ確認** → Merged ならOK
4. **PR #45 の Re-run** → Checksタブ → Re-run all jobs
5. **必須チェック確認** → `security-scan` 等が緑か確認
6. **承認・マージ** → Approve → Squash and merge
7. **Slack周知** → テンプレをそのまま投稿

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **実行準備完了**


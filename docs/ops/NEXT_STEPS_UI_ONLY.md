# 次のステップ（UI-Only操作）

**作成日時**: 2025-11-09  
**現在の状態**: 証跡固定完了、paths-filter適用済み、PR #45 のRe-run・承認・マージ待ち

---

## ✅ 完了済み項目

1. ✅ **証跡固定**: `branch_protection_ok.png` 配置済み、SHA256保存済み
2. ✅ **監査JSON更新**: 参照パス固定済み
3. ✅ **paths-filter適用**: PR #47 マージ済み
4. ✅ **Branch Protection**: HARD適用済み（必須13contexts）
5. ✅ **監査ログアーカイブ**: `docs/ops/audit/2025-11-09/` に集約済み
6. ✅ **タグ作成**: `docs-ui-only-pack-v2` 作成済み

---

## 📋 次のステップ（GitHub UI操作）

### ステップ1: PR #45 を開く

1. **PR #45** を開く: https://github.com/shochaso/starlist-app/pull/45
2. **Draft解除確認**: PRヘッダー右に「Ready for review」があればクリック
3. **ベース同期**: Checks欄に "out-of-date" があれば「Update branch」をクリック

---

### ステップ2: Actions権限確認（初回のみ）

1. **Settings** → **Actions** → **General**
2. **Workflow permissions**: 「Read and write permissions」を選択
3. **Allow GitHub Actions to create and approve pull requests**: ON
4. **Save**

---

### ステップ3: PR #47 のマージ確認

1. **PR #47** を開く: https://github.com/shochaso/starlist-app/pull/47
2. 上部に **"Merged"** が表示されていればOK
3. 未マージの場合は「Update branch」→「Merge」を実行

---

### ステップ4: PR #45 の Re-run

**方法A（推奨）**: PR #45 → **Checks**タブ → **Re-run all jobs**

**方法B（代替）**: 
1. **Actions**タブを開く
2. 対象Workflow（例: `extended-security.yml`）を開く
3. 最新Run → 右上 **…** → **Re-run all jobs**

**方法C（失敗ジョブのみ）**: 
- 失敗ジョブの行末 **…** → **Re-run failed jobs**

**Re-runボタンが出ない場合**:
- 「Ready for review」と「Update branch」を再実行
- PR右カラム「Allow edits by maintainers」をON
- Settings → Actions → Forkからの実行許可を確認

---

### ステップ5: 必須チェックの合否判定

**必須contexts（緑である必要あり）**:
- `security-scan` ✅
- `security-audit` ⚠️（docs-onlyの場合は非ブロッキング）
- `rls-audit` ✅
- `rg-guard` ✅
- `links` ✅
- `audit` ✅

**非ブロッキング（docs-onlyの場合は赤でもOK）**:
- `report` ⚠️
- `Check Startup Performance` ⚠️
- `Telemetry E2E Tests` ⚠️

**判断のコツ**:
- PRヘッダーの **Merge** ボタンが出現 = 必須条件クリア
- Mergeボタンが出ない = 必須contextsの赤がある or 承認不足

---

### ステップ6: 承認・マージ

**承認**:
1. **Files changed**タブを開く
2. **Review changes** → **Approve** をクリック

**自己承認不可の場合**:
- 別ユーザーに承認依頼
- または一時的に `protect-soft` で緩和 → マージ → 即 `protect-hard` 復帰

**マージ**:
1. **Merge pull request** → **Squash and merge** を選択
2. マージ成功で Checks欄に **Merged** が表示

---

### ステップ7: Slack周知

以下のテンプレをそのまま投稿:

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

## 🔧 トラブルシューティング

### Re-runボタンが無い

**原因**: Draft / out-of-date / Actions権限不足

**対処**:
1. 「Ready for review」をクリック
2. 「Update branch」をクリック
3. Settings → Actions → Read&Write + Approve許可

---

### Mergeボタンが出ない

**原因**: 必須contextsの赤 / Review不足

**対処**:
1. 赤のジョブ名が必須contextsに含まれているか確認
2. 含まれている場合はログを確認して対応
3. または一時的に `protect-soft` で緩和 → マージ → 即 `protect-hard` 復帰
4. 承認は1件以上必要

---

### 必須でない赤が消えない

**原因**: paths-filter未反映

**対処**:
1. PR #47 がMergedか確認
2. 未マージの場合はUIでMerge
3. PR #45をRe-run

---

### 自己承認不可

**原因**: ポリシー

**対処**:
1. Reviewer追加
2. または一時的に `protect-soft` でマージ → 即 `protect-hard` 復帰

---

### 証跡がズレる

**原因**: ファイル名変更

**対処**:
- `branch_protection_ok.png` の**名前・パスは固定**。上書きのみ。

---

## 📋 チェックリスト

- [ ] PR #45 を開く
- [ ] Draft解除確認
- [ ] ベース同期（Update branch）
- [ ] Actions権限確認（初回のみ）
- [ ] PR #47 のマージ確認
- [ ] PR #45 の Re-run
- [ ] 必須チェックの合否判定
- [ ] 承認・マージ
- [ ] Slack周知

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **実行準備完了**


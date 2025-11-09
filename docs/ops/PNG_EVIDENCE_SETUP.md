# PNG Evidence Setup — スクリーンショット証跡設定手順

**作成日時**: 2025-11-09  
**目的**: Branch Protection証跡のスクリーンショットPNGを配置・固定する手順

---

## 📋 手順

### 1. スクリーンショット撮影

**macOS**:
1. `Shift+Cmd+4` でスクリーンショットモード
2. 以下のいずれかを撮影:
   - **PR #46** の「Mergeボタンがブロック」画面
   - **Settings → Branches** の main ルール詳細画面
3. PNG保存

---

### 2. ファイル配置

**保存先**: `docs/ops/audit/branch_protection_ok.png`

**配置方法**:
- Finderで `docs/ops/audit/` を開く
- スクリーンショットPNGを `branch_protection_ok.png` として保存

---

### 3. ハッシュ化・証跡固定

**コマンド**:
```bash
# PNGファイルをステージング
git add docs/ops/audit/branch_protection_ok.png

# SHA256ハッシュ計算・保存（日付フォルダに保存）
TODAY=$(date +%F)
mkdir -p docs/ops/audit/${TODAY}
shasum -a 256 docs/ops/audit/branch_protection_ok.png | tee docs/ops/audit/${TODAY}/sha_branch_protection_ok.txt

# SHA256ファイルをステージング
git add docs/ops/audit/${TODAY}/sha_branch_protection_ok.txt

# コミット・プッシュ
git commit -m "docs(audit): add Branch Protection proof screenshot + SHA256"
git push
```

---

### 4. PR #48に証跡コメント再投稿

**コマンド**:
```bash
export GITHUB_TOKEN=github_pat_...
RUN_ID=$(gh run list --workflow extended-security.yml --limit 1 --json databaseId --jq '.[0].databaseId')
make -f Makefile.branch-protection RUN_ID=${RUN_ID} evidence
make -f Makefile.branch-protection PR=48 comment
```

---

## ⚠️ 注意事項

### `.gitignore` の影響

`docs/ops/audit/logs` が `.gitignore` で無視されているため、SHA256ファイルは日付フォルダ（`docs/ops/audit/${TODAY}/`）に保存してください。

---

## 📋 確認方法

### PNGファイル確認
```bash
ls -lh docs/ops/audit/branch_protection_ok.png
```

### SHA256ファイル確認
```bash
TODAY=$(date +%F)
cat docs/ops/audit/${TODAY}/sha_branch_protection_ok.txt
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **PNG Evidence Setup 手順作成完了**

PNGファイルを配置後、上記のコマンドを実行してください。


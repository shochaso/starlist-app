# Branch Protection Go/No-Go チェックリスト

**作成日時**: 2025-11-09  
**目的**: Branch Protection適用前の最終確認

---

## ✅ 最終Go/No-Go判定表

### 1. contexts整合性

- [ ] `/tmp/bp/contexts.json` と PR実ラン名が**完全一致**
- [ ] `make contexts` で最新のcontextsを抽出済み
- [ ] 差分チェック（`comm -13`）で不一致が無い

### 2. soft適用確認

- [ ] `make protect-soft` 実行済み
- [ ] `make status` で **strict=false / enforce_admins=false** を確認
- [ ] エラー（404/403/Unprocessable Entity）が無い

### 3. Evidence準備

- [ ] スクショ `docs/ops/audit/branch_protection_ok.png` 実体保存済み
- [ ] SHA保存済み（`docs/ops/audit/logs/sha_branch_protection_ok.txt`）
- [ ] `make evidence` 実行済み
- [ ] `make comment` でPRに証跡貼付済み

### 4. PR整合確認

- [ ] PR #47（paths-filter）が **MERGED** またはマージ可能
- [ ] PR #45 を **Re-run** 後に**赤→情報扱い/緑化**を確認
- [ ] docs-only のチェックが**情報扱い/非ブロッキング**になっている

### 5. HARD適用準備

- [ ] 問題なければ `make protect-hard` で厳格化可能
- [ ] `make status` で **strict=true / enforce_admins=true** を確認

### 6. ロールバック準備

- [ ] ロールバック手段（`make protect-off` / `make protect-soft`）が**即時**に使える
- [ ] GITHUB_TOKENが設定済み

---

## 🔧 よくある詰まり → 即収束レシピ

### A. 必須チェック名が微妙に違う

**症状**: `Unprocessable Entity` エラー

**対処**:
```bash
# PR実ラン名を抽出
gh pr view 45 --json statusCheckRollup | jq -r '.statusCheckRollup[]?.name' | sort -u

# contexts.json に追記して再生成
make contexts && make soft.json && make protect-soft
```

---

### B. Adminが自分をブロック

**症状**: 自分自身がマージできない

**対処**:
```bash
# softに戻す（enforce_admins=false）
make protect-soft

# 整えてからhardに戻す
make protect-hard
```

---

### C. docs-onlyなのにブロック

**症状**: docs-only PRがブロックされる

**対処**:
```bash
# paths-filter の条件をPR #45の差分に合うよう見直し
# PR #45 を Re-run
gh pr view 45 --json statusCheckRollup | jq '{checks:[.statusCheckRollup[]? | {name, status, conclusion}]}'
```

---

## 📋 実行コマンド一覧

### contexts整合性確認
```bash
# 現在のcontexts一覧と件数
jq -cr '. | length, .' /tmp/bp/contexts.json

# PR実ラン名を可視化
gh pr view 45 --json statusCheckRollup | jq -r '.statusCheckRollup[]?.name' | sort -u | nl

# 差分抽出
comm -13 <(jq -r '.[]' /tmp/bp/contexts.json | sort -u) <(gh pr view 45 --json statusCheckRollup | jq -r '.statusCheckRollup[]?.name' | sort -u)
```

### JSON再生成 → soft適用
```bash
make contexts
make soft.json
make hard.json
export GITHUB_TOKEN=gho_...
make protect-soft
make status
```

### Evidence更新
```bash
make evidence
make comment
```

### PR整合確認
```bash
gh pr view 47 --json state,mergeable,statusCheckRollup
gh pr view 45 --json state,mergeable,statusCheckRollup
```

### HARD適用
```bash
make protect-hard
make status
```

### ロールバック
```bash
# 一時緩和
make protect-soft

# 全解除
make protect-off
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Branch Protection Go/No-Go チェックリスト作成完了**


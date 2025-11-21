---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: aligned-with-Flutter  
Source-of-Truth:: scripts/audit/md_header_apply.sh, scripts/audit/md_header_check.sh, .github/workflows/docs-status-audit.yml  
Spec-State:: 確定済み（運用ルール・スクリプト・CI統合）  
Last-Updated:: 2025-11-07  

# Docs Status Audit 運用ルール

## Status更新フロー

### 実装ブランチ作成時
```bash
# Statusを planned → in-progress に更新
gsed -i '1,100s/^Status:: .*/Status:: in-progress/' docs/path/to/file.md
gsed -i "1,100s/^Last-Updated:: .*/Last-Updated:: $(date +%Y-%m-%d)/" docs/path/to/file.md
```

### 実装完了・レビュー通過時
```bash
# Statusを aligned-with-Flutter に更新
gsed -i '1,100s/^Status:: .*/Status:: aligned-with-Flutter/' docs/path/to/file.md
gsed -i "1,100s/^Last-Updated:: .*/Last-Updated:: $(date +%Y-%m-%d)/" docs/path/to/file.md
```

> **注意**: macOSは `brew install gnu-sed` 後に `gsed` を使用。Linuxは `sed -i` で可。

## DAY5_SOT_DIFFS.md への履歴追記テンプレ

```markdown
## 2025-11-07

- Spec: `docs/<path>/<file>.md`
- Status: planned → in-progress
- Reason: DB+Edgeの実装着手
- CodeRefs:
  - `supabase/migrations/20251107_ops_metrics.sql:L1-L200`
  - `supabase/functions/telemetry/index.ts:L10-L120`
  - `lib/src/features/ops/ops_telemetry.dart:L1-L180`
```

> **CodeRefs** は実コードの行番号を必ず添える（レビュー/追跡の起点）。

## クイック監査チェックリスト

- [ ] mdの先頭付近に **`Status::`** と **`Source-of-Truth::`**（該当コードパス）を必ず記載
- [ ] `DAY5_SOT_DIFFS.md` に当日分の **コード参照（CodeRefs）** が追記されているか
- [ ] ズレが見つかったら：**mdをコードに合わせて即修正**→`SOT_DIFFS` に理由を残す

## 実行順の提案

1. `scripts/audit/md_header_apply.sh docs` - ヘッダの自動補填
2. `scripts/audit/md_header_check.sh docs` - ヘッダの整合性チェック（結果ゼロでOK）
3. 必要なファイルの `Source-of-Truth::` を具体化してコミット
4. 実装が進んだら `Status::` を `in-progress` → `aligned-with-Flutter` に更新
5. その都度、`DAY5_SOT_DIFFS.md` に **差分履歴＋CodeRefs** を追記

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# ドキュメントStatus管理運用ルール

Status:: aligned-with-Flutter  
Source-of-Truth:: scripts/audit/**, .github/workflows/docs-status-audit.yml  
Spec-State:: 確定済み  
Last-Updated:: 

## ヘッダ書式

各`.md`ファイルの先頭に以下のヘッダを記載：

```md
Status:: planned
Source-of-Truth:: <repo paths, comma-separated>
Spec-State:: 確定済み | 初期案 | 未実装
Last-Updated:: 
```

### Status値の定義

- `planned`: 実装前の計画段階
- `in-progress`: 実装中
- `aligned-with-Flutter`: Flutter実装と一致（SoT確定）

### Source-of-Truth

実装の参照元コードパスを記載（例: `lib/src/...`, `supabase/functions/...`, `server/src/...`）

### Spec-State

仕様の成熟度：
- **確定済み**: 実装基準で確定した仕様
- **初期案**: 初期案（draft）として検討中
- **未実装**: 未実装の計画項目

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

> macOSは`brew install gnu-sed`後に`gsed`を使用。Linuxは`sed -i`で可。

## SOT差分追記フロー

実装が進んだら、`docs/reports/DAY5_SOT_DIFFS.md`（または該当するSOT_DIFFSファイル）に履歴を追記：

```md
## 2025-11-07

- Spec: `docs/<path>/<file>.md`
- Status: planned → in-progress
- Reason: DB+Edgeの実装着手
- CodeRefs:
  - `supabase/migrations/20251107_ops_metrics.sql:L1-L200`
  - `supabase/functions/telemetry/index.ts:L10-L120`
  - `lib/src/features/ops/ops_telemetry.dart:L1-L180`
```

**CodeRefs**は実コードの行番号を必ず添える（レビュー/追跡の起点）。

## スクリプト使用方法

### ヘッダ一括付与

```bash
scripts/audit/md_header_apply.sh docs
```

### ヘッダ整合性チェック

```bash
scripts/audit/md_header_check.sh docs
```

### Status鮮度チェック（オプション）

```bash
scripts/audit/md_status_freshness.sh docs 7.days
```

## CI監査

`.github/workflows/docs-status-audit.yml`が自動実行され、以下を検証：

- 必須ヘッダキーの欠落
- Status値の妥当性（planned|in-progress|aligned-with-Flutter）
- Last-Updatedの自動更新

PR作成時とmainブランチへのpush時に自動実行されます。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

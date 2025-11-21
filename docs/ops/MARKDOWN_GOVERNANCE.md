---
source_of_truth: true
version: 1.0.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---











# Markdown Governance Guide

## 概要

STARLISTリポジトリでは、Markdownドキュメントの一貫性と品質を確保するために、拡張されたガバナンスルールを適用しています。このドキュメントでは、ローカル環境での検証方法とCIでの自動チェックについて説明します。

## 実装されているチェック項目

### 基本構造チェック
1. **frontmatter の存在確認** - YAML形式のfrontmatterブロックが先頭にある
2. **frontmatter 必須キー** - `source_of_truth`, `version`, `updated_date`, `owner` が含まれる
3. **updated_date 形式** - `YYYY-MM-DD` 形式である
4. **frontmatter 表記ゆらぎ禁止** - `source-of-truth` 等の誤った表記を検出

### ドキュメント構造チェック（docs/ops/ 配下のみ）
5. **必須セクション** - 背景、要件、Runbook、更新、DoDセクションの存在
6. **Cursor Implementation Prompt** - セクションの存在確認
7. **GitHub Copilot Implementation Prompt** - セクションの存在確認

### コンテンツ品質チェック
8. **見出し階層整合性** - H2の直後にH4など飛びがない
9. **禁止ワード検出** - "tbd", "todo", "fixme", "wip" 等の使用禁止
10. **空リンク検出** - `[]()` 形式の空リンク

### Mermaidダイアグラムチェック
11. **Mermaidブロック構文** - ```mermaid の開始/終了整合
12. **Mermaidブロック数整合** - 開始数と終了数の一致
13. **Mermaidキーワード** - 有効なダイアグラムキーワードを含む

### リンク・画像チェック
14. **画像リンク存在確認** - `![alt](path)` のパスが実在する
15. **画像alt属性** - 代替テキストが空でない
16. **相対リンク強制** - 外部リンクはhttpsを使用
17. **docs/ 外境界逸脱禁止** - `../..` でdocsディレクトリ外を参照しない

### コードチェック
18. **コードフェンス整合** - ``` の開始/終了整合
19. **言語宣言** - コードブロックに言語が指定されている
20. **コードバランス** - TypeScript/Dartの括弧がバランスしている

### テーブルチェック
21. **テーブル列整合** - ヘッダーとセパレーターの列数が一致

### その他
22. **BOM検出** - ファイル先頭のByte Order Mark
23. **空ファイル検出** - サイズ0または空白のみのファイル
24. **TOC整合性** - Table of Contentsと見出しの一致（簡易チェック）

## ローカル検証方法

### 基本的な実行方法

```bash
# 全Markdownファイルを検証
python scripts/starlist_md_validator.py

# 特定のファイルを検証
python scripts/starlist_md_validator.py docs/README.md docs/ops/test.md

# レポート生成付きで実行
python scripts/starlist_md_validator.py --report docs/ops/MD_VALIDATION_REPORT.md

# 自動修正を有効にして実行（frontmatter/DoDセクションのみ）
python scripts/starlist_md_validator.py --autofix
```

### CIとの連携

GitHub Actionsで自動実行されるワークフロー `markdown-validation.yml` は以下のタイミングで実行されます：

- **push**: `main`, `develop` ブランチへの変更時
- **pull_request**: `main`, `develop` ブランチへのPR作成時
- **workflow_dispatch**: 手動実行時

CIでは変更された.mdファイルのみを対象に検証が行われ、以下のツールが実行されます：

1. **STARLIST Markdown Validator** - カスタム20+チェック
2. **markdownlint-cli** - スタイルチェック
3. **markdown-link-check** - リンク存在チェック

### テスト実行

```bash
# Pythonテスト実行
python -m unittest tests/starlist_md_validator_test.py

# 詳細出力
python -m unittest tests/starlist_md_validator_test.py -v
```

## エラー出力形式

各チェックのエラーは以下の形式で出力されます：

```
❌ <ファイルパス>:<行番号> <チェックID> <説明>
```

### 代表的なエラー例

```bash
❌ docs/ops/test.md:1 frontmatter-missing Frontmatter block missing or malformed (requires --- at start).
❌ docs/ops/test.md:1 frontmatter-missing-source_of_truth Frontmatter lacks `source_of_truth`.
❌ docs/ops/test.md:15 forbidden-word Forbidden wording detected: tbd
❌ docs/ops/test.md:20 heading-hierarchy Heading level increases by more than one (H2 -> H4).
❌ docs/ops/test.md:25 link-missing Link target `nonexistent.md` not found.
❌ docs/ops/test.md:30 mermaid-unclosed Mermaid block requires closing ``` marker.
```

## 自動修正機能

`--autofix` オプションを使用すると、以下の項目が自動修正されます：

- **frontmatterの追加** - 必須キーが不足している場合、デフォルト値で追加
- **DoDセクションの追加** - docs/ops/配下のファイルにDoDセクションがない場合、テンプレートを追加

### 修正例

**修正前:**
```markdown
# Test Document

## 背景
Content here.
```

**修正後:**
```markdown
---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---

# Test Document

## 背景
Content here.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
```

## ワークフロー統合

### package.json scripts

```json
{
  "scripts": {
    "lint:md": "node scripts/ensure-node20.js && markdown-link-check -c .mlc.json -q **/*.md",
    "lint:markdownlint": "markdownlint-cli --config ./.markdownlint.json --ignore node_modules --ignore .next --ignore build --ignore dist --ignore out --ignore artifact_4544009766_dir --ignore docs/ops/MD_CI_REPORT.md \"**/*.md\"",
    "lint:md:local": "node scripts/docs/link-check.mjs"
  }
}
```

### 既存ワークフローとの役割分担

- **markdown-validation.yml**: 変更ファイル差分検査 + STARLISTカスタムチェック
- **build-lint.yml**: 一般的なコード品質チェック（既存）
- **docs-link-check.yml**: ドキュメントリンクチェック（既存）

## 移行ガイドライン

### 新規ドキュメント作成時

1. 必ずfrontmatterを先頭に配置
2. docs/ops/配下のファイルは必須セクションを全て含める
3. 見出し階層を正しく維持（1-2-3-4...）
4. 禁止ワードを使用しない
5. 画像/リンクのパスを確認

### 既存ドキュメント修正時

CIで検出されたエラーを順次修正してください。特に自動修正可能な項目（frontmatter, DoDセクション）は `--autofix` オプションを使用すると効率的です。

## トラブルシューティング

### よくあるエラーと対処法

1. **frontmatter-missing**: ファイル先頭に `---` で始まるYAMLブロックを追加
2. **heading-hierarchy**: 見出しレベルを1つずつ上げる（H1→H2→H3）
3. **forbidden-word**: "tbd" → "未定", "todo" → "作業予定" などに置き換え
4. **link-missing**: リンク先ファイルの存在を確認、または相対パスを修正

### デバッグ実行

```bash
# 詳細ログ付き実行
python scripts/starlist_md_validator.py --report debug_report.md 2>&1 | tee validation.log

# 特定のファイルのみ検証
find docs/ops -name "*.md" | head -5 | xargs python scripts/starlist_md_validator.py
```

## 更新履歴

- 2025-11-15: 初回導入。20+チェック項目の実装完了。
- 2025-11-15: CIワークフロー統合とテストコード整備。



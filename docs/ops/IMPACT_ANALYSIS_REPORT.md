---
source_of_truth: true
version: 1.0.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---

# Markdown CI Report

## 最新の実行
- 実行日時: 2025-11-15T16:00:57+00:00Z
- コマンド: `scripts/starlist_md_validator.py --report docs/ops/IMPACT_ANALYSIS_REPORT.md docs/ops/MD_CHECKLIST.md docs/ops/MARKDOWN_GOVERNANCE.md README.md`
- ファイル数: 3
- エラー数: 25
- 自動修復: 無効
- ドライラン: 無効

## 指標
- `reports_generated`: 1
- `fixes_applied`: False

## 失敗一覧
| ファイル | 行 | チェック | メッセージ | 修復可能 |
| --- | --- | --- | --- | --- |
| README.md | 18 | link-missing | Link target `/dashboard/audit` not found. | いいえ |
| README.md | 717 | codefence-unclosed | Code fence opened but never closed. | いいえ |
| README.md | 670 | table-columns | Table columns do not align between header and separator. | いいえ |
| README.md | 1 | cursor-prompt-missing | Document must contain 'Cursor Implementation Prompt' section. | いいえ |
| README.md | 1 | copilot-prompt-missing | Document must contain 'GitHub Copilot Implementation Prompt' section. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 1 | section-requirements | Missing required section: 要件セクション. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 1 | section-runbook | Missing required section: Runbook セクション. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 61 | heading-h1-duplicate | Document must contain at most one H1. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 74 | heading-order | Heading levels must increase by at most one. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 1 | toc-missing | Table of Contents (目次) is required. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 38 | image-missing | Referenced image `path` does not exist. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 38 | link-missing | Link target `path` not found. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 29 | forbidden-word | Forbidden wording detected: tbd | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 29 | forbidden-word | Forbidden wording detected: todo | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 29 | forbidden-word | Forbidden wording detected: fixme | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 29 | forbidden-word | Forbidden wording detected: wip | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 111 | forbidden-word | Forbidden wording detected: tbd | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 192 | forbidden-word | Forbidden wording detected: tbd | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 192 | forbidden-word | Forbidden wording detected: todo | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 102 | codefence-language | Code fence must declare a language. | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 127 | codefence-language-unsupported | Unsupported language: markdown | いいえ |
| docs/ops/MARKDOWN_GOVERNANCE.md | 135 | codefence-language-unsupported | Unsupported language: markdown | いいえ |
| docs/ops/MD_CHECKLIST.md | 1 | toc-missing | Table of Contents (目次) is required. | いいえ |
| docs/ops/MD_CHECKLIST.md | 1 | cursor-prompt-missing | Document must contain 'Cursor Implementation Prompt' section. | いいえ |
| docs/ops/MD_CHECKLIST.md | 1 | copilot-prompt-missing | Document must contain 'GitHub Copilot Implementation Prompt' section. | いいえ |

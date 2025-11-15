---
source_of_truth: true
version: 1.0.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---






# Markdown Governance チェックリスト

## 背景

STARLIST の Markdown ドキュメントは、AI 作成コンテンツや高速な更新サイクルに耐えるために明確な構造と自動検証を必要としています。このチェックリストは、20 種類を超える品質ゲートを実行する `validate_md_starlist.py` と `markdown-validation` CI ワークフローの基盤仕様です。

## 要件

### 機能要件
- [x] フロントマターが定義され、`source_of_truth`, `version`, `updated_date`, `owner` を含むこと
- [x] 必須セクション（背景、要件、DoD, Runbook, 更新）が存在すること
- [x] Mermaid ブロックが閉じており、キーワードを含む構文で構成されること
- [x] 画像リンクと相対リンクが存在するファイルを検証し、破損を防ぐこと
- [x] 見出し階層と ToC が整合していること
- [x] 禁止語と脆弱性につながる外部リンクの利用を検知すること
- [x] code fence が言語を宣言し、TypeScript/Dart サンプルの括弧・波括弧がバランスしていること
- [x] テーブルが列数整合を満たし、一貫したフォーマットであること
- [x] Markdown CI ログが JSON 形式で出力され、ファイル/行番号を含むこと
- [x] ドライランで検出した問題を `--autofix` で自己修復し、再検証すること
- [x] `markdownlint-cli` と `markdown-link-check` のバージョンを固定して CI で再現可能にすること
- [x] CI レポートを `docs/ops/MD_CI_REPORT.md` に Markdown 形式で保存すること

### 非機能要件
- [x] Node.js 18.x を安定実行環境として扱い、npm キャッシュを活用した GitHub Actions を構築すること
- [x] 構文チェックおよびレポート作成のすべてのファイル操作はアトミックに行うこと
- [x] ワークフローとスクリプトの出力は STARLIST らしい日本語/英語のハイブリッドで読みやすくすること

## Definition of Done

- [x] `validate_md_starlist.py` で 20 を超えるチェックを実装し、シンタックスエラーがない
- [x] `.github/workflows/markdown-validation.yml` が Node 18 + npm キャッシュ + markdown チェック + フォーマットされたログ出力を提供
- [x] `docs/ops/MD_CI_REPORT.md` に最新の実行サマリが記録される
- [x] Git ステータスがクリーンでコミット済み
- [x] テスト（`find . | python validate...`, `npm run lint:md`）が成功する

## Runbook

1. `find . -name '*.md' -print0 | xargs -0 python validate_md_starlist.py --autofix --report docs/ops/MD_CI_REPORT.md`
2. `npx markdownlint-cli --config ./.markdownlint.json --ignore node_modules --ignore .next --ignore build --ignore dist --ignore artifact_4544009766_dir --ignore docs/ops/MD_CI_REPORT.md "**/*.md"`
3. `npm run lint:md`
4. 不整合があった場合は `--autofix` で修正し、再度 `find` から実行

## リスク

- `markdownlint` のデフォルトルールが長すぎる行を検出すると既存ドキュメントが大量に失敗するため、MD013 は無効化済み
- `markdown-link-check` の実行時間が長くなる可能性があるため、GitHub Actions では Node 18 の高速キャッシュを利用し、timeout/429 リトライを設定
- `validate_md_starlist.py` の自動修復は限定的（frontmatter/DoD）であるため、重大な構造変更が必要なファイルは手動レビューが必要

## 更新

- 2025-11-15: 最初のチェックリストを追加。`validate_md_starlist.py` で 23 の検証ポイントと自動修復を導入。
- 2025-11-15: `markdown-validation` GitHub Actions と `docs/ops/MD_CI_REPORT.md` による CI レポート生成を追加。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

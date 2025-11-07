# ChatGPT 共有用ドキュメントまとめ

Starlist 関連の情報を ChatGPT などの生成 AI に共有するときの手順と、優先して渡すべき資料をまとめる。

---

## 1. 共有の目的を整理する

1. **目的の明示**: 相談したい内容（例: 決済機能の改修案、API 設計レビュー）を冒頭で一言添える。  
2. **プロジェクト概要**: `docs/overview/COMMON_DOCS_INDEX.md` の概要を最初に提示し、リポジトリ構造と関連資料の位置づけを伝える。  
3. **対象領域**: どの領域（フロントエンド／バックエンド／Supabase／データ連携 etc.）の情報が必要かを具体的に記載する。

---

## 2. 優先して共有する Markdown

| 目的 | 推奨ファイル |
| --- | --- |
| リポジトリ全体の把握 | `docs/overview/COMMON_DOCS_INDEX.md`, `docs/README.md` |
| 開発フロー・環境構築 | `docs/development/DEVELOPMENT_GUIDE.md`, `docs/development/ICON_MANAGEMENT.md` |
| 決済機能の現状 | `docs/features/payment_current_state.md`, `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md` |
| データ取り込み／ファイル運用 | `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md`, `docs/planning/Starlist まとめ.md` |
| ビジネス・タスクの背景 | `docs/planning/Task.md`, `guides/business/starlist_monetization_plan.md` など必要なもの |
| 法的文書の参照 | `docs/legal/` 配下の各種ポリシー |
| 実装進捗レビュー（Day5） | `docs/reports/STARLIST_DAY5_SUMMARY.md` |

> **Tip:** ファイルが多い場合は、関連する部分のみ抜粋して貼り付けるか、ZIP でまとめてアップロードして「docs/features/ 以下を参照して」と指示すると効率的。

---

## 3. 共有手順

1. **抜粋の準備**  
   - 相談テーマに合わせて上表から必要な Markdown を選択。  
   - 大きなファイルは要約（箇条書き）を先に作るとトークン節約になる。
2. **アップロード／貼り付け**  
   - 使用している ChatGPT クライアントがファイルアップロードに対応していれば ZIP を添付、非対応の場合は本文に直接貼る。  
   - 各ファイルのパスを明示し、複数渡す際はインデックスを付ける。
3. **コンテキストの順序**  
   1. プロジェクト概要（上記目的1・2）  
   2. 相談したい課題の説明  
   3. 関連ドキュメントの抜粋  
   4. 質問や依頼内容  
   - 例: 「目的: 決済画面の仕様整理。以下に `docs/features/payment_current_state.md` と `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md` の要約を貼るので、改善案を提案してほしい」
4. **追加情報の提供**  
   - 生成結果で不足があった場合に備え、必要に応じてログやコード抜粋も追記していく。

---

## 4. 大容量ドキュメントの扱い

- **保管場所（推奨）**: Supabase Storage に `doc-share` バケットを用意し、チーム共通で大容量資料を格納する。ChatGPT へ渡す際は期限付きの署名付き URL を発行し、必要ならローカルにダウンロードしてアップロードする。  
- **要約ファイルの作成**: 長文ドキュメントは別途サマリー（例: `docs/summary/` を作成）を用意し、それを共有する。  
- **章ごとの分割**: 章やセクション単位で分割して順番に渡すと、ChatGPT のコンテキスト上限を超えにくい。  
- **PDF/Word の扱い**: `.docx` や `.pdf` は直接読み込めない場合があるため、必要箇所をテキストに変換して渡す。

---

## 5. 共有後のチェックリスト

- [ ] ChatGPT に渡したファイルが最新か？（コミット済み最新版かどうか）  
- [ ] 目的・背景・前提条件を明確に伝えたか？  
- [ ] ChatGPT から受領確認（「確認しました」「了解です」等）を得たか？  
- [ ] ChatGPT が生成した要約／アクション項目を確認し、必要に応じて保存したか？  
- [ ] 追加情報の再提示依頼（追加資料・再アップロード等）に対応したか？  
- [ ] 追加で必要な資料があればすぐ取り出せるよう準備したか？  
- [ ] 会話ログや回答をチームと共有し、必要ならドキュメントへ反映したか？

---

このガイドを基に、テーマごとに必要な Markdown を選択し、効率的に ChatGPT へ情報提供してください。

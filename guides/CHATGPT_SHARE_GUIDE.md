# ChatGPT 共有用ドキュメントまとめ

Starlist 関連の情報を ChatGPT などの生成 AI に共有するときの手順と、優先して渡すべき資料をまとめる。

**Status**: beta  
**Last-Updated**: 2025-11-08

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
| OPS監視・通知（Day10） | `docs/reports/DAY10_SOT_DIFFS.md`, `DAY10_DEPLOYMENT_RUNBOOK.md`, `DAY10_GONOGO_CHECKLIST.md` |

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

### doc-share署名URL SOP（3行版・確定）

1) **Supabase Storage `doc-share` に格納し、期限付き署名URLを発行**（通常7日、最大30日）。  
2) **共有は最少権限（期限/閲覧のみ）、再配布は禁止**。  
3) **失効期限前に必要分のみ再発行（旧URLは無効化ログを残す）**。

### 詳細手順

#### 1. ファイルアップロード

```bash
# Supabase CLIでdoc-shareバケットにアップロード
supabase storage upload doc-share path/to/large-file.pdf
```

#### 2. 署名付きURL発行

```bash
# 期限付きURL発行（例: 7日間有効）
supabase storage create-signed-url doc-share large-file.pdf --expires-in 604800
```

#### 3. ChatGPTへの共有

- **方法1**: 署名付きURLをChatGPTに直接貼り付け（対応している場合）
- **方法2**: URLからローカルにダウンロード後、ChatGPTにアップロード
- **期限**: 必要最小限（通常7日、最大30日）
- **再配布**: 禁止（必要に応じて再発行）

#### 4. 大容量共有の再配布ガイド

**期限切れ時の再発行手順**:

1. **旧URLの確認**: 期限切れURLを確認（`403 Forbidden`または`404 Not Found`）
2. **新URL発行**: `supabase storage create-signed-url doc-share file.pdf --expires-in 604800`
3. **旧URL無効化ログ**: `docs/reports/DAY12_SOT_DIFFS.md`に旧URL無効化日時を記録
4. **新URL配布**: 必要最小限の相手にのみ新URLを配布
5. **再配布禁止**: 新URLの再配布は禁止（必要に応じて再発行）

**再発行頻度**: 必要最小限（通常は週1回以内）

#### 5. ログ・監査

- URL発行ログは`docs/reports/DAY12_SOT_DIFFS.md`に記録
- 再発行時は旧URLを無効化し、ログに残す

### その他の方法

- **要約ファイルの作成**: 長文ドキュメントは別途サマリー（例: `docs/summary/` を作成）を用意し、それを共有する。  
- **章ごとの分割**: 章やセクション単位で分割して順番に渡すと、ChatGPT のコンテキスト上限を超えにくい。  
- **PDF/Word の扱い**: `.docx` や `.pdf` は直接読み込めない場合があるため、必要箇所をテキストに変換して渡す。

### 参考ドキュメント

- `docs/COMPANY_SETUP_GUIDE.md` - doc-share運用の詳細手順
- `docs/ops/supabase_byo_auth.md` - Supabase BYO Auth / doc-share 詳細手順

---

## 5. Cursor / GitHub プロンプトテンプレート（正式版）

### Cursor Composer用プロンプト（標準テンプレート）

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
[実装したい機能・修正内容を簡潔に記載]

【前提】
- 環境: [Flutter Web / Supabase / Node.js 20等]
- 依存: [既存ファイル・ライブラリ]
- CI: [GitHub Actions等]

【要件】
- [要件1]
- [要件2]
- [要件3]

【対象ファイル】
- `path/to/file.dart` (新規/更新)
- `path/to/file.ts` (新規/更新)

【実装手順】
1. [手順1]
2. [手順2]
3. [手順3]

【テスト】
- [テスト項目1]
- [テスト項目2]

【ロールバック】
- [ロールバック手順]

【納品物】
- 変更差分
- テストログ
- 関連ドキュメント
```

**禁止事項**:
- 機密情報（Secrets、API Key等）をプロンプトに含めない
- 実行ログにSecretsの値を出力しない
- `.env.local`や`.envrc`の内容をコミットしない

**出力体裁**:
- コードブロックには言語タグを付与（`dart`, `typescript`, `bash`等）
- 変更ファイルは`git diff`形式で出力
- テスト結果は`✅`/`❌`で明示

**コミット粒度**:
- 1機能 = 1コミット（原則）
- 複数ファイルの変更は関連性が高い場合のみ1コミット
- コミットメッセージは`feat(scope): [簡潔な説明]`形式

### GitHub Issue用テンプレート（標準テンプレート）

```markdown
## 目的
[実装したい機能・修正内容]

## 背景
[なぜこの変更が必要か]

## 要件
- [ ] 要件1
- [ ] 要件2
- [ ] 要件3

## 実装方針
[アプローチの概要]

## 関連Issue/PR
- #xxx

## 参考ドキュメント
- `docs/path/to/doc.md`

## 受入基準（DoD）
- [ ] 実装完了
- [ ] テスト通過（単体テスト・E2Eテスト）
- [ ] コードレビュー完了
- [ ] ドキュメント更新完了

## ログ貼り付け形式
\`\`\`
[実行ログ・エラーログ・テスト結果]
\`\`\`
```

**受入基準（DoD）**:
- 実装完了
- テスト通過（単体テスト・E2Eテスト）
- コードレビュー完了
- ドキュメント更新完了
- CI通過（GitHub Actions全緑）

**ログ貼り付け形式**:
- コードブロック（\`\`\`）で囲む
- 実行ログ・エラーログ・テスト結果を貼り付け
- 機密情報はマスク（`***MASKED***`）してから貼り付け

---

## 6. 共有後のチェックリスト

- [ ] ChatGPT に渡したファイルが最新か？（コミット済み最新版かどうか）  
- [ ] 目的・背景・前提条件を明確に伝えたか？  
- [ ] ChatGPT から受領確認（「確認しました」「了解です」等）を得たか？  
- [ ] ChatGPT が生成した要約／アクション項目を確認し、必要に応じて保存したか？  
- [ ] 追加情報の再提示依頼（追加資料・再アップロード等）に対応したか？  
- [ ] 追加で必要な資料があればすぐ取り出せるよう準備したか？  
- [ ] 会話ログや回答をチームと共有し、必要ならドキュメントへ反映したか？
- [ ] **リンク緑化確認**（`npm run lint:md:local`でリンク切れがないか確認）
- [ ] **Last-Updated反映**（`npm run docs:update-dates`で更新日を反映）

---

## 6. 進捗共有の模範例（Day10）

Day10「OPS Slack Notify」の実装完了を共有する際の例：

```
【目的】Day10 OPS Slack Notify の実装完了を共有します。

【背景】
- Day5-9で構築したOPS監視基盤を拡張し、Slackへ日次通知を実装
- 異常（失敗率上昇・遅延悪化）を数分以内に検知→共有→初動できる状態を構築

【実装内容】
- Edge Function: ops-slack-notify（しきい値判定、Slack送信、dryRun対応）
- GitHub Actions: 日次スケジュール（09:00 JST）+ 手動実行
- DB Migration: ops_slack_notify_logs（監査ログ）
- ドキュメント: DAY10_SOT_DIFFS.md, DAY10_DEPLOYMENT_RUNBOOK.md

【次のステップ】
- 本番デプロイ + 運用チューニング（1週間運用後、しきい値調整予定）

【参考ドキュメント】
- docs/reports/DAY10_SOT_DIFFS.md（実装詳細）
- DAY10_DEPLOYMENT_RUNBOOK.md（デプロイ手順）
```

---

## 7. テンプレ更新の監査履歴

| 日付 | バージョン | 変更内容 | 適用日 | 差分 |
| --- | --- | --- | --- | --- |
| 2025-11-08 | v1.0 | Cursor/GitHubテンプレ正式版追加 | 2025-11-08 | 初版作成 |
| 2025-11-08 | v1.1 | doc-share SOP簡潔化、再配布ガイド追加 | 2025-11-08 | 再配布ガイド追加 |

**更新頻度**: テンプレ変更時、SOP変更時

---

このガイドを基に、テーマごとに必要な Markdown を選択し、効率的に ChatGPT へ情報提供してください。

```bash
# 期限付きURL発行（例: 7日間有効）
supabase storage create-signed-url doc-share large-file.pdf --expires-in 604800
```

#### 3. ChatGPTへの共有

- **方法1**: 署名付きURLをChatGPTに直接貼り付け（対応している場合）
- **方法2**: URLからローカルにダウンロード後、ChatGPTにアップロード
- **期限**: 必要最小限（通常7日、最大30日）
- **再配布**: 禁止（必要に応じて再発行）

#### 4. 大容量共有の再配布ガイド

**期限切れ時の再発行手順**:

1. **旧URLの確認**: 期限切れURLを確認（`403 Forbidden`または`404 Not Found`）
2. **新URL発行**: `supabase storage create-signed-url doc-share file.pdf --expires-in 604800`
3. **旧URL無効化ログ**: `docs/reports/DAY12_SOT_DIFFS.md`に旧URL無効化日時を記録
4. **新URL配布**: 必要最小限の相手にのみ新URLを配布
5. **再配布禁止**: 新URLの再配布は禁止（必要に応じて再発行）

**再発行頻度**: 必要最小限（通常は週1回以内）

#### 5. ログ・監査

- URL発行ログは`docs/reports/DAY12_SOT_DIFFS.md`に記録
- 再発行時は旧URLを無効化し、ログに残す

### その他の方法

- **要約ファイルの作成**: 長文ドキュメントは別途サマリー（例: `docs/summary/` を作成）を用意し、それを共有する。  
- **章ごとの分割**: 章やセクション単位で分割して順番に渡すと、ChatGPT のコンテキスト上限を超えにくい。  
- **PDF/Word の扱い**: `.docx` や `.pdf` は直接読み込めない場合があるため、必要箇所をテキストに変換して渡す。

### 参考ドキュメント

- `docs/COMPANY_SETUP_GUIDE.md` - doc-share運用の詳細手順
- `docs/ops/supabase_byo_auth.md` - Supabase BYO Auth / doc-share 詳細手順

---

## 5. Cursor / GitHub プロンプトテンプレート（正式版）

### Cursor Composer用プロンプト（標準テンプレート）

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
[実装したい機能・修正内容を簡潔に記載]

【前提】
- 環境: [Flutter Web / Supabase / Node.js 20等]
- 依存: [既存ファイル・ライブラリ]
- CI: [GitHub Actions等]

【要件】
- [要件1]
- [要件2]
- [要件3]

【対象ファイル】
- `path/to/file.dart` (新規/更新)
- `path/to/file.ts` (新規/更新)

【実装手順】
1. [手順1]
2. [手順2]
3. [手順3]

【テスト】
- [テスト項目1]
- [テスト項目2]

【ロールバック】
- [ロールバック手順]

【納品物】
- 変更差分
- テストログ
- 関連ドキュメント
```

**禁止事項**:
- 機密情報（Secrets、API Key等）をプロンプトに含めない
- 実行ログにSecretsの値を出力しない
- `.env.local`や`.envrc`の内容をコミットしない

**出力体裁**:
- コードブロックには言語タグを付与（`dart`, `typescript`, `bash`等）
- 変更ファイルは`git diff`形式で出力
- テスト結果は`✅`/`❌`で明示

**コミット粒度**:
- 1機能 = 1コミット（原則）
- 複数ファイルの変更は関連性が高い場合のみ1コミット
- コミットメッセージは`feat(scope): [簡潔な説明]`形式

### GitHub Issue用テンプレート（標準テンプレート）

```markdown
## 目的
[実装したい機能・修正内容]

## 背景
[なぜこの変更が必要か]

## 要件
- [ ] 要件1
- [ ] 要件2
- [ ] 要件3

## 実装方針
[アプローチの概要]

## 関連Issue/PR
- #xxx

## 参考ドキュメント
- `docs/path/to/doc.md`

## 受入基準（DoD）
- [ ] 実装完了
- [ ] テスト通過（単体テスト・E2Eテスト）
- [ ] コードレビュー完了
- [ ] ドキュメント更新完了

## ログ貼り付け形式
\`\`\`
[実行ログ・エラーログ・テスト結果]
\`\`\`
```

**受入基準（DoD）**:
- 実装完了
- テスト通過（単体テスト・E2Eテスト）
- コードレビュー完了
- ドキュメント更新完了
- CI通過（GitHub Actions全緑）

**ログ貼り付け形式**:
- コードブロック（\`\`\`）で囲む
- 実行ログ・エラーログ・テスト結果を貼り付け
- 機密情報はマスク（`***MASKED***`）してから貼り付け

---

## 6. 共有後のチェックリスト

- [ ] ChatGPT に渡したファイルが最新か？（コミット済み最新版かどうか）  
- [ ] 目的・背景・前提条件を明確に伝えたか？  
- [ ] ChatGPT から受領確認（「確認しました」「了解です」等）を得たか？  
- [ ] ChatGPT が生成した要約／アクション項目を確認し、必要に応じて保存したか？  
- [ ] 追加情報の再提示依頼（追加資料・再アップロード等）に対応したか？  
- [ ] 追加で必要な資料があればすぐ取り出せるよう準備したか？  
- [ ] 会話ログや回答をチームと共有し、必要ならドキュメントへ反映したか？
- [ ] **リンク緑化確認**（`npm run lint:md:local`でリンク切れがないか確認）
- [ ] **Last-Updated反映**（`npm run docs:update-dates`で更新日を反映）

---

## 6. 進捗共有の模範例（Day10）

Day10「OPS Slack Notify」の実装完了を共有する際の例：

```
【目的】Day10 OPS Slack Notify の実装完了を共有します。

【背景】
- Day5-9で構築したOPS監視基盤を拡張し、Slackへ日次通知を実装
- 異常（失敗率上昇・遅延悪化）を数分以内に検知→共有→初動できる状態を構築

【実装内容】
- Edge Function: ops-slack-notify（しきい値判定、Slack送信、dryRun対応）
- GitHub Actions: 日次スケジュール（09:00 JST）+ 手動実行
- DB Migration: ops_slack_notify_logs（監査ログ）
- ドキュメント: DAY10_SOT_DIFFS.md, DAY10_DEPLOYMENT_RUNBOOK.md

【次のステップ】
- 本番デプロイ + 運用チューニング（1週間運用後、しきい値調整予定）

【参考ドキュメント】
- docs/reports/DAY10_SOT_DIFFS.md（実装詳細）
- DAY10_DEPLOYMENT_RUNBOOK.md（デプロイ手順）
```

---

## 7. テンプレ更新の監査履歴

| 日付 | バージョン | 変更内容 | 適用日 | 差分 |
| --- | --- | --- | --- | --- |
| 2025-11-08 | v1.0 | Cursor/GitHubテンプレ正式版追加 | 2025-11-08 | 初版作成 |
| 2025-11-08 | v1.1 | doc-share SOP簡潔化、再配布ガイド追加 | 2025-11-08 | 再配布ガイド追加 |

**更新頻度**: テンプレ変更時、SOP変更時

---

このガイドを基に、テーマごとに必要な Markdown を選択し、効率的に ChatGPT へ情報提供してください。

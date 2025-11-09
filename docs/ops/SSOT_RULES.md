# SSOT (Single Source of Truth) ルール

**Status**: beta  
**Last-Updated**: 2025-11-08

## 目的

Day12で確立した「単一の真実源（SSOT）」として、ドキュメントの更新・参照・検証のルールを定義します。

---

## 4本柱ドキュメント

### 1. `docs/overview/STARLIST_OVERVIEW.md`
- **役割**: プロジェクト全体像のサマリー
- **内容**: KPI表、ロードマップ表、監視・通知スタック
- **更新頻度**: マイルストーンごと、または重大な変更時

### 2. `docs/COMPANY_SETUP_GUIDE.md`
- **役割**: 新規メンバーオンボーディング
- **内容**: Secrets運用SOP、doc-share運用SOP、必須ツールバージョン
- **更新頻度**: ツールバージョン変更時、SOP変更時

### 3. `docs/overview/COMMON_DOCS_INDEX.md`
- **役割**: ドキュメント索引・参照ハブ
- **内容**: 運用・監視、レポート、QA、機能・設計のリンク集
- **更新頻度**: 新規ドキュメント追加時

### 4. `guides/CHATGPT_SHARE_GUIDE.md`
- **役割**: AI共有時の手順・テンプレート
- **内容**: doc-share署名URL SOP、Cursor/GitHubプロンプトテンプレート
- **更新頻度**: 共有手順変更時、テンプレート更新時

---

## 更新ルール

### 更新責任者/頻度

| ドキュメント | 責任者 | 更新頻度 | 更新トリガー |
| --- | --- | --- | --- |
| `STARLIST_OVERVIEW.md` | PM（COO） | マイルストーンごと | KPI実測値更新、ロードマップ変更 |
| `COMPANY_SETUP_GUIDE.md` | テックリード | ツールバージョン変更時 | Secrets運用変更、権限変更 |
| `COMMON_DOCS_INDEX.md` | テックリード | 新規ドキュメント追加時 | 図ファイル追加、リンク追加 |
| `CHATGPT_SHARE_GUIDE.md` | Ops Lead | 共有手順変更時 | テンプレート更新、SOP変更 |
| `Mermaid.md` | テックリード | ドキュメント構造変更時 | ノード追加、エッジ変更 |

### 必須メタデータ

各ドキュメントの冒頭に以下を記載：

```markdown
Status: beta
Source-of-Truth: [ファイルパス]
Spec-State: beta
Last-Updated: YYYY-MM-DD
```

### 自動更新

- **Last-Updated**: `npm run docs:update-dates`で一括更新
- **差分ログ**: `npm run docs:diff-log`で`docs/reports/DAY12_SOT_DIFFS.md`に記録

### 手動更新

- **KPI表**: `STARLIST_OVERVIEW.md`のKPI表を更新
- **ロードマップ**: `STARLIST_OVERVIEW.md`のロードマップ表を更新
- **Secrets運用**: `COMPANY_SETUP_GUIDE.md`のSecrets運用SOPを更新
- **doc-share運用**: `COMPANY_SETUP_GUIDE.md`と`CHATGPT_SHARE_GUIDE.md`のdoc-share運用SOPを更新

---

## 検証ルール

### リンクチェック

```bash
# ローカル検証
npm run lint:md:local

# CI検証（全PRで自動実行）
npm run lint:md
```

### 相互参照確認

- `STARLIST_OVERVIEW.md` ↔ `COMMON_DOCS_INDEX.md`
- `COMPANY_SETUP_GUIDE.md` ↔ `CHATGPT_SHARE_GUIDE.md`
- `Mermaid.md` ↔ 各ドキュメント

---

## 用語統一

| 用語 | 正規表記 | 備考 |
| --- | --- | --- |
| OPS | OPS（大文字） | Operationsの略 |
| KPI | KPI（大文字） | Key Performance Indicator |
| Edge Function | Edge Function | Supabase Edge Functions |
| dryRun | dryRun | テスト実行モード |
| Secrets | Secrets | 機密情報（大文字S） |
| doc-share | doc-share | Supabase Storageバケット名 |

詳細は`docs/overview/COMMON_DOCS_INDEX.md`の「用語統一（最小語彙表）」を参照。

---

## ロールバック手順

### 直前コミットへ復帰

```bash
git revert HEAD
```

### Mermaid破損時

```bash
git checkout HEAD~1 -- docs/Mermaid.md
```

### 部分的な復旧

```bash
# 特定ファイルのみ復旧
git checkout HEAD~1 -- docs/overview/STARLIST_OVERVIEW.md
```

---

## 参考ドキュメント

- `docs/overview/STARLIST_OVERVIEW.md` - プロジェクト全体像
- `docs/COMPANY_SETUP_GUIDE.md` - 環境セットアップ
- `docs/overview/COMMON_DOCS_INDEX.md` - ドキュメント索引
- `guides/CHATGPT_SHARE_GUIDE.md` - AI共有手順
- `docs/Mermaid.md` - ドキュメント相関図

---

**最終更新**: 2025-11-08


**Status**: beta  
**Last-Updated**: 2025-11-08

## 目的

Day12で確立した「単一の真実源（SSOT）」として、ドキュメントの更新・参照・検証のルールを定義します。

---

## 4本柱ドキュメント

### 1. `docs/overview/STARLIST_OVERVIEW.md`
- **役割**: プロジェクト全体像のサマリー
- **内容**: KPI表、ロードマップ表、監視・通知スタック
- **更新頻度**: マイルストーンごと、または重大な変更時

### 2. `docs/COMPANY_SETUP_GUIDE.md`
- **役割**: 新規メンバーオンボーディング
- **内容**: Secrets運用SOP、doc-share運用SOP、必須ツールバージョン
- **更新頻度**: ツールバージョン変更時、SOP変更時

### 3. `docs/overview/COMMON_DOCS_INDEX.md`
- **役割**: ドキュメント索引・参照ハブ
- **内容**: 運用・監視、レポート、QA、機能・設計のリンク集
- **更新頻度**: 新規ドキュメント追加時

### 4. `guides/CHATGPT_SHARE_GUIDE.md`
- **役割**: AI共有時の手順・テンプレート
- **内容**: doc-share署名URL SOP、Cursor/GitHubプロンプトテンプレート
- **更新頻度**: 共有手順変更時、テンプレート更新時

---

## 更新ルール

### 更新責任者/頻度

| ドキュメント | 責任者 | 更新頻度 | 更新トリガー |
| --- | --- | --- | --- |
| `STARLIST_OVERVIEW.md` | PM（COO） | マイルストーンごと | KPI実測値更新、ロードマップ変更 |
| `COMPANY_SETUP_GUIDE.md` | テックリード | ツールバージョン変更時 | Secrets運用変更、権限変更 |
| `COMMON_DOCS_INDEX.md` | テックリード | 新規ドキュメント追加時 | 図ファイル追加、リンク追加 |
| `CHATGPT_SHARE_GUIDE.md` | Ops Lead | 共有手順変更時 | テンプレート更新、SOP変更 |
| `Mermaid.md` | テックリード | ドキュメント構造変更時 | ノード追加、エッジ変更 |

### 必須メタデータ

各ドキュメントの冒頭に以下を記載：

```markdown
Status: beta
Source-of-Truth: [ファイルパス]
Spec-State: beta
Last-Updated: YYYY-MM-DD
```

### 自動更新

- **Last-Updated**: `npm run docs:update-dates`で一括更新
- **差分ログ**: `npm run docs:diff-log`で`docs/reports/DAY12_SOT_DIFFS.md`に記録

### 手動更新

- **KPI表**: `STARLIST_OVERVIEW.md`のKPI表を更新
- **ロードマップ**: `STARLIST_OVERVIEW.md`のロードマップ表を更新
- **Secrets運用**: `COMPANY_SETUP_GUIDE.md`のSecrets運用SOPを更新
- **doc-share運用**: `COMPANY_SETUP_GUIDE.md`と`CHATGPT_SHARE_GUIDE.md`のdoc-share運用SOPを更新

---

## 検証ルール

### リンクチェック

```bash
# ローカル検証
npm run lint:md:local

# CI検証（全PRで自動実行）
npm run lint:md
```

### 相互参照確認

- `STARLIST_OVERVIEW.md` ↔ `COMMON_DOCS_INDEX.md`
- `COMPANY_SETUP_GUIDE.md` ↔ `CHATGPT_SHARE_GUIDE.md`
- `Mermaid.md` ↔ 各ドキュメント

---

## 用語統一

| 用語 | 正規表記 | 備考 |
| --- | --- | --- |
| OPS | OPS（大文字） | Operationsの略 |
| KPI | KPI（大文字） | Key Performance Indicator |
| Edge Function | Edge Function | Supabase Edge Functions |
| dryRun | dryRun | テスト実行モード |
| Secrets | Secrets | 機密情報（大文字S） |
| doc-share | doc-share | Supabase Storageバケット名 |

詳細は`docs/overview/COMMON_DOCS_INDEX.md`の「用語統一（最小語彙表）」を参照。

---

## ロールバック手順

### 直前コミットへ復帰

```bash
git revert HEAD
```

### Mermaid破損時

```bash
git checkout HEAD~1 -- docs/Mermaid.md
```

### 部分的な復旧

```bash
# 特定ファイルのみ復旧
git checkout HEAD~1 -- docs/overview/STARLIST_OVERVIEW.md
```

---

## 参考ドキュメント

- `docs/overview/STARLIST_OVERVIEW.md` - プロジェクト全体像
- `docs/COMPANY_SETUP_GUIDE.md` - 環境セットアップ
- `docs/overview/COMMON_DOCS_INDEX.md` - ドキュメント索引
- `guides/CHATGPT_SHARE_GUIDE.md` - AI共有手順
- `docs/Mermaid.md` - ドキュメント相関図

---

**最終更新**: 2025-11-08


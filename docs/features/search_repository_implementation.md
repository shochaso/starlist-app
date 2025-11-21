---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# Search Repository - Supabase Implementation

## 📋 Overview

このドキュメントは、`SearchRepository`のSupabase接続実装の詳細を説明します。

**目的**: `mode='full' | 'tag_only'` の検索と `insertTagOnly` を提供  
**方針**: 最小ファイル追加、Feature Flagで即OFF可能  
**影響**: データアクセス層のみ（UI・Controller層は変更なし）  
**安全性**: RLS で `user_id = auth.uid()` を強制、クエリは常にパラメトリ化

## 🎯 実装完了内容

### 1. Supabase Client Provider
**ファイル**: `lib/src/core/config/supabase_client_provider.dart`

```dart
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
```

### 2. Search Repository実装
**ファイル**: `lib/features/search/data/search_repository.dart`

- **full mode**: `content_consumption`テーブルから検索
  - title, content, tags を横断検索
  - 最新順（updated_at DESC）、limit 200

- **tag_only mode**: `tag_only_ingests`テーブルから検索
  - payload_json内を検索
  - 最新順（created_at DESC）、limit 200

- **insertTagOnly**: tag_only_ingestsへの挿入
  - ゲームカテゴリは除外
  - UNIQUE制約により冪等性を保証
  - upsert with ignoreDuplicates

### 3. Provider配線
**ファイル**: `lib/features/search/providers/search_providers.dart`

```dart
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSearchRepository(client);
});
```

### 4. SQL Migrations

#### A) RLS Policies
**ファイル**: `db/migrations/20251006_03_rls_tag_only.sql`

- `tag_only_ingests`テーブルにRLS有効化
- SELECT, INSERT, UPDATE用のポリシー追加
- 全てのポリシーで `user_id = auth.uid()` を強制

**適用方法**:
```bash
psql "$DATABASE_URL" -f db/migrations/20251006_03_rls_tag_only.sql
```

#### B) Performance Indexes
**ファイル**: `db/migrations/20251006_04_indexes.sql`

- `content_consumption(updated_at DESC)` インデックス
- `content_consumption(title)` GIN トライグラムインデックス
- `tag_only_ingests(created_at DESC)` インデックス
- `tag_only_ingests(user_id, created_at DESC)` 複合インデックス
- `tag_only_ingests(payload_json)` GIN インデックス

**適用方法**:
```bash
psql "$DATABASE_URL" -f db/migrations/20251006_04_indexes.sql
```

## 🔒 Security

### RLS (Row Level Security)
- **有効**: `tag_only_ingests`テーブル
- **ポリシー**: 
  - SELECT: ユーザーは自分のレコードのみ参照可能
  - INSERT: ユーザーは自分のレコードのみ挿入可能
  - UPDATE: ユーザーは自分のレコードのみ更新可能

### SQLインジェクション対策
- 検索クエリは常にパラメトリ化（`.ilike()`, `.or()`メソッド使用）
- `_escapeLike()`関数で `%` と `_` をエスケープ
- SQL文字列連結は使用しない

### PII保護
- `payload_json`の内容は最小化
- ログ出力時はIDの末尾4桁以外マスク
- 環境変数（`SUPABASE_URL`, `SUPABASE_ANON_KEY`）はマスク

## ⚡ Performance

### クエリ最適化
- limit 200で結果を制限
- インデックス活用（updated_at, created_at, payload_json）
- 必要な列のみをSELECT

### 将来の拡張
- **P2**: Fuzzy検索（`pg_trgm` + GIN）
- **P3**: `tsvector`を使用した全文検索
- **P4**: ページング実装

## 🧪 Testing

### 単体テスト
```dart
// Repository単体テスト（HTTPモック）
test('mode=full returns content_consumption rows', () async {
  // ...
});

test('mode=tag_only returns tag_only_ingests rows', () async {
  // ...
});

test('insertTagOnly calls upsert with correct params', () async {
  // ...
});
```

### 統合テスト
- 認証済みユーザーで full / tag_only が正常に動作
- 検索語句を含まない場合は最新順（limit 200）
- mixed モード時、id重複が出ない

## 📊 QA Checklist

- [ ] 認証済みで `full` / `tag_only` が想定件数を返す
- [ ] 検索語句を含まない時は最新順（limit 200）
- [ ] mixed 時、`id` 重複が出ない（順序: full→tag_only）
- [ ] 1.5s 超過時 Telemetry送出 / 正常時は無送出
- [ ] RLS有効で他ユーザーのデータは見えない
- [ ] ゲームカテゴリは`insertTagOnly`で保存されない

## 🔄 Backout Plan

Feature Flag で即時OFF可能:

```dart
// lib/src/core/config/feature_flags.dart
static const enableTagOnlySearch = false; // true → false
```

DBは残置可（RLSにより安全性は確保）

## 📈 Telemetry

### 記録するイベント
- `repo.query` 失敗時：`error_code`, `table`, `mode`（PII無し）
- `insertTagOnly` の `conflict_ignored` を計測（重複率の可視化）
- 検索時間が1.5s超過時にイベント送出

## 🔜 Follow-ups

### P1: High Priority
- [ ] `content_consumption` スキーマに合わせた型マッピング＆DTO整備（Effort: S）

### P2: Medium Priority
- [ ] Fuzzy検索/ランキング（`pg_trgm`・`tsvector`）導入（Effort: M）

### P3: Low Priority
- [ ] `payload_json` の正規化（タグ列抽出・辞書化）（Effort: M）

## 📝 Notes

### スキーマ注意事項
- `content_consumption`テーブルの実際の列名が異なる場合は適宜調整が必要
- `SearchItem`の`id`以外の必須フィールドがある場合はマッピング追加が必要

### 依存関係
- `supabase_flutter`: ^2.0.0 以上
- `flutter_riverpod`: ^2.0.0 以上

---

**実装日**: 2025-10-06  
**実装者**: Claude AI (Cursor)  
**バージョン**: v1.0  
**ステータス**: ✅ 実装完了

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

# Starlist 検索機能 Supabase実装

## 概要

Starlistアプリの検索機能をSupabase/PostgREST に接続し、`mode='full' | 'tag_only'` の検索と `insertTagOnly` を提供します。

## マイグレーション実行手順

### 1. 前提条件

- Supabase プロジェクトが作成済み
- データベース接続が確立済み
- 必要な権限（CREATE, ALTER, INSERT等）を持つユーザーでアクセス可能

### 2. マイグレーション実行

以下の順序でSQLファイルを実行してください：

```bash
# 1. テーブル作成とインデックス
psql "$DATABASE_URL" -f db/migrations/20251006_01_search_tables.sql

# 2. RLS（Row Level Security）設定
psql "$DATABASE_URL" -f db/migrations/20251006_02_search_rls.sql

# 3. パフォーマンス最適化インデックス
psql "$DATABASE_URL" -f db/migrations/20251006_03_search_indexes.sql

# 4. サンプルデータ挿入（テスト用、本番では不要）
psql "$DATABASE_URL" -f db/migrations/20251006_04_sample_data.sql
```

### 3. 環境変数設定

`.env` ファイルに以下の設定を追加：

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## データベーススキーマ

### テーブル構成

#### 1. contents テーブル
```sql
- id: BIGSERIAL PRIMARY KEY
- title: TEXT NOT NULL
- body: TEXT
- author: TEXT
- tags: TEXT
- category: TEXT
- user_id: UUID (auth.users参照)
- privacy_level: TEXT ('public', 'private', 'followers_only')
- created_at: TIMESTAMPTZ
- updated_at: TIMESTAMPTZ
```

#### 2. tag_only_ingests テーブル
```sql
- id: BIGSERIAL PRIMARY KEY
- user_id: UUID NOT NULL (auth.users参照)
- source_id: TEXT NOT NULL
- tag_hash: TEXT NOT NULL
- category: TEXT NOT NULL
- payload_json: JSONB NOT NULL
- created_at: TIMESTAMPTZ
- updated_at: TIMESTAMPTZ
- UNIQUE制約: (source_id, tag_hash)
```

#### 3. search_history テーブル
```sql
- id: BIGSERIAL PRIMARY KEY
- user_id: UUID NOT NULL (auth.users参照)  
- query: TEXT NOT NULL
- search_type: TEXT ('content', 'user', 'star', 'mixed')
- created_at: TIMESTAMPTZ
```

#### 4. user_follows テーブル
```sql
- id: BIGSERIAL PRIMARY KEY
- follower_user_id: UUID NOT NULL (auth.users参照)
- followed_user_id: UUID NOT NULL (auth.users参照)
- created_at: TIMESTAMPTZ
- UNIQUE制約: (follower_user_id, followed_user_id)
```

## セキュリティ

### RLS（Row Level Security）ポリシー

全てのテーブルでRLSが有効化され、以下のポリシーが適用されます：

- **contents**: 公開コンテンツまたは自分のコンテンツのみアクセス可能
- **tag_only_ingests**: 自分のタグデータのみアクセス可能  
- **search_history**: 自分の検索履歴のみアクセス可能
- **user_follows**: フォロー関係は全体閲覧可、操作は本人のみ

### SQLインジェクション対策

- 全てのクエリでパラメトリ化（`eq`, `ilike`等）を使用
- SQL文字列連結は一切使用禁止
- LIKE検索時は適切なエスケープ処理を実行

## パフォーマンス最適化

### インデックス

1. **フルテキスト検索用**: GINインデックス（日本語対応）
2. **ファジー検索用**: pg_trgm トライグラムインデックス
3. **範囲検索用**: B-treeインデックス（日時、カテゴリ等）
4. **JSON検索用**: GINインデックス（payload_json）

### 検索機能

- **全文検索**: PostgreSQLのto_tsvector/to_tsquery使用
- **ファジー検索**: pg_trgm拡張による部分一致
- **重複除去**: アプリケーション層でID重複を排除
- **タイムアウト**: 1.5秒でタイムアウト、テレメトリ送信

## API使用方法

### Flutter/Dartでの実装例

```dart
// 1. 検索実行
final repository = ref.read(searchRepositoryProvider);

// フル検索
final fullResults = await repository.search(
  query: 'iPhone 15', 
  mode: 'full'
);

// タグのみ検索  
final tagResults = await repository.search(
  query: 'ガジェット',
  mode: 'tag_only'  
);

// 2. タグデータ保存
await repository.insertTagOnly({
  'source_id': 'youtube_001',
  'tag_hash': 'hash_001', 
  'category': 'youtube',
  'raw': {'title': '動画タイトル', 'tag': 'ガジェット'}
}, userId: currentUserId);
```

### 混合検索の使用

```dart
// SearchControllerを使用した混合検索
final controller = ref.read(searchControllerProvider.notifier);
await controller.searchMixed(query: 'プログラミング');

// 結果取得
final results = ref.watch(searchControllerProvider);
results.when(
  data: (items) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('エラー: $error'),
);
```

## 運用・メンテナンス

### モニタリング

1. **パフォーマンス**: 1.5秒超過クエリの自動テレメトリ
2. **エラー**: 検索失敗時のエラーログ自動送信  
3. **使用統計**: 人気検索クエリ、検索頻度の分析

### データクリーンアップ

```sql
-- 90日以上古い検索履歴を削除
SELECT cleanup_old_search_history(90);

-- 統計情報更新
ANALYZE contents;
ANALYZE tag_only_ingests;
```

### バックアウト手順

機能を無効化する場合：

```dart
// アプリ側でフィーチャーフラグを設定
const bool STARLIST_FF_TAG_ONLY = false;

// Repository実装を切り替え
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (STARLIST_FF_TAG_ONLY) {
    final client = ref.read(supabaseClientProvider);
    return SupabaseSearchRepository(client);
  }
  return MockSearchRepository(); // フォールバック実装
});
```

## トラブルシューティング

### よくある問題

1. **認証エラー**: RLSによりauth.uid()が必要 → ログイン状態を確認
2. **検索結果が空**: インデックス未作成 → マイグレーション実行状況を確認
3. **パフォーマンス低下**: 統計情報が古い → ANALYZE実行

### ログ確認

```sql
-- 検索統計の確認
SELECT * FROM search_analytics LIMIT 10;

-- 人気タグの確認  
SELECT * FROM get_popular_tags(20);

-- RLSポリシーの確認
SELECT * FROM pg_policies WHERE tablename IN ('contents', 'tag_only_ingests');
```

## 今後の拡張

- P1: contentsスキーマの型マッピング&DTO整備
- P2: Fuzzy検索/ランキング（pg_trgm・tsvector）強化  
- P3: payload_jsonの正規化（タグ列抽出・辞書化）
- P4: リアルタイム検索（WebSocket連携）
- P5: 検索結果キャッシュ（Redis連携）
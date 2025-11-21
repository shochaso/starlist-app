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


# 🚀 Starlist デプロイメントチェックリスト

## 📅 実施日: 2025-10-06

---

## ✅ 1. Flutter/Dart セットアップ & テスト

### ローカル実行
```bash
flutter pub get
flutter analyze
flutter test --coverage
```

**ステータス**: 
- ✅ `flutter pub get` - 完了
- ⚠️ `flutter analyze` - 4,585件の問題（大半は非推奨警告）
- ❌ `flutter test` - パッケージ名の問題で失敗

**次のアクション**:
- [ ] テストファイルのパッケージ名を修正
- [ ] 非推奨APIを更新（優先度: Medium）

---

## ✅ 2. DB マイグレーション

### 実行コマンド
```bash
# RLS有効化
psql "$DATABASE_URL" -f db/migrations/20251006_03_rls_tag_only.sql

# インデックス作成
psql "$DATABASE_URL" -f db/migrations/20251006_04_indexes.sql

# UNIQUE制約（既存）
psql "$DATABASE_URL" -f db/migrations/20251006_add_unique_ingest_guard.sql
```

### ヘルスチェック
```bash
psql "$DATABASE_URL" -c "\d+ tag_only_ingests"
psql "$DATABASE_URL" -c "SELECT indexdef FROM pg_indexes WHERE tablename='tag_only_ingests';"
```

**ステータス**: ⏳ 未実施

**成功条件**:
- [ ] テーブル存在確認
- [ ] `UNIQUE (source_id, tag_hash)` 表示
- [ ] RLS有効化確認
- [ ] インデックス作成確認

---

## ✅ 3. CI/CD ワークフロー追加

### GitHub UI で実施（推奨）

1. GitHub → **Add file → Create new file**
2. パス: `.github/workflows/flutter-ci.yml`
3. 以下の内容を貼り付け:

```yaml
name: Flutter CI

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main, develop ]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Format check
        run: flutter format --set-exit-if-changed .
        
      - name: Analyze
        run: flutter analyze
        
      - name: Test
        run: flutter test --coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

4. **Create a new branch**: `chore/ci-flutter`
5. **Propose changes → Open PR**

**ステータス**: ⏳ 未実施

**成功条件**:
- [ ] PRで format / analyze / test が自動実行
- [ ] 全てのチェックが緑

---

## ✅ 4. Telemetry 本番オーバーライド

### 実装場所
`lib/main.dart` または本番ブートファイル

```dart
import 'package:starlist_app/features/search/providers/search_providers.dart';
import 'package:starlist_app/core/telemetry/search_telemetry.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        // 本番環境では実際のテレメトリシンクを使用
        searchTelemetryProvider.overrideWithValue(
          ProdSearchTelemetry(), // 実装が必要
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 実装が必要なクラス

```dart
class ProdSearchTelemetry implements SearchTelemetry {
  @override
  void recordSearchLatency(Duration elapsed, String mode) {
    // 実際のアナリティクスに送信
    // 例: Firebase Analytics, Sentry, etc.
  }
  
  @override
  void recordSlaMissed(Duration elapsed, String mode) {
    // 100%サンプリング - 全件送信
  }
  
  @override
  void recordTagOnlyDedupHit() {
    // 10%サンプリング
    if (Random().nextDouble() < 0.1) {
      // 送信
    }
  }
}
```

**ステータス**: ⏳ 未実施

**成功条件**:
- [ ] `ProdSearchTelemetry` クラス実装
- [ ] 本番環境でオーバーライド設定
- [ ] テレメトリデータの送信確認

---

## ✅ 5. Feature Flag 有効化とロールバック

### 有効化（本番切替時）

#### 開発・テスト環境
```bash
flutter run --dart-define=STARLIST_FF_TAG_ONLY=true
```

#### ビルド時
```bash
# Android
flutter build apk --dart-define=STARLIST_FF_TAG_ONLY=true

# iOS
flutter build ios --dart-define=STARLIST_FF_TAG_ONLY=true

# Web
flutter build web --dart-define=STARLIST_FF_TAG_ONLY=true
```

### 即時停止（ロールバック）
```bash
flutter run --dart-define=STARLIST_FF_TAG_ONLY=false
# または環境変数を削除してリビルド
```

### コード確認
`lib/src/core/config/feature_flags.dart`

```dart
class FeatureFlags {
  static const enableTagOnlySearch = bool.fromEnvironment(
    'STARLIST_FF_TAG_ONLY',
    defaultValue: false, // デフォルトはOFF
  );
}
```

**現在のステータス**: ✅ 実装済み（デフォルトOFF）

**成功条件**:
- [ ] Flag有効化でmixedモードが動作
- [ ] Flag無効化でfullモードのみ動作
- [ ] 即座にロールバック可能

---

## ✅ 6. 手動スモークテスト（出荷直前）

### テスト項目

#### 6.1 基本ナビゲーション
- [ ] Drawer → **スターリスト** で `/star-data` へ遷移
- [ ] AppBar のタイトルが「スターリスト」と表示
- [ ] 画面が白くならず正常に表示

#### 6.2 検索モード
- [ ] トグルOFF: `full` モードのみ動作
- [ ] トグルON + Flag有効: `mixed` モード動作
- [ ] ID重複がない（`full` 優先）
- [ ] 検索結果が1.5秒以内に表示

#### 6.3 データ保存
- [ ] `category=='game'` のtag-onlyデータが保存されない
- [ ] 他のカテゴリは正常に保存される
- [ ] UNIQUE制約により重複が防止される

#### 6.4 パフォーマンス
- [ ] 検索レスポンス ≤ 1.5秒
- [ ] 1.5秒超過時に `searchSlaMissed` イベント送出
- [ ] メモリリークがない

#### 6.5 エラーハンドリング
- [ ] ネットワークエラー時の適切なメッセージ表示
- [ ] 認証エラー時の適切な処理
- [ ] 空の検索結果時の表示

**ステータス**: ⏳ 未実施

---

## ✅ 7. セキュリティ & 依存関係チェック

### 7.1 RLS (Row Level Security)

#### 確認コマンド
```sql
-- RLS有効化確認
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'tag_only_ingests';

-- ポリシー確認
SELECT * FROM pg_policies 
WHERE tablename = 'tag_only_ingests';
```

**確認項目**:
- [ ] RLS有効化: `rowsecurity = true`
- [ ] SELECT Policy: `user_id = auth.uid()`
- [ ] INSERT Policy: `user_id = auth.uid()`
- [ ] UPDATE Policy: `user_id = auth.uid()`

### 7.2 秘匿情報管理

**チェック項目**:
- [ ] `SUPABASE_URL` は環境変数のみ
- [ ] `SUPABASE_ANON_KEY` は環境変数のみ
- [ ] トークン・キーはログ出力しない
- [ ] `.env` ファイルは `.gitignore` に追加
- [ ] PII (個人情報) はログに出力しない

### 7.3 SQLインジェクション対策

**確認項目**:
- [x] クエリはパラメトリ化（`.eq()`, `.ilike()`, `.or()`）
- [x] SQL文字列連結を使用しない
- [x] `_escapeLike()` でLIKE検索をエスケープ
- [x] ユーザー入力を直接SQLに埋め込まない

### 7.4 依存関係

```bash
flutter pub outdated
flutter pub upgrade --dry-run
```

**確認項目**:
- [ ] セキュリティアップデートの確認
- [ ] 非推奨パッケージの更新
- [ ] 互換性のない依存関係の解決

---

## 📊 実装完了サマリー

### ✅ 完了済み

1. **Search Repository - Supabase実装**
   - ✅ Supabase Client Provider
   - ✅ full/tag_only検索機能
   - ✅ insertTagOnly機能
   - ✅ SQLマイグレーション（RLS + Index）
   - ✅ 静的解析クリア（新規コードのみ）

2. **C/c入力でChrome実行**
   - ✅ `./cli c` コマンド実装済み

3. **Slack関連コード削除**
   - ✅ コード削除
   - ✅ ドキュメント削除
   - ✅ ワークフロー削除（存在せず）

### ⏳ 未実施（要対応）

1. **テストの修正**
   - パッケージ名の問題解決
   - テストカバレッジの向上

2. **DBマイグレーション実行**
   - RLS有効化
   - インデックス作成
   - UNIQUE制約追加

3. **CI/CD設定**
   - GitHub Actions ワークフロー追加

4. **本番環境設定**
   - Telemetry実装
   - Feature Flag設定
   - スモークテスト実施

---

## 📝 次のアクション

### 優先度: High
1. [ ] DBマイグレーション実行
2. [ ] CI/CDワークフロー追加
3. [ ] スモークテスト実施

### 優先度: Medium
4. [ ] テストファイル修正
5. [ ] Telemetry本番実装

### 優先度: Low
6. [ ] 非推奨API更新
7. [ ] 依存関係アップデート

---

**更新日**: 2025-10-06  
**ステータス**: 開発完了 / デプロイ準備中

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

# Starlist Development Guide

## 🚀 クイックスタート

### 開発環境起動
```bash
# tmux開発環境（推奨）
./scripts/dev.sh

# または通常のFlutter run
flutter run -d chrome --web-port 8080
```

## 🎨 スタイルガイド

### アクセス方法
アプリ起動後、以下のURLにアクセス:
```
http://localhost:8080/#/style-guide
```

### テーマシステム
- **カラースキーム**: `Theme.of(context).colorScheme`
- **トークン**: `context.tokens` (拡張メソッド)
- **タイポグラフィ**: `Theme.of(context).textTheme`

## 📁 プロジェクト構造

```
lib/
├── screens/              # メイン画面
│   ├── starlist_main_screen.dart
│   └── style_guide_page.dart  # スタイルガイド
├── theme/                # テーマ定義
│   ├── app_theme.dart
│   ├── color_schemes.dart
│   ├── tokens.dart
│   └── typography.dart
├── ui/                   # 共通UIコンポーネント
│   ├── app_button.dart
│   ├── app_card.dart
│   └── app_text_field.dart
├── features/             # 機能別モジュール
└── src/
    ├── core/
    │   └── routing/
    │       └── app_router.dart  # ルーティング設定
    └── features/
```

## 🛠️ 開発ワークフロー

### 1. コード編集
エディタでコードを変更

### 2. ホットリロード
```bash
./scripts/dev.sh  # 自動でホットリロード + Chrome更新
```

### 3. コード品質チェック
```bash
flutter analyze
```

### 4. テスト実行
```bash
flutter test
```

## 🎯 テーマリファクタ指針

### ❌ 避けるべきパターン
```dart
// ハードコードされた色
Container(
  color: Color(0xFFD10FEE),  // NG
)
```

### ✅ 推奨パターン
```dart
// colorSchemeを使用
Container(
  color: Theme.of(context).colorScheme.primary,  // OK
)

// または tokens 拡張を使用
Container(
  color: context.tokens.colors.primary,  // OK
)
```

## 📝 コミットガイドライン

### コミットメッセージフォーマット
```
<type>: <subject>

例:
feat: Add StyleGuidePage route
fix: RenderFlex overflow in starlist_main_screen
refactor: Use colorScheme in login screen
```

### Type一覧
- `feat`: 新機能
- `fix`: バグ修正
- `refactor`: リファクタリング
- `style`: コードスタイル修正
- `docs`: ドキュメント更新
- `test`: テスト追加・修正
- `chore`: その他の変更

## 🔧 便利なスクリプト

### プロンプト履歴ロガー
```bash
dart scripts/prompt_logger.dart "作業内容"
```

### Chrome実行（C/c コマンド）
```bash
./scripts/c.sh
```

### tmux開発環境
```bash
# 起動
./scripts/dev.sh

# セッション確認
tmux ls

# アタッチ
tmux attach -t flutter_dev

# デタッチ（Ctrl+b → d）

# 終了
tmux kill-session -t flutter_dev
```

## 🐛 トラブルシューティング

### ポートが既に使用されている
```bash
# Flutter webプロセスを終了
pkill -f "flutter_tools\.snapshot run -d chrome"
```

### ビルドエラー
```bash
# クリーンビルド
flutter clean
flutter pub get
flutter run -d chrome
```

### tmuxセッションが起動しない
```bash
# 既存セッションを削除
tmux kill-session -t flutter_dev

# 再起動
./scripts/dev.sh
```

## 📊 パフォーマンス計測

### Web Vitals
- LCP (Largest Contentful Paint): < 2.5s
- FID (First Input Delay): < 100ms
- CLS (Cumulative Layout Shift): < 0.1

### Chrome DevTools
```
http://localhost:9101
```

## 🔗 重要なリンク

- **Supabase Dashboard**: プロジェクトダッシュボード
- **Flutter DevTools**: `http://localhost:9101`
- **Style Guide**: `http://localhost:8080/#/style-guide`

## 📱 マルチプラットフォーム対応

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

### macOS Desktop
```bash
flutter run -d macos
```

## 🧪 テスト戦略

### ユニットテスト
```bash
flutter test test/unit/
```

### ウィジェットテスト
```bash
flutter test test/widget/
```

### 統合テスト
```bash
flutter test integration_test/
```

## 🔐 環境変数

環境変数は `.env.local` ファイルで管理:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## 📚 参考資料

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Riverpodドキュメント](https://riverpod.dev)
- [GoRouterドキュメント](https://pub.dev/packages/go_router)
- [Supabaseドキュメント](https://supabase.com/docs)

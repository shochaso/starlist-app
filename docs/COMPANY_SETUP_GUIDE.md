# STARLIST チーム環境セットアップガイド

## 🎯 目的
STARLISTプロジェクトの開発・運用環境を統一し、効率的なチーム開発を実現する

## 👥 チーム構成
- **PM/COO**: ティム - 仕様品質管理・プロジェクト進行
- **開発者**: Mine - 実装・コード品質・AIレビュー対応

## 🛠️ 技術スタック

### フロントエンド
- **Flutter**: 3.0+
- **Dart**: 3.0+
- **State管理**: Riverpod
- **開発ツール**: VS Code + Flutter拡張

### バックエンド
- **Supabase**: PostgreSQL + Edge Functions
- **認証**: Supabase Auth
- **ストレージ**: Supabase Storage
- **リアルタイム**: Supabase Realtime

### 決済統合
- **Stripe**: サブスクリプション決済
- **キャリア決済**: Docomo/au/SoftBank対応

### データ取り込み
- **OCR**: Google Cloud Vision API
- **YouTube**: Data API v3
- **PII保護**: 自動マスキング

## 🚀 開発環境セットアップ

### 1. Flutter開発環境
```bash
# Flutter SDKインストール
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 依存関係インストール
flutter pub get

# iOSシミュレータ設定（macOS）
flutter config --enable-ios
flutter precache --ios

# Androidエミュレータ設定
flutter config --enable-android
flutter doctor --android-licenses
```

### 2. Supabase CLI
```bash
# Supabase CLIインストール
npm install supabase --save-dev

# ログイン
npx supabase login

# プロジェクト初期化
npx supabase init
```

### 3. 環境変数設定
```bash
# .envファイル作成
cp .env.example .env

# 環境変数編集
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
GOOGLE_CLOUD_VISION_API_KEY=your_google_key
```

## 📁 プロジェクト構造

```
starlist/
├── lib/                    # Flutterソースコード
│   ├── src/
│   │   ├── features/       # 機能別モジュール
│   │   │   ├── auth/       # 認証
│   │   │   ├── payment/    # 決済
│   │   │   ├── ingest/     # データ取り込み
│   │   │   └── ...
│   │   ├── shared/         # 共有コンポーネント
│   │   └── core/          # コア機能
├── supabase/              # Supabase設定
│   ├── migrations/        # DBマイグレーション
│   ├── functions/         # Edge Functions
│   └── config.toml       # 設定ファイル
├── docs/                  # ドキュメント
└── scripts/               # 開発支援スクリプト
```

## 🔐 Supabase Storage `doc-share` 運用

### バケット構成
| バケット名 | 用途 | アクセス権限 | 署名URL有効期限 |
|-----------|------|-------------|----------------|
| avatars | プロフィール画像 | 公開（低解像度） | 300秒 |
| content | 購読コンテンツ | 購読者のみ | 60秒 |
| receipts | レシート類 | 運営のみ | 60秒 |
| temp | アップロード中 | アップローダー | 3600秒 |

### OCR/スクショ分類運用
- **receipts/**: レシート・明細書・支払い証明書
- **content/**: YouTubeスクショ・音楽アプリ・ゲーム履歴・学習資料
- **temp/**: OCR処理中の画像（自動削除）

### PIIマスキングルール
```regex
# メールアドレス
/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i → <PII:EMAIL>

# 電話番号（日本）
/0\d{1,4}-\d{1,4}-\d{4}/ → <PII:TEL>

# 住所
/〒?\d{3}-\d{4}/ → <PII:ADDR>
```

### 監査ログ保存ポリシー
- **保存期間**: 90日（運用ログ）/1年（PII検出ログ）
- **ログ内容**: アップロード・処理・アクセス・PII検出の全操作
- **アクセス制御**: 監査ログは運営のみ閲覧可能

### 運用チェックリスト
- [ ] ストレージ使用量80%警告設定
- [ ] PII検出率95%以上維持
- [ ] 署名URL60秒有効期限厳守
- [ ] 監査ログ定期アーカイブ

## 🔒 セキュリティガイドライン

### APIキー管理
- 環境変数でのみ管理（ハードコーディング禁止）
- `.env`ファイルを`.gitignore`に追加
- 定期的なキーローテーション

### データ保護
- PII情報の自動マスキング
- 署名URLによる一時アクセス
- RLSによるデータアクセス制御

### 監査体制
- 全API呼び出しのログ記録
- 定期的なセキュリティ監査
- 異常検知時の即時対応

## 🚀 デプロイ・CI/CD

### GitHub Actions設定
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test
```

### Supabaseデプロイ
```bash
# マイグレーション適用
npx supabase db push

# Edge Functionsデプロイ
npx supabase functions deploy
```

## 📊 品質管理

### コード品質基準
- **テストカバレッジ**: 80%以上
- **静的解析**: Flutter analyzeクリーン
- **パフォーマンス**: 初期表示1.5秒以内（P95）

### レビュー体制
- **AI自動レビュー**: stripe_rls/ingestプリセット
- **人的レビュー**: ティムによる仕様準拠確認
- **品質ゲート**: source_of_truth昇格必須

## 🆘 トラブルシューティング

### よくある問題
- **Supabase接続エラー**: URL/キーの確認
- **Flutterビルド失敗**: pubspec.yaml依存関係確認
- **OCR精度低下**: APIキークォータ確認

### サポート体制
- **技術的質問**: Discord/Teamsチャンネル
- **仕様確認**: COMMON_DOCS_INDEX.md参照
- **緊急時**: ティム直接連絡

## 📈 継続改善

### パフォーマンス監視
- アプリ起動時間
- APIレスポンス時間
- ストレージ使用量
- OCR処理時間

### フィードバック収集
- 開発者体験アンケート
- コードレビューの改善点
- ドキュメントの改善要望

---

*このガイドは継続的に更新してください*

# データ統合API実装ドキュメント

## 概要

このドキュメントでは、Starlistアプリケーションのデータ統合API実装について説明します。データ統合APIは、YouTube、Spotify、Amazonなどの外部サービスからユーザーのコンテンツ消費データを取得し、統合するための機能を提供します。

## アーキテクチャ

データ統合APIは以下のコンポーネントで構成されています：

1. **ApiClient**: HTTP通信の基本機能を提供するクラス
2. **DataIntegrationService**: 各データソースの共通インターフェース
3. **YouTubeApiService**: YouTube Data APIと連携するサービス実装
4. **DataIntegrationManager**: 複数のデータソースを管理し、データを統合するマネージャー
5. **DataIntegrationServiceFactory**: サービスインスタンスを作成・管理するファクトリ

### クラス図

```
┌─────────────┐     ┌───────────────────────┐
│  ApiClient  │     │ DataIntegrationService │
└─────────────┘     └───────────────────────┘
       ▲                        ▲
       │                        │
       │                        │
       │                ┌───────────────────┐
       └────────────── │ YouTubeApiService │
                       └───────────────────┘
                                 ▲
                                 │
┌─────────────────────────┐     │
│ DataIntegrationManager  │─────┘
└─────────────────────────┘
            │
            │
            ▼
┌──────────────────────────────┐
│ DataIntegrationServiceFactory│
└──────────────────────────────┘
```

## 主要コンポーネント

### ApiClient

`ApiClient`は、HTTP通信の基本機能を提供するクラスです。GET、POST、PUT、DELETEなどの基本的なHTTPメソッドをサポートし、レスポンス処理やエラーハンドリングの機能も含んでいます。

```dart
// 使用例
final apiClient = ApiClient(baseUrl: 'https://api.example.com');
final response = await apiClient.get('/users', queryParams: {'id': '123'});
```

### DataIntegrationService

`DataIntegrationService`は、各データソースの共通インターフェースを定義する抽象クラスです。このインターフェースを実装することで、異なるデータソースに対して一貫した操作方法を提供します。

主要なメソッド：
- `isAuthenticated()`: 認証状態を確認
- `authenticate()`: サービスに認証
- `getUserProfile()`: ユーザーのプロフィール情報を取得
- `getContentConsumptionData()`: ユーザーのコンテンツ消費データを取得
- `searchContent()`: コンテンツを検索
- `disconnect()`: サービスから切断

### YouTubeApiService

`YouTubeApiService`は、`DataIntegrationService`インターフェースを実装し、YouTube Data APIと連携するサービスクラスです。ユーザーの視聴履歴やフォローチャンネルなどの情報を取得する機能を提供します。

```dart
// 使用例
final youtubeService = YouTubeApiService();
await youtubeService.authenticate();
final profile = await youtubeService.getUserProfile();
final watchHistory = await youtubeService.getContentConsumptionData(limit: 10);
```

追加機能：
- `getSubscriptions()`: フォローしているチャンネルのリストを取得
- `getChannelVideos()`: チャンネルの最新動画を取得

### DataIntegrationManager

`DataIntegrationManager`は、複数のデータソースからのデータを統合して管理するクラスです。各サービスのインスタンスを管理し、複数サービスからのデータ統合や横断検索などの高度な機能を提供します。

```dart
// 使用例
final manager = DataIntegrationManager();
manager.registerService(youtubeService);
manager.registerService(spotifyService);

// 単一サービスからデータを取得
final youtubeData = await manager.getContentConsumptionData('YouTube', limit: 10);

// 複数サービスからデータを統合
final integratedData = await manager.getIntegratedContentData(
  serviceNames: ['YouTube', 'Spotify'],
  limit: 10,
);

// 複数サービスで検索
final searchResults = await manager.searchAcrossServices(
  'music',
  serviceNames: ['YouTube', 'Spotify'],
);
```

### DataIntegrationServiceFactory

`DataIntegrationServiceFactory`は、サービスインスタンスを作成・管理するファクトリクラスです。サービス名に基づいて適切なサービスインスタンスを作成し、キャッシュします。

```dart
// 使用例
final factory = DataIntegrationServiceFactory();
factory.registerService('YouTube', youtubeService);
final service = factory.getService('YouTube');
```

## 認証フロー

データ統合APIでは、各サービスに対して以下の認証フローを使用します：

1. ユーザーがサービス連携を開始
2. OAuth2認証フローを使用してアクセストークンを取得
3. アクセストークンを使用してAPIリクエストを実行
4. トークンの有効期限が切れた場合はリフレッシュトークンを使用して更新

実際の実装では、Flutter用のOAuth2ライブラリ（flutter_appauth など）を使用して認証フローを実装することを推奨します。

## エラーハンドリング

データ統合APIでは、以下のエラーハンドリング戦略を採用しています：

1. **ApiException**: API通信に関するエラーを表すクラス
2. **サービス固有のエラー**: 各サービスの実装内でハンドリング
3. **統合レベルのエラー**: DataIntegrationManagerでのエラーハンドリング

エラーが発生した場合でも、アプリケーション全体がクラッシュしないように、適切なエラーメッセージをユーザーに表示することを推奨します。

## テスト

データ統合APIのテストは、`test/data_integration_test.dart`に実装されています。テストでは、モックを使用して外部依存関係を分離し、各コンポーネントの機能を個別にテストしています。

テストを実行するには、以下のコマンドを使用します：

```bash
flutter test test/data_integration_test.dart
```

## 今後の拡張

データ統合APIは、以下の方向に拡張することができます：

1. **追加のサービス実装**: Spotify、Amazon、Netflixなどの他のサービスの実装
2. **データ分析機能**: 収集したデータの分析と可視化
3. **オフラインサポート**: データのローカルキャッシュと同期
4. **プライバシー設定**: ユーザーがデータ共有の粒度を制御する機能

## 注意事項

1. **API制限**: 各サービスのAPI制限に注意し、適切なレート制限を実装してください
2. **認証情報の保護**: アクセストークンなどの認証情報は安全に保存してください
3. **ユーザーの同意**: データ収集前にユーザーの明示的な同意を得てください
4. **エラー処理**: ネットワークエラーや認証エラーに対して適切に対応してください

## まとめ

データ統合APIは、Starlistアプリケーションの中核機能の一つであり、ユーザーのコンテンツ消費データを様々なサービスから収集し、統合する機能を提供します。共通インターフェースとファクトリパターンを使用することで、新しいサービスの追加が容易になり、アプリケーションの拡張性が向上します。

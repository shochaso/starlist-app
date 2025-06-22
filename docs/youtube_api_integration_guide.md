# YouTube API 連携手順書

## 概要
StarlistプラットフォームにおけるYouTube Data API v3の統合手順とベストプラクティスをまとめたガイドです。

## 目次
1. [事前準備](#事前準備)
2. [Google Cloud Console設定](#google-cloud-console設定)
3. [YouTube Data API有効化](#youtube-data-api有効化)
4. [認証設定](#認証設定)
5. [Flutter実装](#flutter実装)
6. [API使用量管理](#api使用量管理)
7. [エラーハンドリング](#エラーハンドリング)
8. [セキュリティ考慮事項](#セキュリティ考慮事項)

## 事前準備

### 必要なアカウント
- **Googleアカウント**: Google Cloud Consoleアクセス用
- **YouTubeチャンネル**: テスト用（推奨）
- **Starlistプロジェクト**: Flutter環境構築済み

### 料金について
- **無料枠**: 1日あたり10,000ユニット
- **課金制**: 100ユニットあたり$0.002 (約0.3円)
- **主要API消費ユニット**:
  - チャンネル情報取得: 1ユニット
  - 動画リスト取得: 1ユニット
  - 動画詳細取得: 1ユニット
  - 検索API: 100ユニット（注意！）

## Google Cloud Console設定

### 1. プロジェクト作成
```bash
# Google Cloud Consoleにアクセス
https://console.cloud.google.com/
```

1. **新しいプロジェクトを作成**
   - プロジェクト名: `starlist-youtube-integration`
   - 組織: 適切な組織を選択
   - 場所: 適切な場所を選択

2. **プロジェクトを選択**して続行

### 2. 請求アカウント設定
```bash
# 請求設定（APIクォータ拡張のため）
https://console.cloud.google.com/billing
```

⚠️ **重要**: 無料枠を超える使用を避けるため、予算アラートを設定

## YouTube Data API有効化

### 1. APIライブラリでの有効化
```bash
# APIライブラリへアクセス
https://console.cloud.google.com/apis/library
```

1. **「YouTube Data API v3」を検索**
2. **「有効にする」をクリック**
3. **API有効化完了を確認**

### 2. APIキー作成
```bash
# 認証情報ページ
https://console.cloud.google.com/apis/credentials
```

#### サーバーサイド用APIキー
```yaml
名前: starlist-youtube-server-key
アプリケーションの制限: なし
API制限: YouTube Data API v3のみ
```

#### クライアントサイド用APIキー
```yaml
名前: starlist-youtube-client-key  
アプリケーションの制限: HTTPリファラー
許可するリファラー:
  - https://yourapp.com/*
  - http://localhost:*
API制限: YouTube Data API v3のみ
```

## 認証設定

### OAuth 2.0設定（ユーザー認証用）

#### 1. OAuth同意画面設定
```yaml
アプリケーション名: Starlist
ユーザーサポートメール: support@starlist.com
アプリケーションのホームページ: https://starlist.com
アプリケーションのプライバシーポリシー: https://starlist.com/privacy
アプリケーションの利用規約: https://starlist.com/terms
```

#### 2. スコープ設定
```yaml
必要なスコープ:
  - https://www.googleapis.com/auth/youtube.readonly
  - https://www.googleapis.com/auth/userinfo.profile
```

#### 3. OAuth クライアント作成
```yaml
アプリケーションタイプ: ウェブアプリケーション
名前: starlist-youtube-oauth
承認済みのJavaScript生成元:
  - https://starlist.com
  - http://localhost:3000
承認済みのリダイレクトURI:
  - https://starlist.com/auth/youtube/callback
  - http://localhost:3000/auth/youtube/callback
```

## Flutter実装

### 1. 依存関係追加

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  oauth2: ^2.0.2
  youtube_api: ^1.1.0
  googleapis: ^11.4.0
  googleapis_auth: ^1.4.1
  url_launcher: ^6.2.1
```

### 2. 設定ファイル作成

```dart
// lib/config/youtube_config.dart
class YouTubeConfig {
  // 本番環境
  static const String prodApiKey = 'YOUR_PRODUCTION_API_KEY';
  static const String prodClientId = 'YOUR_PRODUCTION_CLIENT_ID.googleusercontent.com';
  static const String prodClientSecret = 'YOUR_PRODUCTION_CLIENT_SECRET';
  
  // 開発環境
  static const String devApiKey = 'YOUR_DEVELOPMENT_API_KEY';
  static const String devClientId = 'YOUR_DEVELOPMENT_CLIENT_ID.googleusercontent.com';
  static const String devClientSecret = 'YOUR_DEVELOPMENT_CLIENT_SECRET';
  
  // 環境別取得
  static String get apiKey => const bool.fromEnvironment('dart.vm.product') 
      ? prodApiKey : devApiKey;
  
  static String get clientId => const bool.fromEnvironment('dart.vm.product') 
      ? prodClientId : devClientId;
  
  static String get clientSecret => const bool.fromEnvironment('dart.vm.product') 
      ? prodClientSecret : devClientSecret;
  
  // スコープ定義
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/youtube.readonly',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];
  
  // リダイレクトURI
  static const String redirectUri = 'https://starlist.com/auth/youtube/callback';
}
```

### 3. YouTube APIサービス実装

```dart
// lib/services/youtube_api_service.dart
import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../config/youtube_config.dart';

class YouTubeApiService {
  late YouTubeApi _youtubeApi;
  AuthClient? _authClient;
  
  /// APIキーのみでの初期化（公開データアクセス用）
  Future<void> initializeWithApiKey() async {
    final httpClient = http.Client();
    _youtubeApi = YouTubeApi(httpClient, rootUrl: 'https://www.googleapis.com/');
  }
  
  /// OAuth認証での初期化（ユーザー固有データアクセス用）
  Future<bool> initializeWithOAuth() async {
    try {
      final credentials = ClientId(
        YouTubeConfig.clientId,
        YouTubeConfig.clientSecret,
      );
      
      _authClient = await clientViaUserConsent(
        credentials,
        YouTubeConfig.scopes,
        (url) async {
          // URLをブラウザで開く
          await launchUrl(Uri.parse(url));
        },
      );
      
      _youtubeApi = YouTubeApi(_authClient!);
      return true;
    } catch (e) {
      print('OAuth認証エラー: $e');
      return false;
    }
  }
  
  /// チャンネル情報取得
  Future<Channel?> getChannelInfo(String channelId) async {
    try {
      final response = await _youtubeApi.channels.list(
        ['snippet', 'statistics'],
        id: [channelId],
        key: YouTubeConfig.apiKey,
      );
      
      return response.items?.isNotEmpty == true ? response.items!.first : null;
    } catch (e) {
      print('チャンネル情報取得エラー: $e');
      return null;
    }
  }
  
  /// 動画リスト取得
  Future<List<Video>> getChannelVideos(
    String channelId, {
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      // 1. チャンネルのアップロードプレイリストIDを取得
      final channelResponse = await _youtubeApi.channels.list(
        ['contentDetails'],
        id: [channelId],
        key: YouTubeConfig.apiKey,
      );
      
      if (channelResponse.items?.isEmpty == true) return [];
      
      final uploadsPlaylistId = channelResponse.items!.first
          .contentDetails?.relatedPlaylists?.uploads;
      
      if (uploadsPlaylistId == null) return [];
      
      // 2. プレイリストから動画IDを取得
      final playlistResponse = await _youtubeApi.playlistItems.list(
        ['snippet'],
        playlistId: uploadsPlaylistId,
        maxResults: maxResults,
        pageToken: pageToken,
        key: YouTubeConfig.apiKey,
      );
      
      final videoIds = playlistResponse.items
          ?.map((item) => item.snippet?.resourceId?.videoId)
          .where((id) => id != null)
          .cast<String>()
          .toList() ?? [];
      
      if (videoIds.isEmpty) return [];
      
      // 3. 動画詳細情報を取得
      final videosResponse = await _youtubeApi.videos.list(
        ['snippet', 'statistics', 'contentDetails'],
        id: videoIds,
        key: YouTubeConfig.apiKey,
      );
      
      return videosResponse.items ?? [];
    } catch (e) {
      print('動画リスト取得エラー: $e');
      return [];
    }
  }
  
  /// 動画検索（注意: 100ユニット消費）
  Future<List<SearchResult>> searchVideos(
    String query, {
    int maxResults = 25,
    String? channelId,
    String? pageToken,
  }) async {
    try {
      final response = await _youtubeApi.search.list(
        ['snippet'],
        q: query,
        type: ['video'],
        maxResults: maxResults,
        channelId: channelId,
        pageToken: pageToken,
        order: 'relevance',
        key: YouTubeConfig.apiKey,
      );
      
      return response.items ?? [];
    } catch (e) {
      print('動画検索エラー: $e');
      return [];
    }
  }
  
  /// 動画統計情報取得
  Future<VideoStatistics?> getVideoStatistics(String videoId) async {
    try {
      final response = await _youtubeApi.videos.list(
        ['statistics'],
        id: [videoId],
        key: YouTubeConfig.apiKey,
      );
      
      return response.items?.isNotEmpty == true 
          ? response.items!.first.statistics
          : null;
    } catch (e) {
      print('動画統計取得エラー: $e');
      return null;
    }
  }
  
  /// 認証済みユーザーのチャンネル取得
  Future<Channel?> getMyChannel() async {
    if (_authClient == null) {
      throw Exception('OAuth認証が必要です');
    }
    
    try {
      final response = await _youtubeApi.channels.list(
        ['snippet', 'statistics', 'contentDetails'],
        mine: true,
      );
      
      return response.items?.isNotEmpty == true ? response.items!.first : null;
    } catch (e) {
      print('認証済みチャンネル取得エラー: $e');
      return null;
    }
  }
  
  /// リソース解放
  void dispose() {
    _authClient?.close();
  }
}
```

### 4. データモデル作成

```dart
// lib/models/youtube_models.dart
import 'package:googleapis/youtube/v3.dart' as youtube;

class YouTubeChannelData {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int subscriberCount;
  final int videoCount;
  final int viewCount;
  final DateTime createdAt;
  
  YouTubeChannelData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
    required this.createdAt,
  });
  
  factory YouTubeChannelData.fromYouTubeChannel(youtube.Channel channel) {
    final snippet = channel.snippet!;
    final statistics = channel.statistics!;
    
    return YouTubeChannelData(
      id: channel.id!,
      title: snippet.title ?? '',
      description: snippet.description ?? '',
      thumbnailUrl: snippet.thumbnails?.high?.url ?? '',
      subscriberCount: int.tryParse(statistics.subscriberCount ?? '0') ?? 0,
      videoCount: int.tryParse(statistics.videoCount ?? '0') ?? 0,
      viewCount: int.tryParse(statistics.viewCount ?? '0') ?? 0,
      createdAt: snippet.publishedAt ?? DateTime.now(),
    );
  }
}

class YouTubeVideoData {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final Duration duration;
  final DateTime publishedAt;
  final List<String> tags;
  
  YouTubeVideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.duration,
    required this.publishedAt,
    required this.tags,
  });
  
  factory YouTubeVideoData.fromYouTubeVideo(youtube.Video video) {
    final snippet = video.snippet!;
    final statistics = video.statistics;
    final contentDetails = video.contentDetails;
    
    return YouTubeVideoData(
      id: video.id!,
      title: snippet.title ?? '',
      description: snippet.description ?? '',
      thumbnailUrl: snippet.thumbnails?.high?.url ?? '',
      viewCount: int.tryParse(statistics?.viewCount ?? '0') ?? 0,
      likeCount: int.tryParse(statistics?.likeCount ?? '0') ?? 0,
      commentCount: int.tryParse(statistics?.commentCount ?? '0') ?? 0,
      duration: _parseDuration(contentDetails?.duration ?? ''),
      publishedAt: snippet.publishedAt ?? DateTime.now(),
      tags: snippet.tags ?? [],
    );
  }
  
  static Duration _parseDuration(String isoDuration) {
    // ISO 8601形式（例: PT4M13S）をDurationに変換
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return Duration.zero;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}
```

## API使用量管理

### 1. クォータ監視

```dart
// lib/services/youtube_quota_manager.dart
class YouTubeQuotaManager {
  static const int dailyQuotaLimit = 10000;
  static const Map<String, int> apiCosts = {
    'channels.list': 1,
    'videos.list': 1,
    'playlistItems.list': 1,
    'search.list': 100, // 高コスト注意！
  };
  
  int _dailyUsage = 0;
  DateTime _lastResetDate = DateTime.now();
  
  bool canMakeRequest(String apiEndpoint) {
    _resetIfNewDay();
    
    final cost = apiCosts[apiEndpoint] ?? 1;
    return (_dailyUsage + cost) <= dailyQuotaLimit;
  }
  
  void recordUsage(String apiEndpoint) {
    _resetIfNewDay();
    _dailyUsage += apiCosts[apiEndpoint] ?? 1;
  }
  
  void _resetIfNewDay() {
    final now = DateTime.now();
    if (now.day != _lastResetDate.day) {
      _dailyUsage = 0;
      _lastResetDate = now;
    }
  }
  
  double get usagePercentage => _dailyUsage / dailyQuotaLimit;
  int get remainingQuota => dailyQuotaLimit - _dailyUsage;
}
```

### 2. レスポンスキャッシュ

```dart
// lib/services/youtube_cache_service.dart
class YouTubeCacheService {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration defaultTTL = Duration(hours: 1);
  
  static void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? defaultTTL),
    );
  }
  
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }
  
  static void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  
  CacheEntry({required this.data, required this.expiresAt});
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

## エラーハンドリング

### YouTubeエラー対応

```dart
// lib/services/youtube_error_handler.dart
class YouTubeErrorHandler {
  static YouTubeApiError handleError(dynamic error) {
    if (error.toString().contains('quotaExceeded')) {
      return YouTubeApiError(
        type: YouTubeErrorType.quotaExceeded,
        message: 'APIクォータを超過しました。24時間後に再試行してください。',
        retryAfter: Duration(hours: 24),
      );
    }
    
    if (error.toString().contains('keyInvalid')) {
      return YouTubeApiError(
        type: YouTubeErrorType.invalidApiKey,
        message: 'APIキーが無効です。設定を確認してください。',
      );
    }
    
    if (error.toString().contains('videoNotFound')) {
      return YouTubeApiError(
        type: YouTubeErrorType.resourceNotFound,
        message: '指定された動画が見つかりません。',
      );
    }
    
    return YouTubeApiError(
      type: YouTubeErrorType.unknown,
      message: '不明なエラーが発生しました: ${error.toString()}',
    );
  }
}

enum YouTubeErrorType {
  quotaExceeded,
  invalidApiKey,
  resourceNotFound,
  networkError,
  unknown,
}

class YouTubeApiError {
  final YouTubeErrorType type;
  final String message;
  final Duration? retryAfter;
  
  YouTubeApiError({
    required this.type,
    required this.message,
    this.retryAfter,
  });
}
```

## セキュリティ考慮事項

### 1. APIキー保護

```dart
// 環境変数での管理例
// .env ファイル（gitignoreに追加）
YOUTUBE_API_KEY_DEV=your_development_api_key
YOUTUBE_API_KEY_PROD=your_production_api_key
YOUTUBE_CLIENT_ID_DEV=your_development_client_id
YOUTUBE_CLIENT_SECRET_DEV=your_development_client_secret
```

### 2. セキュリティチェックリスト

- ✅ **APIキーをソースコードに直接含めない**
- ✅ **本番用と開発用でAPIキーを分離**
- ✅ **APIキーにリファラー制限を設定**
- ✅ **OAuth認証にCSRF対策を実装**
- ✅ **ユーザーデータの最小権限原則を適用**
- ✅ **定期的なAPIキーローテーション**

## 実装例：スターYouTube連携

```dart
// lib/features/star_youtube_integration.dart
class StarYouTubeIntegrationService {
  final YouTubeApiService _youtubeService;
  final StarProfileService _starService;
  
  StarYouTubeIntegrationService({
    required YouTubeApiService youtubeService,
    required StarProfileService starService,
  }) : _youtubeService = youtubeService,
       _starService = starService;
  
  /// スターのYouTubeチャンネル連携
  Future<bool> linkYouTubeChannel(String starId, String channelId) async {
    try {
      // 1. YouTubeチャンネル情報取得
      final channel = await _youtubeService.getChannelInfo(channelId);
      if (channel == null) return false;
      
      // 2. スターのプロフィールに反映
      final youtubeData = YouTubeChannelData.fromYouTubeChannel(channel);
      await _starService.updateYouTubeInfo(starId, youtubeData);
      
      // 3. 最新動画を「毎日ピック」候補として取得
      final recentVideos = await _youtubeService.getChannelVideos(
        channelId, 
        maxResults: 10,
      );
      
      for (final video in recentVideos) {
        await _createDailyPickFromVideo(starId, video);
      }
      
      return true;
    } catch (e) {
      print('YouTube連携エラー: $e');
      return false;
    }
  }
  
  /// YouTube動画から毎日ピックコンテンツを作成
  Future<void> _createDailyPickFromVideo(String starId, youtube.Video video) async {
    final videoData = YouTubeVideoData.fromYouTubeVideo(video);
    
    // 毎日ピックアイテムとして保存
    // 実装は daily_pick_models.dart の DailyPickItem を参照
  }
}
```

## トラブルシューティング

### よくある問題と解決策

1. **403 Forbidden エラー**
   - APIキーの制限設定を確認
   - クォータ超過の可能性

2. **401 Unauthorized エラー**
   - OAuth認証の期限切れ
   - トークンの再取得が必要

3. **動画取得が0件**
   - チャンネルのプライバシー設定確認
   - APIスコープの不足

4. **レスポンス速度が遅い**
   - バッチリクエストの活用
   - キャッシュ戦略の見直し

## 参考リンク

- [YouTube Data API v3 公式ドキュメント](https://developers.google.com/youtube/v3)
- [Google APIs Dart ライブラリ](https://pub.dev/packages/googleapis)
- [OAuth 2.0 認証フロー](https://developers.google.com/identity/protocols/oauth2)
- [API使用量とクォータ](https://developers.google.com/youtube/v3/getting-started#quota)

---

📝 **更新履歴**
- 2025-06-22: 初版作成
- 対象: Starlist YouTube統合機能
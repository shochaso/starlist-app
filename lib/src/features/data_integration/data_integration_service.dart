import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/youtube_api_service.dart';
import '../services/spotify_api_service.dart';
import '../services/netflix_api_service.dart';
import '../services/linkedin_api_service.dart';
import '../services/twitter_api_service.dart';
import '../services/instagram_api_service.dart';
import '../../../../src/core/errors/app_exceptions.dart';
import '../../../../src/core/logging/logger.dart';
import '../../../../src/core/cache/cache_manager.dart';

/// データ統合サービスの共通インターフェース
/// 各種APIサービスを統合し、一貫したインターフェースを提供する
class DataIntegrationService {
  final YouTubeApiService _youtubeApiService;
  final SpotifyApiService _spotifyApiService;
  final NetflixApiService _netflixApiService;
  final LinkedInApiService _linkedInApiService;
  final TwitterApiService _twitterApiService;
  final InstagramApiService _instagramApiService;
  final Logger _logger;
  final CacheManager _cacheManager;
  final DataIntegrationConfig _config;

  DataIntegrationService({
    required YouTubeApiService youtubeApiService,
    required SpotifyApiService spotifyApiService,
    required NetflixApiService netflixApiService,
    required LinkedInApiService linkedInApiService,
    required TwitterApiService twitterApiService,
    required InstagramApiService instagramApiService,
    Logger? logger,
    CacheManager? cacheManager,
    DataIntegrationConfig? config,
  }) : _youtubeApiService = youtubeApiService,
       _spotifyApiService = spotifyApiService,
       _netflixApiService = netflixApiService,
       _linkedInApiService = linkedInApiService,
       _twitterApiService = twitterApiService,
       _instagramApiService = instagramApiService,
       _logger = logger ?? Logger(),
       _cacheManager = cacheManager ?? CacheManager(),
       _config = config ?? DataIntegrationConfig();

  /// YouTubeのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getYouTubeData({
    required String accessToken,
    bool includeSubscriptions = true,
    bool includeWatchHistory = true,
    int watchHistoryLimit = 20,
    DateTime? watchHistorySince,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'youtube_${accessToken}_${includeSubscriptions}_${includeWatchHistory}_$watchHistoryLimit';
    // オフライン時はキャッシュを優先的に返す
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity == ConnectivityResult.none;
    if (isOffline) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) return cachedData;
    }
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('YouTube data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching YouTube data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = <String, dynamic>{};

      // リトライ機能付きAPI呼び出し
      if (includeSubscriptions) {
        result['subscriptions'] = await _callWithRetry(
          apiCall: () => _youtubeApiService.getSubscriptions(
            accessToken: accessToken,
          ),
          platform: 'YouTube',
          operationName: 'getSubscriptions',
        );
      }

      if (includeWatchHistory) {
        result['watch_history'] = await _callWithRetry(
          apiCall: () => _youtubeApiService.getWatchHistory(
            accessToken: accessToken,
            limit: watchHistoryLimit,
            since: watchHistorySince,
          ),
          platform: 'YouTube',
          operationName: 'getWatchHistory',
        );
      }
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('youtube_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存
      final expiry = _config.getCacheExpiryForPlatform('youtube');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('YouTube data fetch failed', e);
      throw _handleIntegrationError('YouTube', e);
    }
  }

  /// Spotifyのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getSpotifyData({
    required String accessToken,
    bool includeRecentlyPlayed = true,
    bool includeTopArtists = true,
    bool includeTopTracks = true,
    bool includePlaylists = true,
    int itemLimit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'spotify_${accessToken}_${includeRecentlyPlayed}_${includeTopArtists}_${includeTopTracks}_${includePlaylists}_$itemLimit';
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity == ConnectivityResult.none;
    if (isOffline) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) return cachedData;
    }
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('Spotify data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching Spotify data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = <String, dynamic>{};

      // プロフィール情報の取得
      result['profile'] = await _callWithRetry(
        apiCall: () => _spotifyApiService.getUserProfile(
          accessToken: accessToken,
        ),
        platform: 'Spotify',
        operationName: 'getUserProfile',
      );

      // 並列でその他のデータを取得
      final futures = <Future<void>>[];
      
      if (includeRecentlyPlayed) {
        futures.add(
          _callWithRetry(
            apiCall: () => _spotifyApiService.getRecentlyPlayed(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Spotify',
            operationName: 'getRecentlyPlayed',
          ).then((data) => result['recently_played'] = data)
        );
      }

      if (includeTopArtists) {
        futures.add(
          _callWithRetry(
            apiCall: () => _spotifyApiService.getTopArtists(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Spotify',
            operationName: 'getTopArtists',
          ).then((data) => result['top_artists'] = data)
        );
      }

      if (includeTopTracks) {
        futures.add(
          _callWithRetry(
            apiCall: () => _spotifyApiService.getTopTracks(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Spotify',
            operationName: 'getTopTracks',
          ).then((data) => result['top_tracks'] = data)
        );
      }

      if (includePlaylists) {
        futures.add(
          _callWithRetry(
            apiCall: () => _spotifyApiService.getUserPlaylists(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Spotify',
            operationName: 'getUserPlaylists',
          ).then((data) => result['playlists'] = data)
        );
      }
      
      // 全ての並列処理を待機
      await Future.wait(futures);
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('spotify_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存
      final expiry = _config.getCacheExpiryForPlatform('spotify');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('Spotify data fetch failed', e);
      throw _handleIntegrationError('Spotify', e);
    }
  }

  /// Netflixのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getNetflixData({
    required String accessToken,
    bool includeViewingHistory = true,
    bool includeUserLists = true,
    int itemLimit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'netflix_${accessToken}_${includeViewingHistory}_${includeUserLists}_$itemLimit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('Netflix data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching Netflix data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = <String, dynamic>{};

      // プロフィール情報の取得
      result['profile'] = await _callWithRetry(
        apiCall: () => _netflixApiService.getUserProfile(
          accessToken: accessToken,
        ),
        platform: 'Netflix',
        operationName: 'getUserProfile',
      );

      // 並列でその他のデータを取得
      final futures = <Future<void>>[];
      
      if (includeViewingHistory) {
        futures.add(
          _callWithRetry(
            apiCall: () => _netflixApiService.getViewingHistory(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Netflix',
            operationName: 'getViewingHistory',
          ).then((data) => result['viewing_history'] = data)
        );
      }

      if (includeUserLists) {
        futures.add(
          _callWithRetry(
            apiCall: () => _netflixApiService.getUserLists(
              accessToken: accessToken,
              limit: itemLimit,
            ),
            platform: 'Netflix',
            operationName: 'getUserLists',
          ).then((data) => result['user_lists'] = data)
        );
      }
      
      // 全ての並列処理を待機
      await Future.wait(futures);
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('netflix_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存
      final expiry = _config.getCacheExpiryForPlatform('netflix');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('Netflix data fetch failed', e);
      throw _handleIntegrationError('Netflix', e);
    }
  }

  /// LinkedInのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getLinkedInData({
    required String username,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'linkedin_$username';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('LinkedIn data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching LinkedIn data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = <String, dynamic>{};

      // プロフィール情報の取得
      result['profile'] = await _callWithRetry(
        apiCall: () => _linkedInApiService.getUserProfile(
          username: username,
        ),
        platform: 'LinkedIn',
        operationName: 'getUserProfile',
      );
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('linkedin_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存（LinkedInデータは長期間変更されない可能性が高い）
      final expiry = _config.getCacheExpiryForPlatform('linkedin');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('LinkedIn data fetch failed', e);
      throw _handleIntegrationError('LinkedIn', e);
    }
  }

  /// Twitterのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getTwitterData({
    required String username,
    required String userId,
    bool includeTweets = true,
    bool includeFollowers = true,
    bool includeFollowing = true,
    int itemLimit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'twitter_${username}_${userId}_${includeTweets}_${includeFollowers}_${includeFollowing}_$itemLimit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('Twitter data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching Twitter data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = <String, dynamic>{};

      // ユーザー情報の取得
      result['user_info'] = await _callWithRetry(
        apiCall: () => _twitterApiService.getUserInfo(
          username: username,
        ),
        platform: 'Twitter',
        operationName: 'getUserInfo',
      );

      // 並列でその他のデータを取得
      final futures = <Future<void>>[];
      
      if (includeTweets) {
        futures.add(
          _callWithRetry(
            apiCall: () => _twitterApiService.getUserTweets(
              userId: userId,
              limit: itemLimit,
            ),
            platform: 'Twitter',
            operationName: 'getUserTweets',
          ).then((data) => result['tweets'] = data)
        );
      }

      if (includeFollowers) {
        futures.add(
          _callWithRetry(
            apiCall: () => _twitterApiService.getUserFollowers(
              userId: userId,
              limit: itemLimit,
            ),
            platform: 'Twitter',
            operationName: 'getUserFollowers',
          ).then((data) => result['followers'] = data)
        );
      }

      if (includeFollowing) {
        futures.add(
          _callWithRetry(
            apiCall: () => _twitterApiService.getUserFollowing(
              userId: userId,
              limit: itemLimit,
            ),
            platform: 'Twitter',
            operationName: 'getUserFollowing',
          ).then((data) => result['following'] = data)
        );
      }
      
      // 全ての並列処理を待機
      await Future.wait(futures);
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('twitter_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存
      final expiry = _config.getCacheExpiryForPlatform('twitter');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('Twitter data fetch failed', e);
      throw _handleIntegrationError('Twitter', e);
    }
  }

  /// Instagramのデータを取得する（最適化版）
  Future<Map<String, dynamic>> getInstagramData({
    required String accessToken,
    bool includeMedia = true,
    int mediaLimit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'instagram_${accessToken}_${includeMedia}_$mediaLimit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _logger.info('Instagram data retrieved from cache');
        return cachedData;
      }
    }
    
    _logger.info('Fetching Instagram data from API');
    final stopwatch = Stopwatch()..start();
    
    try {
      final instagramService = InstagramApiService(accessToken: accessToken);
      final result = <String, dynamic>{};

      // プロフィール情報の取得
      result['profile'] = await _callWithRetry(
        apiCall: () => instagramService.getUserProfile(),
        platform: 'Instagram',
        operationName: 'getUserProfile',
      );

      if (includeMedia) {
        result['media'] = await _callWithRetry(
          apiCall: () => instagramService.getUserMedia(limit: mediaLimit),
          platform: 'Instagram',
          operationName: 'getUserMedia',
        );
      }
      
      // パフォーマンスメトリクスの記録
      stopwatch.stop();
      _logger.metric('instagram_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
      
      // データをキャッシュに保存
      final expiry = _config.getCacheExpiryForPlatform('instagram');
      await _cacheManager.set(cacheKey, result, expiry: expiry);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logger.error('Instagram data fetch failed', e);
      throw _handleIntegrationError('Instagram', e);
    }
  }

  /// 全てのプラットフォームからユーザーのコンテンツ消費データを並列取得する
  Future<Map<String, dynamic>> getAllContentConsumptionDataParallel({
    String? youtubeAccessToken,
    String? spotifyAccessToken,
    String? netflixAccessToken,
    String? linkedInUsername,
    String? twitterUsername,
    String? twitterUserId,
    String? instagramAccessToken,
    bool forceRefresh = false,
  }) async {
    _logger.info('Starting parallel data fetch from all platforms');
    final stopwatch = Stopwatch()..start();
    
    final result = <String, dynamic>{};
    final futures = <Future<void>>[];
    final errors = <String, dynamic>{};
    
    // YouTube データの並列取得
    if (youtubeAccessToken != null) {
      futures.add(
        getYouTubeData(
          accessToken: youtubeAccessToken,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['youtube'] = data)
        .catchError((e) {
          _logger.warning('YouTube data fetch failed: $e');
          errors['youtube'] = e.toString();
          result['youtube'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // Spotify データの並列取得
    if (spotifyAccessToken != null) {
      futures.add(
        getSpotifyData(
          accessToken: spotifyAccessToken,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['spotify'] = data)
        .catchError((e) {
          _logger.warning('Spotify data fetch failed: $e');
          errors['spotify'] = e.toString();
          result['spotify'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // Netflix データの並列取得
    if (netflixAccessToken != null) {
      futures.add(
        getNetflixData(
          accessToken: netflixAccessToken,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['netflix'] = data)
        .catchError((e) {
          _logger.warning('Netflix data fetch failed: $e');
          errors['netflix'] = e.toString();
          result['netflix'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // LinkedIn データの並列取得
    if (linkedInUsername != null) {
      futures.add(
        getLinkedInData(
          username: linkedInUsername,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['linkedin'] = data)
        .catchError((e) {
          _logger.warning('LinkedIn data fetch failed: $e');
          errors['linkedin'] = e.toString();
          result['linkedin'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // Twitter データの並列取得
    if (twitterUsername != null && twitterUserId != null) {
      futures.add(
        getTwitterData(
          username: twitterUsername,
          userId: twitterUserId,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['twitter'] = data)
        .catchError((e) {
          _logger.warning('Twitter data fetch failed: $e');
          errors['twitter'] = e.toString();
          result['twitter'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // Instagram データの並列取得
    if (instagramAccessToken != null) {
      futures.add(
        getInstagramData(
          accessToken: instagramAccessToken,
          forceRefresh: forceRefresh,
        )
        .then((data) => result['instagram'] = data)
        .catchError((e) {
          _logger.warning('Instagram data fetch failed: $e');
          errors['instagram'] = e.toString();
          result['instagram'] = {'error': e.toString(), 'partial_data': true};
        })
      );
    }
    
    // 全ての並列処理を待機
    await Future.wait(futures);
    
    // パフォーマンスメトリクスの記録
    stopwatch.stop();
    _logger.metric('all_platforms_data_fetch_time', stopwatch.elapsedMilliseconds.toDouble());
    
    // エラーがあった場合はメタデータに記録
    if (errors.isNotEmpty) {
      result['_metadata'] = {
        'has_errors': true,
        'errors': errors,
        'platforms_with_errors': errors.keys.toList(),
        'platforms_succeeded': result.keys.where((k) => !k.startsWith('_') && !errors.containsKey(k)).toList(),
        'fetch_time_ms': stopwatch.elapsedMilliseconds,
      };
    } else {
      result['_metadata'] = {
        'has_errors': false,
        'platforms_succeeded': result.keys.where((k) => !k.startsWith('_')).toList(),
        'fetch_time_ms': stopwatch.elapsedMilliseconds,
      };
    }
    
    return result;
  }

  /// リトライ機能付きAPI呼び出し
  Future<T> _callWithRetry<T>({
    required Future<T> Function() apiCall,
    required String platform,
    required String operationName,
    int maxRetries = 3,
    Duration? timeout,
  }) async {
    timeout ??= _config.getTimeoutForPlatform(platform);
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 500);
    
    while (true) {
      try {
        attempts++;
        _logger.info('$platform $operationName: attempt $attempts');
        
        // タイムアウト付きでAPI呼び出し
        return await apiCall().timeout(timeout);
      } catch (e) {
        final isLastAttempt = attempts >= maxRetries;
        
        if (e is TimeoutException) {
          _logger.warning('$platform $operationName: timeout on attempt $attempts');
        } else if (e is SocketException) {
          _logger.warning('$platform $operationName: network error on attempt $attempts');
        } else {
          _logger.warning('$platform $operationName: error on attempt $attempts: $e');
        }
        
        // 最大リトライ回数に達した場合はエラーをスロー
        if (isLastAttempt) {
          throw _handleIntegrationError(platform, e);
        }
        
        // 一時的なエラーの場合のみリトライ
        if (e is TimeoutException || e is SocketException || 
            (e is ApiException && (e.isRateLimited || e.isServerError))) {
          await Future.delayed(delay);
          delay *= 2; // 指数バックオフ
          continue;
        }
        
        // その他のエラーは即座に失敗
        throw _handleIntegrationError(platform, e);
      }
    }
  }

  /// 統合エラーを処理する（改善版）
  Exception _handleIntegrationError(String platform, dynamic error) {
    // 監視に送信
    // ignore: unawaited_futures
    Sentry.captureException(error, withScope: (scope) {
      scope.setTag('platform', platform);
    });
    if (error is AppException) {
      return error;
    } else if (error is TimeoutException) {
      return ApiTimeoutException(
        message: '$platform API request timed out',
        details: error.toString(),
        platform: platform,
      );
    } else if (error is SocketException) {
      return NetworkException(
        message: '$platform network connection failed',
        details: error.toString(),
        platform: platform,
      );
    } else {
      return ApiException(
        message: '$platform integration error: ${error.toString()}',
        details: error.toString(),
        platform: platform,
      );
    }
  }
}

/// データ統合サービス設定クラス
class DataIntegrationConfig {
  // デフォルトのタイムアウト設定
  final Duration defaultTimeout = const Duration(seconds: 30);
  
  // プラットフォーム別のタイムアウト設定
  final Map<String, Duration> platformTimeouts = {
    'youtube': const Duration(seconds: 45),
    'spotify': const Duration(seconds: 30),
    'netflix': const Duration(seconds: 60),
    'linkedin': const Duration(seconds: 20),
    'twitter': const Duration(seconds: 15),
    'instagram': const Duration(seconds: 25),
  };
  
  // プラットフォーム別のキャッシュ期間設定
  final Map<String, Duration> platformCacheExpiry = {
    'youtube': const Duration(minutes: 30),
    'spotify': const Duration(minutes: 30),
    'netflix': const Duration(hours: 1),
    'linkedin': const Duration(days: 1),
    'twitter': const Duration(minutes: 15),
    'instagram': const Duration(hours: 2),
  };
  
  // プラットフォームのタイムアウトを取得
  Duration getTimeoutForPlatform(String platform) {
    return platformTimeouts[platform.toLowerCase()] ?? defaultTimeout;
  }
  
  // プラットフォームのキャッシュ期間を取得
  Duration getCacheExpiryForPlatform(String platform) {
    return platformCacheExpiry[platform.toLowerCase()] ?? const Duration(hours: 1);
  }
}

/// API タイムアウト例外
class ApiTimeoutException extends ApiException {
  final String platform;
  
  ApiTimeoutException({
    required String message,
    dynamic details,
    required this.platform,
  }) : super(message: message, details: details);
}

/// ネットワーク例外
class NetworkException extends ApiException {
  final String platform;
  
  NetworkException({
    required String message,
    dynamic details,
    required this.platform,
  }) : super(message: message, details: details);
}

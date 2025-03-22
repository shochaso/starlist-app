import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/cache/cache_manager.dart';

/// ランキングリポジトリクラス
///
/// ランキングデータの取得・保存を担当します。
/// キャッシュ戦略を実装し、APIリクエストを最小限に抑えます。
class RankingRepository {
  /// APIクライアント
  final ApiClient _apiClient;
  
  /// キャッシュマネージャー
  final CacheManager _cacheManager;

  /// コンストラクタ
  RankingRepository(this._apiClient, this._cacheManager);

  /// トレンドコンテンツを取得
  ///
  /// キャッシュ戦略:
  /// 1. キャッシュが有効な場合はキャッシュから返す
  /// 2. キャッシュが無効な場合はAPIから取得し、キャッシュを更新
  Future<RankingModel> getTrendingContent({
    RankingPeriod period = RankingPeriod.week,
    String? contentType,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'trending_content_${period.toString()}_${contentType ?? 'all'}_$limit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final ranking = RankingModel.fromJson(cachedData);
          // キャッシュが有効期限内かチェック
          if (ranking.cacheExpiry.isAfter(DateTime.now())) {
            return ranking;
          }
        } catch (e) {
          // キャッシュデータの解析エラーは無視して続行
        }
      }
    }
    
    // APIからデータ取得
    try {
      final response = await _apiClient.get(
        '/ranking/trending',
        queryParameters: {
          'period': period.toString().split('.').last,
          'limit': limit,
          if (contentType != null) 'content_type': contentType,
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final ranking = RankingModel.fromJson(data);
      
      // キャッシュを更新
      await _cacheManager.set(cacheKey, data, expiry: ranking.cacheExpiry);
      
      return ranking;
    } catch (e) {
      throw DataFetchException('トレンドコンテンツの取得に失敗しました: $e');
    }
  }

  /// 人気スターを取得
  ///
  /// キャッシュ戦略:
  /// 1. キャッシュが有効な場合はキャッシュから返す
  /// 2. キャッシュが無効な場合はAPIから取得し、キャッシュを更新
  Future<RankingModel> getPopularStars({
    RankingPeriod period = RankingPeriod.week,
    String? category,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'popular_stars_${period.toString()}_${category ?? 'all'}_$limit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final ranking = RankingModel.fromJson(cachedData);
          // キャッシュが有効期限内かチェック
          if (ranking.cacheExpiry.isAfter(DateTime.now())) {
            return ranking;
          }
        } catch (e) {
          // キャッシュデータの解析エラーは無視して続行
        }
      }
    }
    
    // APIからデータ取得
    try {
      final response = await _apiClient.get(
        '/ranking/stars',
        queryParameters: {
          'period': period.toString().split('.').last,
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final ranking = RankingModel.fromJson(data);
      
      // キャッシュを更新
      await _cacheManager.set(cacheKey, data, expiry: ranking.cacheExpiry);
      
      return ranking;
    } catch (e) {
      throw DataFetchException('人気スターの取得に失敗しました: $e');
    }
  }

  /// カテゴリ別ランキングを取得
  Future<RankingModel> getCategoryRanking({
    required String categoryId,
    RankingPeriod period = RankingPeriod.week,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'category_ranking_${categoryId}_${period.toString()}_$limit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final ranking = RankingModel.fromJson(cachedData);
          // キャッシュが有効期限内かチェック
          if (ranking.cacheExpiry.isAfter(DateTime.now())) {
            return ranking;
          }
        } catch (e) {
          // キャッシュデータの解析エラーは無視して続行
        }
      }
    }
    
    // APIからデータ取得
    try {
      final response = await _apiClient.get(
        '/ranking/category/$categoryId',
        queryParameters: {
          'period': period.toString().split('.').last,
          'limit': limit,
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final ranking = RankingModel.fromJson(data);
      
      // キャッシュを更新
      await _cacheManager.set(cacheKey, data, expiry: ranking.cacheExpiry);
      
      return ranking;
    } catch (e) {
      throw DataFetchException('カテゴリランキングの取得に失敗しました: $e');
    }
  }

  /// ユーザーのパーソナライズドランキングを取得
  Future<RankingModel> getPersonalizedRanking({
    required String userId,
    RankingPeriod period = RankingPeriod.week,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'personalized_ranking_${userId}_${period.toString()}_$limit';
    
    // キャッシュチェック（強制リフレッシュでない場合）
    if (!forceRefresh) {
      final cachedData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final ranking = RankingModel.fromJson(cachedData);
          // キャッシュが有効期限内かチェック
          if (ranking.cacheExpiry.isAfter(DateTime.now())) {
            return ranking;
          }
        } catch (e) {
          // キャッシュデータの解析エラーは無視して続行
        }
      }
    }
    
    // APIからデータ取得
    try {
      final response = await _apiClient.get(
        '/ranking/personalized/$userId',
        queryParameters: {
          'period': period.toString().split('.').last,
          'limit': limit,
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final ranking = RankingModel.fromJson(data);
      
      // キャッシュを更新
      await _cacheManager.set(cacheKey, data, expiry: ranking.cacheExpiry);
      
      return ranking;
    } catch (e) {
      throw DataFetchException('パーソナライズドランキングの取得に失敗しました: $e');
    }
  }
}

/// ランキングリポジトリプロバイダー
final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  return RankingRepository(apiClient, cacheManager);
});

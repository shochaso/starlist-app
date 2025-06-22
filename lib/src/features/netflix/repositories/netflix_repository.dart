import 'dart:io';
import '../../../data/models/netflix_models.dart';
import '../services/netflix_api_service.dart';
import '../services/netflix_ocr_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/logging/logger.dart';
import '../../../core/errors/app_exceptions.dart';

/// Netflixデータ管理リポジトリ
/// API、OCR、データベースの操作を統合
class NetflixRepository {
  final NetflixApiService _apiService;
  final NetflixOcrService _ocrService;
  final DatabaseService _databaseService;
  final Logger _logger;

  NetflixRepository({
    required NetflixApiService apiService,
    required NetflixOcrService ocrService,
    DatabaseService? databaseService,
    Logger? logger,
  })  : _apiService = apiService,
        _ocrService = ocrService,
        _databaseService = databaseService ?? DatabaseService(),
        _logger = logger ?? Logger();

  /// ユーザーのNetflix視聴履歴を取得
  Future<List<NetflixViewingHistory>> getViewingHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    try {
      _logger.info('Fetching Netflix viewing history for user: $userId');

      // キャッシュから取得を試行（強制リフレッシュでない場合）
      if (!forceRefresh) {
        final cachedHistory = await _getViewingHistoryFromDatabase(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
        
        if (cachedHistory.isNotEmpty) {
          _logger.info('Retrieved ${cachedHistory.length} viewing history items from cache');
          return cachedHistory;
        }
      }

      // APIから取得（手動データ）
      final apiHistory = await _apiService.getViewingHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // データベースに保存
      if (apiHistory.isNotEmpty) {
        await _saveViewingHistoryToDatabase(apiHistory);
      }

      _logger.info('Retrieved ${apiHistory.length} viewing history items from API');
      return apiHistory;

    } catch (e) {
      _logger.error('Failed to fetch Netflix viewing history', e);
      
      // エラー時はキャッシュから取得を試行
      try {
        final fallbackHistory = await _getViewingHistoryFromDatabase(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
        
        if (fallbackHistory.isNotEmpty) {
          _logger.info('Fallback: Retrieved ${fallbackHistory.length} viewing history items from cache');
          return fallbackHistory;
        }
      } catch (dbError) {
        _logger.warning('Fallback database query also failed: $dbError');
      }
      
      throw ApiException(
        message: 'Failed to fetch Netflix viewing history',
        details: e.toString(),
      );
    }
  }

  /// 画像パスからOCR解析を実行
  Future<List<NetflixViewingHistory>> analyzeViewingImageFromPath({
    required String userId,
    required String imagePath,
    required String sourceType,
  }) async {
    try {
      _logger.info('Analyzing Netflix viewing image from path: $imagePath');
      
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw ApiException(
          message: 'Image file not found',
          details: 'File does not exist at path: $imagePath',
        );
      }

      final viewingHistory = await _ocrService.analyzeNetflixViewingImage(
        userId: userId,
        imageFile: imageFile,
        sourceType: sourceType,
      );

      _logger.info('OCR analysis completed: ${viewingHistory.length} viewing history items extracted');
      return viewingHistory;

    } catch (e) {
      _logger.error('Failed to analyze Netflix viewing image', e);
      throw ApiException(
        message: 'Failed to analyze viewing history image',
        details: e.toString(),
      );
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<List<NetflixViewingHistory>> analyzeImageFromGallery({
    required String userId,
    required String sourceType,
  }) async {
    try {
      _logger.info('Analyzing Netflix viewing image from gallery');
      
      final viewingHistory = await _ocrService.analyzeImageFromGallery(
        userId: userId,
        sourceType: sourceType,
      );

      _logger.info('Gallery OCR analysis completed: ${viewingHistory.length} viewing history items extracted');
      return viewingHistory;

    } catch (e) {
      _logger.error('Failed to analyze image from gallery', e);
      rethrow;
    }
  }

  /// 手動で視聴履歴を追加
  Future<NetflixViewingHistory> addManualViewingHistory({
    required String userId,
    required String title,
    required NetflixContentType contentType,
    String? subtitle,
    DateTime? watchedAt,
    int? seasonNumber,
    int? episodeNumber,
    int? releaseYear,
    List<String>? genres,
    String? director,
    List<String>? cast,
    int? rating,
    String? review,
    NetflixWatchStatus? watchStatus,
  }) async {
    try {
      _logger.info('Adding manual Netflix viewing history: $title');
      
      final viewingHistory = await _apiService.addManualViewingHistory(
        userId: userId,
        title: title,
        contentType: contentType,
        subtitle: subtitle,
        watchedAt: watchedAt,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        releaseYear: releaseYear,
        genres: genres,
        director: director,
        cast: cast,
        rating: rating,
        review: review,
        watchStatus: watchStatus,
      );

      _logger.info('Manual viewing history created successfully');
      return viewingHistory;

    } catch (e) {
      _logger.error('Failed to add manual viewing history', e);
      throw ApiException(
        message: 'Failed to add manual viewing history',
        details: e.toString(),
      );
    }
  }

  /// 視聴履歴をデータベースに保存
  Future<void> saveViewingHistory(List<NetflixViewingHistory> viewingHistory) async {
    try {
      _logger.info('Saving ${viewingHistory.length} Netflix viewing history items to database');
      await _saveViewingHistoryToDatabase(viewingHistory);
    } catch (e) {
      _logger.error('Failed to save Netflix viewing history', e);
      throw DatabaseException(
        message: 'Failed to save viewing history to database',
        details: e.toString(),
      );
    }
  }

  /// 視聴履歴を更新
  Future<void> updateViewingHistory(NetflixViewingHistory viewingHistory) async {
    try {
      _logger.info('Updating Netflix viewing history: ${viewingHistory.id}');
      
      final updatedHistory = viewingHistory.copyWith(
        updatedAt: DateTime.now(),
      );

      await _databaseService.supabase
          .from('netflix_viewing_history')
          .update(updatedHistory.toJson())
          .eq('id', viewingHistory.id);

      _logger.info('Netflix viewing history updated successfully');

    } catch (e) {
      _logger.error('Failed to update Netflix viewing history', e);
      throw DatabaseException(
        message: 'Failed to update viewing history',
        details: e.toString(),
      );
    }
  }

  /// 視聴履歴を削除
  Future<void> deleteViewingHistory(String historyId) async {
    try {
      _logger.info('Deleting Netflix viewing history: $historyId');
      
      await _databaseService.supabase
          .from('netflix_viewing_history')
          .delete()
          .eq('id', historyId);

      _logger.info('Netflix viewing history deleted successfully');

    } catch (e) {
      _logger.error('Failed to delete Netflix viewing history', e);
      throw DatabaseException(
        message: 'Failed to delete viewing history',
        details: e.toString(),
      );
    }
  }

  /// コンテンツを検索
  Future<List<Map<String, dynamic>>> searchContent({
    required String query,
    NetflixContentType? contentType,
    int limit = 10,
  }) async {
    try {
      _logger.info('Searching Netflix content: $query');
      return await _apiService.searchContent(
        query: query,
        contentType: contentType,
        limit: limit,
      );
    } catch (e) {
      _logger.error('Failed to search Netflix content', e);
      return [];
    }
  }

  /// ユーザーの視聴統計を取得
  Future<NetflixViewingStats?> getViewingStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.info('Calculating Netflix viewing stats for user: $userId');
      
      final viewingHistory = await getViewingHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 1000, // 統計用に多めに取得
      );

      if (viewingHistory.isEmpty) {
        return null;
      }

      return _calculateViewingStats(viewingHistory, startDate, endDate);

    } catch (e) {
      _logger.error('Failed to calculate viewing stats', e);
      return null;
    }
  }

  /// ユーザープロフィール取得
  Future<Map<String, dynamic>?> getUserProfile({
    required String accessToken,
  }) async {
    try {
      _logger.info('Getting Netflix user profile');
      return await _apiService.getUserProfile(accessToken: accessToken);
    } catch (e) {
      _logger.error('Failed to get Netflix user profile', e);
      return null;
    }
  }

  /// ユーザーリスト取得
  Future<List<Map<String, dynamic>>> getUserLists({
    required String accessToken,
    int limit = 20,
  }) async {
    try {
      _logger.info('Getting Netflix user lists');
      return await _apiService.getUserLists(
        accessToken: accessToken,
        limit: limit,
      );
    } catch (e) {
      _logger.error('Failed to get Netflix user lists', e);
      return [];
    }
  }

  /// データベースから視聴履歴を取得
  Future<List<NetflixViewingHistory>> _getViewingHistoryFromDatabase({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      var query = _databaseService.supabase
          .from('netflix_viewing_history')
          .select()
          .eq('user_id', userId)
          .order('watched_at', ascending: false)
          .limit(limit);

      if (startDate != null) {
        query = query.gte('watched_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('watched_at', endDate.toIso8601String());
      }

      final response = await query;
      
      return (response as List)
          .map((json) => NetflixViewingHistory.fromJson(json))
          .toList();

    } catch (e) {
      _logger.error('Failed to fetch viewing history from database', e);
      rethrow;
    }
  }

  /// データベースに視聴履歴を保存
  Future<void> _saveViewingHistoryToDatabase(List<NetflixViewingHistory> viewingHistory) async {
    try {
      final historyJsonList = viewingHistory.map((h) => h.toJson()).toList();
      
      // upsert（挿入または更新）を使用して重複を回避
      await _databaseService.supabase
          .from('netflix_viewing_history')
          .upsert(historyJsonList);

    } catch (e) {
      _logger.error('Failed to save viewing history to database', e);
      rethrow;
    }
  }

  /// 視聴統計を計算
  NetflixViewingStats _calculateViewingStats(
    List<NetflixViewingHistory> viewingHistory,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    // 総視聴時間
    final totalWatchTime = viewingHistory.fold<Duration>(
      Duration.zero, 
      (sum, item) => sum + (item.watchDuration ?? Duration.zero),
    );

    // タイプ別集計
    final itemsByType = <NetflixContentType, int>{};
    final timeByType = <NetflixContentType, Duration>{};
    
    for (final item in viewingHistory) {
      itemsByType[item.contentType] = (itemsByType[item.contentType] ?? 0) + 1;
      timeByType[item.contentType] = (timeByType[item.contentType] ?? Duration.zero) + 
          (item.watchDuration ?? Duration.zero);
    }

    // ジャンル別集計
    final itemsByGenre = <String, int>{};
    final timeByGenre = <String, Duration>{};
    
    for (final item in viewingHistory) {
      for (final genre in item.genres) {
        itemsByGenre[genre] = (itemsByGenre[genre] ?? 0) + 1;
        timeByGenre[genre] = (timeByGenre[genre] ?? Duration.zero) + 
            (item.watchDuration ?? Duration.zero);
      }
    }

    // 年別集計
    final itemsByYear = <int, int>{};
    for (final item in viewingHistory) {
      if (item.releaseYear != null) {
        itemsByYear[item.releaseYear!] = (itemsByYear[item.releaseYear!] ?? 0) + 1;
      }
    }

    // トップジャンル
    final topGenres = itemsByGenre.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    // トップキャスト
    final castCounts = <String, int>{};
    for (final item in viewingHistory) {
      for (final actor in item.cast) {
        castCounts[actor] = (castCounts[actor] ?? 0) + 1;
      }
    }
    final topCast = castCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    // トップディレクター
    final directorCounts = <String, int>{};
    for (final item in viewingHistory) {
      if (item.director != null) {
        directorCounts[item.director!] = (directorCounts[item.director!] ?? 0) + 1;
      }
    }
    final topDirectors = directorCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    // 平均評価
    final ratingsWithValues = viewingHistory.where((item) => item.rating != null).toList();
    final averageRating = ratingsWithValues.isNotEmpty
        ? ratingsWithValues.fold<double>(0.0, (sum, item) => sum + item.rating!) / ratingsWithValues.length
        : 0.0;

    // 期間の設定
    final actualStartDate = startDate ?? 
        viewingHistory.map((item) => item.watchedAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final actualEndDate = endDate ?? 
        viewingHistory.map((item) => item.watchedAt).reduce((a, b) => a.isAfter(b) ? a : b);

    return NetflixViewingStats(
      totalItems: viewingHistory.length,
      totalWatchTime: totalWatchTime,
      itemsByType: itemsByType,
      timeByType: timeByType,
      itemsByGenre: itemsByGenre,
      timeByGenre: timeByGenre,
      topGenres: topGenres.take(5).map((e) => e.key).toList(),
      topCast: topCast.take(5).map((e) => e.key).toList(),
      topDirectors: topDirectors.take(5).map((e) => e.key).toList(),
      itemsByYear: itemsByYear,
      averageRating: averageRating,
      totalRatings: ratingsWithValues.length,
      periodStart: actualStartDate,
      periodEnd: actualEndDate,
    );
  }

  /// リソースをクリーンアップ
  void dispose() {
    _apiService.dispose();
  }
}
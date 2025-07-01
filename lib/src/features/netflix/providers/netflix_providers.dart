import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/netflix_models.dart';
import '../services/netflix_api_service.dart';
import '../services/netflix_ocr_service.dart';
import '../repositories/netflix_repository.dart';
import '../../auth/providers/user_provider.dart';
import '../../../core/logging/logger.dart';

/// Netflix APIサービスプロバイダー
final netflixApiServiceProvider = Provider<NetflixApiService>((ref) {
  return NetflixApiService(
    logger: ref.read(loggerProvider),
  );
});

/// Netflix OCRサービスプロバイダー
final netflixOcrServiceProvider = Provider<NetflixOcrService>((ref) {
  return NetflixOcrService(
    logger: ref.read(loggerProvider),
  );
});

/// Netflixリポジトリプロバイダー
final netflixRepositoryProvider = Provider<NetflixRepository>((ref) {
  return NetflixRepository(
    apiService: ref.read(netflixApiServiceProvider),
    ocrService: ref.read(netflixOcrServiceProvider),
    logger: ref.read(loggerProvider),
  );
});

/// ユーザーのNetflix視聴履歴プロバイダー
final netflixViewingHistoryProvider = FutureProvider.family<List<NetflixViewingHistory>, String>((ref, userId) async {
  final repository = ref.read(netflixRepositoryProvider);
  return await repository.getViewingHistory(userId: userId);
});

/// Netflix視聴履歴フィルタープロバイダー
final netflixViewingFilterProvider = StateProvider<NetflixViewingFilter>((ref) {
  return const NetflixViewingFilter();
});

/// フィルター済みNetflix視聴履歴プロバイダー
final filteredNetflixViewingHistoryProvider = FutureProvider<List<NetflixViewingHistory>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return [];
  
  final historyAsync = ref.watch(netflixViewingHistoryProvider(user.id));
  final filter = ref.watch(netflixViewingFilterProvider);
  
  return historyAsync.when(
    data: (history) => _applyFilter(history, filter),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Netflix視聴統計プロバイダー
final netflixViewingStatsProvider = FutureProvider<NetflixViewingStats?>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return null;
  
  final historyAsync = ref.watch(netflixViewingHistoryProvider(user.id));
  
  return historyAsync.when(
    data: (history) => _calculateStats(history),
    loading: () => null,
    error: (_, __) => null,
  );
});

/// コンテンツタイプ別視聴データプロバイダー
final netflixViewingByContentTypeProvider = FutureProvider<Map<NetflixContentType, List<NetflixViewingHistory>>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return {};
  
  final historyAsync = ref.watch(netflixViewingHistoryProvider(user.id));
  
  return historyAsync.when(
    data: (history) => _groupByContentType(history),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// ジャンル別視聴データプロバイダー
final netflixViewingByGenreProvider = FutureProvider<Map<String, List<NetflixViewingHistory>>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return {};
  
  final historyAsync = ref.watch(netflixViewingHistoryProvider(user.id));
  
  return historyAsync.when(
    data: (history) => _groupByGenre(history),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Netflix視聴履歴の読み込み状態プロバイダー
final netflixViewingLoadingProvider = StateProvider<bool>((ref) => false);

/// Netflix視聴履歴エラー状態プロバイダー
final netflixViewingErrorProvider = StateProvider<String?>((ref) => null);

/// OCR解析結果プロバイダー
final netflixOcrResultProvider = StateProvider<List<NetflixViewingHistory>?>((ref) => null);

/// OCR解析進行状態プロバイダー
final netflixOcrProgressProvider = StateProvider<double>((ref) => 0.0);

/// Netflix視聴履歴アクションプロバイダー
final netflixViewingActionProvider = Provider<NetflixViewingActions>((ref) {
  return NetflixViewingActions(ref);
});

/// Netflix視聴履歴アクションクラス
class NetflixViewingActions {
  final ProviderRef ref;
  
  NetflixViewingActions(this.ref);

  /// 視聴履歴を更新
  Future<void> refreshViewingHistory() async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(netflixViewingLoadingProvider.notifier).state = true;
    ref.read(netflixViewingErrorProvider.notifier).state = null;

    try {
      ref.invalidate(netflixViewingHistoryProvider(user.id));
      await ref.read(netflixViewingHistoryProvider(user.id).future);
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(netflixViewingLoadingProvider.notifier).state = false;
    }
  }

  /// OCR解析を実行
  Future<void> analyzeViewingImage({
    required String imagePath,
    required String sourceType,
  }) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(netflixViewingLoadingProvider.notifier).state = true;
    ref.read(netflixViewingErrorProvider.notifier).state = null;
    ref.read(netflixOcrProgressProvider.notifier).state = 0.1;

    try {
      final repository = ref.read(netflixRepositoryProvider);
      
      ref.read(netflixOcrProgressProvider.notifier).state = 0.5;
      
      final viewingHistory = await repository.analyzeViewingImageFromPath(
        userId: user.id,
        imagePath: imagePath,
        sourceType: sourceType,
      );
      
      ref.read(netflixOcrProgressProvider.notifier).state = 0.8;
      
      // OCR結果を保存
      if (viewingHistory.isNotEmpty) {
        await repository.saveViewingHistory(viewingHistory);
        ref.read(netflixOcrResultProvider.notifier).state = viewingHistory;
        
        // 視聴履歴を更新
        ref.invalidate(netflixViewingHistoryProvider(user.id));
      }
      
      ref.read(netflixOcrProgressProvider.notifier).state = 1.0;
      
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(netflixViewingLoadingProvider.notifier).state = false;
      
      // 2秒後にプログレスをリセット
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(netflixOcrProgressProvider.notifier).state = 0.0;
      });
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<void> analyzeImageFromGallery({
    required String sourceType,
  }) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(netflixViewingLoadingProvider.notifier).state = true;
    ref.read(netflixViewingErrorProvider.notifier).state = null;

    try {
      final repository = ref.read(netflixRepositoryProvider);
      final viewingHistory = await repository.analyzeImageFromGallery(
        userId: user.id,
        sourceType: sourceType,
      );
      
      if (viewingHistory.isNotEmpty) {
        await repository.saveViewingHistory(viewingHistory);
        ref.read(netflixOcrResultProvider.notifier).state = viewingHistory;
        
        // 視聴履歴を更新
        ref.invalidate(netflixViewingHistoryProvider(user.id));
      }
      
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(netflixViewingLoadingProvider.notifier).state = false;
    }
  }

  /// 手動で視聴履歴を追加
  Future<void> addManualViewingHistory({
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
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(netflixViewingLoadingProvider.notifier).state = true;
    ref.read(netflixViewingErrorProvider.notifier).state = null;

    try {
      final repository = ref.read(netflixRepositoryProvider);
      final viewingHistory = await repository.addManualViewingHistory(
        userId: user.id,
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
      
      await repository.saveViewingHistory([viewingHistory]);
      
      // 視聴履歴を更新
      ref.invalidate(netflixViewingHistoryProvider(user.id));
      
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(netflixViewingLoadingProvider.notifier).state = false;
    }
  }

  /// フィルターを更新
  void updateFilter(NetflixViewingFilter filter) {
    ref.read(netflixViewingFilterProvider.notifier).state = filter;
  }

  /// フィルターをリセット
  void resetFilter() {
    ref.read(netflixViewingFilterProvider.notifier).state = const NetflixViewingFilter();
  }

  /// 視聴データを削除
  Future<void> deleteViewingHistory(String historyId) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final repository = ref.read(netflixRepositoryProvider);
      await repository.deleteViewingHistory(historyId);
      
      // 視聴履歴を更新
      ref.invalidate(netflixViewingHistoryProvider(user.id));
      
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    }
  }

  /// 視聴データを編集
  Future<void> updateViewingHistory(NetflixViewingHistory viewingHistory) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final repository = ref.read(netflixRepositoryProvider);
      await repository.updateViewingHistory(viewingHistory);
      
      // 視聴履歴を更新
      ref.invalidate(netflixViewingHistoryProvider(user.id));
      
    } catch (e) {
      ref.read(netflixViewingErrorProvider.notifier).state = e.toString();
    }
  }

  /// エラーをクリア
  void clearError() {
    ref.read(netflixViewingErrorProvider.notifier).state = null;
  }

  /// OCR結果をクリア
  void clearOcrResult() {
    ref.read(netflixOcrResultProvider.notifier).state = null;
  }
}

/// Loggerプロバイダー（他の場所で定義されていない場合）
final loggerProvider = Provider<Logger>((ref) => Logger());

/// フィルターを適用
List<NetflixViewingHistory> _applyFilter(List<NetflixViewingHistory> history, NetflixViewingFilter filter) {
  return history.where((item) {
    // 日付フィルター
    if (filter.startDate != null && item.watchedAt.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && item.watchedAt.isAfter(filter.endDate!)) {
      return false;
    }
    
    // コンテンツタイプフィルター
    if (filter.contentTypes != null && !filter.contentTypes!.contains(item.contentType)) {
      return false;
    }
    
    // ジャンルフィルター
    if (filter.genres != null) {
      final hasMatchingGenre = filter.genres!.any((genre) => item.genres.contains(genre));
      if (!hasMatchingGenre) {
        return false;
      }
    }
    
    // 視聴状態フィルター
    if (filter.watchStatuses != null && !filter.watchStatuses!.contains(item.watchStatus)) {
      return false;
    }
    
    // 評価フィルター
    if (filter.minRating != null && (item.rating == null || item.rating! < filter.minRating!)) {
      return false;
    }
    if (filter.maxRating != null && (item.rating == null || item.rating! > filter.maxRating!)) {
      return false;
    }
    
    // 公開年フィルター
    if (filter.releaseYearStart != null && (item.releaseYear == null || item.releaseYear! < filter.releaseYearStart!)) {
      return false;
    }
    if (filter.releaseYearEnd != null && (item.releaseYear == null || item.releaseYear! > filter.releaseYearEnd!)) {
      return false;
    }
    
    // 検索クエリフィルター
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      if (!item.title.toLowerCase().contains(query) &&
          (item.subtitle?.toLowerCase().contains(query) != true) &&
          !item.genres.any((genre) => genre.toLowerCase().contains(query))) {
        return false;
      }
    }
    
    return true;
  }).toList();
}

/// 統計を計算
NetflixViewingStats _calculateStats(List<NetflixViewingHistory> history) {
  if (history.isEmpty) {
    return NetflixViewingStats(
      totalItems: 0,
      totalWatchTime: Duration.zero,
      itemsByType: const {},
      timeByType: const {},
      itemsByGenre: const {},
      timeByGenre: const {},
      topGenres: const [],
      topCast: const [],
      topDirectors: const [],
      itemsByYear: const {},
      averageRating: 0.0,
      totalRatings: 0,
      periodStart: DateTime.now(),
      periodEnd: DateTime.now(),
    );
  }

  // 総視聴時間
  final totalWatchTime = history.fold<Duration>(
    Duration.zero, 
    (sum, item) => sum + (item.watchDuration ?? Duration.zero),
  );

  // タイプ別集計
  final itemsByType = <NetflixContentType, int>{};
  final timeByType = <NetflixContentType, Duration>{};
  
  for (final item in history) {
    itemsByType[item.contentType] = (itemsByType[item.contentType] ?? 0) + 1;
    timeByType[item.contentType] = (timeByType[item.contentType] ?? Duration.zero) + (item.watchDuration ?? Duration.zero);
  }

  // ジャンル別集計
  final itemsByGenre = <String, int>{};
  final timeByGenre = <String, Duration>{};
  
  for (final item in history) {
    for (final genre in item.genres) {
      itemsByGenre[genre] = (itemsByGenre[genre] ?? 0) + 1;
      timeByGenre[genre] = (timeByGenre[genre] ?? Duration.zero) + (item.watchDuration ?? Duration.zero);
    }
  }

  // 年別集計
  final itemsByYear = <int, int>{};
  for (final item in history) {
    if (item.releaseYear != null) {
      itemsByYear[item.releaseYear!] = (itemsByYear[item.releaseYear!] ?? 0) + 1;
    }
  }

  // トップジャンル
  final topGenres = itemsByGenre.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

  // トップキャスト
  final castCounts = <String, int>{};
  for (final item in history) {
    for (final actor in item.cast) {
      castCounts[actor] = (castCounts[actor] ?? 0) + 1;
    }
  }
  final topCast = castCounts.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

  // トップディレクター
  final directorCounts = <String, int>{};
  for (final item in history) {
    if (item.director != null) {
      directorCounts[item.director!] = (directorCounts[item.director!] ?? 0) + 1;
    }
  }
  final topDirectors = directorCounts.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

  // 平均評価
  final ratingsWithValues = history.where((item) => item.rating != null).toList();
  final averageRating = ratingsWithValues.isNotEmpty
      ? ratingsWithValues.fold<double>(0.0, (sum, item) => sum + item.rating!) / ratingsWithValues.length
      : 0.0;

  return NetflixViewingStats(
    totalItems: history.length,
    totalWatchTime: totalWatchTime,
    itemsByType: itemsByType,
    timeByType: timeByType,
    itemsByGenre: itemsByGenre,
    timeByGenre: timeByGenre,
    topGenres: topGenres.map((e) => e.key).toList(),
    topCast: topCast.map((e) => e.key).toList(),
    topDirectors: topDirectors.map((e) => e.key).toList(),
    itemsByYear: itemsByYear,
    averageRating: averageRating,
    totalRatings: ratingsWithValues.length,
    periodStart: history.map((item) => item.watchedAt).reduce((a, b) => a.isBefore(b) ? a : b),
    periodEnd: history.map((item) => item.watchedAt).reduce((a, b) => a.isAfter(b) ? a : b),
  );
}

/// コンテンツタイプ別にグループ化
Map<NetflixContentType, List<NetflixViewingHistory>> _groupByContentType(List<NetflixViewingHistory> history) {
  final grouped = <NetflixContentType, List<NetflixViewingHistory>>{};
  
  for (final item in history) {
    grouped[item.contentType] ??= [];
    grouped[item.contentType]!.add(item);
  }
  
  return grouped;
}

/// ジャンル別にグループ化
Map<String, List<NetflixViewingHistory>> _groupByGenre(List<NetflixViewingHistory> history) {
  final grouped = <String, List<NetflixViewingHistory>>{};
  
  for (final item in history) {
    for (final genre in item.genres) {
      grouped[genre] ??= [];
      grouped[genre]!.add(item);
    }
  }
  
  return grouped;
}
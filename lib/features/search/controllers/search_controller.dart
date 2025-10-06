import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/core/error/app_error.dart';
import '../data/search_repository.dart';
import '../providers/search_providers.dart';

/// 検索コントローラークラス
/// UIと検索ロジックを分離し、状態管理を行う
class SearchController extends StateNotifier<AsyncValue<List<SearchItem>>> {
  final SearchRepository _repository;
  final StateNotifierProviderRef<SearchController, AsyncValue<List<SearchItem>>> _ref;

  SearchController(this._repository, this._ref) : super(const AsyncValue.data([]));

  /// 検索を実行
  Future<void> search({String? query, String mode = 'full'}) async {
    // 空のクエリの場合は結果をクリア
    if (query == null || query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _ref.read(searchQueryProvider.notifier).state = '';
      return;
    }

    // 検索中の状態を設定
    state = const AsyncValue.loading();
    _ref.read(isSearchingProvider.notifier).state = true;
    _ref.read(searchQueryProvider.notifier).state = query;
    _ref.read(searchModeProvider.notifier).state = mode;

    try {
      // 検索実行（1.5秒でタイムアウト）
      final stopwatch = Stopwatch()..start();
      
      final results = await _repository.search(query: query, mode: mode)
          .timeout(const Duration(milliseconds: 1500));
      
      stopwatch.stop();
      
      // 検索履歴に追加
      await _addToSearchHistory(query);
      
      // 結果を設定
      state = AsyncValue.data(results);
      _ref.read(searchResultsProvider.notifier).state = results;
      
      // パフォーマンステレメトリ（1.5秒超過時）
      if (stopwatch.elapsedMilliseconds > 1500) {
        _sendPerformanceTelemetry(
          query: query,
          mode: mode,
          duration: stopwatch.elapsedMilliseconds,
          resultCount: results.length,
        );
      }
      
    } catch (e) {
      // エラー状態を設定
      state = AsyncValue.error(e, StackTrace.current);
      
      // エラーテレメトリ
      _sendErrorTelemetry(
        query: query,
        mode: mode,
        error: e.toString(),
      );
    } finally {
      _ref.read(isSearchingProvider.notifier).state = false;
    }
  }

  /// 混合検索（fullとtag_onlyの結果を統合）
  Future<void> searchMixed({required String query}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    _ref.read(isSearchingProvider.notifier).state = true;
    _ref.read(searchModeProvider.notifier).state = 'mixed';

    try {
      final stopwatch = Stopwatch()..start();
      
      // 並列で両方の検索を実行
      final results = await Future.wait([
        _repository.search(query: query, mode: 'full'),
        _repository.search(query: query, mode: 'tag_only'),
      ]).timeout(const Duration(milliseconds: 1500));

      final fullResults = results[0];
      final tagOnlyResults = results[1];

      // 結果を統合し、IDによる重複を除去
      final combinedResults = <SearchItem>[];
      final seenIds = <String>{};

      // full検索の結果を優先
      for (final item in fullResults) {
        if (!seenIds.contains(item.id)) {
          combinedResults.add(item);
          seenIds.add(item.id);
        }
      }

      // tag_only検索の結果を追加（重複除外）
      for (final item in tagOnlyResults) {
        if (!seenIds.contains(item.id)) {
          combinedResults.add(item);
          seenIds.add(item.id);
        }
      }

      stopwatch.stop();
      
      await _addToSearchHistory(query);
      
      state = AsyncValue.data(combinedResults);
      _ref.read(searchResultsProvider.notifier).state = combinedResults;

      // パフォーマンステレメトリ
      if (stopwatch.elapsedMilliseconds > 1500) {
        _sendPerformanceTelemetry(
          query: query,
          mode: 'mixed',
          duration: stopwatch.elapsedMilliseconds,
          resultCount: combinedResults.length,
        );
      }

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _sendErrorTelemetry(query: query, mode: 'mixed', error: e.toString());
    } finally {
      _ref.read(isSearchingProvider.notifier).state = false;
    }
  }

  /// タグデータを保存
  Future<void> saveTagOnly(Map<String, dynamic> payload, String userId) async {
    try {
      await _repository.insertTagOnly(payload, userId: userId);
    } catch (e) {
      // エラーログ出力（UIには影響しない）
      print('Tag save error: ${e.toString()}');
    }
  }

  /// 検索結果をクリア
  void clearResults() {
    state = const AsyncValue.data([]);
    _ref.read(searchResultsProvider.notifier).state = [];
    _ref.read(searchQueryProvider.notifier).state = '';
  }

  /// 検索履歴に追加
  Future<void> _addToSearchHistory(String query) async {
    final currentHistory = _ref.read(searchHistoryProvider);
    final newHistory = [query, ...currentHistory.where((q) => q != query)]
        .take(10)
        .toList();
    _ref.read(searchHistoryProvider.notifier).state = newHistory;
  }

  /// パフォーマンステレメトリを送信
  void _sendPerformanceTelemetry({
    required String query,
    required String mode,
    required int duration,
    required int resultCount,
  }) {
    // TODO: 実際のテレメトリサービスに送信
    print('Performance Telemetry: query=${query.length > 4 ? query.substring(0, 4) + "***" : "***"}, '
          'mode=$mode, duration=${duration}ms, results=$resultCount');
  }

  /// エラーテレメトリを送信
  void _sendErrorTelemetry({
    required String query,
    required String mode,
    required String error,
  }) {
    // TODO: 実際のテレメトリサービスに送信
    print('Error Telemetry: query=${query.length > 4 ? query.substring(0, 4) + "***" : "***"}, '
          'mode=$mode, error=${error.substring(0, 50)}...');
  }
}

/// SearchControllerのプロバイダー
final searchControllerProvider = StateNotifierProvider<SearchController, AsyncValue<List<SearchItem>>>((ref) {
  final repository = ref.read(searchRepositoryProvider);
  return SearchController(repository, ref);
});
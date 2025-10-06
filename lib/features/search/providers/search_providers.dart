import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/core/config/supabase_client_provider.dart';
import '../data/search_repository.dart';

/// SearchRepositoryのプロバイダー
/// Supabase実装に接続
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSearchRepository(client);
});

/// 検索結果を管理するStateProvider
final searchResultsProvider = StateProvider<List<SearchItem>>((ref) => []);

/// 検索クエリを管理するStateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 検索モードを管理するStateProvider ('full' | 'tag_only')
final searchModeProvider = StateProvider<String>((ref) => 'full');

/// 検索中の状態を管理するStateProvider
final isSearchingProvider = StateProvider<bool>((ref) => false);

/// 検索履歴を管理するStateProvider
final searchHistoryProvider = StateProvider<List<String>>((ref) => []);

/// 検索を実行するプロバイダー
final searchProvider = FutureProvider.family<List<SearchItem>, Map<String, String>>((ref, params) async {
  final repository = ref.read(searchRepositoryProvider);
  final query = params['query'];
  final mode = params['mode'] ?? 'full';
  
  if (query == null || query.trim().isEmpty) {
    return [];
  }
  
  return await repository.search(query: query, mode: mode);
});

/// タグのみのデータを保存するプロバイダー
final insertTagOnlyProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(searchRepositoryProvider);
  final userId = params['userId'] as String;
  final payload = Map<String, dynamic>.from(params);
  payload.remove('userId'); // userIdをpayloadから除去
  
  return await repository.insertTagOnly(payload, userId: userId);
});

/// 検索結果の混合表示用プロバイダー
/// full検索とtag_only検索の結果を統合し、重複を除去
final mixedSearchProvider = FutureProvider.family<List<SearchItem>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }
  
  final repository = ref.read(searchRepositoryProvider);
  
  // 並列で両方の検索を実行
  final results = await Future.wait([
    repository.search(query: query, mode: 'full'),
    repository.search(query: query, mode: 'tag_only'),
  ]);
  
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
  
  return combinedResults;
});

/// フィルター付き検索プロバイダー
final filteredSearchProvider = FutureProvider.family<List<SearchItem>, Map<String, dynamic>>((ref, filters) async {
  final query = filters['query'] as String? ?? '';
  final mode = filters['mode'] as String? ?? 'full';
  final category = filters['category'] as String?;
  final type = filters['type'] as String?;
  
  if (query.trim().isEmpty) {
    return [];
  }
  
  final repository = ref.read(searchRepositoryProvider);
  var results = await repository.search(query: query, mode: mode);
  
  // カテゴリフィルター
  if (category != null && category.isNotEmpty) {
    results = results.where((item) => item.category == category).toList();
  }
  
  // タイプフィルター
  if (type != null && type.isNotEmpty) {
    results = results.where((item) => item.type == type).toList();
  }
  
  return results;
});
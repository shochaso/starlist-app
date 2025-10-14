import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/data/models/genre_taxonomy.dart';

/// ジャンルタクソノミーのプロバイダー
final genreTaxonomyProvider = Provider<GenreTaxonomyV1>((ref) {
  return DefaultGenreTaxonomy.data;
});

/// 特定カテゴリのジャンルリストを取得するプロバイダー
final categoryGenresProvider = Provider.family<List<Genre>, String>((ref, categoryKey) {
  final taxonomy = ref.watch(genreTaxonomyProvider);
  final category = taxonomy.getCategory(categoryKey);
  return category?.genres ?? [];
});

/// サービス名でジャンルを検索するプロバイダー
final genresByServiceProvider = Provider.family<List<Genre>, String>((ref, serviceName) {
  final taxonomy = ref.watch(genreTaxonomyProvider);
  return taxonomy.getGenresByService(serviceName);
});

/// 全ジャンルのリストを取得するプロバイダー
final allGenresProvider = Provider<List<Genre>>((ref) {
  final taxonomy = ref.watch(genreTaxonomyProvider);
  return taxonomy.getAllGenres();
});

/// ジャンル検索用のプロバイダー（フィルタリング対応）
final genreSearchProvider = StateProvider<String>((ref) => '');

/// フィルタリングされたジャンルリストを取得するプロバイダー
final filteredGenresProvider = Provider<List<Genre>>((ref) {
  final allGenres = ref.watch(allGenresProvider);
  final searchQuery = ref.watch(genreSearchProvider);
  
  if (searchQuery.isEmpty) return allGenres;
  
  return allGenres.where((genre) =>
    genre.label.toLowerCase().contains(searchQuery.toLowerCase()) ||
    genre.slug.toLowerCase().contains(searchQuery.toLowerCase())
  ).toList();
});

/// カテゴリ別のジャンル統計を取得するプロバイダー
final genreStatsProvider = Provider<Map<String, int>>((ref) {
  final taxonomy = ref.watch(genreTaxonomyProvider);
  final stats = <String, int>{};
  
  for (final categoryKey in taxonomy.categories.keys) {
    final category = taxonomy.getCategory(categoryKey);
    if (category != null) {
      stats[categoryKey] = category.genres.length;
    }
  }
  
  return stats;
});



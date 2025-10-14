import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/data/models/genre_taxonomy.dart';
import 'package:starlist_app/features/search/providers/genre_taxonomy_provider.dart';

/// ジャンルフィルターチップウィジェット
class GenreFilterChip extends ConsumerWidget {
  final Genre genre;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? categoryKey;

  const GenreFilterChip({
    super.key,
    required this.genre,
    required this.isSelected,
    this.onTap,
    this.categoryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(
        genre.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap?.call(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected 
          ? theme.colorScheme.primary 
          : theme.colorScheme.outline.withOpacity(0.3),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// カテゴリ別ジャンルフィルターリスト
class CategoryGenreFilterList extends ConsumerWidget {
  final String categoryKey;
  final List<String> selectedGenreSlugs;
  final Function(List<String>) onSelectionChanged;
  final bool showCategoryTitle;

  const CategoryGenreFilterList({
    super.key,
    required this.categoryKey,
    required this.selectedGenreSlugs,
    required this.onSelectionChanged,
    this.showCategoryTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(categoryGenresProvider(categoryKey));
    final taxonomy = ref.watch(genreTaxonomyProvider);
    final category = taxonomy.getCategory(categoryKey);
    
    if (genres.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCategoryTitle && category != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _getCategoryDisplayName(categoryKey),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            final isSelected = selectedGenreSlugs.contains(genre.slug);
            return GenreFilterChip(
              genre: genre,
              isSelected: isSelected,
              onTap: () => _toggleGenre(genre.slug),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleGenre(String genreSlug) {
    final newSelection = List<String>.from(selectedGenreSlugs);
    if (newSelection.contains(genreSlug)) {
      newSelection.remove(genreSlug);
    } else {
      newSelection.add(genreSlug);
    }
    onSelectionChanged(newSelection);
  }

  String _getCategoryDisplayName(String categoryKey) {
    const categoryNames = {
      'video': '動画コンテンツ',
      'shopping': 'ショッピング',
      'food_delivery': 'フードデリバリー',
      'convenience_store': 'コンビニ',
      'music': '音楽',
      'game_play': 'ゲーム',
      'mobile_apps': 'モバイルアプリ',
      'screen_time': 'スクリーンタイム',
      'fashion': 'ファッション',
      'book': '書籍',
    };
    return categoryNames[categoryKey] ?? categoryKey;
  }
}

/// 全ジャンル検索フィルター
class AllGenresFilterList extends ConsumerWidget {
  final List<String> selectedGenreSlugs;
  final Function(List<String>) onSelectionChanged;

  const AllGenresFilterList({
    super.key,
    required this.selectedGenreSlugs,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredGenres = ref.watch(filteredGenresProvider);
    final searchQuery = ref.watch(genreSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 検索フィールド
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            onChanged: (value) {
              ref.read(genreSearchProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'ジャンルを検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // ジャンルチップ
        if (filteredGenres.isEmpty && searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '「$searchQuery」に一致するジャンルが見つかりません',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredGenres.map((genre) {
              final isSelected = selectedGenreSlugs.contains(genre.slug);
              return GenreFilterChip(
                genre: genre,
                isSelected: isSelected,
                onTap: () => _toggleGenre(genre.slug),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _toggleGenre(String genreSlug) {
    final newSelection = List<String>.from(selectedGenreSlugs);
    if (newSelection.contains(genreSlug)) {
      newSelection.remove(genreSlug);
    } else {
      newSelection.add(genreSlug);
    }
    onSelectionChanged(newSelection);
  }
}



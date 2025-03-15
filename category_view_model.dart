import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../content/domain/services/content_service.dart';

/// カテゴリビューモデルクラス
class CategoryViewModel extends StateNotifier<CategoryViewState> {
  /// コンテンツサービス
  final ContentService _contentService;

  /// コンストラクタ
  CategoryViewModel(this._contentService) : super(CategoryViewState.initial());

  /// カテゴリ一覧を読み込む
  void loadCategories() {
    // カテゴリ一覧は静的なデータなので、ここで直接設定
    state = state.copyWith(
      categories: [
        CategoryItem(
          type: ContentType.youtube,
          name: _contentService.getContentTypeName(ContentType.youtube),
          icon: _contentService.getContentTypeIcon(ContentType.youtube),
          color: _contentService.getContentTypeColor(ContentType.youtube),
        ),
        CategoryItem(
          type: ContentType.spotify,
          name: _contentService.getContentTypeName(ContentType.spotify),
          icon: _contentService.getContentTypeIcon(ContentType.spotify),
          color: _contentService.getContentTypeColor(ContentType.spotify),
        ),
        CategoryItem(
          type: ContentType.netflix,
          name: _contentService.getContentTypeName(ContentType.netflix),
          icon: _contentService.getContentTypeIcon(ContentType.netflix),
          color: _contentService.getContentTypeColor(ContentType.netflix),
        ),
        CategoryItem(
          type: ContentType.book,
          name: _contentService.getContentTypeName(ContentType.book),
          icon: _contentService.getContentTypeIcon(ContentType.book),
          color: _contentService.getContentTypeColor(ContentType.book),
        ),
        CategoryItem(
          type: ContentType.shopping,
          name: _contentService.getContentTypeName(ContentType.shopping),
          icon: _contentService.getContentTypeIcon(ContentType.shopping),
          color: _contentService.getContentTypeColor(ContentType.shopping),
        ),
        CategoryItem(
          type: ContentType.app,
          name: _contentService.getContentTypeName(ContentType.app),
          icon: _contentService.getContentTypeIcon(ContentType.app),
          color: _contentService.getContentTypeColor(ContentType.app),
        ),
        CategoryItem(
          type: ContentType.food,
          name: _contentService.getContentTypeName(ContentType.food),
          icon: _contentService.getContentTypeIcon(ContentType.food),
          color: _contentService.getContentTypeColor(ContentType.food),
        ),
      ],
      isLoading: false,
    );
  }

  /// カテゴリ別のトレンドコンテンツを読み込む
  Future<void> loadCategoryTrends(ContentType type) async {
    try {
      state = state.copyWith(
        isLoadingTrends: true,
        selectedCategory: type,
        error: null,
      );

      final trends = await _contentService.getTrendingContent(
        contentType: type,
        limit: 5,
      );

      state = state.copyWith(
        trendingContents: trends,
        isLoadingTrends: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingTrends: false,
        error: e.toString(),
      );
    }
  }

  /// カテゴリを選択
  void selectCategory(ContentType type) {
    if (state.selectedCategory == type) return;
    
    loadCategoryTrends(type);
  }
}

/// カテゴリビュー状態クラス
class CategoryViewState {
  /// カテゴリ一覧
  final List<CategoryItem> categories;
  
  /// 選択中のカテゴリ
  final ContentType? selectedCategory;
  
  /// トレンドコンテンツ
  final List<ContentConsumptionModel> trendingContents;
  
  /// 読み込み中かどうか
  final bool isLoading;
  
  /// トレンド読み込み中かどうか
  final bool isLoadingTrends;
  
  /// エラーメッセージ
  final String? error;

  /// コンストラクタ
  const CategoryViewState({
    required this.categories,
    this.selectedCategory,
    required this.trendingContents,
    required this.isLoading,
    required this.isLoadingTrends,
    this.error,
  });

  /// 初期状態を作成
  factory CategoryViewState.initial() {
    return const CategoryViewState(
      categories: [],
      selectedCategory: null,
      trendingContents: [],
      isLoading: true,
      isLoadingTrends: false,
      error: null,
    );
  }

  /// 新しい状態をコピーして作成
  CategoryViewState copyWith({
    List<CategoryItem>? categories,
    ContentType? selectedCategory,
    List<ContentConsumptionModel>? trendingContents,
    bool? isLoading,
    bool? isLoadingTrends,
    String? error,
  }) {
    return CategoryViewState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      trendingContents: trendingContents ?? this.trendingContents,
      isLoading: isLoading ?? this.isLoading,
      isLoadingTrends: isLoadingTrends ?? this.isLoadingTrends,
      error: error,
    );
  }
}

/// カテゴリアイテムクラス
class CategoryItem {
  /// コンテンツタイプ
  final ContentType type;
  
  /// カテゴリ名
  final String name;
  
  /// アイコン
  final IconData icon;
  
  /// 色
  final Color color;

  /// コンストラクタ
  const CategoryItem({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// カテゴリビューモデルプロバイダー
final categoryViewModelProvider = StateNotifierProvider<CategoryViewModel, CategoryViewState>((ref) {
  final contentService = ref.watch(contentServiceProvider);
  return CategoryViewModel(contentService);
});

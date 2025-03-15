import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/category_view_model.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../shared/widgets/content_item_card.dart';
import '../../../../shared/widgets/app_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../content/presentation/screens/content_feed_screen.dart';

/// カテゴリビュー画面
class CategoryViewScreen extends ConsumerStatefulWidget {
  /// コンストラクタ
  const CategoryViewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends ConsumerState<CategoryViewScreen> {
  @override
  void initState() {
    super.initState();
    
    // 初期データの読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(categoryViewModelProvider.notifier);
      viewModel.loadCategories();
      
      // 最初のカテゴリを選択
      final state = ref.read(categoryViewModelProvider);
      if (state.categories.isNotEmpty) {
        viewModel.selectCategory(state.categories.first.type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリ'),
      ),
      body: state.isLoading
          ? const Center(child: LoadingIndicator())
          : _buildContent(state),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// コンテンツを構築
  Widget _buildContent(CategoryViewState state) {
    if (state.categories.isEmpty) {
      return const Center(
        child: Text('カテゴリがありません'),
      );
    }
    
    return Column(
      children: [
        // カテゴリグリッド
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = state.selectedCategory == category.type;
              
              return _buildCategoryCard(
                category: category,
                isSelected: isSelected,
                onTap: () {
                  final viewModel = ref.read(categoryViewModelProvider.notifier);
                  viewModel.selectCategory(category.type);
                },
              );
            },
          ),
        ),
        
        // トレンドコンテンツ
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.selectedCategory != null
                          ? '${_getCategoryName(state)}のトレンド'
                          : 'トレンド',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (state.selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          // カテゴリ別コンテンツフィード画面に遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContentFeedScreen(
                                userId: 'current_user_id', // 実際のアプリでは現在のユーザーIDを使用
                                contentType: state.selectedCategory,
                                feedType: FeedType.category,
                              ),
                            ),
                          );
                        },
                        child: const Text('もっと見る'),
                      ),
                  ],
                ),
              ),
              
              Expanded(
                child: state.isLoadingTrends
                    ? const Center(child: LoadingIndicator())
                    : state.error != null
                        ? Center(
                            child: ErrorMessage(
                              message: state.error!,
                              retryText: '再試行',
                              onRetry: () {
                                if (state.selectedCategory != null) {
                                  final viewModel = ref.read(categoryViewModelProvider.notifier);
                                  viewModel.loadCategoryTrends(state.selectedCategory!);
                                }
                              },
                            ),
                          )
                        : state.trendingContents.isEmpty
                            ? Center(
                                child: Text(
                                  'トレンドコンテンツはまだありません',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.trendingContents.length,
                                itemBuilder: (context, index) {
                                  final content = state.trendingContents[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ContentItemCard(
                                      content: content,
                                      onTap: () {
                                        // コンテンツ詳細画面に遷移
                                        // TODO: コンテンツ詳細画面に遷移する処理を実装
                                      },
                                      onLike: () {
                                        // いいね処理
                                        // TODO: いいね処理を実装
                                      },
                                      onComment: () {
                                        // コメント処理
                                        // TODO: コメント処理を実装
                                      },
                                      onShare: () {
                                        // 共有処理
                                        // TODO: 共有処理を実装
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// カテゴリカードを構築
  Widget _buildCategoryCard({
    required CategoryItem category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: category.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      category.color.withOpacity(0.1),
                      category.color.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 32,
                color: category.color,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? category.color : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ボトムナビゲーションを構築
  Widget _buildBottomNavigation() {
    return AppNavigation(
      currentIndex: 1, // カテゴリタブ
      onIndexChanged: _onNavigationIndexChanged,
      items: const [
        NavigationItem(
          label: 'ホーム',
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
        ),
        NavigationItem(
          label: 'カテゴリ',
          icon: Icons.category_outlined,
          activeIcon: Icons.category,
        ),
        NavigationItem(
          label: '検索',
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
        ),
        NavigationItem(
          label: 'プロフィール',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
        ),
      ],
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    );
  }

  /// ナビゲーションインデックスが変更されたときのハンドラ
  void _onNavigationIndexChanged(int index) {
    // 実際のアプリでは画面遷移の処理を実装
    // TODO: 画面遷移の処理を実装
  }

  /// 選択中のカテゴリ名を取得
  String _getCategoryName(CategoryViewState state) {
    if (state.selectedCategory == null) return '';
    
    final selectedCategory = state.categories.firstWhere(
      (category) => category.type == state.selectedCategory,
      orElse: () => CategoryItem(
        type: ContentType.youtube,
        name: 'カテゴリ',
        icon: Icons.category,
        color: Colors.grey,
      ),
    );
    
    return selectedCategory.name;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/content_feed_view_model.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../shared/widgets/content_item_card.dart';
import '../../../../shared/widgets/app_navigation.dart';
import '../../../../core/theme/app_colors.dart';

/// コンテンツフィード画面
class ContentFeedScreen extends ConsumerStatefulWidget {
  /// ユーザーID
  final String userId;
  
  /// コンテンツタイプ
  final ContentType? contentType;
  
  /// フィードタイプ
  final FeedType feedType;

  /// コンストラクタ
  const ContentFeedScreen({
    Key? key,
    required this.userId,
    this.contentType,
    this.feedType = FeedType.userFeed,
  }) : super(key: key);

  @override
  ConsumerState<ContentFeedScreen> createState() => _ContentFeedScreenState();
}

class _ContentFeedScreenState extends ConsumerState<ContentFeedScreen> {
  final _scrollController = ScrollController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  
  // カテゴリリスト
  final List<ContentType> _categories = [
    ContentType.youtube,
    ContentType.spotify,
    ContentType.netflix,
    ContentType.book,
    ContentType.shopping,
    ContentType.app,
    ContentType.food,
  ];

  @override
  void initState() {
    super.initState();
    
    // スクロールイベントのリスナーを追加
    _scrollController.addListener(_onScroll);
    
    // 初期データの読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 初期データを読み込む
  void _loadInitialData() {
    final viewModel = ref.read(contentFeedViewModelProvider.notifier);
    
    switch (widget.feedType) {
      case FeedType.userFeed:
        viewModel.loadContentFeed(userId: widget.userId, refresh: true);
        break;
      case FeedType.category:
        if (widget.contentType != null) {
          viewModel.loadCategoryContent(contentType: widget.contentType!, refresh: true);
        }
        break;
      case FeedType.trending:
        viewModel.loadTrendingContent(contentType: widget.contentType, refresh: true);
        break;
      case FeedType.search:
        // 検索は初期状態では何も読み込まない
        break;
    }
  }

  /// スクロールイベントのハンドラ
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// 追加データを読み込む
  void _loadMoreData() {
    final state = ref.read(contentFeedViewModelProvider);
    if (state.isLoading || !state.hasMore) return;
    
    final viewModel = ref.read(contentFeedViewModelProvider.notifier);
    
    switch (widget.feedType) {
      case FeedType.userFeed:
        viewModel.loadContentFeed(userId: widget.userId);
        break;
      case FeedType.category:
        if (widget.contentType != null) {
          viewModel.loadCategoryContent(contentType: widget.contentType!);
        } else if (_selectedCategoryIndex < _categories.length) {
          viewModel.loadCategoryContent(contentType: _categories[_selectedCategoryIndex]);
        }
        break;
      case FeedType.trending:
        viewModel.loadTrendingContent(contentType: widget.contentType);
        break;
      case FeedType.search:
        if (_searchQuery.isNotEmpty) {
          viewModel.searchContent(query: _searchQuery, contentType: widget.contentType);
        }
        break;
    }
  }

  /// 検索を実行
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isNotEmpty) {
      final viewModel = ref.read(contentFeedViewModelProvider.notifier);
      viewModel.searchContent(query: query, contentType: widget.contentType, refresh: true);
    }
  }

  /// カテゴリを選択
  void _selectCategory(int index) {
    if (_selectedCategoryIndex == index) return;
    
    setState(() {
      _selectedCategoryIndex = index;
    });
    
    if (index < _categories.length) {
      final viewModel = ref.read(contentFeedViewModelProvider.notifier);
      viewModel.loadCategoryContent(contentType: _categories[index], refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentFeedViewModelProvider);
    final contentService = ref.watch(contentServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          if (widget.feedType == FeedType.search)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // 検索ダイアログを表示
                showSearch(
                  context: context,
                  delegate: ContentSearchDelegate(
                    onSearch: _performSearch,
                    contentType: widget.contentType,
                    contentService: contentService,
                  ),
                );
              },
            ),
        ],
        bottom: widget.feedType == FeedType.category ? _buildCategoryTabs() : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // プルダウンでリフレッシュ
          _loadInitialData();
        },
        child: _buildContent(state),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// アプリバータイトルを構築
  Widget _buildAppBarTitle() {
    switch (widget.feedType) {
      case FeedType.userFeed:
        return const Text('フィード');
      case FeedType.category:
        return const Text('カテゴリ');
      case FeedType.trending:
        return const Text('人気');
      case FeedType.search:
        return const Text('検索');
    }
  }

  /// カテゴリタブを構築
  PreferredSizeWidget _buildCategoryTabs() {
    final contentService = ref.watch(contentServiceProvider);
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_categories.length, (index) {
            final category = _categories[index];
            final isSelected = _selectedCategoryIndex == index;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(contentService.getContentTypeName(category)),
                selected: isSelected,
                onSelected: (_) => _selectCategory(index),
                backgroundColor: Colors.grey[200],
                selectedColor: contentService.getContentTypeColor(category).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected 
                      ? contentService.getContentTypeColor(category)
                      : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: Icon(
                  contentService.getContentTypeIcon(category),
                  size: 16,
                  color: isSelected 
                      ? contentService.getContentTypeColor(category)
                      : Colors.grey[700],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// コンテンツを構築
  Widget _buildContent(ContentFeedState state) {
    if (state.isLoading && state.contents.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }
    
    if (state.error != null && state.contents.isEmpty) {
      return Center(
        child: ErrorMessage(
          message: state.error!,
          retryText: '再試行',
          onRetry: _loadInitialData,
        ),
      );
    }
    
    if (state.contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.contents.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.contents.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingIndicator(size: 24),
            ),
          );
        }
        
        final content = state.contents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ContentItemCard(
            content: content,
            onTap: () {
              // コンテンツ詳細画面に遷移
              // TODO: コンテンツ詳細画面に遷移する処理を実装
            },
            onLike: () {
              final viewModel = ref.read(contentFeedViewModelProvider.notifier);
              if (content.isLiked) {
                viewModel.unlikeContent(content.id);
              } else {
                viewModel.likeContent(content.id);
              }
            },
            onComment: () {
              // コメント入力ダイアログを表示
              _showCommentDialog(content.id);
            },
            onShare: () {
              final viewModel = ref.read(contentFeedViewModelProvider.notifier);
              viewModel.shareContent(content.id);
            },
          ),
        );
      },
    );
  }

  /// 空の場合のメッセージを取得
  String _getEmptyMessage() {
    switch (widget.feedType) {
      case FeedType.userFeed:
        return 'フィードにはまだコンテンツがありません';
      case FeedType.category:
        if (_selectedCategoryIndex < _categories.length) {
          final contentService = ref.watch(contentServiceProvider);
          final categoryName = contentService.getContentTypeName(_categories[_selectedCategoryIndex]);
          return '$categoryNameにはまだコンテンツがありません';
        }
        return 'このカテゴリにはまだコンテンツがありません';
      case FeedType.trending:
        return '人気コンテンツはまだありません';
      case FeedType.search:
        return _searchQuery.isEmpty
            ? '検索キーワードを入力してください'
            : '「$_searchQuery」に一致するコンテンツは見つかりませんでした';
    }
  }

  /// コメント入力ダイアログを表示
  void _showCommentDialog(String contentId) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('コメントを追加'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: 'コメントを入力してください',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.trim().isNotEmpty) {
                  final viewModel = ref.read(contentFeedViewModelProvider.notifier);
                  viewModel.commentOnContent(contentId, commentController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('送信'),
            ),
          ],
        );
      },
    );
  }

  /// ボトムナビゲーションを構築
  Widget _buildBottomNavigation() {
    return AppNavigation(
      currentIndex: _getNavigationIndex(),
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

  /// 現在のナビゲーションインデックスを取得
  int _getNavigationIndex() {
    switch (widget.feedType) {
      case FeedType.userFeed:
        return 0;
      case FeedType.category:
        return 1;
      case FeedType.search:
        return 2;
      case FeedType.trending:
        return 0; // トレンディングはホームタブに含める
    }
  }

  /// ナビゲーションインデックスが変更されたときのハンドラ
  void _onNavigationIndexChanged(int index) {
    // 実際のアプリでは画面遷移の処理を実装
    // TODO: 画面遷移の処理を実装
  }
}

/// コンテンツ検索デリゲート
class ContentSearchDelegate extends SearchDelegate<String> {
  /// 検索コールバック
  final Function(String) onSearch;
  
  /// コンテンツタイプ
  final ContentType? contentType;
  
  /// コンテンツサービス
  final ContentService contentService;

  /// コンストラクタ
  ContentSearchDelegate({
    required this.onSearch,
    this.contentType,
    required this.contentService,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      onSearch(query);
      close(context, query);
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              contentType != null
                  ? '${contentService.getContentTypeName(contentType!)}を検索'
                  : 'コンテンツを検索',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // 実際のアプリでは検索候補を表示する処理を実装
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: Text('「$query」を検索'),
          onTap: () {
            onSearch(query);
            close(context, query);
          },
        ),
      ],
    );
  }
}

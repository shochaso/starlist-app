import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/discover_view_model.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../shared/widgets/content_item_card.dart';
import '../../../../shared/widgets/star_profile_card.dart';
import '../../../../shared/widgets/app_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../content/presentation/screens/content_feed_screen.dart';
import '../../../../shared/models/content_consumption_model.dart';

/// 検索・発見画面
class DiscoverScreen extends ConsumerStatefulWidget {
  /// コンストラクタ
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初期データの読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(discoverViewModelProvider.notifier);
      viewModel.loadTrendingContent(refresh: true);
      viewModel.loadPopularStars();
    });
    
    // 検索コントローラーのリスナー
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 検索テキストが変更されたときのハンドラ
  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      
      // 検索実行
      final viewModel = ref.read(discoverViewModelProvider.notifier);
      if (_tabController.index == 0) {
        viewModel.searchContent(query: query);
      } else {
        viewModel.searchStars(query);
      }
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// 検索を実行
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    final viewModel = ref.read(discoverViewModelProvider.notifier);
    viewModel.addSearchHistory(query);
    
    if (_tabController.index == 0) {
      viewModel.searchContent(query: query, refresh: true);
    } else {
      viewModel.searchStars(query);
    }
    
    // キーボードを閉じる
    FocusScope.of(context).unfocus();
  }

  /// 検索履歴アイテムをタップ
  void _onHistoryItemTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  /// 検索履歴アイテムを削除
  void _onHistoryItemDelete(String query) {
    final viewModel = ref.read(discoverViewModelProvider.notifier);
    viewModel.removeSearchHistory(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: _tabController.index == 0 ? 'コンテンツを検索...' : 'スターを検索...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onSubmitted: _performSearch,
              )
            : const Text('検索・発見'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
                _searchFocusNode.requestFocus();
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'コンテンツ'),
            Tab(text: 'スター'),
          ],
          onTap: (_) {
            // タブが変更されたら検索を再実行
            if (_searchController.text.isNotEmpty) {
              _onSearchChanged();
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // コンテンツタブ
          _isSearching
              ? _buildContentSearchResults(state)
              : _buildDiscoverContent(state),
          
          // スタータブ
          _isSearching
              ? _buildStarSearchResults(state)
              : _buildDiscoverStars(state),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// 検索結果（コンテンツ）を構築
  Widget _buildContentSearchResults(DiscoverViewState state) {
    if (state.isLoadingSearch) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.searchError != null) {
      return Center(
        child: ErrorMessage(
          message: state.searchError!,
          retryText: '再試行',
          onRetry: () => _performSearch(_searchController.text),
        ),
      );
    }
    
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory(state);
    }
    
    if (state.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '「${state.currentQuery}」に一致するコンテンツは見つかりませんでした',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final content = state.searchResults[index];
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
    );
  }

  /// 検索結果（スター）を構築
  Widget _buildStarSearchResults(DiscoverViewState state) {
    if (state.isLoadingStarSearch) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.starSearchError != null) {
      return Center(
        child: ErrorMessage(
          message: state.starSearchError!,
          retryText: '再試行',
          onRetry: () => _performSearch(_searchController.text),
        ),
      );
    }
    
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory(state);
    }
    
    if (state.starSearchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '「${_searchController.text}」に一致するスターは見つかりませんでした',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.starSearchResults.length,
      itemBuilder: (context, index) {
        final star = state.starSearchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StarProfileCard(
            user: star,
            onTap: () {
              // スタープロフィール画面に遷移
              // TODO: スタープロフィール画面に遷移する処理を実装
            },
            onFollow: () {
              // フォロー処理
              // TODO: フォロー処理を実装
            },
            onMessage: () {
              // メッセージ処理
              // TODO: メッセージ処理を実装
            },
          ),
        );
      },
    );
  }

  /// 検索履歴を構築
  Widget _buildSearchHistory(DiscoverViewState state) {
    if (state.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '検索履歴はありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '検索履歴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  final viewModel = ref.read(discoverViewModelProvider.notifier);
                  viewModel.clearSearchHistory();
                },
                child: const Text('すべて削除'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.searchHistory.length,
            itemBuilder: (context, index) {
              final query = state.searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _onHistoryItemDelete(query),
                ),
                onTap: () => _onHistoryItemTap(query),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 発見コンテンツを構築
  Widget _buildDiscoverContent(DiscoverViewState state) {
    if (state.isLoadingTrends && state.trendingContents.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.trendingError != null && state.trendingContents.isEmpty) {
      return Center(
        child: ErrorMessage(
          message: state.trendingError!,
          retryText: '再試行',
          onRetry: () {
            final viewModel = ref.read(discoverViewModelProvider.notifier);
            viewModel.loadTrendingContent(refresh: true);
          },
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        final viewModel = ref.read(discoverViewModelProvider.notifier);
        await viewModel.loadTrendingContent(refresh: true);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // トレンドコンテンツセクション
          const Text(
            '人気のコンテンツ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.trendingContents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  '人気のコンテンツはまだありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...state.trendingContents.map((content) => Padding(
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
            )),
          
          // カテゴリセクション
          const SizedBox(height: 24),
          const Text(
            'カテゴリから探す',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  /// 発見スターを構築
  Widget _buildDiscoverStars(DiscoverViewState state) {
    if (state.isLoadingStars && state.popularStars.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.starsError != null && state.popularStars.isEmpty) {
      return Center(
        child: ErrorMessage(
          message: state.starsError!,
          retryText: '再試行',
          onRetry: () {
            final viewModel = ref.read(discoverViewModelProvider.notifier);
            viewModel.loadPopularStars();
          },
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        final viewModel = ref.read(discoverViewModelProvider.notifier);
        await viewModel.loadPopularStars();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 人気のスターセクション
          const Text(
            '人気のスター',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.popularStars.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  '人気のスターはまだいません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...state.popularStars.map((star) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StarProfileCard(
                user: star,
                onTap: () {
                  // スタープロフィール画面に遷移
                  // TODO: スタープロフィール画面に遷移する処理を実装
                },
                onFollow: () {
                  // フォロー処理
                  // TODO: フォロー処理を実装
                },
                onMessage: () {
                  // メッセージ処理
                  // TODO: メッセージ処理を実装
                },
              ),
            )),
        ],
      ),
    );
  }

  /// カテゴリグリッドを構築
  Widget _buildCategoryGrid() {
    final categories = [
      {
        'name': 'YouTube',
        'icon': Icons.play_circle_filled,
        'color': Colors.red,
        'type': ContentType.youtube,
      },
      {
        'name': '音楽',
        'icon': Icons.music_note,
        'color': Colors.green,
        'type': <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
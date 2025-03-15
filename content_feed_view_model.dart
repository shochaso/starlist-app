import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/content_service.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';
import '../../../../shared/widgets/content_item_card.dart';

/// コンテンツフィードビューモデルクラス
///
/// コンテンツフィード画面のUIロジックを担当します。
class ContentFeedViewModel extends StateNotifier<ContentFeedState> {
  /// コンテンツサービス
  final ContentService _contentService;

  /// コンストラクタ
  ContentFeedViewModel(this._contentService) : super(ContentFeedState.initial());

  /// コンテンツフィードを読み込む
  Future<void> loadContentFeed({
    required String userId,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = ContentFeedState.loading();
      } else if (state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final offset = refresh ? 0 : state.contents.length;
      final contents = await _contentService.getContentFeed(
        userId: userId,
        offset: offset,
      );

      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        state = ContentFeedState(
          contents: [...state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      }
    } catch (e) {
      state = ContentFeedState(
        contents: refresh ? [] : state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// カテゴリ別コンテンツを読み込む
  Future<void> loadCategoryContent({
    required ContentType contentType,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = ContentFeedState.loading();
      } else if (state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final offset = refresh ? 0 : state.contents.length;
      final contents = await _contentService.getCategoryContent(
        contentType: contentType,
        offset: offset,
      );

      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        state = ContentFeedState(
          contents: [...state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      }
    } catch (e) {
      state = ContentFeedState(
        contents: refresh ? [] : state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// 人気コンテンツを読み込む
  Future<void> loadTrendingContent({
    ContentType? contentType,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = ContentFeedState.loading();
      } else if (state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final offset = refresh ? 0 : state.contents.length;
      final contents = await _contentService.getTrendingContent(
        contentType: contentType,
        offset: offset,
      );

      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        state = ContentFeedState(
          contents: [...state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      }
    } catch (e) {
      state = ContentFeedState(
        contents: refresh ? [] : state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// コンテンツを検索
  Future<void> searchContent({
    required String query,
    ContentType? contentType,
    bool refresh = false,
  }) async {
    try {
      // 検索クエリが空の場合は何もしない
      if (query.trim().isEmpty) {
        state = ContentFeedState.initial();
        return;
      }

      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = ContentFeedState.loading();
      } else if (state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final offset = refresh ? 0 : state.contents.length;
      final contents = await _contentService.searchContent(
        query: query,
        contentType: contentType,
        offset: offset,
      );

      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        state = ContentFeedState(
          contents: [...state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= 20, // 20件以上あれば追加読み込み可能
          error: null,
        );
      }
    } catch (e) {
      state = ContentFeedState(
        contents: refresh ? [] : state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// コンテンツにいいねする
  Future<void> likeContent(String contentId) async {
    try {
      await _contentService.likeContent(contentId);
      
      // ステートを更新
      final updatedContents = state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            isLiked: true,
            likeCount: content.likeCount + 1,
          );
        }
        return content;
      }).toList();
      
      state = state.copyWith(contents: updatedContents);
    } catch (e) {
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }

  /// コンテンツのいいねを取り消す
  Future<void> unlikeContent(String contentId) async {
    try {
      await _contentService.unlikeContent(contentId);
      
      // ステートを更新
      final updatedContents = state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            isLiked: false,
            likeCount: content.likeCount - 1,
          );
        }
        return content;
      }).toList();
      
      state = state.copyWith(contents: updatedContents);
    } catch (e) {
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }

  /// コンテンツにコメントする
  Future<void> commentOnContent(String contentId, String comment) async {
    try {
      await _contentService.commentOnContent(contentId, comment);
      
      // ステートを更新
      final updatedContents = state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            commentCount: content.commentCount + 1,
          );
        }
        return content;
      }).toList();
      
      state = state.copyWith(contents: updatedContents);
    } catch (e) {
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }

  /// コンテンツを共有する
  Future<void> shareContent(String contentId) async {
    try {
      await _contentService.shareContent(contentId);
      
      // ステートを更新
      final updatedContents = state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            shareCount: content.shareCount + 1,
          );
        }
        return content;
      }).toList();
      
      state = state.copyWith(contents: updatedContents);
    } catch (e) {
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }
}

/// コンテンツフィード状態クラス
class ContentFeedState {
  /// コンテンツリスト
  final List<ContentConsumptionModel> contents;
  
  /// 読み込み中かどうか
  final bool isLoading;
  
  /// さらにコンテンツがあるかどうか
  final bool hasMore;
  
  /// エラーメッセージ
  final String? error;

  /// コンストラクタ
  const ContentFeedState({
    required this.contents,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  /// 初期状態を作成
  factory ContentFeedState.initial() {
    return const ContentFeedState(
      contents: [],
      isLoading: false,
      hasMore: true,
      error: null,
    );
  }

  /// 読み込み中状態を作成
  factory ContentFeedState.loading() {
    return const ContentFeedState(
      contents: [],
      isLoading: true,
      hasMore: true,
      error: null,
    );
  }

  /// エラー状態を作成
  factory ContentFeedState.error(String message) {
    return ContentFeedState(
      contents: [],
      isLoading: false,
      hasMore: false,
      error: message,
    );
  }

  /// 新しい状態をコピーして作成
  ContentFeedState copyWith({
    List<ContentConsumptionModel>? contents,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ContentFeedState(
      contents: contents ?? this.contents,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// コンテンツフィードビューモデルプロバイダー
final contentFeedViewModelProvider = StateNotifierProvider<ContentFeedViewModel, ContentFeedState>((ref) {
  final contentService = ref.watch(contentServiceProvider);
  return ContentFeedViewModel(contentService);
});

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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // プルダウンでリフレッシュ
          _loadInitialData();
        },
        child: _buildContent(state),
      ),
    );
  }

  /// アプリバータイトルを構築
  Widget _buildAppBarTitle() {
    switch (widget.feedType) {
      case FeedType.userFeed:
        return const Text('フィード');
      case FeedType.category:
        if (widget.contentType != null) {
          final contentService = ref.watch(contentServiceProvider);
          final categoryName = contentService.getContentTypeName(widget.contentType!);
          return Text(categoryName);
        }
        return const Text('カテゴリ');
      case FeedType.trending:
        return const Text('人気');
      case FeedType.search:
        return const Text('検索');
    }
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
          <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
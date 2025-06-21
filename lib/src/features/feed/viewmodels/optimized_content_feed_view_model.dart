import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/logging/logger.dart';
import '../../content/models/content_model.dart';
import '../../content/services/content_service.dart';

/// コンテンツフィードの状態
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
  ContentFeedState({
    required this.contents,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });
  
  /// 初期状態を作成
  factory ContentFeedState.initial() {
    return ContentFeedState(
      contents: [],
      isLoading: false,
      hasMore: false,
      error: null,
    );
  }
  
  /// 読み込み中の状態を作成
  factory ContentFeedState.loading() {
    return ContentFeedState(
      contents: [],
      isLoading: true,
      hasMore: false,
      error: null,
    );
  }
  
  /// 状態をコピーして新しい状態を作成
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
      error: error ?? this.error,
    );
  }
}

/// 最適化されたコンテンツフィードビューモデル
class OptimizedContentFeedViewModel extends ChangeNotifier {
  /// コンテンツサービス
  final ContentService _contentService;
  
  /// キャッシュマネージャー
  final CacheManager _cacheManager;
  
  /// ロガー
  final Logger _logger;
  
  /// 現在の状態
  ContentFeedState _state = ContentFeedState.initial();
  
  /// ページサイズ
  final int _pageSize = 10;
  
  /// 現在のページ
  int _currentPage = 0;
  
  /// 最後のクエリパラメータ
  Map<String, dynamic>? _lastQueryParams;
  
  /// コンストラクタ
  OptimizedContentFeedViewModel(
    this._contentService,
    this._cacheManager,
    this._logger,
  );
  
  /// 現在の状態を取得
  ContentFeedState get state => _state;
  
  /// コンテンツフィードを読み込む
  Future<void> loadContentFeed({
    required String userId,
    bool refresh = false,
  }) async {
    try {
      // クエリパラメータを保存
      _lastQueryParams = {
        'type': 'feed',
        'userId': userId,
      };
      
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        _state = ContentFeedState.loading();
        _currentPage = 0;
        notifyListeners();
      } else if (_state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        _state = _state.copyWith(
          isLoading: true,
          error: null,
        );
        notifyListeners();
      }
      
      // キャッシュキー
      final cacheKey = 'content_feed_${userId}_${_currentPage}';
      
      // キャッシュからデータを取得
      final cachedData = await _cacheManager.get<List<ContentConsumptionModel>>(cacheKey);
      List<ContentConsumptionModel> contents;
      
      if (cachedData != null && !refresh) {
        _logger.info('Using cached content feed data for page $_currentPage');
        contents = cachedData;
      } else {
        _logger.info('Fetching content feed data from API for page $_currentPage');
        contents = await _contentService.getContentFeed(
          userId: userId,
          offset: _currentPage * _pageSize,
          limit: _pageSize,
        );
        
        // データをキャッシュに保存
        await _cacheManager.set(cacheKey, contents, expiry: Duration(minutes: 5));
      }
      
      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        _state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        _state = ContentFeedState(
          contents: [..._state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      }
      
      // ページカウントを更新
      if (contents.length >= _pageSize) {
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to load content feed', e);
      _state = ContentFeedState(
        contents: refresh ? [] : _state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }
  
  /// 次のページを読み込む
  Future<void> loadNextPage() async {
    if (_state.isLoading || !_state.hasMore) {
      return;
    }
    
    if (_lastQueryParams != null) {
      if (_lastQueryParams!['type'] == 'feed') {
        await loadContentFeed(
          userId: _lastQueryParams!['userId'],
          refresh: false,
        );
      } else if (_lastQueryParams!['type'] == 'category') {
        await loadCategoryContent(
          contentType: _lastQueryParams!['contentType'],
          refresh: false,
        );
      } else if (_lastQueryParams!['type'] == 'trending') {
        await loadTrendingContent(
          contentType: _lastQueryParams!['contentType'],
          refresh: false,
        );
      } else if (_lastQueryParams!['type'] == 'search') {
        await searchContent(
          query: _lastQueryParams!['query'],
          contentType: _lastQueryParams!['contentType'],
          refresh: false,
        );
      }
    }
  }
  
  /// カテゴリ別コンテンツを読み込む
  Future<void> loadCategoryContent({
    required ContentType contentType,
    bool refresh = false,
  }) async {
    try {
      // クエリパラメータを保存
      _lastQueryParams = {
        'type': 'category',
        'contentType': contentType,
      };
      
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        _state = ContentFeedState.loading();
        _currentPage = 0;
        notifyListeners();
      } else if (_state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        _state = _state.copyWith(
          isLoading: true,
          error: null,
        );
        notifyListeners();
      }
      
      // キャッシュキー
      final cacheKey = 'category_content_${contentType.toString()}_${_currentPage}';
      
      // キャッシュからデータを取得
      final cachedData = await _cacheManager.get<List<ContentConsumptionModel>>(cacheKey);
      List<ContentConsumptionModel> contents;
      
      if (cachedData != null && !refresh) {
        _logger.info('Using cached category content data for page $_currentPage');
        contents = cachedData;
      } else {
        _logger.info('Fetching category content data from API for page $_currentPage');
        contents = await _contentService.getCategoryContent(
          contentType: contentType,
          offset: _currentPage * _pageSize,
          limit: _pageSize,
        );
        
        // データをキャッシュに保存
        await _cacheManager.set(cacheKey, contents, expiry: Duration(minutes: 5));
      }
      
      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        _state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        _state = ContentFeedState(
          contents: [..._state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      }
      
      // ページカウントを更新
      if (contents.length >= _pageSize) {
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to load category content', e);
      _state = ContentFeedState(
        contents: refresh ? [] : _state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }
  
  /// 人気コンテンツを読み込む
  Future<void> loadTrendingContent({
    ContentType? contentType,
    bool refresh = false,
  }) async {
    try {
      // クエリパラメータを保存
      _lastQueryParams = {
        'type': 'trending',
        'contentType': contentType,
      };
      
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        _state = ContentFeedState.loading();
        _currentPage = 0;
        notifyListeners();
      } else if (_state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        _state = _state.copyWith(
          isLoading: true,
          error: null,
        );
        notifyListeners();
      }
      
      // キャッシュキー
      final cacheKey = 'trending_content_${contentType?.toString() ?? 'all'}_${_currentPage}';
      
      // キャッシュからデータを取得
      final cachedData = await _cacheManager.get<List<ContentConsumptionModel>>(cacheKey);
      List<ContentConsumptionModel> contents;
      
      if (cachedData != null && !refresh) {
        _logger.info('Using cached trending content data for page $_currentPage');
        contents = cachedData;
      } else {
        _logger.info('Fetching trending content data from API for page $_currentPage');
        contents = await _contentService.getTrendingContent(
          contentType: contentType,
          offset: _currentPage * _pageSize,
          limit: _pageSize,
        );
        
        // データをキャッシュに保存（トレンドは短い有効期限）
        await _cacheManager.set(cacheKey, contents, expiry: Duration(minutes: 2));
      }
      
      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        _state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        _state = ContentFeedState(
          contents: [..._state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      }
      
      // ページカウントを更新
      if (contents.length >= _pageSize) {
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to load trending content', e);
      _state = ContentFeedState(
        contents: refresh ? [] : _state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
      notifyListeners();
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
        _state = ContentFeedState.initial();
        notifyListeners();
        return;
      }
      
      // クエリパラメータを保存
      _lastQueryParams = {
        'type': 'search',
        'query': query,
        'contentType': contentType,
      };
      
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        _state = ContentFeedState.loading();
        _currentPage = 0;
        notifyListeners();
      } else if (_state.isLoading) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        _state = _state.copyWith(
          isLoading: true,
          error: null,
        );
        notifyListeners();
      }
      
      // キャッシュキー
      final cacheKey = 'search_content_${query}_${contentType?.toString() ?? 'all'}_${_currentPage}';
      
      // キャッシュからデータを取得
      final cachedData = await _cacheManager.get<List<ContentConsumptionModel>>(cacheKey);
      List<ContentConsumptionModel> contents;
      
      if (cachedData != null && !refresh) {
        _logger.info('Using cached search content data for page $_currentPage');
        contents = cachedData;
      } else {
        _logger.info('Fetching search content data from API for page $_currentPage');
        contents = await _contentService.searchContent(
          query: query,
          contentType: contentType,
          offset: _currentPage * _pageSize,
          limit: _pageSize,
        );
        
        // データをキャッシュに保存
        await _cacheManager.set(cacheKey, contents, expiry: Duration(minutes: 5));
      }
      
      if (refresh) {
        // リフレッシュの場合は新しいコンテンツで置き換え
        _state = ContentFeedState(
          contents: contents,
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      } else {
        // 追加読み込みの場合は既存のコンテンツに追加
        _state = ContentFeedState(
          contents: [..._state.contents, ...contents],
          isLoading: false,
          hasMore: contents.length >= _pageSize,
          error: null,
        );
      }
      
      // ページカウントを更新
      if (contents.length >= _pageSize) {
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to search content', e);
      _state = ContentFeedState(
        contents: refresh ? [] : _state.contents,
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }
  
  /// コンテンツにいいねする
  Future<void> likeContent(String contentId) async {
    try {
      await _contentService.likeContent(contentId);
      
      // ステートを更新
      final updatedContents = _state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            isLiked: true,
            likeCount: content.likeCount + 1,
          );
        }
        return content;
      }).toList();
      
      _state = _state.copyWith(contents: updatedContents);
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to like content', e);
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }
  
  /// コンテンツのいいねを取り消す
  Future<void> unlikeContent(String contentId) async {
    try {
      await _contentService.unlikeContent(contentId);
      
      // ステートを更新
      final updatedContents = _state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            isLiked: false,
            likeCount: content.likeCount - 1,
          );
        }
        return content;
      }).toList();
      
      _state = _state.copyWith(contents: updatedContents);
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to unlike content', e);
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }
  
  /// コンテンツを共有する
  Future<void> shareContent(String contentId) async {
    try {
      await _contentService.shareContent(contentId);
      
      // ステートを更新
      final updatedContents = _state.contents.map((content) {
        if (content.id == contentId) {
          return content.copyWith(
            shareCount: content.shareCount + 1,
          );
        }
        return content;
      }).toList();
      
      _state = _state.copyWith(contents: updatedContents);
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to share content', e);
      // エラーハンドリング
      // ここではUIに通知するだけで、ステートは変更しない
    }
  }
}

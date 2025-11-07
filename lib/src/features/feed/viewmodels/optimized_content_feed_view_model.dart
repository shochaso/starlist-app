import 'package:flutter/foundation.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/logging/logger.dart';
import '../../content/models/content_model.dart';
import '../../content/services/content_service.dart';

/// Lightweight state used by the feed screens while the legacy stack is refactored.
@immutable
class ContentFeedState {
  const ContentFeedState({
    required this.contents,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  final List<ContentModel> contents;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  factory ContentFeedState.initial() => const ContentFeedState(
        contents: <ContentModel>[],
        isLoading: false,
        hasMore: false,
        error: null,
      );

  ContentFeedState copyWith({
    List<ContentModel>? contents,
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

/// Temporary implementation that keeps the feed running while the optimized stack is rebuilt.
class OptimizedContentFeedViewModel extends ChangeNotifier {
  OptimizedContentFeedViewModel(
    this._contentService,
    this._cacheManager,
    this._logger,
  );

  final ContentService _contentService;
  final CacheManager _cacheManager;
  final Logger _logger;

  ContentFeedState _state = ContentFeedState.initial();
  int _currentPage = 1;
  final int _pageSize = 20;

  ContentFeedState get state => _state;

  Future<void> loadContentFeed({
    required String userId,
    bool refresh = false,
  }) async {
    await _loadPage(page: refresh ? 1 : _currentPage, refresh: refresh);
  }

  Future<void> loadNextPage() async {
    if (_state.isLoading || !_state.hasMore) {
      return;
    }
    await _loadPage(page: _currentPage + 1, refresh: false);
  }

  Future<void> refresh(String userId) async {
    await loadContentFeed(userId: userId, refresh: true);
  }

  Future<void> likeContent(String contentId, String userId) async {
    try {
      await _contentService.likeContent(contentId, userId);
    } catch (error, stackTrace) {
      await _logger.error(
        'Failed to like content $contentId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> unlikeContent(String contentId, String userId) async {
    try {
      await _contentService.unlikeContent(contentId, userId);
    } catch (error, stackTrace) {
      await _logger.error(
        'Failed to unlike content $contentId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> shareContent(String contentId, String userId) async {
    try {
      await _contentService.shareContent(contentId, userId);
    } catch (error, stackTrace) {
      await _logger.error(
        'Failed to share content $contentId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _loadPage({required int page, required bool refresh}) async {
    if (_state.isLoading && !refresh) {
      return;
    }

    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final contents =
          await _contentService.getContents(page: page, limit: _pageSize);
      _currentPage = page;

      _state = ContentFeedState(
        contents: refresh ? contents : [..._state.contents, ...contents],
        isLoading: false,
        hasMore: contents.length >= _pageSize,
        error: null,
      );
    } catch (error, stackTrace) {
      await _logger.error(
        'Failed to load content feed page $page',
        error: error,
        stackTrace: stackTrace,
      );
      _state = _state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    } finally {
      notifyListeners();
    }
  }
}

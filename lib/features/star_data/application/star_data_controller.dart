import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/telemetry/star_data_telemetry.dart';
import '../domain/category.dart';
import '../domain/star_data.dart';
import '../domain/visibility.dart';
import '../infrastructure/star_data_repository.dart';
import 'star_data_providers.dart';

final starDataControllerProvider = AutoDisposeAsyncNotifierProviderFamily<
    StarDataController, StarDataState, StarDataControllerArgs>(
  StarDataController.new,
);

class StarDataControllerArgs {
  const StarDataControllerArgs({
    required this.username,
    this.initialCategory,
  });

  final String username;
  final StarDataCategory? initialCategory;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StarDataControllerArgs &&
        other.username == username &&
        other.initialCategory == initialCategory;
  }

  @override
  int get hashCode => Object.hash(username, initialCategory);
}

class StarDataState {
  const StarDataState({
    required this.profile,
    required this.viewerAccess,
    required this.items,
    required this.nextCursor,
    required this.category,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.hasMore,
  });

  final StarProfile profile;
  final StarDataViewerAccess viewerAccess;
  final List<StarData> items;
  final String? nextCursor;
  final StarDataCategory? category;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;

  bool get showDigestOnly => viewerAccess.shouldShowDigestOnly;

  Map<StarDataCategory, int> get categoryDigest => viewerAccess.categoryDigest;

  StarDataState copyWith({
    StarProfile? profile,
    StarDataViewerAccess? viewerAccess,
    List<StarData>? items,
    String? nextCursor,
    StarDataCategory? category,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
  }) {
    return StarDataState(
      profile: profile ?? this.profile,
      viewerAccess: viewerAccess ?? this.viewerAccess,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      category: category ?? this.category,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class StarDataController extends AutoDisposeFamilyAsyncNotifier<StarDataState,
    StarDataControllerArgs> {
  StarDataController() : _paywallReported = false;

  late StarDataControllerArgs _args;
  late StarDataRepository _repository;
  late StarDataTelemetry _telemetry;
  bool _isFetchingMore = false;
  bool _paywallReported;

  @override
  FutureOr<StarDataState> build(StarDataControllerArgs args) async {
    _args = args;
    _repository = ref.watch(starDataRepositoryProvider);
    _telemetry = ref.watch(starDataTelemetryProvider);

    ref.onDispose(() {
      _isFetchingMore = false;
      _paywallReported = false;
    });

    final page = await _repository.fetchStarData(
      username: args.username,
      category: args.initialCategory,
    );

    _recordView(args.initialCategory);
    _recordPaywallUnlockIfNeeded(page);

    return _mapPageToState(page, args.initialCategory);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncLoading();
      try {
        final page = await _repository.fetchStarData(
          username: _args.username,
          category: _args.initialCategory,
        );
        _paywallReported = false;
        _recordView(_args.initialCategory);
        _recordPaywallUnlockIfNeeded(page);
        state = AsyncValue.data(_mapPageToState(page, _args.initialCategory));
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
      return;
    }

    state = AsyncValue.data(current.copyWith(isRefreshing: true));
    try {
      final page = await _repository.fetchStarData(
        username: _args.username,
        category: current.category,
      );

      _paywallReported = false;
      _recordView(current.category);
      _recordPaywallUnlockIfNeeded(page);

      state = AsyncValue.data(_mapPageToState(page, current.category));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> selectCategory(StarDataCategory? category) async {
    final current = state.value;
    if (current == null) return;
    if (current.category == category) return;

    state = AsyncValue.data(
      current.copyWith(
        category: category,
        isRefreshing: true,
      ),
    );

    try {
      final page = await _repository.fetchStarData(
        username: _args.username,
        category: category,
      );
      _paywallReported = false;
      _recordView(category);
      _recordPaywallUnlockIfNeeded(page);

      state = AsyncValue.data(_mapPageToState(page, category));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> fetchNext() async {
    final current = state.value;
    if (current == null || _isFetchingMore) return;
    if (!current.hasMore) return;

    _isFetchingMore = true;
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repository.fetchStarData(
        username: _args.username,
        category: current.category,
        cursor: current.nextCursor,
      );

      final mergedItems = <StarData>[
        ...current.items,
        ...page.items.where(
          (incoming) =>
              !current.items.any((existing) => existing.id == incoming.id),
        ),
      ];

      _recordPaywallUnlockIfNeeded(page);

      state = AsyncValue.data(
        current.copyWith(
          items: mergedItems,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
          viewerAccess: page.viewerAccess,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } finally {
      _isFetchingMore = false;
    }
  }

  void recordLikeInteraction() {
    _telemetry.recordInteractionLike(username: _args.username);
  }

  void recordCommentInteraction() {
    _telemetry.recordInteractionComment(username: _args.username);
  }

  void _recordView(StarDataCategory? category) {
    _telemetry.recordView(
      username: _args.username,
      category: category,
    );
  }

  void _recordPaywallUnlockIfNeeded(StarDataPage page) {
    if (_paywallReported) return;
    if (!page.viewerAccess.canViewFollowersOnlyContent) return;

    final hasFollowersContent = page.items.any(
      (item) => item.visibility == StarDataVisibility.followers,
    );

    if (hasFollowersContent) {
      _telemetry.recordPaywallUnlock(username: _args.username);
      _paywallReported = true;
    }
  }

  StarDataState _mapPageToState(
    StarDataPage page,
    StarDataCategory? category,
  ) {
    return StarDataState(
      profile: page.profile,
      viewerAccess: page.viewerAccess,
      items: page.items,
      nextCursor: page.nextCursor,
      category: category,
      isLoadingMore: false,
      isRefreshing: false,
      hasMore: page.hasMore,
    );
  }
}

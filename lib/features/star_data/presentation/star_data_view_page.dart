import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/category.dart';
import '../domain/star_data.dart';
import '../application/star_data_controller.dart';
import 'widgets/star_action_bar.dart';
import 'widgets/star_data_grid.dart';
import 'widgets/star_filter_bar.dart';
import 'widgets/star_header.dart';
import 'widgets/skeleton_card.dart';

class StarDataViewPage extends ConsumerStatefulWidget {
  const StarDataViewPage({
    super.key,
    required this.username,
    this.initialCategory,
  });

  final String username;
  final StarDataCategory? initialCategory;

  @override
  ConsumerState<StarDataViewPage> createState() => _StarDataViewPageState();
}

class _StarDataViewPageState extends ConsumerState<StarDataViewPage> {
  late final ScrollController _scrollController;
  late StarDataControllerArgs _args;

  @override
  void initState() {
    super.initState();
    _args = StarDataControllerArgs(
      username: widget.username,
      initialCategory: widget.initialCategory,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant StarDataViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextArgs = StarDataControllerArgs(
      username: widget.username,
      initialCategory: widget.initialCategory,
    );
    if (nextArgs != _args) {
      ref.invalidate(starDataControllerProvider(_args));
      _args = nextArgs;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 480) {
      ref.read(starDataControllerProvider(_args).notifier).fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(starDataControllerProvider(_args));
    final notifier = ref.read(starDataControllerProvider(_args).notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: asyncState.when(
          data: (data) => _buildDataView(context, data, notifier),
          loading: () => _buildSkeletonView(context),
          error: (error, _) => _ErrorView(
            message: 'データを読み込めませんでした',
            onRetry: notifier.refresh,
          ),
        ),
      ),
    );
  }

  Widget _buildDataView(
    BuildContext context,
    StarDataState state,
    StarDataController notifier,
  ) {
    final snapshot = StarDataStateSnapshot(
      items: state.items,
      viewerAccess: state.viewerAccess,
      categoryDigest: _digestWithDefaults(state.viewerAccess.categoryDigest),
      showDigestOnly: state.showDigestOnly,
    );

    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          sliver: SliverToBoxAdapter(
            child: StarHeader(profile: state.profile),
          ),
        ),
        SliverToBoxAdapter(
          child: StarActionBar(
            enableActions: state.viewerAccess.isLoggedIn &&
                state.viewerAccess.canToggleActions,
            onFollow: () => _showSnack(context, 'フォロー機能は近日公開予定です'),
            onShare: () => _showSnack(context, 'シェアリンクをコピーしました（仮）'),
            onReport: () => _showSnack(context, '報告機能は準備中です'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: StarFilterBar(
              selectedCategory: state.category,
              onCategorySelected: notifier.selectCategory,
            ),
          ),
        ),
        if (state.isRefreshing)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2),
          ),
        StarDataGrid(
          state: snapshot,
          onCardTap: (item) {
            if (!state.viewerAccess.canViewItem(item.visibility)) {
              _showSnack(context, 'メンバーシップに加入すると閲覧できます');
              return;
            }
            _showSnack(context, '詳細画面は近日公開予定です');
          },
          onLike: () {
            notifier.recordLikeInteraction();
            _showSnack(context, 'リアクションを記録しました（仮）');
          },
          onComment: () {
            notifier.recordCommentInteraction();
            _showSnack(context, 'コメント機能は準備中です');
          },
          showSkeleton: state.items.isEmpty && state.isRefreshing,
          skeletonCount: 6,
        ),
        if (state.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildSkeletonView(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const SkeletonCard(),
              childCount: 6,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
          ),
        ),
      ],
    );
  }

  Map<StarDataCategory, int> _digestWithDefaults(
    Map<StarDataCategory, int> digest,
  ) {
    final Map<StarDataCategory, int> seeded = {
      for (final category in StarDataCategory.values) category: 0,
    };
    for (final entry in digest.entries) {
      if (seeded.containsKey(entry.key)) {
        seeded[entry.key] = entry.value;
      }
    }
    return seeded;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}

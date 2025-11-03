import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/user_provider.dart';
import '../../data_integration/screens/youtube_import_screen.dart';
import '../domain/star_content_entry.dart';
import '../infrastructure/star_content_repository.dart';
import '../../../src/core/components/service_icons.dart';

enum _TimeFilter { all, day1, days7, days30 }

enum _TimelineLayout { list, grid }

class StarDataYoutubePage extends ConsumerStatefulWidget {
  const StarDataYoutubePage({super.key, this.username});

  final String? username;

  @override
  ConsumerState<StarDataYoutubePage> createState() => _StarDataYoutubePageState();
}

class _StarDataYoutubePageState extends ConsumerState<StarDataYoutubePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  _TimeFilter _timeFilter = _TimeFilter.days30;
  _TimelineLayout _layout = _TimelineLayout.list;
  bool _showOnlyLocal = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _handleRefresh() async {
    await ref.refresh(starYoutubeTimelineProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final asyncTimeline = ref.watch(starYoutubeTimelineProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9F5FF), Color(0xFFF5F3FF), Color(0xFFF8FBFF)],
            ),
          ),
          child: asyncTimeline.when(
            data: (items) => _buildLoadedView(context, user.name, items),
            loading: () => const _LoadingView(),
            error: (error, _) => _ErrorView(
              message: 'データの読み込みに失敗しました\n${error.toString()}',
              onRetry: _handleRefresh,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    String displayName,
    List<StarContentEntry> items,
  ) {
    final filtered = _applyFilters(items);
    final stats = _buildStats(items);
    final timelineStats = _buildStats(filtered);

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HeaderSection(
              starName: displayName.isEmpty ? 'Starlist' : displayName,
              totalCount: stats.totalCount,
              recentCount: stats.lastSevenDays,
              localCount: stats.localOnlyCount,
              topChannel: stats.topChannel,
              onImportTap: () => _openImport(context),
            ),
          ),
          SliverToBoxAdapter(
            child: _SearchAndFilterBar(
              controller: _searchController,
              timeFilter: _timeFilter,
              onTimeFilterChanged: (filter) => setState(() => _timeFilter = filter),
              layout: _layout,
              onLayoutChanged: (layout) => setState(() => _layout = layout),
              showOnlyLocal: _showOnlyLocal,
              onToggleLocal: (value) => setState(() => _showOnlyLocal = value),
              query: _searchQuery,
            ),
          ),
          SliverToBoxAdapter(
            child: _StatsHighlightRow(stats: timelineStats),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyState(onImportTap: () => _openImport(context)),
            )
          else if (_layout == _TimelineLayout.grid)
            _buildGridSliver(filtered)
          else
            _buildListSliver(filtered),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  SliverPadding _buildListSliver(List<StarContentEntry> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _YouTubeContentCard(
                entry: entry,
                onOpen: () => _openContent(context, entry),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverPadding _buildGridSliver(List<StarContentEntry> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = items[index];
            return _YouTubeContentCard(
              entry: entry,
              compact: true,
              onOpen: () => _openContent(context, entry),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  _TimelineStats _buildStats(List<StarContentEntry> items) {
    final now = DateTime.now();
    final lastSeven = items.where((item) {
      return now.difference(item.occurredAt).inDays < 7;
    }).length;
    final lastThirty = items.where((item) {
      return now.difference(item.occurredAt).inDays < 30;
    }).length;
    final localOnly = items.where((item) => item.isLocalOnly).length;

    final channelCounter = SplayTreeMap<String, int>((a, b) => a.compareTo(b));
    for (final item in items) {
      if (item.channel.isNotEmpty) {
        channelCounter[item.channel] = (channelCounter[item.channel] ?? 0) + 1;
      }
    }
    String? topChannel;
    if (channelCounter.isNotEmpty) {
      final sorted = channelCounter.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topChannel = sorted.first.key;
    }

    return _TimelineStats(
      totalCount: items.length,
      lastSevenDays: lastSeven,
      lastThirtyDays: lastThirty,
      localOnlyCount: localOnly,
      topChannel: topChannel,
    );
  }

  List<StarContentEntry> _applyFilters(List<StarContentEntry> items) {
    final startDate = _startForFilter(_timeFilter);
    return items.where((item) {
      if (_showOnlyLocal && !item.isLocalOnly) {
        return false;
      }
      if (startDate != null && item.occurredAt.isBefore(startDate)) {
        return false;
      }
      if (_searchQuery.isEmpty) {
        return true;
      }
      final query = _searchQuery;
      final inTitle = item.title.toLowerCase().contains(query);
      final inChannel = item.channel.toLowerCase().contains(query);
      final inViews = (item.viewsText ?? '').toLowerCase().contains(query);
      final inTags = item.tags.any((tag) => tag.toLowerCase().contains(query));
      return inTitle || inChannel || inViews || inTags;
    }).toList();
  }

  DateTime? _startForFilter(_TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case _TimeFilter.all:
        return null;
      case _TimeFilter.day1:
        return now.subtract(const Duration(hours: 24));
      case _TimeFilter.days7:
        return now.subtract(const Duration(days: 7));
      case _TimeFilter.days30:
        return now.subtract(const Duration(days: 30));
    }
  }

  void _openImport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const YouTubeImportScreen()),
    );
  }

  Future<void> _openContent(BuildContext context, StarContentEntry entry) async {
    final url = entry.url;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('動画リンクが見つかりませんでした')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無効なURLです: $url')),
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('外部ブラウザで開けませんでした: ${uri.toString()}')),
      );
    }
  }
}

class _TimelineStats {
  const _TimelineStats({
    required this.totalCount,
    required this.lastSevenDays,
    required this.lastThirtyDays,
    required this.localOnlyCount,
    required this.topChannel,
  });

  final int totalCount;
  final int lastSevenDays;
  final int lastThirtyDays;
  final int localOnlyCount;
  final String? topChannel;
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.starName,
    required this.totalCount,
    required this.recentCount,
    required this.localCount,
    required this.topChannel,
    required this.onImportTap,
  });

  final String starName;
  final int totalCount;
  final int recentCount;
  final int localCount;
  final String? topChannel;
  final VoidCallback onImportTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.16),
              colorScheme.secondary.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.primary,
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$starName のスターリスト',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'YouTubeインポート済みのコンテンツが一覧で表示されます',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _HeaderMetric(
                    label: '総登録数',
                    value: '$totalCount 件',
                    icon: Icons.video_library_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderMetric(
                    label: '直近7日',
                    value: '$recentCount 件',
                    icon: Icons.update_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HeaderMetric(
                    label: '未同期の下書き',
                    value: '$localCount 件',
                    icon: Icons.pending_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderMetric(
                    label: '注目チャンネル',
                    value: topChannel ?? '未集計',
                    icon: Icons.star_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onImportTap,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('YouTubeデータを取り込む'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surface.withOpacity(0.9),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.timeFilter,
    required this.onTimeFilterChanged,
    required this.layout,
    required this.onLayoutChanged,
    required this.showOnlyLocal,
    required this.onToggleLocal,
    required this.query,
  });

  final TextEditingController controller;
  final _TimeFilter timeFilter;
  final ValueChanged<_TimeFilter> onTimeFilterChanged;
  final _TimelineLayout layout;
  final ValueChanged<_TimelineLayout> onLayoutChanged;
  final bool showOnlyLocal;
  final ValueChanged<bool> onToggleLocal;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              prefixIcon: const Icon(Icons.search),
              hintText: 'タイトル・チャンネル・キーワードで検索',
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => controller.clear(),
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in _filterDefinitions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.label),
                      selected: entry.filter == timeFilter,
                      onSelected: (_) => onTimeFilterChanged(entry.filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                avatar: const Icon(Icons.pending_actions_outlined, size: 18),
                label: const Text('未同期のみ'),
                selected: showOnlyLocal,
                onSelected: onToggleLocal,
              ),
              const Spacer(),
              SegmentedButton<_TimelineLayout>(
                segments: const [
                  ButtonSegment(
                    value: _TimelineLayout.list,
                    icon: Icon(Icons.view_agenda_outlined),
                    label: Text('リスト'),
                  ),
                  ButtonSegment(
                    value: _TimelineLayout.grid,
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('カード'),
                  ),
                ],
                selected: <_TimelineLayout>{layout},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    onLayoutChanged(selection.first);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDefinition {
  const _FilterDefinition(this.filter, this.label);

  final _TimeFilter filter;
  final String label;
}

const List<_FilterDefinition> _filterDefinitions = <_FilterDefinition>[
  _FilterDefinition(_TimeFilter.all, 'すべて'),
  _FilterDefinition(_TimeFilter.day1, '24時間'),
  _FilterDefinition(_TimeFilter.days7, '7日間'),
  _FilterDefinition(_TimeFilter.days30, '30日間'),
];

class _StatsHighlightRow extends StatelessWidget {
  const _StatsHighlightRow({required this.stats});

  final _TimelineStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatsHighlightCard(
            icon: Icons.history_outlined,
            title: '直近30日',
            value: '${stats.lastThirtyDays}件',
            color: colorScheme.secondary,
          ),
          _StatsHighlightCard(
            icon: Icons.trending_up,
            title: 'インポート増加',
            value: stats.lastThirtyDays == 0
                ? 'まだデータが少ないです'
                : '週あたり約 ${(stats.lastThirtyDays / 4).ceil()} 本',
            color: colorScheme.primary,
          ),
          _StatsHighlightCard(
            icon: Icons.favorite_outline,
            title: '人気チャンネル',
            value: stats.topChannel ?? '未集計',
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StatsHighlightCard extends StatelessWidget {
  const _StatsHighlightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: color.withOpacity(0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _YouTubeContentCard extends StatelessWidget {
  const _YouTubeContentCard({
    required this.entry,
    this.onOpen,
    this.compact = false,
  });

  final StarContentEntry entry;
  final VoidCallback? onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateText = DateFormat('yyyy/MM/dd HH:mm').format(entry.occurredAt.toLocal());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ThumbnailPreview(url: entry.thumbnailUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE7E7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ServiceIcons.buildIcon(
                                      serviceId: 'youtube',
                                      size: 14,
                                      isDark: false,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'YouTube',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (entry.isLocalOnly)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiary.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '未同期',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                dateText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.title,
                            maxLines: compact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.channel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (entry.durationText != null && entry.durationText!.isNotEmpty)
                      _InfoBadge(
                        icon: Icons.timer_outlined,
                        label: entry.durationText!,
                      ),
                    if (entry.viewsText != null && entry.viewsText!.isNotEmpty) ...[
                      if (entry.durationText != null && entry.durationText!.isNotEmpty)
                        const SizedBox(width: 8),
                      _InfoBadge(
                        icon: Icons.visibility_outlined,
                        label: entry.viewsText!,
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: '外部で開く',
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_new_rounded),
                    ),
                  ],
                ),
                if ((entry.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            padding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 96,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: const Icon(Icons.play_circle_outline, size: 28, color: Colors.black54),
    );

    if (url == null || url!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 96,
        height: 72,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onImportTap});

  final VoidCallback onImportTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 52, color: Colors.black45),
            const SizedBox(height: 16),
            Text(
              'まだYouTubeデータがありません',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'データ取り込みを行うと、ここに視聴履歴や投稿が自動で一覧化されます。',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onImportTap,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('YouTube取り込みを始める'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              '読み込みエラー',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }
}

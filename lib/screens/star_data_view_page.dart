import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/star_data/models.dart';
import '../features/star_data/star_data_repository.dart';
import '../src/core/config/feature_flags.dart';

class StarDataViewPage extends ConsumerStatefulWidget {
  const StarDataViewPage({super.key});

  @override
  ConsumerState<StarDataViewPage> createState() => _StarDataViewPageState();
}

class _StarDataViewPageState extends ConsumerState<StarDataViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isStarView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(starDashboardProvider(_isStarView));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(dashboardAsync.maybeWhen(
          data: (data) => data.summary.name,
          orElse: () => 'スターデータ',
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [_isStarView, !_isStarView],
              onPressed: (index) {
                setState(() => _isStarView = index == 0);
                ref.invalidate(starDashboardProvider(_isStarView));
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('スター表示'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ファン表示'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: dashboardAsync.when(
          data: (dashboard) => DefaultTabController(
            length: 5,
              child: Column(
                children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HeroSummaryCard(
                    summary: dashboard.summary,
                    isStarView: _isStarView,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tabs: const [
                        Tab(text: '概要'),
                        Tab(text: '投稿'),
                        Tab(text: 'ランキング'),
                        Tab(text: '統計'),
                        Tab(text: '受賞'),
                ],
              ),
            ),
          ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                      children: [
                      _OverviewSection(data: dashboard),
                      _PostsSection(posts: dashboard.posts),
                      _RankingSection(items: dashboard.ranking),
                      _StatsSection(stats: dashboard.stats),
                      _AwardSection(awards: dashboard.awards),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(message: 'データを読み込めませんでした\n$error'),
        ),
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({required this.summary, required this.isStarView});

  final StarSummary summary;
  final bool isStarView;

  @override
  Widget build(BuildContext context) {
    final accentColor = isStarView
        ? const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFFAE8FFF)])
        : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: accentColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: (!FeatureFlags.hideSampleMedia &&
                        summary.avatarUrl.isNotEmpty)
                    ? NetworkImage(summary.avatarUrl)
                    : null,
                child: (FeatureFlags.hideSampleMedia || summary.avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 32, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                      summary.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.followerCount.toStringAsFixed(0)} フォロワー',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(isStarView ? 'スター表示' : 'ファン表示'),
                backgroundColor: Colors.white.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _MetricTile(
                label: '今月の収益',
                value: '¥${_currency(summary.revenueThisMonth)}',
                footnote: '+${summary.growthRate.toStringAsFixed(1)}% vs 先月',
              ),
              _MetricTile(
                label: 'ファン支持率',
                value: '${summary.fanSupportRate}%',
                footnote: 'サブスク / 投げ銭ベース',
              ),
              _MetricTile(
                label: '連携SNS',
                value: '${summary.connectedSocials}件',
                footnote: 'Google, X, Instagram',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.data});

  final StarDashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: '統計サマリ'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
                label: '投稿数 (30日)',
                value: '${data.stats.postCount}',
                trend: '+8.5%'),
            _StatCard(
                label: '視聴・閲覧',
                value: '${data.stats.views.toStringAsFixed(0)}',
                trend: '+12%'),
            _StatCard(
                label: '総収益',
                value: '¥${_currency(data.stats.revenue)}',
                trend: '+5.1%'),
            _StatCard(
                label: '平均エンゲージ',
                value: '${data.stats.engagement.toStringAsFixed(1)}%',
                trend: '+2.3%'),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeader(title: 'ファン層別サマリ'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _surfaceCard(context),
          child: Column(
            children: const [
              _BreakdownRow(
                  label: 'プレミアム', value: '2,340人', accent: Colors.amber),
              _BreakdownRow(
                  label: 'スタンダード', value: '5,210人', accent: Colors.blueAccent),
              _BreakdownRow(
                  label: 'ライト', value: '8,120人', accent: Colors.purpleAccent),
              _BreakdownRow(label: '無料', value: '28,900人', accent: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(title: '最新連携SNS状態'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _surfaceCard(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _SocialChip(provider: 'Google', status: '連携中'),
              _SocialChip(provider: 'X', status: '再認証'),
              _SocialChip(provider: 'Instagram', status: '連携中'),
            ],
                      ),
                    ),
                ],
    );
  }
}

class _PostsSection extends StatelessWidget {
  const _PostsSection({required this.posts});

  final List<StarPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _EmptyState(message: '投稿がまだありません');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: _surfaceCard(context),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(post.coverUrl, fit: BoxFit.cover),
                ),
              ),
              title: Text(post.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.impressions}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.favorite_border, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.likes}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.mode_comment_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.comments}'),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text(post.publishedAt)],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankingSection extends StatelessWidget {
  const _RankingSection({required this.items});

  final List<FanRankingItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(message: 'ランキングデータがありません');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text('${item.rank}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          title: Text(item.fanName,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('スコア ${item.score}'),
        );
      },
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final StarStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: '指標推移'),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: _surfaceCard(context),
          alignment: Alignment.center,
          child: Text(
            '投稿数: ${stats.postCount}\nビュー: ${stats.views.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'ファン行動ヒートマップ'),
        const SizedBox(height: 12),
        Container(
          height: 240,
          decoration: _surfaceCard(context),
          alignment: Alignment.center,
          child: const Text('ヒートマップ Placeholder'),
        ),
      ],
    );
  }
}

class _AwardSection extends StatelessWidget {
  const _AwardSection({required this.awards});

  final List<StarAward> awards;

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) {
      return const _EmptyState(message: '受賞データがありません');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: awards.length,
      itemBuilder: (context, index) {
        final award = awards[index];
        return Container(
          decoration: _surfaceCard(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.emoji_events_outlined,
                  size: 32, color: Colors.amber),
              const SizedBox(height: 12),
              Text(award.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('受賞日: ${award.date}'),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('詳細'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.trend});

  final String label;
  final String value;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: _surfaceCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Text(trend!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(
      {required this.label, required this.value, required this.footnote});

  final String label;
  final String value;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(footnote,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(
      {required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.provider, required this.status});

  final String provider;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == '連携中'
        ? Colors.green
        : status == '再認証'
            ? Colors.orange
            : Colors.grey;
    return Chip(
      label: Text('$provider  ·  $status'),
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

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
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                DefaultTabController.of(context)?.animateTo(0);
              },
              child: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }
}

String _currency(num value) {
  final str = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    buffer.write(str[str.length - 1 - i]);
    if ((i + 1) % 3 == 0 && i != str.length - 1) buffer.write(',');
  }
  return buffer.toString().split('').reversed.join();
}

BoxDecoration _surfaceCard(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    color: scheme.surface,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

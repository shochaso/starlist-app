import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/data/models/genre_taxonomy.dart';
import 'package:starlist_app/features/search/providers/genre_taxonomy_provider.dart';
import 'package:starlist_app/features/data_integration/screens/data_import_screen.dart';
import 'package:starlist_app/src/core/constants/service_definitions.dart';

// 検索タブの状態管理
final searchTabProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _categorySearchController;

  final List<String> tabTitles = [
    '最新の検索結果',
    'スター',
    'カテゴリー',
    'コンテンツ',
    'タグ',
    'YouTube',
    'Spotify',
    'Amazon',
  ];

  static const Map<String, String> _categoryDisplayNames = {
    'video': '動画配信',
    'shopping': 'ショッピング',
    'food_delivery': 'フードデリバリ',
    'convenience_store': 'コンビニ',
    'music': '音楽',
    'game_play': 'ゲーム（プレイのみ）',
    'mobile_apps': 'スマホアプリ',
    'screen_time': 'アプリ使用時間',
    'fashion': 'ファッション',
    'book': '本（ブック）',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTitles.length, vsync: this);
    _categorySearchController = TextEditingController();
    _categorySearchController.addListener(() {
      ref.read(genreSearchProvider.notifier).state =
          _categorySearchController.text.trim();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _categorySearchController.dispose();
    ref.read(genreSearchProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDefaultSearchView(),
                _buildStarsView(),
                _buildCategoryView(),
                _buildContentView(),
                _buildTagsView(),
                _buildYouTubeView(),
                _buildSpotifyView(),
                _buildAmazonView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'スター、コンテンツ、タグを検索',
              prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF3B82F6),
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabTitles.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  Widget _buildDefaultSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新の検索結果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTagCard('#新着コンテンツ', '今週の新しい投稿'),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '田中 太郎',
            '24.5万フォロワー',
            '1',
            Colors.yellow,
            [Colors.purple, Colors.blue],
            false,
          ),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '佐藤 花子',
            '18.3万フォロワー',
            '2',
            Colors.grey,
            [Colors.green, Colors.blue],
            true,
          ),
          const SizedBox(height: 12),
          _buildStarResultCard(
            '鈴木 次郎',
            '9.7万フォロワー',
            '3',
            Colors.orange,
            [Colors.red, Colors.yellow],
            false,
          ),
          const SizedBox(height: 24),
          const Text(
            'トレンド検索',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildContentCard(),
          const SizedBox(height: 12),
          _buildTagCard('#アニメレビュー', '1,284件の投稿'),
        ],
      ),
    );
  }

  Widget _buildStarsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStarSection('あなたにおすすめ', [
            _buildStarProfile(
                '田中 太郎', '音楽・エンタメ', 'T', [Colors.purple, Colors.pink]),
            _buildStarProfile(
                '佐藤 花子', 'ファッション', 'S', [Colors.green, Colors.teal]),
            _buildStarProfile(
                '鈴木 次郎', 'ゲーム', 'SZ', [Colors.red, Colors.orange]),
            _buildStarProfile(
                '山田 一郎', 'YouTuber', 'Y', [Colors.yellow, Colors.orange]),
            _buildStarProfile(
                '中村 愛', '美容・コスメ', 'N', [Colors.blue, Colors.indigo]),
          ]),
          const SizedBox(height: 32),
          _buildStarSection('ゲーム', [
            _buildStarProfile(
                '高橋 ゲーマー', 'eスポーツ選手', 'G1', [Colors.red, Colors.pink]),
            _buildStarProfile(
                '佐々木 プレイヤー', 'ゲーム実況者', 'G2', [Colors.purple, Colors.indigo]),
            _buildStarProfile(
                '伊藤 ゲーム', 'ゲームクリエイター', 'G3', [Colors.blue, Colors.cyan]),
            _buildStarProfile(
                '渡辺 ストリーマー', 'ゲーム配信者', 'G4', [Colors.green, Colors.teal]),
          ]),
          const SizedBox(height: 32),
          _buildStarSection('料理・グルメ', [
            _buildStarProfile(
                '斎藤 シェフ', '料理研究家', 'C1', [Colors.amber, Colors.orange]),
            _buildStarProfile(
                '加藤 グルメ', '食レポーター', 'C2', [Colors.red, Colors.pink]),
            _buildStarProfile(
                '小林 ベジタリアン', 'ベジタリアン料理家', 'C3', [Colors.green, Colors.lime]),
            _buildStarProfile(
                '吉田 カフェ', 'カフェオーナー', 'C4', [Colors.blue, Colors.lightBlue]),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategoryView() {
    final theme = Theme.of(context);
    final taxonomy = ref.watch(genreTaxonomyProvider);
    final stats = ref.watch(genreStatsProvider);
    final searchQuery = ref.watch(genreSearchProvider);
    final normalizedQuery = searchQuery.toLowerCase();

    final categories = taxonomy.categories.entries.toList();

    final filteredCategories = categories.where((entry) {
      if (normalizedQuery.isEmpty) return true;
      final displayName =
          _categoryDisplayNames[entry.key]?.toLowerCase() ?? entry.key;
      final categoryMatch = displayName.contains(normalizedQuery) ||
          entry.key.toLowerCase().contains(normalizedQuery);
      final serviceMatch = entry.value.services.any((serviceId) {
        final serviceName =
            ServiceDefinitions.getServiceName(serviceId).toLowerCase();
        return serviceName.contains(normalizedQuery) ||
            serviceId.contains(normalizedQuery);
      });
      final genreMatch = entry.value.genres.any((genre) {
        return genre.label.toLowerCase().contains(normalizedQuery) ||
            genre.slug.toLowerCase().contains(normalizedQuery);
      });
      return categoryMatch || serviceMatch || genreMatch;
    }).toList();

    final filteredGenres = ref.watch(filteredGenresProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryStrategyHero(context, theme),
          const SizedBox(height: 20),
          _buildCategorySearchField(theme),
          const SizedBox(height: 18),
          _buildCategoryStatGrid(stats, theme),
          const SizedBox(height: 24),
          if (filteredCategories.isEmpty)
            _buildNoCategoryResult(normalizedQuery.isEmpty)
          else
            ...filteredCategories.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCategoryStrategyCard(
                  theme: theme,
                  categoryKey: entry.key,
                  data: entry.value,
                  query: normalizedQuery,
                ),
              ),
            ),
          if (filteredGenres.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'ジャンルのヒント',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildGenreChipCloud(theme, filteredGenres, normalizedQuery),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return const Center(
      child: Text(
        'コンテンツ検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildTagsView() {
    return const Center(
      child: Text(
        'タグ検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildYouTubeView() {
    return const Center(
      child: Text(
        'YouTube検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildSpotifyView() {
    return const Center(
      child: Text(
        'Spotify検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildAmazonView() {
    return const Center(
      child: Text(
        'Amazon検索',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildCategoryStrategyHero(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'カテゴリー戦略ハブ',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '対応サービスを横断して、スターの提供価値やトレンドジャンルを分析しましょう。'
            '\nデータ取り込みページと連携してカテゴリ別に深掘りできます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroBadge(icon: Icons.play_circle_fill, label: '動画配信'),
              _HeroBadge(icon: Icons.shopping_bag, label: 'ショッピング'),
              _HeroBadge(icon: Icons.restaurant_menu, label: 'フードデリバリ'),
              _HeroBadge(icon: Icons.music_note, label: '音楽'),
              _HeroBadge(icon: Icons.auto_awesome, label: 'ファッション'),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DataImportScreen(showAppBar: true),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4338CA),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.auto_graph, size: 20),
              label: const Text('カテゴリ別サービスを見る'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySearchField(ThemeData theme) {
    return TextField(
      controller: _categorySearchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        hintText: 'カテゴリ・ジャンル・サービスを検索',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }

  Widget _buildCategoryStatGrid(Map<String, int> stats, ThemeData theme) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリー戦略サマリー',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: entries.map((entry) {
                final label = _categoryDisplayNames[entry.key] ?? entry.key;
                return _CategoryStatPill(label: label, count: entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCategoryResult(bool isEmptyQuery) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            isEmptyQuery ? Icons.category_outlined : Icons.search_off,
            size: 36,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            isEmptyQuery ? 'カテゴリーデータが読み込まれていません' : '条件に一致するカテゴリーが見つかりませんでした',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (!isEmptyQuery) ...[
            const SizedBox(height: 8),
            const Text(
              'キーワードを変えるか、サービス名で検索してみてください。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryStrategyCard({
    required ThemeData theme,
    required String categoryKey,
    required CategoryData data,
    required String query,
  }) {
    final displayName = _categoryDisplayNames[categoryKey] ?? categoryKey;
    final primaryService =
        data.services.isNotEmpty ? data.services.first : null;
    final accent = primaryService != null
        ? ServiceDefinitions.getServiceColor(primaryService)
        : const Color(0xFF4ECDC4);

    final highlightedGenres = query.isEmpty
        ? <String>{}
        : data.genres
            .where((genre) =>
                genre.label.toLowerCase().contains(query) ||
                genre.slug.toLowerCase().contains(query))
            .map((genre) => genre.slug)
            .toSet();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dashboard_customize, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.services.length}サービス / ${data.genres.length}ジャンル',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.services.isNotEmpty) ...[
              Text(
                '主要サービス',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.services.map((serviceId) {
                  final name = ServiceDefinitions.getServiceName(serviceId);
                  return _ServiceChip(label: name);
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '戦略的ジャンル',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.genres.take(12).map((genre) {
                final isHighlighted = highlightedGenres.contains(genre.slug);
                return Chip(
                  label: Text(genre.label),
                  backgroundColor: isHighlighted
                      ? const Color(0xFFFFEDD5)
                      : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isHighlighted
                          ? const Color(0xFFFB923C)
                          : Colors.transparent,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isHighlighted
                        ? const Color(0xFFFB923C)
                        : const Color(0xFF334155),
                    fontWeight:
                        isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChipCloud(
    ThemeData theme,
    List<Genre> genres,
    String query,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.take(18).map((genre) {
        final matches = query.isNotEmpty &&
            (genre.label.toLowerCase().contains(query) ||
                genre.slug.toLowerCase().contains(query));
        return Chip(
          avatar: matches
              ? const Icon(Icons.trending_up,
                  size: 16, color: Color(0xFF2563EB))
              : null,
          label: Text(genre.label),
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: matches ? const Color(0xFF2563EB) : const Color(0xFF334155),
            fontWeight: matches ? FontWeight.w600 : FontWeight.w500,
          ),
          backgroundColor:
              matches ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color:
                  matches ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagCard(String tag, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarResultCard(
    String name,
    String followers,
    String rank,
    Color rankColor,
    List<Color> gradientColors,
    bool isFollowing,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  followers,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFollowing ? Colors.grey : const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isFollowing ? 'フォロー中' : 'フォロー',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundColor: Color(0xFFA7F3D0),
                child: Text(
                  'S',
                  style: TextStyle(fontSize: 8, color: Color(0xFF047857)),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '佐藤 花子さんが投稿',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.music_note, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lo-Fi Study Beats',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'ChillHop Music - アルバム',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '4時間前',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSection(String title, List<Widget> stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'すべて表示',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemCount: stars.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 128,
                child: stars[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarProfile(
      String name, String category, String initial, List<Color> colors) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CategoryStatPill extends StatelessWidget {
  final String label;
  final int count;

  const _CategoryStatPill({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count ジャンル',
              style: const TextStyle(
                color: Color(0xFF4338CA),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;

  const _ServiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFEFF6FF),
      labelStyle: const TextStyle(
        color: Color(0xFF1D4ED8),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: const Color(0xFF1D4ED8).withOpacity(0.2)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/netflix_providers.dart';
import '../widgets/netflix_viewing_card.dart';
import '../widgets/netflix_stats_card.dart';
import '../widgets/netflix_filter_chip.dart';
import '../widgets/netflix_ocr_button.dart';
import 'netflix_viewing_detail_screen.dart';
import 'netflix_filter_screen.dart';
import 'netflix_add_manual_screen.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix視聴履歴ホーム画面
class NetflixHomeScreen extends ConsumerStatefulWidget {
  const NetflixHomeScreen({super.key});

  @override
  ConsumerState<NetflixHomeScreen> createState() => _NetflixHomeScreenState();
}

class _NetflixHomeScreenState extends ConsumerState<NetflixHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(filteredNetflixViewingHistoryProvider);
    final statsAsync = ref.watch(netflixViewingStatsProvider);
    final filter = ref.watch(netflixViewingFilterProvider);
    final isLoading = ref.watch(netflixViewingLoadingProvider);
    final error = ref.watch(netflixViewingErrorProvider);
    final ocrProgress = ref.watch(netflixOcrProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Netflix視聴履歴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // 手動追加ボタン
              IconButton(
                onPressed: () => _navigateToAddManual(),
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: '手動追加',
              ),
              // フィルターボタン
              Stack(
                children: [
                  IconButton(
                    onPressed: () => _navigateToFilterScreen(),
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                  if (filter.hasFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE50914),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // リフレッシュボタン
              IconButton(
                onPressed: isLoading ? null : () => _refreshData(),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE50914),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '視聴履歴'),
                Tab(text: '統計'),
                Tab(text: 'ジャンル'),
                Tab(text: 'タイプ'),
              ],
            ),
          ),

          // エラー表示
          if (error != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(netflixViewingActionProvider).clearError(),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),

          // OCR進捗表示
          if (ocrProgress > 0 && ocrProgress < 1)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: ocrProgress,
                      backgroundColor: const Color(0xFF333333),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OCR解析中... ${(ocrProgress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // フィルターチップ
          if (filter.hasFilters)
            SliverToBoxAdapter(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (filter.contentTypes != null)
                      ...filter.contentTypes!.map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: NetflixFilterChip(
                          label: _getContentTypeDisplayName(type),
                          onDeleted: () => _removeContentType(type),
                        ),
                      )),
                    if (filter.genres != null)
                      ...filter.genres!.map((genre) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: NetflixFilterChip(
                          label: genre,
                          onDeleted: () => _removeGenre(genre),
                        ),
                      )),
                    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: NetflixFilterChip(
                          label: '検索: ${filter.searchQuery}',
                          onDeleted: () => _clearSearchQuery(),
                        ),
                      ),
                    if (filter.startDate != null || filter.endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: NetflixFilterChip(
                          label: _getDateRangeLabel(filter.startDate, filter.endDate),
                          onDeleted: () => _clearDateRange(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // コンテンツ
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 視聴履歴タブ
                _buildViewingHistoryTab(historyAsync),
                
                // 統計タブ
                _buildStatsTab(statsAsync),
                
                // ジャンルタブ
                _buildGenreTab(historyAsync),
                
                // タイプタブ
                _buildContentTypeTab(historyAsync),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: NetflixOcrButton(
        onOcrComplete: (viewingHistory) => _handleOcrComplete(viewingHistory),
      ),
    );
  }

  /// 視聴履歴タブ
  Widget _buildViewingHistoryTab(AsyncValue<List<NetflixViewingHistory>> historyAsync) {
    return historyAsync.when(
      data: (viewingHistory) {
        if (viewingHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _refreshData(),
          color: const Color(0xFFE50914),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewingHistory.length,
            itemBuilder: (context, index) {
              final item = viewingHistory[index];
              return NetflixViewingCard(
                viewingHistory: item,
                onTap: () => _navigateToViewingDetail(item),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'エラーが発生しました',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _refreshData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  /// 統計タブ
  Widget _buildStatsTab(AsyncValue<NetflixViewingStats?> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 総合統計カード
              NetflixStatsCard(stats: stats),
              const SizedBox(height: 16),
              
              // ジャンル別視聴時間
              _buildGenreTimeChart(stats),
              const SizedBox(height: 16),
              
              // タイプ別視聴数
              _buildContentTypeChart(stats),
              const SizedBox(height: 16),
              
              // 年別視聴数
              _buildYearChart(stats),
              const SizedBox(height: 16),
              
              // トップキャスト
              if (stats.topCast.isNotEmpty)
                _buildTopCast(stats),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  /// ジャンルタブ
  Widget _buildGenreTab(AsyncValue<List<NetflixViewingHistory>> historyAsync) {
    final genreAsync = ref.watch(netflixViewingByGenreProvider);
    
    return genreAsync.when(
      data: (genreMap) {
        if (genreMap.isEmpty) {
          return _buildEmptyState();
        }

        final sortedGenres = genreMap.entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedGenres.length,
          itemBuilder: (context, index) {
            final entry = sortedGenres[index];
            final genre = entry.key;
            final items = entry.value;
            
            return _buildGenreSection(genre, items);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  /// タイプタブ
  Widget _buildContentTypeTab(AsyncValue<List<NetflixViewingHistory>> historyAsync) {
    final typeAsync = ref.watch(netflixViewingByContentTypeProvider);
    
    return typeAsync.when(
      data: (typeMap) {
        if (typeMap.isEmpty) {
          return _buildEmptyState();
        }

        final sortedTypes = typeMap.entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedTypes.length,
          itemBuilder: (context, index) {
            final entry = sortedTypes[index];
            final contentType = entry.key;
            final items = entry.value;
            
            return _buildContentTypeSection(contentType, items);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  /// ジャンルセクション
  Widget _buildGenreSection(String genre, List<NetflixViewingHistory> items) {
    final totalWatchTime = items.fold<Duration>(
      Duration.zero, 
      (sum, item) => sum + (item.watchDuration ?? Duration.zero),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getGenreIcon(genre),
              color: const Color(0xFFE50914),
              size: 20,
            ),
          ),
          title: Text(
            genre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${items.length}作品 • ${_formatDuration(totalWatchTime)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          children: items.take(5).map((item) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              item.fullTitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateFormat('yyyy/MM/dd').format(item.watchedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              item.contentTypeDisplayName,
              style: const TextStyle(
                color: Color(0xFFE50914),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _navigateToViewingDetail(item),
          )).toList(),
        ),
      ),
    );
  }

  /// コンテンツタイプセクション
  Widget _buildContentTypeSection(NetflixContentType contentType, List<NetflixViewingHistory> items) {
    final totalWatchTime = items.fold<Duration>(
      Duration.zero, 
      (sum, item) => sum + (item.watchDuration ?? Duration.zero),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getContentTypeIcon(contentType),
              color: const Color(0xFFE50914),
              size: 20,
            ),
          ),
          title: Text(
            _getContentTypeDisplayName(contentType),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${items.length}作品 • ${_formatDuration(totalWatchTime)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          children: items.take(5).map((item) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              item.fullTitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateFormat('yyyy/MM/dd').format(item.watchedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: item.rating != null 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE50914), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : null,
            onTap: () => _navigateToViewingDetail(item),
          )).toList(),
        ),
      ),
    );
  }

  /// ジャンル別視聴時間チャート
  Widget _buildGenreTimeChart(NetflixViewingStats stats) {
    final sortedGenres = stats.timeByGenre.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ジャンル別視聴時間',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedGenres.take(5).map((entry) {
            final percentage = stats.totalWatchTime.inMinutes > 0 
                ? (entry.value.inMinutes / stats.totalWatchTime.inMinutes * 100).toInt()
                : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${_formatDuration(entry.value)} ($percentage%)',
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: stats.totalWatchTime.inMinutes > 0 
                        ? entry.value.inMinutes / stats.totalWatchTime.inMinutes 
                        : 0.0,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// コンテンツタイプ別チャート
  Widget _buildContentTypeChart(NetflixViewingStats stats) {
    final sortedTypes = stats.itemsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'コンテンツタイプ別視聴数',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedTypes.map((entry) {
            final percentage = (entry.value / stats.totalItems * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getContentTypeIcon(entry.key),
                    color: const Color(0xFFE50914),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getContentTypeDisplayName(entry.key),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    '${entry.value}件 ($percentage%)',
                    style: const TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 年別視聴数チャート
  Widget _buildYearChart(NetflixViewingStats stats) {
    final sortedYears = stats.itemsByYear.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '公開年別視聴数',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedYears.take(5).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.key}年',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    '${entry.value}作品',
                    style: const TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// トップキャスト
  Widget _buildTopCast(NetflixViewingStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'よく見る出演者',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.topCast.map((actor) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
              ),
              child: Text(
                actor,
                style: const TextStyle(
                  color: Color(0xFFE50914),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// 空の状態
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.movie_outlined,
              size: 40,
              color: Color(0xFFE50914),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '視聴履歴がありません',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'OCRボタンまたは手動追加で視聴履歴を登録してください',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// コンテンツタイプアイコン取得
  IconData _getContentTypeIcon(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return Icons.movie;
      case NetflixContentType.series:
        return Icons.tv;
      case NetflixContentType.documentary:
        return Icons.video_library;
      case NetflixContentType.anime:
        return Icons.animation;
      case NetflixContentType.standup:
        return Icons.mic;
      case NetflixContentType.kids:
        return Icons.child_care;
      case NetflixContentType.reality:
        return Icons.camera_alt;
      case NetflixContentType.other:
        return Icons.play_circle;
    }
  }

  /// ジャンルアイコン取得
  IconData _getGenreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'アクション':
      case 'action':
        return Icons.local_fire_department;
      case 'コメディ':
      case 'comedy':
        return Icons.sentiment_very_satisfied;
      case 'ドラマ':
      case 'drama':
        return Icons.theater_comedy;
      case 'ホラー':
      case 'horror':
        return Icons.psychology;
      case 'ロマンス':
      case 'romance':
        return Icons.favorite;
      case 'sf':
      case 'sci-fi':
        return Icons.rocket_launch;
      case 'アニメ':
      case 'anime':
        return Icons.animation;
      case '日本':
      case 'japanese':
        return Icons.flag;
      default:
        return Icons.category;
    }
  }

  /// コンテンツタイプ表示名取得
  String _getContentTypeDisplayName(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return '映画';
      case NetflixContentType.series:
        return 'シリーズ';
      case NetflixContentType.documentary:
        return 'ドキュメンタリー';
      case NetflixContentType.anime:
        return 'アニメ';
      case NetflixContentType.standup:
        return 'スタンダップコメディ';
      case NetflixContentType.kids:
        return 'キッズ';
      case NetflixContentType.reality:
        return 'リアリティ番組';
      case NetflixContentType.other:
        return 'その他';
    }
  }

  /// 時間フォーマット
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours時間$minutes分';
    } else {
      return '$minutes分';
    }
  }

  /// 日付範囲ラベル取得
  String _getDateRangeLabel(DateTime? start, DateTime? end) {
    final formatter = DateFormat('yyyy/MM/dd');
    if (start != null && end != null) {
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } else if (start != null) {
      return '${formatter.format(start)}以降';
    } else if (end != null) {
      return '${formatter.format(end)}まで';
    }
    return '';
  }

  /// データ更新
  Future<void> _refreshData() async {
    await ref.read(netflixViewingActionProvider).refreshViewingHistory();
  }

  /// OCR完了処理
  void _handleOcrComplete(List<NetflixViewingHistory> viewingHistory) {
    if (viewingHistory.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${viewingHistory.length}件の視聴履歴を読み込みました'),
          backgroundColor: const Color(0xFFE50914),
        ),
      );
    }
  }

  /// 視聴詳細画面へ遷移
  void _navigateToViewingDetail(NetflixViewingHistory viewingHistory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NetflixViewingDetailScreen(viewingHistory: viewingHistory),
      ),
    );
  }

  /// フィルター画面へ遷移
  void _navigateToFilterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetflixFilterScreen(),
      ),
    );
  }

  /// 手動追加画面へ遷移
  void _navigateToAddManual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetflixAddManualScreen(),
      ),
    );
  }

  /// コンテンツタイプ削除
  void _removeContentType(NetflixContentType contentType) {
    final filter = ref.read(netflixViewingFilterProvider);
    final newTypes = List<NetflixContentType>.from(filter.contentTypes ?? [])
      ..remove(contentType);
    
    ref.read(netflixViewingActionProvider).updateFilter(
      filter.copyWith(contentTypes: newTypes.isEmpty ? null : newTypes),
    );
  }

  /// ジャンル削除
  void _removeGenre(String genre) {
    final filter = ref.read(netflixViewingFilterProvider);
    final newGenres = List<String>.from(filter.genres ?? [])
      ..remove(genre);
    
    ref.read(netflixViewingActionProvider).updateFilter(
      filter.copyWith(genres: newGenres.isEmpty ? null : newGenres),
    );
  }

  /// 検索クエリクリア
  void _clearSearchQuery() {
    final filter = ref.read(netflixViewingFilterProvider);
    ref.read(netflixViewingActionProvider).updateFilter(
      filter.copyWith(searchQuery: null),
    );
  }

  /// 日付範囲クリア
  void _clearDateRange() {
    final filter = ref.read(netflixViewingFilterProvider);
    ref.read(netflixViewingActionProvider).updateFilter(
      filter.copyWith(startDate: null, endDate: null),
    );
  }
}
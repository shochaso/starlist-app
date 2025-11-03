import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/services/image_url_builder.dart';

import '../viewmodels/ranking_view_model.dart';
import '../../../models/ranking_model.dart';
import '../../../../../shared/widgets/loading_indicator.dart';
import '../../../../../shared/widgets/error_message.dart';

/// ランキング画面
///
/// トレンドコンテンツや人気スターのランキングを表示する画面です。
class RankingScreen extends ConsumerStatefulWidget {
  /// コンストラクタ
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初期データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rankingViewModel = ref.read(rankingViewModelProvider.notifier);
      rankingViewModel.loadTrendingContent();
      rankingViewModel.loadPopularStars();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankingState = ref.watch(rankingViewModelProvider);
    final rankingViewModel = ref.read(rankingViewModelProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'トレンドコンテンツ'),
            Tab(text: '人気スター'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // トレンドコンテンツタブ
          _buildTrendingContentTab(rankingState, rankingViewModel),
          
          // 人気スタータブ
          _buildPopularStarsTab(rankingState, rankingViewModel),
        ],
      ),
      bottomNavigationBar: _buildPeriodSelector(rankingState, rankingViewModel),
    );
  }

  /// トレンドコンテンツタブを構築
  Widget _buildTrendingContentTab(RankingViewState state, RankingViewModel viewModel) {
    if (state.isLoadingTrending) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.trendingError != null) {
      return ErrorMessage(
        message: state.trendingError!,
        onRetry: () => viewModel.loadTrendingContent(refresh: true),
      );
    }
    
    if (state.trendingRanking == null || state.trendingRanking!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('データがありません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadTrendingContent(refresh: true),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => viewModel.loadTrendingContent(refresh: true),
      child: ListView.builder(
        itemCount: state.trendingRanking!.items.length,
        itemBuilder: (context, index) {
          final item = state.trendingRanking!.items[index];
          return _buildRankingItem(item);
        },
      ),
    );
  }

  /// 人気スタータブを構築
  Widget _buildPopularStarsTab(RankingViewState state, RankingViewModel viewModel) {
    if (state.isLoadingPopularStars) {
      return const Center(child: LoadingIndicator());
    }
    
    if (state.popularStarsError != null) {
      return ErrorMessage(
        message: state.popularStarsError!,
        onRetry: () => viewModel.loadPopularStars(refresh: true),
      );
    }
    
    if (state.popularStarsRanking == null || state.popularStarsRanking!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('データがありません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadPopularStars(refresh: true),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => viewModel.loadPopularStars(refresh: true),
      child: ListView.builder(
        itemCount: state.popularStarsRanking!.items.length,
        itemBuilder: (context, index) {
          final item = state.popularStarsRanking!.items[index];
          return _buildRankingItem(item);
        },
      ),
    );
  }

  /// ランキングアイテムを構築
  Widget _buildRankingItem(RankingItemModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ランキング順位
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(item.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${item.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // アイテム画像
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ImageUrlBuilder.thumbnail(
                    item.imageUrl!,
                    width: 240,
                  ),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: Icon(
                  _getItemTypeIcon(item.type),
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(width: 16),
            
            // アイテム情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16),
                      const SizedBox(width: 4),
                      Text('スコア: ${item.score.toStringAsFixed(1)}'),
                      if (item.previousRank != null) ...[
                        const SizedBox(width: 16),
                        _buildRankChange(item.rank, item.previousRank!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ランキング変動を構築
  Widget _buildRankChange(int currentRank, int previousRank) {
    final diff = previousRank - currentRank;
    
    if (diff > 0) {
      // ランクアップ
      return Row(
        children: [
          const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            '+$diff',
            style: const TextStyle(color: Colors.green),
          ),
        ],
      );
    } else if (diff < 0) {
      // ランクダウン
      return Row(
        children: [
          const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Text(
            '${diff.abs()}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    } else {
      // 変動なし
      return const Row(
        children: [
          Icon(Icons.remove, color: Colors.grey, size: 16),
          SizedBox(width: 4),
          Text(
            '変動なし',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
  }

  /// 期間セレクターを構築
  Widget _buildPeriodSelector(RankingViewState state, RankingViewModel viewModel) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: RankingPeriod.values.map((period) {
            final isSelected = state.selectedPeriod == period;
            
            return InkWell(
              onTap: () => viewModel.changePeriod(period),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  viewModel.getPeriodDisplayName(period),
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// ランク順位に応じた色を取得
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!;
      case 2:
        return Colors.blueGrey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// アイテムタイプに応じたアイコンを取得
  IconData _getItemTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_filled;
      case 'music':
        return Icons.music_note;
      case 'book':
        return Icons.book;
      case 'movie':
        return Icons.movie;
      case 'star':
        return Icons.person;
      default:
        return Icons.category;
    }
  }
}

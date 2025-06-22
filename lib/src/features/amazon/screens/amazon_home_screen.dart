import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/amazon_providers.dart';
import '../widgets/amazon_purchase_card.dart';
import '../widgets/amazon_stats_card.dart';
import '../widgets/amazon_filter_chip.dart';
import '../widgets/amazon_ocr_button.dart';
import 'amazon_purchase_detail_screen.dart';
import 'amazon_filter_screen.dart';
import '../../../data/models/amazon_models.dart';

/// Amazon購入履歴ホーム画面
class AmazonHomeScreen extends ConsumerStatefulWidget {
  const AmazonHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AmazonHomeScreen> createState() => _AmazonHomeScreenState();
}

class _AmazonHomeScreenState extends ConsumerState<AmazonHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(filteredAmazonPurchasesProvider);
    final statsAsync = ref.watch(amazonPurchaseStatsProvider);
    final filter = ref.watch(amazonPurchaseFilterProvider);
    final isLoading = ref.watch(amazonPurchaseLoadingProvider);
    final error = ref.watch(amazonPurchaseErrorProvider);
    final ocrProgress = ref.watch(amazonOcrProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF2A2A2A),
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Amazon購入履歴',
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
                          color: Color(0xFFFF9900),
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
              indicatorColor: const Color(0xFFFF9900),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '購入履歴'),
                Tab(text: '統計'),
                Tab(text: 'カテゴリ'),
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
                      onPressed: () => ref.read(amazonPurchaseActionProvider).clearError(),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
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
                    if (filter.categories != null)
                      ...filter.categories!.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AmazonFilterChip(
                          label: category.toString().split('.').last,
                          onDeleted: () => _removeCategory(category),
                        ),
                      )),
                    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AmazonFilterChip(
                          label: '検索: ${filter.searchQuery}',
                          onDeleted: () => _clearSearchQuery(),
                        ),
                      ),
                    if (filter.startDate != null || filter.endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AmazonFilterChip(
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
                // 購入履歴タブ
                _buildPurchaseHistoryTab(purchasesAsync),
                
                // 統計タブ
                _buildStatsTab(statsAsync),
                
                // カテゴリタブ
                _buildCategoryTab(purchasesAsync),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AmazonOcrButton(
        onOcrComplete: (purchases) => _handleOcrComplete(purchases),
      ),
    );
  }

  /// 購入履歴タブ
  Widget _buildPurchaseHistoryTab(AsyncValue<List<AmazonPurchase>> purchasesAsync) {
    return purchasesAsync.when(
      data: (purchases) {
        if (purchases.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _refreshData(),
          color: const Color(0xFFFF9900),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return AmazonPurchaseCard(
                purchase: purchase,
                onTap: () => _navigateToPurchaseDetail(purchase),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
                backgroundColor: const Color(0xFFFF9900),
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
  Widget _buildStatsTab(AsyncValue<AmazonPurchaseStats?> statsAsync) {
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
              AmazonStatsCard(stats: stats),
              const SizedBox(height: 16),
              
              // カテゴリ別支出
              _buildCategorySpendingChart(stats),
              const SizedBox(height: 16),
              
              // 月別支出
              _buildMonthlySpendingChart(stats),
              const SizedBox(height: 16),
              
              // トップブランド
              _buildTopBrands(stats),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  /// カテゴリタブ
  Widget _buildCategoryTab(AsyncValue<List<AmazonPurchase>> purchasesAsync) {
    final categorizedAsync = ref.watch(amazonPurchasesByCategoryProvider);
    
    return categorizedAsync.when(
      data: (categorized) {
        if (categorized.isEmpty) {
          return _buildEmptyState();
        }

        final sortedCategories = categorized.entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            final entry = sortedCategories[index];
            final category = entry.key;
            final purchases = entry.value;
            
            return _buildCategorySection(category, purchases);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  /// カテゴリセクション
  Widget _buildCategorySection(AmazonPurchaseCategory category, List<AmazonPurchase> purchases) {
    final totalAmount = purchases.fold<double>(0.0, (sum, p) => sum + p.totalAmount);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
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
              color: const Color(0xFFFF9900).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: const Color(0xFFFF9900),
              size: 20,
            ),
          ),
          title: Text(
            purchases.first.categoryDisplayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${purchases.length}件 • ${AmazonPurchase._formatPrice(totalAmount, 'JPY')}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          children: purchases.take(5).map((purchase) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              purchase.productName,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateFormat('yyyy/MM/dd').format(purchase.purchaseDate),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              purchase.formattedPrice,
              style: const TextStyle(
                color: Color(0xFFFF9900),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _navigateToPurchaseDetail(purchase),
          )).toList(),
        ),
      ),
    );
  }

  /// カテゴリ別支出チャート
  Widget _buildCategorySpendingChart(AmazonPurchaseStats stats) {
    final sortedCategories = stats.spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'カテゴリ別支出',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedCategories.take(5).map((entry) {
            final percentage = (entry.value / stats.totalSpent * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AmazonPurchase(
                          id: '',
                          userId: '',
                          orderId: '',
                          productId: '',
                          productName: '',
                          price: 0,
                          currency: 'JPY',
                          quantity: 1,
                          category: entry.key,
                          purchaseDate: DateTime.now(),
                          isReturned: false,
                          isRefunded: false,
                          metadata: {},
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ).categoryDisplayName,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${AmazonPurchase._formatPrice(entry.value, 'JPY')} ($percentage%)',
                        style: const TextStyle(
                          color: Color(0xFFFF9900),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / stats.totalSpent,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 月別支出チャート
  Widget _buildMonthlySpendingChart(AmazonPurchaseStats stats) {
    final sortedMonths = stats.spentByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月別支出',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedMonths.take(6).map((entry) {
            final parts = entry.key.split('-');
            final month = '${parts[0]}年${int.parse(parts[1])}月';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    AmazonPurchase._formatPrice(entry.value, 'JPY'),
                    style: const TextStyle(
                      color: Color(0xFFFF9900),
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

  /// トップブランド
  Widget _buildTopBrands(AmazonPurchaseStats stats) {
    if (stats.topBrands.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'よく購入するブランド',
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
            children: stats.topBrands.map((brand) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9900).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9900).withOpacity(0.3)),
              ),
              child: Text(
                brand,
                style: const TextStyle(
                  color: Color(0xFFFF9900),
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
              color: const Color(0xFFFF9900).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Color(0xFFFF9900),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '購入履歴がありません',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'OCRボタンから購入履歴を読み込んでください',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// カテゴリアイコン取得
  IconData _getCategoryIcon(AmazonPurchaseCategory category) {
    switch (category) {
      case AmazonPurchaseCategory.books:
        return Icons.menu_book;
      case AmazonPurchaseCategory.electronics:
        return Icons.devices;
      case AmazonPurchaseCategory.clothing:
        return Icons.checkroom;
      case AmazonPurchaseCategory.home:
        return Icons.home;
      case AmazonPurchaseCategory.beauty:
        return Icons.face;
      case AmazonPurchaseCategory.sports:
        return Icons.sports_basketball;
      case AmazonPurchaseCategory.toys:
        return Icons.toys;
      case AmazonPurchaseCategory.food:
        return Icons.restaurant;
      case AmazonPurchaseCategory.automotive:
        return Icons.directions_car;
      case AmazonPurchaseCategory.health:
        return Icons.health_and_safety;
      case AmazonPurchaseCategory.music:
        return Icons.music_note;
      case AmazonPurchaseCategory.video:
        return Icons.movie;
      case AmazonPurchaseCategory.software:
        return Icons.computer;
      case AmazonPurchaseCategory.pet:
        return Icons.pets;
      case AmazonPurchaseCategory.baby:
        return Icons.child_care;
      case AmazonPurchaseCategory.industrial:
        return Icons.build;
      case AmazonPurchaseCategory.other:
        return Icons.category;
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
    await ref.read(amazonPurchaseActionProvider).refreshPurchaseHistory();
  }

  /// OCR完了処理
  void _handleOcrComplete(List<AmazonPurchase> purchases) {
    if (purchases.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${purchases.length}件の購入履歴を読み込みました'),
          backgroundColor: const Color(0xFFFF9900),
        ),
      );
    }
  }

  /// 購入詳細画面へ遷移
  void _navigateToPurchaseDetail(AmazonPurchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmazonPurchaseDetailScreen(purchase: purchase),
      ),
    );
  }

  /// フィルター画面へ遷移
  void _navigateToFilterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AmazonFilterScreen(),
      ),
    );
  }

  /// カテゴリ削除
  void _removeCategory(AmazonPurchaseCategory category) {
    final filter = ref.read(amazonPurchaseFilterProvider);
    final newCategories = List<AmazonPurchaseCategory>.from(filter.categories ?? [])
      ..remove(category);
    
    ref.read(amazonPurchaseActionProvider).updateFilter(
      filter.copyWith(categories: newCategories.isEmpty ? null : newCategories),
    );
  }

  /// 検索クエリクリア
  void _clearSearchQuery() {
    final filter = ref.read(amazonPurchaseFilterProvider);
    ref.read(amazonPurchaseActionProvider).updateFilter(
      filter.copyWith(searchQuery: null),
    );
  }

  /// 日付範囲クリア
  void _clearDateRange() {
    final filter = ref.read(amazonPurchaseFilterProvider);
    ref.read(amazonPurchaseActionProvider).updateFilter(
      filter.copyWith(startDate: null, endDate: null),
    );
  }
}
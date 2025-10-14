import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/affiliate_service.dart';
import 'revenue_distribution_service.dart';

/// アフィリエイト収益情報を表すモデルクラス（広告収益は除外）
class AffiliateRevenue {
  final double totalRevenue;
  final double starShare;
  final double platformShare;
  final DateTime startDate;
  final DateTime endDate;

  AffiliateRevenue({
    required this.totalRevenue,
    required this.starShare,
    required this.platformShare,
    required this.startDate,
    required this.endDate,
  });
}

/// スターのアフィリエイト収益を提供するプロバイダー（広告収益は除外）
final affiliateRevenueProvider = FutureProvider.family<AffiliateRevenue, String>((ref, starId) async {
  final revenueService = ref.watch(revenueDistributionServiceProvider);
  
  // 過去30日間の収益を計算（アフィリエイトのみ）
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  
  final revenueData = await revenueService.calculateRevenueShare(starId, startDate, endDate);
  final affiliateData = revenueData['affiliate_revenue'];
  
  return AffiliateRevenue(
    totalRevenue: affiliateData['total'] ?? 0.0,
    starShare: affiliateData['star_share'] ?? 0.0,
    platformShare: affiliateData['platform_share'] ?? 0.0,
    startDate: startDate,
    endDate: endDate,
  );
});

/// アフィリエイト収益ダッシュボードウィジェット（広告収益は表示しない）
class AffiliateRevenueDashboard extends ConsumerWidget {
  final String starId;

  const AffiliateRevenueDashboard({
    super.key,
    required this.starId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(affiliateRevenueProvider(starId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'アフィリエイト収益',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '過去30日',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            revenueAsync.when(
              data: (revenue) => _buildRevenueContent(revenue),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorContent(error),
            ),
            
            const SizedBox(height: 16),
            
            // 注意事項
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '広告収益は100%運営に帰属します。スターには分配されません。',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueContent(AffiliateRevenue revenue) {
    return Column(
      children: [
        // 総収益
        _buildRevenueCard(
          title: '総アフィリエイト収益',
          amount: revenue.totalRevenue,
          color: Colors.blue,
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        
        // 分配詳細
        Row(
          children: [
            Expanded(
              child: _buildRevenueCard(
                title: 'あなたの取り分',
                subtitle: '(70%)',
                amount: revenue.starShare,
                color: Colors.green,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRevenueCard(
                title: 'プラットフォーム',
                subtitle: '(30%)',
                amount: revenue.platformShare,
                color: Colors.grey,
                icon: Icons.business,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 詳細ボタン
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showDetailedRevenue(revenue),
            icon: const Icon(Icons.analytics),
            label: const Text('詳細な収益分析を見る'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard({
    required String title,
    String? subtitle,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '¥${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 48),
          const SizedBox(height: 8),
          Text(
            '収益データの読み込みに失敗しました',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedRevenue(AffiliateRevenue revenue) {
    // 詳細な収益分析画面を表示
    // 実装は省略
  }
}

/// 収益履歴ウィジェット
class RevenueHistoryWidget extends ConsumerWidget {
  final String starId;

  const RevenueHistoryWidget({
    super.key,
    required this.starId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '収益履歴',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 履歴リスト
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(revenueDistributionServiceProvider).getRevenueHistory(starId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Text('エラー: ${snapshot.error}');
                }
                
                final history = snapshot.data ?? [];
                
                if (history.isEmpty) {
                  return const Center(
                    child: Text('収益履歴がありません'),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryItem(item);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final revenueType = item['revenue_type'] as String;
    final starShare = item['star_share'] as double;
    final createdAt = DateTime.parse(item['created_at']);
    
    // 広告収益の場合はスター分配がないことを明示
    final isAffiliate = revenueType == 'affiliate';
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAffiliate ? Colors.green[100] : Colors.grey[100],
        child: Icon(
          isAffiliate ? Icons.link : Icons.ads_click,
          color: isAffiliate ? Colors.green : Colors.grey,
        ),
      ),
      title: Text(
        isAffiliate ? 'アフィリエイト収益' : '広告収益（運営収益）',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${createdAt.year}/${createdAt.month}/${createdAt.day}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isAffiliate ? '¥${starShare.toStringAsFixed(0)}' : '¥0',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAffiliate ? Colors.green : Colors.grey,
            ),
          ),
          if (!isAffiliate)
            const Text(
              '運営収益',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

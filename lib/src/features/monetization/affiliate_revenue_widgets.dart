import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/affiliate_service.dart';

/// アフィリエイト収益情報を表すモデルクラス
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

/// スターのアフィリエイト収益を提供するプロバイダー
final affiliateRevenueProvider = FutureProvider.family<AffiliateRevenue, String>((ref, starId) async {
  final affiliateService = ref.watch(affiliateServiceProvider);
  
  // 過去30日間の収益を計算
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  
  final revenueData = await affiliateService.calculateAffiliateRevenue(
    starId,
    startDate: startDate,
    endDate: endDate,
  );
  
  return AffiliateRevenue(
    totalRevenue: revenueData['totalRevenue'] ?? 0.0,
    starShare: revenueData['starShare'] ?? 0.0,
    platformShare: revenueData['platformShare'] ?? 0.0,
    startDate: startDate,
    endDate: endDate,
  );
});

/// アフィリエイト収益ダッシュボードウィジェット
class AffiliateRevenueDashboard extends ConsumerWidget {
  final String starId;

  const AffiliateRevenueDashboard({
    Key? key,
    required this.starId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(affiliateRevenueProvider(starId));

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: revenueAsync.when(
          data: (revenue) => _buildRevenueContent(context, revenue),
          loading: () => _buildLoadingContent(),
          error: (error, stackTrace) => _buildErrorContent(error),
        ),
      ),
    );
  }

  /// 収益情報の表示
  Widget _buildRevenueContent(BuildContext context, AffiliateRevenue revenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'アフィリエイト収益',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          '${_formatDate(revenue.startDate)} 〜 ${_formatDate(revenue.endDate)}',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16.0),
        
        // 総収益
        _buildRevenueItem(
          context,
          title: '総収益',
          amount: revenue.totalRevenue,
          color: Colors.blue,
        ),
        const SizedBox(height: 12.0),
        
        // 収益分配の内訳
        Row(
          children: [
            // スターの取り分（70%）
            Expanded(
              flex: 7,
              child: _buildRevenueItem(
                context,
                title: 'スターの取り分 (70%)',
                amount: revenue.starShare,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12.0),
            // プラットフォームの取り分（30%）
            Expanded(
              flex: 3,
              child: _buildRevenueItem(
                context,
                title: 'プラットフォーム (30%)',
                amount: revenue.platformShare,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16.0),
        const Divider(),
        const SizedBox(height: 8.0),
        
        // 注意書き
        Text(
          '※ 収益は毎月15日に確定し、月末に振り込まれます。',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 収益項目の表示
  Widget _buildRevenueItem(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '¥${_formatCurrency(amount)}',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// ローディング中の表示
  Widget _buildLoadingContent() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// エラー時の表示
  Widget _buildErrorContent(Object error) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'データの取得に失敗しました: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 日付のフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  /// 金額のフォーマット
  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}

/// アフィリエイト収益詳細画面
class AffiliateRevenueDetailScreen extends ConsumerWidget {
  final String starId;

  const AffiliateRevenueDetailScreen({
    Key? key,
    required this.starId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('収益詳細'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 収益ダッシュボード
            AffiliateRevenueDashboard(starId: starId),
            const SizedBox(height: 24.0),
            
            // 収益分配の説明
            const Card(
              elevation: 2.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '収益分配について',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      'Starlistでは、アフィリエイト収益をスターとプラットフォームで分配しています。スターには収益の70%、プラットフォームには30%が配分されます。',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'この分配率は、スターの皆様の活動を最大限サポートするために設定されています。業界標準の分配率と比較しても、スターに有利な条件となっています。',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            
            // 収益向上のヒント
            Card(
              elevation: 2.0,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                          '収益向上のヒント',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    _buildTip(
                      icon: Icons.favorite,
                      title: 'あなたが本当に好きな商品を紹介しましょう',
                      description: '本当に気に入っている商品を紹介することで、ファンの共感を得やすくなります。',
                    ),
                    const SizedBox(height: 8.0),
                    _buildTip(
                      icon: Icons.people,
                      title: 'ファンとの信頼関係を大切に',
                      description: '信頼関係があるほど、あなたのおすすめする商品がファンに響きます。',
                    ),
                    const SizedBox(height: 8.0),
                    _buildTip(
                      icon: Icons.auto_awesome,
                      title: '商品の魅力を具体的に伝える',
                      description: '「なぜ良いのか」「どう使っているか」など、具体的なエピソードが説得力を高めます。',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ヒント項目の表示
  Widget _buildTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.0,
          color: Colors.blue[700],
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

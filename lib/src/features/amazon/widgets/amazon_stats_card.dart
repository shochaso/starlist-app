import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/amazon_models.dart';

/// Amazon統計カードウィジェット
class AmazonStatsCard extends StatelessWidget {
  final AmazonPurchaseStats stats;

  const AmazonStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9900),
            Color(0xFFFF6600),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9900).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 期間表示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('yyyy/MM/dd').format(stats.periodStart)} - ${DateFormat('yyyy/MM/dd').format(stats.periodEnd)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 総支出額
          Column(
            children: [
              const Text(
                '総支出額',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatPrice(stats.totalSpent, stats.currency),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 統計グリッド
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.shopping_bag,
                label: '購入数',
                value: '${stats.totalPurchases}件',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              _buildStatItem(
                icon: Icons.attach_money,
                label: '平均単価',
                value: _formatPrice(stats.averageOrderValue, stats.currency),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.assignment_return,
                label: '返品',
                value: '${stats.totalReturns}件',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              _buildStatItem(
                icon: Icons.payments,
                label: '返金',
                value: '${stats.totalRefunds}件',
              ),
            ],
          ),
          
          // 最も多いカテゴリ
          if (stats.purchasesByCategory.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '最も購入しているカテゴリ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTopCategory(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getTopCategoryCount()}件',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 統計項目ウィジェット
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 最も多いカテゴリを取得
  String _getTopCategory() {
    if (stats.purchasesByCategory.isEmpty) return '-';
    
    final topCategory = stats.purchasesByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return AmazonPurchase(
      id: '',
      userId: '',
      orderId: '',
      productId: '',
      productName: '',
      price: 0,
      currency: 'JPY',
      quantity: 1,
      category: topCategory,
      purchaseDate: DateTime.now(),
      isReturned: false,
      isRefunded: false,
      metadata: const {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).categoryDisplayName;
  }

  /// 最も多いカテゴリの件数を取得
  int _getTopCategoryCount() {
    if (stats.purchasesByCategory.isEmpty) return 0;
    
    return stats.purchasesByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .value;
  }

  /// 価格フォーマット
  String _formatPrice(double price, String currency) {
    final currencySymbols = {
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    final symbol = currencySymbols[currency] ?? currency;
    
    String formattedAmount;
    if (currency == 'JPY') {
      formattedAmount = price.toInt().toString();
    } else {
      formattedAmount = price.toStringAsFixed(2);
    }
    
    final parts = formattedAmount.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    if (parts.length > 1) {
      return '$symbol$integerPart.${parts[1]}';
    } else {
      return '$symbol$integerPart';
    }
  }
}
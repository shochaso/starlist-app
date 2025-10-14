import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/amazon_models.dart';

/// Amazon購入履歴カードウィジェット
class AmazonPurchaseCard extends StatelessWidget {
  final AmazonPurchase purchase;
  final VoidCallback? onTap;

  const AmazonPurchaseCard({
    super.key,
    required this.purchase,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                // 商品画像プレースホルダー
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: purchase.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            purchase.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 16),
                
                // 商品情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 商品名
                      Text(
                        purchase.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // ブランド名（存在する場合）
                      if (purchase.productBrand != null) ...[
                        Text(
                          purchase.productBrand!,
                          style: const TextStyle(
                            color: Color(0xFFFF9900),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      // 購入日とカテゴリ
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy/MM/dd').format(purchase.purchaseDate),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              purchase.categoryDisplayName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 価格と数量
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 数量
                          if (purchase.quantity > 1)
                            Text(
                              '数量: ${purchase.quantity}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          
                          // 価格
                          Text(
                            purchase.formattedTotalAmount,
                            style: const TextStyle(
                              color: Color(0xFFFF9900),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // 返品・返金状態
                      if (purchase.isReturned || purchase.isRefunded) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (purchase.isReturned)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.assignment_return,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '返品済み',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (purchase.isReturned && purchase.isRefunded)
                              const SizedBox(width: 8),
                            if (purchase.isRefunded)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.payments,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '返金済み',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                      
                      // レビュー評価（存在する場合）
                      if (purchase.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < purchase.rating!.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: const Color(0xFFFF9900),
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              purchase.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFFFF9900),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 矢印アイコン
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 画像プレースホルダー
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(purchase.category),
          color: const Color(0xFFFF9900),
          size: 32,
        ),
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
}
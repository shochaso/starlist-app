import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/amazon_models.dart';
import '../providers/amazon_providers.dart';

/// Amazon購入詳細画面
class AmazonPurchaseDetailScreen extends ConsumerWidget {
  final AmazonPurchase purchase;

  const AmazonPurchaseDetailScreen({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('購入詳細'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2A2A2A),
            onSelected: (value) => _handleMenuSelection(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('編集', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('削除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品画像セクション
            _buildImageSection(),
            
            // 商品情報セクション
            _buildProductInfoSection(),
            
            // 価格詳細セクション
            _buildPriceSection(),
            
            // 注文情報セクション
            _buildOrderInfoSection(),
            
            // レビューセクション（存在する場合）
            if (purchase.reviewText != null || purchase.rating != null)
              _buildReviewSection(),
            
            // メタデータセクション（デバッグ用）
            if (purchase.metadata.isNotEmpty)
              _buildMetadataSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 画像セクション
  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: double.infinity,
      color: const Color(0xFF2A2A2A),
      child: purchase.imageUrl != null
          ? Image.network(
              purchase.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  /// 画像プレースホルダー
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(purchase.category),
            size: 64,
            color: const Color(0xFFFF9900),
          ),
          const SizedBox(height: 16),
          Text(
            purchase.categoryDisplayName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 商品情報セクション
  Widget _buildProductInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品名
          Text(
            purchase.productName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // ブランド名
          if (purchase.productBrand != null)
            Text(
              purchase.productBrand!,
              style: const TextStyle(
                color: Color(0xFFFF9900),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 16),
          
          // カテゴリとステータス
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                label: purchase.categoryDisplayName,
                backgroundColor: const Color(0xFF333333),
                textColor: Colors.white,
              ),
              if (purchase.isReturned)
                _buildChip(
                  label: '返品済み',
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  textColor: Colors.orange,
                  icon: Icons.assignment_return,
                ),
              if (purchase.isRefunded)
                _buildChip(
                  label: '返金済み',
                  backgroundColor: Colors.green.withOpacity(0.2),
                  textColor: Colors.green,
                  icon: Icons.payments,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 価格セクション
  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            '価格詳細',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 単価
          _buildPriceRow(
            label: '単価',
            value: purchase.formattedPrice,
          ),
          const SizedBox(height: 8),
          
          // 数量
          _buildPriceRow(
            label: '数量',
            value: '${purchase.quantity}個',
          ),
          const Divider(color: Color(0xFF333333), height: 24),
          
          // 合計
          _buildPriceRow(
            label: '合計金額',
            value: purchase.formattedTotalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// 注文情報セクション
  Widget _buildOrderInfoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
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
            '注文情報',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 注文ID
          _buildInfoRow(
            icon: Icons.confirmation_number,
            label: '注文ID',
            value: purchase.orderId,
          ),
          const SizedBox(height: 12),
          
          // 商品ID
          _buildInfoRow(
            icon: Icons.qr_code,
            label: '商品ID',
            value: purchase.productId,
          ),
          const SizedBox(height: 12),
          
          // 購入日
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: '購入日',
            value: DateFormat('yyyy年MM月dd日').format(purchase.purchaseDate),
          ),
          
          // 配送日
          if (purchase.deliveryDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.local_shipping,
              label: '配送日',
              value: DateFormat('yyyy年MM月dd日').format(purchase.deliveryDate!),
            ),
          ],
        ],
      ),
    );
  }

  /// レビューセクション
  Widget _buildReviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'レビュー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              if (purchase.rating != null)
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < purchase.rating!.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 18,
                        color: const Color(0xFFFF9900),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      purchase.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFFFF9900),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (purchase.reviewText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                purchase.reviewText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// メタデータセクション
  Widget _buildMetadataSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'データソース',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ソース: ${purchase.metadata['source'] ?? 'unknown'}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          if (purchase.metadata['extraction_method'] != null)
            Text(
              '抽出方法: ${purchase.metadata['extraction_method']}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  /// チップウィジェット
  Widget _buildChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 価格行
  Widget _buildPriceRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFFFF9900) : Colors.white,
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 情報行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF9900)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
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

  /// メニュー選択処理
  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'edit':
        // TODO: 編集画面への遷移
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('編集機能は開発中です')),
        );
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
    }
  }

  /// 削除確認ダイアログ
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '購入履歴を削除',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'この購入履歴を削除してもよろしいですか？\nこの操作は取り消せません。',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(amazonPurchaseActionProvider).deletePurchase(purchase.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
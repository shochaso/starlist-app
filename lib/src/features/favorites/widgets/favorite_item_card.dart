import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/services/image_url_builder.dart';

import '../models/favorite_item_model.dart';
import '../providers/favorite_provider.dart';
/// お気に入りアイテムを表示するカードウィジェット
class FavoriteItemCard extends ConsumerWidget {
  final FavoriteItemModel item;
  final VoidCallback? onTap;

  const FavoriteItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      child: InkWell(
        onTap: onTap ?? () async {
          if (item.url != null) {
            final url = Uri.parse(item.url!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイル画像
            if (item.thumbnailUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  ImageUrlBuilder.thumbnail(item.thumbnailUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // 説明文
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // アイテムタイプとアクション
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // アイテムタイプ（YouTube、記事など）
                      Chip(
                        label: Text(
                          _getItemTypeLabel(item.itemType),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getItemTypeColor(item.itemType),
                        padding: EdgeInsets.zero,
                      ),
                      
                      // お気に入り削除ボタン
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          _showRemoveDialog(context, ref);
                        },
                      ),
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

  /// アイテムタイプに基づいてラベルを取得
  String _getItemTypeLabel(String itemType) {
    switch (itemType) {
      case 'youtube':
        return 'YouTube';
      case 'article':
        return '記事';
      case 'product':
        return '商品';
      default:
        return itemType;
    }
  }

  /// アイテムタイプに基づいて色を取得
  Color _getItemTypeColor(String itemType) {
    switch (itemType) {
      case 'youtube':
        return Colors.red.shade100;
      case 'article':
        return Colors.blue.shade100;
      case 'product':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// お気に入り削除確認ダイアログを表示
  void _showRemoveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('お気に入りから削除'),
        content: Text('「${item.title}」をお気に入りから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final favoriteNotifier = ref.read(favoriteNotifierProvider(item.userId).notifier);
              favoriteNotifier.removeFavorite(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('お気に入りから削除しました')),
              );
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 

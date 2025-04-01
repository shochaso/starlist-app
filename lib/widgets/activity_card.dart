import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starlist_app/models/activity.dart';
import 'package:starlist_app/theme/app_theme.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const ActivityCard({
    Key? key,
    required this.activity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アクティビティ画像
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  // 画像
                  Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.network(
                      activity.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            _getTypeIcon(),
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  // タイプバッジ
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(),
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _getTypeText(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // アクティビティ情報
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    activity.content,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 日付
                      Text(
                        DateFormat('yyyy/MM/dd').format(activity.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      // 価格（あれば）
                      if (activity.price != null)
                        Text(
                          '¥${NumberFormat('#,###').format(activity.price)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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

  IconData _getTypeIcon() {
    switch (activity.type) {
      case 'youtube':
        return Icons.play_circle_outline;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'app':
        return Icons.apps_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      default:
        return Icons.star_outline;
    }
  }

  String _getTypeText() {
    switch (activity.type) {
      case 'youtube':
        return '動画';
      case 'purchase':
        return '購入';
      case 'music':
        return '音楽';
      case 'app':
        return 'アプリ';
      case 'food':
        return '食事';
      default:
        return activity.type;
    }
  }

  Color _getTypeColor() {
    switch (activity.type) {
      case 'youtube':
        return Colors.red;
      case 'purchase':
        return Colors.green;
      case 'music':
        return Colors.purple;
      case 'app':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
} 
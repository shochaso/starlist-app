import 'package:flutter/material.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/theme/app_theme.dart';

class StarCard extends StatelessWidget {
  final Star star;
  final VoidCallback? onTap;
  final bool isCompact;

  const StarCard({
    Key? key,
    required this.star,
    this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スター画像
            AspectRatio(
              aspectRatio: isCompact ? 1.0 : 1.5,
              child: Stack(
                children: [
                  // 画像
                  Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.network(
                      star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            star.name,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  // ランクバッジ
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getRankColor(star.rank),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        star.rank,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // スター情報
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    star.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    star.category,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isCompact ? 12 : 14,
                    ),
                  ),
                  if (!isCompact) SizedBox(height: 4),
                  if (!isCompact)
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatFollowers(star.followers),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
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
  
  // フォロワー数のフォーマット（1万以上は万単位で表示）
  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      double man = followers / 10000;
      return '${man.toStringAsFixed(man.truncateToDouble() == man ? 0 : 1)}万人';
    } else {
      return '${followers}人';
    }
  }
} 
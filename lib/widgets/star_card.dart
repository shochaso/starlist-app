import 'package:flutter/material.dart';
import '../models/star.dart';

class StarCard extends StatelessWidget {
  final Star star;
  final VoidCallback? onTap;
  final String? postId; // 投稿ID（他機能との連携用）

  const StarCard({
    Key? key,
    required this.star,
    this.onTap,
    this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isDarkMode ? 0 : 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // スター画像
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                          child: Center(
                            child: Text(
                              star.name.substring(0, 1),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // グラデーションオーバーレイ（任意）
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ランクバッジ
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRankColor(star.rank),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          star.rank,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // スター情報
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    star.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    star.platforms.isNotEmpty ? star.platforms.first : '',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatFollowers(star.followers),
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  // ホームカードではリアクションボタンを非表示
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // フォロワー数のフォーマット
  String _formatFollowers(int followers) {
    if (followers >= 10000) {
      double man = followers / 10000;
      return '${man.toStringAsFixed(man.truncateToDouble() == man ? 0 : 1)}万';
    } else if (followers >= 1000) {
      double kilo = followers / 1000;
      return '${kilo.toStringAsFixed(kilo.truncateToDouble() == kilo ? 0 : 1)}千';
    } else {
      return '$followers';
    }
  }

  // ランクに応じた色を返す
  Color _getRankColor(String rank) {
    switch (rank) {
      case 'スーパー':
      case 'S+':
        return Colors.purple;
      case 'プラチナ':
      case 'S':
        return Colors.blue;
      case 'ゴールド':
      case 'A+':
        return Colors.green;
      case 'シルバー':
      case 'A':
        return Colors.teal;
      case 'ブロンズ':
      case 'B+':
        return Colors.amber;
      case 'レギュラー':
      case 'B':
        return Colors.orange;
      default:
        return Colors.grey.shade700;
    }
  }
} 

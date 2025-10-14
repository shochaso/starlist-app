import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(isDarkMode ? 0.8 : 1.0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                icon,
                color: textColor,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // カテゴリー名からアイコンを取得するための静的メソッド
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'YouTuber':
        return Icons.play_circle_filled;
      case 'ミュージシャン':
        return Icons.music_note;
      case 'アーティスト':
        return Icons.palette;
      case 'モデル':
        return Icons.face;
      case 'ストリーマー':
        return Icons.stream;
      case 'イラストレーター':
        return Icons.brush;
      case 'ゲーマー':
        return Icons.sports_esports;
      case 'コメディアン':
        return Icons.theater_comedy;
      case 'インフルエンサー':
        return Icons.trending_up;
      default:
        return Icons.star;
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:starlist_app/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;
  final IconData icon;
  
  const CategoryCard({
    Key? key,
    required this.category,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // アイコン円形
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          // カテゴリー名
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
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
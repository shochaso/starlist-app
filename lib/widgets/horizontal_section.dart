import 'package:flutter/material.dart';
import 'package:starlist_app/theme/app_theme.dart';

class HorizontalSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSeeMore;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const HorizontalSection({
    Key? key,
    required this.title,
    required this.children,
    this.onSeeMore,
    this.itemWidth = 140,
    this.itemHeight = 200,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー（タイトル + もっと見るボタン）
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onSeeMore != null)
                  TextButton(
                    onPressed: onSeeMore,
                    child: Row(
                      children: [
                        Text(
                          'もっと見る',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // 横スクロールリスト
          Container(
            height: itemHeight,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return Container(
                  width: itemWidth,
                  margin: EdgeInsets.only(
                    right: index == children.length - 1 ? 0 : spacing,
                  ),
                  child: children[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
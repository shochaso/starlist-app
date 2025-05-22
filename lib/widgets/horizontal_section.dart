import 'package:flutter/material.dart';

class HorizontalSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSeeMorePressed;
  final String? seeMoreText;
  final VoidCallback? onSeeMoreTap;
  final Widget? trailing;
  final double itemWidth;
  final double itemHeight;
  final double spacing;

  const HorizontalSection({
    Key? key,
    required this.title,
    required this.children,
    this.onSeeMorePressed,
    this.seeMoreText,
    this.onSeeMoreTap,
    this.trailing,
    this.itemWidth = 150,
    this.itemHeight = 200,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              if (onSeeMorePressed != null || onSeeMoreTap != null)
                TextButton(
                  onPressed: onSeeMoreTap ?? onSeeMorePressed,
                  child: Text(
                    seeMoreText ?? 'すべて表示',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 水平スクロールビュー
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            itemBuilder: (context, index) {
              return Container(
                width: itemWidth,
                margin: EdgeInsets.only(right: spacing),
                child: children[index],
              );
            },
          ),
        ),
      ],
    );
  }
} 
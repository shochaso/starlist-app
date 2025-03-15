import 'package:flutter/material.dart';

/// バッジウィジェット
class BadgeWidget extends StatelessWidget {
  /// バッジのテキスト
  final String text;
  
  /// バッジの色
  final Color? color;
  
  /// テキストの色
  final Color? textColor;
  
  /// バッジの形状
  final BadgeShape shape;
  
  /// バッジのサイズ
  final BadgeSize size;
  
  /// アイコン
  final IconData? icon;
  
  /// タップ時のコールバック
  final VoidCallback? onTap;

  /// コンストラクタ
  const BadgeWidget({
    Key? key,
    required this.text,
    this.color,
    this.textColor,
    this.shape = BadgeShape.rounded,
    this.size = BadgeSize.medium,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;
    final badgeTextColor = textColor ?? theme.colorScheme.onPrimary;
    
    // サイズに基づくパディングとフォントサイズを設定
    double horizontalPadding;
    double verticalPadding;
    double fontSize;
    double iconSize;
    
    switch (size) {
      case BadgeSize.small:
        horizontalPadding = 8.0;
        verticalPadding = 2.0;
        fontSize = 10.0;
        iconSize = 12.0;
        break;
      case BadgeSize.medium:
        horizontalPadding = 12.0;
        verticalPadding = 4.0;
        fontSize = 12.0;
        iconSize = 14.0;
        break;
      case BadgeSize.large:
        horizontalPadding = 16.0;
        verticalPadding = 6.0;
        fontSize = 14.0;
        iconSize = 16.0;
        break;
    }
    
    // 形状に基づく境界線の半径を設定
    BorderRadius borderRadius;
    
    switch (shape) {
      case BadgeShape.rounded:
        borderRadius = BorderRadius.circular(16.0);
        break;
      case BadgeShape.square:
        borderRadius = BorderRadius.circular(4.0);
        break;
      case BadgeShape.pill:
        borderRadius = BorderRadius.circular(50.0);
        break;
    }
    
    // バッジの内容を作成
    Widget badgeContent;
    
    if (icon != null) {
      badgeContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: badgeTextColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              color: badgeTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      badgeContent = Text(
        text,
        style: TextStyle(
          color: badgeTextColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    // バッジウィジェットを作成
    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: borderRadius,
      ),
      child: badgeContent,
    );
    
    // タップ可能にする
    if (onTap != null) {
      badge = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: badge,
      );
    }
    
    return badge;
  }
}

/// バッジの形状
enum BadgeShape {
  /// 丸みを帯びた四角形
  rounded,
  
  /// 四角形
  square,
  
  /// 丸形（ピル形状）
  pill,
}

/// バッジのサイズ
enum BadgeSize {
  /// 小
  small,
  
  /// 中
  medium,
  
  /// 大
  large,
}

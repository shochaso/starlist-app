import 'package:flutter/material.dart';

/// カスタムカードウィジェット
class CustomCard extends StatelessWidget {
  /// カードの子ウィジェット
  final Widget child;
  
  /// カードの高さ
  final double? height;
  
  /// カードの幅
  final double? width;
  
  /// カードの角の丸み
  final double borderRadius;
  
  /// カードの影の強さ
  final double elevation;
  
  /// カードの色
  final Color? color;
  
  /// カードの境界線
  final Border? border;
  
  /// カードのパディング
  final EdgeInsetsGeometry padding;
  
  /// カードのマージン
  final EdgeInsetsGeometry margin;
  
  /// タップ時のコールバック
  final VoidCallback? onTap;

  /// コンストラクタ
  const CustomCard({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.elevation = 2.0,
    this.color,
    this.border,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(0.0),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardColor;
    
    Widget cardWidget = Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 2,
                  spreadRadius: elevation / 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );
    
    if (onTap != null) {
      cardWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardWidget,
      );
    }
    
    return Padding(
      padding: margin,
      child: cardWidget,
    );
  }
}

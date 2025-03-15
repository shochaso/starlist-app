import 'package:flutter/material.dart';

/// ローディングインジケーターウィジェット
class LoadingIndicator extends StatelessWidget {
  /// サイズ
  final double size;
  
  /// 色
  final Color? color;
  
  /// 太さ
  final double strokeWidth;
  
  /// テキスト
  final String? text;
  
  /// テキストスタイル
  final TextStyle? textStyle;

  /// コンストラクタ
  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
    this.text,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!,
            style: textStyle ?? theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// カスタムボタンウィジェット
class CustomButton extends StatelessWidget {
  /// ボタンのテキスト
  final String text;
  
  /// ボタンを押したときのコールバック
  final VoidCallback? onPressed;
  
  /// ボタンの色
  final Color? color;
  
  /// テキストの色
  final Color? textColor;
  
  /// ボタンの高さ
  final double height;
  
  /// ボタンの幅
  final double? width;
  
  /// ボタンの角の丸み
  final double borderRadius;
  
  /// ボタンの影の強さ
  final double elevation;
  
  /// アイコン
  final IconData? icon;
  
  /// アイコンの位置
  final IconPosition iconPosition;
  
  /// ボタンのパディング
  final EdgeInsetsGeometry padding;

  /// コンストラクタ
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.height = 50.0,
    this.width,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? theme.colorScheme.onPrimary;
    
    Widget buttonContent;
    
    if (icon != null) {
      final iconWidget = Icon(
        icon,
        color: buttonTextColor,
        size: 20.0,
      );
      
      if (iconPosition == IconPosition.left) {
        buttonContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        buttonContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8.0),
            iconWidget,
          ],
        );
      }
    } else {
      buttonContent = Text(
        text,
        style: TextStyle(
          color: buttonTextColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}

/// アイコンの位置
enum IconPosition {
  /// 左側
  left,
  
  /// 右側
  right,
}

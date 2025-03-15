import 'package:flutter/material.dart';

/// エラーメッセージウィジェット
class ErrorMessage extends StatelessWidget {
  /// エラーメッセージ
  final String message;
  
  /// アイコン
  final IconData? icon;
  
  /// アイコンの色
  final Color? iconColor;
  
  /// テキストスタイル
  final TextStyle? textStyle;
  
  /// 再試行ボタンのテキスト
  final String? retryText;
  
  /// 再試行ボタンを押したときのコールバック
  final VoidCallback? onRetry;

  /// コンストラクタ
  const ErrorMessage({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.textStyle,
    this.retryText,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = iconColor ?? theme.colorScheme.error;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          message,
          style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null && retryText != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(retryText!),
          ),
        ],
      ],
    );
  }
}

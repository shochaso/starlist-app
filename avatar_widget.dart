import 'package:flutter/material.dart';

/// アバターウィジェット
class AvatarWidget extends StatelessWidget {
  /// 画像URL
  final String? imageUrl;
  
  /// プレースホルダーテキスト
  final String? placeholderText;
  
  /// サイズ
  final double size;
  
  /// 境界線の幅
  final double borderWidth;
  
  /// 境界線の色
  final Color? borderColor;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// オンライン状態を表示するかどうか
  final bool showOnlineStatus;
  
  /// オンラインかどうか
  final bool isOnline;
  
  /// タップ時のコールバック
  final VoidCallback? onTap;

  /// コンストラクタ
  const AvatarWidget({
    Key? key,
    this.imageUrl,
    this.placeholderText,
    this.size = 48.0,
    this.borderWidth = 0.0,
    this.borderColor,
    this.backgroundColor,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarBorderColor = borderColor ?? theme.colorScheme.primary;
    final avatarBackgroundColor = backgroundColor ?? theme.colorScheme.surface;
    
    Widget avatar;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // 画像がある場合
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: avatarBackgroundColor,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else if (placeholderText != null && placeholderText!.isNotEmpty) {
      // プレースホルダーテキストがある場合
      final initials = _getInitials(placeholderText!);
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: avatarBackgroundColor,
        child: Text(
          initials,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: size / 3,
          ),
        ),
      );
    } else {
      // デフォルトのアイコン
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: avatarBackgroundColor,
        child: Icon(
          Icons.person,
          size: size / 2,
          color: theme.colorScheme.onSurface,
        ),
      );
    }
    
    // 境界線を追加
    if (borderWidth > 0) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: avatarBorderColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }
    
    // オンライン状態を表示
    if (showOnlineStatus) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size / 4,
              height: size / 4,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // タップ可能にする
    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: avatar,
    );
  }
  
  /// テキストからイニシャルを取得
  String _getInitials(String text) {
    final words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1 && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '';
  }
}

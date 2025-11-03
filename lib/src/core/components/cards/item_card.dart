import 'package:flutter/material.dart';
import 'package:starlist_app/services/image_url_builder.dart';

/// リストビュー内で使用される汎用的なアイテムカード
class ItemCard extends StatelessWidget {
  /// カードのタイトル
  final String title;
  
  /// カードのサブタイトル（オプション）
  final String? subtitle;
  
  /// カードの説明文（オプション）
  final String? description;
  
  /// カードに表示するアイコン（オプション）
  final IconData? leadingIcon;
  
  /// カードの右側に表示するウィジェット（オプション）
  final Widget? trailing;
  
  /// カードの画像URL（オプション）
  final String? imageUrl;
  
  /// カードがタップされたときのコールバック
  final VoidCallback? onTap;
  
  /// カードを長押ししたときのコールバック
  final VoidCallback? onLongPress;
  
  /// カードの高さ（オプション）
  final double? height;
  
  /// カードの内部余白
  final EdgeInsetsGeometry padding;
  
  /// カードの外部余白
  final EdgeInsetsGeometry margin;
  
  /// カードの丸み
  final double borderRadius;
  
  /// カードの影の不透明度
  final double shadowOpacity;

  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leadingIcon,
    this.trailing,
    this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.borderRadius = 12.0,
    this.shadowOpacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(shadowOpacity),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 先頭のアイコンまたは画像
              if (leadingIcon != null || imageUrl != null) ...[
                _buildLeading(),
                const SizedBox(width: 16.0),
              ],
              
              // コンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // タイトル
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // サブタイトル（存在する場合）
                    if (subtitle != null) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // 説明文（存在する場合）
                    if (description != null) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // 右側のウィジェット（存在する場合）
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 先頭に表示するアイコンまたは画像を構築
  Widget _buildLeading() {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius / 2),
        child: Image.network(
          ImageUrlBuilder.thumbnail(
            imageUrl!,
            width: 320,
          ),
          width: 60.0,
          height: 60.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60.0,
              height: 60.0,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      );
    } else if (leadingIcon != null) {
      return Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius / 2),
        ),
        child: Icon(
          leadingIcon,
          color: Colors.grey.shade700,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
} 

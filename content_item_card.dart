import 'package:flutter/material.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/theme/app_colors.dart';

/// コンテンツアイテムカードウィジェット
class ContentItemCard extends StatelessWidget {
  /// コンテンツ消費モデル
  final ContentConsumptionModel content;
  
  /// カードの高さ
  final double? height;
  
  /// カードの幅
  final double? width;
  
  /// 詳細表示するかどうか
  final bool showDetails;
  
  /// タップ時のコールバック
  final VoidCallback? onTap;
  
  /// 共有ボタンを押したときのコールバック
  final VoidCallback? onShare;
  
  /// いいねボタンを押したときのコールバック
  final VoidCallback? onLike;
  
  /// コメントボタンを押したときのコールバック
  final VoidCallback? onComment;

  /// コンストラクタ
  const ContentItemCard({
    Key? key,
    required this.content,
    this.height,
    this.width,
    this.showDetails = true,
    this.onTap,
    this.onShare,
    this.onLike,
    this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      height: height,
      width: width,
      onTap: onTap,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分（ユーザー情報）
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // ユーザーアバター
                AvatarWidget(
                  imageUrl: content.user?.profileImageUrl,
                  placeholderText: content.user?.displayName,
                  size: 40,
                  borderWidth: 2,
                  borderColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                
                // ユーザー情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.user?.displayName ?? 'Unknown User',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${content.user?.username ?? 'unknown'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 日時
                Text(
                  _formatDate(content.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // コンテンツ画像（あれば）
          if (content.imageUrl != null && content.imageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(content.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // コンテンツ情報
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // カテゴリバッジ
                Row(
                  children: [
                    BadgeWidget(
                      text: _getCategoryText(content.contentType),
                      color: _getCategoryColor(content.contentType),
                      size: BadgeSize.small,
                    ),
                    if (content.isPrivate)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: BadgeWidget(
                          text: 'プライベート',
                          color: Colors.grey,
                          size: BadgeSize.small,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // タイトル
                Text(
                  content.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // 詳細情報
                if (showDetails && content.description != null && content.description!.isNotEmpty)
                  Text(
                    content.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                
                // 商品情報（あれば）
                if (content.productInfo != null && content.productInfo!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          content.productInfo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                
                // 場所情報（あれば）
                if (content.locationInfo != null && content.locationInfo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            content.locationInfo!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // アクションボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // いいねボタン
                    _buildActionButton(
                      icon: Icons.favorite,
                      count: content.likeCount,
                      isActive: content.isLiked,
                      activeColor: Colors.red,
                      onTap: onLike,
                    ),
                    
                    // コメントボタン
                    _buildActionButton(
                      icon: Icons.comment,
                      count: content.commentCount,
                      isActive: false,
                      activeColor: theme.colorScheme.primary,
                      onTap: onComment,
                    ),
                    
                    // 共有ボタン
                    _buildActionButton(
                      icon: Icons.share,
                      count: content.shareCount,
                      isActive: false,
                      activeColor: theme.colorScheme.primary,
                      onTap: onShare,
                    ),
                    
                    // 外部リンクボタン（あれば）
                    if (content.externalUrl != null && content.externalUrl!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          // 外部リンクを開く処理
                          // TODO: 外部リンクを開く処理を実装
                        },
                        iconSize: 20,
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// アクションボタンを構築
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? activeColor : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 日付をフォーマット
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '数秒前';
    }
  }
  
  /// コンテンツタイプからカテゴリテキストを取得
  String _getCategoryText(ContentType? type) {
    switch (type) {
      case ContentType.youtube:
        return 'YouTube';
      case ContentType.spotify:
        return '音楽';
      case ContentType.netflix:
        return '映像';
      case ContentType.book:
        return '書籍';
      case ContentType.shopping:
        return 'ショッピング';
      case ContentType.app:
        return 'アプリ';
      case ContentType.food:
        return '食事';
      default:
        return 'その他';
    }
  }
  
  /// コンテンツタイプからカテゴリ色を取得
  Color _getCategoryColor(ContentType? type) {
    switch (type) {
      case ContentType.youtube:
        return Colors.red;
      case ContentType.spotify:
        return Colors.green;
      case ContentType.netflix:
        return Colors.purple;
      case ContentType.book:
        return Colors.blue;
      case ContentType.shopping:
        return Colors.orange;
      case ContentType.app:
        return Colors.teal;
      case ContentType.food:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

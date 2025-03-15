import 'package:flutter/material.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/theme/app_colors.dart';

/// スタープロフィールカードウィジェット
class StarProfileCard extends StatelessWidget {
  /// ユーザーモデル
  final UserModel user;
  
  /// カードの高さ
  final double? height;
  
  /// カードの幅
  final double? width;
  
  /// 詳細表示するかどうか
  final bool showDetails;
  
  /// フォローボタンを表示するかどうか
  final bool showFollowButton;
  
  /// フォロー中かどうか
  final bool isFollowing;
  
  /// タップ時のコールバック
  final VoidCallback? onTap;
  
  /// フォローボタンを押したときのコールバック
  final VoidCallback? onFollow;
  
  /// メッセージボタンを押したときのコールバック
  final VoidCallback? onMessage;

  /// コンストラクタ
  const StarProfileCard({
    Key? key,
    required this.user,
    this.height,
    this.width,
    this.showDetails = true,
    this.showFollowButton = true,
    this.isFollowing = false,
    this.onTap,
    this.onFollow,
    this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      height: height,
      width: width,
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分（ユーザー情報）
          Row(
            children: [
              // ユーザーアバター
              AvatarWidget(
                imageUrl: user.profileImageUrl,
                placeholderText: user.displayName,
                size: 60,
                borderWidth: 2,
                borderColor: AppColors.primary,
              ),
              const SizedBox(width: 16),
              
              // ユーザー情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // バッジ
                    Row(
                      children: [
                        if (user.userType == UserType.star)
                          const BadgeWidget(
                            text: 'スター',
                            color: AppColors.primary,
                            size: BadgeSize.small,
                          ),
                        if (user.userType == UserType.admin)
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: BadgeWidget(
                              text: '管理者',
                              color: Colors.purple,
                              size: BadgeSize.small,
                            ),
                          ),
                        if (user.subscriptionTier != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: BadgeWidget(
                              text: _getSubscriptionTierText(user.subscriptionTier!),
                              color: _getSubscriptionTierColor(user.subscriptionTier!),
                              size: BadgeSize.small,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 詳細情報
          if (showDetails) ...[
            const SizedBox(height: 16),
            
            // バイオ
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 16),
            
            // 統計情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '${user.followerCount}',
                  'フォロワー',
                ),
                _buildStatItem(
                  context,
                  '${user.followingCount}',
                  'フォロー中',
                ),
                _buildStatItem(
                  context,
                  '${user.contentCount}',
                  'コンテンツ',
                ),
              ],
            ),
          ],
          
          // アクションボタン
          if (showFollowButton) ...[
            const SizedBox(height: 16),
            
            Row(
              children: [
                // フォローボタン
                Expanded(
                  child: CustomButton(
                    text: isFollowing ? 'フォロー中' : 'フォローする',
                    icon: isFollowing ? Icons.check : Icons.add,
                    color: isFollowing ? Colors.grey : theme.colorScheme.primary,
                    height: 40,
                    onPressed: onFollow,
                  ),
                ),
                
                // メッセージボタン
                if (onMessage != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: onMessage,
                      color: theme.colorScheme.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  /// 統計項目を構築
  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  /// サブスクリプション層からテキストを取得
  String _getSubscriptionTierText(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.solo:
        return 'ソロファン';
      case SubscriptionTier.light:
        return 'ライト';
      case SubscriptionTier.standard:
        return 'スタンダード';
      case SubscriptionTier.premium:
        return 'プレミアム';
      default:
        return '無料';
    }
  }
  
  /// サブスクリプション層から色を取得
  Color _getSubscriptionTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.solo:
        return Colors.blue;
      case SubscriptionTier.light:
        return Colors.green;
      case SubscriptionTier.standard:
        return Colors.orange;
      case SubscriptionTier.premium:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

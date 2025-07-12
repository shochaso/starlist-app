import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/post_model.dart';
import '../../providers/posts_provider.dart';
import '../providers/theme_provider_enhanced.dart';
import '../providers/membership_provider.dart';
import '../../features/premium/screens/premium_restriction_screen.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final bool isCompact;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    final membership = ref.watch(membershipProvider);
    
    // アクセス権限チェック
    AccessLevel userAccessLevel;
    switch (membership) {
      case MembershipType.free:
        userAccessLevel = AccessLevel.public;
        break;
      case MembershipType.light:
        userAccessLevel = AccessLevel.light;
        break;
      case MembershipType.standard:
        userAccessLevel = AccessLevel.standard;
        break;
      case MembershipType.premium:
        userAccessLevel = AccessLevel.premium;
        break;
    }

    final canAccess = post.canAccess(userAccessLevel);

    return GestureDetector(
      onTap: () {
        if (canAccess) {
          onTap?.call();
        } else {
          _showAccessRestriction(context, post);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canAccess 
                ? (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0))
                : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            width: canAccess ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: canAccess 
                  ? (isDark ? Colors.black : Colors.black).withValues(alpha: 0.08)
                  : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
              blurRadius: canAccess ? 12 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            _buildHeader(isDark, canAccess),
            
            // コンテンツ
            if (canAccess) ...[
              _buildContent(isDark),
            ] else ...[
              _buildRestrictedContent(isDark),
            ],
            
            // フッター
            _buildFooter(ref, isDark, canAccess),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool canAccess) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // アバター
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [post.authorColor, post.authorColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                post.authorAvatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 作者情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAccessLevelBadge(canAccess),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // 投稿タイプアイコン
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(post.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(post.type),
              color: _getTypeColor(post.type),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessLevelBadge(bool canAccess) {
    if (post.accessLevel == AccessLevel.public) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '公開',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: canAccess 
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canAccess ? Icons.star : Icons.lock,
            size: 10,
            color: canAccess ? Colors.amber : Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            post.accessLevel.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: canAccess ? Colors.amber : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Text(
            post.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.3,
            ),
          ),
          
          if (post.description != null) ...[
            const SizedBox(height: 8),
            Text(
              post.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
              maxLines: isCompact ? 2 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // コンテンツタイプ別表示
          _buildTypeSpecificContent(isDark),
          
          // タグ
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTags(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildRestrictedContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              '${post.accessLevel.displayName}限定コンテンツ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'このコンテンツを閲覧するには${post.accessLevel.displayName}が必要です',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificContent(bool isDark) {
    switch (post.type) {
      case PostType.youtube:
        return _buildYouTubeContent(isDark);
      case PostType.shopping:
        return _buildShoppingContent(isDark);
      default:
        return _buildDefaultContent(isDark);
    }
  }

  Widget _buildYouTubeContent(bool isDark) {
    final videos = post.content['videos'] as List<dynamic>? ?? [];
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF0000).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.youtube,
                color: const Color(0xFFFF0000),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${videos.length}本の動画を視聴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (post.content['totalDuration'] != null)
                Text(
                  '総視聴時間: ${post.content['totalDuration']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
            ],
          ),
        ),
        
        if (!isCompact && videos.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...videos.take(3).map((video) => _buildVideoItem(video, isDark)),
        ],
      ],
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              FontAwesomeIcons.play,
              color: Color(0xFFFF0000),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  video['channel'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (video['duration'] != null)
            Text(
              video['duration'],
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShoppingContent(bool isDark) {
    final items = post.content['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final totalAmount = post.content['totalAmount'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${items.length}点の商品を購入',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                '合計: ¥${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        if (!isCompact && items.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...items.take(3).map((item) => _buildShoppingItem(item, isDark)),
        ],
      ],
    );
  }

  Widget _buildShoppingItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['brand'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${(item['price'] as int? ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              if (item['color'] != null)
                Text(
                  item['color'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(bool isDark) {
    return const SizedBox.shrink();
  }

  Widget _buildTags(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: post.tags.take(5).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(WidgetRef ref, bool isDark, bool canAccess) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // いいねボタン
          GestureDetector(
            onTap: canAccess ? () {
              ref.read(postsProvider.notifier).toggleLike(post.id);
            } : null,
            child: Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : (canAccess 
                      ? (isDark ? Colors.white54 : Colors.black54)
                      : Colors.grey),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  post.likesCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: canAccess 
                        ? (isDark ? Colors.white54 : Colors.black54)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // コメントボタン
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: canAccess 
                    ? (isDark ? Colors.white54 : Colors.black54)
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                post.commentsCount.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: canAccess 
                      ? (isDark ? Colors.white54 : Colors.black54)
                      : Colors.grey,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          if (!canAccess)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock,
                    color: Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'プランをアップグレード',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(PostType type) {
    switch (type) {
      case PostType.youtube:
        return FontAwesomeIcons.youtube;
      case PostType.shopping:
        return Icons.shopping_bag;
      case PostType.music:
        return Icons.music_note;
      case PostType.food:
        return Icons.restaurant;
      case PostType.lifestyle:
        return Icons.auto_awesome;
      case PostType.other:
        return Icons.more_horiz;
    }
  }

  Color _getTypeColor(PostType type) {
    switch (type) {
      case PostType.youtube:
        return const Color(0xFFFF0000);
      case PostType.shopping:
        return Colors.green;
      case PostType.music:
        return Colors.purple;
      case PostType.food:
        return Colors.orange;
      case PostType.lifestyle:
        return Colors.pink;
      case PostType.other:
        return Colors.grey;
    }
  }

  void _showAccessRestriction(BuildContext context, PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumRestrictionScreen(
          contentTitle: post.title,
          contentType: post.type.displayName,
          starName: post.authorName,
          requiredPlan: post.accessLevel.displayName,
        ),
      ),
    );
  }
}
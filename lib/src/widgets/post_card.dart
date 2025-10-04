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

    final cardRadius = isCompact ? 20.0 : 24.0;

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
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: canAccess
                ? (isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFE2E8F0))
                : const Color(0xFFFF6B6B).withOpacity(0.35),
            width: canAccess ? 1 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF0F172A)).withOpacity(0.08),
              blurRadius: 28,
              offset: const Offset(0, 18),
              spreadRadius: -14,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cardRadius),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            _buildHeader(isDark, canAccess),
            
            // コンテンツ
              Flexible(
                child: canAccess 
                  ? _buildContent(isDark)
                  : _buildRestrictedContent(isDark),
              ),
            
            _buildSectionDivider(isDark),

            // フッター
            _buildFooter(ref, isDark, canAccess),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool canAccess) {
    final accent = _getTypeColor(post.type);
    final headerRadius = isCompact ? 16.0 : 18.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(isDark ? 0.2 : 0.12),
            accent.withOpacity(isDark ? 0.06 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(headerRadius)),
      ),
      child: Row(
        children: [
          // アバター
          Container(
            width: isCompact ? 34 : 36,
            height: isCompact ? 34 : 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [post.authorColor, post.authorColor.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: post.authorColor.withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                post.authorAvatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 10),
          
          // 作者情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        post.authorName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAccessLevelBadge(canAccess),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 10),

          Container(
            height: isCompact ? 28 : 32,
            width: isCompact ? 28 : 32,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Icon(
              _getTypeIcon(post.type),
              color: accent,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessLevelBadge(bool canAccess) {
    if (post.accessLevel == AccessLevel.public) {
      const Color base = Color(0xFF22C55E);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: base.withOpacity(0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: base.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 11, color: base),
            const SizedBox(width: 3),
            Text(
              '公開',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: base,
              ),
            ),
          ],
        ),
      );
    }

    final Color badgeColor = canAccess ? const Color(0xFFEAB308) : const Color(0xFFEF4444);
    final IconData badgeIcon = canAccess ? Icons.workspace_premium : Icons.lock_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeColor.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 11,
            color: badgeColor,
          ),
          const SizedBox(width: 3),
          Text(
            post.accessLevel.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // タイトル
          Text(
            post.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (!isCompact && post.description != null) ...[
            const SizedBox(height: 6),
            Text(
              post.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // コンテンツタイプ別表示
          _buildTypeSpecificContent(isDark),
          
          // タグ
          if (!isCompact && post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTags(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildRestrictedContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEF4444).withOpacity(isDark ? 0.28 : 0.16),
              const Color(0xFFEF4444).withOpacity(isDark ? 0.14 : 0.08),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.08 : 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFFEF4444),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${post.accessLevel.displayName}限定コンテンツ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'このコンテンツを見るには${post.accessLevel.displayName}メンバーへのアップグレードが必要です。',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                height: 1.5,
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

    const Color accent = Color(0xFFFF0000);
    final mainVideo = videos.isNotEmpty ? videos.first : null;
    final otherVideos = videos.length > 1 ? videos.skip(1).take(2).toList() : [];

    if (isCompact && mainVideo != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF26262A) : const Color(0xFFFFF1F1),
          border: Border.all(
            color: accent.withOpacity(isDark ? 0.25 : 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                FontAwesomeIcons.youtube,
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mainVideo['title'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.youtube,
                          size: 11, color: accent.withOpacity(0.9)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          mainVideo['channel'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (videos.length > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+${videos.length - 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accent.withOpacity(0.9),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (mainVideo['duration'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      mainVideo['duration'],
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // メイン動画（大きく表示）
        if (mainVideo != null) ...[
        Container(
            padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withOpacity(isDark ? 0.25 : 0.16),
                accent.withOpacity(isDark ? 0.12 : 0.08),
              ],
            ),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
                // サムネイル風のアイコン
              Container(
                  width: 76,
                  height: 52,
                decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.play,
                    color: Color(0xFFFF0000),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainVideo['title'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                  FontAwesomeIcons.youtube,
                  color: accent,
                            size: 12,
                ),
                          const SizedBox(width: 5),
              Expanded(
                child: Text(
                              mainVideo['channel'] ?? '',
                  style: TextStyle(
                                fontSize: 13,
                    fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                ),
              ),
                        ],
                      ),
                      if (mainVideo['duration'] != null) ...[
                        const SizedBox(height: 3),
                Text(
                          mainVideo['duration'],
                  style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                ),
                      ],
            ],
          ),
        ),
              ],
            ),
          ),
        ],
        
        // 他の動画（視聴として小さく表示）
        if (!isCompact && otherVideos.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '他 ${otherVideos.length}本の動画を視聴',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...otherVideos.map((video) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video['title'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
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
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  video['channel'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
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
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
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
            color: Colors.green.withOpacity( 0.1),
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
              color: Colors.grey.withOpacity( 0.3),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : const Color(0xFF111827)).withOpacity(0.08),
                (isDark ? Colors.white : const Color(0xFF111827)).withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(WidgetRef ref, bool isDark, bool canAccess) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          _buildStatPill(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: post.likesCount.toString(),
            color: post.isLiked
                ? const Color(0xFFFF6B6B)
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            background: post.isLiked
                ? const Color(0xFFFF6B6B).withOpacity(0.16)
                : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9)),
            onTap: canAccess
                ? () {
                    ref.read(postsProvider.notifier).toggleLike(post.id);
                  }
                : null,
            isEnabled: canAccess,
          ),
          const SizedBox(width: 12),
          _buildStatPill(
            icon: Icons.comment_outlined,
            label: post.commentsCount.toString(),
            color: isDark ? Colors.white70 : const Color(0xFF475569),
            background: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
            isEnabled: canAccess,
          ),
          const Spacer(),
          if (!isCompact && post.tags.isNotEmpty)
            _buildStatPill(
              icon: Icons.local_offer_outlined,
              label: post.tags.length.toString(),
              color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
              background: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF4F4F5),
              isEnabled: false,
            ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isEnabled ? color : color.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isEnabled ? color : color.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
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

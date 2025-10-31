import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/star_data.dart';
import '../../domain/visibility.dart';
import 'locked_overlay.dart';

class StarDataCard extends StatelessWidget {
  const StarDataCard({
    super.key,
    required this.data,
    required this.isLocked,
    required this.onTap,
    required this.onLike,
    required this.onComment,
  });

  final StarData data;
  final bool isLocked;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final relativeTime = _formatRelativeTime(data.createdAt);

    return Semantics(
      button: true,
      label: data.title,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceHeader(
                iconPath: data.serviceIcon,
                categoryLabel: data.category.displayLabel,
                visibility: data.visibility,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildImage(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.starComment != null &&
                        data.starComment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data.starComment!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          relativeTime,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: isLocked ? null : onLike,
                          tooltip: 'いいね',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: isLocked ? null : onComment,
                          tooltip: 'コメント',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined),
      ),
    );

    final imageWidget = data.imageUrl != null && data.imageUrl!.isNotEmpty
        ? ClipRRect(
            borderRadius: borderRadius,
            child: CachedNetworkImage(
              imageUrl: data.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : placeholder;

    if (!isLocked) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: imageWidget,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : placeholder,
          ),
          LockedOverlay(
            message: 'メンバー限定',
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat.yMMMd('ja').format(dateTime);
    }
  }
}

class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({
    required this.iconPath,
    required this.categoryLabel,
    required this.visibility,
  });

  final String iconPath;
  final String categoryLabel;
  final StarDataVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibilityLabel = visibility.displayLabel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 32,
              height: 32,
              child: _buildIcon(colorScheme),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              categoryLabel,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              visibilityLabel,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    if (iconPath.isNotEmpty) {
      return Image.asset(
        iconPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.apps,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Icon(
      Icons.apps,
      color: colorScheme.onSurfaceVariant,
    );
  }
}

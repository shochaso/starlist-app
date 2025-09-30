import 'package:flutter/material.dart';

import '../models/star.dart';
import '../theme/tokens.dart';

class StarCard extends StatelessWidget {
  const StarCard({
    super.key,
    required this.star,
    this.onTap,
    this.postId,
  });

  final Star star;
  final VoidCallback? onTap;
  final String? postId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.tokens;

    final placeholderColor = colorScheme.surfaceVariant;
    final textColor = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurfaceVariant;

    return Card(
      margin: EdgeInsets.zero,
      elevation: tokens.elevations.sm,
      shape: RoundedRectangleBorder(borderRadius: tokens.radius.xlRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.radius.xlRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radius.xl)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: placeholderColor,
                        alignment: Alignment.center,
                        child: Text(
                          star.name.substring(0, 1),
                          style: theme.textTheme.headlineMedium?.copyWith(color: textColor),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: tokens.spacing.sm,
                      right: tokens.spacing.sm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.xs,
                          vertical: tokens.spacing.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: _rankColor(star.rank, colorScheme),
                          borderRadius: tokens.radius.smRadius,
                        ),
                        child: Text(
                          star.rank,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _rankForegroundColor(_rankColor(star.rank, colorScheme)),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    star.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing.xxxs),
                  Text(
                    star.description ?? 'プロフィール準備中',
                    style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (postId != null) ...[
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '関連投稿: $postId',
                      style: theme.textTheme.labelSmall?.copyWith(color: secondaryText),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(String rank, ColorScheme colorScheme) {
    switch (rank) {
      case 'レギュラー':
        return colorScheme.primary;
      case 'プラチナ':
        return colorScheme.secondary;
      case 'スーパー':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }

  Color _rankForegroundColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

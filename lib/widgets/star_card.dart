import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../models/star.dart';
import '../theme/context_ext.dart';

class StarCard extends StatefulWidget {
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
  State<StarCard> createState() => _StarCardState();
}

class _StarCardState extends State<StarCard> {
  static const _maxTilt = 12.0;
  double _rx = 0;
  double _ry = 0;

  void _updateTilt(PointerHoverEvent event) {
    final size = context.size;
    if (size == null) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = (event.localPosition.dx - cx) / cx;
    final dy = (event.localPosition.dy - cy) / cy;
    final nextRy = (dx * 10).clamp(-_maxTilt, _maxTilt);
    final nextRx = (-dy * 10).clamp(-_maxTilt, _maxTilt);
    if (nextRx == _rx && nextRy == _ry) {
      return;
    }
    setState(() {
      _ry = nextRy;
      _rx = nextRx;
    });
  }

  void _resetTilt() {
    if (_rx == 0 && _ry == 0) return;
    setState(() {
      _rx = 0;
      _ry = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.tokens;

    final placeholderColor = colorScheme.surfaceVariant;
    final textColor = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurfaceVariant;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: secondaryText,
    );

    final badgeColor = _rankColor(widget.star.rank, colorScheme);
    final badgeLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: _rankForegroundColor(badgeColor),
      fontWeight: FontWeight.w600,
    );

    final card = Card(
      margin: EdgeInsets.zero,
      elevation: tokens.elevations.sm,
      shape: RoundedRectangleBorder(borderRadius: tokens.radius.xlRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: tokens.radius.xlRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(tokens.radius.xl),
                    ),
                    child: Image.network(
                      widget.star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: placeholderColor,
                        alignment: Alignment.center,
                        child: Text(
                          widget.star.name.substring(0, 1),
                          style: theme.textTheme.headlineMedium?.copyWith(color: textColor),
                        ),
                      ),
                    ),
                  ),
                  // gloss
                  Positioned(
                    top: -40,
                    left: -60,
                    child: Transform.rotate(
                      angle: -15 * math.pi / 180,
                      child: Container(
                        width: 300,
                        height: 120,
                        color: colorScheme.onSurface.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // sparkle overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _SparklePainter(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
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
                        color: badgeColor,
                        borderRadius: tokens.radius.smRadius,
                      ),
                      child: Text(widget.star.rank, style: badgeLabelStyle),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.star.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.spacing.xxxs),
                  Text(
                    widget.star.description ?? 'プロフィール準備中',
                    style: subtitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.postId != null) ...[
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '関連投稿: ${widget.postId}',
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

    return MouseRegion(
      onExit: (_) => _resetTilt(),
      onHover: _updateTilt,
      child: AnimatedContainer(
        duration: tokens.motion.fast,
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rx * math.pi / 180)
          ..rotateY(_ry * math.pi / 180),
        child: card,
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

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // きらめきを簡易的に配置
    for (int i = 0; i < 12; i++) {
      final dx = (i * 19) % (size.width - 6);
      final dy = (i * 31) % (size.height - 6);
      canvas.drawCircle(Offset(dx.toDouble() + 3, dy.toDouble() + 3), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => false;
}

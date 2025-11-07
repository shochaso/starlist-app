import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/star_data.dart';

class StarHeader extends StatelessWidget {
  const StarHeader({
    super.key,
    required this.profile,
  });

  final StarProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final avatar = _buildAvatar(colorScheme);
        final details = _StarDetails(profile: profile);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 24),
              Expanded(child: details),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            const SizedBox(height: 16),
            details,
          ],
        );
      },
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(80),
      child: SizedBox(
        width: 96,
        height: 96,
        child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: profile.avatarUrl!,
                fit: BoxFit.cover,
              )
            : Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  size: 48,
                ),
              ),
      ),
    );
  }
}

class _StarDetails extends StatelessWidget {
  const _StarDetails({required this.profile});

  final StarProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.displayName,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Text(
            profile.bio!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        if (profile.totalFollowers != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.groups_3_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${profile.totalFollowers} フォロワー',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        if (profile.snsLinks.hasAny) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (profile.snsLinks.x != null)
                _SnsChip(
                  icon: Icons.alternate_email,
                  label: 'X',
                  url: profile.snsLinks.x!,
                ),
              if (profile.snsLinks.instagram != null)
                _SnsChip(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  url: profile.snsLinks.instagram!,
                ),
              if (profile.snsLinks.youtube != null)
                _SnsChip(
                  icon: Icons.play_circle_outline,
                  label: 'YouTube',
                  url: profile.snsLinks.youtube!,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SnsChip extends StatelessWidget {
  const _SnsChip({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      label: Text(label),
      onPressed: () {
        // TODO: open external link once launcher is wired.
      },
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
    );
  }
}

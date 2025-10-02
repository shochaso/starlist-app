import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/theme_provider_enhanced.dart';
import '../../theme/context_ext.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackToHome = true,
    this.onBackPressed,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackToHome;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.tokens;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      leadingWidth: showBackToHome ? 72 : null,
      leading: showBackToHome
          ? Padding(
              padding: EdgeInsets.only(left: tokens.spacing.sm),
              child: _BackHomeButton(
                onPressed: onBackPressed ?? () => _navigateToHome(context),
                icon: Icons.home,
              ),
            )
          : null,
      titleSpacing: showBackToHome ? tokens.spacing.sm : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.xxxs),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      systemOverlayStyle: themeState.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  void _navigateToHome(BuildContext context) {
    context.go('/home');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceVariant.withOpacity(0.6),
      borderRadius: tokens.radius.lgRadius,
      child: InkWell(
        borderRadius: tokens.radius.lgRadius,
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xs),
          child: Icon(icon, color: colorScheme.onSurface, size: 22),
        ),
      ),
    );
  }
}

class CommonBackButton extends ConsumerWidget {
  const CommonBackButton({
    super.key,
    this.onPressed,
    this.toHome = true,
  });

  final VoidCallback? onPressed;
  final bool toHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: toHome ? 'Back to home' : 'Back',
      button: true,
      child: Material(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: tokens.radius.lgRadius,
        child: InkWell(
          borderRadius: tokens.radius.lgRadius,
          onTap: onPressed ?? () => _handleBack(context),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.xs),
            child: Icon(
              toHome ? Icons.home : Icons.arrow_back,
              color: colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (toHome) {
      context.go('/home');
    } else {
      Navigator.of(context).maybePop();
    }
  }
}

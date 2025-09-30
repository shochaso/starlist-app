import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppButtonVariant { primary, secondary, tonal, text }

class AppButton extends StatelessWidget {
  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.leading,
    this.trailing,
    this.variant = AppButtonVariant.primary,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildLabel(Color? color) {
      final textStyle = Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: color ?? colorScheme.onPrimary);

      return Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: tokens.spacing.xs),
          ],
          Flexible(child: Text(label, style: textStyle)),
          if (trailing != null) ...[
            SizedBox(width: tokens.spacing.xs),
            trailing!,
          ],
        ],
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(expanded ? double.infinity : 64, 44),
          ),
          child: buildLabel(null),
        );
      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(expanded ? double.infinity : 64, 44),
            side: BorderSide(color: colorScheme.outline, width: tokens.border.thin),
          ),
          child: buildLabel(colorScheme.primary),
        );
      case AppButtonVariant.tonal:
        return FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(expanded ? double.infinity : 64, 44),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          child: buildLabel(colorScheme.onPrimaryContainer),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(expanded ? double.infinity : 48, 44),
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
          ),
          child: buildLabel(colorScheme.primary),
        );
    }
  }
}

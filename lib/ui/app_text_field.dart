import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AppTextFieldState { normal, success, warning, danger }

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.state = AppTextFieldState.normal,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final AppTextFieldState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    Color borderColor;
    switch (state) {
      case AppTextFieldState.success:
        borderColor = colorScheme.tertiary;
        break;
      case AppTextFieldState.warning:
        borderColor = colorScheme.tertiaryContainer;
        break;
      case AppTextFieldState.danger:
        borderColor = colorScheme.error;
        break;
      case AppTextFieldState.normal:
      default:
        borderColor = colorScheme.outlineVariant;
        break;
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: tokens.radius.mdRadius,
          borderSide: BorderSide(color: borderColor, width: tokens.border.thin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: tokens.radius.mdRadius,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: tokens.focus.ringWidth,
          ),
        ),
      ),
    );
  }
}

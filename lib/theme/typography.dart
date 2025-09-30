import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildAppTextTheme(ColorScheme colorScheme) {
  final baseLatin = GoogleFonts.plusJakartaSans();
  final bodyColor = colorScheme.onSurface;
  final mutedColor = colorScheme.onSurface.withOpacity(0.72);

  TextStyle toStyle(double size, FontWeight weight, {double? height, Color? color}) {
    return baseLatin.copyWith(
      fontSize: size,
      fontWeight: weight,
      height: height ?? 1.3,
      color: color ?? bodyColor,
      letterSpacing: size >= 48 ? -0.5 : 0,
      fontFamilyFallback: const [
        'Noto Sans JP',
        'system-ui',
        'Hiragino Sans',
        'Yu Gothic UI',
      ],
    );
  }

  return TextTheme(
    displayLarge: toStyle(56, FontWeight.w700, height: 1.1),
    displayMedium: toStyle(48, FontWeight.w700, height: 1.1),
    displaySmall: toStyle(40, FontWeight.w700, height: 1.15),
    headlineLarge: toStyle(34, FontWeight.w700),
    headlineMedium: toStyle(28, FontWeight.w700),
    headlineSmall: toStyle(24, FontWeight.w600),
    titleLarge: toStyle(20, FontWeight.w600),
    titleMedium: toStyle(18, FontWeight.w600),
    titleSmall: toStyle(16, FontWeight.w600),
    bodyLarge: toStyle(16, FontWeight.w500),
    bodyMedium: toStyle(14, FontWeight.w500, color: mutedColor),
    bodySmall: toStyle(12, FontWeight.w500, color: mutedColor),
    labelLarge: toStyle(14, FontWeight.w600),
    labelMedium: toStyle(12, FontWeight.w600, color: mutedColor),
    labelSmall: toStyle(11, FontWeight.w600, color: mutedColor),
  );
}

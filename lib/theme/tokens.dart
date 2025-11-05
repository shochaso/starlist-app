// lib/theme/tokens.dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF8F9FB);
  static const text = Color(0xFF0F172A);
  static const subtext = Color(0xFF475569);
  static const brand = Color(0xFF3B82F6);
  static const brandDark = Color(0xFF1D4ED8);
  static const border = Color(0xFFE2E8F0);
  static const card = Colors.white;
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

class AppSpace { // 4ptグリッド
  const AppSpace();
  
  double get xxxs => 2.0;
  double get xxs => 4.0;
  double get xs => 8.0;
  double get sm => 12.0;
  double get md => 16.0;
  double get lg => 20.0;
  double get xl => 24.0;
  double get xxl => 32.0;
  double get section => 48.0;
}

class AppRadius {
  const AppRadius();
  
  double get sm => 8.0;
  double get md => 12.0;
  double get lg => 16.0;
  double get xl => 20.0;
  double get xxl => 24.0;
  
  BorderRadius get smRadius => BorderRadius.circular(sm);
  BorderRadius get mdRadius => BorderRadius.circular(md);
  BorderRadius get lgRadius => BorderRadius.circular(lg);
  BorderRadius get xlRadius => BorderRadius.circular(xl);
  BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  BorderRadius get fullRadius => BorderRadius.circular(9999);
}

class AppBorder {
  const AppBorder();
  
  double get thin => 1.0;
  double get medium => 2.0;
  double get thick => 3.0;
}

class AppElevations {
  const AppElevations();
  
  double get sm => 4.0;
  double get md => 8.0;
  double get lg => 16.0;
  double get xl => 24.0;
}

class AppShadows {
  static List<BoxShadow> soft = [
    const BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
  ];
}

class AppMotion {
  const AppMotion();

  Duration get fast => const Duration(milliseconds: 120);
  Duration get normal => const Duration(milliseconds: 200);
  Duration get slow => const Duration(milliseconds: 360);
}

/// Theme extension for accessing design tokens
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spacing,
    required this.radius,
    required this.border,
    required this.elevations,
    required this.motion,
  });

  final AppSpace spacing;
  final AppRadius radius;
  final AppBorder border;
  final AppElevations elevations;
  final AppMotion motion;

  @override
  AppTokens copyWith({
    AppSpace? spacing,
    AppRadius? radius,
    AppBorder? border,
    AppElevations? elevations,
    AppMotion? motion,
  }) {
    return AppTokens(
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      border: border ?? this.border,
      elevations: elevations ?? this.elevations,
      motion: motion ?? this.motion,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    return const AppTokens(
      spacing: AppSpace(),
      radius: AppRadius(),
      border: AppBorder(),
      elevations: AppElevations(),
      motion: AppMotion(),
    );
  }

  static const defaultTokens = AppTokens(
    spacing: AppSpace(),
    radius: AppRadius(),
    border: AppBorder(),
    elevations: AppElevations(),
    motion: AppMotion(),
  );
}

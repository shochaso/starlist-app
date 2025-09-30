import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.radius,
    required this.spacing,
    required this.elevations,
    required this.motion,
    required this.focus,
    required this.opacity,
    required this.border,
    required this.zIndex,
  });

  final AppRadius radius;
  final AppSpacing spacing;
  final AppElevation elevations;
  final AppMotion motion;
  final AppFocus focus;
  final AppOpacity opacity;
  final AppBorder border;
  final AppZIndex zIndex;

  factory AppTokens.light() {
    return AppTokens(
      radius: const AppRadius(),
      spacing: const AppSpacing(),
      elevations: const AppElevation(),
      motion: const AppMotion(),
      focus: const AppFocus(
        ringColor: Color(0x4C7C5CFF),
        ringWidth: 2,
        ringOffset: 2,
      ),
      opacity: const AppOpacity(),
      border: const AppBorder(
        color: Color(0xFFE5E9F0),
        subtleColor: Color(0xFFEDEFF4),
      ),
      zIndex: const AppZIndex(),
    );
  }

  factory AppTokens.dark() {
    return AppTokens(
      radius: const AppRadius(),
      spacing: const AppSpacing(),
      elevations: const AppElevation(),
      motion: const AppMotion(),
      focus: const AppFocus(
        ringColor: Color(0x66FFFFFF),
        ringWidth: 2,
        ringOffset: 2,
      ),
      opacity: const AppOpacity(),
      border: const AppBorder(
        color: Color(0x14FFFFFF),
        subtleColor: Color(0x1FFFFFFF),
      ),
      zIndex: const AppZIndex(),
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }

    return AppTokens(
      radius: AppRadius.lerp(radius, other.radius, t),
      spacing: AppSpacing.lerp(spacing, other.spacing, t),
      elevations: AppElevation.lerp(elevations, other.elevations, t),
      motion: AppMotion.lerp(motion, other.motion, t),
      focus: AppFocus.lerp(focus, other.focus, t),
      opacity: AppOpacity.lerp(opacity, other.opacity, t),
      border: AppBorder.lerp(border, other.border, t),
      zIndex: AppZIndex.lerp(zIndex, other.zIndex, t),
    );
  }

  @override
  AppTokens copyWith({
    AppRadius? radius,
    AppSpacing? spacing,
    AppElevation? elevations,
    AppMotion? motion,
    AppFocus? focus,
    AppOpacity? opacity,
    AppBorder? border,
    AppZIndex? zIndex,
  }) {
    return AppTokens(
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      elevations: elevations ?? this.elevations,
      motion: motion ?? this.motion,
      focus: focus ?? this.focus,
      opacity: opacity ?? this.opacity,
      border: border ?? this.border,
      zIndex: zIndex ?? this.zIndex,
    );
  }
}

@immutable
class AppRadius {
  const AppRadius({
    this.xs = 6,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  BorderRadius get xsRadius => BorderRadius.circular(xs);
  BorderRadius get smRadius => BorderRadius.circular(sm);
  BorderRadius get mdRadius => BorderRadius.circular(md);
  BorderRadius get lgRadius => BorderRadius.circular(lg);
  BorderRadius get xlRadius => BorderRadius.circular(xl);
  BorderRadius get xxlRadius => BorderRadius.circular(xxl);

  static AppRadius lerp(AppRadius a, AppRadius b, double t) {
    return AppRadius(
      xs: lerpDouble(a.xs, b.xs, t),
      sm: lerpDouble(a.sm, b.sm, t),
      md: lerpDouble(a.md, b.md, t),
      lg: lerpDouble(a.lg, b.lg, t),
      xl: lerpDouble(a.xl, b.xl, t),
      xxl: lerpDouble(a.xxl, b.xxl, t),
    );
  }
}

@immutable
class AppSpacing {
  const AppSpacing({
    this.none = 0,
    this.xxxs = 2,
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 40,
    this.section = 48,
  });

  final double none;
  final double xxxs;
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double section;

  static AppSpacing lerp(AppSpacing a, AppSpacing b, double t) {
    return AppSpacing(
      none: lerpDouble(a.none, b.none, t),
      xxxs: lerpDouble(a.xxxs, b.xxxs, t),
      xxs: lerpDouble(a.xxs, b.xxs, t),
      xs: lerpDouble(a.xs, b.xs, t),
      sm: lerpDouble(a.sm, b.sm, t),
      md: lerpDouble(a.md, b.md, t),
      lg: lerpDouble(a.lg, b.lg, t),
      xl: lerpDouble(a.xl, b.xl, t),
      xxl: lerpDouble(a.xxl, b.xxl, t),
      section: lerpDouble(a.section, b.section, t),
    );
  }
}

@immutable
class AppElevation {
  const AppElevation({
    this.sm = 1,
    this.md = 4,
    this.lg = 10,
    this.xl = 18,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;

  static AppElevation lerp(AppElevation a, AppElevation b, double t) {
    return AppElevation(
      sm: lerpDouble(a.sm, b.sm, t),
      md: lerpDouble(a.md, b.md, t),
      lg: lerpDouble(a.lg, b.lg, t),
      xl: lerpDouble(a.xl, b.xl, t),
    );
  }
}

@immutable
class AppMotion {
  const AppMotion({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 250),
  });

  final Duration fast;
  final Duration medium;
  final Duration slow;

  static AppMotion lerp(AppMotion a, AppMotion b, double t) {
    return AppMotion(
      fast: Duration(milliseconds: lerpDouble(a.fast.inMilliseconds.toDouble(), b.fast.inMilliseconds.toDouble(), t).round()),
      medium: Duration(milliseconds: lerpDouble(a.medium.inMilliseconds.toDouble(), b.medium.inMilliseconds.toDouble(), t).round()),
      slow: Duration(milliseconds: lerpDouble(a.slow.inMilliseconds.toDouble(), b.slow.inMilliseconds.toDouble(), t).round()),
    );
  }
}

@immutable
class AppFocus {
  const AppFocus({
    required this.ringColor,
    required this.ringWidth,
    required this.ringOffset,
  });

  final Color ringColor;
  final double ringWidth;
  final double ringOffset;

  static AppFocus lerp(AppFocus a, AppFocus b, double t) {
    return AppFocus(
      ringColor: Color.lerp(a.ringColor, b.ringColor, t) ?? a.ringColor,
      ringWidth: lerpDouble(a.ringWidth, b.ringWidth, t),
      ringOffset: lerpDouble(a.ringOffset, b.ringOffset, t),
    );
  }
}

@immutable
class AppOpacity {
  const AppOpacity({
    this.disabled = 0.38,
    this.hover = 0.08,
    this.focus = 0.12,
  });

  final double disabled;
  final double hover;
  final double focus;

  static AppOpacity lerp(AppOpacity a, AppOpacity b, double t) {
    return AppOpacity(
      disabled: lerpDouble(a.disabled, b.disabled, t),
      hover: lerpDouble(a.hover, b.hover, t),
      focus: lerpDouble(a.focus, b.focus, t),
    );
  }
}

@immutable
class AppBorder {
  const AppBorder({
    required this.color,
    required this.subtleColor,
    this.hairline = 0.5,
    this.thin = 1,
    this.thick = 2,
  });

  final Color color;
  final Color subtleColor;
  final double hairline;
  final double thin;
  final double thick;

  static AppBorder lerp(AppBorder a, AppBorder b, double t) {
    return AppBorder(
      color: Color.lerp(a.color, b.color, t) ?? a.color,
      subtleColor: Color.lerp(a.subtleColor, b.subtleColor, t) ?? a.subtleColor,
      hairline: lerpDouble(a.hairline, b.hairline, t),
      thin: lerpDouble(a.thin, b.thin, t),
      thick: lerpDouble(a.thick, b.thick, t),
    );
  }
}

@immutable
class AppZIndex {
  const AppZIndex({
    this.drawer = 800,
    this.modal = 900,
    this.toast = 950,
    this.overlay = 1000,
  });

  final int drawer;
  final int modal;
  final int toast;
  final int overlay;

  static AppZIndex lerp(AppZIndex a, AppZIndex b, double t) {
    return AppZIndex(
      drawer: (lerpDouble(a.drawer.toDouble(), b.drawer.toDouble(), t)).round(),
      modal: (lerpDouble(a.modal.toDouble(), b.modal.toDouble(), t)).round(),
      toast: (lerpDouble(a.toast.toDouble(), b.toast.toDouble(), t)).round(),
      overlay: (lerpDouble(a.overlay.toDouble(), b.overlay.toDouble(), t)).round(),
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

extension BuildContextTokens on BuildContext {
  AppTokens get tokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(tokens != null, 'AppTokens not found on Theme');
    return tokens!;
  }
}

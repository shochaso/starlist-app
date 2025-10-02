import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_schemes.dart';
import 'tokens.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF7C5CFF);
  static const Color secondaryColor = Color(0xFF00C2FF);
  static const Color accentColor = Color(0xFF22C55E);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F7FA);
  static const Color borderColor = Color(0xFFE5E9F0);
  static const Color mutedForegroundColor = Color(0xFF5A6472);
  static const Color destructiveColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);

  static ThemeData get lightTheme => _buildTheme(lightColorScheme, AppTokens.light());

  static ThemeData get darkTheme => _buildTheme(darkColorScheme, AppTokens.dark());

  static ThemeData themeFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkTheme : lightTheme;

  static ThemeData _buildTheme(ColorScheme colorScheme, AppTokens tokens) {
    final textTheme = buildAppTextTheme(colorScheme);
    final focusRing = tokens.focus;

    OutlineInputBorder outline(Color borderColor, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: tokens.radius.mdRadius,
          borderSide: BorderSide(color: borderColor, width: width),
        );

    MaterialStateProperty<Color?> overlay(Color base, double opacity) =>
        MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.pressed)) {
            return base.withOpacity(opacity + 0.08);
          }
          if (states.contains(MaterialState.hovered)) {
            return base.withOpacity(opacity);
          }
          if (states.contains(MaterialState.focused)) {
            return focusRing.ringColor;
          }
          return null;
        });

    MaterialStateProperty<double?> elevation(double resting) =>
        MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return 0;
          }
          if (states.contains(MaterialState.pressed)) {
            return tokens.elevations.md;
          }
          if (states.contains(MaterialState.hovered)) {
            return tokens.elevations.md;
          }
          return resting;
        });

    ButtonStyle buildFilledButton() {
      return ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(64, 44)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.sm,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: tokens.radius.lgRadius),
        ),
        elevation: elevation(tokens.elevations.sm),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.primary.withOpacity(tokens.opacity.disabled);
          }
          return colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          return colorScheme.onPrimary;
        }),
        overlayColor: overlay(colorScheme.onPrimary, tokens.opacity.focus),
        textStyle: MaterialStateProperty.all(textTheme.labelLarge),
        animationDuration: tokens.motion.medium,
      );
    }

    ButtonStyle buildOutlinedButton() {
      return ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(64, 44)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.sm,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: tokens.radius.lgRadius),
        ),
        side: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(
              color: colorScheme.onSurface.withOpacity(0.12),
              width: tokens.border.thin,
            );
          }
          if (states.contains(MaterialState.focused)) {
            return BorderSide(
              color: colorScheme.primary,
              width: tokens.border.thick,
            );
          }
          return BorderSide(
            color: colorScheme.outline,
            width: tokens.border.thin,
          );
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          return colorScheme.primary;
        }),
        overlayColor: overlay(colorScheme.primary, tokens.opacity.hover),
        textStyle: MaterialStateProperty.all(textTheme.labelLarge),
        animationDuration: tokens.motion.medium,
      );
    }

    ButtonStyle buildTextButton() {
      return ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(48, 44)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: tokens.spacing.sm,
          ),
        ),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          return colorScheme.primary;
        }),
        overlayColor: overlay(colorScheme.primary, tokens.opacity.hover),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: tokens.radius.mdRadius),
        ),
        textStyle: MaterialStateProperty.all(textTheme.labelLarge),
        animationDuration: tokens.motion.fast,
      );
    }

    final filledFieldColor = colorScheme.surface;
    final errorColor = colorScheme.error;
    
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      fontFamily: textTheme.bodyLarge?.fontFamily,
      focusColor: focusRing.ringColor,
      hoverColor: colorScheme.primary.withOpacity(tokens.opacity.hover),
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      extensions: [tokens],
      elevatedButtonTheme: ElevatedButtonThemeData(style: buildFilledButton()),
      filledButtonTheme: FilledButtonThemeData(style: buildFilledButton()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: buildOutlinedButton()),
      textButtonTheme: TextButtonThemeData(style: buildTextButton()),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: filledFieldColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        border: outline(tokens.border.subtleColor,
            width: tokens.border.thin),
        enabledBorder: outline(tokens.border.subtleColor,
            width: tokens.border.thin),
        focusedBorder: outline(colorScheme.primary,
            width: focusRing.ringWidth),
        errorBorder: outline(errorColor, width: tokens.border.thin),
        focusedErrorBorder: outline(errorColor, width: focusRing.ringWidth),
        labelStyle: textTheme.bodyMedium,
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: errorColor),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: tokens.elevations.sm,
        shape: RoundedRectangleBorder(borderRadius: tokens.radius.xlRadius),
        shadowColor: colorScheme.shadow,
        margin: EdgeInsets.all(tokens.spacing.sm),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: colorScheme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primary.withOpacity(0.16),
        disabledColor: colorScheme.surfaceVariant.withOpacity(0.4),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.xs,
          vertical: tokens.spacing.xxxs,
        ),
        shape: RoundedRectangleBorder(borderRadius: tokens.radius.lgRadius),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle:
            textTheme.labelLarge?.copyWith(color: colorScheme.primary),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.14),
          borderRadius: tokens.radius.lgRadius,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle:
            textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        overlayColor: overlay(colorScheme.primary, tokens.opacity.hover),
        splashFactory: InkSparkle.splashFactory,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.16),
        elevation: tokens.elevations.sm,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          if (states.contains(MaterialState.disabled)) {
            return IconThemeData(
              color: colorScheme.onSurface.withOpacity(tokens.opacity.disabled),
            );
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textTheme.labelLarge?.copyWith(color: colorScheme.primary);
          }
          if (states.contains(MaterialState.disabled)) {
            return textTheme.labelLarge
                ?.copyWith(color: colorScheme.onSurface.withOpacity(0.4));
          }
          return textTheme.labelLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: tokens.radius.mdRadius),
        selectedTileColor: colorScheme.primary.withOpacity(0.12),
        iconColor: colorScheme.onSurfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: tokens.border.thin,
        space: tokens.spacing.sm,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 300),
        textStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onInverseSurface),
        decoration: ShapeDecoration(
          color: colorScheme.inverseSurface,
          shape: RoundedRectangleBorder(borderRadius: tokens.radius.smRadius),
          shadows: [
            BoxShadow(
              color: colorScheme.shadow,
              blurRadius: tokens.elevations.md,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: MaterialStateProperty.all(6),
        radius: Radius.circular(tokens.radius.md),
        thumbVisibility: const MaterialStatePropertyAll(true),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.dragged)) {
            return colorScheme.primary.withOpacity(0.8);
          }
          return colorScheme.onSurfaceVariant.withOpacity(0.6);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: tokens.radius.xsRadius),
        side: BorderSide(color: colorScheme.outline, width: tokens.border.thin),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          return colorScheme.surface;
        }),
        checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(tokens.opacity.disabled);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.12);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.54);
          }
          return colorScheme.outline.withOpacity(0.5);
        }),
      ),
    );
  }
} 

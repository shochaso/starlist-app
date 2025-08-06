import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../src/core/constants/theme_constants.dart';

/// 統合されたテーマ定義クラス
class AppThemeEnhanced {
  // プライベートコンストラクタ
  AppThemeEnhanced._();

  /// ライトテーマ
  static ThemeData get lightTheme {
    final TextTheme textTheme = _buildTextTheme(
      baseColor: ThemeConstants.lightOnBackground,
      mutedColor: ThemeConstants.lightMutedForeground,
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: GoogleFonts.mPlusRounded1c().fontFamily,
      textTheme: textTheme,
      
      // カラースキーム
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.primaryPurple,
        onPrimary: Colors.white,
        secondary: ThemeConstants.secondaryPurple,
        onSecondary: Colors.white,
        tertiary: ThemeConstants.accentPink,
        onTertiary: Colors.white,
        error: ThemeConstants.errorColor,
        onError: Colors.white,
        surface: ThemeConstants.lightSurface,
        onSurface: ThemeConstants.lightOnSurface,
        outline: ThemeConstants.lightBorder,
        outlineVariant: ThemeConstants.lightMuted,
        surfaceContainerHighest: ThemeConstants.lightMuted,
        onSurfaceVariant: ThemeConstants.lightMutedForeground,
      ),
      
      scaffoldBackgroundColor: ThemeConstants.lightBackground,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeConstants.lightOnBackground,
        elevation: ThemeConstants.elevation0,
        scrolledUnderElevation: ThemeConstants.elevation1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          textStyle: const TextStyle(
            color: ThemeConstants.lightOnBackground,
            fontWeight: ThemeConstants.fontWeightBold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: ThemeConstants.lightOnBackground,
        ),
      ),
      
      // Card
      cardTheme: CardTheme(
        color: ThemeConstants.lightSurface,
        elevation: ThemeConstants.elevation0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
          side: const BorderSide(color: ThemeConstants.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ThemeConstants.lightMuted,
          disabledForegroundColor: ThemeConstants.lightMutedForeground,
          elevation: ThemeConstants.elevation0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeConstants.primaryPurple,
          disabledForegroundColor: ThemeConstants.lightMutedForeground,
          side: const BorderSide(color: ThemeConstants.primaryPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryPurple,
          disabledForegroundColor: ThemeConstants.lightMutedForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spaceMd,
          vertical: ThemeConstants.spaceSm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: ThemeConstants.lightMutedForeground),
        hintStyle: const TextStyle(color: ThemeConstants.lightMutedForeground),
      ),
      
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: ThemeConstants.lightSurface,
        elevation: ThemeConstants.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.lightOnSurface,
          fontSize: 20,
          fontWeight: ThemeConstants.fontWeightBold,
        ),
        contentTextStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.lightOnSurface,
          fontSize: 16,
        ),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ThemeConstants.lightSurface,
        selectedItemColor: ThemeConstants.primaryPurple,
        unselectedItemColor: ThemeConstants.lightMutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: ThemeConstants.elevation8,
        selectedLabelStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 12,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        unselectedLabelStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 12,
          fontWeight: ThemeConstants.fontWeightRegular,
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: ThemeConstants.lightMuted,
        selectedColor: ThemeConstants.primaryPurple.withOpacity( 0.1),
        deleteIconColor: ThemeConstants.lightMutedForeground,
        disabledColor: ThemeConstants.lightMuted.withOpacity( 0.5),
        labelStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.lightOnSurface,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        secondaryLabelStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.primaryPurple,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
        ),
        side: const BorderSide(color: ThemeConstants.lightBorder),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemeConstants.primaryPurple,
        foregroundColor: Colors.white,
        elevation: ThemeConstants.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
      ),
    );
  }

  /// ダークテーマ
  static ThemeData get darkTheme {
    final TextTheme textTheme = _buildTextTheme(
      baseColor: ThemeConstants.darkOnBackground,
      mutedColor: ThemeConstants.darkMutedForeground,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: GoogleFonts.mPlusRounded1c().fontFamily,
      textTheme: textTheme,
      
      // カラースキーム
      colorScheme: const ColorScheme.dark(
        primary: ThemeConstants.primaryPurple,
        onPrimary: Colors.white,
        secondary: ThemeConstants.secondaryPurple,
        onSecondary: Colors.white,
        tertiary: ThemeConstants.accentPink,
        onTertiary: Colors.white,
        error: ThemeConstants.errorColor,
        onError: Colors.white,
        surface: ThemeConstants.darkSurface,
        onSurface: ThemeConstants.darkOnSurface,
        outline: ThemeConstants.darkBorder,
        outlineVariant: ThemeConstants.darkMuted,
        surfaceContainerHighest: ThemeConstants.darkMuted,
        onSurfaceVariant: ThemeConstants.darkMutedForeground,
      ),
      
      scaffoldBackgroundColor: ThemeConstants.darkBackground,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeConstants.darkOnBackground,
        elevation: ThemeConstants.elevation0,
        scrolledUnderElevation: ThemeConstants.elevation1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          textStyle: const TextStyle(
            color: ThemeConstants.darkOnBackground,
            fontWeight: ThemeConstants.fontWeightBold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: ThemeConstants.darkOnBackground,
        ),
      ),
      
      // Card
      cardTheme: CardTheme(
        color: ThemeConstants.darkSurface,
        elevation: ThemeConstants.elevation0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
          side: const BorderSide(color: ThemeConstants.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ThemeConstants.darkMuted,
          disabledForegroundColor: ThemeConstants.darkMutedForeground,
          elevation: ThemeConstants.elevation0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeConstants.primaryPurple,
          disabledForegroundColor: ThemeConstants.darkMutedForeground,
          side: const BorderSide(color: ThemeConstants.primaryPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryPurple,
          disabledForegroundColor: ThemeConstants.darkMutedForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceMd,
            vertical: ThemeConstants.spaceSm + 4,
          ),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontWeight: ThemeConstants.fontWeightMedium,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spaceMd,
          vertical: ThemeConstants.spaceSm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(color: ThemeConstants.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: ThemeConstants.darkMutedForeground),
        hintStyle: const TextStyle(color: ThemeConstants.darkMutedForeground),
      ),
      
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: ThemeConstants.darkSurface,
        elevation: ThemeConstants.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.darkOnSurface,
          fontSize: 20,
          fontWeight: ThemeConstants.fontWeightBold,
        ),
        contentTextStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.darkOnSurface,
          fontSize: 16,
        ),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ThemeConstants.darkSurface,
        selectedItemColor: ThemeConstants.primaryPurple,
        unselectedItemColor: ThemeConstants.darkMutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: ThemeConstants.elevation8,
        selectedLabelStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 12,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        unselectedLabelStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 12,
          fontWeight: ThemeConstants.fontWeightRegular,
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: ThemeConstants.darkMuted,
        selectedColor: ThemeConstants.primaryPurple.withOpacity( 0.2),
        deleteIconColor: ThemeConstants.darkMutedForeground,
        disabledColor: ThemeConstants.darkMuted.withOpacity( 0.5),
        labelStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.darkOnSurface,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        secondaryLabelStyle: GoogleFonts.mPlusRounded1c(
          color: ThemeConstants.primaryPurple,
          fontWeight: ThemeConstants.fontWeightMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
        ),
        side: const BorderSide(color: ThemeConstants.darkBorder),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemeConstants.primaryPurple,
        foregroundColor: Colors.white,
        elevation: ThemeConstants.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
      ),
    );
  }

  /// テキストテーマビルダー
  static TextTheme _buildTextTheme({
    required Color baseColor,
    required Color mutedColor,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 48,
          letterSpacing: -1.5,
        ),
      ),
      displayMedium: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 36,
          letterSpacing: -0.5,
        ),
      ),
      displaySmall: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 24,
          letterSpacing: 0.0,
        ),
      ),
      headlineLarge: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 32,
          letterSpacing: 0.25,
        ),
      ),
      headlineMedium: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 20,
          letterSpacing: 0.0,
        ),
      ),
      headlineSmall: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightSemiBold,
          fontSize: 18,
          letterSpacing: 0.15,
        ),
      ),
      titleLarge: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightBold,
          fontSize: 16,
          letterSpacing: 0.15,
        ),
      ),
      titleMedium: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightSemiBold,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
      titleSmall: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightMedium,
          fontSize: 12,
          letterSpacing: 0.1,
        ),
      ),
      bodyLarge: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightRegular,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      bodyMedium: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: mutedColor,
          fontWeight: ThemeConstants.fontWeightRegular,
          fontSize: 14,
          letterSpacing: 0.25,
        ),
      ),
      bodySmall: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: mutedColor,
          fontWeight: ThemeConstants.fontWeightRegular,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
      labelLarge: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightMedium,
          fontSize: 14,
          letterSpacing: 1.25,
        ),
      ),
      labelMedium: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: baseColor,
          fontWeight: ThemeConstants.fontWeightMedium,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
      labelSmall: GoogleFonts.mPlusRounded1c(
        textStyle: TextStyle(
          color: mutedColor,
          fontWeight: ThemeConstants.fontWeightMedium,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// ランクカラー取得
  static Color getRankColor(String rank) {
    return ThemeConstants.starRankColors[rank] ?? ThemeConstants.primaryPurple;
  }

  /// グラデーション背景デコレーション
  static BoxDecoration get backgroundGradient => BoxDecoration(
    gradient: RadialGradient(
      colors: [
        ThemeConstants.primaryPurple.withOpacity( 0.1),
        Colors.transparent,
      ],
      center: Alignment.topRight,
      radius: 0.8,
      stops: const [0.0, 0.6],
    ),
  );

  /// カードグラデーションデコレーション（ライト）
  static BoxDecoration get lightCardGradient => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity( 0.1),
        Colors.white.withOpacity( 0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
    border: Border.all(color: ThemeConstants.lightBorder),
    boxShadow: ThemeConstants.lightShadow,
  );

  /// カードグラデーションデコレーション（ダーク）
  static BoxDecoration get darkCardGradient => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity( 0.05),
        Colors.white.withOpacity( 0.02),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
    border: Border.all(color: ThemeConstants.darkBorder),
    boxShadow: ThemeConstants.darkShadow,
  );
}
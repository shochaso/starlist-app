import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // カラーテーマ - Webデザインのカラーに更新
  static const Color primaryColor = Color(0xFFD10FEE); // --primary: 280 90% 50%
  static const Color primaryForeground = Colors.white; // --primary-foreground: 0 0% 100%
  static const Color secondaryColor = Color(0xFF8C52FF); // 紫色に変更
  static const Color secondaryForeground = Colors.white; // --secondary-foreground: 0 0% 100%
  static const Color accentColor = Color(0xFFFF7AC5); // --accent: 315 90% 75%
  static const Color accentForeground = Color(0xFF1A1A1A); // --accent-foreground: 280 10% 10%
  static const Color backgroundColor = Color(0xFFF9F4FA); // --background: 280 50% 98%
  static const Color foregroundColor = Color(0xFF1A1A1A); // --foreground: 280 10% 10%
  static const Color cardBackgroundColor = Colors.white; // --card: 0 0% 100%
  static const Color cardForegroundColor = Color(0xFF1A1A1A); // --card-foreground: 280 10% 10%
  static const Color borderColor = Color(0xFFE5DCE7); // --border: 280 20% 90%
  static const Color mutedColor = Color(0xFFF0EAF2); // --muted: 280 20% 96%
  static const Color mutedForegroundColor = Color(0xFF736B76); // --muted-foreground: 280 5% 45%
  static const Color destructiveColor = Color(0xFFE53935); // --destructive: 0 84.2% 60.2%
  static const Color destructiveForeground = Colors.white; // --destructive-foreground: 0 0% 100%

  // 境界半径
  static const double radiusLg = 16.0; // --radius: 1rem
  static const double radiusMd = 14.0; // calc(var(--radius) - 2px)
  static const double radiusSm = 12.0; // calc(var(--radius) - 4px)

  // グラデーション
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primaryColor,
      accentColor,
      Color(0xFF4285F4), // 青色に変更
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 背景グラデーション
  static const BoxDecoration backgroundDecoration = BoxDecoration(
    color: backgroundColor,
    gradient: RadialGradient(
      colors: [Color(0x33D10FEE), Colors.transparent],
      center: Alignment.topRight,
      radius: 0.5,
      stops: [0.0, 0.5],
    ),
  );
  
  // カードグラデーション
  static BoxDecoration cardGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // アニメーション定義
  static Duration animationDuration = const Duration(milliseconds: 300);
  static Curve animationCurve = Curves.easeOut;

  // ランクカラー
  static Color getRankColor(String rank) {
    switch (rank) {
      case 'レギュラー':
        return primaryColor;
      case 'プラチナ':
        return secondaryColor;
      case 'スーパー':
        return accentColor;
      default:
        return primaryColor;
    }
  }

  // テーマデータ
  static ThemeData get lightTheme {
    // TextThemeで完全に日本語フォントをセットアップ
    final TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 48,
        ),
      ),
      displayMedium: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
      ),
      displaySmall: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      headlineMedium: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      titleLarge: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      titleMedium: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      bodyLarge: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: foregroundColor,
          fontSize: 16,
        ),
      ),
      bodyMedium: GoogleFonts.mPlusRounded1c(
        textStyle: const TextStyle(
          color: mutedForegroundColor,
          fontSize: 14,
        ),
      ),
    );
    
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      fontFamily: GoogleFonts.mPlusRounded1c().fontFamily,
      textTheme: textTheme, // カスタムテキストテーマを適用
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardBackgroundColor,
        onPrimary: primaryForeground,
        onSecondary: secondaryForeground,
        onSurface: cardForegroundColor,
        error: destructiveColor,
        onError: destructiveForeground,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          textStyle: const TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// グラデーションテキスト用のウィジェット
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    Key? key,
    this.style,
    this.gradient = AppTheme.primaryGradient,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
} 
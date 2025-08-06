import 'package:flutter/material.dart';

/// テーマ定数
class ThemeConstants {
  // メインカラー
  static const Color primaryPurple = Color(0xFFD10FEE);
  static const Color secondaryPurple = Color(0xFF8C52FF);
  static const Color accentPink = Color(0xFFFF7AC5);
  static const Color accentBlue = Color(0xFF4285F4);
  static const Color accentTeal = Color(0xFF4ECDC4);
  
  // ライトテーマ
  static const Color lightBackground = Color(0xFFF9F4FA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightMuted = Color(0xFFF0EAF2);
  static const Color lightMutedForeground = Color(0xFF736B76);
  static const Color lightBorder = Color(0xFFE5DCE7);
  
  // ダークテーマ
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkOnBackground = Color(0xFFF4F4F5);
  static const Color darkOnSurface = Color(0xFFF4F4F5);
  static const Color darkMuted = Color(0xFF27272A);
  static const Color darkMutedForeground = Color(0xFFA1A1AA);
  static const Color darkBorder = Color(0xFF27272A);
  
  // エラーカラー
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // エレベーション
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation16 = 16.0;
  
  // 半径
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  
  // スペーシング
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;
  
  // アニメーション
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  static const Curve animationCurveDefault = Curves.easeInOut;
  static const Curve animationCurveEaseOut = Curves.easeOut;
  static const Curve animationCurveEaseIn = Curves.easeIn;
  
  // 影
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity( 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get darkShadow => [
    BoxShadow(
      color: Colors.black.withOpacity( 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  // グラデーション
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, accentPink, accentBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ランク
  static const Map<String, Color> rankColors = {
    'none': Color(0xFF9E9E9E),
    'bronze': Color(0xFFCD7F32),
    'silver': Color(0xFFC0C0C0),
    'gold': Color(0xFFFFD700),
    'platinum': Color(0xFFE5E4E2),
    'diamond': Color(0xFFB9F2FF),
  };
  
  // StarRank色分け
  static const Map<String, Color> starRankColors = {
    'レギュラー': primaryPurple,
    'プラチナ': secondaryPurple,
    'スーパー': accentPink,
  };
  
  // 破壊的カラー
  static const Color destructiveColor = Color(0xFFDC2626);
  static const Color destructiveForeground = Colors.white;
  
  // 成功カラー
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);
  
  // 警告カラー
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFED7AA);
  
  // 情報カラー
  static const Color infoSurface = Color(0xFFF0F9FF);
  static const Color infoBorder = Color(0xFFBAE6FD);
  
  // カードデコレーション
  static BoxDecoration lightCardDecoration = BoxDecoration(
    color: lightSurface,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: lightBorder),
    boxShadow: lightShadow,
  );
  
  static BoxDecoration darkCardDecoration = BoxDecoration(
    color: darkSurface,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: darkBorder),
    boxShadow: darkShadow,
  );
  
  // ガラス効果
  static BoxDecoration glassEffect = BoxDecoration(
    color: Colors.white.withOpacity( 0.1),
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(
      color: Colors.white.withOpacity( 0.2),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity( 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // フォントウェイト
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  
  // ブレークポイント
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}
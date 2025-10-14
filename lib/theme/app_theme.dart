import 'package:flutter/material.dart';
import 'tokens.dart';

class AppTheme {
  static const Color primaryColor = AppColors.brand;
  
  static ThemeData get lightTheme => buildTheme();
  static ThemeData get darkTheme => buildTheme(); // TODO: ダークテーマを実装
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, fontFamily: 'NotoSansJP');
  const tokens = AppTokens.defaultTokens;
  
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.text,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.radius.lgRadius,
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.all(tokens.spacing.md),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border:
          const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: AppColors.brand)),
      contentPadding: EdgeInsets.all(tokens.spacing.md),
    ),
    extensions: const [AppTokens.defaultTokens],
  );
}

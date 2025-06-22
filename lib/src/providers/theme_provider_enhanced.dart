import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマモード
enum AppThemeMode {
  light('light', 'ライト'),
  dark('dark', 'ダーク'),
  system('system', 'システム');

  const AppThemeMode(this.value, this.displayName);
  
  final String value;
  final String displayName;

  /// 文字列から AppThemeMode を取得
  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }
}

/// テーマ状態管理
class ThemeState {
  final AppThemeMode themeMode;
  final bool isSystemDarkMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    required this.isSystemDarkMode,
    this.isLoading = false,
  });

  /// 実際のテーマモードを取得
  ThemeMode get effectiveThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 現在ダークモードかどうか
  bool get isDarkMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return isSystemDarkMode;
    }
  }

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isSystemDarkMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDarkMode: isSystemDarkMode ?? this.isSystemDarkMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isSystemDarkMode == isSystemDarkMode &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode =>
      themeMode.hashCode ^ isSystemDarkMode.hashCode ^ isLoading.hashCode;
}

/// テーマ状態管理クラス
class ThemeNotifierEnhanced extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifierEnhanced() : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isSystemDarkMode: false,
  )) {
    _initialize();
  }

  /// 初期化
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      final themeMode = savedTheme != null 
          ? AppThemeMode.fromString(savedTheme)
          : AppThemeMode.system;
      
      state = state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      );
    } catch (e) {
      // エラーが発生した場合はシステムテーマにフォールバック
      state = state.copyWith(
        themeMode: AppThemeMode.system,
        isLoading: false,
      );
    }
  }

  /// システムのダークモード状態を更新
  void updateSystemDarkMode(bool isDarkMode) {
    if (state.isSystemDarkMode != isDarkMode) {
      state = state.copyWith(isSystemDarkMode: isDarkMode);
    }
  }

  /// テーマモードを設定
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (state.themeMode == themeMode) return;
    
    try {
      state = state.copyWith(themeMode: themeMode);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.value);
    } catch (e) {
      // 保存に失敗した場合は元に戻す
      // ただし、UI上は新しいテーマを反映する
    }
  }

  /// ライト/ダークの切り替え
  Future<void> toggleLightDark() async {
    final newMode = state.isDarkMode 
        ? AppThemeMode.light 
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// システムテーマに切り替え
  Future<void> useSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// 次のテーマに切り替え（light -> dark -> system -> light...）
  Future<void> cycleTheme() async {
    AppThemeMode nextMode;
    switch (state.themeMode) {
      case AppThemeMode.light:
        nextMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        nextMode = AppThemeMode.system;
        break;
      case AppThemeMode.system:
        nextMode = AppThemeMode.light;
        break;
    }
    await setThemeMode(nextMode);
  }

  /// テーマをリセット（システムテーマに戻す）
  Future<void> resetTheme() async {
    await setThemeMode(AppThemeMode.system);
  }
}

/// テーマプロバイダー（新版）
final themeProviderEnhanced = StateNotifierProvider<ThemeNotifierEnhanced, ThemeState>((ref) {
  return ThemeNotifierEnhanced();
});

/// 現在のテーマモードプロバイダー
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeProviderEnhanced);
  return themeState.effectiveThemeMode;
});

/// ダークモードかどうかのプロバイダー
final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProviderEnhanced);
  return themeState.isDarkMode;
});

/// テーマが読み込み中かどうかのプロバイダー
final isThemeLoadingProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProviderEnhanced);
  return themeState.isLoading;
});

/// テーマアクションプロバイダー
final themeActionProvider = Provider<ThemeActions>((ref) {
  return ThemeActions(ref.read(themeProviderEnhanced.notifier));
});

/// テーマアクションクラス
class ThemeActions {
  final ThemeNotifierEnhanced _notifier;
  
  const ThemeActions(this._notifier);

  /// ライトテーマに設定
  Future<void> setLight() => _notifier.setThemeMode(AppThemeMode.light);

  /// ダークテーマに設定
  Future<void> setDark() => _notifier.setThemeMode(AppThemeMode.dark);

  /// システムテーマに設定
  Future<void> setSystem() => _notifier.setThemeMode(AppThemeMode.system);

  /// テーマモードを設定
  Future<void> setThemeMode(AppThemeMode mode) => _notifier.setThemeMode(mode);

  /// ライト/ダーク切り替え
  Future<void> toggle() => _notifier.toggleLightDark();

  /// 次のテーマに切り替え
  Future<void> cycle() => _notifier.cycleTheme();

  /// リセット
  Future<void> reset() => _notifier.resetTheme();

  /// システムダークモード状態を更新
  void updateSystemDarkMode(bool isDarkMode) {
    _notifier.updateSystemDarkMode(isDarkMode);
  }
}

/// レガシーテーマプロバイダー（互換性のため）
@Deprecated('Use themeProviderEnhanced instead')
final themeProvider = StateNotifierProvider<LegacyThemeNotifier, AppThemeMode>((ref) {
  return LegacyThemeNotifier();
});

/// レガシーテーマ通知クラス（互換性のため）
@Deprecated('Use ThemeNotifierEnhanced instead')
class LegacyThemeNotifier extends StateNotifier<AppThemeMode> {
  LegacyThemeNotifier() : super(AppThemeMode.system);
  
  void toggleTheme() {
    state = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }
  
  void setTheme(AppThemeMode theme) {
    state = theme;
  }
}
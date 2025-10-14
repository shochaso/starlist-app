import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/lazy_loading_manager.dart';

/// 軽量化のためのプリローダーサービス
class LightweightPreloader {
  static final LightweightPreloader _instance = LightweightPreloader._internal();
  factory LightweightPreloader() => _instance;
  LightweightPreloader._internal();

  final LazyLoadingManager _lazyManager = LazyLoadingManager();
  final Map<String, dynamic> _preloadedData = {};
  final Map<String, Timer> _preloadTimers = {};

  /// 軽量化を考慮したプリロード戦略
  static const Map<String, PreloadStrategy> _strategies = {
    'core': PreloadStrategy.immediate,
    'auth': PreloadStrategy.immediate,
    'data_import': PreloadStrategy.onDemand,
    'youtube': PreloadStrategy.delayed,
    'maps': PreloadStrategy.background,
    'analytics': PreloadStrategy.background,
  };

  /// アプリ起動時の軽量プリロード
  Future<void> initializeLightweight() async {
    // 必要最小限のコアモジュールのみプリロード
    await _preloadCoreModules();
    
    // バックグラウンドで低優先度モジュールをプリロード
    _scheduleBackgroundPreload();
  }

  /// コアモジュールの軽量プリロード
  Future<void> _preloadCoreModules() async {
    final coreModules = ['core', 'auth'];
    
    for (final module in coreModules) {
      try {
        await _preloadModule(module);
      } catch (e) {
        debugPrint('軽量化警告: コアモジュール $module のプリロードに失敗: $e');
      }
    }
  }

  /// モジュール別プリロード
  Future<void> _preloadModule(String moduleName) async {
    final strategy = _strategies[moduleName] ?? PreloadStrategy.onDemand;
    
    switch (strategy) {
      case PreloadStrategy.immediate:
        await _immediatePreload(moduleName);
        break;
      case PreloadStrategy.delayed:
        _scheduleDelayedPreload(moduleName);
        break;
      case PreloadStrategy.background:
        _scheduleBackgroundPreload(moduleName);
        break;
      case PreloadStrategy.onDemand:
        // オンデマンドなので何もしない
        break;
    }
  }

  /// 即座プリロード（軽量化対応）
  Future<void> _immediatePreload(String moduleName) async {
    return _lazyManager.loadModule(
      moduleName,
      () => _createLightweightModule(moduleName),
      cacheExpiry: const Duration(hours: 1),
    );
  }

  /// 遅延プリロード（軽量化対応）
  void _scheduleDelayedPreload(String moduleName) {
    _preloadTimers[moduleName] = Timer(
      const Duration(seconds: 5), // 5秒後にプリロード
      () => _preloadModule(moduleName),
    );
  }

  /// バックグラウンドプリロード（軽量化対応）
  void _scheduleBackgroundPreload([String? specificModule]) {
    Timer(const Duration(seconds: 10), () async {
      if (specificModule != null) {
        await _backgroundPreload(specificModule);
      } else {
        final backgroundModules = ['youtube', 'maps', 'analytics'];
        for (final module in backgroundModules) {
          await _backgroundPreload(module);
          // 軽量化のため各モジュール間に間隔を空ける
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    });
  }

  /// バックグラウンドプリロード実行
  Future<void> _backgroundPreload(String moduleName) async {
    if (_lazyManager.isModuleLoaded(moduleName)) {
      return;
    }

    try {
      await _lazyManager.loadModule(
        moduleName,
        () => _createLightweightModule(moduleName),
        cacheExpiry: const Duration(minutes: 30),
      );
    } catch (e) {
      debugPrint('軽量化情報: バックグラウンドプリロード $moduleName をスキップ: $e');
    }
  }

  /// 軽量化されたモジュール作成
  Future<dynamic> _createLightweightModule(String moduleName) async {
    switch (moduleName) {
      case 'core':
        return _createCoreModule();
      case 'auth':
        return _createAuthModule();
      case 'data_import':
        return _createDataImportModule();
      case 'youtube':
        return _createYouTubeModule();
      case 'maps':
        return _createMapsModule();
      case 'analytics':
        return _createAnalyticsModule();
      default:
        throw Exception('未知のモジュール: $moduleName');
    }
  }

  /// 軽量化されたコアモジュール
  Future<Map<String, dynamic>> _createCoreModule() async {
    return {
      'name': 'core',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['error_handler', 'logger'],
    };
  }

  /// 軽量化された認証モジュール
  Future<Map<String, dynamic>> _createAuthModule() async {
    return {
      'name': 'auth',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['supabase_auth'],
    };
  }

  /// 軽量化されたデータ取り込みモジュール
  Future<Map<String, dynamic>> _createDataImportModule() async {
    return {
      'name': 'data_import',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['text_parser'],
    };
  }

  /// 軽量化されたYouTubeモジュール（機能制限版）
  Future<Map<String, dynamic>> _createYouTubeModule() async {
    return {
      'name': 'youtube',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['text_parser_only'], // 動画プレイヤーは除外
    };
  }

  /// 軽量化されたMapsモジュール（機能制限版）
  Future<Map<String, dynamic>> _createMapsModule() async {
    return {
      'name': 'maps',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['url_generator_only'], // インタラクティブマップは除外
    };
  }

  /// 軽量化された分析モジュール
  Future<Map<String, dynamic>> _createAnalyticsModule() async {
    return {
      'name': 'analytics',
      'version': '1.0.0',
      'lightweight': true,
      'services': ['basic_tracking'],
    };
  }

  /// プリロード状態の取得
  Map<String, dynamic> getPreloadStatus() {
    return {
      'preloaded_modules': _preloadedData.keys.toList(),
      'active_timers': _preloadTimers.keys.toList(),
      'loading_stats': _lazyManager.getLoadingStats(),
    };
  }

  /// 軽量化のためのクリーンアップ
  void cleanup() {
    for (var timer in _preloadTimers.values) {
      timer.cancel();
    }
    _preloadTimers.clear();
    _preloadedData.clear();
    _lazyManager.cleanupMemory();
  }
}

/// プリロード戦略の定義
enum PreloadStrategy {
  immediate,  // 即座にプリロード
  delayed,    // 遅延プリロード
  background, // バックグラウンドプリロード
  onDemand,   // オンデマンド（プリロードしない）
} 
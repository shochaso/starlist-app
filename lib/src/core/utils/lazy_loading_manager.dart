import 'dart:async';

/// 軽量化のための遅延ローディング管理クラス
class LazyLoadingManager {
  static final LazyLoadingManager _instance = LazyLoadingManager._internal();
  factory LazyLoadingManager() => _instance;
  LazyLoadingManager._internal();

  final Map<String, bool> _loadedModules = {};
  final Map<String, Future<dynamic>> _loadingModules = {};
  final Map<String, DateTime> _loadTimestamps = {};
  
  /// 軽量化優先度設定
  static const Map<String, int> _modulePriority = {
    'core': 1,        // 最高優先度
    'auth': 2,        // 認証機能
    'data_import': 3, // データ取り込み
    'youtube': 4,     // YouTube機能（軽量化対象）
    'maps': 5,        // 地図機能（軽量化対象）
    'analytics': 6,   // 分析機能（最低優先度）
  };

  /// モジュールが読み込み済みかチェック
  bool isModuleLoaded(String moduleName) {
    return _loadedModules[moduleName] ?? false;
  }

  /// 軽量化を考慮したモジュール読み込み
  Future<T> loadModule<T>(
    String moduleName,
    Future<T> Function() loader, {
    bool forceReload = false,
    Duration? cacheExpiry,
  }) async {
    // キャッシュ期限チェック（軽量化のため）
    if (cacheExpiry != null && _loadTimestamps.containsKey(moduleName)) {
      final loadTime = _loadTimestamps[moduleName]!;
      if (DateTime.now().difference(loadTime) > cacheExpiry) {
        _loadedModules.remove(moduleName);
        _loadingModules.remove(moduleName);
        _loadTimestamps.remove(moduleName);
      }
    }

    if (_loadedModules[moduleName] == true && !forceReload) {
      return _loadingModules[moduleName] as Future<T>;
    }

    if (_loadingModules.containsKey(moduleName)) {
      return _loadingModules[moduleName] as Future<T>;
    }

    // 優先度チェック（軽量化のため低優先度は遅延）
    final priority = _modulePriority[moduleName] ?? 999;
    if (priority > 4) {
      // 低優先度モジュールは少し遅延させる
      await Future.delayed(Duration(milliseconds: 100 * (priority - 4)));
    }

    final future = _loadModuleWithErrorHandling(moduleName, loader);
    _loadingModules[moduleName] = future;

    try {
      final result = await future;
      _loadedModules[moduleName] = true;
      _loadTimestamps[moduleName] = DateTime.now();
      return result;
    } catch (e) {
      _loadedModules[moduleName] = false;
      _loadingModules.remove(moduleName);
      rethrow;
    }
  }

  /// エラーハンドリング付きモジュール読み込み
  Future<T> _loadModuleWithErrorHandling<T>(
    String moduleName,
    Future<T> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (e) {
      print('軽量化エラー: モジュール $moduleName の読み込みに失敗: $e');
      rethrow;
    }
  }

  /// 軽量化のためのメモリクリーンアップ
  void cleanupMemory() {
    final now = DateTime.now();
    final expiredModules = <String>[];
    
    _loadTimestamps.forEach((module, timestamp) {
      // 30分以上使用されていないモジュールをクリーンアップ
      if (now.difference(timestamp) > const Duration(minutes: 30)) {
        expiredModules.add(module);
      }
    });
    
    for (final module in expiredModules) {
      unloadModule(module);
    }
  }

  /// モジュールのアンロード（軽量化のため）
  void unloadModule(String moduleName) {
    _loadedModules.remove(moduleName);
    _loadingModules.remove(moduleName);
    _loadTimestamps.remove(moduleName);
  }

  /// 軽量化統計情報
  Map<String, dynamic> getLoadingStats() {
    return {
      'loaded_modules': _loadedModules.length,
      'loading_modules': _loadingModules.length,
      'memory_usage': _calculateMemoryUsage(),
      'cleanup_candidates': _getCleanupCandidates(),
    };
  }

  int _calculateMemoryUsage() {
    // 簡易メモリ使用量計算
    return _loadedModules.length * 100; // KB単位の概算
  }

  List<String> _getCleanupCandidates() {
    final now = DateTime.now();
    return _loadTimestamps.entries
        .where((entry) => now.difference(entry.value) > const Duration(minutes: 15))
        .map((entry) => entry.key)
        .toList();
  }
} 
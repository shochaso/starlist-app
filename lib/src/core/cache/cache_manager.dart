import 'dart:async';
import 'package:flutter/foundation.dart';

/// キャッシュマネージャークラス
///
/// アプリケーション全体のキャッシュを管理します。
class CacheManager {
  /// インメモリキャッシュ
  final Map<String, _CacheEntry> _cache = {};
  
  /// デフォルトの有効期限
  final Duration _defaultExpiry = const Duration(hours: 1);
  
  /// ロガー
  final Logger? _logger;
  
  /// コンストラクタ
  CacheManager({Logger? logger}) : _logger = logger;
  
  /// キャッシュからデータを取得
  Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry == null) {
      _logInfo('Cache miss: $key');
      return null;
    }
    
    // 有効期限チェック
    if (entry.expiry.isBefore(DateTime.now())) {
      _logInfo('Cache expired: $key');
      _cache.remove(key);
      return null;
    }
    
    _logInfo('Cache hit: $key');
    return entry.data as T?;
  }
  
  /// キャッシュにデータを保存
  Future<void> set<T>(String key, T data, {Duration? expiry}) async {
    final expiryDuration = expiry ?? _defaultExpiry;
    final expiryTime = DateTime.now().add(expiryDuration);
    
    _cache[key] = _CacheEntry(
      data: data,
      expiry: expiryTime,
    );
    
    _logInfo('Cache set: $key, expires at: $expiryTime');
  }
  
  /// キャッシュからデータを削除
  Future<void> remove(String key) async {
    _cache.remove(key);
    _logInfo('Cache removed: $key');
  }
  
  /// キャッシュをクリア
  Future<void> clear() async {
    _cache.clear();
    _logInfo('Cache cleared');
  }
  
  /// 期限切れのキャッシュをクリア
  Future<void> clearExpired() async {
    final now = DateTime.now();
    final expiredKeys = _cache.keys.where((key) => _cache[key]!.expiry.isBefore(now)).toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    _logInfo('Expired cache cleared: ${expiredKeys.length} entries removed');
  }
  
  /// キャッシュの統計情報を取得
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final totalEntries = _cache.length;
    final expiredEntries = _cache.values.where((entry) => entry.expiry.isBefore(now)).length;
    final validEntries = totalEntries - expiredEntries;
    
    return {
      'total_entries': totalEntries,
      'valid_entries': validEntries,
      'expired_entries': expiredEntries,
      'memory_usage_estimate': _estimateMemoryUsage(),
    };
  }
  
  /// メモリ使用量を推定（非常に大まかな推定）
  int _estimateMemoryUsage() {
    // 非常に大まかな推定
    // 実際の実装ではより正確な方法を使用すべき
    return _cache.entries.fold<int>(0, (sum, entry) {
      // キーのサイズ + データのサイズ（大まかな推定）
      return sum + entry.key.length * 2 + _estimateObjectSize(entry.value.data);
    });
  }
  
  /// オブジェクトサイズを推定（非常に大まかな推定）
  int _estimateObjectSize(dynamic obj) {
    if (obj == null) return 0;
    if (obj is String) return obj.length * 2;
    if (obj is num) return 8;
    if (obj is bool) return 1;
    if (obj is List) return obj.fold<int>(0, (sum, item) => sum + _estimateObjectSize(item));
    if (obj is Map) {
      return obj.entries.fold<int>(0, (sum, entry) => 
        sum + _estimateObjectSize(entry.key) + _estimateObjectSize(entry.value));
    }
    // その他のオブジェクトは大まかに100バイトと推定
    return 100;
  }
  
  /// 情報ログを記録
  void _logInfo(String message) {
    _logger?.info('CacheManager: $message');
  }
}

/// キャッシュエントリクラス
class _CacheEntry {
  final dynamic data;
  final DateTime expiry;
  
  _CacheEntry({
    required this.data,
    required this.expiry,
  });
}

/// ロガークラス（簡易版）
class Logger {
  void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }
}

import 'package:flutter/foundation.dart';

/// ロガークラス
///
/// アプリケーション全体のログを管理します。
class Logger {
  /// コンストラクタ
  Logger();

  /// 情報ログを記録
  void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
    // 実際の実装では適切なロギングライブラリを使用
    // 例: Firebase Crashlytics, Sentry など
  }
  
  /// 警告ログを記録
  void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
    // 実際の実装では適切なロギングライブラリを使用
  }
  
  /// エラーログを記録
  void error(String message, [dynamic error]) {
    if (kDebugMode) {
      print('[ERROR] $message: $error');
      if (error is Error) {
        print(error.stackTrace);
      }
    }
    // 実際の実装では適切なロギングライブラリを使用
  }
  
  /// メトリクスを記録
  void metric(String name, double value, {Map<String, String>? tags}) {
    if (kDebugMode) {
      print('[METRIC] $name: $value ${tags != null ? tags : ''}');
    }
    // 実際の実装ではパフォーマンスモニタリングサービスを使用
    // 例: Firebase Performance Monitoring など
  }
}

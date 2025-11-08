import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全なプリファレンス保存ラッパー
/// 
/// Webでは機密値（トークン等）の永続化を禁止し、モバイルではSecureStorageを使用します。
/// Webはインメモリ運用（persistSession: false）を推奨し、再開時はEdge Function経由の再発行を想定します。
class SecurePrefs {
  /// 保存禁止キーリスト（大文字小文字を区別しない）
  static const _forbiddenKeys = {
    'token',
    'access_token',
    'refresh_token',
    'jwt',
    'supabase.auth.token',
    'auth_token',
    'session_token',
  };

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// 文字列を保存（Webでは機密値の保存を禁止）
  /// 
  /// [key] が [_forbiddenKeys] に含まれる場合、またはWeb環境では例外をスローします。
  /// Webでは永続化しない方針（persistSession: false）に切替え、再開時はEdge Function経由の再発行を推奨します。
  static Future<void> setString(String key, String value) async {
    _assertKey(key);
    if (kIsWeb) {
      // Web: インメモリ推奨（永続化しない）。必要時は sessionStorage ではなく保持を諦める方針。
      // → アプリの Auth 層で「persistSession: false」に切替え、復元はサーバ(Edge)経由で行う。
      throw StateError(
        'Web では機密値の永続化を禁止: key=$key. '
        'Webではインメモリ運用（persistSession: false）を推奨し、再開時はEdge Function経由の再発行を利用してください。',
      );
    } else {
      // iOS/Android: セキュア領域
      await _secure.write(key: key, value: value);
    }
  }

  /// 文字列を取得（Webでは常にnullを返す）
  static Future<String?> getString(String key) async {
    _assertKey(key);
    if (kIsWeb) return null; // Webでは保存していない前提
    return _secure.read(key: key);
  }

  /// キーを削除
  static Future<void> remove(String key) async {
    if (kIsWeb) return;
    await _secure.delete(key: key);
  }

  /// 全てのキーを削除
  static Future<void> clear() async {
    if (kIsWeb) return;
    await _secure.deleteAll();
  }

  /// キーが保存禁止リストに含まれていないか確認
  static void _assertKey(String key) {
    final lowerKey = key.toLowerCase();
    if (_forbiddenKeys.contains(lowerKey)) {
      throw StateError(
        'このキーは保存禁止です: $key. '
        '機密情報はWebでは永続化せず、モバイルではSecureStorageを使用してください。',
      );
    }
  }
}


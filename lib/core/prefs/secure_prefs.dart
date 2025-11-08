import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'forbidden_keys.dart';

/// 安全なプリファレンス保存ラッパー
///
/// Webでは機密値（トークン等）の永続化を禁止し、モバイルではSecureStorageを使用します。
/// Webはインメモリ運用（persistSession: false）を推奨し、再開時はEdge Function経由の再発行を想定します。
class SecurePrefs {
  static FlutterSecureStorage? _secure;

  static FlutterSecureStorage _ensureSecure() {
    _secure ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    return _secure!;
  }

  /// 文字列を保存（Webでは機密値の保存を禁止、それ以外はSecureStorageへ）
  ///
  /// [key] が [forbiddenKeys] に含まれる場合、Webでは例外をスローし、Mobileでは保存を許可します。
  static Future<void> setString(String key, String value) async {
    final lowerKey = key.toLowerCase();
    if (kIsWeb) {
      // Web: 機密キーは保存禁止（例外）
      if (forbiddenKeys.contains(lowerKey)) {
        throw StateError(
          'Web では機密値の永続化を禁止: key=$key. '
          'Webではインメモリ運用（persistSession: false）を推奨し、再開時はEdge Function経由の再発行を利用してください。',
        );
      }
      // Web: その他のキーも永続化しない（no-op）
      return;
    } else {
      // Mobile: セキュア領域に保存
      await _ensureSecure().write(key: key, value: value);
    }
  }

  /// 文字列を取得（Webでは常にnullを返す）
  static Future<String?> getString(String key) async {
    if (kIsWeb) return null; // Webでは保存していない前提
    return _ensureSecure().read(key: key);
  }

  /// キーを削除
  static Future<void> remove(String key) async {
    if (kIsWeb) return;
    await _ensureSecure().delete(key: key);
  }

  /// 全てのキーを削除
  static Future<void> clear() async {
    if (kIsWeb) return;
    await _ensureSecure().deleteAll();
  }
}

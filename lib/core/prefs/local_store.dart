import 'dart:convert';
import 'dart:html' as html;

/// ローカルストレージラッパー（非機密データ用）
/// 
/// 機密情報（トークン等）の保存は禁止されています。
/// 機密情報を保存する場合は、[SecurePrefs]を使用してください。
class LocalStore {
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

  final _ls = html.window.localStorage;

  int? getInt(String k) => _ls[k] != null ? int.tryParse(_ls[k]!) : null;
  void setInt(String k, int v) => _ls[k] = v.toString();

  String? getString(String k) => _ls[k];
  
  /// 文字列を保存（機密キーの保存は禁止）
  /// 
  /// 機密情報を保存する場合は、[SecurePrefs]を使用してください。
  void setString(String k, String v) {
    _assertKey(k);
    _ls[k] = v;
  }

  void setJson(String k, Object v) {
    _assertKey(k);
    _ls[k] = jsonEncode(v);
  }
  
  Map<String, dynamic>? getJson(String k) {
    final v = _ls[k];
    if (v == null) return null;
    return jsonDecode(v) as Map<String, dynamic>;
  }

  void remove(String k) => _ls.remove(k);

  /// キーが保存禁止リストに含まれていないか確認
  static void _assertKey(String key) {
    final lowerKey = key.toLowerCase();
    if (_forbiddenKeys.contains(lowerKey)) {
      throw StateError(
        'このキーは保存禁止です: $key. '
        '機密情報は SecurePrefs を使用してください（Webでは永続化されません）。',
      );
    }
  }
}

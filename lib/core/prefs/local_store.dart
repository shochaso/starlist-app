import 'dart:convert';
import 'dart:html' as html;
import 'forbidden_keys.dart';

class LocalStore {
  final _ls = html.window.localStorage;

  int? getInt(String k) => _ls[k] != null ? int.tryParse(_ls[k]!) : null;
  void setInt(String k, int v) {
    final lower = k.toLowerCase();
    if (forbiddenKeys.contains(lower)) {
      throw StateError('localStorage に機密キーを保存できません: $k');
    }
    _ls[k] = v.toString();
  }

  String? getString(String k) => _ls[k];
  void setString(String k, String v) {
    final lower = k.toLowerCase();
    if (forbiddenKeys.contains(lower)) {
      throw StateError('localStorage に機密キーを保存できません: $k');
    }
    _ls[k] = v;
  }

  void setJson(String k, Object v) {
    final lower = k.toLowerCase();
    if (forbiddenKeys.contains(lower)) {
      throw StateError('localStorage に機密キーを保存できません: $k');
    }
    _ls[k] = jsonEncode(v);
  }

  Map<String, dynamic>? getJson(String k) {
    final v = _ls[k];
    if (v == null) return null;
    return jsonDecode(v) as Map<String, dynamic>;
  }

  void remove(String k) => _ls.remove(k);
}

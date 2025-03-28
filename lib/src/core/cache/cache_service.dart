import "dart:convert";
import "package:shared_preferences.dart";

class CacheService {
  static const String _prefix = "starlist_cache_";
  final SharedPreferences _prefs;
  final Duration _defaultExpiration;

  CacheService(this._prefs, {Duration? defaultExpiration})
      : _defaultExpiration = defaultExpiration ?? const Duration(hours: 1);

  Future<void> set<T>(String key, T value, {Duration? expiration}) async {
    final data = {
      "value": value,
      "expires_at": DateTime.now().add(expiration ?? _defaultExpiration).toIso8601String(),
    };
    await _prefs.setString(_prefix + key, jsonEncode(data));
  }

  T? get<T>(String key) {
    final data = _prefs.getString(_prefix + key);
    if (data == null) return null;

    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final expiresAt = DateTime.parse(decoded["expires_at"] as String);

    if (DateTime.now().isAfter(expiresAt)) {
      delete(key);
      return null;
    }

    return decoded["value"] as T;
  }

  Future<void> delete(String key) async {
    await _prefs.remove(_prefix + key);
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await _prefs.remove(key);
      }
    }
  }
}

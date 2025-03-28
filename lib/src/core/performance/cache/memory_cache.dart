import "dart:async";

class MemoryCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration _defaultExpiration;

  MemoryCache({Duration? defaultExpiration})
      : _defaultExpiration = defaultExpiration ?? const Duration(hours: 1);

  void set(String key, T value, {Duration? expiration}) {
    _cache[key] = CacheEntry(
      value: value,
      expiration: DateTime.now().add(expiration ?? _defaultExpiration),
    );
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiration;

  CacheEntry({required this.value, required this.expiration});

  bool get isExpired => DateTime.now().isAfter(expiration);
}

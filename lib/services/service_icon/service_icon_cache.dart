import 'dart:typed_data';

/// Maximum number of icon payloads to keep in memory before LRU eviction.
const int kServiceIconCacheLimit = 100;

/// The origin of an icon payload. Used for diagnostics and fallback handling.
enum ServiceIconSourceType {
  cache,
  cdnSvg,
  cdnPng,
  assetSvg,
  assetPng,
  inline,
  fallback,
}

class ServiceIconPayload {
  const ServiceIconPayload({
    required this.bytes,
    required this.isSvg,
    this.mimeType,
  });

  const ServiceIconPayload.svg(
    Uint8List bytes, {
    this.mimeType = 'image/svg+xml',
  })  : bytes = bytes,
        isSvg = true;

  const ServiceIconPayload.raster(
    Uint8List bytes, {
    this.mimeType = 'image/png',
  })  : bytes = bytes,
        isSvg = false;

  final Uint8List bytes;
  final bool isSvg;
  final String? mimeType;
}

class ServiceIconCacheEntry {
  const ServiceIconCacheEntry({
    required this.payload,
    required this.originalSource,
    required this.originPath,
    required this.loadedAt,
    required this.loadDuration,
  });

  final ServiceIconPayload payload;
  final ServiceIconSourceType originalSource;
  final String originPath;
  final DateTime loadedAt;
  final Duration loadDuration;
}

/// In-memory LRU cache for icon payloads. The cache intentionally stores the
/// raw bytes so the caller can decide whether to render via SVG or raster APIs.
class ServiceIconCache {
  ServiceIconCache._();

  static final _cache = <String, ServiceIconCacheEntry>{};

  static ServiceIconCacheEntry? get(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      // Move to the end to express recent use.
      _cache[key] = entry;
      return entry;
    }
    return null;
  }

  static void put(String key, ServiceIconCacheEntry entry) {
    if (_cache.length >= kServiceIconCacheLimit) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = entry;
  }

  static void clear() => _cache.clear();

  static int get size => _cache.length;
}

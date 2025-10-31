import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../config/debug_flags.dart';

/// Lightweight analytics helper that aggregates Cloudflare cache behaviour for
/// CDN-backed requests (icons, transformed images, signed media, ...).
class CdnAnalytics {
  CdnAnalytics._();

  static final CdnAnalytics instance = CdnAnalytics._();

  final Map<String, _BucketStats> _stats =
      SplayTreeMap<String, _BucketStats>();

  void recordResponse({
    required String bucket,
    required Map<String, String> headers,
    required Duration duration,
  }) {
    final status = (headers['cf-cache-status'] ??
            headers['cf-cache-status'.toLowerCase()] ??
            headers['x-cache'] ??
            '')
        .toLowerCase()
        .trim();
    final hitType = _cacheHitTypeFromHeader(status);
    _stats.putIfAbsent(bucket, _BucketStats.new).register(hitType, duration);
    _maybeDebugLog(bucket);
  }

  void recordError({
    required String bucket,
    required Object error,
  }) {
    _stats.putIfAbsent(bucket, _BucketStats.new).errors++;
    if (DebugFlags.instance.imageDiagnostics && kDebugMode) {
      debugPrint('[CDN] $bucket error: $error');
    }
  }

  Map<String, dynamic> snapshot() {
    return _stats.map((key, value) => MapEntry(key, value.toJson()));
  }

  void clear() => _stats.clear();

  void _maybeDebugLog(String bucket) {
    if (!DebugFlags.instance.imageDiagnostics || !kDebugMode) {
      return;
    }
    final stats = _stats[bucket];
    if (stats == null) return;
    debugPrint('[CDN] $bucket '
        'hit=${stats.hits} miss=${stats.misses} stale=${stats.stale} '
        'err=${stats.errors}');
  }
}

enum _CacheHitType { hit, miss, stale }

_CacheHitType _cacheHitTypeFromHeader(String status) {
  switch (status) {
    case 'hit':
    case 'dynamic':
    case 'revalidated':
      return _CacheHitType.hit;
    case 'expired':
    case 'stale':
    case 'updating':
      return _CacheHitType.stale;
    default:
      return _CacheHitType.miss;
  }
}

class _BucketStats {
  int hits = 0;
  int misses = 0;
  int stale = 0;
  int errors = 0;
  Duration totalLatency = Duration.zero;

  void register(_CacheHitType type, Duration latency) {
    switch (type) {
      case _CacheHitType.hit:
        hits++;
        break;
      case _CacheHitType.miss:
        misses++;
        break;
      case _CacheHitType.stale:
        stale++;
        break;
    }
    totalLatency += latency;
  }

  Map<String, dynamic> toJson() {
    final total = hits + misses + stale;
    final avgLatencyMs =
        total == 0 ? 0 : totalLatency.inMilliseconds / total;
    return {
      'hits': hits,
      'misses': misses,
      'stale': stale,
      'errors': errors,
      'avgLatencyMs': avgLatencyMs,
    };
  }
}

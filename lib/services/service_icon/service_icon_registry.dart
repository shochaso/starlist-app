import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../config/environment_config.dart';
import '../../utils/key_normalizer.dart';
import 'service_icon_cache.dart';
import 'service_icon_sources.dart';

class ServiceIconRegistry {
  ServiceIconRegistry._();

  static final ServiceIconRegistry instance = ServiceIconRegistry._();

  final Map<String, Future<ServiceIconResolution?>> _inFlight = {};
  final Map<String, ServiceIconResolution> _resolved = {};

  Future<ServiceIconResolution?> resolve(String rawKey) {
    final normalized = KeyNormalizer.normalize(rawKey);
    final alias = KeyNormalizer.resolveAlias(rawKey);
    if (normalized.isEmpty) {
      return Future.value(null);
    }

    final cached = _resolved[normalized];
    if (cached != null) {
      _logProbe(
        rawKey: rawKey,
        normalized: normalized,
        alias: alias,
        resolution: cached,
        stage: 'cache',
      );
      return Future.value(cached);
    }

    final existingFuture = _inFlight[normalized];
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = ServiceIconSources.resolve(normalized).then((result) {
      _inFlight.remove(normalized);
      if (result != null) {
        _resolved[normalized] = result;
      }
      _logProbe(
        rawKey: rawKey,
        normalized: normalized,
        alias: alias,
        resolution: result,
        stage: 'resolve',
      );
      return result;
    });
    _inFlight[normalized] = future;
    return future;
  }

  ServiceIconResolution? lookup(String rawKey) {
    final normalized = KeyNormalizer.normalize(rawKey);
    return _resolved[normalized];
  }

  Map<String, String> get icons =>
      _resolved.map((key, value) => MapEntry(key, value.originPath));

  static Future<void> init() async {
    ServiceIconCache.clear();
  }

  void clear() {
    _resolved.clear();
    _inFlight.clear();
    ServiceIconCache.clear();
  }

  static String? pathFor(String rawKey) {
    final normalized = KeyNormalizer.normalize(rawKey);
    if (normalized.isEmpty || EnvironmentConfig.assetsCdnOrigin.isEmpty) {
      return null;
    }
    final cacheBuster = Uri.encodeComponent(
      EnvironmentConfig.appBuildVersion,
    );
    return '${EnvironmentConfig.assetsCdnOrigin}/icons/$normalized.svg?v=$cacheBuster';
  }
}

void _logProbe({
  required String rawKey,
  required String normalized,
  required String alias,
  required ServiceIconResolution? resolution,
  required String stage,
}) {
  if (!kDebugMode) {
    return;
  }
  // Console で確実に見えるよう print を使用
  // ignore: avoid_print
  print(jsonEncode({
    'iconProbe': stage,
    'raw': rawKey,
    'normalized': normalized,
    'alias': alias,
    'source': resolution?.sourceType.name ?? 'none',
    'origin': resolution?.originPath,
    'cacheHit': resolution?.cacheHit ?? false,
  }));
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/environment_config.dart';
import '../../config/runtime_flags.dart';
import '../cdn_analytics.dart';
import '../../utils/key_normalizer.dart';
import 'service_icon_cache.dart';

const Duration _iconFetchTimeout = Duration(milliseconds: 2500);

final RegExp _cdnDenyPattern = RegExp(
  r'^(?:seven[_-]?eleven|family[_-]?mart|lawson|daily[_-]?yamazaki|ministop)$',
  caseSensitive: false,
);

Map<String, String>? _iconConfigCache;
Future<Map<String, String>> _loadIconConfig() async {
  if (_iconConfigCache != null) {
    return _iconConfigCache!;
  }
  final raw = await rootBundle.loadString('assets/config/service_icons.json');
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  _iconConfigCache = decoded.map(
    (key, value) => MapEntry(key.toString(), value.toString()),
  );
  return _iconConfigCache!;
}

Future<ServiceIconResolution?> _loadExplicitAsset(
  String cacheKey,
  String assetPath,
  ServiceIconSourceType sourceType,
) async {
  final stopwatch = Stopwatch()..start();
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();

  final payload = assetPath.toLowerCase().endsWith('.svg')
      ? ServiceIconPayload.svg(bytes)
      : ServiceIconPayload.raster(bytes);

  ServiceIconCache.put(
    cacheKey,
    ServiceIconCacheEntry(
      payload: payload,
      originalSource: sourceType,
      originPath: assetPath,
      loadedAt: DateTime.now(),
      loadDuration: stopwatch.elapsed,
    ),
  );

  return ServiceIconResolution(
    key: cacheKey,
    payload: payload,
    sourceType: sourceType,
    originPath: assetPath,
    duration: stopwatch.elapsed,
  );
}

Future<ServiceIconResolution?> _loadGeneric(String key) {
  return _loadExplicitAsset(
    key,
    'assets/service_icons/generic.svg',
    ServiceIconSourceType.assetSvg,
  );
}

bool _matchesDenyList(String value) =>
    value.isNotEmpty && _cdnDenyPattern.hasMatch(value);

bool _shouldBypassCdn(String rawKey, String normalized) {
  if (kForceGenericServiceIcons) {
    return true;
  }
  final alias = resolveAlias(rawKey);
  return _matchesDenyList(rawKey) ||
      _matchesDenyList(normalized) ||
      _matchesDenyList(alias);
}

Uri _buildCdnUri(String key, String extension) {
  final cacheBuster = Uri.encodeComponent(
    EnvironmentConfig.appBuildVersion,
  );
  return Uri.parse(
      '${EnvironmentConfig.assetsCdnOrigin}/icons/$key.$extension?v=$cacheBuster');
}

bool get _shouldLogResolution => kEnv == 'development';

class ServiceIconResolution {
  const ServiceIconResolution({
    required this.key,
    required this.payload,
    required this.sourceType,
    required this.originPath,
    required this.duration,
    this.cacheHit = false,
    this.originalSource,
    this.error,
  });

  final String key;
  final ServiceIconPayload payload;
  final ServiceIconSourceType sourceType;
  final ServiceIconSourceType? originalSource;
  final String originPath;
  final Duration duration;
  final bool cacheHit;
  final Object? error;
}

/// Resolves service icons from CDN (SVG preferred) with fallbacks to PNG and
/// bundled assets. Results are cached in-memory to avoid redundant decoding.
class ServiceIconSources {
  ServiceIconSources._();

  static final http.Client _client = http.Client();

  static Future<ServiceIconResolution?> resolve(String rawKey) async {
    final normalized = KeyNormalizer.normalize(rawKey);
    if (normalized.isEmpty) {
      return null;
    }
    if (kForceGenericServiceIcons) {
      final generic = await _loadGeneric(normalized);
      if (generic != null) {
        debugPrint('[ServiceIcon] forced generic for $rawKey -> $normalized');
      }
      return generic;
    }

    final cached = ServiceIconCache.get(normalized);
    if (cached != null) {
      return ServiceIconResolution(
        key: normalized,
        payload: cached.payload,
        sourceType: ServiceIconSourceType.cache,
        originalSource: cached.originalSource,
        originPath: cached.originPath,
        duration: Duration.zero,
        cacheHit: true,
      );
    }

    final config = await _loadIconConfig();
    final alias = resolveAlias(rawKey);
    final configCandidates = <String>{
      rawKey,
      normalized,
      alias,
    }..removeWhere((value) => value.isEmpty);

    for (final candidate in configCandidates) {
      final mapped = config[candidate];
      if (mapped != null && mapped.isNotEmpty) {
        final sourceType = mapped.toLowerCase().endsWith('.svg')
            ? ServiceIconSourceType.assetSvg
            : ServiceIconSourceType.assetPng;
        final explicit = await _loadExplicitAsset(
          normalized,
          mapped,
          sourceType,
        );
        if (explicit != null) {
          if (_shouldLogResolution) {
            debugPrint(
                '[ServiceIcon] resolved $normalized -> ${explicit.originPath} (config)');
          }
          return explicit;
        }
      }
    }

    final assetSvg = await _loadAsset(
      normalized,
      extension: 'svg',
      type: ServiceIconSourceType.assetSvg,
    );
    if (assetSvg != null) {
      if (_shouldLogResolution) {
        debugPrint(
            '[ServiceIcon] resolved $normalized -> ${assetSvg.originPath} (assetSvg)');
      }
      return assetSvg;
    }

    final assetPng = await _loadAsset(
      normalized,
      extension: 'png',
      type: ServiceIconSourceType.assetPng,
    );
    if (assetPng != null) {
      if (_shouldLogResolution) {
        debugPrint(
            '[ServiceIcon] resolved $normalized -> ${assetPng.originPath} (assetPng)');
      }
      return assetPng;
    }

    final skipCdn = _shouldBypassCdn(rawKey, normalized);
    if (!skipCdn) {
      final svgResolution = await _fetchRemote(
        normalized,
        extension: 'svg',
        type: ServiceIconSourceType.cdnSvg,
      );

      if (svgResolution != null) {
        if (_shouldLogResolution) {
          debugPrint(
              '[ServiceIcon] resolved $normalized -> ${svgResolution.originPath} (cdnSvg)');
        }
        return svgResolution;
      }

      final pngResolution = await _fetchRemote(
        normalized,
        extension: 'png',
        type: ServiceIconSourceType.cdnPng,
      );
      if (pngResolution != null) {
        if (_shouldLogResolution) {
          debugPrint(
              '[ServiceIcon] resolved $normalized -> ${pngResolution.originPath} (cdnPng)');
        }
        return pngResolution;
      }
    } else if (kDebugMode) {
      debugPrint('[ServiceIcon] bypassing CDN for $normalized (deny list)');
    }

    final generic = await _loadGeneric(normalized);
    if (_shouldLogResolution && generic != null) {
      debugPrint(
          '[ServiceIcon] resolved $normalized -> ${generic.originPath} (generic)');
    }
    return generic;
  }

  static Future<ServiceIconResolution?> _fetchRemote(
    String key, {
    required String extension,
    required ServiceIconSourceType type,
  }) async {
    if (kCfBypassLocal) {
      return null;
    }
    if (EnvironmentConfig.assetsCdnOrigin.isEmpty) {
      return null;
    }
    final stopwatch = Stopwatch()..start();
    final uri = _buildCdnUri(key, extension);
    final effectiveUri = kReleaseMode
        ? uri
        : Uri.parse(
            '${uri.toString()}${uri.hasQuery ? '&' : '?'}v=probe',
          );

    try {
      final response = await _client
          .get(effectiveUri)
          .timeout(_iconFetchTimeout, onTimeout: () {
        throw TimeoutException('Timed out fetching $effectiveUri');
      });
      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.bodyBytes);
        if (bytes.isEmpty) {
          return null;
        }
        CdnAnalytics.instance.recordResponse(
          bucket: 'icons/$extension',
          headers: response.headers,
          duration: stopwatch.elapsed,
        );
        final payload = extension == 'svg'
            ? ServiceIconPayload.svg(
                bytes,
                mimeType: response.headers['content-type'],
              )
            : ServiceIconPayload.raster(
                bytes,
                mimeType: response.headers['content-type'],
              );
        final elapsed = stopwatch.elapsed;

        ServiceIconCache.put(
          key,
          ServiceIconCacheEntry(
            payload: payload,
            originalSource: type,
            originPath: effectiveUri.toString(),
            loadedAt: DateTime.now(),
            loadDuration: elapsed,
          ),
        );

        return ServiceIconResolution(
          key: key,
          payload: payload,
          sourceType: type,
          originPath: effectiveUri.toString(),
          duration: elapsed,
        );
      }
    } on TimeoutException catch (error) {
      CdnAnalytics.instance
          .recordError(bucket: 'icons/$extension', error: error);
      if (kDebugMode) {
        debugPrint('[ServiceIcon] timeout fetching $effectiveUri: $error');
      }
    } catch (error) {
      CdnAnalytics.instance
          .recordError(bucket: 'icons/$extension', error: error);
      if (kDebugMode) {
        debugPrint('[ServiceIcon] failed fetching $effectiveUri: $error');
      }
    }
    return null;
  }

  static Future<ServiceIconResolution?> _loadAsset(
    String key, {
    required String extension,
    required ServiceIconSourceType type,
    String? assetKey,
  }) async {
    final stopwatch = Stopwatch()..start();
    final resolvedKey = assetKey ?? key;
    final assetPath = 'assets/service_icons/$resolvedKey.$extension';
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final payload = extension == 'svg'
          ? ServiceIconPayload.svg(bytes)
          : ServiceIconPayload.raster(bytes);
      final elapsed = stopwatch.elapsed;

      ServiceIconCache.put(
        key,
        ServiceIconCacheEntry(
          payload: payload,
          originalSource: type,
          originPath: assetPath,
          loadedAt: DateTime.now(),
          loadDuration: elapsed,
        ),
      );
      return ServiceIconResolution(
        key: key,
        payload: payload,
        sourceType: type,
        originPath: assetPath,
        duration: elapsed,
        cacheHit: false,
      );
    } on FlutterError {
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ServiceIcon] failed loading $assetPath: $error');
      }
      return null;
    }
  }
}

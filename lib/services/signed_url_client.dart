import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/environment_config.dart';

class SignedUrlClient {
  SignedUrlClient({
    SupabaseClient? client,
    String functionPath = 'sign-url',
  })  : _client = client ?? Supabase.instance.client,
        _functionPath = functionPath;

  final SupabaseClient _client;
  final String _functionPath;
  final Map<String, _SignedUrlEntry> _cache = {};

  Future<String> getSignedUrl(
    String objectPath, {
    int? ttlSeconds,
  }) async {
    final ttl = Duration(
      seconds: ttlSeconds ?? EnvironmentConfig.signedUrlTtlSeconds,
    );
    final entry = await _requestSignedUrl(objectPath, ttl);
    _cache[objectPath] = entry;
    return entry.url;
  }

  Future<String> ensureFresh(
    String objectPath,
    String currentUrl, {
    bool forceRefresh = false,
    int? ttlSeconds,
    Duration renewGrace = const Duration(seconds: 30),
  }) async {
    final cached = _cache[objectPath];
    if (!forceRefresh && cached != null) {
      if (!cached.isExpired &&
          !cached.isApproachingExpiry(renewGrace) &&
          cached.url == currentUrl) {
        return cached.url;
      }
    }

    try {
      return await getSignedUrl(objectPath, ttlSeconds: ttlSeconds);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SignedUrlClient] refresh failed: $error');
      }
      if (cached != null && !cached.isExpired) {
        return cached.url;
      }
      rethrow;
    }
  }

  void invalidate(String objectPath) {
    _cache.remove(objectPath);
  }

  void clear() => _cache.clear();

  Future<_SignedUrlEntry> _requestSignedUrl(
    String objectPath,
    Duration ttl,
  ) async {
    final response = await _client.functions.invoke(
      _functionPath,
      body: {
        'mode': 'path',
        'path': objectPath,
        'expiresIn': ttl.inSeconds,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final signedUrl = data['url'] as String?;
      if (signedUrl != null && signedUrl.isNotEmpty) {
        final expiresAt = _deriveExpiry(signedUrl, ttl);
        return _SignedUrlEntry(
          url: signedUrl,
          ttl: ttl,
          expiresAt: expiresAt,
        );
      }
    }
    throw StateError(
      'Edge function $_functionPath did not return a url field.',
    );
  }

  DateTime? _deriveExpiry(String url, Duration ttl) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return DateTime.now().add(ttl);
    }
    final exp = uri.queryParameters['exp'] ?? uri.queryParameters['expires'];
    if (exp != null) {
      final seconds = int.tryParse(exp);
      if (seconds != null) {
        // Supabase returns seconds since epoch.
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    return DateTime.now().add(ttl);
  }
}

class _SignedUrlEntry {
  _SignedUrlEntry({
    required this.url,
    required this.ttl,
    required this.expiresAt,
  });

  final String url;
  final Duration ttl;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool isApproachingExpiry(Duration threshold) {
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt!.subtract(threshold));
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/supabase_client_provider.dart';
import 'models.dart';

final socialLinkRepositoryProvider = Provider<SocialLinkRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SocialLinkRepository(client);
});

class SocialLinkRepository {
  SocialLinkRepository(this._client) : _functions = _client.functions;

  final SupabaseClient _client;
  final FunctionsClient _functions;

  Future<List<SocialAccount>> fetchLinkedAccounts() async {
    final payload = await _invoke(
      'user_social_accounts',
      method: HttpMethod.get,
    );
    final data = (payload as List<dynamic>? ?? const <dynamic>[]);
    return data
        .map((raw) => SocialAccount.fromJson(
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
            ))
        .toList();
  }

  Future<List<SocialLinkLog>> fetchLogs() async {
    final payload = await _invoke(
      'oauth/logs',
      method: HttpMethod.get,
    );
    final data = (payload as List<dynamic>? ?? const <dynamic>[]);
    return data
        .map((raw) => SocialLinkLog.fromJson(
              Map<String, dynamic>.from(raw as Map<String, dynamic>),
            ))
        .toList();
  }

  Future<void> connect(SocialProvider provider) async {
    final providerKey = _providerToKey(provider);
    try {
      await _invoke(
        'oauth/connect',
        method: HttpMethod.post,
        body: {
          'provider': providerKey,
          'redirect_to': _redirectUrl,
        },
      );
      _logMetric('oauth_connect_success++');
    } on SocialLinkApiException {
      _logMetric('oauth_connect_failure++');
      rethrow;
    }
  }

  Future<void> disconnect(SocialProvider provider) async {
    final providerKey = _providerToKey(provider);
    try {
      await _invoke(
        'oauth/disconnect/$providerKey',
        method: HttpMethod.delete,
      );
      _logMetric('oauth_disconnect_success++');
    } on SocialLinkApiException {
      _logMetric('oauth_disconnect_failure++');
      rethrow;
    }
  }

  Future<void> refreshTokens({SocialProvider? provider}) async {
    final body = {
      if (provider != null) 'provider': _providerToKey(provider),
    };
    try {
      await _invoke(
        'oauth/refresh',
        method: HttpMethod.post,
        body: body.isEmpty ? null : body,
      );
      _logMetric('oauth_refresh_success++');
    } on SocialLinkApiException {
      _logMetric('oauth_refresh_failure++');
      rethrow;
    }
  }

  String _providerToKey(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'google';
      case SocialProvider.instagram:
        return 'instagram';
      case SocialProvider.x:
        return 'x';
    }
  }

  Future<dynamic> _invoke(
    String path, {
    HttpMethod method = HttpMethod.get,
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _functions.invoke(
        path,
        method: method,
        body: body,
        queryParameters: query,
      );
      return response.data;
    } on FunctionException catch (error, stack) {
      throw SocialLinkApiException(
        statusCode: error.status,
        message: 'Failed to call $path (${error.status})',
        details: error.details,
        stackTrace: stack,
      );
    } on SocialLinkApiException {
      rethrow;
    } catch (error, stack) {
      throw SocialLinkApiException(
        statusCode: 500,
        message: 'Unexpected error while calling $path: $error',
        details: error,
        stackTrace: stack,
      );
    }
  }

  void _logMetric(String metric) {
    log('[metrics] $metric', name: 'social_link');
  }

  String get _redirectUrl {
    final uri = Uri.base;
    return Uri(
      scheme: uri.scheme.isEmpty ? 'https' : uri.scheme,
      host: uri.host.isEmpty ? 'localhost' : uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/settings/social-link',
    ).toString();
  }
}

class SocialLinkApiException implements Exception {
  const SocialLinkApiException({
    required this.statusCode,
    required this.message,
    this.details,
    this.stackTrace,
  });

  final int statusCode;
  final String message;
  final Object? details;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'SocialLinkApiException(statusCode: $statusCode, message: $message, details: $details)';
}

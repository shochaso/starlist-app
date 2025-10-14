import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/supabase_client_provider.dart';
import 'models.dart';

final importDiagnoseRepositoryProvider =
    Provider<ImportDiagnoseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ImportDiagnoseRepository(client);
});

final importDiagnoseProvider = FutureProvider.autoDispose
    .family<ImportDiagnoseState, String?>((ref, jobId) async {
  final repository = ref.watch(importDiagnoseRepositoryProvider);
  return repository.fetch(jobId: jobId);
});

class ImportDiagnoseRepository {
  ImportDiagnoseRepository(this._client) : _functions = _client.functions;

  final SupabaseClient _client;
  final FunctionsClient _functions;

  Future<ImportDiagnoseState> fetch({String? jobId}) async {
    if (jobId == null || jobId.isEmpty) {
      return ImportDiagnoseState.sample();
    }
    return fetchOcrResult(jobId);
  }

  Future<ImportDiagnoseState> fetchOcrResult(String fileId) async {
    try {
      final payload = await _invoke(
        'api/ocr',
        method: HttpMethod.get,
        queryParameters: {'file_id': fileId},
      );
      var state = _parseState(payload);
      state = await _maybeRefreshSignedUrl(state, payload);
      _logOcrMetrics(state.ocr);
      return state;
    } on ImportDiagnoseApiException {
      _logMetric('ocr_failure_total++');
      rethrow;
    } catch (error, stack) {
      _logMetric('ocr_failure_total++');
      log('fetchOcrResult failed', error: error, stackTrace: stack);
      throw ImportDiagnoseApiException(
        message: 'Failed to fetch OCR result',
        statusCode: 500,
        details: error,
        stackTrace: stack,
      );
    }
  }

  Future<ImportDiagnoseState> retryOcr(String fileId) async {
    final payload = await _invoke(
      'api/ocr',
      method: HttpMethod.post,
      body: {'file_id': fileId, 'action': 'retry'},
    );
    var state = _parseState(payload);
    state = await _maybeRefreshSignedUrl(state, payload);
    _logOcrMetrics(state.ocr, source: 'retry');
    return state;
  }

  Future<ImportDiagnoseState> retryEnrich(String fileId) async {
    final payload = await _invoke(
      'api/enrich',
      method: HttpMethod.post,
      body: {'file_id': fileId, 'action': 'retry'},
    );
    return _parseState(payload);
  }

  Future<String?> refreshSignedUrl(String resource) async {
    final payload = await _invoke(
      'media/refresh-signed-url',
      method: HttpMethod.post,
      body: {'resource': resource},
    );
    if (payload is Map<String, dynamic>) {
      return payload['signed_url'] as String? ?? payload['url'] as String?;
    }
    if (payload is String && payload.isNotEmpty) {
      return payload;
    }
    return null;
  }

  Future<dynamic> _invoke(
    String path, {
    HttpMethod method = HttpMethod.post,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _functions.invoke(
        path,
        method: method,
        body: body,
        queryParameters: queryParameters,
      );
      return response.data;
    } on FunctionException catch (error, stack) {
      throw ImportDiagnoseApiException(
        statusCode: error.status,
        message: 'Edge Function call failed ($path)',
        details: error.details,
        stackTrace: stack,
      );
    }
  }

  ImportDiagnoseState _parseState(dynamic payload) {
    if (payload == null) {
      return ImportDiagnoseState.empty();
    }
    if (payload is Map<String, dynamic>) {
      return ImportDiagnoseState.fromJson(payload);
    }
    if (payload is Map) {
      return ImportDiagnoseState.fromJson(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    if (payload is List && payload.isNotEmpty) {
      final first = payload.first;
      if (first is Map<String, dynamic>) {
        return ImportDiagnoseState.fromJson(first);
      }
      if (first is Map) {
        return ImportDiagnoseState.fromJson(
          first.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }
    throw const ImportDiagnoseApiException(
      statusCode: 500,
      message: 'Unexpected payload from import diagnose endpoint',
    );
  }

  Future<ImportDiagnoseState> _maybeRefreshSignedUrl(
    ImportDiagnoseState state,
    dynamic payload,
  ) async {
    final needsRefresh = state.ocr.imageUrl.isEmpty ||
        state.alertMessage?.contains('expired') == true ||
        _payloadFlagTrue(payload, 'signed_url_expired');
    if (!needsRefresh) {
      return state;
    }
    final resource = _extractStorageResource(payload);
    if (resource == null) {
      return state;
    }
    final refreshed = await refreshSignedUrl(resource);
    if (refreshed == null || refreshed.isEmpty) {
      return state;
    }
    return state.copyWith(
      ocr: state.ocr.copyWith(imageUrl: refreshed),
    );
  }

  bool _payloadFlagTrue(dynamic payload, String key) {
    if (payload is Map && payload.containsKey(key)) {
      final value = payload[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
    }
    return false;
  }

  String? _extractStorageResource(dynamic payload) {
    if (payload is Map) {
      if (payload['storage_path'] is String) {
        return payload['storage_path'] as String;
      }
      if (payload['path'] is String) {
        return payload['path'] as String;
      }
      if (payload['resource'] is String) {
        return payload['resource'] as String;
      }
      if (payload['ocr'] is Map) {
        return _extractStorageResource(payload['ocr']);
      }
    }
    if (payload is List && payload.isNotEmpty) {
      return _extractStorageResource(payload.first);
    }
    return null;
  }

  void _logOcrMetrics(OcrResult ocr, {String source = 'fetch'}) {
    if (ocr.confidence >= 0.6) {
      _logMetric('ocr_success_total++');
    } else {
      _logMetric('ocr_low_conf_total++');
    }
    log(
      '[metrics] ocr_confidence_source:$source value:${ocr.confidence.toStringAsFixed(2)}',
      name: 'import_diagnose',
    );
  }

  void _logMetric(String metric) {
    log('[metrics] $metric', name: 'import_diagnose');
  }
}

class ImportDiagnoseApiException implements Exception {
  const ImportDiagnoseApiException({
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
      'ImportDiagnoseApiException(statusCode: $statusCode, message: $message, details: $details)';
}

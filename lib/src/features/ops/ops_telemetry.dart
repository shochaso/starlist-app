// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/ops_telemetry.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/environment_config.dart';

/// OPS Telemetry client for sending operational metrics to Edge Functions
class OpsTelemetry {
  final String baseUrl;
  final String app;
  final String env;

  OpsTelemetry({
    required this.baseUrl,
    required this.app,
    required this.env,
  });

  /// Factory constructor for production environment
  factory OpsTelemetry.prod() {
    final supabaseUrl = EnvironmentConfig.supabaseUrl;
    // Edge Functions URL format: {supabaseUrl}/functions/v1/{functionName}
    final baseUrl = '$supabaseUrl/functions/v1';
    return OpsTelemetry(
      baseUrl: baseUrl,
      app: 'starlist',
      env: 'prod',
    );
  }

  /// Factory constructor for staging environment
  factory OpsTelemetry.staging() {
    final supabaseUrl = EnvironmentConfig.supabaseUrl;
    final baseUrl = '$supabaseUrl/functions/v1';
    return OpsTelemetry(
      baseUrl: baseUrl,
      app: 'starlist',
      env: 'stg',
    );
  }

  /// Factory constructor for development environment
  factory OpsTelemetry.dev() {
    final supabaseUrl = EnvironmentConfig.supabaseUrl;
    final baseUrl = '$supabaseUrl/functions/v1';
    return OpsTelemetry(
      baseUrl: baseUrl,
      app: 'starlist',
      env: 'dev',
    );
  }

  /// Send telemetry event to Edge Function
  Future<bool> send({
    required String event,
    required bool ok,
    int? latencyMs,
    String? errCode,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/telemetry');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvironmentConfig.supabaseAnonKey}',
        },
        body: jsonEncode({
          'app': app,
          'env': env,
          'event': event,
          'ok': ok,
          'latency_ms': latencyMs,
          'err_code': errCode,
          'extra': extra,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      // エラー時はログに記録するが、アプリの動作は継続
      print('[OpsTelemetry] Send failed: $e');
      return false;
    }
  }
}


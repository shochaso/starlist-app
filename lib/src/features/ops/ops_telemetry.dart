import 'dart:convert';

import 'package:http/http.dart' as http;

class OpsTelemetry {
  final String baseUrl;
  final String app;
  final String env;

  OpsTelemetry({
    required this.baseUrl,
    required this.app,
    required this.env,
  });

  Future<bool> send({
    required String event,
    required bool ok,
    int? latencyMs,
    String? errCode,
    Map<String, dynamic>? extra,
  }) async {
    final uri = Uri.parse('$baseUrl/telemetry');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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
    return res.statusCode == 201;
  }
}

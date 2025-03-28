import "dart:convert";
import "package:http/http.dart" as http;

class ApiSecurityService {
  static const String _apiKeyHeader = "X-API-Key";
  static const String _authHeader = "Authorization";
  static const String _timestampHeader = "X-Timestamp";
  static const String _signatureHeader = "X-Signature";

  final String _apiKey;
  final String _apiSecret;

  ApiSecurityService(this._apiKey, this._apiSecret);

  Map<String, String> getSecurityHeaders() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateSignature(timestamp);

    return {
      _apiKeyHeader: _apiKey,
      _timestampHeader: timestamp,
      _signatureHeader: signature,
    };
  }

  Map<String, String> getAuthHeaders(String token) {
    final headers = getSecurityHeaders();
    headers[_authHeader] = "Bearer $token";
    return headers;
  }

  String _generateSignature(String timestamp) {
    final data = "$_apiKey:$timestamp";
    final key = utf8.encode(_apiSecret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  bool validateSignature(String signature, String timestamp) {
    final expectedSignature = _generateSignature(timestamp);
    return signature == expectedSignature;
  }

  bool validateTimestamp(String timestamp) {
    final requestTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();
    return now.difference(requestTime).inMinutes < 5;
  }
}

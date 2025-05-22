import "dart:convert";
import "package:http/http.dart" as http;
import "package:starlist/src/core/config/firebase_config.dart";

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({required this.baseUrl}) : _client = http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        if (_authToken != null) "Authorization": "Bearer $_authToken",
      };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse("$baseUrl$path"),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse("$baseUrl$path"),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse("$baseUrl$path"),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client.delete(
      Uri.parse("$baseUrl$path"),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: ${response.statusCode} - ${response.body}");
    }
  }
}

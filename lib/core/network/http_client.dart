import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HttpX {
  static http.Client create() {
    if (kIsWeb) {
      return BrowserClient()..withCredentials = true; // send cookies from web
    }
    return http.Client();
  }
}

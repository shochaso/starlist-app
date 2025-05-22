import "package:http/http.dart" as http;

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  AppError(this.message, {this.code, this.details, this.stackTrace});

  @override
  String toString() => "AppError: $message${code != null ? " (Code: $code)" : ""}";
}

class NetworkError extends AppError {
  NetworkError(String message, {String? code, dynamic details, StackTrace? stackTrace})
      : super(message, code: code, details: details, stackTrace: stackTrace);
}

class ApiError extends AppError {
  final int statusCode;
  final String? responseBody;

  ApiError(String message, this.statusCode, {String? code, dynamic details, this.responseBody, StackTrace? stackTrace})
      : super(message, code: code, details: details, stackTrace: stackTrace);

  factory ApiError.fromResponse(http.Response response) {
    try {
      final body = response.body;
      return ApiError(
        "API Error: ${response.statusCode}",
        response.statusCode,
        responseBody: body,
      );
    } catch (e) {
      return ApiError(
        "Failed to parse API error response",
        response.statusCode,
      );
    }
  }
}

class ValidationError extends AppError {
  ValidationError(String message, {String? code, dynamic details, StackTrace? stackTrace})
      : super(message, code: code, details: details, stackTrace: stackTrace);
}

class AuthError extends AppError {
  AuthError(String message, {String? code, dynamic details, StackTrace? stackTrace})
      : super(message, code: code, details: details, stackTrace: stackTrace);
}

class CacheError extends AppError {
  CacheError(String message, {String? code, dynamic details, StackTrace? stackTrace})
      : super(message, code: code, details: details, stackTrace: stackTrace);
}

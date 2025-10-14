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
  NetworkError(super.message, {super.code, super.details, super.stackTrace});
}

class ApiError extends AppError {
  final int statusCode;
  final String? responseBody;

  ApiError(super.message, this.statusCode, {super.code, super.details, this.responseBody, super.stackTrace});

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
  ValidationError(super.message, {super.code, super.details, super.stackTrace});
}

class AuthError extends AppError {
  AuthError(super.message, {super.code, super.details, super.stackTrace});
}

class CacheError extends AppError {
  CacheError(super.message, {super.code, super.details, super.stackTrace});
}

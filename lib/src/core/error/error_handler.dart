import "dart:async";

import "package:http/http.dart" as http;
import "app_error.dart";

class ErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is http.ClientException) {
      return NetworkError(
        "Network error: ${error.message}",
        code: "NETWORK_ERROR",
        stackTrace: StackTrace.current,
      );
    }

    if (error is FormatException) {
      return ValidationError(
        "Invalid data format: ${error.message}",
        code: "FORMAT_ERROR",
        stackTrace: StackTrace.current,
      );
    }

    return AppError(
      "Unexpected error: ${error.toString()}",
      code: "UNKNOWN_ERROR",
      stackTrace: error is Error ? error.stackTrace : null,
    );
  }

  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      attempts++;
      try {
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
    throw AppError("Max retry attempts reached");
  }

  static Future<T> withTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw NetworkError(
        "Operation timed out",
        code: "TIMEOUT_ERROR",
        stackTrace: StackTrace.current,
      );
    }
  }
}

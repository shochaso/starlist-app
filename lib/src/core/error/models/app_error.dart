
class AppError {
  final String message;
  final String? code;
  final dynamic details;

  AppError({
    required this.message,
    this.code,
    this.details,
  });

  factory AppError.fromException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }
    return AppError(
      message: exception.toString(),
      details: exception,
    );
  }
}

class ErrorMessage {
  static String getMessage(AppError error) {
    return error.message;
  }

  static String getCode(AppError error) {
    return error.code ?? "UNKNOWN_ERROR";
  }
}

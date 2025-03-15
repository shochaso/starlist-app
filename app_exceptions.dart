/// アプリケーション全体で使用する例外クラスの基底クラス
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// ネットワーク関連の例外
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// API関連の例外
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(String message, {this.statusCode, String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'ApiException: $message (code: $code, statusCode: $statusCode)';
}

/// 認証関連の例外
class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// データベース関連の例外
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 入力検証関連の例外
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(String message, {this.fieldErrors, String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return 'ValidationException: $message (code: $code, fieldErrors: $fieldErrors)';
    }
    return 'ValidationException: $message (code: $code)';
  }
}

/// 権限関連の例外
class PermissionException extends AppException {
  const PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// リソースが見つからない例外
class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// サーバー関連の例外
class ServerException extends AppException {
  const ServerException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// キャッシュ関連の例外
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 予期せぬ例外
class UnexpectedException extends AppException {
  const UnexpectedException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// タイムアウト例外
class TimeoutException extends AppException {
  const TimeoutException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 支払い関連の例外
class PaymentException extends AppException {
  const PaymentException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

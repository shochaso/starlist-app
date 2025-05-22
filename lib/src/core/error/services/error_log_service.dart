import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:starlist/src/core/error/app_error.dart";

class ErrorLogService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> logError(AppError error, {StackTrace? stackTrace}) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: error.message,
      information: [
        "Error Code: ${error.code ?? "N/A"}",
        "Error Type: ${error.runtimeType}",
        if (error.originalError != null)
          "Original Error: ${error.originalError.toString()}",
      ],
    );
  }

  Future<void> logNonFatalError(AppError error, {StackTrace? stackTrace}) async {
    await _crashlytics.recordNonFatalError(
      error,
      stackTrace,
      reason: error.message,
      information: [
        "Error Code: ${error.code ?? "N/A"}",
        "Error Type: ${error.runtimeType}",
        if (error.originalError != null)
          "Original Error: ${error.originalError.toString()}",
      ],
    );
  }

  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterError(details);
  }

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterFatalError(details);
  }
}

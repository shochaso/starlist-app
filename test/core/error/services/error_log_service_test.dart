@Skip('legacy error log service tests; pending migration')
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/core/error/app_error.dart";
import "package:starlist_app/src/core/error/services/error_log_service.dart";

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late ErrorLogService errorLogService;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    errorLogService = ErrorLogService();
  });

  group("ErrorLogService", () {
    test("logError", () async {
      final error = AuthError("Test error", code: "test_code");
      final stackTrace = StackTrace.current;

      await errorLogService.logError(error, stackTrace: stackTrace);

      verify(mockCrashlytics.recordError(
        error,
        stackTrace,
        reason: error.message,
        information: anyNamed("information"),
      )).called(1);
    });

    test("logNonFatalError", () async {
      final error = NetworkError("Test error", code: "test_code");
      final stackTrace = StackTrace.current;

      await errorLogService.logNonFatalError(error, stackTrace: stackTrace);

      verify(mockCrashlytics.recordNonFatalError(
        error,
        stackTrace,
        reason: error.message,
        information: anyNamed("information"),
      )).called(1);
    });

    test("setUserIdentifier", () async {
      const userId = "test_user_id";

      await errorLogService.setUserIdentifier(userId);

      verify(mockCrashlytics.setUserIdentifier(userId)).called(1);
    });

    test("setCustomKey", () async {
      const key = "test_key";
      const value = "test_value";

      await errorLogService.setCustomKey(key, value);

      verify(mockCrashlytics.setCustomKey(key, value)).called(1);
    });

    test("recordFlutterError", () async {
      final details = FlutterErrorDetails(
        exception: Exception("Test error"),
        stack: StackTrace.current,
      );

      await errorLogService.recordFlutterError(details);

      verify(mockCrashlytics.recordFlutterError(details)).called(1);
    });

    test("recordFlutterFatalError", () async {
      final details = FlutterErrorDetails(
        exception: Exception("Test error"),
        stack: StackTrace.current,
      );

      await errorLogService.recordFlutterFatalError(details);

      verify(mockCrashlytics.recordFlutterFatalError(details)).called(1);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:starlist_app/src/core/error/app_error.dart';
import 'package:starlist_app/src/core/error/error_handler.dart';

dynamic _wrapError(dynamic error) => ErrorHandler.handleError(error);

void main() {
  group('ErrorHandler.handleError', () {
    test('returns AppError as-is', () {
      final appError = AppError('already handled', code: 'KNOWN');
      final result = _wrapError(appError);
      expect(identical(result, appError), isTrue);
    });

    test('wraps ClientException as NetworkError', () {
      final clientException = http.ClientException('socket closed');
      final result = _wrapError(clientException);
      expect(result, isA<NetworkError>());
      expect(result.message, contains('socket closed'));
      expect(result.code, 'NETWORK_ERROR');
    });

    test('wraps FormatException as ValidationError', () {
      const formatException = FormatException('bad JSON');
      final result = _wrapError(formatException);
      expect(result, isA<ValidationError>());
      expect(result.message, contains('bad JSON'));
      expect(result.code, 'FORMAT_ERROR');
    });

    test('wraps unknown error as AppError', () {
      final error = StateError('something unexpected');
      final result = _wrapError(error);
      expect(result, isA<AppError>());
      expect(result.message, contains('Unexpected error'));
    });
  });

  group('ErrorHandler.withRetry', () {
    test('retries operation until success', () async {
      var attempts = 0;
      final result = await ErrorHandler.withRetry(
        operation: () async {
          attempts++;
          if (attempts < 3) throw Exception('fail');
          return 'ok';
        },
        maxAttempts: 3,
        delay: const Duration(milliseconds: 10),
      );

      expect(result, 'ok');
      expect(attempts, 3);
    });

    test('rethrows after reaching maxAttempts', () async {
      var attempts = 0;

      try {
        await ErrorHandler.withRetry(
          operation: () async {
            attempts++;
            throw Exception('still failing');
          },
          maxAttempts: 2,
          delay: const Duration(milliseconds: 10),
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }

      expect(attempts, 2);
    });
  });

  group('ErrorHandler.withTimeout', () {
    test('returns result before timeout', () async {
      final value = await ErrorHandler.withTimeout(
        operation: () async {
          await Future.delayed(const Duration(milliseconds: 20));
          return 42;
        },
        timeout: const Duration(milliseconds: 200),
      );

      expect(value, 42);
    });

    test('throws NetworkError on timeout', () async {
      expect(
        () => ErrorHandler.withTimeout(
          operation: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return 'never';
          },
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}

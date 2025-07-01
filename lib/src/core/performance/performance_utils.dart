import "dart:async";
import "package:flutter/foundation.dart";

class PerformanceUtils {
  static Future<T> measureOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    required Function(String, int) onComplete,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      onComplete(operationName, stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      stopwatch.stop();
      onComplete(operationName, stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }

  static void debounce(VoidCallback callback, {Duration duration = const Duration(milliseconds: 300)}) {
    Timer? debounceTimer;
    if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
    debounceTimer = Timer(duration, callback);
  }

  static Future<T> throttle<T>({
    required Future<T> Function() operation,
    required String key,
    required Duration duration,
  }) async {
    final now = DateTime.now();
    final lastExecution = _lastExecutionTime[key];

    if (lastExecution != null &&
        now.difference(lastExecution) < duration) {
      return _lastResult[key] as T;
    }

    _lastExecutionTime[key] = now;
    final result = await operation();
    _lastResult[key] = result;
    return result;
  }

  static final Map<String, DateTime> _lastExecutionTime = {};
  static final Map<String, dynamic> _lastResult = {};

  static void clearThrottleCache() {
    _lastExecutionTime.clear();
    _lastResult.clear();
  }

  static Future<List<T>> batchProcess<T>({
    required List<T> items,
    required Future<void> Function(T) processItem,
    int batchSize = 10,
  }) async {
    final results = <T>[];
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(processItem));
      results.addAll(batch);
    }
    return results;
  }

  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    var attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(delay * attempts);
      }
    }
    throw Exception("Max retry attempts reached");
  }

  static Future<T> withTimeout<T>({
    required Future<T> Function() operation,
    required Duration timeout,
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw Exception("Operation timed out after ${timeout.inSeconds} seconds");
    }
  }
}

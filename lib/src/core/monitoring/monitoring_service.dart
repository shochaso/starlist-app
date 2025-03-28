import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_performance/firebase_performance.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _performance.setPerformanceCollectionEnabled(true);
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
  }

  Future<void> stopTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.stop();
  }

  Future<void> addMetric(String traceName, String metricName, int value) async {
    final trace = _performance.newTrace(traceName);
    trace.setMetric(metricName, value);
  }

  Future<void> recordError(dynamic error, StackTrace? stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  Future<void> logNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required int duration,
  }) async {
    final trace = _performance.newHttpMetric(url, HttpMethod.values.firstWhere(
      (e) => e.toString() == "HttpMethod.$method",
      orElse: () => HttpMethod.Get,
    ));

    await trace.start();
    trace.httpResponseCode = statusCode;
    trace.responseContentType = "application/json";
    await trace.stop();
  }
}

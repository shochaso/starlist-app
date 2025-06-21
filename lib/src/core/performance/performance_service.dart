import "package:firebase_performance/firebase_performance.dart";

class PerformanceService {
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeMetrics = {};

  Future<void> startTrace(String traceName) async {
    if (_activeTraces.containsKey(traceName)) return;

    final trace = await _performance.newTrace(traceName);
    await trace.start();
    _activeTraces[traceName] = trace;
  }

  Future<void> stopTrace(String traceName) async {
    final trace = _activeTraces.remove(traceName);
    if (trace != null) {
      await trace.stop();
    }
  }

  Future<void> startHttpMetric(String url, HttpMethod method) async {
    if (_activeMetrics.containsKey(url)) return;

    final metric = _performance.newHttpMetric(url, method);
    await metric.start();
    _activeMetrics[url] = metric;
  }

  Future<void> stopHttpMetric(String url, int responseCode, int responseSize) async {
    final metric = _activeMetrics.remove(url);
    if (metric != null) {
      metric
        ..httpResponseCode = responseCode
        ..responseContentType = "application/json"
        ..responsePayloadSize = responseSize;
      await metric.stop();
    }
  }

  void addAttribute(String traceName, String attributeName, String value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.setAttribute(attributeName, value);
    }
  }

  void incrementMetric(String traceName, String metricName, int value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.setMetric(metricName, value);
    }
  }

  Future<void> recordScreenLoad(String screenName) async {
    final trace = await _performance.newTrace("screen_load_$screenName");
    await trace.start();
    await trace.stop();
  }

  Future<void> recordApiCall(String endpoint, int duration, bool success) async {
    final trace = await _performance.newTrace("api_call_$endpoint");
    await trace.start();
    trace.setAttribute("success", success.toString());
    trace.setMetric("duration", duration);
    await trace.stop();
  }

  Future<void> recordDatabaseOperation(String operation, int duration) async {
    final trace = await _performance.newTrace("db_operation_$operation");
    await trace.start();
    trace.setMetric("duration", duration);
    await trace.stop();
  }

  Future<void> recordCacheOperation(String operation, int duration, bool hit) async {
    final trace = await _performance.newTrace("cache_operation_$operation");
    await trace.start();
    trace.setAttribute("hit", hit.toString());
    trace.setMetric("duration", duration);
    await trace.stop();
  }
}

// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/models/ops_metrics_series_model.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

// Sentinel value for copyWith to distinguish between null and undefined
const _undefined = Object();

/// Time series data point from v_ops_5min view
class OpsMetricsSeriesPoint {
  final DateTime bucketStart;
  final String env;
  final String app;
  final String event;
  final int total;
  final double failureRate;
  final int? p95LatencyMs;

  OpsMetricsSeriesPoint({
    required this.bucketStart,
    required this.env,
    required this.app,
    required this.event,
    required this.total,
    required this.failureRate,
    this.p95LatencyMs,
  });

  factory OpsMetricsSeriesPoint.fromJson(Map<String, dynamic> json) {
    return OpsMetricsSeriesPoint(
      bucketStart: DateTime.parse(json['bucket_5m'] as String).toLocal(),
      env: json['env'] as String? ?? '',
      app: json['app'] as String? ?? '',
      event: json['event'] as String? ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      failureRate: (json['failure_rate'] as num?)?.toDouble() ?? 0.0,
      p95LatencyMs: (json['p95_latency_ms'] as num?)?.toInt(),
    );
  }

  int get successCount => total - errorCount;
  int get errorCount => (total * failureRate).round();
}

/// Filter parameters for OPS metrics queries
class OpsMetricsFilter {
  final String? env;
  final String? app;
  final String? eventType;
  final int sinceMinutes;

  const OpsMetricsFilter({
    this.env,
    this.app,
    this.eventType,
    this.sinceMinutes = 30,
  });

  OpsMetricsFilter copyWith({
    Object? env = _undefined,
    Object? app = _undefined,
    Object? eventType = _undefined,
    int? sinceMinutes,
  }) {
    return OpsMetricsFilter(
      env: env == _undefined ? this.env : env as String?,
      app: app == _undefined ? this.app : app as String?,
      eventType: eventType == _undefined ? this.eventType : eventType as String?,
      sinceMinutes: sinceMinutes ?? this.sinceMinutes,
    );
  }
}

/// Aggregated KPI metrics for the selected period
class OpsMetricsKpi {
  final int totalRequests;
  final int errorCount;
  final double errorRate;
  final int? p95LatencyMs;

  OpsMetricsKpi({
    required this.totalRequests,
    required this.errorCount,
    required this.errorRate,
    this.p95LatencyMs,
  });

  factory OpsMetricsKpi.fromSeries(List<OpsMetricsSeriesPoint> series) {
    final total = series.fold<int>(0, (sum, point) => sum + point.total);
    final errors = series.fold<int>(0, (sum, point) => sum + point.errorCount);
    final errorRate = total > 0 ? (errors / total) : 0.0;
    
    final latencies = series
        .map((p) => p.p95LatencyMs)
        .whereType<int>()
        .toList();
    final p95 = latencies.isNotEmpty
        ? latencies.reduce((a, b) => a > b ? a : b) // Max of p95 values
        : null;

    return OpsMetricsKpi(
      totalRequests: total,
      errorCount: errors,
      errorRate: errorRate,
      p95LatencyMs: p95,
    );
  }
}



import 'package:intl/intl.dart';

/// Represents an aggregated ops metric row coming from `v_ops_5min`.
class OpsMetric {
  final DateTime bucketStart;
  final String env;
  final String app;
  final String eventType;
  final int successCount;
  final int errorCount;
  final int? p95Ms;

  const OpsMetric({
    required this.bucketStart,
    required this.env,
    required this.app,
    required this.eventType,
    required this.successCount,
    required this.errorCount,
    required this.p95Ms,
  });

  factory OpsMetric.fromMap(Map<String, dynamic> map) {
    final bucket = map['bucket_start'];
    DateTime parsedBucket;
    if (bucket is DateTime) {
      parsedBucket = bucket.toUtc();
    } else if (bucket is String) {
      parsedBucket = DateTime.parse(bucket).toUtc();
    } else {
      throw ArgumentError('bucket_start is required');
    }

    return OpsMetric(
      bucketStart: parsedBucket,
      env: (map['env'] as String?) ?? 'unknown',
      app: (map['app'] as String?) ?? 'unknown',
      eventType: (map['event_type'] as String?) ?? 'unknown',
      successCount: (map['success_count'] as num?)?.toInt() ?? 0,
      errorCount: (map['error_count'] as num?)?.toInt() ?? 0,
      p95Ms: (map['p95_ms'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bucket_start': bucketStart.toIso8601String(),
      'env': env,
      'app': app,
      'event_type': eventType,
      'success_count': successCount,
      'error_count': errorCount,
      'p95_ms': p95Ms,
    };
  }

  int get total => successCount + errorCount;

  double get errorRate => total == 0 ? 0 : errorCount / total;

  /// Supabase returns UTC; convert to JST for display.
  DateTime get bucketStartJst => bucketStart.toUtc().add(const Duration(hours: 9));

  /// Convenience label for 5-minute buckets (HH:mm JST).
  String get jstAxisLabel => DateFormat('HH:mm', 'ja_JP').format(bucketStartJst);

  String formatJst(String pattern) => DateFormat(pattern, 'ja_JP').format(bucketStartJst);
}

class OpsKpiSummary {
  final int total;
  final int successCount;
  final int errorCount;
  final double errorRate;
  final int? latestP95Ms;

  const OpsKpiSummary({
    required this.total,
    required this.successCount,
    required this.errorCount,
    required this.errorRate,
    required this.latestP95Ms,
  });

  factory OpsKpiSummary.fromMetrics(
    List<OpsMetric> metrics, {
    Duration window = const Duration(minutes: 30),
  }) {
    if (metrics.isEmpty) {
      return const OpsKpiSummary.empty();
    }

    final cutoff = DateTime.now().toUtc().subtract(window);
    final recent = metrics.where((m) => !m.bucketStart.isBefore(cutoff)).toList();
    final source = recent.isNotEmpty ? recent : metrics;
    final totalSuccess = source.fold<int>(0, (sum, m) => sum + m.successCount);
    final totalError = source.fold<int>(0, (sum, m) => sum + m.errorCount);
    final total = totalSuccess + totalError;
    final errorRate = total == 0 ? 0 : totalError / total;
    final latestWithP95 = source.lastWhere(
      (m) => m.p95Ms != null,
      orElse: () => source.last,
    );

    return OpsKpiSummary(
      total: total,
      successCount: totalSuccess,
      errorCount: totalError,
      errorRate: errorRate,
      latestP95Ms: latestWithP95.p95Ms,
    );
  }

  const OpsKpiSummary.empty()
      : total = 0,
        successCount = 0,
        errorCount = 0,
        errorRate = 0,
        latestP95Ms = null;
}

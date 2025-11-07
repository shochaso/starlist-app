// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/models/ops_health_model.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

/// Health aggregation data from ops-health Edge Function
class OpsHealthAggregation {
  final String? app;
  final String? env;
  final String? event;
  final double uptimePercent;
  final int? meanP95Ms;
  final int alertCount;
  final String alertTrend; // 'increasing', 'decreasing', 'stable'

  OpsHealthAggregation({
    this.app,
    this.env,
    this.event,
    required this.uptimePercent,
    this.meanP95Ms,
    required this.alertCount,
    required this.alertTrend,
  });

  factory OpsHealthAggregation.fromJson(Map<String, dynamic> json) {
    return OpsHealthAggregation(
      app: json['app'] as String?,
      env: json['env'] as String?,
      event: json['event'] as String?,
      uptimePercent: (json['uptime_percent'] as num).toDouble(),
      meanP95Ms: json['mean_p95_ms'] != null ? (json['mean_p95_ms'] as num).toInt() : null,
      alertCount: json['alert_count'] as int,
      alertTrend: json['alert_trend'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app,
      'env': env,
      'event': event,
      'uptime_percent': uptimePercent,
      'mean_p95_ms': meanP95Ms,
      'alert_count': alertCount,
      'alert_trend': alertTrend,
    };
  }
}

/// Health data from ops-health Edge Function
class OpsHealthData {
  final String period;
  final List<OpsHealthAggregation> aggregations;

  OpsHealthData({
    required this.period,
    required this.aggregations,
  });

  factory OpsHealthData.fromJson(Map<String, dynamic> json) {
    return OpsHealthData(
      period: json['period'] as String,
      aggregations: (json['aggregations'] as List<dynamic>?)
          ?.map((item) => OpsHealthAggregation.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  factory OpsHealthData.empty() {
    return OpsHealthData(
      period: '24h',
      aggregations: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'aggregations': aggregations.map((a) => a.toJson()).toList(),
    };
  }
}


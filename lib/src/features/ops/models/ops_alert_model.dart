// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/models/ops_alert_model.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

/// Alert information from ops-alert Edge Function
class OpsAlert {
  final String type; // 'failure_rate' or 'p95_latency'
  final String message;
  final double value;
  final double threshold;
  final DateTime alertedAt;

  OpsAlert({
    required this.type,
    required this.message,
    required this.value,
    required this.threshold,
    required this.alertedAt,
  });

  factory OpsAlert.fromJson(Map<String, dynamic> json) {
    return OpsAlert(
      type: json['type'] as String,
      message: json['message'] as String,
      value: (json['value'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      alertedAt: json['alerted_at'] != null
          ? DateTime.parse(json['alerted_at'] as String).toLocal()
          : DateTime.now().toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'value': value,
      'threshold': threshold,
      'alerted_at': alertedAt.toUtc().toIso8601String(),
    };
  }
}


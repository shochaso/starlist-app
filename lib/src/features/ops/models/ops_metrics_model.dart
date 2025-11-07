// Status:: in-progress
// Source-of-Truth:: lib/src/features/ops/models/ops_metrics_model.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

/// OPS Metrics data model
class OpsMetrics {
  final double signInSuccessRate;
  final double reauthSuccessRate;
  final int authFailures24h;
  final int rlsDenials24h;
  final double rlsDenialRate;
  final int priceSetEvents24h;
  final int priceDeniedEvents24h;
  final double priceDeniedRate;
  final int searchSlaMissed1h;
  final int avgResponseTimeMs;

  OpsMetrics({
    required this.signInSuccessRate,
    required this.reauthSuccessRate,
    required this.authFailures24h,
    required this.rlsDenials24h,
    required this.rlsDenialRate,
    required this.priceSetEvents24h,
    required this.priceDeniedEvents24h,
    required this.priceDeniedRate,
    required this.searchSlaMissed1h,
    required this.avgResponseTimeMs,
  });

  /// Empty metrics (default values)
  factory OpsMetrics.empty() {
    return OpsMetrics(
      signInSuccessRate: 100.0,
      reauthSuccessRate: 100.0,
      authFailures24h: 0,
      rlsDenials24h: 0,
      rlsDenialRate: 0.0,
      priceSetEvents24h: 0,
      priceDeniedEvents24h: 0,
      priceDeniedRate: 0.0,
      searchSlaMissed1h: 0,
      avgResponseTimeMs: 0,
    );
  }
}


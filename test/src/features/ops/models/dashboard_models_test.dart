import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/models/dashboard_models.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  test('OpsMetric view helpers compute success/error', () {
    final point = OpsMetricsSeriesPoint(
      bucketStart: DateTime.parse('2025-01-01T00:00:00Z'),
      env: 'prod',
      app: 'app',
      event: 'event',
      total: 100,
      failureRate: 0.1,
    );
    expect(point.successCount, 90);
    expect(point.errorCount, 10);
    expect(point.jstAxisLabel, contains(''));
  });

  test('OpsKpiSummary sums metrics', () {
    final metrics = [
      OpsMetricsSeriesPoint(
        bucketStart: DateTime.now(),
        env: 'prod',
        app: 'app',
        event: 'event',
        total: 100,
        failureRate: 0.1,
      ),
    ];
    final summary = OpsKpiSummary.fromMetrics(metrics);
    expect(summary.total, 100);
    expect(summary.errorCount, 10);
  });
}

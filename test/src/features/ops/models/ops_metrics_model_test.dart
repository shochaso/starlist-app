import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_model.dart';

void main() {
  group('OpsMetric', () {
    test('errorRate is zero-safe when total == 0', () {
      final metric = OpsMetric(
        bucketStart: DateTime.now().toUtc(),
        env: 'prod',
        app: 'flutter_web',
        eventType: 'search',
        successCount: 0,
        errorCount: 0,
        p95Ms: 120,
      );

      expect(metric.errorRate, 0);
    });

    test('jstAxisLabel converts UTC to JST HH:mm', () {
      final metric = OpsMetric(
        bucketStart: DateTime.utc(2024, 1, 1, 0, 0),
        env: 'prod',
        app: 'web',
        eventType: 'search',
        successCount: 1,
        errorCount: 0,
        p95Ms: 100,
      );

      expect(metric.jstAxisLabel, '09:00');
    });
  });

  group('OpsKpiSummary', () {
    test('aggregates success, error, and p95 from metrics', () {
      final now = DateTime.now().toUtc();
      final metrics = [
        OpsMetric(
          bucketStart: now.subtract(const Duration(minutes: 10)),
          env: 'prod',
          app: 'flutter_web',
          eventType: 'import',
          successCount: 90,
          errorCount: 10,
          p95Ms: 200,
        ),
        OpsMetric(
          bucketStart: now.subtract(const Duration(minutes: 5)),
          env: 'prod',
          app: 'flutter_web',
          eventType: 'import',
          successCount: 45,
          errorCount: 5,
          p95Ms: 150,
        ),
      ];

      final summary = OpsKpiSummary.fromMetrics(metrics);

      expect(summary.total, 150);
      expect(summary.successCount, 135);
      expect(summary.errorCount, 15);
      expect(summary.errorRate, closeTo(0.1, 0.0001));
      expect(summary.latestP95Ms, 150);
    });

    test('p95 remains null when all source values missing', () {
      final now = DateTime.now().toUtc();
      final metrics = [
        OpsMetric(
          bucketStart: now.subtract(const Duration(minutes: 10)),
          env: 'prod',
          app: 'flutter_web',
          eventType: 'import',
          successCount: 90,
          errorCount: 10,
          p95Ms: null,
        ),
      ];

      final summary = OpsKpiSummary.fromMetrics(metrics);

      expect(summary.latestP95Ms, isNull);
    });
  });
}

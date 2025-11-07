import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  group('OpsMetricsSeriesPoint', () {
    test('errorCount and successCount are calculated correctly', () {
      final point = OpsMetricsSeriesPoint(
        bucketStart: DateTime.now(),
        env: 'prod',
        app: 'flutter_web',
        event: 'search',
        total: 100,
        failureRate: 0.1,
        p95LatencyMs: 120,
      );

      expect(point.errorCount, 10);
      expect(point.successCount, 90);
    });

    test('errorCount is zero when failureRate is 0', () {
      final point = OpsMetricsSeriesPoint(
        bucketStart: DateTime.now(),
        env: 'prod',
        app: 'flutter_web',
        event: 'search',
        total: 100,
        failureRate: 0.0,
        p95LatencyMs: 120,
      );

      expect(point.errorCount, 0);
      expect(point.successCount, 100);
    });

    test('fromJson parses correctly', () {
      final json = {
        'bucket_5m': '2024-01-01T00:00:00Z',
        'env': 'prod',
        'app': 'flutter_web',
        'event': 'search',
        'total': 100,
        'failure_rate': 0.1,
        'p95_latency_ms': 120,
      };

      final point = OpsMetricsSeriesPoint.fromJson(json);

      expect(point.env, 'prod');
      expect(point.app, 'flutter_web');
      expect(point.event, 'search');
      expect(point.total, 100);
      expect(point.failureRate, 0.1);
      expect(point.p95LatencyMs, 120);
      expect(point.errorCount, 10);
      expect(point.successCount, 90);
    });
  });

  group('OpsMetricsKpi', () {
    test('aggregates success, error, and p95 from series', () {
      final now = DateTime.now();
      final series = [
        OpsMetricsSeriesPoint(
          bucketStart: now.subtract(const Duration(minutes: 10)),
          env: 'prod',
          app: 'flutter_web',
          event: 'import',
          total: 100,
          failureRate: 0.1,
          p95LatencyMs: 200,
        ),
        OpsMetricsSeriesPoint(
          bucketStart: now.subtract(const Duration(minutes: 5)),
          env: 'prod',
          app: 'flutter_web',
          event: 'import',
          total: 50,
          failureRate: 0.1,
          p95LatencyMs: 150,
        ),
      ];

      final kpi = OpsMetricsKpi.fromSeries(series);

      expect(kpi.totalRequests, 150);
      expect(kpi.errorCount, 15);
      expect(kpi.errorRate, closeTo(0.1, 0.0001));
      expect(kpi.p95LatencyMs, 200); // Max of p95 values
    });

    test('p95 remains null when all source values missing', () {
      final now = DateTime.now();
      final series = [
        OpsMetricsSeriesPoint(
          bucketStart: now.subtract(const Duration(minutes: 10)),
          env: 'prod',
          app: 'flutter_web',
          event: 'import',
          total: 100,
          failureRate: 0.1,
          p95LatencyMs: null,
        ),
      ];

      final kpi = OpsMetricsKpi.fromSeries(series);

      expect(kpi.p95LatencyMs, isNull);
    });

    test('handles empty series', () {
      final kpi = OpsMetricsKpi.fromSeries([]);

      expect(kpi.totalRequests, 0);
      expect(kpi.errorCount, 0);
      expect(kpi.errorRate, 0.0);
      expect(kpi.p95LatencyMs, isNull);
    });
  });
}


// Status:: in-progress
// Source-of-Truth:: test/src/features/ops/ops_metrics_model_test.dart
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  group('OpsMetricsSeriesPoint', () {
    test('calculates successCount and errorCount correctly', () {
      final point = OpsMetricsSeriesPoint(
        bucketStart: DateTime.now(),
        env: 'prod',
        app: 'starlist',
        event: 'search.sla_missed',
        total: 100,
        failureRate: 0.1,
        p95LatencyMs: 500,
      );

      expect(point.errorCount, 10);
      expect(point.successCount, 90);
    });

    test('handles zero total correctly', () {
      final point = OpsMetricsSeriesPoint(
        bucketStart: DateTime.now(),
        env: 'prod',
        app: 'starlist',
        event: 'search.sla_missed',
        total: 0,
        failureRate: 0.0,
      );

      expect(point.errorCount, 0);
      expect(point.successCount, 0);
    });

    test('fromJson parses correctly', () {
      final json = {
        'bucket_5m': '2025-11-07T12:00:00Z',
        'env': 'prod',
        'app': 'starlist',
        'event': 'search.sla_missed',
        'total': 100,
        'failure_rate': 0.1,
        'p95_latency_ms': 500,
      };

      final point = OpsMetricsSeriesPoint.fromJson(json);
      expect(point.env, 'prod');
      expect(point.app, 'starlist');
      expect(point.total, 100);
      expect(point.failureRate, 0.1);
      expect(point.p95LatencyMs, 500);
    });
  });

  group('OpsMetricsKpi', () {
    test('calculates KPI from series correctly', () {
      final series = [
        OpsMetricsSeriesPoint(
          bucketStart: DateTime.now(),
          env: 'prod',
          app: 'starlist',
          event: 'search',
          total: 100,
          failureRate: 0.1,
          p95LatencyMs: 200,
        ),
        OpsMetricsSeriesPoint(
          bucketStart: DateTime.now(),
          env: 'prod',
          app: 'starlist',
          event: 'search',
          total: 50,
          failureRate: 0.2,
          p95LatencyMs: 500,
        ),
      ];

      final kpi = OpsMetricsKpi.fromSeries(series);
      expect(kpi.totalRequests, 150);
      expect(kpi.errorCount, 20);
      expect((kpi.errorRate * 100).round(), 13); // ~13.33%
      expect(kpi.p95LatencyMs, 500); // Max of p95 values
    });

    test('handles empty series', () {
      final kpi = OpsMetricsKpi.fromSeries([]);
      expect(kpi.totalRequests, 0);
      expect(kpi.errorCount, 0);
      expect(kpi.errorRate, 0.0);
      expect(kpi.p95LatencyMs, null);
    });
  });
}



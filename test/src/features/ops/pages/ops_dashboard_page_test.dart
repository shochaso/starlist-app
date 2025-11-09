import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';
import 'package:starlist_app/src/features/ops/screens/ops_dashboard_page.dart';
import 'package:starlist_app/src/features/ops/providers/ops_metrics_provider.dart';

void main() {
  group('OpsDashboardPage', () {
    testWidgets('changing env dropdown updates filter provider', (tester) async {
      final now = DateTime.now();
      final series = [
        OpsMetricsSeriesPoint(
          bucketStart: now,
          env: 'prod',
          app: 'flutter_web',
          event: 'search',
          total: 12,
          failureRate: 0.1667, // 2 errors out of 12
          p95LatencyMs: 200,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          opsMetricsSeriesProvider.overrideWith(
            () => _FakeOpsMetricsSeriesNotifier(series),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OpsDashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the first dropdown (Env) and select "prod".
      final dropdowns = find.byType(DropdownButton<String>);
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('prod').last);
        await tester.pumpAndSettle();

        final filter = container.read(opsMetricsFilterProvider);
        expect(filter.env, 'prod');
      }
    });
  });
}

class _FakeOpsMetricsSeriesNotifier extends OpsMetricsSeriesNotifier {
  _FakeOpsMetricsSeriesNotifier(this._series);

  final List<OpsMetricsSeriesPoint> _series;

  @override
  Future<List<OpsMetricsSeriesPoint>> build() async {
    return _series;
  }
}

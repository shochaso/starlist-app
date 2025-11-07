import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_model.dart';
import 'package:starlist_app/src/features/ops/pages/ops_dashboard_page.dart';
import 'package:starlist_app/src/features/ops/providers/ops_metrics_provider.dart';

class _FakeOpsMetricsSeriesNotifier
    extends AutoDisposeAsyncNotifier<List<OpsMetric>> {
  _FakeOpsMetricsSeriesNotifier(this._metrics);

  final List<OpsMetric> _metrics;

  @override
  Future<List<OpsMetric>> build() async => _metrics;
}

void main() {
  group('OpsDashboardPage', () {
    testWidgets('changing env dropdown updates filter provider', (tester) async {
      final now = DateTime.now().toUtc();
      final metrics = [
        OpsMetric(
          bucketStart: now,
          env: 'prod',
          app: 'flutter_web',
          eventType: 'search',
          successCount: 10,
          errorCount: 2,
          p95Ms: 200,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          opsMetricsSeriesProvider.overrideWith(
            () => _FakeOpsMetricsSeriesNotifier(metrics),
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
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('prod').last);
      await tester.pumpAndSettle();

      final filter = container.read(opsMetricsFilterProvider);
      expect(filter.env, 'prod');
    });
  });
}

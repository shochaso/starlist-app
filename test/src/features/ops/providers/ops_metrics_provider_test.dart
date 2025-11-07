import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/src/features/ops/providers/ops_metrics_provider.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  group('OpsMetricsFilterProvider', () {
    test('updates env/app/event/window correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(opsMetricsFilterProvider.notifier);
      
      notifier.state = const OpsMetricsFilter(
        env: 'prod',
        app: 'flutter_web',
        eventType: 'search',
        sinceMinutes: 60,
      );

      expect(notifier.state.env, 'prod');
      expect(notifier.state.app, 'flutter_web');
      expect(notifier.state.eventType, 'search');
      expect(notifier.state.sinceMinutes, 60);

      notifier.state = notifier.state.copyWith(env: null);
      expect(notifier.state.env, isNull);
    });
  });
}


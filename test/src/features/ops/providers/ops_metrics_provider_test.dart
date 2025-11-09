import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/src/features/ops/providers/ops_metrics_provider.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  group('OpsMetricsFilterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('normalizes values and clamps window', () {
      final notifier = container.read(opsMetricsFilterProvider.notifier);

      notifier.updateEnv('prod');
      notifier.updateApp('  flutter_web  ');
      notifier.updateEventType('auth.login.success');
      notifier.updateWindow(3); // should clamp to >=5

      expect(notifier.state.env, 'prod');
      expect(notifier.state.app, 'flutter_web');
      expect(notifier.state.eventType, 'auth.login.success');
      expect(notifier.state.sinceMinutes, 5);

      notifier.updateEnv('ALL');
      notifier.updateApp('');
      notifier.updateEventType(null);

      expect(notifier.state.env, isNull);
      expect(notifier.state.app, isNull);
      expect(notifier.state.eventType, isNull);
    });

    test('reset returns default filter', () {
      final notifier = container.read(opsMetricsFilterProvider.notifier);
      notifier.setFilter(const OpsMetricsFilter(env: 'dev', sinceMinutes: 120));
      expect(notifier.state.env, 'dev');
      expect(notifier.state.sinceMinutes, 120);

      notifier.reset();
      expect(notifier.state.env, isNull);
      expect(notifier.state.sinceMinutes, 30);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/providers/ops_metrics_provider.dart';

void main() {
  group('OpsMetricsFilterNotifier', () {
    test('updates env/app/event/window correctly', () {
      final notifier = OpsMetricsFilterNotifier();

      notifier.updateEnv('prod');
      expect(notifier.state.env, 'prod');

      notifier.updateApp('flutter_web');
      expect(notifier.state.app, 'flutter_web');

      notifier.updateEventType('search');
      expect(notifier.state.eventType, 'search');

      notifier.updateWindow(60);
      expect(notifier.state.sinceMinutes, 60);

      notifier.updateEnv(null);
      expect(notifier.state.env, isNull);
    });
  });
}

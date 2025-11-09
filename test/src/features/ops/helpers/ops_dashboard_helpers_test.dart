import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/features/ops/helpers/ops_dashboard_helpers.dart';
import 'package:starlist_app/src/features/ops/models/ops_metrics_series_model.dart';

void main() {
  test('formatFilterBadge shows defaults when nulls', () {
    final filter = const OpsMetricsFilter();
    final badge = formatFilterBadge(filter);
    expect(badge, contains('env:ALL'));
    expect(badge, contains('app:ALL'));
  });

  test('isAuthorizationError detects 401/403/forbidden', () {
    expect(isAuthorizationError(Exception('401 unauthorized')), isTrue);
    expect(isAuthorizationError(Exception('forbidden')), isTrue);
    expect(isAuthorizationError(Exception('timeout')), isFalse);
  });
}

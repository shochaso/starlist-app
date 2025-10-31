import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/telemetry/star_data_telemetry.dart';

final starDataTelemetryProvider = Provider<StarDataTelemetry>((ref) {
  return const NoopStarDataTelemetry();
});

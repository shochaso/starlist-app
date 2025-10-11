import 'package:flutter_test/flutter_test.dart';

import 'package:starlist_app/services/service_icon_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('service icon map should not be empty', () async {
    await ServiceIconRegistry.init();
    expect(
      ServiceIconRegistryDebug.readMap().isNotEmpty,
      true,
      reason: 'assets/config/service_icons.json が空です',
    );
  });
}

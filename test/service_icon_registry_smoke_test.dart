import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:starlist_app/services/service_icon_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iconFor returns blank placeholder respecting size', () {
    const size = 42.0;
    final widget = ServiceIconRegistry.iconFor('amazon', size: size);

    expect(widget, isA<SizedBox>());
    final box = widget as SizedBox;
    expect(box.width, size);
    expect(box.height, size);
  });

  test('pathFor returns empty string while images are hidden', () {
    expect(ServiceIconRegistry.pathFor('amazon'), equals(''));
    expect(ServiceIconRegistry.pathFor('netflix'), equals(''));
    expect(ServiceIconRegistry.pathFor('shein_jp'), equals(''));
  });

  test('debugAutoMap exposes empty mappings when images disabled', () {
    final debugMap = ServiceIconRegistry.debugAutoMap();
    for (final entry in debugMap.entries) {
      expect(entry.value, isEmpty);
    }
  });

  test('iconForOrNull also returns placeholder', () {
    const size = 30.0;
    final widget = ServiceIconRegistry.iconForOrNull('netflix', size: size);
    expect(widget, isA<SizedBox>());
    final box = widget as SizedBox;
    expect(box.width, size);
    expect(box.height, size);
  });
}

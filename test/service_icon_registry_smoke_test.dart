import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:starlist_app/services/service_icon_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iconFor returns a ServiceIcon widget', () {
    final widget = ServiceIconRegistry.iconFor('amazon', size: 42);
    expect(widget, isA<Widget>());
  });

  test('pathFor resolves CDN SVG path', () {
    expect(
      ServiceIconRegistry.pathFor('amazon'),
      startsWith('https://cdn.starlist.jp/icons/amazon.svg'),
    );
    expect(
      ServiceIconRegistry.pathFor('prime_video'),
      startsWith('https://cdn.starlist.jp/icons/prime_video.svg'),
    );
    expect(
      ServiceIconRegistry.pathFor('SHEIN_JP'),
      startsWith('https://cdn.starlist.jp/icons/shein.svg'),
    );
    expect(ServiceIconRegistry.pathFor('amazon'), contains('?v='));
  });

  test('debugAutoMap exposes alias mappings', () {
    final debugMap = ServiceIconRegistry.debugAutoMap();
    expect(debugMap['amazon_prime'], contains('prime_video.svg'));
    expect(debugMap['u_next'], contains('unext.svg'));
  });

  test('iconForOrNull returns null when key empty', () {
    expect(ServiceIconRegistry.iconForOrNull(null), isNull);
    expect(ServiceIconRegistry.iconForOrNull(''), isNull);
    expect(
      ServiceIconRegistry.iconForOrNull('netflix', size: 30),
      isA<Widget>(),
    );
  });
}

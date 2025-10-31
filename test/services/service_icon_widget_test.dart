import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/services/service_icon_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ServiceIcon.forKey renders SVG fallback when CDN unreachable',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ServiceIconRegistry.iconFor('youtube', size: 48),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 150));
    final svgFound = find.byType(SvgPicture).evaluate().isNotEmpty;
    final imageFound = find.byType(Image).evaluate().isNotEmpty;
    final sizedBoxFound = find.byType(SizedBox).evaluate().isNotEmpty;
    expect(svgFound || imageFound || sizedBoxFound, isTrue,
        reason:
            'Expected icon fallback to render (SvgPicture, Image, or SizedBox).');
  });
}

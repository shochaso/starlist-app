import "package:flutter_test/flutter_test.dart";
import "package:starlist_app/src/core/components/buttons/primary_button.dart";

void main() {
  group("PrimaryButton", () {
    testWidgets("renders correctly", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: "Test Button",
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text("Test Button"), findsOneWidget);
    });

    testWidgets("shows loading indicator when isLoading is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: "Test Button",
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("is disabled when isEnabled is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: "Test Button",
              onPressed: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}

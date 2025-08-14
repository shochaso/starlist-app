import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/subscription/models/subscription_plan.dart";
import "package:starlist_app/src/features/subscription/models/subscription_status.dart";
import "package:starlist_app/src/features/subscription/providers/subscription_provider.dart";
import "package:starlist_app/src/features/subscription/services/subscription_service.dart";
import "package:starlist_app/src/features/subscription/services/subscription_validation_service.dart";

class MockSubscriptionService extends Mock implements SubscriptionService {}
class MockValidationService extends Mock implements SubscriptionValidationService {}

void main() {
  late SubscriptionProvider subscriptionProvider;
  late MockSubscriptionService mockSubscriptionService;
  late MockValidationService mockValidationService;

  setUp(() {
    mockSubscriptionService = MockSubscriptionService();
    mockValidationService = MockValidationService();
    subscriptionProvider = SubscriptionProvider(
      mockSubscriptionService,
      mockValidationService,
    );
  });

  group("SubscriptionProvider", () {
    test("initial state", () {
      expect(subscriptionProvider.availablePlans, isEmpty);
      expect(subscriptionProvider.currentSubscription, isNull);
      expect(subscriptionProvider.isLoading, isFalse);
      expect(subscriptionProvider.error, isNull);
      expect(subscriptionProvider.hasActiveSubscription, isFalse);
    });

    test("load available plans success", () async {
      final plans = [
        SubscriptionPlan(
          id: "1",
          name: "Basic",
          description: "Basic Plan",
          price: 9.99,
          currency: "USD",
          billingPeriod: const Duration(days: 30),
          features: ["feature1", "feature2"],
        ),
      ];

      when(mockSubscriptionService.getAvailablePlans()).thenAnswer((_) async => plans);

      await subscriptionProvider.loadAvailablePlans();

      expect(subscriptionProvider.availablePlans, equals(plans));
      expect(subscriptionProvider.error, isNull);
    });

    test("load current subscription success", () async {
      final subscription = SubscriptionStatusModel(
        id: "1",
        userId: "user1",
        planId: "plan1",
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
      );

      when(mockSubscriptionService.getCurrentSubscription("user1"))
          .thenAnswer((_) async => subscription);
      when(mockValidationService.isValidSubscription(subscription)).thenReturn(true);

      await subscriptionProvider.loadCurrentSubscription("user1");

      expect(subscriptionProvider.currentSubscription, equals(subscription));
      expect(subscriptionProvider.error, isNull);
      expect(subscriptionProvider.hasActiveSubscription, isTrue);
    });

    test("subscribe success", () async {
      final subscription = SubscriptionStatusModel(
        id: "1",
        userId: "user1",
        planId: "plan1",
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
      );

      when(mockSubscriptionService.subscribe("user1", "plan1", "payment1"))
          .thenAnswer((_) async => subscription);

      await subscriptionProvider.subscribe("user1", "plan1", "payment1");

      expect(subscriptionProvider.currentSubscription, equals(subscription));
      expect(subscriptionProvider.error, isNull);
    });

    test("cancel subscription success", () async {
      final subscription = SubscriptionStatusModel(
        id: "1",
        userId: "user1",
        planId: "plan1",
        status: SubscriptionStatus.canceled,
        startDate: DateTime.now(),
      );

      when(mockSubscriptionService.cancelSubscription("user1"))
          .thenAnswer((_) async => subscription);

      await subscriptionProvider.cancelSubscription("user1");

      expect(subscriptionProvider.currentSubscription, equals(subscription));
      expect(subscriptionProvider.error, isNull);
    });
  });
}

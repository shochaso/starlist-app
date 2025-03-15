import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/subscription/domain/services/subscription_service.dart';
import 'package:starlist/src/shared/models/subscription_model.dart';
import 'package:starlist/src/shared/models/user_model.dart';

@GenerateMocks([SubscriptionService])
void main() {
  late MockSubscriptionService mockSubscriptionService;
  late SubscriptionViewModel viewModel;

  setUp(() {
    mockSubscriptionService = MockSubscriptionService();
    viewModel = SubscriptionViewModel(subscriptionService: mockSubscriptionService);
  });

  group('SubscriptionViewModel', () {
    test('loadActiveSubscriptions should update state correctly', () async {
      // Arrange
      final subscriptions = [
        SubscriptionModel(
          id: '1',
          fanId: 'fan1',
          starId: 'star1',
          tierLevel: 1,
          amount: 500.0,
          currency: 'JPY',
          billingCycle: 'monthly',
          paymentMethod: 'credit_card',
          paymentStatus: 'active',
          startedAt: DateTime.now(),
          nextBillingDate: DateTime.now().add(Duration(days: 30)),
          isActive: true,
        ),
      ];
      
      when(mockSubscriptionService.getActiveSubscriptions())
          .thenAnswer((_) async => subscriptions);
      
      // Act
      await viewModel.loadActiveSubscriptions();
      
      // Assert
      expect(viewModel.activeSubscriptions, subscriptions);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockSubscriptionService.getActiveSubscriptions()).called(1);
    });

    test('loadStarSubscriptionTiers should update state correctly', () async {
      // Arrange
      final star = UserModel(
        id: 'star1',
        email: 'star@example.com',
        username: 'staruser',
        displayName: 'Star User',
        isVerified: true,
        isStar: true,
      );
      
      final tiers = [
        SubscriptionTierModel(
          id: 1,
          name: 'Basic',
          description: 'Basic tier',
          price: 500.0,
          currency: 'JPY',
          billingCycle: 'monthly',
          benefits: ['Ad-free experience', 'Basic content access'],
        ),
        SubscriptionTierModel(
          id: 2,
          name: 'Premium',
          description: 'Premium tier',
          price: 1200.0,
          currency: 'JPY',
          billingCycle: 'monthly',
          benefits: ['Ad-free experience', 'Full content access', 'Exclusive messages'],
        ),
      ];
      
      when(mockSubscriptionService.getStarProfile('star1'))
          .thenAnswer((_) async => star);
      when(mockSubscriptionService.getStarSubscriptionTiers('star1'))
          .thenAnswer((_) async => tiers);
      
      // Act
      await viewModel.loadStarSubscriptionTiers('star1');
      
      // Assert
      expect(viewModel.selectedStar, star);
      expect(viewModel.availableTiers, tiers);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockSubscriptionService.getStarProfile('star1')).called(1);
      verify(mockSubscriptionService.getStarSubscriptionTiers('star1')).called(1);
    });

    test('purchaseSubscription should call service and reload subscriptions on success', () async {
      // Arrange
      final subscriptions = [
        SubscriptionModel(
          id: '1',
          fanId: 'fan1',
          starId: 'star1',
          tierLevel: 1,
          amount: 500.0,
          currency: 'JPY',
          billingCycle: 'monthly',
          paymentMethod: 'credit_card',
          paymentStatus: 'active',
          startedAt: DateTime.now(),
          nextBillingDate: DateTime.now().add(Duration(days: 30)),
          isActive: true,
        ),
      ];
      
      when(mockSubscriptionService.purchaseSubscription(
        starId: 'star1',
        tierId: 1,
        paymentMethod: 'credit_card',
      )).thenAnswer((_) async => true);
      
      when(mockSubscriptionService.getActiveSubscriptions())
          .thenAnswer((_) async => subscriptions);
      
      // Act
      final result = await viewModel.purchaseSubscription(
        starId: 'star1',
        tierId: 1,
        paymentMethod: 'credit_card',
      );
      
      // Assert
      expect(result, true);
      expect(viewModel.activeSubscriptions, subscriptions);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockSubscriptionService.purchaseSubscription(
        starId: 'star1',
        tierId: 1,
        paymentMethod: 'credit_card',
      )).called(1);
      verify(mockSubscriptionService.getActiveSubscriptions()).called(1);
    });

    test('cancelSubscription should call service and reload subscriptions on success', () async {
      // Arrange
      final subscriptions = [];
      
      when(mockSubscriptionService.cancelSubscription('sub1'))
          .thenAnswer((_) async => true);
      
      when(mockSubscriptionService.getActiveSubscriptions())
          .thenAnswer((_) async => subscriptions);
      
      // Act
      final result = await viewModel.cancelSubscription('sub1');
      
      // Assert
      expect(result, true);
      expect(viewModel.activeSubscriptions, subscriptions);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockSubscriptionService.cancelSubscription('sub1')).called(1);
      verify(mockSubscriptionService.getActiveSubscriptions()).called(1);
    });
  });
}

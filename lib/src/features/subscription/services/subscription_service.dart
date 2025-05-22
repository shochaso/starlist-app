import "../models/subscription_plan.dart";
import "../models/subscription_status.dart";

abstract class SubscriptionService {
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId);
  Future<SubscriptionStatusModel> subscribe(String userId, String planId, String paymentMethodId);
  Future<SubscriptionStatusModel> cancelSubscription(String userId);
  Future<SubscriptionStatusModel> updateSubscription(String userId, String newPlanId);
  Future<void> handleWebhook(String payload);
}

class SubscriptionServiceImpl implements SubscriptionService {
  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    // TODO: Implement plan fetching from backend
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId) async {
    // TODO: Implement subscription status fetching
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionStatusModel> subscribe(String userId, String planId, String paymentMethodId) async {
    // TODO: Implement subscription creation
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionStatusModel> cancelSubscription(String userId) async {
    // TODO: Implement subscription cancellation
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionStatusModel> updateSubscription(String userId, String newPlanId) async {
    // TODO: Implement subscription update
    throw UnimplementedError();
  }

  @override
  Future<void> handleWebhook(String payload) async {
    // TODO: Implement webhook handling
    throw UnimplementedError();
  }
}

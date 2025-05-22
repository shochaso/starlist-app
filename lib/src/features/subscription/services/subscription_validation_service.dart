import "../models/subscription_status.dart";

class SubscriptionValidationService {
  bool isValidSubscription(SubscriptionStatusModel subscription) {
    if (subscription.isExpired || subscription.isCanceled || subscription.isFailed) {
      return false;
    }

    if (subscription.nextBillingDate != null &&
        DateTime.now().isAfter(subscription.nextBillingDate!)) {
      return false;
    }

    return true;
  }

  bool hasAccessToFeature(SubscriptionStatusModel subscription, String feature) {
    if (!isValidSubscription(subscription)) {
      return false;
    }

    // TODO: Implement feature access check based on subscription plan
    return true;
  }

  bool canUpgrade(SubscriptionStatusModel current, String newPlanId) {
    if (!isValidSubscription(current)) {
      return true;
    }

    // TODO: Implement upgrade eligibility check
    return true;
  }

  bool canDowngrade(SubscriptionStatusModel current, String newPlanId) {
    if (!isValidSubscription(current)) {
      return true;
    }

    // TODO: Implement downgrade eligibility check
    return true;
  }
}

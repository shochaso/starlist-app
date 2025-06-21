import "package:flutter/foundation.dart";
import "../models/subscription_plan.dart";
import "../models/subscription_status.dart";
import "../services/subscription_service.dart";
import "../services/subscription_validation_service.dart";

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  final SubscriptionValidationService _validationService;

  List<SubscriptionPlan> _availablePlans = [];
  SubscriptionStatusModel? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider(this._subscriptionService, this._validationService);

  List<SubscriptionPlan> get availablePlans => _availablePlans;
  SubscriptionStatusModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSubscription =>
      _currentSubscription != null && _validationService.isValidSubscription(_currentSubscription!);

  Future<void> loadAvailablePlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _availablePlans = await _subscriptionService.getAvailablePlans();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentSubscription(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentSubscription = await _subscriptionService.getCurrentSubscription(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentSubscription = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribe(String userId, String planId, String paymentMethodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentSubscription = await _subscriptionService.subscribe(userId, planId, paymentMethodId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelSubscription(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentSubscription = await _subscriptionService.cancelSubscription(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSubscription(String userId, String newPlanId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentSubscription = await _subscriptionService.updateSubscription(userId, newPlanId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasAccessToFeature(String feature) {
    if (_currentSubscription == null) return false;
    return _validationService.hasAccessToFeature(_currentSubscription!, feature);
  }

  bool canUpgrade(String newPlanId) {
    if (_currentSubscription == null) return true;
    return _validationService.canUpgrade(_currentSubscription!, newPlanId);
  }

  bool canDowngrade(String newPlanId) {
    if (_currentSubscription == null) return true;
    return _validationService.canDowngrade(_currentSubscription!, newPlanId);
  }
}

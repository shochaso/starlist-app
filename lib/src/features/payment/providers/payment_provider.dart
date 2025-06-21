import "package:flutter/foundation.dart";
import "package:starlist/src/features/payment/models/payment_model.dart";
import "package:starlist/src/features/payment/services/payment_service.dart";

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  PaymentProvider(this._paymentService);

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createPayment({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final payment = await _paymentService.createPayment(
        userId: userId,
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      _payments.add(payment);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPayments(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _payments = await _paymentService.getUserPayments(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelPayment(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final payment = await _paymentService.cancelPayment(paymentId);
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = payment;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refundPayment(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final payment = await _paymentService.refundPayment(paymentId);
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = payment;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/user_model.dart';

/// 決済機能のビューモデル
/// 決済の状態管理と操作を担当する
class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService;
  
  List<TransactionModel> _transactions = [];
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;
  
  PaymentViewModel({
    required PaymentService paymentService,
  }) : _paymentService = paymentService;
  
  /// トランザクション履歴
  List<TransactionModel> get transactions => _transactions;
  
  /// 登録済み決済方法
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  
  /// 読み込み中かどうか
  bool get isLoading => _isLoading;
  
  /// エラーメッセージ
  String? get error => _error;
  
  /// トランザクション履歴を読み込む
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final transactions = await _paymentService.getTransactionHistory();
      
      _transactions = transactions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 登録済み決済方法を読み込む
  Future<void> loadPaymentMethods() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final methods = await _paymentService.getPaymentMethods();
      
      _paymentMethods = methods;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 新しい決済方法を追加する
  Future<bool> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _paymentService.addPaymentMethod(
        type: type,
        details: details,
      );
      
      if (success) {
        await loadPaymentMethods();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// 決済方法を削除する
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _paymentService.removePaymentMethod(paymentMethodId);
      
      if (success) {
        await loadPaymentMethods();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// 投げ銭を送信する
  Future<bool> sendDonation({
    required String receiverId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    String? message,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _paymentService.sendDonation(
        receiverId: receiverId,
        amount: amount,
        currency: currency,
        paymentMethodId: paymentMethodId,
        message: message,
      );
      
      if (success) {
        await loadTransactions();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// 収益レポートを取得する
  Future<Map<String, dynamic>> getEarningsReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final report = await _paymentService.getEarningsReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return report;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }
}

/// 決済方法モデル
class PaymentMethodModel {
  final String id;
  final String type; // credit_card, paypal, etc.
  final String label;
  final bool isDefault;
  final Map<String, dynamic> details;
  
  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.label,
    required this.isDefault,
    required this.details,
  });
}

/// 決済サービスのインターフェース
/// 決済データの取得と操作を担当する
abstract class PaymentService {
  /// トランザクション履歴を取得する
  Future<List<TransactionModel>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
  });
  
  /// 登録済み決済方法を取得する
  Future<List<PaymentMethodModel>> getPaymentMethods();
  
  /// 新しい決済方法を追加する
  Future<bool> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
  });
  
  /// 決済方法を削除する
  Future<bool> removePaymentMethod(String paymentMethodId);
  
  /// 投げ銭を送信する
  Future<bool> sendDonation({
    required String receiverId,
    required double amount,
    required String currency,
    required String paymentMethodId,
    String? message,
  });
  
  /// 収益レポートを取得する
  Future<Map<String, dynamic>> getEarningsReport({
    DateTime? startDate,
    DateTime? endDate,
  });
}

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// 決済サービスインターフェース
abstract class PaymentService {
  /// 取引を作成
  Future<TransactionModel> createTransaction({
    required String userId,
    String? starId,
    required String transactionType,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? subscriptionId,
    String? description,
    Map<String, dynamic>? metadata,
  });
  
  /// 取引を更新
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  
  /// 取引をキャンセル
  Future<void> cancelTransaction(String transactionId);
  
  /// 取引を取得
  Future<TransactionModel?> getTransaction(String transactionId);
  
  /// ユーザーの取引履歴を取得
  Future<List<TransactionModel>> getUserTransactions(String userId);
  
  /// スターの取引履歴を取得
  Future<List<TransactionModel>> getStarTransactions(String starId);
  
  /// サブスクリプションに関連する取引を取得
  Future<List<TransactionModel>> getSubscriptionTransactions(String subscriptionId);
  
  /// 投げ銭取引を作成
  Future<TransactionModel> createTipTransaction({
    required String userId,
    required String starId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? description,
    Map<String, dynamic>? metadata,
  });
}

/// 決済サービスの実装
class PaymentServiceImpl implements PaymentService {
  final TransactionRepository _transactionRepository;
  
  PaymentServiceImpl(this._transactionRepository);
  
  @override
  Future<TransactionModel> createTransaction({
    required String userId,
    String? starId,
    required String transactionType,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? subscriptionId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 実際の実装ではUUIDなどを使用
      userId: userId,
      starId: starId,
      transactionType: transactionType,
      transactionDate: DateTime.now(),
      amount: amount,
      currency: currency,
      status: 'completed',
      paymentMethod: paymentMethod,
      subscriptionId: subscriptionId,
      description: description,
      metadata: metadata,
    );
    
    return _transactionRepository.createTransaction(transaction);
  }
  
  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) {
    return _transactionRepository.updateTransaction(transaction);
  }
  
  @override
  Future<void> cancelTransaction(String transactionId) {
    return _transactionRepository.cancelTransaction(transactionId);
  }
  
  @override
  Future<TransactionModel?> getTransaction(String transactionId) {
    return _transactionRepository.getTransaction(transactionId);
  }
  
  @override
  Future<List<TransactionModel>> getUserTransactions(String userId) {
    return _transactionRepository.getUserTransactions(userId);
  }
  
  @override
  Future<List<TransactionModel>> getStarTransactions(String starId) {
    return _transactionRepository.getStarTransactions(starId);
  }
  
  @override
  Future<List<TransactionModel>> getSubscriptionTransactions(String subscriptionId) {
    return _transactionRepository.getSubscriptionTransactions(subscriptionId);
  }
  
  @override
  Future<TransactionModel> createTipTransaction({
    required String userId,
    required String starId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return createTransaction(
      userId: userId,
      starId: starId,
      transactionType: 'tip',
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      description: description ?? 'Tip to creator',
      metadata: metadata,
    );
  }
}

import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/payment_method_model.dart';
import '../repositories/transaction_repository.dart';

/// 決済プロセッサーの種類を表すenum
enum PaymentProcessorType {
  /// Stripe決済
  stripe,
  
  /// PayPal決済
  paypal,
  
  /// Apple Pay
  applePay,
  
  /// Google Pay
  googlePay,
  
  /// PayPay
  paypay,
  
  /// LINE Pay
  linePay,
  
  /// キャリア決済
  carrierBilling,
  
  /// コンビニ決済
  convenienceStore,
  
  /// 銀行振込
  bankTransfer,
}

/// 決済プロセッサーの抽象インターフェース
abstract class PaymentProcessor {
  /// 決済プロセッサーの種類
  PaymentProcessorType get type;
  
  /// 決済処理を実行する
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentDetails,
    Map<String, dynamic>? metadata,
  });
  
  /// 決済状態を確認する
  Future<TransactionStatus> checkPaymentStatus(String paymentId);
  
  /// 決済をキャンセルする
  Future<bool> cancelPayment(String paymentId);
  
  /// 返金処理を実行する
  Future<Map<String, dynamic>> processRefund({
    required String paymentId,
    required double amount,
    String? reason,
  });
}

/// 決済サービスクラス
class PaymentService {
  final TransactionRepository _transactionRepository;
  final Map<PaymentProcessorType, PaymentProcessor> _processors;
  
  /// コンストラクタ
  PaymentService({
    required TransactionRepository transactionRepository,
    required Map<PaymentProcessorType, PaymentProcessor> processors,
  }) : _transactionRepository = transactionRepository,
       _processors = processors;
  
  /// 決済処理を実行する
  Future<Transaction> processPayment({
    required String userId,
    required String? targetId,
    required double amount,
    required String currency,
    required TransactionType transactionType,
    required PaymentMethodType methodType,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 支払い方法に対応する決済プロセッサーを選択
      final processorType = _getProcessorTypeForPaymentMethod(methodType);
      final processor = _processors[processorType];
      
      if (processor == null) {
        throw Exception('対応する決済プロセッサーが見つかりません: $processorType');
      }
      
      // 支払い方法の詳細を取得（実際の実装では支払い方法リポジトリから取得）
      final paymentDetails = await _getPaymentMethodDetails(paymentMethodId);
      
      // 決済処理を実行
      final result = await processor.processPayment(
        userId: userId,
        amount: amount,
        currency: currency,
        paymentDetails: paymentDetails,
        metadata: metadata,
      );
      
      // トランザクションを作成
      final transaction = Transaction(
        id: result['transactionId'],
        userId: userId,
        targetId: targetId,
        amount: amount,
        currency: currency,
        type: transactionType,
        status: TransactionStatus.completed,
        paymentMethod: methodType.toString().split('.').last,
        description: '${transactionType.toString().split('.').last} payment',
        metadata: {
          ...?metadata,
          'processorType': processorType.toString(),
          'processorTransactionId': result['processorTransactionId'],
        },
        receiptUrl: result['receiptUrl'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // トランザクションを保存
      return await _transactionRepository.saveTransaction(transaction);
    } catch (e) {
      // エラーログ
      debugPrint('決済処理エラー: $e');
      
      // 失敗したトランザクションを記録
      final failedTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        targetId: targetId,
        amount: amount,
        currency: currency,
        type: transactionType,
        status: TransactionStatus.failed,
        paymentMethod: methodType.toString().split('.').last,
        description: 'Failed payment: ${e.toString()}',
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _transactionRepository.saveTransaction(failedTransaction);
      
      // エラーを再スロー
      rethrow;
    }
  }
  
  /// 決済状態を確認する
  Future<TransactionStatus> checkPaymentStatus(String transactionId) async {
    try {
      // トランザクションを取得
      final transaction = await _transactionRepository.getTransactionById(transactionId);
      
      // すでに完了または失敗している場合はその状態を返す
      if (transaction.status == TransactionStatus.completed || 
          transaction.status == TransactionStatus.failed ||
          transaction.status == TransactionStatus.refunded) {
        return transaction.status;
      }
      
      // 処理中の場合は決済プロセッサーに状態を確認
      final processorType = PaymentProcessorType.values.firstWhere(
        (type) => transaction.metadata?['processorType'] == type.toString(),
        orElse: () => PaymentProcessorType.stripe, // デフォルト
      );
      
      final processor = _processors[processorType];
      if (processor == null) {
        throw Exception('対応する決済プロセッサーが見つかりません: $processorType');
      }
      
      final processorTransactionId = transaction.metadata?['processorTransactionId'];
      if (processorTransactionId == null) {
        throw Exception('プロセッサートランザクションIDが見つかりません');
      }
      
      // プロセッサーから最新の状態を取得
      final status = await processor.checkPaymentStatus(processorTransactionId);
      
      // トランザクションの状態を更新
      if (status != transaction.status) {
        final updatedTransaction = transaction.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _transactionRepository.saveTransaction(updatedTransaction);
      }
      
      return status;
    } catch (e) {
      debugPrint('決済状態確認エラー: $e');
      rethrow;
    }
  }
  
  /// 決済をキャンセルする
  Future<bool> cancelPayment(String transactionId) async {
    try {
      // トランザクションを取得
      final transaction = await _transactionRepository.getTransactionById(transactionId);
      
      // すでに完了または失敗している場合はキャンセル不可
      if (transaction.status == TransactionStatus.completed || 
          transaction.status == TransactionStatus.failed ||
          transaction.status == TransactionStatus.refunded) {
        return false;
      }
      
      // 決済プロセッサーを特定
      final processorType = PaymentProcessorType.values.firstWhere(
        (type) => transaction.metadata?['processorType'] == type.toString(),
        orElse: () => PaymentProcessorType.stripe, // デフォルト
      );
      
      final processor = _processors[processorType];
      if (processor == null) {
        throw Exception('対応する決済プロセッサーが見つかりません: $processorType');
      }
      
      final processorTransactionId = transaction.metadata?['processorTransactionId'];
      if (processorTransactionId == null) {
        throw Exception('プロセッサートランザクションIDが見つかりません');
      }
      
      // プロセッサーでキャンセル処理
      final success = await processor.cancelPayment(processorTransactionId);
      
      if (success) {
        // トランザクションの状態を更新
        final updatedTransaction = transaction.copyWith(
          status: TransactionStatus.failed,
          description: '${transaction.description} (Cancelled)',
          updatedAt: DateTime.now(),
        );
        await _transactionRepository.saveTransaction(updatedTransaction);
      }
      
      return success;
    } catch (e) {
      debugPrint('決済キャンセルエラー: $e');
      return false;
    }
  }
  
  /// 支払い方法に対応する決済プロセッサーの種類を取得する
  PaymentProcessorType _getProcessorTypeForPaymentMethod(PaymentMethodType methodType) {
    switch (methodType) {
      case PaymentMethodType.creditCard:
        return PaymentProcessorType.stripe;
      case PaymentMethodType.paypal:
        return PaymentProcessorType.paypal;
      case PaymentMethodType.applePay:
        return PaymentProcessorType.applePay;
      case PaymentMethodType.googlePay:
        return PaymentProcessorType.googlePay;
      case PaymentMethodType.paypay:
        return PaymentProcessorType.paypay;
      case PaymentMethodType.linePay:
        return PaymentProcessorType.linePay;
      case PaymentMethodType.carrierBilling:
        return PaymentProcessorType.carrierBilling;
      case PaymentMethodType.convenienceStore:
        return PaymentProcessorType.convenienceStore;
      case PaymentMethodType.bankTransfer:
        return PaymentProcessorType.bankTransfer;
      default:
        return PaymentProcessorType.stripe;
    }
  }
  
  /// 支払い方法の詳細を取得する（実際の実装では支払い方法リポジトリから取得）
  Future<Map<String, dynamic>> _getPaymentMethodDetails(String paymentMethodId) async {
    // 実際の実装では支払い方法リポジトリから取得
    // このサンプルでは仮のデータを返す
    return {
      'id': paymentMethodId,
      'last4': '4242',
      'brand': 'visa',
      'expiryMonth': 12,
      'expiryYear': 2025,
    };
  }
}

import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import 'payment_service.dart';
import 'notification_service.dart';

/// 返金理由を表すenum
enum RefundReason {
  /// ユーザーリクエスト
  customerRequest,
  
  /// 技術的問題
  technicalIssue,
  
  /// 不正取引
  fraudulentTransaction,
  
  /// 商品の問題
  productIssue,
  
  /// その他
  other,
}

/// 返金ステータスを表すenum
enum RefundStatus {
  /// リクエスト済み
  requested,
  
  /// 審査中
  underReview,
  
  /// 承認済み
  approved,
  
  /// 拒否
  rejected,
  
  /// 処理済み
  processed,
  
  /// 失敗
  failed,
}

/// 返金を表すクラス
class Refund {
  final String id;
  final String transactionId;
  final String userId;
  final double amount;
  final RefundReason reason;
  final String? description;
  final RefundStatus status;
  final String? approvedBy;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? metadata;
  
  /// コンストラクタ
  Refund({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.reason,
    this.description,
    required this.status,
    this.approvedBy,
    required this.requestedAt,
    this.processedAt,
    this.metadata,
  });
  
  /// JSONからRefundを生成するファクトリメソッド
  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      transactionId: json['transactionId'],
      userId: json['userId'],
      amount: json['amount'],
      reason: RefundReason.values.firstWhere(
        (e) => e.toString() == 'RefundReason.${json['reason']}',
        orElse: () => RefundReason.other,
      ),
      description: json['description'],
      status: RefundStatus.values.firstWhere(
        (e) => e.toString() == 'RefundStatus.${json['status']}',
        orElse: () => RefundStatus.requested,
      ),
      approvedBy: json['approvedBy'],
      requestedAt: DateTime.parse(json['requestedAt']),
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      metadata: json['metadata'],
    );
  }
  
  /// RefundをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'userId': userId,
      'amount': amount,
      'reason': reason.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'approvedBy': approvedBy,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  Refund copyWith({
    String? id,
    String? transactionId,
    String? userId,
    double? amount,
    RefundReason? reason,
    String? description,
    RefundStatus? status,
    String? approvedBy,
    DateTime? requestedAt,
    DateTime? processedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Refund(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 返金リポジトリの抽象インターフェース
abstract class RefundRepository {
  /// ユーザーの返金リクエストを取得する
  Future<List<Refund>> getRefundsForUser(String userId);
  
  /// 保留中の返金リクエストを取得する
  Future<List<Refund>> getPendingRefunds();
  
  /// 返金リクエストを作成する
  Future<Refund> createRefundRequest(Refund refund);
  
  /// 返金ステータスを更新する
  Future<Refund> updateRefundStatus(String refundId, RefundStatus status, {String? approvedBy, DateTime? processedAt});
  
  /// 返金IDで返金リクエストを取得する
  Future<Refund> getRefundById(String refundId);
}

/// 返金サービスクラス
class RefundService {
  final RefundRepository _refundRepository;
  final TransactionRepository _transactionRepository;
  final PaymentService _paymentService;
  final NotificationService _notificationService;
  
  /// コンストラクタ
  RefundService({
    required RefundRepository refundRepository,
    required TransactionRepository transactionRepository,
    required PaymentService paymentService,
    required NotificationService notificationService,
  }) : _refundRepository = refundRepository,
       _transactionRepository = transactionRepository,
       _paymentService = paymentService,
       _notificationService = notificationService;
  
  /// 返金リクエストを作成する
  Future<Refund> requestRefund({
    required String transactionId,
    required String userId,
    required double amount,
    required RefundReason reason,
    String? description,
  }) async {
    try {
      // トランザクションを取得
      final transaction = await _transactionRepository.getTransactionById(transactionId);
      
      // トランザクションがユーザーのものであることを確認
      if (transaction.userId != userId) {
        throw Exception('このトランザクションに対する返金権限がありません');
      }
      
      // トランザクションが返金可能であることを確認
      if (transaction.status != TransactionStatus.completed) {
        throw Exception('完了していないトランザクションは返金できません');
      }
      
      // 返金額がトランザクション金額以下であることを確認
      if (amount > transaction.amount) {
        throw Exception('返金額はトランザクション金額を超えることはできません');
      }
      
      // 返金リクエストを作成
      final refund = Refund(
        id: 'refund_${DateTime.now().millisecondsSinceEpoch}',
        transactionId: transactionId,
        userId: userId,
        amount: amount,
        reason: reason,
        description: description,
        status: RefundStatus.requested,
        requestedAt: DateTime.now(),
      );
      
      // 返金リクエストを保存
      final savedRefund = await _refundRepository.createRefundRequest(refund);
      
      // 管理者に通知
      // 実際の実装では管理者通知システムを使用
      debugPrint('新しい返金リクエスト: ${savedRefund.toJson()}');
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: userId,
        title: '返金リクエストを受け付けました',
        body: '返金リクエストを受け付けました。審査後に結果をお知らせします。',
        data: {'refundId': savedRefund.id},
      );
      
      return savedRefund;
    } catch (e) {
      debugPrint('返金リクエスト作成エラー: $e');
      rethrow;
    }
  }
  
  /// 返金リクエストを承認する
  Future<Refund> approveRefund(String refundId, String adminId) async {
    try {
      // 返金リクエストを取得
      final refund = await _refundRepository.getRefundById(refundId);
      
      // すでに処理済みの場合はエラー
      if (refund.status != RefundStatus.requested && refund.status != RefundStatus.underReview) {
        throw Exception('すでに処理済みの返金リクエストです');
      }
      
      // 返金ステータスを承認済みに更新
      final approvedRefund = await _refundRepository.updateRefundStatus(
        refundId,
        RefundStatus.approved,
        approvedBy: adminId,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: refund.userId,
        title: '返金リクエストが承認されました',
        body: '返金リクエストが承認されました。返金処理を開始します。',
        data: {'refundId': refund.id},
      );
      
      // 返金処理を実行
      return await processRefund(refundId);
    } catch (e) {
      debugPrint('返金承認エラー: $e');
      rethrow;
    }
  }
  
  /// 返金リクエストを拒否する
  Future<Refund> rejectRefund(String refundId, String adminId, String reason) async {
    try {
      // 返金リクエストを取得
      final refund = await _refundRepository.getRefundById(refundId);
      
      // すでに処理済みの場合はエラー
      if (refund.status != RefundStatus.requested && refund.status != RefundStatus.underReview) {
        throw Exception('すでに処理済みの返金リクエストです');
      }
      
      // 返金ステータスを拒否に更新
      final rejectedRefund = await _refundRepository.updateRefundStatus(
        refundId,
        RefundStatus.rejected,
        approvedBy: adminId,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: refund.userId,
        title: '返金リクエストが拒否されました',
        body: '返金リクエストが拒否されました。理由: $reason',
        data: {'refundId': refund.id},
      );
      
      return rejectedRefund;
    } catch (e) {
      debugPrint('返金拒否エラー: $e');
      rethrow;
    }
  }
  
  /// 返金処理を実行する
  Future<Refund> processRefund(String refundId) async {
    try {
      // 返金リクエストを取得
      final refund = await _refundRepository.getRefundById(refundId);
      
      // 承認済みの場合のみ処理
      if (refund.status != RefundStatus.approved) {
        throw Exception('承認されていない返金リクエストは処理できません');
      }
      
      // トランザクションを取得
      final transaction = await _transactionRepository.getTransactionById(refund.transactionId);
      
      // 決済プロセッサーで返金処理を実行
      try {
        final processorType = PaymentProcessorType.values.firstWhere(
          (type) => transaction.metadata?['processorType'] == type.toString(),
          orElse: () => PaymentProcessorType.stripe, // デフォルト
        );
        
        final processor = _getPaymentProcessor(processorType);
        
        final processorTransactionId = transaction.metadata?['processorTransactionId'];
        if (processorTransactionId == null) {
          throw Exception('プロセッサートランザクションIDが見つかりません');
        }
        
        // プロセッサーで返金処理
        final result = await processor.processRefund(
          paymentId: processorTransactionId,
          amount: refund.amount,
          reason: refund.description,
        );
        
        // 返金ステータスを処理済みに更新
        final processedRefund = await _refundRepository.updateRefundStatus(
          refundId,
          RefundStatus.processed,
          processedAt: DateTime.now(),
        );
        
        // トランザクションのステータスを返金済みに更新
        final refundedTransaction = transaction.copyWith(
          status: TransactionStatus.refunded,
          metadata: {
            ...transaction.metadata ?? {},
            'refundId': refund.id,
            'refundAmount': refund.amount,
            'refundDate': DateTime.now().toIso8601String(),
          },
          updatedAt: DateTime.now(),
        );
        
        await _transactionRepository.saveTransaction(refundedTransaction);
        
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: refund.userId,
          title: '返金処理が完了しました',
          body: '${refund.amount}円の返金処理が完了しました。',
          data: {'refundId': refund.id},
        );
        
        return processedRefund;
      } catch (e) {
        // 返金処理に失敗した場合
        final failedRefund = await _refundRepository.updateRefundStatus(
          refundId,
          RefundStatus.failed,
          processedAt: DateTime.now(),
        );
        
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: refund.userId,
          title: '返金処理に失敗しました',
          body: '返金処理に失敗しました。サポートにお問い合わせください。',
          data: {'refundId': refund.id},
        );
        
        throw Exception('返金処理に失敗しました: $e');
      }
    } catch (e) {
      debugPrint('返金処理エラー: $e');
      rethrow;
    }
  }
  
  /// 返金状態を確認する
  Future<RefundStatus> checkRefundStatus(String refundId) async {
    try {
      final refund = await _refundRepository.getRefundById(refundId);
      return refund.status;
    } catch (e) {
      debugPrint('返金状態確認エラー: $e');
      rethrow;
    }
  }
  
  /// 保留中の返金リクエストを取得する
  Future<List<Refund>> getPendingRefunds() async {
    try {
      return await _refundRepository.getPendingRefunds();
    } catch (e) {
      debugPrint('保留中返金リクエスト取得エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーの返金履歴を取得する
  Future<List<Refund>> getUserRefundHistory(String userId) async {
    try {
      return await _refundRepository.getRefundsForUser(userId);
    } catch (e) {
      debugPrint('ユーザー返金履歴取得エラー: $e');
      rethrow;
    }
  }
  
  /// 決済プロセッサーを取得する（実際の実装ではDIコンテナから取得）
  PaymentProcessor _getPaymentProcessor(PaymentProcessorType type) {
    // 実際の実装ではDIコンテナから取得
    throw UnimplementedError('この実装はモックです。実際の実装では適切な決済プロセッサーを返す必要があります。');
  }
}

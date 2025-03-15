import 'package:flutter/foundation.dart';
import 'user_model.dart';

/// トランザクションモデルクラス
class TransactionModel {
  /// トランザクションID
  final String id;
  
  /// 送金者のユーザーID
  final String senderId;
  
  /// 受取人のユーザーID
  final String recipientId;
  
  /// トランザクションタイプ
  final TransactionType transactionType;
  
  /// 金額（円）
  final int amount;
  
  /// 手数料（円）
  final int fee;
  
  /// 支払い方法
  final PaymentMethod paymentMethod;
  
  /// トランザクションステータス
  final TransactionStatus status;
  
  /// 説明
  final String? description;
  
  /// メタデータ
  final Map<String, dynamic>? metadata;
  
  /// 関連コンテンツID
  final String? relatedContentId;
  
  /// 支払い日時
  final DateTime paymentDate;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// 更新日時
  final DateTime updatedAt;
  
  /// コンストラクタ
  TransactionModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.transactionType,
    required this.amount,
    required this.fee,
    required this.paymentMethod,
    required this.status,
    this.description,
    this.metadata,
    this.relatedContentId,
    required this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// JSONからTransactionModelを作成
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      transactionType: TransactionType.values.firstWhere(
        (type) => type.toString().split('.').last == json['transaction_type'],
        orElse: () => TransactionType.donation,
      ),
      amount: json['amount'],
      fee: json['fee'] ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == json['payment_method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: TransactionStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      description: json['description'],
      metadata: json['metadata'],
      relatedContentId: json['related_content_id'],
      paymentDate: DateTime.parse(json['payment_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// TransactionModelをJSONに変換
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'transaction_type': transactionType.toString().split('.').last,
      'amount': amount,
      'fee': fee,
      'payment_method': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'payment_date': paymentDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (description != null) {
      data['description'] = description;
    }
    
    if (metadata != null) {
      data['metadata'] = metadata;
    }
    
    if (relatedContentId != null) {
      data['related_content_id'] = relatedContentId;
    }
    
    return data;
  }
  
  /// TransactionModelをコピーして新しいインスタンスを作成
  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    TransactionType? transactionType,
    int? amount,
    int? fee,
    PaymentMethod? paymentMethod,
    TransactionStatus? status,
    String? description,
    Map<String, dynamic>? metadata,
    String? relatedContentId,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      relatedContentId: relatedContentId ?? this.relatedContentId,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 純額（手数料を引いた金額）
  int get netAmount => amount - fee;
  
  /// トランザクションが成功したかどうか
  bool get isSuccessful => status == TransactionStatus.completed;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TransactionModel &&
        other.id == id &&
        other.senderId == senderId &&
        other.recipientId == recipientId &&
        other.transactionType == transactionType &&
        other.amount == amount &&
        other.fee == fee &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.description == description &&
        mapEquals(other.metadata, metadata) &&
        other.relatedContentId == relatedContentId &&
        other.paymentDate == paymentDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        senderId.hashCode ^
        recipientId.hashCode ^
        transactionType.hashCode ^
        amount.hashCode ^
        fee.hashCode ^
        paymentMethod.hashCode ^
        status.hashCode ^
        description.hashCode ^
        metadata.hashCode ^
        relatedContentId.hashCode ^
        paymentDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'TransactionModel(id: $id, senderId: $senderId, recipientId: $recipientId, transactionType: $transactionType, amount: $amount, status: $status)';
  }
}

/// トランザクションタイプ
enum TransactionType {
  /// サブスクリプション支払い
  subscription,
  
  /// 投げ銭
  donation,
  
  /// リクエスト料金
  request,
  
  /// 投票ポイント購入
  votingPoints,
  
  /// アフィリエイト収益
  affiliate,
  
  /// その他
  other,
}

/// 支払い方法
enum PaymentMethod {
  /// クレジットカード
  creditCard,
  
  /// デビットカード
  debitCard,
  
  /// PayPal
  paypal,
  
  /// Apple Pay
  applePay,
  
  /// Google Pay
  googlePay,
  
  /// 銀行振込
  bankTransfer,
  
  /// ポイント
  points,
  
  /// その他
  other,
}

/// トランザクションステータス
enum TransactionStatus {
  /// 保留中
  pending,
  
  /// 処理中
  processing,
  
  /// 完了
  completed,
  
  /// 失敗
  failed,
  
  /// 返金
  refunded,
  
  /// キャンセル
  cancelled,
}

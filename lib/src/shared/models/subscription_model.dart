import 'package:flutter/foundation.dart';
import 'user_model.dart';

/// サブスクリプションモデルクラス
class SubscriptionModel {
  /// サブスクリプションID
  final String id;
  
  /// ファンのユーザーID
  final String fanId;
  
  /// スターのユーザーID
  final String starId;
  
  /// サブスクリプションプラン
  final SubscriptionPlan plan;
  
  /// サブスクリプション価格（円）
  final int price;
  
  /// 開始日時
  final DateTime startDate;
  
  /// 終了日時
  final DateTime? endDate;
  
  /// 自動更新するかどうか
  final bool autoRenew;
  
  /// 支払い状態
  final PaymentStatus paymentStatus;
  
  /// 最終支払い日時
  final DateTime? lastPaymentDate;
  
  /// 次回支払い日時
  final DateTime? nextPaymentDate;
  
  /// キャンセル日時
  final DateTime? cancelledAt;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// 更新日時
  final DateTime updatedAt;
  
  /// コンストラクタ
  SubscriptionModel({
    required this.id,
    required this.fanId,
    required this.starId,
    required this.plan,
    required this.price,
    required this.startDate,
    this.endDate,
    required this.autoRenew,
    required this.paymentStatus,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// JSONからSubscriptionModelを作成
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      fanId: json['fan_id'],
      starId: json['star_id'],
      plan: SubscriptionPlan.values.firstWhere(
        (plan) => plan.toString().split('.').last == json['plan'],
        orElse: () => SubscriptionPlan.none,
      ),
      price: json['price'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      autoRenew: json['auto_renew'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      lastPaymentDate: json['last_payment_date'] != null
          ? DateTime.parse(json['last_payment_date'])
          : null,
      nextPaymentDate: json['next_payment_date'] != null
          ? DateTime.parse(json['next_payment_date'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// SubscriptionModelをJSONに変換
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'fan_id': fanId,
      'star_id': starId,
      'plan': plan.toString().split('.').last,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'auto_renew': autoRenew,
      'payment_status': paymentStatus.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (endDate != null) {
      data['end_date'] = endDate!.toIso8601String();
    }
    
    if (lastPaymentDate != null) {
      data['last_payment_date'] = lastPaymentDate!.toIso8601String();
    }
    
    if (nextPaymentDate != null) {
      data['next_payment_date'] = nextPaymentDate!.toIso8601String();
    }
    
    if (cancelledAt != null) {
      data['cancelled_at'] = cancelledAt!.toIso8601String();
    }
    
    return data;
  }
  
  /// SubscriptionModelをコピーして新しいインスタンスを作成
  SubscriptionModel copyWith({
    String? id,
    String? fanId,
    String? starId,
    SubscriptionPlan? plan,
    int? price,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    PaymentStatus? paymentStatus,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      fanId: fanId ?? this.fanId,
      starId: starId ?? this.starId,
      plan: plan ?? this.plan,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// サブスクリプションがアクティブかどうか
  bool get isActive {
    if (paymentStatus != PaymentStatus.active) {
      return false;
    }
    
    if (endDate != null && DateTime.now().isAfter(endDate!)) {
      return false;
    }
    
    if (cancelledAt != null) {
      return false;
    }
    
    return true;
  }
  
  /// サブスクリプションの残り日数
  int get remainingDays {
    if (endDate == null) {
      return 0;
    }
    
    final difference = endDate!.difference(DateTime.now());
    return difference.inDays < 0 ? 0 : difference.inDays;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SubscriptionModel &&
        other.id == id &&
        other.fanId == fanId &&
        other.starId == starId &&
        other.plan == plan &&
        other.price == price &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.autoRenew == autoRenew &&
        other.paymentStatus == paymentStatus &&
        other.lastPaymentDate == lastPaymentDate &&
        other.nextPaymentDate == nextPaymentDate &&
        other.cancelledAt == cancelledAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        fanId.hashCode ^
        starId.hashCode ^
        plan.hashCode ^
        price.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        autoRenew.hashCode ^
        paymentStatus.hashCode ^
        lastPaymentDate.hashCode ^
        nextPaymentDate.hashCode ^
        cancelledAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'SubscriptionModel(id: $id, fanId: $fanId, starId: $starId, plan: $plan, isActive: $isActive)';
  }
}

/// 支払い状態
enum PaymentStatus {
  /// 保留中
  pending,
  
  /// アクティブ
  active,
  
  /// 失敗
  failed,
  
  /// キャンセル
  cancelled,
  
  /// 期限切れ
  expired,
}

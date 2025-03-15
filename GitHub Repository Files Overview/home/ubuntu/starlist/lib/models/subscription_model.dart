class SubscriptionModel {
  final String id;
  final String userId;
  final String starId;
  final String planId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double amount;
  final String currency;
  final String paymentMethod;
  final bool autoRenew;
  final Map<String, dynamic>? metadata;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.starId,
    required this.planId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.autoRenew = true,
    this.metadata,
  });

  // Supabaseからの変換メソッド
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      userId: map['user_id'],
      starId: map['star_id'],
      planId: map['plan_id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      status: map['status'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      paymentMethod: map['payment_method'],
      autoRenew: map['auto_renew'] ?? true,
      metadata: map['metadata'],
    );
  }

  // Supabaseへの変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'star_id': starId,
      'plan_id': planId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'auto_renew': autoRenew,
      'metadata': metadata,
    };
  }

  // コピーメソッド
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? starId,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? amount,
    String? currency,
    String? paymentMethod,
    bool? autoRenew,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      starId: starId ?? this.starId,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      autoRenew: autoRenew ?? this.autoRenew,
      metadata: metadata ?? this.metadata,
    );
  }

  // サブスクリプションが有効かどうかを確認するメソッド
  bool isActive() {
    return status == 'active' && (endDate == null || endDate!.isAfter(DateTime.now()));
  }
}

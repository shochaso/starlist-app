/// サブスクリプションプラン種別を表すenum
enum SubscriptionPlanType {
  /// 無料プラン
  free,
  
  /// ライトプラン（980円/月）
  light,
  
  /// スタンダードプラン（1,980円/月）
  standard,
  
  /// プレミアムプラン（2,980円/月）
  premium,
}

/// サブスクリプションステータスを表すenum
enum SubscriptionStatus {
  /// アクティブ
  active,
  
  /// キャンセル済み
  canceled,
  
  /// 期限切れ
  expired,
  
  /// 保留中
  pending,
}

/// 支払い方法を表すenum
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
  
  /// キャリア決済
  carrierBilling,
}

/// サブスクリプションを表すクラス
class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlanType planType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAutoRenew;
  final double price;
  final SubscriptionStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime? lastBillingDate;
  final DateTime? nextBillingDate;
  final double? discountRate;
  final String? discountReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.isAutoRenew,
    required this.price,
    required this.status,
    this.paymentMethod,
    this.lastBillingDate,
    this.nextBillingDate,
    this.discountRate,
    this.discountReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからSubscriptionを生成するファクトリメソッド
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      planType: SubscriptionPlanType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionPlanType.${json['planType']}',
        orElse: () => SubscriptionPlanType.free,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isAutoRenew: json['isAutoRenew'] ?? false,
      price: json['price'] ?? 0.0,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == 'SubscriptionStatus.${json['status']}',
        orElse: () => SubscriptionStatus.expired,
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
              orElse: () => PaymentMethod.creditCard,
            )
          : null,
      lastBillingDate: json['lastBillingDate'] != null
          ? DateTime.parse(json['lastBillingDate'])
          : null,
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'])
          : null,
      discountRate: json['discountRate'],
      discountReason: json['discountReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// SubscriptionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planType': planType.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isAutoRenew': isAutoRenew,
      'price': price,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'lastBillingDate': lastBillingDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'discountRate': discountRate,
      'discountReason': discountReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlanType? planType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAutoRenew,
    double? price,
    SubscriptionStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? lastBillingDate,
    DateTime? nextBillingDate,
    double? discountRate,
    String? discountReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAutoRenew: isAutoRenew ?? this.isAutoRenew,
      price: price ?? this.price,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      lastBillingDate: lastBillingDate ?? this.lastBillingDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      discountRate: discountRate ?? this.discountRate,
      discountReason: discountReason ?? this.discountReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// サブスクリプションがアクティブかどうかを判定するメソッド
  bool isActive() {
    final now = DateTime.now();
    return status == SubscriptionStatus.active && 
           now.isAfter(startDate) && 
           now.isBefore(endDate);
  }

  /// 有効期限までの日数を計算するメソッド
  int daysUntilExpiration() {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// 月額料金を計算するメソッド（割引を考慮）
  double calculateMonthlyPrice() {
    if (discountRate != null) {
      return price * (1 - discountRate!);
    }
    return price;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription &&
        other.id == id &&
        other.userId == userId &&
        other.planType == planType &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isAutoRenew == isAutoRenew &&
        other.price == price &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.lastBillingDate == lastBillingDate &&
        other.nextBillingDate == nextBillingDate &&
        other.discountRate == discountRate &&
        other.discountReason == discountReason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        planType,
        startDate,
        endDate,
        isAutoRenew,
        price,
        status,
        paymentMethod,
        lastBillingDate,
        nextBillingDate,
        discountRate,
        discountReason,
        createdAt,
        updatedAt,
      );
}

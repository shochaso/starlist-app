enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  failed,
}

class SubscriptionStatusModel {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final String? paymentMethodId;
  final Map<String, dynamic> metadata;

  SubscriptionStatusModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.paymentMethodId,
    this.metadata = const {},
  });

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      id: json["id"] as String,
      userId: json["userId"] as String,
      planId: json["planId"] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == "SubscriptionStatus.${json["status"]}",
        orElse: () => SubscriptionStatus.pending,
      ),
      startDate: DateTime.parse(json["startDate"] as String),
      endDate: json["endDate"] != null
          ? DateTime.parse(json["endDate"] as String)
          : null,
      nextBillingDate: json["nextBillingDate"] != null
          ? DateTime.parse(json["nextBillingDate"] as String)
          : null,
      paymentMethodId: json["paymentMethodId"] as String?,
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "planId": planId,
      "status": status.toString().split(".").last,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "nextBillingDate": nextBillingDate?.toIso8601String(),
      "paymentMethodId": paymentMethodId,
      "metadata": metadata,
    };
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCanceled => status == SubscriptionStatus.canceled;
  bool get isPending => status == SubscriptionStatus.pending;
  bool get isFailed => status == SubscriptionStatus.failed;
}

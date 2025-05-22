enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
  canceled,
}

enum PaymentMethod {
  creditCard,
  bankTransfer,
  paypal,
  applePay,
  googlePay,
}

class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final Map<String, dynamic> metadata;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.metadata = const {},
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["id"] as String,
      userId: json["userId"] as String,
      amount: (json["amount"] as num).toDouble(),
      currency: json["currency"] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == "PaymentStatus.${json["status"]}",
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == "PaymentMethod.${json["method"]}",
        orElse: () => PaymentMethod.creditCard,
      ),
      createdAt: DateTime.parse(json["createdAt"] as String),
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"] as String)
          : null,
      transactionId: json["transactionId"] as String?,
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "amount": amount,
      "currency": currency,
      "status": status.toString().split(".").last,
      "method": method.toString().split(".").last,
      "createdAt": createdAt.toIso8601String(),
      "completedAt": completedAt?.toIso8601String(),
      "transactionId": transactionId,
      "metadata": metadata,
    };
  }

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isRefunded => status == PaymentStatus.refunded;
  bool get isCanceled => status == PaymentStatus.canceled;
}

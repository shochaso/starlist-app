class TransactionModel {
  final String id;
  final String userId;
  final String? starId;
  final String transactionType;
  final DateTime transactionDate;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? subscriptionId;
  final String? description;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.userId,
    this.starId,
    required this.transactionType,
    required this.transactionDate,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.subscriptionId,
    this.description,
    this.metadata,
  });

  // Supabaseからの変換メソッド
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['user_id'],
      starId: map['star_id'],
      transactionType: map['transaction_type'],
      transactionDate: DateTime.parse(map['transaction_date']),
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      status: map['status'],
      paymentMethod: map['payment_method'],
      subscriptionId: map['subscription_id'],
      description: map['description'],
      metadata: map['metadata'],
    );
  }

  // Supabaseへの変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'star_id': starId,
      'transaction_type': transactionType,
      'transaction_date': transactionDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'subscription_id': subscriptionId,
      'description': description,
      'metadata': metadata,
    };
  }

  // コピーメソッド
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? starId,
    String? transactionType,
    DateTime? transactionDate,
    double? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? subscriptionId,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      starId: starId ?? this.starId,
      transactionType: transactionType ?? this.transactionType,
      transactionDate: transactionDate ?? this.transactionDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  // 取引が成功したかどうかを確認するメソッド
  bool isSuccessful() {
    return status == 'completed' || status == 'success';
  }

  // 取引が返金されたかどうかを確認するメソッド
  bool isRefunded() {
    return status == 'refunded';
  }
}

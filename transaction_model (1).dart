/// トランザクション種別を表すenum
enum TransactionType {
  /// サブスクリプション支払い
  subscription,
  
  /// チケット購入
  ticket,
  
  /// 投げ銭
  donation,
  
  /// 返金
  refund,
}

/// トランザクションステータスを表すenum
enum TransactionStatus {
  /// 保留中
  pending,
  
  /// 完了
  completed,
  
  /// 失敗
  failed,
  
  /// 返金済み
  refunded,
}

/// トランザクションを表すクラス
class Transaction {
  final String id;
  final String userId;
  final String? targetId;
  final double amount;
  final String currency;
  final TransactionType type;
  final TransactionStatus status;
  final String paymentMethod;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    this.targetId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.description,
    this.metadata,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからTransactionを生成するファクトリメソッド
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      targetId: json['targetId'],
      amount: json['amount'],
      currency: json['currency'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.subscription,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
        orElse: () => TransactionStatus.pending,
      ),
      paymentMethod: json['paymentMethod'],
      description: json['description'],
      metadata: json['metadata'],
      receiptUrl: json['receiptUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// TransactionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetId': targetId,
      'amount': amount,
      'currency': currency,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'description': description,
      'metadata': metadata,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  Transaction copyWith({
    String? id,
    String? userId,
    String? targetId,
    double? amount,
    String? currency,
    TransactionType? type,
    TransactionStatus? status,
    String? paymentMethod,
    String? description,
    Map<String, dynamic>? metadata,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// トランザクションが成功したかどうかを判定するメソッド
  bool isSuccessful() {
    return status == TransactionStatus.completed;
  }

  /// フォーマットされた金額を取得するメソッド
  String getFormattedAmount() {
    // 通貨記号のマッピング
    final currencySymbols = {
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    final symbol = currencySymbols[currency] ?? currency;
    
    // 小数点以下の処理
    String formattedAmount;
    if (currency == 'JPY') {
      // 日本円は小数点以下なし
      formattedAmount = amount.toInt().toString();
    } else {
      // その他の通貨は小数点以下2桁
      formattedAmount = amount.toStringAsFixed(2);
    }
    
    // 3桁ごとにカンマを挿入
    final parts = formattedAmount.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    if (parts.length > 1) {
      return '$symbol$integerPart.${parts[1]}';
    } else {
      return '$symbol$integerPart';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.userId == userId &&
        other.targetId == targetId &&
        other.amount == amount &&
        other.currency == currency &&
        other.type == type &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.description == description &&
        other.receiptUrl == receiptUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        targetId,
        amount,
        currency,
        type,
        status,
        paymentMethod,
        description,
        receiptUrl,
        createdAt,
        updatedAt,
      );
}

class SubscriptionHistoryModel {
  final String id;
  final String userId;
  final String planId;
  final String action;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  SubscriptionHistoryModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.action,
    required this.createdAt,
    this.metadata = const {},
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String,
      planId: json['plan_id'] as String? ?? json['planId'] as String,
      action: json['action'] as String,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? json['createdAt'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'action': action,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

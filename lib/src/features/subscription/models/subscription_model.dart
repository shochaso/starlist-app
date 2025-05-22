enum SubscriptionStatus {
  active,
  canceled,
  expired,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String starId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.starId,
    required this.planId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.autoRenew = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json["id"] as String,
      userId: json["user_id"] as String,
      starId: json["star_id"] as String,
      planId: json["plan_id"] as String,
      status: _statusFromString(json["status"] as String),
      startDate: DateTime.parse(json["start_date"] as String),
      endDate: json["end_date"] != null ? DateTime.parse(json["end_date"] as String) : null,
      autoRenew: json["auto_renew"] as bool? ?? true,
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "star_id": starId,
      "plan_id": planId,
      "status": status.toString().split(".").last,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate?.toIso8601String(),
      "auto_renew": autoRenew,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  static SubscriptionStatus _statusFromString(String status) {
    try {
      return SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
      );
    } catch (_) {
      return SubscriptionStatus.expired;
    }
  }
} 
enum SubscriptionInterval {
  monthly,
  yearly,
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final SubscriptionInterval interval;
  final Map<String, dynamic> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'JPY',
    required this.interval,
    this.features = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json["id"] as String,
      name: json["name"] as String,
      description: json["description"] as String?,
      price: (json["price"] as num).toDouble(),
      currency: json["currency"] as String? ?? "JPY",
      interval: _intervalFromString(json["interval"] as String),
      features: (json["features"] as Map<String, dynamic>?) ?? {},
      isActive: json["is_active"] as bool? ?? true,
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "currency": currency,
      "interval": interval.toString().split(".").last,
      "features": features,
      "is_active": isActive,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  static SubscriptionInterval _intervalFromString(String interval) {
    try {
      return SubscriptionInterval.values.firstWhere(
        (e) => e.toString().split('.').last == interval,
      );
    } catch (_) {
      return SubscriptionInterval.monthly;
    }
  }
} 
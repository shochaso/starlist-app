class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final Duration billingPeriod;
  final List<String> features;
  final bool isPopular;
  final Map<String, dynamic> metadata;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.features,
    this.isPopular = false,
    this.metadata = const {},
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json["id"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      price: (json["price"] as num).toDouble(),
      currency: json["currency"] as String,
      billingPeriod: Duration(days: json["billingPeriodDays"] as int),
      features: List<String>.from(json["features"] as List),
      isPopular: json["isPopular"] as bool? ?? false,
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "currency": currency,
      "billingPeriodDays": billingPeriod.inDays,
      "features": features,
      "isPopular": isPopular,
      "metadata": metadata,
    };
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    Duration? billingPeriod,
    List<String>? features,
    bool? isPopular,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum StarCategory {
  entertainer,
  athlete,
  creator,
  vtuber,
  musician,
  actor,
  other,
}

enum StarRank {
  regular,
  platinum,
  supreme,
}

class StarProfileModel {
  final String id;
  final String userId;
  final StarCategory category;
  final String? description;
  final int paidFollowerCount;
  final StarRank starRank;
  final double revenueShareRate;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  StarProfileModel({
    required this.id,
    required this.userId,
    required this.category,
    this.description,
    this.paidFollowerCount = 0,
    this.starRank = StarRank.regular,
    this.revenueShareRate = 80.0,
    this.verified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StarProfileModel.fromJson(Map<String, dynamic> json) {
    return StarProfileModel(
      id: json["id"] as String,
      userId: json["user_id"] as String,
      category: _categoryFromString(json["category"] as String),
      description: json["description"] as String?,
      paidFollowerCount: json["paid_follower_count"] as int? ?? 0,
      starRank: _rankFromString(json["star_rank"] as String? ?? "regular"),
      revenueShareRate: (json["revenue_share_rate"] as num?)?.toDouble() ?? 80.0,
      verified: json["verified"] as bool? ?? false,
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "category": category.toString().split(".").last,
      "description": description,
      "paid_follower_count": paidFollowerCount,
      "star_rank": starRank.toString().split(".").last,
      "revenue_share_rate": revenueShareRate,
      "verified": verified,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  static StarCategory _categoryFromString(String category) {
    try {
      return StarCategory.values.firstWhere(
        (e) => e.toString().split('.').last == category,
      );
    } catch (_) {
      return StarCategory.other;
    }
  }

  static StarRank _rankFromString(String rank) {
    try {
      return StarRank.values.firstWhere(
        (e) => e.toString().split('.').last == rank,
      );
    } catch (_) {
      return StarRank.regular;
    }
  }
} 
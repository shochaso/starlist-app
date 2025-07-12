enum UserType {
  star,
  fan,
}

enum FanPlanType {
  free,       // 無料ファン
  light,      // ライトプラン
  standard,   // スタンダードプラン
  premium,    // プレミアムプラン
}

class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final FanPlanType? fanPlanType; // ファンの場合のプランタイプ
  final String? profileImageUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.fanPlanType,
    this.profileImageUrl,
    this.platforms,
    this.genres,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${json['type']}',
      ),
      fanPlanType: json['fanPlanType'] != null
          ? FanPlanType.values.firstWhere(
              (e) => e.toString() == 'FanPlanType.${json['fanPlanType']}',
            )
          : null,
      profileImageUrl: json['profileImageUrl'],
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'])
          : null,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'fanPlanType': fanPlanType?.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
      'platforms': platforms,
      'genres': genres,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // 権限チェックメソッド
  bool get isStar => type == UserType.star;
  bool get isFan => type == UserType.fan;
  bool get isFreeFan => type == UserType.fan && fanPlanType == FanPlanType.free;
  bool get isLightPlan => type == UserType.fan && fanPlanType == FanPlanType.light;
  bool get isStandardPlan => type == UserType.fan && fanPlanType == FanPlanType.standard;
  bool get isPremiumPlan => type == UserType.fan && fanPlanType == FanPlanType.premium;
  
  // プラン表示名取得
  String get planDisplayName {
    if (isStar) return 'スター';
    switch (fanPlanType) {
      case FanPlanType.free:
        return '無料ファン';
      case FanPlanType.light:
        return 'ライトプラン';
      case FanPlanType.standard:
        return 'スタンダードプラン';
      case FanPlanType.premium:
        return 'プレミアムプラン';
      default:
        return 'ファン';
    }
  }
} 
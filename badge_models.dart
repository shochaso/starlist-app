import 'package:flutter/material.dart';

/// バッジタイプの列挙型
enum BadgeType {
  bronze,
  silver,
  gold,
  loyal,
  custom
}

/// バッジモデルクラス
class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final String iconPath;
  final Color color;
  final DateTime? awardedAt;
  final Map<String, dynamic>? criteria;
  final bool isVisible;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.iconPath,
    required this.color,
    this.awardedAt,
    this.criteria,
    this.isVisible = true,
  });

  /// JSONからバッジを作成するファクトリメソッド
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: _badgeTypeFromString(json['type']),
      iconPath: json['iconPath'],
      color: _colorFromHex(json['color']),
      awardedAt: json['awardedAt'] != null ? DateTime.parse(json['awardedAt']) : null,
      criteria: json['criteria'],
      isVisible: json['isVisible'] ?? true,
    );
  }

  /// バッジをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'iconPath': iconPath,
      'color': _colorToHex(color),
      'awardedAt': awardedAt?.toIso8601String(),
      'criteria': criteria,
      'isVisible': isVisible,
    };
  }

  /// 文字列からバッジタイプを取得するヘルパーメソッド
  static BadgeType _badgeTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'bronze':
        return BadgeType.bronze;
      case 'silver':
        return BadgeType.silver;
      case 'gold':
        return BadgeType.gold;
      case 'loyal':
        return BadgeType.loyal;
      case 'custom':
        return BadgeType.custom;
      default:
        return BadgeType.bronze;
    }
  }

  /// 16進数の文字列からColorを取得するヘルパーメソッド
  static Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// ColorをHEX文字列に変換するヘルパーメソッド
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  /// バッジのコピーを作成し、指定されたプロパティを更新するメソッド
  Badge copyWith({
    String? id,
    String? name,
    String? description,
    BadgeType? type,
    String? iconPath,
    Color? color,
    DateTime? awardedAt,
    Map<String, dynamic>? criteria,
    bool? isVisible,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      awardedAt: awardedAt ?? this.awardedAt,
      criteria: criteria ?? this.criteria,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// ユーザーバッジコレクションモデル
class UserBadges {
  final String userId;
  final List<Badge> badges;
  final Badge? activeBadge;

  UserBadges({
    required this.userId,
    required this.badges,
    this.activeBadge,
  });

  /// JSONからユーザーバッジコレクションを作成するファクトリメソッド
  factory UserBadges.fromJson(Map<String, dynamic> json) {
    final List<dynamic> badgesList = json['badges'] ?? [];
    final badges = badgesList.map((badgeJson) => Badge.fromJson(badgeJson)).toList();
    
    Badge? activeBadge;
    if (json['activeBadgeId'] != null) {
      activeBadge = badges.firstWhere(
        (badge) => badge.id == json['activeBadgeId'],
        orElse: () => badges.isNotEmpty ? badges.first : null,
      );
    }

    return UserBadges(
      userId: json['userId'],
      badges: badges,
      activeBadge: activeBadge,
    );
  }

  /// ユーザーバッジコレクションをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'badges': badges.map((badge) => badge.toJson()).toList(),
      'activeBadgeId': activeBadge?.id,
    };
  }

  /// 特定のタイプのバッジを取得するメソッド
  List<Badge> getBadgesByType(BadgeType type) {
    return badges.where((badge) => badge.type == type).toList();
  }

  /// バッジを追加するメソッド
  UserBadges addBadge(Badge badge) {
    final updatedBadges = List<Badge>.from(badges);
    updatedBadges.add(badge);
    return UserBadges(
      userId: userId,
      badges: updatedBadges,
      activeBadge: activeBadge,
    );
  }

  /// アクティブバッジを設定するメソッド
  UserBadges setActiveBadge(Badge badge) {
    return UserBadges(
      userId: userId,
      badges: badges,
      activeBadge: badge,
    );
  }

  /// バッジの可視性を更新するメソッド
  UserBadges updateBadgeVisibility(String badgeId, bool isVisible) {
    final updatedBadges = badges.map((badge) {
      if (badge.id == badgeId) {
        return badge.copyWith(isVisible: isVisible);
      }
      return badge;
    }).toList();

    return UserBadges(
      userId: userId,
      badges: updatedBadges,
      activeBadge: activeBadge?.id == badgeId 
          ? updatedBadges.firstWhere((badge) => badge.id == badgeId) 
          : activeBadge,
    );
  }
}

/// ロイヤルファンステータスモデル
class LoyalFanStatus {
  final String userId;
  final String starId;
  final int loyaltyPoints;
  final int consecutiveMonthsSupporting;
  final DateTime memberSince;
  final List<Badge> specialBadges;
  final bool isTopFan;

  LoyalFanStatus({
    required this.userId,
    required this.starId,
    required this.loyaltyPoints,
    required this.consecutiveMonthsSupporting,
    required this.memberSince,
    required this.specialBadges,
    this.isTopFan = false,
  });

  /// JSONからロイヤルファンステータスを作成するファクトリメソッド
  factory LoyalFanStatus.fromJson(Map<String, dynamic> json) {
    final List<dynamic> badgesList = json['specialBadges'] ?? [];
    final specialBadges = badgesList.map((badgeJson) => Badge.fromJson(badgeJson)).toList();

    return LoyalFanStatus(
      userId: json['userId'],
      starId: json['starId'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      consecutiveMonthsSupporting: json['consecutiveMonthsSupporting'] ?? 0,
      memberSince: DateTime.parse(json['memberSince']),
      specialBadges: specialBadges,
      isTopFan: json['isTopFan'] ?? false,
    );
  }

  /// ロイヤルファンステータスをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'starId': starId,
      'loyaltyPoints': loyaltyPoints,
      'consecutiveMonthsSupporting': consecutiveMonthsSupporting,
      'memberSince': memberSince.toIso8601String(),
      'specialBadges': specialBadges.map((badge) => badge.toJson()).toList(),
      'isTopFan': isTopFan,
    };
  }

  /// ロイヤルファンステータスのコピーを作成し、指定されたプロパティを更新するメソッド
  LoyalFanStatus copyWith({
    String? userId,
    String? starId,
    int? loyaltyPoints,
    int? consecutiveMonthsSupporting,
    DateTime? memberSince,
    List<Badge>? specialBadges,
    bool? isTopFan,
  }) {
    return LoyalFanStatus(
      userId: userId ?? this.userId,
      starId: starId ?? this.starId,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      consecutiveMonthsSupporting: consecutiveMonthsSupporting ?? this.consecutiveMonthsSupporting,
      memberSince: memberSince ?? this.memberSince,
      specialBadges: specialBadges ?? this.specialBadges,
      isTopFan: isTopFan ?? this.isTopFan,
    );
  }

  /// ロイヤルティレベルを取得するメソッド
  String getLoyaltyLevel() {
    if (consecutiveMonthsSupporting >= 12 || loyaltyPoints >= 10000) {
      return 'ゴールド';
    } else if (consecutiveMonthsSupporting >= 6 || loyaltyPoints >= 5000) {
      return 'シルバー';
    } else {
      return 'ブロンズ';
    }
  }

  /// ロイヤルティポイントを追加するメソッド
  LoyalFanStatus addLoyaltyPoints(int points) {
    return copyWith(loyaltyPoints: loyaltyPoints + points);
  }
}

/// ファン・スターインタラクションモデル
class Interaction {
  final String id;
  final String userId;
  final String starId;
  final InteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isPublic;

  Interaction({
    required this.id,
    required this.userId,
    required this.starId,
    required this.type,
    required this.timestamp,
    required this.data,
    this.isPublic = true,
  });

  /// JSONからインタラクションを作成するファクトリメソッド
  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'],
      userId: json['userId'],
      starId: json['starId'],
      type: _interactionTypeFromString(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'] ?? {},
      isPublic: json['isPublic'] ?? true,
    );
  }

  /// インタラクションをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'starId': starId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'isPublic': isPublic,
    };
  }

  /// 文字列からインタラクションタイプを取得するヘルパーメソッド
  static InteractionType _interactionTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'comment':
        return InteractionType.comment;
      case 'like':
        return InteractionType.like;
      case 'share':
        return InteractionType.share;
      case 'purchase':
        return InteractionType.purchase;
      case 'donation':
        return InteractionType.donation;
      case 'message':
        return InteractionType.message;
      default:
        return InteractionType.comment;
    }
  }
}

/// インタラクションタイプの列挙型
enum InteractionType {
  comment,
  like,
  share,
  purchase,
  donation,
  message
}

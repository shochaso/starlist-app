import 'package:flutter/foundation.dart';

/// 関係タイプを表すenum
enum RelationshipType {
  /// 無料フォロー
  free,
  
  /// ライトプラン
  light,
  
  /// スタンダードプラン
  standard,
  
  /// プレミアムプラン
  premium,
}

/// チケットタイプを表すenum
enum TicketType {
  /// ブロンズチケット（無料）
  bronze,
  
  /// シルバーチケット（有料）
  silver,
}

/// バッジを表すクラス
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime acquiredAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.acquiredAt,
  });

  /// JSONからBadgeを生成するファクトリメソッド
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      acquiredAt: DateTime.parse(json['acquiredAt']),
    );
  }

  /// BadgeをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'acquiredAt': acquiredAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Badge &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconUrl == iconUrl &&
        other.acquiredAt == acquiredAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        iconUrl,
        acquiredAt,
      );
}

/// ファン-スター関係を表すクラス
class FanStarRelationship {
  final String id;
  final String fanId;
  final String starId;
  final RelationshipType relationshipType;
  final DateTime startDate;
  final DateTime? lastInteractionDate;
  final double totalSpent;
  final Map<String, int> ticketBalance;
  final List<Badge>? badges;
  final String? notes;
  final bool isNotificationEnabled;
  final Map<String, dynamic>? customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  FanStarRelationship({
    required this.id,
    required this.fanId,
    required this.starId,
    required this.relationshipType,
    required this.startDate,
    this.lastInteractionDate,
    this.totalSpent = 0.0,
    required this.ticketBalance,
    this.badges,
    this.notes,
    this.isNotificationEnabled = true,
    this.customSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからFanStarRelationshipを生成するファクトリメソッド
  factory FanStarRelationship.fromJson(Map<String, dynamic> json) {
    return FanStarRelationship(
      id: json['id'],
      fanId: json['fanId'],
      starId: json['starId'],
      relationshipType: RelationshipType.values.firstWhere(
        (e) => e.toString() == 'RelationshipType.${json['relationshipType']}',
        orElse: () => RelationshipType.free,
      ),
      startDate: DateTime.parse(json['startDate']),
      lastInteractionDate: json['lastInteractionDate'] != null
          ? DateTime.parse(json['lastInteractionDate'])
          : null,
      totalSpent: json['totalSpent'] ?? 0.0,
      ticketBalance: json['ticketBalance'] != null
          ? Map<String, int>.from(json['ticketBalance'])
          : {},
      badges: json['badges'] != null
          ? (json['badges'] as List)
              .map((badge) => Badge.fromJson(badge))
              .toList()
          : null,
      notes: json['notes'],
      isNotificationEnabled: json['isNotificationEnabled'] ?? true,
      customSettings: json['customSettings'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// FanStarRelationshipをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fanId': fanId,
      'starId': starId,
      'relationshipType': relationshipType.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'lastInteractionDate': lastInteractionDate?.toIso8601String(),
      'totalSpent': totalSpent,
      'ticketBalance': ticketBalance,
      'badges': badges?.map((badge) => badge.toJson()).toList(),
      'notes': notes,
      'isNotificationEnabled': isNotificationEnabled,
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  FanStarRelationship copyWith({
    String? id,
    String? fanId,
    String? starId,
    RelationshipType? relationshipType,
    DateTime? startDate,
    DateTime? lastInteractionDate,
    double? totalSpent,
    Map<String, int>? ticketBalance,
    List<Badge>? badges,
    String? notes,
    bool? isNotificationEnabled,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FanStarRelationship(
      id: id ?? this.id,
      fanId: fanId ?? this.fanId,
      starId: starId ?? this.starId,
      relationshipType: relationshipType ?? this.relationshipType,
      startDate: startDate ?? this.startDate,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      totalSpent: totalSpent ?? this.totalSpent,
      ticketBalance: ticketBalance ?? this.ticketBalance,
      badges: badges ?? this.badges,
      notes: notes ?? this.notes,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// チケットを追加するメソッド
  void addTickets(String type, int amount) {
    if (ticketBalance.containsKey(type)) {
      ticketBalance[type] = ticketBalance[type]! + amount;
    } else {
      ticketBalance[type] = amount;
    }
  }

  /// チケットを使用するメソッド
  bool useTickets(String type, int amount) {
    if (!ticketBalance.containsKey(type) || ticketBalance[type]! < amount) {
      return false;
    }
    
    ticketBalance[type] = ticketBalance[type]! - amount;
    return true;
  }

  /// 関係の継続期間を取得するメソッド
  Duration getRelationshipDuration() {
    return DateTime.now().difference(startDate);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FanStarRelationship &&
        other.id == id &&
        other.fanId == fanId &&
        other.starId == starId &&
        other.relationshipType == relationshipType &&
        other.startDate == startDate &&
        other.lastInteractionDate == lastInteractionDate &&
        other.totalSpent == totalSpent &&
        mapEquals(other.ticketBalance, ticketBalance) &&
        listEquals(other.badges, badges) &&
        other.notes == notes &&
        other.isNotificationEnabled == isNotificationEnabled &&
        mapEquals(other.customSettings, customSettings) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        fanId,
        starId,
        relationshipType,
        startDate,
        lastInteractionDate,
        totalSpent,
        ticketBalance,
        badges,
        notes,
        isNotificationEnabled,
        customSettings,
        createdAt,
        updatedAt,
      );
}

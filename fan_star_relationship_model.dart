import 'package:flutter/foundation.dart';
import 'user_model.dart';

/// ファン-スター関係モデルクラス
class FanStarRelationshipModel {
  /// 関係ID
  final String id;
  
  /// ファンのユーザーID
  final String fanId;
  
  /// スターのユーザーID
  final String starId;
  
  /// 関係タイプ
  final RelationshipType relationshipType;
  
  /// バッジレベル
  final BadgeLevel badgeLevel;
  
  /// 累計投げ銭金額（円）
  final int totalDonationAmount;
  
  /// フォロー日時
  final DateTime followedAt;
  
  /// VIPルームアクセス権があるかどうか
  final bool hasVipAccess;
  
  /// VIPルームアクセス権の有効期限
  final DateTime? vipAccessExpiresAt;
  
  /// 最終インタラクション日時
  final DateTime? lastInteractionAt;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// 更新日時
  final DateTime updatedAt;
  
  /// コンストラクタ
  FanStarRelationshipModel({
    required this.id,
    required this.fanId,
    required this.starId,
    required this.relationshipType,
    required this.badgeLevel,
    required this.totalDonationAmount,
    required this.followedAt,
    required this.hasVipAccess,
    this.vipAccessExpiresAt,
    this.lastInteractionAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// JSONからFanStarRelationshipModelを作成
  factory FanStarRelationshipModel.fromJson(Map<String, dynamic> json) {
    return FanStarRelationshipModel(
      id: json['id'],
      fanId: json['fan_id'],
      starId: json['star_id'],
      relationshipType: RelationshipType.values.firstWhere(
        (type) => type.toString().split('.').last == json['relationship_type'],
        orElse: () => RelationshipType.follower,
      ),
      badgeLevel: BadgeLevel.values.firstWhere(
        (level) => level.toString().split('.').last == json['badge_level'],
        orElse: () => BadgeLevel.none,
      ),
      totalDonationAmount: json['total_donation_amount'] ?? 0,
      followedAt: DateTime.parse(json['followed_at']),
      hasVipAccess: json['has_vip_access'] ?? false,
      vipAccessExpiresAt: json['vip_access_expires_at'] != null
          ? DateTime.parse(json['vip_access_expires_at'])
          : null,
      lastInteractionAt: json['last_interaction_at'] != null
          ? DateTime.parse(json['last_interaction_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// FanStarRelationshipModelをJSONに変換
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'fan_id': fanId,
      'star_id': starId,
      'relationship_type': relationshipType.toString().split('.').last,
      'badge_level': badgeLevel.toString().split('.').last,
      'total_donation_amount': totalDonationAmount,
      'followed_at': followedAt.toIso8601String(),
      'has_vip_access': hasVipAccess,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (vipAccessExpiresAt != null) {
      data['vip_access_expires_at'] = vipAccessExpiresAt!.toIso8601String();
    }
    
    if (lastInteractionAt != null) {
      data['last_interaction_at'] = lastInteractionAt!.toIso8601String();
    }
    
    return data;
  }
  
  /// FanStarRelationshipModelをコピーして新しいインスタンスを作成
  FanStarRelationshipModel copyWith({
    String? id,
    String? fanId,
    String? starId,
    RelationshipType? relationshipType,
    BadgeLevel? badgeLevel,
    int? totalDonationAmount,
    DateTime? followedAt,
    bool? hasVipAccess,
    DateTime? vipAccessExpiresAt,
    DateTime? lastInteractionAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FanStarRelationshipModel(
      id: id ?? this.id,
      fanId: fanId ?? this.fanId,
      starId: starId ?? this.starId,
      relationshipType: relationshipType ?? this.relationshipType,
      badgeLevel: badgeLevel ?? this.badgeLevel,
      totalDonationAmount: totalDonationAmount ?? this.totalDonationAmount,
      followedAt: followedAt ?? this.followedAt,
      hasVipAccess: hasVipAccess ?? this.hasVipAccess,
      vipAccessExpiresAt: vipAccessExpiresAt ?? this.vipAccessExpiresAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// VIPアクセスが有効かどうか
  bool get isVipAccessActive {
    if (!hasVipAccess) {
      return false;
    }
    
    if (vipAccessExpiresAt != null && DateTime.now().isAfter(vipAccessExpiresAt!)) {
      return false;
    }
    
    return true;
  }
  
  /// フォロー期間（日数）
  int get followDurationInDays {
    final difference = DateTime.now().difference(followedAt);
    return difference.inDays;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FanStarRelationshipModel &&
        other.id == id &&
        other.fanId == fanId &&
        other.starId == starId &&
        other.relationshipType == relationshipType &&
        other.badgeLevel == badgeLevel &&
        other.totalDonationAmount == totalDonationAmount &&
        other.followedAt == followedAt &&
        other.hasVipAccess == hasVipAccess &&
        other.vipAccessExpiresAt == vipAccessExpiresAt &&
        other.lastInteractionAt == lastInteractionAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        fanId.hashCode ^
        starId.hashCode ^
        relationshipType.hashCode ^
        badgeLevel.hashCode ^
        totalDonationAmount.hashCode ^
        followedAt.hashCode ^
        hasVipAccess.hashCode ^
        vipAccessExpiresAt.hashCode ^
        lastInteractionAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'FanStarRelationshipModel(id: $id, fanId: $fanId, starId: $starId, relationshipType: $relationshipType, badgeLevel: $badgeLevel)';
  }
}

/// 関係タイプ
enum RelationshipType {
  /// フォロワー
  follower,
  
  /// サポーター（投げ銭あり）
  supporter,
  
  /// VIPメンバー
  vipMember,
}

/// バッジレベル
enum BadgeLevel {
  /// なし
  none,
  
  /// ブロンズ
  bronze,
  
  /// シルバー
  silver,
  
  /// ゴールド
  gold,
}

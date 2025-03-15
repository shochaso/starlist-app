import 'package:flutter/foundation.dart';

/// ユーザーモデルクラス
class UserModel {
  /// ユーザーID
  final String id;
  
  /// メールアドレス
  final String email;
  
  /// ユーザー名
  final String username;
  
  /// 表示名
  final String displayName;
  
  /// プロフィール画像URL
  final String? profileImageUrl;
  
  /// バナー画像URL
  final String? bannerImageUrl;
  
  /// 自己紹介
  final String? bio;
  
  /// ユーザータイプ（スターまたはファン）
  final UserType userType;
  
  /// スター認証済みかどうか
  final bool isVerifiedStar;
  
  /// フォロワー数
  final int followerCount;
  
  /// フォロー数
  final int followingCount;
  
  /// SNSリンク
  final Map<SocialMediaType, String>? socialMediaLinks;
  
  /// スタータイプ（YouTuber、VTuberなど）
  final StarType? starType;
  
  /// サブスクリプションプラン
  final SubscriptionPlan? subscriptionPlan;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// 更新日時
  final DateTime updatedAt;
  
  /// コンストラクタ
  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.bio,
    required this.userType,
    this.isVerifiedStar = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.socialMediaLinks,
    this.starType,
    this.subscriptionPlan,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// JSONからUserModelを作成
  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<SocialMediaType, String>? socialLinks;
    if (json['social_media_links'] != null) {
      socialLinks = {};
      (json['social_media_links'] as Map<String, dynamic>).forEach((key, value) {
        final socialType = SocialMediaType.values.firstWhere(
          (type) => type.toString().split('.').last == key,
          orElse: () => SocialMediaType.other,
        );
        socialLinks![socialType] = value;
      });
    }
    
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      profileImageUrl: json['profile_image_url'],
      bannerImageUrl: json['banner_image_url'],
      bio: json['bio'],
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['user_type'],
        orElse: () => UserType.fan,
      ),
      isVerifiedStar: json['is_verified_star'] ?? false,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      socialMediaLinks: socialLinks,
      starType: json['star_type'] != null
          ? StarType.values.firstWhere(
              (type) => type.toString().split('.').last == json['star_type'],
              orElse: () => StarType.other,
            )
          : null,
      subscriptionPlan: json['subscription_plan'] != null
          ? SubscriptionPlan.values.firstWhere(
              (plan) => plan.toString().split('.').last == json['subscription_plan'],
              orElse: () => SubscriptionPlan.none,
            )
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// UserModelをJSONに変換
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'profile_image_url': profileImageUrl,
      'banner_image_url': bannerImageUrl,
      'bio': bio,
      'user_type': userType.toString().split('.').last,
      'is_verified_star': isVerifiedStar,
      'follower_count': followerCount,
      'following_count': followingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (socialMediaLinks != null) {
      data['social_media_links'] = {};
      socialMediaLinks!.forEach((key, value) {
        data['social_media_links'][key.toString().split('.').last] = value;
      });
    }
    
    if (starType != null) {
      data['star_type'] = starType.toString().split('.').last;
    }
    
    if (subscriptionPlan != null) {
      data['subscription_plan'] = subscriptionPlan.toString().split('.').last;
    }
    
    return data;
  }
  
  /// UserModelをコピーして新しいインスタンスを作成
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
    UserType? userType,
    bool? isVerifiedStar,
    int? followerCount,
    int? followingCount,
    Map<SocialMediaType, String>? socialMediaLinks,
    StarType? starType,
    SubscriptionPlan? subscriptionPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      bio: bio ?? this.bio,
      userType: userType ?? this.userType,
      isVerifiedStar: isVerifiedStar ?? this.isVerifiedStar,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      starType: starType ?? this.starType,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.displayName == displayName &&
        other.profileImageUrl == profileImageUrl &&
        other.bannerImageUrl == bannerImageUrl &&
        other.bio == bio &&
        other.userType == userType &&
        other.isVerifiedStar == isVerifiedStar &&
        other.followerCount == followerCount &&
        other.followingCount == followingCount &&
        mapEquals(other.socialMediaLinks, socialMediaLinks) &&
        other.starType == starType &&
        other.subscriptionPlan == subscriptionPlan &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        displayName.hashCode ^
        profileImageUrl.hashCode ^
        bannerImageUrl.hashCode ^
        bio.hashCode ^
        userType.hashCode ^
        isVerifiedStar.hashCode ^
        followerCount.hashCode ^
        followingCount.hashCode ^
        socialMediaLinks.hashCode ^
        starType.hashCode ^
        subscriptionPlan.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, displayName: $displayName, userType: $userType, isVerifiedStar: $isVerifiedStar)';
  }
}

/// ユーザータイプ
enum UserType {
  /// スター（コンテンツ提供者）
  star,
  
  /// ファン（コンテンツ消費者）
  fan,
}

/// スタータイプ
enum StarType {
  /// YouTuber
  youtuber,
  
  /// VTuber
  vtuber,
  
  /// ストリーマー
  streamer,
  
  /// クリエイター
  creator,
  
  /// 一般人スター
  generalStar,
  
  /// その他
  other,
}

/// SNSタイプ
enum SocialMediaType {
  /// YouTube
  youtube,
  
  /// Twitter
  twitter,
  
  /// Instagram
  instagram,
  
  /// TikTok
  tiktok,
  
  /// Twitch
  twitch,
  
  /// Discord
  discord,
  
  /// その他
  other,
}

/// サブスクリプションプラン
enum SubscriptionPlan {
  /// なし
  none,
  
  /// ソロファン
  soloFan,
  
  /// ライト
  light,
  
  /// スタンダード
  standard,
  
  /// プレミアム
  premium,
}

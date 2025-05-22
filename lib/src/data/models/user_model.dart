import 'package:flutter/foundation.dart';

/// スターランクを表すenum
enum StarRank {
  /// レギュラースター（1000人以下）：収益分配率 80%
  regular,
  
  /// プラチナスター（10000人以上）：収益分配率 82%
  platinum,
  
  /// スーパースター（100000人以上）：収益分配率 85%
  super,
}

/// ユーザー設定を表すクラス
class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final Map<String, bool> privacySettings;
  final String language;

  UserPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.privacySettings = const {},
    this.language = 'ja',
  });

  /// JSONからUserPreferencesを生成するファクトリメソッド
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      privacySettings: Map<String, bool>.from(json['privacySettings'] ?? {}),
      language: json['language'] ?? 'ja',
    );
  }

  /// UserPreferencesをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'privacySettings': privacySettings,
      'language': language,
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  UserPreferences copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    Map<String, bool>? privacySettings,
    String? language,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacySettings: privacySettings ?? this.privacySettings,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.darkMode == darkMode &&
        other.notificationsEnabled == notificationsEnabled &&
        mapEquals(other.privacySettings, privacySettings) &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(
        darkMode,
        notificationsEnabled,
        privacySettings,
        language,
      );
}

/// ユーザーを表すクラス
class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final bool isStarCreator;
  final int followerCount;
  final StarRank starRank;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, String>? socialLinks;
  final UserPreferences? preferences;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    this.isStarCreator = false,
    this.followerCount = 0,
    this.starRank = StarRank.regular,
    required this.createdAt,
    required this.updatedAt,
    this.socialLinks,
    this.preferences,
  });

  /// JSONからUserを生成するファクトリメソッド
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['displayName'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      isStarCreator: json['isStarCreator'] ?? false,
      followerCount: json['followerCount'] ?? 0,
      starRank: StarRank.values.firstWhere(
        (e) => e.toString() == 'StarRank.${json['starRank']}',
        orElse: () => StarRank.regular,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      socialLinks: json['socialLinks'] != null
          ? Map<String, String>.from(json['socialLinks'])
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  /// UserをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isStarCreator': isStarCreator,
      'followerCount': followerCount,
      'starRank': starRank.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'socialLinks': socialLinks,
      'preferences': preferences?.toJson(),
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    bool? isStarCreator,
    int? followerCount,
    StarRank? starRank,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? socialLinks,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isStarCreator: isStarCreator ?? this.isStarCreator,
      followerCount: followerCount ?? this.followerCount,
      starRank: starRank ?? this.starRank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      socialLinks: socialLinks ?? this.socialLinks,
      preferences: preferences ?? this.preferences,
    );
  }

  /// スターランクに基づく収益分配率を取得するメソッド
  double getRevenueShare() {
    switch (starRank) {
      case StarRank.regular:
        return 0.80; // 80%
      case StarRank.platinum:
        return 0.82; // 82%
      case StarRank.super:
        return 0.85; // 85%
      default:
        return 0.80; // デフォルトは80%
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.displayName == displayName &&
        other.profileImageUrl == profileImageUrl &&
        other.bio == bio &&
        other.isStarCreator == isStarCreator &&
        other.followerCount == followerCount &&
        other.starRank == starRank &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        mapEquals(other.socialLinks, socialLinks) &&
        other.preferences == preferences;
  }

  @override
  int get hashCode => Object.hash(
        id,
        username,
        email,
        displayName,
        profileImageUrl,
        bio,
        isStarCreator,
        followerCount,
        starRank,
        createdAt,
        updatedAt,
        socialLinks,
        preferences,
      );
}

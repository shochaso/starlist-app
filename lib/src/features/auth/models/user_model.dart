/// ユーザーモデル
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? profileImageUrl;
  final String? bio;
  final bool isStar; // スター（情報を共有する人）かどうか
  final int followerCount;
  final StarRank starRank;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, String>? socialLinks;
  final UserPreferences? preferences;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.profileImageUrl,
    this.bio,
    this.isStar = false, // デフォルトはファン（閲覧者）
    this.followerCount = 0,
    this.starRank = StarRank.none,
    required this.createdAt,
    required this.updatedAt,
    this.socialLinks,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
      isStar: json['is_star'] ?? false,
      followerCount: json['follower_count'] ?? 0,
      starRank: StarRank.values.firstWhere(
        (rank) => rank.name == json['star_rank'],
        orElse: () => StarRank.none,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'])
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'is_star': isStar,
      'follower_count': followerCount,
      'star_rank': starRank.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'social_links': socialLinks,
      'preferences': preferences?.toJson(),
    };
  }

  /// コピーを作成するメソッド
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    bool? isStar,
    int? followerCount,
    StarRank? starRank,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? socialLinks,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isStar: isStar ?? this.isStar,
      followerCount: followerCount ?? this.followerCount,
      starRank: starRank ?? this.starRank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      socialLinks: socialLinks ?? this.socialLinks,
      preferences: preferences ?? this.preferences,
    );
  }

  /// ユーザーがスター（情報を共有する人）かどうかを判定
  bool get isContentCreator => isStar;

  /// ユーザーがファン（情報を閲覧する人）かどうかを判定
  bool get isFan => !isStar;

  /// ユーザーの種類を表す文字列
  String get roleText => isStar ? 'スター' : 'ファン';
}

/// スターランク（ユーザーの等級）
enum StarRank {
  none,
  bronze,
  silver,
  gold,
  platinum,
  diamond;
}

/// ユーザー設定
class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final Map<String, bool>? privacySettings;
  final String? language;

  UserPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.privacySettings,
    this.language,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      privacySettings: json['privacy_settings'] != null
          ? Map<String, bool>.from(json['privacy_settings'])
          : null,
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'privacy_settings': privacySettings,
      'language': language,
    };
  }

  /// コピーを作成するメソッド
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
} 
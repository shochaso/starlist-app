/// SNS認証情報
class SNSVerification {
  final String id;
  final String userId;
  final SNSPlatform platform;
  final String accountHandle;
  final String accountUrl;
  final int? followerCount;
  final String verificationCode;
  final bool ownershipVerified;
  final DateTime? ownershipVerifiedAt;
  final Map<String, dynamic>? apiData;
  final String verificationStatus;
  final int verificationAttempts;
  final DateTime? lastVerificationAttempt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SNSVerification({
    required this.id,
    required this.userId,
    required this.platform,
    required this.accountHandle,
    required this.accountUrl,
    this.followerCount,
    required this.verificationCode,
    required this.ownershipVerified,
    this.ownershipVerifiedAt,
    this.apiData,
    required this.verificationStatus,
    required this.verificationAttempts,
    this.lastVerificationAttempt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SNSVerification.fromJson(Map<String, dynamic> json) {
    return SNSVerification(
      id: json['id'],
      userId: json['user_id'],
      platform: SNSPlatform.fromString(json['platform']),
      accountHandle: json['account_handle'],
      accountUrl: json['account_url'],
      followerCount: json['follower_count'],
      verificationCode: json['verification_code'],
      ownershipVerified: json['ownership_verified'] ?? false,
      ownershipVerifiedAt: json['ownership_verified_at'] != null
          ? DateTime.parse(json['ownership_verified_at'])
          : null,
      apiData: json['api_data'],
      verificationStatus: json['verification_status'],
      verificationAttempts: json['verification_attempts'] ?? 0,
      lastVerificationAttempt: json['last_verification_attempt'] != null
          ? DateTime.parse(json['last_verification_attempt'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform.value,
      'account_handle': accountHandle,
      'account_url': accountUrl,
      'follower_count': followerCount,
      'verification_code': verificationCode,
      'ownership_verified': ownershipVerified,
      'ownership_verified_at': ownershipVerifiedAt?.toIso8601String(),
      'api_data': apiData,
      'verification_status': verificationStatus,
      'verification_attempts': verificationAttempts,
      'last_verification_attempt': lastVerificationAttempt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// SNSプラットフォーム
enum SNSPlatform {
  youtube('youtube', 'YouTube'),
  instagram('instagram', 'Instagram'),
  tiktok('tiktok', 'TikTok'),
  twitter('twitter', 'Twitter');

  const SNSPlatform(this.value, this.displayName);
  final String value;
  final String displayName;

  static SNSPlatform fromString(String value) {
    return SNSPlatform.values.firstWhere(
      (platform) => platform.value == value,
      orElse: () => SNSPlatform.youtube,
    );
  }

  /// プラットフォームのアイコン取得
  String get iconAsset {
    switch (this) {
      case SNSPlatform.youtube:
        return 'assets/icons/services/youtube.svg';
      case SNSPlatform.instagram:
        return 'assets/icons/services/instagram.svg';
      case SNSPlatform.tiktok:
        return 'assets/icons/services/tiktok.svg';
      case SNSPlatform.twitter:
        return 'assets/icons/services/twitter.svg';
    }
  }

  /// プラットフォームのメインカラー取得
  int get primaryColor {
    switch (this) {
      case SNSPlatform.youtube:
        return 0xFFFF0000; // YouTube Red
      case SNSPlatform.instagram:
        return 0xFFE4405F; // Instagram Pink
      case SNSPlatform.tiktok:
        return 0xFF000000; // TikTok Black
      case SNSPlatform.twitter:
        return 0xFF1DA1F2; // Twitter Blue
    }
  }

  /// URLプレフィックス取得
  String get urlPrefix {
    switch (this) {
      case SNSPlatform.youtube:
        return 'https://www.youtube.com/@';
      case SNSPlatform.instagram:
        return 'https://www.instagram.com/';
      case SNSPlatform.tiktok:
        return 'https://www.tiktok.com/@';
      case SNSPlatform.twitter:
        return 'https://twitter.com/';
    }
  }

  /// フォロワー名称取得
  String get followerLabel {
    switch (this) {
      case SNSPlatform.youtube:
        return 'チャンネル登録者';
      case SNSPlatform.instagram:
        return 'フォロワー';
      case SNSPlatform.tiktok:
        return 'フォロワー';
      case SNSPlatform.twitter:
        return 'フォロワー';
    }
  }
}

/// SNS認証ステータス
enum SNSVerificationStatus {
  pending('pending', '認証待ち'),
  verified('verified', '認証済み'),
  failed('failed', '認証失敗');

  const SNSVerificationStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static SNSVerificationStatus fromString(String value) {
    return SNSVerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SNSVerificationStatus.pending,
    );
  }
}

/// SNS認証リクエスト
class SNSVerificationRequest {
  final String userId;
  final SNSPlatform platform;
  final String accountHandle;
  final String accountUrl;

  SNSVerificationRequest({
    required this.userId,
    required this.platform,
    required this.accountHandle,
    required this.accountUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'platform': platform.value,
      'account_handle': accountHandle,
      'account_url': accountUrl,
    };
  }
}

/// SNS認証統計
class SNSVerificationStats {
  final int totalVerifications;
  final int pendingVerifications;
  final int verifiedAccounts;
  final int failedVerifications;
  final Map<SNSPlatform, int> platformCounts;

  SNSVerificationStats({
    required this.totalVerifications,
    required this.pendingVerifications,
    required this.verifiedAccounts,
    required this.failedVerifications,
    required this.platformCounts,
  });

  factory SNSVerificationStats.fromJson(Map<String, dynamic> json) {
    final platformCountsMap = <SNSPlatform, int>{};
    
    if (json['platform_counts'] != null) {
      (json['platform_counts'] as Map<String, dynamic>).forEach((key, value) {
        final platform = SNSPlatform.fromString(key);
        platformCountsMap[platform] = value as int;
      });
    }

    return SNSVerificationStats(
      totalVerifications: json['total_verifications'] ?? 0,
      pendingVerifications: json['pending_verifications'] ?? 0,
      verifiedAccounts: json['verified_accounts'] ?? 0,
      failedVerifications: json['failed_verifications'] ?? 0,
      platformCounts: platformCountsMap,
    );
  }
} 
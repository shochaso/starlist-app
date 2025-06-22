import 'package:flutter/foundation.dart';
import '../features/subscription/models/subscription_models.dart';
import '../data/models/star_point_models.dart';

/// 既存会員管理サービス連携インターフェース
abstract class ExistingMembershipService {
  /// 外部会員情報を取得
  Future<ExternalMembershipInfo?> getMembershipInfo(String userId);
  
  /// 外部ポイント残高を取得
  Future<int> getExternalPointBalance(String userId);
  
  /// 外部ポイントをスターPに変換
  Future<bool> convertExternalPointsToStarP(String userId, int externalPoints);
  
  /// 会員ステータスを同期
  Future<bool> syncMembershipStatus(String userId, SubscriptionPlanType planType);
}

/// 外部会員情報モデル
@immutable
class ExternalMembershipInfo {
  final String externalMemberId;
  final String membershipTier;
  final int externalPointBalance;
  final DateTime memberSince;
  final bool isActive;
  final Map<String, dynamic> additionalData;

  const ExternalMembershipInfo({
    required this.externalMemberId,
    required this.membershipTier,
    required this.externalPointBalance,
    required this.memberSince,
    required this.isActive,
    required this.additionalData,
  });

  factory ExternalMembershipInfo.fromJson(Map<String, dynamic> json) {
    return ExternalMembershipInfo(
      externalMemberId: json['external_member_id'],
      membershipTier: json['membership_tier'],
      externalPointBalance: json['external_point_balance'] ?? 0,
      memberSince: DateTime.parse(json['member_since']),
      isActive: json['is_active'] ?? false,
      additionalData: Map<String, dynamic>.from(json['additional_data'] ?? {}),
    );
  }
}

/// 会員管理統合サービス
class MembershipIntegrationService {
  final ExistingMembershipService _externalService;

  MembershipIntegrationService({
    required ExistingMembershipService externalService,
  }) : _externalService = externalService;

  /// 外部会員情報を取得してStarlistアカウントと連携
  Future<MembershipIntegrationResult> linkExternalMembership(String userId) async {
    try {
      final externalInfo = await _externalService.getMembershipInfo(userId);
      
      if (externalInfo == null) {
        return MembershipIntegrationResult.error('外部会員情報が見つかりません');
      }

      if (!externalInfo.isActive) {
        return MembershipIntegrationResult.error('外部会員アカウントが無効です');
      }

      // 外部ポイントをスターPに変換（1:1レート）
      if (externalInfo.externalPointBalance > 0) {
        final conversionSuccess = await _externalService.convertExternalPointsToStarP(
          userId,
          externalInfo.externalPointBalance,
        );

        if (!conversionSuccess) {
          debugPrint('外部ポイント変換に失敗しました');
        }
      }

      // 会員ティアに基づいてStarlistプランを推奨
      final recommendedPlan = _getRecommendedPlan(externalInfo.membershipTier);

      return MembershipIntegrationResult.success(
        externalInfo: externalInfo,
        convertedStarPoints: externalInfo.externalPointBalance,
        recommendedPlan: recommendedPlan,
      );

    } catch (e) {
      debugPrint('会員連携エラー: $e');
      return MembershipIntegrationResult.error('会員連携中にエラーが発生しました: $e');
    }
  }

  /// 定期的な会員ステータス同期
  Future<void> syncMembershipStatus(String userId, UserSubscription subscription) async {
    try {
      await _externalService.syncMembershipStatus(userId, subscription.planType);
    } catch (e) {
      debugPrint('会員ステータス同期エラー: $e');
    }
  }

  /// 外部ポイントの定期取得とスターP変換
  Future<PointSyncResult> syncExternalPoints(String userId) async {
    try {
      final currentBalance = await _externalService.getExternalPointBalance(userId);
      
      if (currentBalance <= 0) {
        return PointSyncResult(
          success: true,
          convertedPoints: 0,
          message: '変換可能なポイントがありません',
        );
      }

      final conversionSuccess = await _externalService.convertExternalPointsToStarP(
        userId,
        currentBalance,
      );

      return PointSyncResult(
        success: conversionSuccess,
        convertedPoints: conversionSuccess ? currentBalance : 0,
        message: conversionSuccess 
            ? '$currentBalance ポイントをスターPに変換しました'
            : 'ポイント変換に失敗しました',
      );

    } catch (e) {
      debugPrint('ポイント同期エラー: $e');
      return PointSyncResult(
        success: false,
        convertedPoints: 0,
        message: 'ポイント同期中にエラーが発生しました: $e',
      );
    }
  }

  /// 会員ティアに基づくプラン推奨ロジック
  SubscriptionPlanType _getRecommendedPlan(String membershipTier) {
    switch (membershipTier.toLowerCase()) {
      case 'bronze':
      case 'basic':
        return SubscriptionPlanType.basic;
      case 'silver':
      case 'standard':
        return SubscriptionPlanType.standard;
      case 'gold':
      case 'premium':
        return SubscriptionPlanType.premium;
      case 'platinum':
      case 'ultimate':
      case 'vip':
        return SubscriptionPlanType.ultimate;
      default:
        return SubscriptionPlanType.standard; // デフォルトは人気プラン
    }
  }

  /// 会員特典の移行
  Future<MigrationResult> migrateMemberBenefits(
    String userId,
    ExternalMembershipInfo externalInfo,
  ) async {
    final migratedBenefits = <String>[];
    final failedBenefits = <String>[];

    try {
      // 1. ポイント移行
      if (externalInfo.externalPointBalance > 0) {
        final pointMigration = await syncExternalPoints(userId);
        if (pointMigration.success) {
          migratedBenefits.add('ポイント: ${pointMigration.convertedPoints}スターP');
        } else {
          failedBenefits.add('ポイント移行');
        }
      }

      // 2. 会員ティア特典の移行
      final recommendedPlan = _getRecommendedPlan(externalInfo.membershipTier);
      migratedBenefits.add('推奨プラン: ${recommendedPlan.name}');

      // 3. 追加特典の移行（実装依存）
      final additionalBenefits = _migrateAdditionalBenefits(externalInfo.additionalData);
      migratedBenefits.addAll(additionalBenefits);

      return MigrationResult(
        success: failedBenefits.isEmpty,
        migratedBenefits: migratedBenefits,
        failedBenefits: failedBenefits,
      );

    } catch (e) {
      debugPrint('特典移行エラー: $e');
      return MigrationResult(
        success: false,
        migratedBenefits: migratedBenefits,
        failedBenefits: ['全体的な移行エラー'],
      );
    }
  }

  /// 追加特典の移行ロジック
  List<String> _migrateAdditionalBenefits(Map<String, dynamic> additionalData) {
    final benefits = <String>[];

    // VIP期間の移行
    if (additionalData['vip_until'] != null) {
      benefits.add('VIP期間を引き継ぎ');
    }

    // 特別バッジの移行
    if (additionalData['special_badges'] != null) {
      final badges = additionalData['special_badges'] as List;
      benefits.add('特別バッジ: ${badges.length}個');
    }

    // 限定コンテンツアクセス権の移行
    if (additionalData['exclusive_content_access'] == true) {
      benefits.add('限定コンテンツアクセス権');
    }

    return benefits;
  }
}

/// 会員連携結果
@immutable
class MembershipIntegrationResult {
  final bool success;
  final String message;
  final ExternalMembershipInfo? externalInfo;
  final int? convertedStarPoints;
  final SubscriptionPlanType? recommendedPlan;

  const MembershipIntegrationResult({
    required this.success,
    required this.message,
    this.externalInfo,
    this.convertedStarPoints,
    this.recommendedPlan,
  });

  factory MembershipIntegrationResult.success({
    required ExternalMembershipInfo externalInfo,
    int? convertedStarPoints,
    SubscriptionPlanType? recommendedPlan,
  }) {
    return MembershipIntegrationResult(
      success: true,
      message: '会員連携が完了しました',
      externalInfo: externalInfo,
      convertedStarPoints: convertedStarPoints,
      recommendedPlan: recommendedPlan,
    );
  }

  factory MembershipIntegrationResult.error(String message) {
    return MembershipIntegrationResult(
      success: false,
      message: message,
    );
  }
}

/// ポイント同期結果
@immutable
class PointSyncResult {
  final bool success;
  final int convertedPoints;
  final String message;

  const PointSyncResult({
    required this.success,
    required this.convertedPoints,
    required this.message,
  });
}

/// 特典移行結果
@immutable
class MigrationResult {
  final bool success;
  final List<String> migratedBenefits;
  final List<String> failedBenefits;

  const MigrationResult({
    required this.success,
    required this.migratedBenefits,
    required this.failedBenefits,
  });
}

/// デモ用の外部会員管理サービス実装
class DemoExternalMembershipService implements ExistingMembershipService {
  @override
  Future<ExternalMembershipInfo?> getMembershipInfo(String userId) async {
    // デモデータを返す
    await Future.delayed(const Duration(seconds: 1));
    
    return ExternalMembershipInfo(
      externalMemberId: 'EXT_$userId',
      membershipTier: 'gold',
      externalPointBalance: 5000,
      memberSince: DateTime.now().subtract(const Duration(days: 365)),
      isActive: true,
      additionalData: {
        'vip_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'special_badges': ['early_adopter', 'loyalty'],
        'exclusive_content_access': true,
      },
    );
  }

  @override
  Future<int> getExternalPointBalance(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 1200; // デモ残高
  }

  @override
  Future<bool> convertExternalPointsToStarP(String userId, int externalPoints) async {
    await Future.delayed(const Duration(seconds: 2));
    // デモでは常に成功
    return true;
  }

  @override
  Future<bool> syncMembershipStatus(String userId, SubscriptionPlanType planType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // デモでは常に成功
    return true;
  }
}
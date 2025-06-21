import '../models/user_model.dart';
import '../models/content_consumption_model.dart';
import '../models/subscription_model.dart';
import '../models/fan_star_relationship_model.dart';
import '../models/transaction_model.dart';
import '../models/admin/user_management_model.dart';
import '../models/admin/content_moderation_model.dart';
import '../models/legal/legal_compliance_model.dart';

/// 既存モデルと管理・運用機能を統合するクラス
class ModelIntegrationService {
  /// ユーザーモデルから管理用ユーザー情報を取得する
  UserAdminStatus getUserAdminStatus(User user) {
    // ユーザーの状態に基づいて管理ステータスを返す
    if (user.isDeleted) {
      return UserAdminStatus.deleted;
    } else if (user.isSuspended) {
      return UserAdminStatus.suspended;
    } else if (user.isUnderReview) {
      return UserAdminStatus.underReview;
    } else {
      return UserAdminStatus.active;
    }
  }
  
  /// 管理ステータスをユーザーモデルに適用する
  User applyAdminStatusToUser(User user, UserAdminStatus status) {
    // 管理ステータスに基づいてユーザーモデルを更新
    switch (status) {
      case UserAdminStatus.active:
        return user.copyWith(
          isSuspended: false,
          isUnderReview: false,
          isDeleted: false,
        );
      case UserAdminStatus.suspended:
        return user.copyWith(
          isSuspended: true,
          isUnderReview: false,
        );
      case UserAdminStatus.banned:
        return user.copyWith(
          isSuspended: true,
          isUnderReview: false,
        );
      case UserAdminStatus.underReview:
        return user.copyWith(
          isUnderReview: true,
        );
      case UserAdminStatus.deleted:
        return user.copyWith(
          isDeleted: true,
        );
      default:
        return user;
    }
  }
  
  /// コンテンツ消費モデルからコンテンツモデレーション情報を取得する
  ContentModerationStatus getContentModerationStatus(ContentConsumption content) {
    // コンテンツの状態に基づいてモデレーションステータスを返す
    if (content.isRemoved) {
      return ContentModerationStatus.removed;
    } else if (content.isRejected) {
      return ContentModerationStatus.rejected;
    } else if (content.isPending) {
      return ContentModerationStatus.pending;
    } else if (content.isAutoFlagged) {
      return ContentModerationStatus.autoFlagged;
    } else {
      return ContentModerationStatus.approved;
    }
  }
  
  /// モデレーションステータスをコンテンツ消費モデルに適用する
  ContentConsumption applyModerationStatusToContent(ContentConsumption content, ContentModerationStatus status) {
    // モデレーションステータスに基づいてコンテンツモデルを更新
    switch (status) {
      case ContentModerationStatus.approved:
        return content.copyWith(
          isPending: false,
          isRejected: false,
          isRemoved: false,
          isAutoFlagged: false,
        );
      case ContentModerationStatus.pending:
        return content.copyWith(
          isPending: true,
          isRejected: false,
          isRemoved: false,
        );
      case ContentModerationStatus.rejected:
        return content.copyWith(
          isPending: false,
          isRejected: true,
        );
      case ContentModerationStatus.removed:
        return content.copyWith(
          isPending: false,
          isRemoved: true,
        );
      case ContentModerationStatus.autoFlagged:
        return content.copyWith(
          isAutoFlagged: true,
        );
      default:
        return content;
    }
  }
  
  /// サブスクリプションモデルから収益分析データを取得する
  Map<String, dynamic> getRevenueAnalyticsFromSubscription(List<Subscription> subscriptions) {
    // サブスクリプションリストから収益分析データを生成
    double totalRevenue = 0;
    Map<String, double> revenueByPlan = {
      'free': 0,
      'light': 0,
      'standard': 0,
      'premium': 0,
    };
    
    for (final subscription in subscriptions) {
      final price = subscription.monthlyPrice;
      totalRevenue += price;
      
      switch (subscription.planType) {
        case PlanType.free:
          revenueByPlan['free'] = (revenueByPlan['free'] ?? 0) + price;
          break;
        case PlanType.light:
          revenueByPlan['light'] = (revenueByPlan['light'] ?? 0) + price;
          break;
        case PlanType.standard:
          revenueByPlan['standard'] = (revenueByPlan['standard'] ?? 0) + price;
          break;
        case PlanType.premium:
          revenueByPlan['premium'] = (revenueByPlan['premium'] ?? 0) + price;
          break;
      }
    }
    
    return {
      'totalRevenue': totalRevenue,
      'revenueByPlan': revenueByPlan,
      'averageRevenuePerUser': subscriptions.isEmpty ? 0 : totalRevenue / subscriptions.length,
    };
  }
  
  /// トランザクションモデルから収益分析データを取得する
  Map<String, dynamic> getRevenueAnalyticsFromTransactions(List<Transaction> transactions) {
    // トランザクションリストから収益分析データを生成
    double totalRevenue = 0;
    double subscriptionRevenue = 0;
    double ticketRevenue = 0;
    double donationRevenue = 0;
    
    for (final transaction in transactions) {
      final amount = transaction.amount;
      
      // 返金は収益から差し引く
      if (transaction.type == TransactionType.refund) {
        totalRevenue -= amount;
        continue;
      }
      
      totalRevenue += amount;
      
      switch (transaction.type) {
        case TransactionType.subscription:
          subscriptionRevenue += amount;
          break;
        case TransactionType.ticket:
          ticketRevenue += amount;
          break;
        case TransactionType.donation:
          donationRevenue += amount;
          break;
        default:
          break;
      }
    }
    
    return {
      'totalRevenue': totalRevenue,
      'subscriptionRevenue': subscriptionRevenue,
      'ticketRevenue': ticketRevenue,
      'donationRevenue': donationRevenue,
    };
  }
  
  /// ファン-スター関係モデルからチケット使用状況を取得する
  Map<String, dynamic> getTicketUsageAnalytics(List<FanStarRelationship> relationships) {
    // ファン-スター関係リストからチケット使用状況データを生成
    int totalBronzeTickets = 0;
    int totalSilverTickets = 0;
    int usedBronzeTickets = 0;
    int usedSilverTickets = 0;
    
    for (final relationship in relationships) {
      final bronzeBalance = relationship.ticketBalance['bronze'] ?? 0;
      final silverBalance = relationship.ticketBalance['silver'] ?? 0;
      
      totalBronzeTickets += bronzeBalance;
      totalSilverTickets += silverBalance;
      
      // 使用済みチケット数は履歴から計算（実際の実装ではより複雑になる可能性あり）
      usedBronzeTickets += relationship.ticketUsageHistory.where((h) => h.ticketType == 'bronze').length;
      usedSilverTickets += relationship.ticketUsageHistory.where((h) => h.ticketType == 'silver').length;
    }
    
    return {
      'totalBronzeTickets': totalBronzeTickets,
      'totalSilverTickets': totalSilverTickets,
      'usedBronzeTickets': usedBronzeTickets,
      'usedSilverTickets': usedSilverTickets,
      'bronzeUsageRate': totalBronzeTickets > 0 ? usedBronzeTickets / totalBronzeTickets : 0,
      'silverUsageRate': totalSilverTickets > 0 ? usedSilverTickets / totalSilverTickets : 0,
    };
  }
  
  /// コンテンツ消費モデルに年齢制限を適用する
  ContentConsumption applyAgeRestrictionToContent(ContentConsumption content, ContentAgeRestriction restriction) {
    // 年齢制限に基づいてコンテンツモデルを更新
    return content.copyWith(
      ageRestriction: restriction.toString().split('.').last,
    );
  }
  
  /// コンテンツ消費モデルに著作権保護を適用する
  ContentConsumption applyCopyrightProtectionToContent(ContentConsumption content, CopyrightProtectionType protectionType, String? licenseDetails) {
    // 著作権保護に基づいてコンテンツモデルを更新
    return content.copyWith(
      copyrightProtection: protectionType.toString().split('.').last,
      licenseDetails: licenseDetails,
    );
  }
  
  /// ユーザーモデルに利用規約同意情報を適用する
  User applyTermsConsentToUser(User user, String termsVersion, DateTime consentDate) {
    // 利用規約同意情報に基づいてユーザーモデルを更新
    return user.copyWith(
      termsAccepted: true,
      termsVersion: termsVersion,
      termsAcceptedAt: consentDate,
    );
  }
  
  /// ユーザーモデルにプライバシーポリシー同意情報を適用する
  User applyPrivacyPolicyConsentToUser(User user, String privacyPolicyVersion, DateTime consentDate) {
    // プライバシーポリシー同意情報に基づいてユーザーモデルを更新
    return user.copyWith(
      privacyPolicyAccepted: true,
      privacyPolicyVersion: privacyPolicyVersion,
      privacyPolicyAcceptedAt: consentDate,
    );
  }
}

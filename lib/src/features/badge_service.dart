import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_models.dart';

/// バッジサービスクラス
class BadgeService {
  /// バッジを取得するメソッド
  Future<List<Badge>> getBadges(String userId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    return [
      Badge(
        id: 'bronze_badge_1',
        name: 'ブロンズサポーター',
        description: '3ヶ月以上継続的にスターをサポートしているファン',
        type: BadgeType.bronze,
        iconPath: 'assets/badges/bronze_supporter.png',
        color: Colors.brown[300]!,
        criteria: {
          'minMonths': 3,
          'minPoints': 1000,
        },
      ),
      Badge(
        id: 'silver_badge_1',
        name: 'シルバーサポーター',
        description: '6ヶ月以上継続的にスターをサポートしているファン',
        type: BadgeType.silver,
        iconPath: 'assets/badges/silver_supporter.png',
        color: Colors.grey[400]!,
        criteria: {
          'minMonths': 6,
          'minPoints': 5000,
        },
      ),
      Badge(
        id: 'gold_badge_1',
        name: 'ゴールドサポーター',
        description: '12ヶ月以上継続的にスターをサポートしているファン',
        type: BadgeType.gold,
        iconPath: 'assets/badges/gold_supporter.png',
        color: Colors.amber[300]!,
        criteria: {
          'minMonths': 12,
          'minPoints': 10000,
        },
      ),
      Badge(
        id: 'loyal_badge_1',
        name: 'ロイヤルファン',
        description: 'スターの最も熱心なサポーター',
        type: BadgeType.loyal,
        iconPath: 'assets/badges/loyal_fan.png',
        color: Colors.purple[300]!,
        criteria: {
          'isTopFan': true,
          'minMonths': 24,
          'minPoints': 20000,
        },
      ),
    ];
  }

  /// ユーザーのバッジコレクションを取得するメソッド
  Future<UserBadges> getUserBadges(String userId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final badges = await getBadges(userId);
    
    // ユーザーに付与されたバッジをシミュレート
    final awardedBadges = badges.take(2).map((badge) {
      return badge.copyWith(
        awardedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    }).toList();
    
    return UserBadges(
      userId: userId,
      badges: awardedBadges,
      activeBadge: awardedBadges.isNotEmpty ? awardedBadges.last : null,
    );
  }

  /// ロイヤルファンステータスを取得するメソッド
  Future<LoyalFanStatus> getLoyalFanStatus(String userId, String starId) async {
    // 実際のアプリではAPIからデータを取得
    // ここではモックデータを返す
    final badges = await getBadges(userId);
    final loyalBadges = badges.where((badge) => badge.type == BadgeType.loyal).toList();
    
    return LoyalFanStatus(
      userId: userId,
      starId: starId,
      loyaltyPoints: 7500,
      consecutiveMonthsSupporting: 8,
      memberSince: DateTime.now().subtract(const Duration(days: 365)),
      specialBadges: loyalBadges,
      isTopFan: false,
    );
  }

  /// バッジを付与するメソッド
  Future<UserBadges> awardBadge(String userId, Badge badge) async {
    // 実際のアプリではAPIを呼び出してバッジを付与
    // ここではモックの処理を行う
    final userBadges = await getUserBadges(userId);
    final updatedBadge = badge.copyWith(awardedAt: DateTime.now());
    return userBadges.addBadge(updatedBadge);
  }

  /// アクティブバッジを設定するメソッド
  Future<UserBadges> setActiveBadge(String userId, String badgeId) async {
    // 実際のアプリではAPIを呼び出してアクティブバッジを設定
    // ここではモックの処理を行う
    final userBadges = await getUserBadges(userId);
    final badge = userBadges.badges.firstWhere((b) => b.id == badgeId);
    return userBadges.setActiveBadge(badge);
  }

  /// バッジの可視性を更新するメソッド
  Future<UserBadges> updateBadgeVisibility(String userId, String badgeId, bool isVisible) async {
    // 実際のアプリではAPIを呼び出して可視性を更新
    // ここではモックの処理を行う
    final userBadges = await getUserBadges(userId);
    return userBadges.updateBadgeVisibility(badgeId, isVisible);
  }

  /// ロイヤルティポイントを追加するメソッド
  Future<LoyalFanStatus> addLoyaltyPoints(String userId, String starId, int points) async {
    // 実際のアプリではAPIを呼び出してポイントを追加
    // ここではモックの処理を行う
    final loyalFanStatus = await getLoyalFanStatus(userId, starId);
    return loyalFanStatus.addLoyaltyPoints(points);
  }

  /// バッジの獲得条件を確認するメソッド
  Future<List<Badge>> checkEligibleBadges(String userId, String starId) async {
    // 実際のアプリではユーザーの活動データを分析して獲得可能なバッジを判定
    // ここではモックの処理を行う
    final allBadges = await getBadges(userId);
    final userBadges = await getUserBadges(userId);
    final loyalFanStatus = await getLoyalFanStatus(userId, starId);
    
    // ユーザーがまだ獲得していないバッジを抽出
    final notAwardedBadges = allBadges.where((badge) {
      return !userBadges.badges.any((userBadge) => userBadge.id == badge.id);
    }).toList();
    
    // 獲得条件を満たすバッジを抽出
    return notAwardedBadges.where((badge) {
      if (badge.criteria == null) return false;
      
      final criteria = badge.criteria!;
      
      // ブロンズバッジの条件
      if (badge.type == BadgeType.bronze) {
        return loyalFanStatus.consecutiveMonthsSupporting >= (criteria['minMonths'] ?? 3) &&
               loyalFanStatus.loyaltyPoints >= (criteria['minPoints'] ?? 1000);
      }
      
      // シルバーバッジの条件
      if (badge.type == BadgeType.silver) {
        return loyalFanStatus.consecutiveMonthsSupporting >= (criteria['minMonths'] ?? 6) &&
               loyalFanStatus.loyaltyPoints >= (criteria['minPoints'] ?? 5000);
      }
      
      // ゴールドバッジの条件
      if (badge.type == BadgeType.gold) {
        return loyalFanStatus.consecutiveMonthsSupporting >= (criteria['minMonths'] ?? 12) &&
               loyalFanStatus.loyaltyPoints >= (criteria['minPoints'] ?? 10000);
      }
      
      // ロイヤルバッジの条件
      if (badge.type == BadgeType.loyal) {
        return loyalFanStatus.isTopFan &&
               loyalFanStatus.consecutiveMonthsSupporting >= (criteria['minMonths'] ?? 24) &&
               loyalFanStatus.loyaltyPoints >= (criteria['minPoints'] ?? 20000);
      }
      
      return false;
    }).toList();
  }
}

/// バッジサービスのプロバイダー
final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService();
});

/// ユーザーバッジのプロバイダー
final userBadgesProvider = FutureProvider.family<UserBadges, String>((ref, userId) async {
  final badgeService = ref.watch(badgeServiceProvider);
  return await badgeService.getUserBadges(userId);
});

/// ロイヤルファンステータスのプロバイダー
final loyalFanStatusProvider = FutureProvider.family<LoyalFanStatus, Map<String, String>>((ref, params) async {
  final badgeService = ref.watch(badgeServiceProvider);
  return await badgeService.getLoyalFanStatus(params['userId']!, params['starId']!);
});

/// 獲得可能バッジのプロバイダー
final eligibleBadgesProvider = FutureProvider.family<List<Badge>, Map<String, String>>((ref, params) async {
  final badgeService = ref.watch(badgeServiceProvider);
  return await badgeService.checkEligibleBadges(params['userId']!, params['starId']!);
});

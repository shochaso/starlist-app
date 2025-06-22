import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 収益分配サービス - 広告収益は100%運営、アフィリエイト収益のみスターと分配
abstract class RevenueDistributionService {
  Future<Map<String, dynamic>> calculateRevenueShare(String starId, DateTime startDate, DateTime endDate);
  Future<void> distributeRevenue(String starId, double amount, String revenueType);
  Future<List<Map<String, dynamic>>> getRevenueHistory(String starId);
  Future<Map<String, dynamic>> getRevenueBreakdown(String starId);
}

class RevenueDistributionServiceImpl implements RevenueDistributionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 収益分配率設定
  static const double _affiliateStarShare = 0.70; // スター70%
  static const double _affiliatePlatformShare = 0.30; // プラットフォーム30%
  static const double _adPlatformShare = 1.0; // 広告収益は100%プラットフォーム

  @override
  Future<Map<String, dynamic>> calculateRevenueShare(String starId, DateTime startDate, DateTime endDate) async {
    try {
      // アフィリエイト収益のみスターと分配
      final affiliateRevenue = await _getAffiliateRevenue(starId, startDate, endDate);
      
      // 広告収益は100%運営（スターには分配しない）
      final adRevenue = await _getAdRevenue(starId, startDate, endDate);

      final starAffiliateShare = affiliateRevenue * _affiliateStarShare;
      final platformAffiliateShare = affiliateRevenue * _affiliatePlatformShare;
      final platformAdShare = adRevenue * _adPlatformShare; // 100%運営

      return {
        'star_id': starId,
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
        'affiliate_revenue': {
          'total': affiliateRevenue,
          'star_share': starAffiliateShare,
          'platform_share': platformAffiliateShare,
        },
        'ad_revenue': {
          'total': adRevenue,
          'star_share': 0.0, // スターには分配しない
          'platform_share': platformAdShare, // 100%運営
        },
        'total_star_earnings': starAffiliateShare, // アフィリエイトのみ
        'total_platform_earnings': platformAffiliateShare + platformAdShare,
      };
    } catch (e) {
      throw RevenueException('収益分配計算に失敗しました: $e');
    }
  }

  @override
  Future<void> distributeRevenue(String starId, double amount, String revenueType) async {
    try {
      double starShare = 0.0;
      double platformShare = 0.0;

      // 収益タイプに応じて分配率を決定
      switch (revenueType) {
        case 'affiliate':
          starShare = amount * _affiliateStarShare;
          platformShare = amount * _affiliatePlatformShare;
          break;
        case 'advertisement':
          starShare = 0.0; // 広告収益はスターに分配しない
          platformShare = amount * _adPlatformShare; // 100%運営
          break;
        default:
          throw RevenueException('無効な収益タイプです: $revenueType');
      }

      // スターへの分配（アフィリエイトのみ）
      if (starShare > 0) {
        await _distributeToStar(starId, starShare, revenueType);
      }

      // プラットフォームへの分配
      await _distributeToPlatform(platformShare, revenueType);

      // 分配履歴を記録
      await _recordRevenueDistribution(starId, amount, revenueType, starShare, platformShare);
    } catch (e) {
      throw RevenueException('収益分配に失敗しました: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueHistory(String starId) async {
    try {
      final response = await _supabase
          .from('revenue_distributions')
          .select()
          .eq('star_id', starId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw RevenueException('収益履歴の取得に失敗しました: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getRevenueBreakdown(String starId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final breakdown = await calculateRevenueShare(starId, thirtyDaysAgo, DateTime.now());
      
      // 追加統計情報
      final totalTransactions = await _supabase
          .from('revenue_distributions')
          .select('id')
          .eq('star_id', starId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .count();

      breakdown['statistics'] = {
        'total_transactions': totalTransactions,
        'average_transaction': breakdown['total_star_earnings'] / (totalTransactions > 0 ? totalTransactions : 1),
        'affiliate_percentage': breakdown['affiliate_revenue']['total'] > 0 
            ? (breakdown['affiliate_revenue']['star_share'] / breakdown['affiliate_revenue']['total'] * 100) 
            : 0.0,
        'ad_note': '広告収益は100%運営に帰属します',
      };

      return breakdown;
    } catch (e) {
      throw RevenueException('収益内訳の取得に失敗しました: $e');
    }
  }

  // プライベートメソッド
  Future<double> _getAffiliateRevenue(String starId, DateTime startDate, DateTime endDate) async {
    try {
      final result = await _supabase
          .from('affiliate_transactions')
          .select('commission_amount')
          .eq('star_id', starId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      return result.fold<double>(0.0, (sum, item) => sum + (item['commission_amount'] ?? 0.0));
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getAdRevenue(String starId, DateTime startDate, DateTime endDate) async {
    try {
      final result = await _supabase
          .from('ad_impressions')
          .select('revenue_amount')
          .eq('star_id', starId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      return result.fold<double>(0.0, (sum, item) => sum + (item['revenue_amount'] ?? 0.0));
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _distributeToStar(String starId, double amount, String revenueType) async {
    // スターのウォレットに収益を追加
    await _supabase.rpc('add_star_revenue', params: {
      'star_id': starId,
      'amount': amount,
      'revenue_type': revenueType,
      'description': 'アフィリエイト収益分配',
    });
  }

  Future<void> _distributeToPlatform(double amount, String revenueType) async {
    // プラットフォーム収益を記録
    await _supabase
        .from('platform_revenue')
        .insert({
          'amount': amount,
          'revenue_type': revenueType,
          'description': revenueType == 'advertisement' ? '広告収益（100%運営）' : 'アフィリエイト収益分配',
          'created_at': DateTime.now().toIso8601String(),
        });
  }

  Future<void> _recordRevenueDistribution(String starId, double totalAmount, String revenueType, double starShare, double platformShare) async {
    await _supabase
        .from('revenue_distributions')
        .insert({
          'star_id': starId,
          'total_amount': totalAmount,
          'revenue_type': revenueType,
          'star_share': starShare,
          'platform_share': platformShare,
          'distribution_note': revenueType == 'advertisement' 
              ? '広告収益は100%運営に帰属' 
              : 'アフィリエイト収益分配',
          'created_at': DateTime.now().toIso8601String(),
        });
  }
}

class RevenueException implements Exception {
  final String message;
  RevenueException(this.message);
  
  @override
  String toString() => 'RevenueException: $message';
}

final revenueDistributionServiceProvider = Provider<RevenueDistributionService>((ref) {
  return RevenueDistributionServiceImpl();
});

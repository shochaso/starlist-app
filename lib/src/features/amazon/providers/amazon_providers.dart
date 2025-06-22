import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/amazon_models.dart';
import '../services/amazon_api_service.dart';
import '../services/amazon_ocr_service.dart';
import '../repositories/amazon_repository.dart';
import '../../auth/providers/user_provider.dart';
import '../../../core/logging/logger.dart';

/// Amazon APIサービスプロバイダー
final amazonApiServiceProvider = Provider<AmazonApiService>((ref) {
  return AmazonApiService(
    logger: ref.read(loggerProvider),
  );
});

/// Amazon OCRサービスプロバイダー
final amazonOcrServiceProvider = Provider<AmazonOcrService>((ref) {
  return AmazonOcrService(
    logger: ref.read(loggerProvider),
  );
});

/// Amazonリポジトリプロバイダー
final amazonRepositoryProvider = Provider<AmazonRepository>((ref) {
  return AmazonRepository(
    apiService: ref.read(amazonApiServiceProvider),
    ocrService: ref.read(amazonOcrServiceProvider),
    logger: ref.read(loggerProvider),
  );
});

/// ユーザーのAmazon購入履歴プロバイダー
final amazonPurchaseHistoryProvider = FutureProvider.family<List<AmazonPurchase>, String>((ref, userId) async {
  final repository = ref.read(amazonRepositoryProvider);
  return await repository.getPurchaseHistory(userId: userId);
});

/// Amazon購入履歴フィルタープロバイダー
final amazonPurchaseFilterProvider = StateProvider<AmazonPurchaseFilter>((ref) {
  return const AmazonPurchaseFilter();
});

/// フィルター済みAmazon購入履歴プロバイダー
final filteredAmazonPurchasesProvider = FutureProvider<List<AmazonPurchase>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return [];
  
  final purchasesAsync = ref.watch(amazonPurchaseHistoryProvider(user.id));
  final filter = ref.watch(amazonPurchaseFilterProvider);
  
  return purchasesAsync.when(
    data: (purchases) => _applyFilter(purchases, filter),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Amazon購入統計プロバイダー
final amazonPurchaseStatsProvider = FutureProvider<AmazonPurchaseStats?>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return null;
  
  final purchasesAsync = ref.watch(amazonPurchaseHistoryProvider(user.id));
  
  return purchasesAsync.when(
    data: (purchases) => _calculateStats(purchases),
    loading: () => null,
    error: (_, __) => null,
  );
});

/// カテゴリ別購入データプロバイダー
final amazonPurchasesByCategoryProvider = FutureProvider<Map<AmazonPurchaseCategory, List<AmazonPurchase>>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return {};
  
  final purchasesAsync = ref.watch(amazonPurchaseHistoryProvider(user.id));
  
  return purchasesAsync.when(
    data: (purchases) => _groupByCategory(purchases),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Amazon購入履歴の読み込み状態プロバイダー
final amazonPurchaseLoadingProvider = StateProvider<bool>((ref) => false);

/// Amazon購入履歴エラー状態プロバイダー
final amazonPurchaseErrorProvider = StateProvider<String?>((ref) => null);

/// OCR解析結果プロバイダー
final amazonOcrResultProvider = StateProvider<List<AmazonPurchase>?>((ref) => null);

/// OCR解析進行状態プロバイダー
final amazonOcrProgressProvider = StateProvider<double>((ref) => 0.0);

/// Amazon購入履歴アクションプロバイダー
final amazonPurchaseActionProvider = Provider<AmazonPurchaseActions>((ref) {
  return AmazonPurchaseActions(ref);
});

/// Amazon購入履歴アクションクラス
class AmazonPurchaseActions {
  final ProviderRef ref;
  
  AmazonPurchaseActions(this.ref);

  /// 購入履歴を更新
  Future<void> refreshPurchaseHistory() async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(amazonPurchaseLoadingProvider.notifier).state = true;
    ref.read(amazonPurchaseErrorProvider.notifier).state = null;

    try {
      ref.invalidate(amazonPurchaseHistoryProvider(user.id));
      await ref.read(amazonPurchaseHistoryProvider(user.id).future);
    } catch (e) {
      ref.read(amazonPurchaseErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(amazonPurchaseLoadingProvider.notifier).state = false;
    }
  }

  /// OCR解析を実行
  Future<void> analyzePurchaseImage({
    required String imagePath,
    required String sourceType,
  }) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(amazonPurchaseLoadingProvider.notifier).state = true;
    ref.read(amazonPurchaseErrorProvider.notifier).state = null;
    ref.read(amazonOcrProgressProvider.notifier).state = 0.1;

    try {
      final repository = ref.read(amazonRepositoryProvider);
      
      ref.read(amazonOcrProgressProvider.notifier).state = 0.5;
      
      final purchases = await repository.analyzePurchaseImageFromPath(
        userId: user.id,
        imagePath: imagePath,
        sourceType: sourceType,
      );
      
      ref.read(amazonOcrProgressProvider.notifier).state = 0.8;
      
      // OCR結果を保存
      if (purchases.isNotEmpty) {
        await repository.savePurchases(purchases);
        ref.read(amazonOcrResultProvider.notifier).state = purchases;
        
        // 購入履歴を更新
        ref.invalidate(amazonPurchaseHistoryProvider(user.id));
      }
      
      ref.read(amazonOcrProgressProvider.notifier).state = 1.0;
      
    } catch (e) {
      ref.read(amazonPurchaseErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(amazonPurchaseLoadingProvider.notifier).state = false;
      
      // 2秒後にプログレスをリセット
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(amazonOcrProgressProvider.notifier).state = 0.0;
      });
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<void> analyzeImageFromGallery({
    required String sourceType,
  }) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    ref.read(amazonPurchaseLoadingProvider.notifier).state = true;
    ref.read(amazonPurchaseErrorProvider.notifier).state = null;

    try {
      final repository = ref.read(amazonRepositoryProvider);
      final purchases = await repository.analyzeImageFromGallery(
        userId: user.id,
        sourceType: sourceType,
      );
      
      if (purchases.isNotEmpty) {
        await repository.savePurchases(purchases);
        ref.read(amazonOcrResultProvider.notifier).state = purchases;
        
        // 購入履歴を更新
        ref.invalidate(amazonPurchaseHistoryProvider(user.id));
      }
      
    } catch (e) {
      ref.read(amazonPurchaseErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(amazonPurchaseLoadingProvider.notifier).state = false;
    }
  }

  /// フィルターを更新
  void updateFilter(AmazonPurchaseFilter filter) {
    ref.read(amazonPurchaseFilterProvider.notifier).state = filter;
  }

  /// フィルターをリセット
  void resetFilter() {
    ref.read(amazonPurchaseFilterProvider.notifier).state = const AmazonPurchaseFilter();
  }

  /// 購入データを削除
  Future<void> deletePurchase(String purchaseId) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final repository = ref.read(amazonRepositoryProvider);
      await repository.deletePurchase(purchaseId);
      
      // 購入履歴を更新
      ref.invalidate(amazonPurchaseHistoryProvider(user.id));
      
    } catch (e) {
      ref.read(amazonPurchaseErrorProvider.notifier).state = e.toString();
    }
  }

  /// 購入データを編集
  Future<void> updatePurchase(AmazonPurchase purchase) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final repository = ref.read(amazonRepositoryProvider);
      await repository.updatePurchase(purchase);
      
      // 購入履歴を更新
      ref.invalidate(amazonPurchaseHistoryProvider(user.id));
      
    } catch (e) {
      ref.read(amazonPurchaseErrorProvider.notifier).state = e.toString();
    }
  }

  /// エラーをクリア
  void clearError() {
    ref.read(amazonPurchaseErrorProvider.notifier).state = null;
  }

  /// OCR結果をクリア
  void clearOcrResult() {
    ref.read(amazonOcrResultProvider.notifier).state = null;
  }
}

/// Loggerプロバイダー（他の場所で定義されていない場合）
final loggerProvider = Provider<Logger>((ref) => Logger());

/// フィルターを適用
List<AmazonPurchase> _applyFilter(List<AmazonPurchase> purchases, AmazonPurchaseFilter filter) {
  return purchases.where((purchase) {
    // 日付フィルター
    if (filter.startDate != null && purchase.purchaseDate.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && purchase.purchaseDate.isAfter(filter.endDate!)) {
      return false;
    }
    
    // カテゴリフィルター
    if (filter.categories != null && !filter.categories!.contains(purchase.category)) {
      return false;
    }
    
    // 価格フィルター
    if (filter.minPrice != null && purchase.price < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && purchase.price > filter.maxPrice!) {
      return false;
    }
    
    // ブランドフィルター
    if (filter.brands != null && purchase.productBrand != null && 
        !filter.brands!.contains(purchase.productBrand)) {
      return false;
    }
    
    // レビューフィルター
    if (filter.hasReview == true && purchase.reviewText == null) {
      return false;
    }
    
    // 返品除外フィルター
    if (filter.excludeReturned == true && purchase.isReturned) {
      return false;
    }
    
    // 検索クエリフィルター
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      if (!purchase.productName.toLowerCase().contains(query) &&
          (purchase.productBrand?.toLowerCase().contains(query) != true)) {
        return false;
      }
    }
    
    return true;
  }).toList();
}

/// 統計を計算
AmazonPurchaseStats _calculateStats(List<AmazonPurchase> purchases) {
  if (purchases.isEmpty) {
    return AmazonPurchaseStats(
      totalPurchases: 0,
      totalSpent: 0.0,
      currency: 'JPY',
      purchasesByCategory: {},
      spentByCategory: {},
      spentByMonth: {},
      topBrands: [],
      averageOrderValue: 0.0,
      totalReturns: 0,
      totalRefunds: 0,
      periodStart: DateTime.now(),
      periodEnd: DateTime.now(),
    );
  }

  final totalSpent = purchases.fold<double>(0.0, (sum, p) => sum + p.totalAmount);
  final totalReturns = purchases.where((p) => p.isReturned).length;
  final totalRefunds = purchases.where((p) => p.isRefunded).length;

  // カテゴリ別集計
  final purchasesByCategory = <AmazonPurchaseCategory, int>{};
  final spentByCategory = <AmazonPurchaseCategory, double>{};
  
  for (final purchase in purchases) {
    purchasesByCategory[purchase.category] = (purchasesByCategory[purchase.category] ?? 0) + 1;
    spentByCategory[purchase.category] = (spentByCategory[purchase.category] ?? 0.0) + purchase.totalAmount;
  }

  // 月別集計
  final spentByMonth = <String, double>{};
  for (final purchase in purchases) {
    final monthKey = '${purchase.purchaseDate.year}-${purchase.purchaseDate.month.toString().padLeft(2, '0')}';
    spentByMonth[monthKey] = (spentByMonth[monthKey] ?? 0.0) + purchase.totalAmount;
  }

  // トップブランド
  final brandCounts = <String, int>{};
  for (final purchase in purchases) {
    if (purchase.productBrand != null) {
      brandCounts[purchase.productBrand!] = (brandCounts[purchase.productBrand!] ?? 0) + 1;
    }
  }
  final topBrands = brandCounts.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

  return AmazonPurchaseStats(
    totalPurchases: purchases.length,
    totalSpent: totalSpent,
    currency: purchases.first.currency,
    purchasesByCategory: purchasesByCategory,
    spentByCategory: spentByCategory,
    spentByMonth: spentByMonth,
    topBrands: topBrands.map((e) => e.key).toList(),
    averageOrderValue: totalSpent / purchases.length,
    totalReturns: totalReturns,
    totalRefunds: totalRefunds,
    periodStart: purchases.map((p) => p.purchaseDate).reduce((a, b) => a.isBefore(b) ? a : b),
    periodEnd: purchases.map((p) => p.purchaseDate).reduce((a, b) => a.isAfter(b) ? a : b),
  );
}

/// カテゴリ別にグループ化
Map<AmazonPurchaseCategory, List<AmazonPurchase>> _groupByCategory(List<AmazonPurchase> purchases) {
  final grouped = <AmazonPurchaseCategory, List<AmazonPurchase>>{};
  
  for (final purchase in purchases) {
    grouped[purchase.category] ??= [];
    grouped[purchase.category]!.add(purchase);
  }
  
  return grouped;
}
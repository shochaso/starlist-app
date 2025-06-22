import 'dart:io';
import '../../../data/models/amazon_models.dart';
import '../services/amazon_api_service.dart';
import '../services/amazon_ocr_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/logging/logger.dart';
import '../../../core/errors/app_exceptions.dart';

/// Amazonデータ管理リポジトリ
/// API、OCR、データベースの操作を統合
class AmazonRepository {
  final AmazonApiService _apiService;
  final AmazonOcrService _ocrService;
  final DatabaseService _databaseService;
  final Logger _logger;

  AmazonRepository({
    required AmazonApiService apiService,
    required AmazonOcrService ocrService,
    DatabaseService? databaseService,
    Logger? logger,
  })  : _apiService = apiService,
        _ocrService = ocrService,
        _databaseService = databaseService ?? DatabaseService(),
        _logger = logger ?? Logger();

  /// ユーザーのAmazon購入履歴を取得
  Future<List<AmazonPurchase>> getPurchaseHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    try {
      _logger.info('Fetching Amazon purchase history for user: $userId');

      // キャッシュから取得を試行（強制リフレッシュでない場合）
      if (!forceRefresh) {
        final cachedPurchases = await _getPurchasesFromDatabase(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
        
        if (cachedPurchases.isNotEmpty) {
          _logger.info('Retrieved ${cachedPurchases.length} purchases from cache');
          return cachedPurchases;
        }
      }

      // APIから取得
      final apiPurchases = await _apiService.getPurchaseHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // データベースに保存
      if (apiPurchases.isNotEmpty) {
        await _savePurchasesToDatabase(apiPurchases);
      }

      _logger.info('Retrieved ${apiPurchases.length} purchases from API');
      return apiPurchases;

    } catch (e) {
      _logger.error('Failed to fetch Amazon purchase history', e);
      
      // エラー時はキャッシュから取得を試行
      try {
        final fallbackPurchases = await _getPurchasesFromDatabase(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
        
        if (fallbackPurchases.isNotEmpty) {
          _logger.info('Fallback: Retrieved ${fallbackPurchases.length} purchases from cache');
          return fallbackPurchases;
        }
      } catch (dbError) {
        _logger.warning('Fallback database query also failed: $dbError');
      }
      
      throw ApiException(
        message: 'Failed to fetch Amazon purchase history',
        details: e.toString(),
      );
    }
  }

  /// 画像パスからOCR解析を実行
  Future<List<AmazonPurchase>> analyzePurchaseImageFromPath({
    required String userId,
    required String imagePath,
    required String sourceType,
  }) async {
    try {
      _logger.info('Analyzing Amazon purchase image from path: $imagePath');
      
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw ApiException(
          message: 'Image file not found',
          details: 'File does not exist at path: $imagePath',
        );
      }

      final purchases = await _ocrService.analyzeAmazonPurchaseImage(
        userId: userId,
        imageFile: imageFile,
        sourceType: sourceType,
      );

      _logger.info('OCR analysis completed: ${purchases.length} purchases extracted');
      return purchases;

    } catch (e) {
      _logger.error('Failed to analyze Amazon purchase image', e);
      throw ApiException(
        message: 'Failed to analyze purchase image',
        details: e.toString(),
      );
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<List<AmazonPurchase>> analyzeImageFromGallery({
    required String userId,
    required String sourceType,
  }) async {
    try {
      _logger.info('Analyzing Amazon purchase image from gallery');
      
      final purchases = await _ocrService.analyzeImageFromGallery(
        userId: userId,
        sourceType: sourceType,
      );

      _logger.info('Gallery OCR analysis completed: ${purchases.length} purchases extracted');
      return purchases;

    } catch (e) {
      _logger.error('Failed to analyze image from gallery', e);
      rethrow;
    }
  }

  /// 購入データをデータベースに保存
  Future<void> savePurchases(List<AmazonPurchase> purchases) async {
    try {
      _logger.info('Saving ${purchases.length} Amazon purchases to database');
      await _savePurchasesToDatabase(purchases);
    } catch (e) {
      _logger.error('Failed to save Amazon purchases', e);
      throw DatabaseException(
        message: 'Failed to save purchases to database',
        details: e.toString(),
      );
    }
  }

  /// 購入データを更新
  Future<void> updatePurchase(AmazonPurchase purchase) async {
    try {
      _logger.info('Updating Amazon purchase: ${purchase.id}');
      
      final updatedPurchase = purchase.copyWith(
        updatedAt: DateTime.now(),
      );

      await _databaseService.supabase
          .from('amazon_purchases')
          .update(updatedPurchase.toJson())
          .eq('id', purchase.id);

      _logger.info('Amazon purchase updated successfully');

    } catch (e) {
      _logger.error('Failed to update Amazon purchase', e);
      throw DatabaseException(
        message: 'Failed to update purchase',
        details: e.toString(),
      );
    }
  }

  /// 購入データを削除
  Future<void> deletePurchase(String purchaseId) async {
    try {
      _logger.info('Deleting Amazon purchase: $purchaseId');
      
      await _databaseService.supabase
          .from('amazon_purchases')
          .delete()
          .eq('id', purchaseId);

      _logger.info('Amazon purchase deleted successfully');

    } catch (e) {
      _logger.error('Failed to delete Amazon purchase', e);
      throw DatabaseException(
        message: 'Failed to delete purchase',
        details: e.toString(),
      );
    }
  }

  /// 商品詳細情報を取得
  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      _logger.info('Fetching product details for: $productId');
      return await _apiService.getProductDetails(productId: productId);
    } catch (e) {
      _logger.error('Failed to fetch product details', e);
      return null;
    }
  }

  /// 商品を検索
  Future<List<Map<String, dynamic>>> searchProducts({
    required String keywords,
    String searchIndex = 'All',
    int itemCount = 10,
  }) async {
    try {
      _logger.info('Searching Amazon products: $keywords');
      return await _apiService.searchProducts(
        keywords: keywords,
        searchIndex: searchIndex,
        itemCount: itemCount,
      );
    } catch (e) {
      _logger.error('Failed to search Amazon products', e);
      return [];
    }
  }

  /// ユーザーの購入統計を取得
  Future<AmazonPurchaseStats?> getPurchaseStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.info('Calculating Amazon purchase stats for user: $userId');
      
      final purchases = await getPurchaseHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 1000, // 統計用に多めに取得
      );

      if (purchases.isEmpty) {
        return null;
      }

      return _calculatePurchaseStats(purchases, startDate, endDate);

    } catch (e) {
      _logger.error('Failed to calculate purchase stats', e);
      return null;
    }
  }

  /// データベースから購入履歴を取得
  Future<List<AmazonPurchase>> _getPurchasesFromDatabase({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      var query = _databaseService.supabase
          .from('amazon_purchases')
          .select()
          .eq('user_id', userId)
          .order('purchase_date', ascending: false)
          .limit(limit);

      if (startDate != null) {
        query = query.gte('purchase_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('purchase_date', endDate.toIso8601String());
      }

      final response = await query;
      
      return (response as List)
          .map((json) => AmazonPurchase.fromJson(json))
          .toList();

    } catch (e) {
      _logger.error('Failed to fetch purchases from database', e);
      rethrow;
    }
  }

  /// データベースに購入データを保存
  Future<void> _savePurchasesToDatabase(List<AmazonPurchase> purchases) async {
    try {
      final purchaseJsonList = purchases.map((p) => p.toJson()).toList();
      
      // upsert（挿入または更新）を使用して重複を回避
      await _databaseService.supabase
          .from('amazon_purchases')
          .upsert(purchaseJsonList);

    } catch (e) {
      _logger.error('Failed to save purchases to database', e);
      rethrow;
    }
  }

  /// 購入統計を計算
  AmazonPurchaseStats _calculatePurchaseStats(
    List<AmazonPurchase> purchases,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final totalSpent = purchases.fold<double>(0.0, (sum, p) => sum + p.totalAmount);
    final totalReturns = purchases.where((p) => p.isReturned).length;
    final totalRefunds = purchases.where((p) => p.isRefunded).length;

    // カテゴリ別集計
    final purchasesByCategory = <AmazonPurchaseCategory, int>{};
    final spentByCategory = <AmazonPurchaseCategory, double>{};
    
    for (final purchase in purchases) {
      purchasesByCategory[purchase.category] = 
          (purchasesByCategory[purchase.category] ?? 0) + 1;
      spentByCategory[purchase.category] = 
          (spentByCategory[purchase.category] ?? 0.0) + purchase.totalAmount;
    }

    // 月別支出集計
    final spentByMonth = <String, double>{};
    for (final purchase in purchases) {
      final monthKey = '${purchase.purchaseDate.year}-${purchase.purchaseDate.month.toString().padLeft(2, '0')}';
      spentByMonth[monthKey] = (spentByMonth[monthKey] ?? 0.0) + purchase.totalAmount;
    }

    // トップブランド集計
    final brandCounts = <String, int>{};
    for (final purchase in purchases) {
      if (purchase.productBrand != null) {
        brandCounts[purchase.productBrand!] = 
            (brandCounts[purchase.productBrand!] ?? 0) + 1;
      }
    }
    
    final topBrands = brandCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    // 期間の設定
    final actualStartDate = startDate ?? 
        purchases.map((p) => p.purchaseDate).reduce((a, b) => a.isBefore(b) ? a : b);
    final actualEndDate = endDate ?? 
        purchases.map((p) => p.purchaseDate).reduce((a, b) => a.isAfter(b) ? a : b);

    return AmazonPurchaseStats(
      totalPurchases: purchases.length,
      totalSpent: totalSpent,
      currency: purchases.isNotEmpty ? purchases.first.currency : 'JPY',
      purchasesByCategory: purchasesByCategory,
      spentByCategory: spentByCategory,
      spentByMonth: spentByMonth,
      topBrands: topBrands.take(5).map((e) => e.key).toList(),
      averageOrderValue: purchases.isNotEmpty ? totalSpent / purchases.length : 0.0,
      totalReturns: totalReturns,
      totalRefunds: totalRefunds,
      periodStart: actualStartDate,
      periodEnd: actualEndDate,
    );
  }

  /// リソースをクリーンアップ
  void dispose() {
    _apiService.dispose();
  }
}
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/amazon_models.dart';
import '../../ocr/ocr_service.dart';
import '../../../core/logging/logger.dart';
import '../../../core/errors/app_exceptions.dart';

/// Amazon購入履歴OCR解析サービス
/// 既存のOCRServiceを拡張してAmazon特化の解析機能を提供
class AmazonOcrService {
  final OCRService _ocrService;
  final Logger _logger;
  final ImagePicker _imagePicker;

  AmazonOcrService({
    OCRService? ocrService,
    Logger? logger,
    ImagePicker? imagePicker,
  })  : _ocrService = ocrService ?? OCRService(),
        _logger = logger ?? Logger(),
        _imagePicker = imagePicker ?? ImagePicker();

  /// Amazon購入履歴画像をOCR解析
  Future<List<AmazonPurchase>> analyzeAmazonPurchaseImage({
    required String userId,
    required File imageFile,
    required String sourceType, // 'email', 'receipt', 'order_history', 'invoice'
  }) async {
    try {
      _logger.info('Starting Amazon purchase OCR analysis for user: $userId');
      
      // 画像を圧縮してメモリ使用量を最適化
      final compressedImage = await _compressImage(imageFile);
      
      // 基本OCR解析を実行
      final ocrResult = await _ocrService.extractTextFromImage(compressedImage);
      
      if (ocrResult['text'] == null || ocrResult['text'].isEmpty) {
        throw ApiException(
          message: 'OCR failed to extract text from image',
          details: 'No text content found in the image',
        );
      }
      
      // Amazon特化のテキスト解析
      final purchases = await _extractAmazonPurchasesFromText(
        userId: userId,
        ocrText: ocrResult['text'],
        sourceType: sourceType,
        confidence: ocrResult['confidence'] ?? 0.0,
      );
      
      _logger.info('Extracted ${purchases.length} Amazon purchases from OCR');
      return purchases;
      
    } catch (e) {
      _logger.error('Amazon OCR analysis failed', e);
      throw ApiException(
        message: 'Failed to analyze Amazon purchase image',
        details: e.toString(),
      );
    } finally {
      // 一時ファイルをクリーンアップ
      _cleanupTempFiles();
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<List<AmazonPurchase>> analyzeImageFromGallery({
    required String userId,
    required String sourceType,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        throw ApiException(
          message: 'No image selected',
          details: 'User cancelled image selection',
        );
      }

      final imageFile = File(pickedFile.path);
      return await analyzeAmazonPurchaseImage(
        userId: userId,
        imageFile: imageFile,
        sourceType: sourceType,
      );
      
    } catch (e) {
      _logger.error('Failed to analyze image from gallery', e);
      rethrow;
    }
  }

  /// Amazon特化のテキスト解析
  Future<List<AmazonPurchase>> _extractAmazonPurchasesFromText({
    required String userId,
    required String ocrText,
    required String sourceType,
    required double confidence,
  }) async {
    final purchases = <AmazonPurchase>[];
    
    try {
      // Amazon注文確認メールパターン
      if (sourceType == 'email') {
        purchases.addAll(await _extractFromEmailPattern(userId, ocrText));
      }
      
      // Amazon注文履歴画面パターン
      else if (sourceType == 'order_history') {
        purchases.addAll(await _extractFromOrderHistoryPattern(userId, ocrText));
      }
      
      // Amazon領収書パターン
      else if (sourceType == 'receipt' || sourceType == 'invoice') {
        purchases.addAll(await _extractFromReceiptPattern(userId, ocrText));
      }
      
      // 汎用パターン（フォールバック）
      else {
        purchases.addAll(await _extractFromGenericPattern(userId, ocrText));
      }
      
    } catch (e) {
      _logger.warning('Pattern extraction failed, trying fallback: $e');
      purchases.addAll(await _extractFromGenericPattern(userId, ocrText));
    }
    
    return purchases;
  }

  /// Amazon注文確認メールからの抽出
  Future<List<AmazonPurchase>> _extractFromEmailPattern(String userId, String text) async {
    final purchases = <AmazonPurchase>[];
    
    // 注文番号パターン
    final orderNumberRegex = RegExp(r'注文番号[:：]\s*([0-9A-Z-]{15,25})', caseSensitive: false);
    final orderMatch = orderNumberRegex.firstMatch(text);
    final orderId = orderMatch?.group(1) ?? 'UNKNOWN_ORDER';
    
    // 商品と価格のパターン
    final productPriceRegex = RegExp(r'(.+?)\s+¥([\d,]+)', multiLine: true);
    final productMatches = productPriceRegex.allMatches(text);
    
    // 配送日パターン
    final deliveryDateRegex = RegExp(r'配送日[:：]\s*(\d{4})年(\d{1,2})月(\d{1,2})日');
    final deliveryMatch = deliveryDateRegex.firstMatch(text);
    DateTime? deliveryDate;
    if (deliveryMatch != null) {
      deliveryDate = DateTime(
        int.parse(deliveryMatch.group(1)!),
        int.parse(deliveryMatch.group(2)!),
        int.parse(deliveryMatch.group(3)!),
      );
    }
    
    int productIndex = 0;
    for (final match in productMatches) {
      final productName = match.group(1)?.trim();
      final priceString = match.group(2)?.replaceAll(',', '');
      
      if (productName != null && priceString != null) {
        final price = double.tryParse(priceString);
        if (price != null && price > 0) {
          final purchase = AmazonPurchase(
            id: '${orderId}_$productIndex',
            userId: userId,
            orderId: orderId,
            productId: 'PRODUCT_${DateTime.now().millisecondsSinceEpoch}_$productIndex',
            productName: productName,
            productBrand: _extractBrandFromProductName(productName),
            price: price,
            currency: 'JPY',
            quantity: 1,
            category: _categorizeProduct(productName),
            purchaseDate: DateTime.now().subtract(const Duration(days: 1)), // 推定
            deliveryDate: deliveryDate,
            imageUrl: null,
            productUrl: null,
            reviewId: null,
            rating: null,
            reviewText: null,
            isReturned: false,
            isRefunded: false,
            metadata: {
              'source': 'email_ocr',
              'extraction_method': 'email_pattern',
              'original_text_snippet': match.group(0),
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          purchases.add(purchase);
          productIndex++;
        }
      }
    }
    
    return purchases;
  }

  /// Amazon注文履歴画面からの抽出
  Future<List<AmazonPurchase>> _extractFromOrderHistoryPattern(String userId, String text) async {
    final purchases = <AmazonPurchase>[];
    
    // 注文履歴の一般的なパターン
    final historyItemRegex = RegExp(
      r'(.+?)\s+配送済み\s+¥([\d,]+)',
      multiLine: true,
      caseSensitive: false,
    );
    
    final matches = historyItemRegex.allMatches(text);
    int itemIndex = 0;
    
    for (final match in matches) {
      final productName = match.group(1)?.trim();
      final priceString = match.group(2)?.replaceAll(',', '');
      
      if (productName != null && priceString != null) {
        final price = double.tryParse(priceString);
        if (price != null && price > 0) {
          final purchase = AmazonPurchase(
            id: 'history_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
            userId: userId,
            orderId: 'ORDER_HISTORY_$itemIndex',
            productId: 'PRODUCT_HISTORY_$itemIndex',
            productName: productName,
            productBrand: _extractBrandFromProductName(productName),
            price: price,
            currency: 'JPY',
            quantity: 1,
            category: _categorizeProduct(productName),
            purchaseDate: DateTime.now().subtract(Duration(days: itemIndex * 7)), // 推定
            deliveryDate: null,
            imageUrl: null,
            productUrl: null,
            reviewId: null,
            rating: null,
            reviewText: null,
            isReturned: false,
            isRefunded: false,
            metadata: {
              'source': 'order_history_ocr',
              'extraction_method': 'history_pattern',
              'original_text_snippet': match.group(0),
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          purchases.add(purchase);
          itemIndex++;
        }
      }
    }
    
    return purchases;
  }

  /// Amazon領収書からの抽出
  Future<List<AmazonPurchase>> _extractFromReceiptPattern(String userId, String text) async {
    final purchases = <AmazonPurchase>[];
    
    // 領収書の商品行パターン
    final receiptItemRegex = RegExp(
      r'(\d+)\s+(.+?)\s+¥([\d,]+)',
      multiLine: true,
    );
    
    final matches = receiptItemRegex.allMatches(text);
    int itemIndex = 0;
    
    for (final match in matches) {
      final quantityString = match.group(1);
      final productName = match.group(2)?.trim();
      final priceString = match.group(3)?.replaceAll(',', '');
      
      if (productName != null && priceString != null && quantityString != null) {
        final price = double.tryParse(priceString);
        final quantity = int.tryParse(quantityString);
        
        if (price != null && quantity != null && price > 0 && quantity > 0) {
          final purchase = AmazonPurchase(
            id: 'receipt_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
            userId: userId,
            orderId: 'ORDER_RECEIPT_$itemIndex',
            productId: 'PRODUCT_RECEIPT_$itemIndex',
            productName: productName,
            productBrand: _extractBrandFromProductName(productName),
            price: price / quantity, // 単価計算
            currency: 'JPY',
            quantity: quantity,
            category: _categorizeProduct(productName),
            purchaseDate: DateTime.now(), // 推定
            deliveryDate: null,
            imageUrl: null,
            productUrl: null,
            reviewId: null,
            rating: null,
            reviewText: null,
            isReturned: false,
            isRefunded: false,
            metadata: {
              'source': 'receipt_ocr',
              'extraction_method': 'receipt_pattern',
              'original_text_snippet': match.group(0),
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          purchases.add(purchase);
          itemIndex++;
        }
      }
    }
    
    return purchases;
  }

  /// 汎用パターンからの抽出（フォールバック）
  Future<List<AmazonPurchase>> _extractFromGenericPattern(String userId, String text) async {
    final purchases = <AmazonPurchase>[];
    
    // 汎用的な商品名＋価格パターン
    final genericItemRegex = RegExp(
      r'(.{5,50}?)\s*¥\s*([\d,]+)',
      multiLine: true,
    );
    
    final matches = genericItemRegex.allMatches(text);
    int itemIndex = 0;
    
    for (final match in matches.take(10)) { // 最大10件に制限
      final productName = match.group(1)?.trim();
      final priceString = match.group(2)?.replaceAll(',', '');
      
      if (productName != null && priceString != null && productName.length >= 3) {
        final price = double.tryParse(priceString);
        
        if (price != null && price > 0 && price < 1000000) { // 現実的な価格範囲
          final purchase = AmazonPurchase(
            id: 'generic_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
            userId: userId,
            orderId: 'ORDER_GENERIC_$itemIndex',
            productId: 'PRODUCT_GENERIC_$itemIndex',
            productName: productName,
            productBrand: _extractBrandFromProductName(productName),
            price: price,
            currency: 'JPY',
            quantity: 1,
            category: _categorizeProduct(productName),
            purchaseDate: DateTime.now(),
            deliveryDate: null,
            imageUrl: null,
            productUrl: null,
            reviewId: null,
            rating: null,
            reviewText: null,
            isReturned: false,
            isRefunded: false,
            metadata: {
              'source': 'generic_ocr',
              'extraction_method': 'generic_pattern',
              'original_text_snippet': match.group(0),
              'confidence': 'low',
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          purchases.add(purchase);
          itemIndex++;
        }
      }
    }
    
    return purchases;
  }

  /// 商品名からブランドを抽出
  String? _extractBrandFromProductName(String productName) {
    final commonBrands = [
      'Amazon', 'Apple', 'Sony', 'Panasonic', 'Samsung', 'Nintendo',
      'Microsoft', 'Google', 'Anker', 'BOSE', 'Canon', 'Nikon',
      'MUJI', 'UNIQLO', 'Nike', 'Adidas', 'ルルルン', 'DHC',
    ];
    
    final upperProductName = productName.toUpperCase();
    for (final brand in commonBrands) {
      if (upperProductName.contains(brand.toUpperCase())) {
        return brand;
      }
    }
    
    return null;
  }

  /// 商品名からカテゴリを推定
  AmazonPurchaseCategory _categorizeProduct(String productName) {
    final productLower = productName.toLowerCase();
    
    // 家電・PC
    if (productLower.contains('echo') || productLower.contains('fire') ||
        productLower.contains('kindle') || productLower.contains('iphone') ||
        productLower.contains('ipad') || productLower.contains('pc') ||
        productLower.contains('パソコン') || productLower.contains('スマホ') ||
        productLower.contains('イヤホン') || productLower.contains('スピーカー')) {
      return AmazonPurchaseCategory.electronics;
    }
    
    // 本・雑誌
    if (productLower.contains('本') || productLower.contains('書籍') ||
        productLower.contains('雑誌') || productLower.contains('漫画') ||
        productLower.contains('小説')) {
      return AmazonPurchaseCategory.books;
    }
    
    // ビューティー
    if (productLower.contains('化粧') || productLower.contains('コスメ') ||
        productLower.contains('スキンケア') || productLower.contains('ルルルン') ||
        productLower.contains('シャンプー') || productLower.contains('美容')) {
      return AmazonPurchaseCategory.beauty;
    }
    
    // ファッション
    if (productLower.contains('服') || productLower.contains('シャツ') ||
        productLower.contains('パンツ') || productLower.contains('靴') ||
        productLower.contains('バッグ') || productLower.contains('時計')) {
      return AmazonPurchaseCategory.clothing;
    }
    
    // 食品・飲料
    if (productLower.contains('食品') || productLower.contains('飲料') ||
        productLower.contains('お茶') || productLower.contains('コーヒー') ||
        productLower.contains('お米') || productLower.contains('調味料')) {
      return AmazonPurchaseCategory.food;
    }
    
    return AmazonPurchaseCategory.other;
  }

  /// 画像を圧縮してメモリ使用量を最適化
  Future<File> _compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 600,
        format: CompressFormat.jpeg,
      );
      
      return compressedFile != null ? File(compressedFile.path) : imageFile;
    } catch (e) {
      _logger.warning('Image compression failed, using original: $e');
      return imageFile;
    }
  }

  /// 一時ファイルのクリーンアップ
  Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('compressed_')) {
          final stats = await file.stat();
          final age = DateTime.now().difference(stats.modified);
          
          // 1時間以上古い一時ファイルを削除
          if (age.inHours > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to cleanup temp files: $e');
    }
  }
}
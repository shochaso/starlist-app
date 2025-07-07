import 'dart:math';

class AmazonPurchaseItem {
  final String productName;
  final String price;
  final String orderNumber;
  final String orderDate;
  final String? category;
  final String? seller;
  final String? deliveryStatus;
  final double confidence;
  final String rawText;

  AmazonPurchaseItem({
    required this.productName,
    required this.price,
    required this.orderNumber,
    required this.orderDate,
    this.category,
    this.seller,
    this.deliveryStatus,
    required this.confidence,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': productName,
      'price': price,
      'site': 'Amazon',
      'orderNumber': orderNumber,
      'orderDate': orderDate,
      'category': category,
      'seller': seller,
      'deliveryStatus': deliveryStatus,
      'confidence': confidence,
      'rawText': rawText,
    };
  }
}

class AmazonPurchaseParser {
  static const double minConfidenceThreshold = 0.6;

  static List<AmazonPurchaseItem> parseText(String text) {
    if (text.trim().isEmpty) return [];

    final List<AmazonPurchaseItem> items = [];
    
    // 複数のパース戦略を順番に試行
    items.addAll(_parseOrderHistory(text));
    items.addAll(_parseOrderDetails(text));
    items.addAll(_parseEmailConfirmation(text));
    items.addAll(_parseReceiptFormat(text));
    items.addAll(_parseGenericFormat(text));

    // 重複除去と信頼度によるフィルタリング
    final uniqueItems = _removeDuplicates(items);
    final filteredItems = uniqueItems
        .where((item) => item.confidence >= minConfidenceThreshold)
        .toList();

    // 信頼度によるソート
    filteredItems.sort((a, b) => b.confidence.compareTo(a.confidence));

    return filteredItems;
  }

  // Amazon注文履歴ページ形式のパース（OCRデータに特化）
  static List<AmazonPurchaseItem> _parseOrderHistory(String text) {
    final List<AmazonPurchaseItem> items = [];
    
    // ユーザーデータのようなOCR形式用パターン
    // 商品名が複数行に分かれ、配送日情報が含まれる形式
    final deliveryPattern = RegExp(
      r'(\d{1,2}月\d{1,2}日[にへ].*?(?:お?届け済み|受取済み))',
      caseSensitive: false,
    );

    final lines = text.split('\n');
    List<String> currentProductLines = [];
    String? currentDeliveryInfo;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // 配送情報の検出
      if (deliveryPattern.hasMatch(line)) {
        // 前の商品情報があれば処理
        if (currentProductLines.isNotEmpty) {
          final item = _createItemFromLines(currentProductLines, currentDeliveryInfo);
          if (item != null) items.add(item);
        }
        
        currentDeliveryInfo = line;
        currentProductLines.clear();
      } 
      // 価格情報や注文に関係ない行をスキップ
      else if (!_isSystemLine(line)) {
        currentProductLines.add(line);
      }
    }
    
    // 最後の商品を処理
    if (currentProductLines.isNotEmpty) {
      final item = _createItemFromLines(currentProductLines, currentDeliveryInfo);
      if (item != null) items.add(item);
    }

    return items;
  }

  static AmazonPurchaseItem? _createItemFromLines(List<String> productLines, String? deliveryInfo) {
    if (productLines.isEmpty) return null;
    
    // 商品名を結合（途中で切れている商品名を復元）
    String productName = '';
    for (final line in productLines) {
      final cleanLine = line.replaceAll(RegExp(r'^[・▶＞>\s]+'), '').trim();
      if (cleanLine.isNotEmpty && !_isSystemLine(cleanLine)) {
        if (productName.isNotEmpty && !productName.endsWith(' ') && !cleanLine.startsWith(' ')) {
          productName += ' ';
        }
        productName += cleanLine;
      }
    }
    
    productName = _cleanProductName(productName);
    
    // 商品名が短すぎる場合はスキップ
    if (productName.length < 8) return null;
    
    // 配送日から日付を抽出
    String? orderDate;
    if (deliveryInfo != null) {
      final dateMatch = RegExp(r'(\d{1,2}月\d{1,2}日)').firstMatch(deliveryInfo);
      if (dateMatch != null) {
        orderDate = '2024/${dateMatch.group(1)!.replaceAll('月', '/').replaceAll('日', '')}';
      }
    }
    
    // 価格は推定（実際のOCRテキストに価格情報がない場合）
    String price = '価格不明';
    
    final confidence = _calculateConfidence({
      'hasProduct': productName.length > 15,
      'hasPrice': false, // OCRデータには価格情報がない
      'hasDate': orderDate != null,
      'amazonFormat': true,
      'deliveryInfo': deliveryInfo != null,
    });

    return AmazonPurchaseItem(
      productName: productName,
      price: price,
      orderNumber: 'N/A',
      orderDate: orderDate ?? 'N/A',
      deliveryStatus: deliveryInfo,
      confidence: confidence,
      rawText: productLines.join('\n'),
    );
  }

  static bool _isSystemLine(String line) {
    final systemPatterns = [
      RegExp(r'^\d+[）)]'), // 番号付きリスト
      RegExp(r'^[・▶＞>\s]*$'), // 記号のみ
      RegExp(r'^\d+$'), // 数字のみ
      RegExp(r'^[a-zA-Z\s]*$'), // アルファベットのみ
      RegExp(r'(meiji|明治|arau|HITACHI|熱)'), // ブランド名の断片
    ];
    
    return systemPatterns.any((pattern) => pattern.hasMatch(line)) || line.length < 3;
  }

  // Amazon注文詳細ページ形式のパース
  static List<AmazonPurchaseItem> _parseOrderDetails(String text) {
    final items = <AmazonPurchaseItem>[];
    
    // 注文詳細ページの構造化データパターン
    final orderDetailPattern = RegExp(
      r'(?:商品名|タイトル)[：:\s]*([^\n]{10,100})[\s\S]*?(?:価格|料金)[：:\s]*[¥￥]\s*([0-9,]+)',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = orderDetailPattern.allMatches(text);
    for (final match in matches) {
      final product = _cleanProductName(match.group(1)!);
      final price = '¥${match.group(2)}';
      
      final confidence = _calculateConfidence({
        'hasProduct': product.length > 10,
        'hasPrice': true,
        'amazonKeywords': _containsAmazonKeywords(text),
        'structuredFormat': true,
      });

      if (confidence >= minConfidenceThreshold) {
        items.add(AmazonPurchaseItem(
          productName: product,
          price: price,
          orderNumber: _extractOrderNumber(text) ?? 'N/A',
          orderDate: _extractDate(text) ?? 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // Eメール確認形式のパース
  static List<AmazonPurchaseItem> _parseEmailConfirmation(String text) {
    final items = <AmazonPurchaseItem>[];
    
    if (!text.toLowerCase().contains('amazon') && 
        !text.contains('アマゾン') && 
        !text.contains('注文確認')) {
      return items;
    }

    // メール形式の商品リストパターン
    final emailPattern = RegExp(
      r'([^\n]{15,80})[\s\S]*?[¥￥]\s*([0-9,]+)',
      multiLine: true,
    );

    final matches = emailPattern.allMatches(text);
    for (final match in matches) {
      final productCandidate = match.group(1)!.trim();
      
      // 商品名らしいかチェック
      if (_isLikelyProductName(productCandidate)) {
        final product = _cleanProductName(productCandidate);
        final price = '¥${match.group(2)}';
        
        final confidence = _calculateConfidence({
          'hasProduct': true,
          'hasPrice': true,
          'amazonKeywords': true,
          'emailFormat': true,
        });

        items.add(AmazonPurchaseItem(
          productName: product,
          price: price,
          orderNumber: _extractOrderNumber(text) ?? 'N/A',
          orderDate: _extractDate(text) ?? 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // レシート形式のパース
  static List<AmazonPurchaseItem> _parseReceiptFormat(String text) {
    final items = <AmazonPurchaseItem>[];
    
    // レシート形式（商品名 価格の並び）
    final receiptPattern = RegExp(
      r'^([^\d¥￥\n]{10,60})\s+[¥￥]\s*([0-9,]+)',
      multiLine: true,
    );

    final matches = receiptPattern.allMatches(text);
    for (final match in matches) {
      final product = _cleanProductName(match.group(1)!);
      final price = '¥${match.group(2)}';
      
      final confidence = _calculateConfidence({
        'hasProduct': product.length > 10,
        'hasPrice': true,
        'receiptFormat': true,
      });

      if (confidence >= minConfidenceThreshold) {
        items.add(AmazonPurchaseItem(
          productName: product,
          price: price,
          orderNumber: 'N/A',
          orderDate: _extractDate(text) ?? 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // 汎用形式のパース（最後の手段）
  static List<AmazonPurchaseItem> _parseGenericFormat(String text) {
    final items = <AmazonPurchaseItem>[];
    
    // 汎用的なパターンマッチング
    final lines = text.split('\n');
    String? productCandidate;
    String? priceCandidate;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 価格らしい行
      final priceMatch = RegExp(r'[¥￥]\s*([0-9,]+)').firstMatch(trimmedLine);
      if (priceMatch != null) {
        priceCandidate = '¥${priceMatch.group(1)}';
        
        // 直前の行から商品名を推測
        if (productCandidate != null && _isLikelyProductName(productCandidate)) {
          final confidence = _calculateConfidence({
            'hasProduct': productCandidate.length > 10,
            'hasPrice': true,
            'genericFormat': true,
          });

          if (confidence >= minConfidenceThreshold) {
            items.add(AmazonPurchaseItem(
              productName: _cleanProductName(productCandidate),
              price: priceCandidate,
              orderNumber: 'N/A',
              orderDate: 'N/A',
              confidence: confidence,
              rawText: '$productCandidate $priceCandidate',
            ));
          }
        }
      }
      
      // 商品名の候補
      if (trimmedLine.length > 10 && 
          !trimmedLine.contains('¥') && 
          !trimmedLine.contains('￥') &&
          !_isDateLike(trimmedLine)) {
        productCandidate = trimmedLine;
      }
    }

    return items;
  }

  // ユーティリティメソッド群
  static String _cleanProductName(String name) {
    return name
        .replaceAll(RegExp(r'[【】\[\]()]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _normalizeDate(String date) {
    final match = RegExp(r'(\d{4})[/年-]\s*(\d{1,2})[/月-]\s*(\d{1,2})').firstMatch(date);
    if (match != null) {
      final year = match.group(1);
      final month = match.group(2)!.padLeft(2, '0');
      final day = match.group(3)!.padLeft(2, '0');
      return '$year/$month/$day';
    }
    return date;
  }

  static String? _extractOrderNumber(String text) {
    final patterns = [
      RegExp(r'注文番号[：:\s]*([0-9]{3}-[0-9]{7}-[0-9]{7})'),
      RegExp(r'Order\s*[#№]?\s*([0-9]{3}-[0-9]{7}-[0-9]{7})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }

  static String? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{4})[/年-]\s*(\d{1,2})[/月-]\s*(\d{1,2})'),
      RegExp(r'注文日[：:\s]*(\d{4}[/年-]\d{1,2}[/月-]\d{1,2})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return _normalizeDate(match.group(0)!);
    }
    return null;
  }

  static bool _isLikelyProductName(String text) {
    if (text.length < 10) return false;
    if (_isDateLike(text)) return false;
    if (RegExp(r'^[0-9\s-]+$').hasMatch(text)) return false;
    if (text.contains('注文') || text.contains('配送') || text.contains('amazon')) return false;
    return true;
  }

  static bool _isDateLike(String text) {
    return RegExp(r'\d{4}[/年-]\d{1,2}[/月-]\d{1,2}').hasMatch(text) ||
           RegExp(r'\d{1,2}[/月]\d{1,2}[日]').hasMatch(text);
  }

  static bool _containsAmazonKeywords(String text) {
    final keywords = ['amazon', 'アマゾン', '注文確認', 'order', 'amazon.co.jp'];
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  static double _calculateConfidence(Map<String, dynamic> factors) {
    double score = 0.0;
    
    if (factors['hasOrderNumber'] == true) score += 0.25;
    if (factors['hasProduct'] == true) score += 0.3;
    if (factors['hasPrice'] == true) score += 0.15;
    if (factors['hasDate'] == true) score += 0.15;
    if (factors['amazonKeywords'] == true) score += 0.1;
    if (factors['structuredFormat'] == true) score += 0.1;
    if (factors['emailFormat'] == true) score += 0.08;
    if (factors['receiptFormat'] == true) score += 0.05;
    if (factors['amazonFormat'] == true) score += 0.2; // OCR形式ボーナス
    if (factors['deliveryInfo'] == true) score += 0.15; // 配送情報ボーナス
    
    // 商品名の長さボーナス
    if (factors['hasProduct'] == true) {
      score += 0.1; // 基本的な商品名ボーナス
    }

    return min(1.0, score);
  }

  static List<AmazonPurchaseItem> _removeDuplicates(List<AmazonPurchaseItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.productName}_${item.price}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
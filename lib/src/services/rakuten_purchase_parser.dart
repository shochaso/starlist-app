class RakutenPurchaseItem {
  final String productName;
  final String price;
  final String? quantity;
  final String? shopName;
  final String orderNumber;
  final String orderDate;
  final String? pointsEarned;
  final String? category;
  final double confidence;
  final String rawText;

  RakutenPurchaseItem({
    required this.productName,
    required this.price,
    this.quantity,
    this.shopName,
    required this.orderNumber,
    required this.orderDate,
    this.pointsEarned,
    this.category,
    required this.confidence,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': productName,
      'price': price,
      'quantity': quantity,
      'site': shopName ?? '楽天市場',
      'orderNumber': orderNumber,
      'orderDate': orderDate,
      'pointsEarned': pointsEarned,
      'category': category,
      'confidence': confidence,
      'rawText': rawText,
    };
  }
}

class RakutenPurchaseParser {
  static const double minConfidenceThreshold = 0.6;

  static List<RakutenPurchaseItem> parseText(String text) {
    if (text.trim().isEmpty) return [];

    final List<RakutenPurchaseItem> items = [];
    
    // 複数のパース戦略を順番に試行
    items.addAll(_parseOrderHistory(text));
    items.addAll(_parseEmailFormat(text));
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

  // 楽天市場注文履歴形式のパース
  static List<RakutenPurchaseItem> _parseOrderHistory(String text) {
    final items = <RakutenPurchaseItem>[];
    
    if (!_containsRakutenKeywords(text)) return items;

    final lines = text.split('\n');
    String? currentProduct;
    String? currentPrice;
    String? currentShop;
    String? currentOrderNumber;
    String? currentDate;
    String? currentPoints;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // 注文番号の検出（楽天形式：数字14桁など）
      final orderNumberMatch = RegExp(r'注文番号[：:\s]*(\d{10,})', caseSensitive: false).firstMatch(line);
      if (orderNumberMatch != null) {
        currentOrderNumber = orderNumberMatch.group(1);
        continue;
      }

      // 日付の検出
      final dateMatch = RegExp(r'(\d{4})[年/]\s*(\d{1,2})[月/]\s*(\d{1,2})日?').firstMatch(line);
      if (dateMatch != null) {
        currentDate = '${dateMatch.group(1)}/${dateMatch.group(2)!.padLeft(2, '0')}/${dateMatch.group(3)!.padLeft(2, '0')}';
        continue;
      }

      // 価格の検出
      final priceMatch = RegExp(r'[¥￥円]\s*([0-9,]+)', caseSensitive: false).firstMatch(line);
      if (priceMatch != null) {
        currentPrice = '¥${priceMatch.group(1)}';
        continue;
      }

      // ポイント獲得の検出
      final pointsMatch = RegExp(r'(\d+)ポイント', caseSensitive: false).firstMatch(line);
      if (pointsMatch != null) {
        currentPoints = '${pointsMatch.group(1)}ポイント';
        continue;
      }

      // ショップ名の検出（「〇〇ショップ」「〇〇店」など）
      if (line.contains('ショップ') || line.contains('店舗') || line.contains('店')) {
        if (line.length < 30 && !line.contains('¥')) {
          currentShop = line;
          continue;
        }
      }

      // 商品名の検出
      if (_isLikelyProductName(line)) {
        currentProduct = line;
      }

      // 十分な情報が揃った場合にアイテム作成
      if (currentProduct != null && currentPrice != null) {
        final confidence = _calculateConfidence({
          'hasProduct': currentProduct.length > 5,
          'hasPrice': true,
          'hasOrderNumber': currentOrderNumber != null,
          'hasDate': currentDate != null,
          'hasShop': currentShop != null,
          'hasPoints': currentPoints != null,
          'rakutenFormat': true,
        });

        items.add(RakutenPurchaseItem(
          productName: currentProduct,
          price: currentPrice,
          shopName: currentShop,
          orderNumber: currentOrderNumber ?? 'N/A',
          orderDate: currentDate ?? 'N/A',
          pointsEarned: currentPoints,
          confidence: confidence,
          rawText: line,
        ));

        // 商品と価格はリセット、その他は継続
        currentProduct = null;
        currentPrice = null;
      }
    }

    return items;
  }

  // メール形式のパース
  static List<RakutenPurchaseItem> _parseEmailFormat(String text) {
    final items = <RakutenPurchaseItem>[];
    
    if (!text.contains('楽天市場') && !text.contains('注文確認')) {
      return items;
    }

    // メール内の商品リストパターン
    final emailPattern = RegExp(
      r'商品名[：:\s]*([^\n]{10,80})[\s\S]*?価格[：:\s]*[¥￥]\s*([0-9,]+)',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = emailPattern.allMatches(text);
    for (final match in matches) {
      final product = match.group(1)!.trim();
      final price = '¥${match.group(2)}';
      
      final confidence = _calculateConfidence({
        'hasProduct': product.length > 10,
        'hasPrice': true,
        'emailFormat': true,
        'rakutenKeywords': true,
      });

      if (confidence >= minConfidenceThreshold) {
        items.add(RakutenPurchaseItem(
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
  static List<RakutenPurchaseItem> _parseReceiptFormat(String text) {
    final items = <RakutenPurchaseItem>[];
    
    // レシート形式（商品名 価格の並び）
    final receiptPattern = RegExp(
      r'^([^\d¥￥\n]{10,60})\s+[¥￥]\s*([0-9,]+)',
      multiLine: true,
    );

    final matches = receiptPattern.allMatches(text);
    for (final match in matches) {
      final product = match.group(1)!.trim();
      final price = '¥${match.group(2)}';
      
      if (_isLikelyProductName(product)) {
        final confidence = _calculateConfidence({
          'hasProduct': product.length > 10,
          'hasPrice': true,
          'receiptFormat': true,
        });

        if (confidence >= minConfidenceThreshold) {
          items.add(RakutenPurchaseItem(
            productName: product,
            price: price,
            orderNumber: 'N/A',
            orderDate: _extractDate(text) ?? 'N/A',
            confidence: confidence,
            rawText: match.group(0)!,
          ));
        }
      }
    }

    return items;
  }

  // 汎用形式のパース
  static List<RakutenPurchaseItem> _parseGenericFormat(String text) {
    final items = <RakutenPurchaseItem>[];
    final lines = text.split('\n');
    
    String? productCandidate;
    String? priceCandidate;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 価格らしい行
      final priceMatch = RegExp(r'[¥￥]\s*([0-9,]+)').firstMatch(trimmedLine);
      if (priceMatch != null) {
        priceCandidate = '¥${priceMatch.group(1)}';
        
        // 同じ行に商品名がある場合
        final beforePrice = trimmedLine.substring(0, priceMatch.start).trim();
        if (beforePrice.isNotEmpty && _isLikelyProductName(beforePrice)) {
          productCandidate = beforePrice;
        }
        
        if (productCandidate != null && priceCandidate != null) {
          final confidence = _calculateConfidence({
            'hasProduct': productCandidate.length > 10,
            'hasPrice': true,
            'genericFormat': true,
          });

          if (confidence >= minConfidenceThreshold) {
            items.add(RakutenPurchaseItem(
              productName: productCandidate,
              price: priceCandidate,
              orderNumber: 'N/A',
              orderDate: 'N/A',
              confidence: confidence,
              rawText: trimmedLine,
            ));
          }
          
          productCandidate = null;
          priceCandidate = null;
        }
      }
      
      // 商品名の候補
      if (_isLikelyProductName(trimmedLine)) {
        productCandidate = trimmedLine;
      }
    }

    return items;
  }

  // ユーティリティメソッド
  static bool _containsRakutenKeywords(String text) {
    final keywords = ['楽天市場', '楽天', 'rakuten', '注文確認', 'ポイント'];
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  static bool _isLikelyProductName(String text) {
    if (text.length < 5 || text.length > 80) return false;
    if (RegExp(r'^[\d\s¥￥-]+$').hasMatch(text)) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isSystemText(String text) {
    final systemKeywords = [
      '合計', '小計', '送料', '税込', '税抜', '消費税', 'ポイント利用',
      'クーポン', '割引', '楽天市場', '注文番号', '配送', 'お届け'
    ];
    return systemKeywords.any((keyword) => text.contains(keyword));
  }

  static String? _extractOrderNumber(String text) {
    final patterns = [
      RegExp(r'注文番号[：:\s]*(\d{10,})'),
      RegExp(r'Order\s*[#№]?\s*(\d{10,})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }

  static String? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{4})[年/]\s*(\d{1,2})[月/]\s*(\d{1,2})日?'),
      RegExp(r'注文日[：:\s]*(\d{4}[/年-]\d{1,2}[/月-]\d{1,2})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        if (match.groupCount >= 3 && match.group(3) != null) {
          return '${match.group(1)}/${match.group(2)!.padLeft(2, '0')}/${match.group(3)!.padLeft(2, '0')}';
        } else {
          return match.group(1);
        }
      }
    }
    return null;
  }

  static double _calculateConfidence(Map<String, dynamic> factors) {
    double score = 0.0;
    
    if (factors['hasProduct'] == true) score += 0.3;
    if (factors['hasPrice'] == true) score += 0.25;
    if (factors['hasOrderNumber'] == true) score += 0.15;
    if (factors['hasDate'] == true) score += 0.1;
    if (factors['hasShop'] == true) score += 0.1;
    if (factors['hasPoints'] == true) score += 0.1;
    if (factors['rakutenFormat'] == true) score += 0.15;
    if (factors['emailFormat'] == true) score += 0.1;
    if (factors['receiptFormat'] == true) score += 0.05;
    if (factors['rakutenKeywords'] == true) score += 0.1;
    if (factors['genericFormat'] == true) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  static List<RakutenPurchaseItem> _removeDuplicates(List<RakutenPurchaseItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.productName}_${item.price}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
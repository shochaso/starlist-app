class MercariPurchaseItem {
  final String productName;
  final String price;
  final String sellerName;
  final String orderDate;
  final String? category;
  final String? condition;
  final String? shippingMethod;
  final double confidence;
  final String rawText;

  MercariPurchaseItem({
    required this.productName,
    required this.price,
    required this.sellerName,
    required this.orderDate,
    this.category,
    this.condition,
    this.shippingMethod,
    required this.confidence,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': productName,
      'price': price,
      'site': 'メルカリ',
      'seller': sellerName,
      'orderDate': orderDate,
      'category': category,
      'condition': condition,
      'shippingMethod': shippingMethod,
      'confidence': confidence,
      'rawText': rawText,
    };
  }
}

class MercariPurchaseParser {
  static const double minConfidenceThreshold = 0.6;

  static List<MercariPurchaseItem> parseText(String text) {
    if (text.trim().isEmpty) return [];

    final List<MercariPurchaseItem> items = [];
    
    // 複数のパース戦略を順番に試行
    items.addAll(_parsePurchaseHistory(text));
    items.addAll(_parseNotificationFormat(text));
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

  // メルカリ購入履歴形式のパース
  static List<MercariPurchaseItem> _parsePurchaseHistory(String text) {
    final items = <MercariPurchaseItem>[];
    
    if (!_containsMercariKeywords(text)) return items;

    final lines = text.split('\n');
    String? currentProduct;
    String? currentPrice;
    String? currentSeller;
    String? currentDate;
    String? currentCondition;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // 日付の検出
      final dateMatch = RegExp(r'(\d{4})[年/]\s*(\d{1,2})[月/]\s*(\d{1,2})日?').firstMatch(line);
      if (dateMatch != null) {
        currentDate = '${dateMatch.group(1)}/${dateMatch.group(2)!.padLeft(2, '0')}/${dateMatch.group(3)!.padLeft(2, '0')}';
        continue;
      }

      // 価格の検出（メルカリ特有：¥記号付き）
      final priceMatch = RegExp(r'[¥￥]\s*([0-9,]+)', caseSensitive: false).firstMatch(line);
      if (priceMatch != null && line.length < 20) {
        currentPrice = '¥${priceMatch.group(1)}';
        continue;
      }

      // 出品者名の検出
      if (line.contains('出品者') || line.contains('販売者')) {
        final sellerMatch = RegExp(r'(?:出品者|販売者)[：:\s]*(.+)').firstMatch(line);
        if (sellerMatch != null) {
          currentSeller = sellerMatch.group(1)!.trim();
          continue;
        }
      }

      // 商品状態の検出
      if (line.contains('新品') || line.contains('中古') || line.contains('未使用')) {
        currentCondition = line;
        continue;
      }

      // 商品名の検出
      if (_isLikelyProductName(line)) {
        currentProduct = line;
      }

      // 十分な情報が揃った場合にアイテム作成
      if (currentProduct != null && currentPrice != null && currentSeller != null) {
        final confidence = _calculateConfidence({
          'hasProduct': currentProduct.length > 5,
          'hasPrice': true,
          'hasSeller': true,
          'hasDate': currentDate != null,
          'hasCondition': currentCondition != null,
          'mercariFormat': true,
        });

        items.add(MercariPurchaseItem(
          productName: currentProduct,
          price: currentPrice,
          sellerName: currentSeller,
          orderDate: currentDate ?? 'N/A',
          condition: currentCondition,
          confidence: confidence,
          rawText: line,
        ));

        // 商品、価格、出品者をリセット
        currentProduct = null;
        currentPrice = null;
        currentSeller = null;
        currentCondition = null;
      }
    }

    return items;
  }

  // 通知形式のパース（購入完了通知など）
  static List<MercariPurchaseItem> _parseNotificationFormat(String text) {
    final items = <MercariPurchaseItem>[];
    
    if (!text.contains('購入しました') && !text.contains('取引完了')) {
      return items;
    }

    // 通知内の商品情報パターン
    final notificationPattern = RegExp(
      r'商品名[：:\s]*([^\n]{5,50})[\s\S]*?価格[：:\s]*[¥￥]\s*([0-9,]+)[\s\S]*?出品者[：:\s]*([^\n]+)',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = notificationPattern.allMatches(text);
    for (final match in matches) {
      final product = match.group(1)!.trim();
      final price = '¥${match.group(2)}';
      final seller = match.group(3)!.trim();
      
      final confidence = _calculateConfidence({
        'hasProduct': product.length > 5,
        'hasPrice': true,
        'hasSeller': true,
        'notificationFormat': true,
        'mercariKeywords': true,
      });

      if (confidence >= minConfidenceThreshold) {
        items.add(MercariPurchaseItem(
          productName: product,
          price: price,
          sellerName: seller,
          orderDate: _extractDate(text) ?? 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // レシート形式のパース
  static List<MercariPurchaseItem> _parseReceiptFormat(String text) {
    final items = <MercariPurchaseItem>[];
    
    // レシート形式（商品名 価格 出品者の並び）
    final receiptPattern = RegExp(
      r'^([^\d¥￥\n]{5,40})\s+[¥￥]\s*([0-9,]+)\s+(.+)',
      multiLine: true,
    );

    final matches = receiptPattern.allMatches(text);
    for (final match in matches) {
      final product = match.group(1)!.trim();
      final price = '¥${match.group(2)}';
      final seller = match.group(3)!.trim();
      
      if (_isLikelyProductName(product) && _isLikelySeller(seller)) {
        final confidence = _calculateConfidence({
          'hasProduct': product.length > 5,
          'hasPrice': true,
          'hasSeller': true,
          'receiptFormat': true,
        });

        if (confidence >= minConfidenceThreshold) {
          items.add(MercariPurchaseItem(
            productName: product,
            price: price,
            sellerName: seller,
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
  static List<MercariPurchaseItem> _parseGenericFormat(String text) {
    final items = <MercariPurchaseItem>[];
    final lines = text.split('\n');
    
    String? productCandidate;
    String? priceCandidate;
    String? sellerCandidate;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 価格らしい行
      final priceMatch = RegExp(r'[¥￥]\s*([0-9,]+)').firstMatch(trimmedLine);
      if (priceMatch != null) {
        priceCandidate = '¥${priceMatch.group(1)}';
        continue;
      }
      
      // 出品者らしい行
      if (_isLikelySeller(trimmedLine)) {
        sellerCandidate = trimmedLine;
        continue;
      }
      
      // 商品名の候補
      if (_isLikelyProductName(trimmedLine)) {
        productCandidate = trimmedLine;
      }

      // 十分な情報が揃った場合
      if (productCandidate != null && priceCandidate != null && sellerCandidate != null) {
        final confidence = _calculateConfidence({
          'hasProduct': productCandidate.length > 5,
          'hasPrice': true,
          'hasSeller': true,
          'genericFormat': true,
        });

        if (confidence >= minConfidenceThreshold) {
          items.add(MercariPurchaseItem(
            productName: productCandidate,
            price: priceCandidate,
            sellerName: sellerCandidate,
            orderDate: 'N/A',
            confidence: confidence,
            rawText: trimmedLine,
          ));
        }
        
        productCandidate = null;
        priceCandidate = null;
        sellerCandidate = null;
      }
    }

    return items;
  }

  // ユーティリティメソッド
  static bool _containsMercariKeywords(String text) {
    final keywords = ['メルカリ', 'mercari', '購入しました', '取引完了', '出品者'];
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  static bool _isLikelyProductName(String text) {
    if (text.length < 3 || text.length > 50) return false;
    if (RegExp(r'^[\d\s¥￥-]+$').hasMatch(text)) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isLikelySeller(String text) {
    if (text.length < 2 || text.length > 20) return false;
    if (text.contains('¥') || text.contains('￥')) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isSystemText(String text) {
    final systemKeywords = [
      '合計', '小計', '送料', '手数料', '税込', '税抜', '消費税',
      'メルカリ', '購入', '取引', '評価', '配送', 'お届け', '支払い'
    ];
    return systemKeywords.any((keyword) => text.contains(keyword));
  }

  static String? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{4})[年/]\s*(\d{1,2})[月/]\s*(\d{1,2})日?'),
      RegExp(r'購入日[：:\s]*(\d{4}[/年-]\d{1,2}[/月-]\d{1,2})'),
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
    if (factors['hasSeller'] == true) score += 0.2;
    if (factors['hasDate'] == true) score += 0.1;
    if (factors['hasCondition'] == true) score += 0.1;
    if (factors['mercariFormat'] == true) score += 0.15;
    if (factors['notificationFormat'] == true) score += 0.1;
    if (factors['receiptFormat'] == true) score += 0.05;
    if (factors['mercariKeywords'] == true) score += 0.1;
    if (factors['genericFormat'] == true) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  static List<MercariPurchaseItem> _removeDuplicates(List<MercariPurchaseItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.productName}_${item.price}_${item.sellerName}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
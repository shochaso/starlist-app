class ReceiptItem {
  final String itemName;
  final String price;
  final String? quantity;
  final String? category;
  final String storeName;
  final String purchaseDate;
  final String? tax;
  final double confidence;
  final String rawText;

  ReceiptItem({
    required this.itemName,
    required this.price,
    this.quantity,
    this.category,
    required this.storeName,
    required this.purchaseDate,
    this.tax,
    required this.confidence,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
      'category': category,
      'storeName': storeName,
      'purchaseDate': purchaseDate,
      'tax': tax,
      'confidence': confidence,
      'rawText': rawText,
    };
  }
}

class ReceiptParser {
  static const double minConfidenceThreshold = 0.6;

  static List<ReceiptItem> parseReceiptText(String text) {
    if (text.trim().isEmpty) return [];

    final List<ReceiptItem> items = [];
    
    // 複数のパース戦略を順番に試行
    items.addAll(_parseConvenienceStoreReceipt(text));
    items.addAll(_parseRestaurantReceipt(text));
    items.addAll(_parseSupermarketReceipt(text));
    items.addAll(_parseGenericReceipt(text));

    // 重複除去と信頼度によるフィルタリング
    final uniqueItems = _removeDuplicates(items);
    final filteredItems = uniqueItems
        .where((item) => item.confidence >= minConfidenceThreshold)
        .toList();

    // 信頼度によるソート
    filteredItems.sort((a, b) => b.confidence.compareTo(a.confidence));

    return filteredItems;
  }

  // コンビニレシート形式のパース
  static List<ReceiptItem> _parseConvenienceStoreReceipt(String text) {
    final items = <ReceiptItem>[];
    
    // 店舗名の検出
    final storePatterns = [
      RegExp(r'(セブン-イレブン|セブンイレブン|7-Eleven)', caseSensitive: false),
      RegExp(r'(ローソン|Lawson)', caseSensitive: false),
      RegExp(r'(ファミリーマート|FamilyMart)', caseSensitive: false),
      RegExp(r'(ミニストップ|MINISTOP)', caseSensitive: false),
    ];
    
    String storeName = '不明';
    for (final pattern in storePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        storeName = match.group(1)!;
        break;
      }
    }

    // 日付の検出
    final datePattern = RegExp(r'(\d{4})[/年-]\s*(\d{1,2})[/月-]\s*(\d{1,2})[日/\s]*(\d{1,2}):(\d{2})');
    final dateMatch = datePattern.firstMatch(text);
    final purchaseDate = dateMatch != null 
        ? '${dateMatch.group(1)}/${dateMatch.group(2)!.padLeft(2, '0')}/${dateMatch.group(3)!.padLeft(2, '0')} ${dateMatch.group(4)}:${dateMatch.group(5)}'
        : 'N/A';

    // 商品と価格のパターン
    final itemPatterns = [
      // 商品名 数量 価格 (コンビニ形式)
      RegExp(r'^([^\d¥￥\n]{3,30})\s+(\d+)\s*[¥￥]\s*([0-9,]+)', multiLine: true),
      // 商品名 価格
      RegExp(r'^([^\d¥￥\n]{3,30})\s+[¥￥]\s*([0-9,]+)', multiLine: true),
    ];

    for (final pattern in itemPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final itemName = match.group(1)!.trim();
        String price;
        String? quantity;
        
        if (match.groupCount >= 3) {
          quantity = match.group(2);
          price = '¥${match.group(3)}';
        } else {
          price = '¥${match.group(2)}';
        }

        if (_isValidItem(itemName)) {
          final confidence = _calculateConfidence({
            'hasValidName': itemName.length > 3,
            'hasPrice': true,
            'hasQuantity': quantity != null,
            'hasStore': storeName != '不明',
            'hasDate': purchaseDate != 'N/A',
            'convenienceStore': true,
          });

          items.add(ReceiptItem(
            itemName: itemName,
            price: price,
            quantity: quantity,
            storeName: storeName,
            purchaseDate: purchaseDate,
            confidence: confidence,
            rawText: match.group(0)!,
          ));
        }
      }
    }

    return items;
  }

  // レストランレシート形式のパース
  static List<ReceiptItem> _parseRestaurantReceipt(String text) {
    final items = <ReceiptItem>[];
    
    // レストラン特有のキーワード
    if (!_containsRestaurantKeywords(text)) return items;

    final lines = text.split('\n');
    String storeName = 'レストラン';
    String purchaseDate = 'N/A';
    
    // 店舗名と日付の検出
    for (final line in lines) {
      if (line.contains('店') || line.contains('レストラン') || line.contains('カフェ')) {
        if (line.length < 20 && !line.contains('¥')) {
          storeName = line.trim();
        }
      }
      
      final dateMatch = RegExp(r'(\d{4})[/年-]\s*(\d{1,2})[/月-]\s*(\d{1,2})').firstMatch(line);
      if (dateMatch != null) {
        purchaseDate = '${dateMatch.group(1)}/${dateMatch.group(2)!.padLeft(2, '0')}/${dateMatch.group(3)!.padLeft(2, '0')}';
      }
    }

    // メニュー項目のパターン
    final menuPatterns = [
      // メニュー名 数量 価格
      RegExp(r'^([^\d¥￥\n]{3,25})\s*×?\s*(\d+)\s*[¥￥]\s*([0-9,]+)', multiLine: true),
      // メニュー名 価格
      RegExp(r'^([^\d¥￥\n]{3,25})\s+[¥￥]\s*([0-9,]+)', multiLine: true),
    ];

    for (final pattern in menuPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final itemName = match.group(1)!.trim();
        String price;
        String? quantity;
        
        if (match.groupCount >= 3) {
          quantity = match.group(2);
          price = '¥${match.group(3)}';
        } else {
          price = '¥${match.group(2)}';
        }

        if (_isValidMenuItem(itemName)) {
          final confidence = _calculateConfidence({
            'hasValidName': itemName.length > 3,
            'hasPrice': true,
            'hasQuantity': quantity != null,
            'hasStore': storeName != 'レストラン',
            'hasDate': purchaseDate != 'N/A',
            'restaurant': true,
          });

          items.add(ReceiptItem(
            itemName: itemName,
            price: price,
            quantity: quantity,
            category: ' 飲食',
            storeName: storeName,
            purchaseDate: purchaseDate,
            confidence: confidence,
            rawText: match.group(0)!,
          ));
        }
      }
    }

    return items;
  }

  // スーパーマーケットレシート形式のパース
  static List<ReceiptItem> _parseSupermarketReceipt(String text) {
    final items = <ReceiptItem>[];
    
    // スーパー特有のキーワード
    final superPatterns = [
      RegExp(r'(イオン|AEON)', caseSensitive: false),
      RegExp(r'(西友|SEIYU)', caseSensitive: false),
      RegExp(r'(ライフ|LIFE)', caseSensitive: false),
      RegExp(r'(マルエツ)', caseSensitive: false),
    ];
    
    String storeName = 'スーパーマーケット';
    for (final pattern in superPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        storeName = match.group(1)!;
        break;
      }
    }

    // 商品コードと商品名のパターン
    final superItemPattern = RegExp(
      r'(\d{10,13})\s*([^\d¥￥\n]{3,30})\s*(\d+)個?\s*[¥￥]\s*([0-9,]+)',
      multiLine: true,
    );

    final matches = superItemPattern.allMatches(text);
    for (final match in matches) {
      final itemName = match.group(2)!.trim();
      final quantity = match.group(3);
      final price = '¥${match.group(4)}';

      if (_isValidItem(itemName)) {
        final confidence = _calculateConfidence({
          'hasValidName': itemName.length > 3,
          'hasPrice': true,
          'hasQuantity': true,
          'hasBarcode': true,
          'supermarket': true,
        });

        items.add(ReceiptItem(
          itemName: itemName,
          price: price,
          quantity: quantity,
          category: _categorizeItem(itemName),
          storeName: storeName,
          purchaseDate: _extractDate(text) ?? 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // 汎用レシート形式のパース
  static List<ReceiptItem> _parseGenericReceipt(String text) {
    final items = <ReceiptItem>[];
    final lines = text.split('\n');
    
    String? currentItem;
    String? currentPrice;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 価格パターンの検出
      final priceMatch = RegExp(r'[¥￥]\s*([0-9,]+)').firstMatch(trimmedLine);
      if (priceMatch != null) {
        currentPrice = '¥${priceMatch.group(1)}';
        
        // 同じ行に商品名がある場合
        final beforePrice = trimmedLine.substring(0, priceMatch.start).trim();
        if (beforePrice.isNotEmpty && _isValidItem(beforePrice)) {
          currentItem = beforePrice;
        }
        
        if (currentItem != null && currentPrice != null) {
          final confidence = _calculateConfidence({
            'hasValidName': currentItem.length > 3,
            'hasPrice': true,
            'generic': true,
          });

          items.add(ReceiptItem(
            itemName: currentItem,
            price: currentPrice,
            storeName: '不明',
            purchaseDate: 'N/A',
            confidence: confidence,
            rawText: trimmedLine,
          ));
          
          currentItem = null;
          currentPrice = null;
        }
      }
      // 商品名候補の検出
      else if (_isValidItem(trimmedLine)) {
        currentItem = trimmedLine;
      }
    }

    return items;
  }

  // ユーティリティメソッド
  static bool _isValidItem(String text) {
    if (text.length < 3 || text.length > 30) return false;
    if (RegExp(r'^[\d\s¥￥-]+$').hasMatch(text)) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isValidMenuItem(String text) {
    if (!_isValidItem(text)) return false;
    // レストランメニューっぽいかチェック
    final menuKeywords = ['セット', 'コース', 'ランチ', 'ディナー', 'ドリンク', 'デザート'];
    return menuKeywords.any((keyword) => text.contains(keyword)) || text.length > 3;
  }

  static bool _containsRestaurantKeywords(String text) {
    final keywords = ['お食事代', 'お会計', 'テーブル', '席', 'ランチ', 'ディナー', 'セット', 'コース'];
    return keywords.any((keyword) => text.contains(keyword));
  }

  static bool _isSystemText(String text) {
    final systemKeywords = [
      '合計', '小計', '税込', '税抜', '消費税', '釣銭', 'お釣り',
      'カード', 'クレジット', 'ポイント', 'レシート', '領収書'
    ];
    return systemKeywords.any((keyword) => text.contains(keyword));
  }

  static String _categorizeItem(String itemName) {
    final categories = {
      '食品': ['肉', '魚', '野菜', 'パン', '米', '卵', '牛乳'],
      '飲料': ['ジュース', 'お茶', 'コーヒー', 'ビール', 'ワイン'],
      '日用品': ['洗剤', 'シャンプー', 'ティッシュ', 'トイレット'],
    };
    
    for (final entry in categories.entries) {
      if (entry.value.any((keyword) => itemName.contains(keyword))) {
        return entry.key;
      }
    }
    
    return 'その他';
  }

  static String? _extractDate(String text) {
    final datePattern = RegExp(r'(\d{4})[/年-]\s*(\d{1,2})[/月-]\s*(\d{1,2})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      return '${match.group(1)}/${match.group(2)!.padLeft(2, '0')}/${match.group(3)!.padLeft(2, '0')}';
    }
    return null;
  }

  static double _calculateConfidence(Map<String, dynamic> factors) {
    double score = 0.0;
    
    if (factors['hasValidName'] == true) score += 0.3;
    if (factors['hasPrice'] == true) score += 0.25;
    if (factors['hasQuantity'] == true) score += 0.15;
    if (factors['hasStore'] == true) score += 0.1;
    if (factors['hasDate'] == true) score += 0.1;
    if (factors['hasBarcode'] == true) score += 0.1;
    if (factors['convenienceStore'] == true) score += 0.1;
    if (factors['restaurant'] == true) score += 0.1;
    if (factors['supermarket'] == true) score += 0.1;
    if (factors['generic'] == true) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  static List<ReceiptItem> _removeDuplicates(List<ReceiptItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.itemName}_${item.price}_${item.storeName}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
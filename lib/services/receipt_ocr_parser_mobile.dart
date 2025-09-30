import 'dart:typed_data';
import 'dart:convert';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis/language/v1.dart' as language;
import 'package:googleapis_auth/auth_io.dart';

class ReceiptItem {
  final String name;
  final double? price;
  final int? quantity;
  final String category;
  final double confidence;
  bool isSelected;

  ReceiptItem({
    required this.name,
    this.price,
    this.quantity = 1,
    required this.category,
    required this.confidence,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'category': category,
        'confidence': confidence,
        'isSelected': isSelected,
      };
}

class Receipt {
  final DateTime? purchaseDate;
  final String? storeName;
  final List<ReceiptItem> items;
  final double? totalAmount;
  final double? tax;

  Receipt({
    this.purchaseDate,
    this.storeName,
    required this.items,
    this.totalAmount,
    this.tax,
  });

  Map<String, dynamic> toJson() => {
        'purchaseDate': purchaseDate?.toIso8601String(),
        'storeName': storeName,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'tax': tax,
      };
}

class ReceiptOCRParser {
  final String _apiKey;
  vision.VisionApi? _visionApi;
  language.CloudNaturalLanguageApi? _languageApi;

  ReceiptOCRParser({required String apiKey}) : _apiKey = apiKey;

  Future<void> _initializeApis() async {
    final client = clientViaApiKey(_apiKey);
    _visionApi = vision.VisionApi(client);
    _languageApi = language.CloudNaturalLanguageApi(client);
  }

  Future<Receipt> parseReceiptImage(Uint8List imageBytes) async {
    if (_visionApi == null || _languageApi == null) {
      await _initializeApis();
    }

    final extractedText = await _extractTextFromImage(imageBytes);
    final receipt = await _parseReceiptText(extractedText);
    return receipt;
  }

  Future<String> _extractTextFromImage(Uint8List imageBytes) async {
    final image = vision.Image()..content = base64Encode(imageBytes);
    final feature = vision.Feature()..type = 'TEXT_DETECTION';
    final request = vision.AnnotateImageRequest()
      ..image = image
      ..features = [feature];
    final batchRequest = vision.BatchAnnotateImagesRequest()..requests = [request];
    final response = await _visionApi!.images.annotate(batchRequest);
    final textAnnotation = response.responses?.first.fullTextAnnotation;
    return textAnnotation?.text ?? '';
  }

  Future<Receipt> _parseReceiptText(String text) async {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    DateTime? purchaseDate;
    String? storeName;
    List<ReceiptItem> items = [];
    double? totalAmount;
    double? tax;

    if (lines.isNotEmpty) {
      storeName = _extractStoreName(lines);
    }
    purchaseDate = _extractPurchaseDate(lines);

    final rawItems = _extractItems(lines);
    for (final rawItem in rawItems) {
      final category = await _classifyItemCategory(rawItem['name']);
      items.add(ReceiptItem(
        name: rawItem['name'],
        price: rawItem['price'],
        quantity: rawItem['quantity'] ?? 1,
        category: category,
        confidence: rawItem['confidence'] ?? 0.7,
      ));
    }

    totalAmount = _extractTotalAmount(lines);
    tax = _extractTax(lines);

    return Receipt(
      purchaseDate: purchaseDate,
      storeName: storeName,
      items: items,
      totalAmount: totalAmount,
      tax: tax,
    );
  }

  String? _extractStoreName(List<String> lines) {
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      if (!_isDateLine(line) && !_isPriceLine(line) && !line.contains('TEL') && !line.contains('営業時間') && line.length > 2) {
        return line;
      }
    }
    return null;
  }

  DateTime? _extractPurchaseDate(List<String> lines) {
    for (final line in lines) {
      final date = _parseDate(line);
      if (date != null) return date;
    }
    return null;
  }

  DateTime? _parseDate(String text) {
    final datePatterns = [
      RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'),
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'),
      RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日'),
    ];
    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int year, month, day;
          if (pattern == datePatterns[0]) {
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (pattern == datePatterns[1]) {
            year = int.parse(match.group(3)!);
            month = int.parse(match.group(1)!);
            day = int.parse(match.group(2)!);
          } else {
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          }
          return DateTime(year, month, day);
        } catch (_) { /* ignore */ }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractItems(List<String> lines) {
    final items = <Map<String, dynamic>>[];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final priceMatch = RegExp(r'¥?(\d{1,3}(?:,\d{3})*)\s*
$').firstMatch(line);
      final priceText = priceMatch.group(1)!.replaceAll(',', '');
      final price = double.tryParse(priceText);
      if (price != null && price > 0 && price < 100000) {
        final itemName = line.substring(0, priceMatch.start).trim();
        if (itemName.isNotEmpty && !_isSystemText(itemName) && !_isTotalLine(line)) {
          items.add({'name': itemName, 'price': price, 'quantity': 1, 'confidence': 0.8});
        }
      }
        }
    return items;
  }

  double? _extractTotalAmount(List<String> lines) {
    for (final line in lines) {
      if (_isTotalLine(line)) {
        final priceMatch = RegExp(r'¥?(\d{1,3}(?:,\d{3})*)').firstMatch(line);
        if (priceMatch != null) {
          final priceText = priceMatch.group(1)!.replaceAll(',', '');
          return double.tryParse(priceText);
        }
      }
    }
    return null;
  }

  double? _extractTax(List<String> lines) {
    for (final line in lines) {
      if (line.contains('税') || line.contains('TAX')) {
        final priceMatch = RegExp(r'¥?(\d{1,3}(?:,\d{3})*)').firstMatch(line);
        if (priceMatch != null) {
          final priceText = priceMatch.group(1)!.replaceAll(',', '');
          return double.tryParse(priceText);
        }
      }
    }
    return null;
  }

  Future<String> _classifyItemCategory(String itemName) async {
    try {
      final document = language.Document()
        ..content = itemName
        ..type = 'PLAIN_TEXT';
      final request = language.ClassifyTextRequest()..document = document;
      final response = await _languageApi!.documents.classifyText(request);
      if (response.categories != null && response.categories!.isNotEmpty) {
        final category = response.categories!.first;
        return _mapToLocalCategory(category.name ?? 'その他');
      }
    } catch (_) {
      return _inferCategoryFromName(itemName);
    }
    return _inferCategoryFromName(itemName);
  }

  String _mapToLocalCategory(String googleCategory) {
    final categoryMap = {
      '/Food & Drink': '食品・飲料',
      '/Shopping/Apparel': 'ファッション',
      '/Health': 'ヘルスケア',
      '/Beauty & Fitness': '美容・フィットネス',
      '/Home & Garden': '住宅・ガーデン',
      '/Computers & Electronics': '家電・PC',
      '/Books & Literature': '本・文学',
      '/Games': 'ゲーム',
      '/Sports': 'スポーツ',
      '/Travel': '旅行',
    };
    for (final entry in categoryMap.entries) {
      if (googleCategory.startsWith(entry.key)) return entry.value;
    }
    return 'その他';
  }

  String _inferCategoryFromName(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('パン') || name.contains('牛乳') || name.contains('野菜') || name.contains('肉') || name.contains('魚') || name.contains('米') || name.contains('ジュース') || name.contains('コーヒー') || name.contains('お茶')) return '食品・飲料';
    if (name.contains('シャツ') || name.contains('パンツ') || name.contains('靴') || name.contains('バッグ') || name.contains('帽子')) return 'ファッション';
    if (name.contains('シャンプー') || name.contains('化粧') || name.contains('薬') || name.contains('サプリ') || name.contains('歯ブラシ')) return '美容・ヘルスケア';
    if (name.contains('pc') || name.contains('パソコン') || name.contains('スマホ') || name.contains('充電器') || name.contains('ケーブル')) return '家電・PC';
    if (name.contains('本') || name.contains('ノート') || name.contains('ペン') || name.contains('雑誌')) return '本・文具';
    return 'その他';
  }

  bool _isDateLine(String line) => RegExp(r'\d{4}[/-]\d{1,2}[/-]\d{1,2}|\d{4}年\d{1,2}月\d{1,2}日').hasMatch(line);
  bool _isPriceLine(String line) => RegExp(r'¥?\d{1,3}(?:,\d{3})*\s*$').hasMatch(line);
  bool _isTotalLine(String line) { final totalKeywords = ['合計', '小計', '総計', 'TOTAL', 'SUB TOTAL', '計']; return totalKeywords.any((k) => line.contains(k)); }
  bool _isSystemText(String text) { final systemPatterns = ['TEL','営業時間','住所','レジ','ありがとうございました','またお越しください','ポイント','クレジット','カード','釣銭','お預り']; return systemPatterns.any((p) => text.contains(p)); }
} 
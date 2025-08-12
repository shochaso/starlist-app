import 'dart:typed_data';

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
}

class ReceiptOCRParser {
  final String apiKey;
  ReceiptOCRParser({required this.apiKey});

  Future<Receipt> parseReceiptImage(Uint8List imageBytes) async {
    // Webスタブ: 画像OCRは未対応。空の結果を返す。
    return Receipt(purchaseDate: null, storeName: null, items: const [], totalAmount: null, tax: null);
  }
} 
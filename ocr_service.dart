import 'package:dio/dio.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/content_consumption_model.dart';

/// OCR機能サービスクラス
class OcrService {
  final ApiClient _apiClient;
  final AppConfig _appConfig;
  final Dio _dio;
  final TextRecognizer _textRecognizer;

  /// コンストラクタ
  OcrService({
    ApiClient? apiClient,
    AppConfig? appConfig,
    Dio? dio,
    TextRecognizer? textRecognizer,
  })  : _apiClient = apiClient ?? ApiClient(),
        _appConfig = appConfig ?? AppConfig(),
        _dio = dio ?? Dio(),
        _textRecognizer = textRecognizer ?? GoogleMlKit.vision.textRecognizer();

  /// デバイス上でOCRを実行
  Future<String> recognizeTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw OcrException('画像からのテキスト認識に失敗しました: ${e.toString()}', details: e);
    }
  }

  /// Google Cloud Vision APIを使用してOCRを実行
  Future<Map<String, dynamic>> recognizeTextWithCloudVision(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        'https://vision.googleapis.com/v1/images:annotate',
        queryParameters: {
          'key': _appConfig.googleCloudVisionApiKey,
        },
        data: {
          'requests': [
            {
              'image': {
                'content': base64Image,
              },
              'features': [
                {
                  'type': 'TEXT_DETECTION',
                  'maxResults': 1,
                },
                {
                  'type': 'DOCUMENT_TEXT_DETECTION',
                  'maxResults': 1,
                },
              ],
            },
          ],
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          'Google Cloud Vision APIでのOCR処理に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Google Cloud Vision APIでのOCR処理に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// レシート情報を抽出
  Future<Map<String, dynamic>> extractReceiptInfo(File imageFile) async {
    try {
      final response = await recognizeTextWithCloudVision(imageFile);
      
      // レスポンスからテキスト情報を抽出
      final textAnnotations = response['responses'][0]['textAnnotations'];
      if (textAnnotations == null || textAnnotations.isEmpty) {
        throw OcrException('レシートからテキストを抽出できませんでした');
      }
      
      final fullText = textAnnotations[0]['description'];
      
      // レシート情報を解析
      final receiptInfo = _parseReceiptText(fullText);
      
      return receiptInfo;
    } catch (e) {
      if (e is ApiException || e is OcrException) {
        rethrow;
      }
      throw OcrException('レシート情報の抽出に失敗しました: ${e.toString()}', details: e);
    }
  }

  /// 商品情報を抽出
  Future<List<Map<String, dynamic>>> extractProductInfo(File imageFile) async {
    try {
      final response = await recognizeTextWithCloudVision(imageFile);
      
      // レスポンスからテキスト情報を抽出
      final textAnnotations = response['responses'][0]['textAnnotations'];
      if (textAnnotations == null || textAnnotations.isEmpty) {
        throw OcrException('商品情報からテキストを抽出できませんでした');
      }
      
      final fullText = textAnnotations[0]['description'];
      
      // 商品情報を解析
      final productInfo = _parseProductText(fullText);
      
      return productInfo;
    } catch (e) {
      if (e is ApiException || e is OcrException) {
        rethrow;
      }
      throw OcrException('商品情報の抽出に失敗しました: ${e.toString()}', details: e);
    }
  }

  /// 店舗情報を抽出
  Future<Map<String, dynamic>> extractStoreInfo(File imageFile) async {
    try {
      final response = await recognizeTextWithCloudVision(imageFile);
      
      // レスポンスからテキスト情報を抽出
      final textAnnotations = response['responses'][0]['textAnnotations'];
      if (textAnnotations == null || textAnnotations.isEmpty) {
        throw OcrException('店舗情報からテキストを抽出できませんでした');
      }
      
      final fullText = textAnnotations[0]['description'];
      
      // 店舗情報を解析
      final storeInfo = _parseStoreText(fullText);
      
      return storeInfo;
    } catch (e) {
      if (e is ApiException || e is OcrException) {
        rethrow;
      }
      throw OcrException('店舗情報の抽出に失敗しました: ${e.toString()}', details: e);
    }
  }

  /// レシートテキストを解析
  Map<String, dynamic> _parseReceiptText(String text) {
    // 実際の実装では、正規表現やNLPを使用してより高度な解析を行います
    final lines = text.split('\n');
    
    // 店舗名を抽出（通常は最初の数行に含まれる）
    String? storeName;
    for (int i = 0; i < min(5, lines.length); i++) {
      if (lines[i].length > 3 && !RegExp(r'^\d').hasMatch(lines[i])) {
        storeName = lines[i].trim();
        break;
      }
    }
    
    // 日付を抽出
    final dateRegex = RegExp(r'(\d{4}[/\-年]\d{1,2}[/\-月]\d{1,2}日?)');
    final dateMatch = dateRegex.firstMatch(text);
    final date = dateMatch != null ? dateMatch.group(0) : null;
    
    // 時間を抽出
    final timeRegex = RegExp(r'(\d{1,2}:\d{2})');
    final timeMatch = timeRegex.firstMatch(text);
    final time = timeMatch != null ? timeMatch.group(0) : null;
    
    // 合計金額を抽出
    final totalRegex = RegExp(r'(合計|小計|総額|お買上げ額|金額).*?(\d{1,3}(,\d{3})*円|\d+円)');
    final totalMatch = totalRegex.firstMatch(text);
    String? totalAmount;
    if (totalMatch != null) {
      totalAmount = totalMatch.group(2)?.replaceAll(RegExp(r'[^\d]'), '');
    }
    
    // 商品リストを抽出
    final items = <Map<String, dynamic>>[];
    bool isItemSection = false;
    
    for (final line in lines) {
      // 商品行の特徴: 商品名と価格が含まれる
      if (RegExp(r'.*\d+円$').hasMatch(line) || 
          RegExp(r'.*\d+$').hasMatch(line) && !line.contains('合計') && !line.contains('小計')) {
        isItemSection = true;
        
        // 価格を抽出
        final priceMatch = RegExp(r'(\d{1,3}(,\d{3})*円|\d+円|\d+)$').firstMatch(line);
        String? price;
        if (priceMatch != null) {
          price = priceMatch.group(0)?.replaceAll(RegExp(r'[^\d]'), '');
        }
        
        // 商品名を抽出（価格を除いた部分）
        String itemName = line;
        if (priceMatch != null) {
          itemName = line.substring(0, line.length - priceMatch.group(0)!.length).trim();
        }
        
        // 数量を抽出
        final quantityMatch = RegExp(r'(\d+)個|(\d+)点|x(\d+)').firstMatch(itemName);
        String? quantity;
        if (quantityMatch != null) {
          for (int i = 1; i <= 3; i++) {
            if (quantityMatch.group(i) != null) {
              quantity = quantityMatch.group(i);
              break;
            }
          }
        }
        
        items.add({
          'name': itemName,
          'price': price,
          'quantity': quantity ?? '1',
        });
      } else if (isItemSection && (line.contains('合計') || line.contains('小計'))) {
        // 商品セクションの終わり
        isItemSection = false;
      }
    }
    
    return {
      'store_name': storeName,
      'date': date,
      'time': time,
      'total_amount': totalAmount,
      'items': items,
    };
  }

  /// 商品テキストを解析
  List<Map<String, dynamic>> _parseProductText(String text) {
    // 実際の実装では、正規表現やNLPを使用してより高度な解析を行います
    final products = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    
    String? currentProductName;
    String? currentPrice;
    String? currentBrand;
    List<String> currentFeatures = [];
    
    for (final line in lines) {
      if (line.isEmpty) continue;
      
      // 価格を検出
      final priceMatch = RegExp(r'(\d{1,3}(,\d{3})*円|\d+円)').firstMatch(line);
      if (priceMatch != null) {
        // 新しい価格が見つかった場合、前の商品情報を保存
        if (currentProductName != null) {
          products.add({
            'name': currentProductName,
            'price': currentPrice,
            'brand': currentBrand,
            'features': currentFeatures,
          });
          
          // リセット
          currentFeatures = [];
        }
        
        currentPrice = priceMatch.group(0)?.replaceAll(RegExp(r'[^\d]'), '');
        
        // 価格を除いた部分を商品名として扱う
        final nameCandidate = line.replaceAll(priceMatch.group(0)!, '').trim();
        if (nameCandidate.isNotEmpty) {
          currentProductName = nameCandidate;
        }
      } 
      // ブランド名を検出
      else if (line.length < 30 && !line.contains(':') && !RegExp(r'^\d').hasMatch(line)) {
        currentBrand = line.trim();
      }
      // 商品名を検出
      else if (currentProductName == null && line.length > 5 && line.length < 100) {
        currentProductName = line.trim();
      }
      // 特徴を検出
      else if (line.contains(':') || line.startsWith('・') || line.length > 10) {
        currentFeatures.add(line.trim());
      }
    }
    
    // 最後の商品を追加
    if (currentProductName != null) {
      products.add({
        'name': currentProductName,
        'price': currentPrice,
        'brand': currentBrand,
        'features': currentFeatures,
      });
    }
    
    return products;
  }

  /// 店舗テキストを解析
  Map<String, dynamic> _parseStoreText(String text) {
    // 実際の実装では、正規表現やNLPを使用してより高度な解析を行います
    final lines = text.split('\n');
    
    // 店舗名を抽出（通常は最初の数行に含まれる）
    String? storeName;
    for (int i = 0; i < min(5, lines.length); i++) {
      if (lines[i].length > 3 && !RegExp(r'^\d').hasMatch(lines[i])) {
        storeName = lines[i].trim();
        break;
      }
    }
    
    // 住所を抽出
    String? address;
    final addressRegex = RegExp(r'(東京都|北海道|大阪府|京都府|[^\s]{2,3}県)[^\n]{5,50}');
    final addressMatch = addressRegex.firstMatch(text);
    if (addressMatch != null) {
      address = addressMatch.group(0)?.trim();
    }
    
    // 電話番号を抽出
    String? phone;
    final phoneRegex = RegExp(r'(\d{2,4}-\d{2,4}-\d{4}|\d{10,11})');
    final phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) {
      phone = phoneMatch.group(0);
    }
    
    // 営業時間を抽出
    String? businessHours;
    final hoursRegex = RegExp(r'営業時間[：:]\s*([^\n]+)');
    final hoursMatch = hoursRegex.firstMatch(text);
    if (hoursMatch != null) {
      businessHours = hoursMatch.group(1)?.trim();
    }
    
    // ウェブサイトを抽出
    String? website;
    final websiteRegex = RegExp(r'(https?://[^\s]+)');
    final websiteMatch = websiteRegex.firstMatch(text);
    if (websiteMatch != null) {
      website = websiteMatch.group(0);
    }
    
    return {
      'name': storeName,
      'address': address,
      'phone': phone,
      'business_hours': businessHours,
      'website': website,
    };
  }

  /// プライバシー情報をマスク
  Map<String, dynamic> maskPrivacyInfo(Map<String, dynamic> data) {
    final maskedData = Map<String, dynamic>.from(data);
    
    // 住所のマスク
    if (maskedData.containsKey('address') && maskedData['address'] != null) {
      // 番地以降をマスク
      final addressParts = maskedData['address'].toString().split('丁目');
      if (addressParts.length > 1) {
        maskedData['address'] = '${addressParts[0]}丁目 ***';
      } else {
        final parts = maskedData['address'].toString().split('町');
        if (parts.length > 1) {
          maskedData['address'] = '${parts[0]}町 ***';
        }
      }
    }
    
    // 電話番号のマスク
    if (maskedData.containsKey('phone') && maskedData['phone'] != null) {
      final phone = maskedData['phone'].toString();
      if (phone.contains('-')) {
        final parts = phone.split('-');
        if (parts.length >= 3) {
          maskedData['phone'] = '${parts[0]}-${parts[1].substring(0, 1)}***-****';
        }
      } else if (phone.length >= 10) {
        maskedData['phone'] = '${phone.substring(0, 4)}******';
      }
    }
    
    return maskedData;
  }

  /// OCR結果をContentConsumptionModelに変換
  ContentConsumptionModel convertReceiptToContentConsumption(
    Map<String, dynamic> receiptData,
    String userId,
  ) {
    final storeName = receiptData['store_name'] ?? '不明な店舗';
    final date = receiptData['date'];
    final totalAmount = receiptData['total_amount'];
    final items = receiptData['items'] as List<Map<String, dynamic>>;
    
    // 商品名のリストを作成
    final itemNames = items.map((item) => item['name']).toList().cast<String>();
    
    // 説明文を作成
    String description = '購入店舗: $storeName';
    if (date != null) {
      description += '\n購入日: $date';
    }
    if (totalAmount != null) {
      description += '\n合計金額: $totalAmount円';
    }
    description += '\n購入商品数: ${items.length}点';
    
    return ContentConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentType: ContentType.purchase,
      title: '$storeNameでの購入',
      description: description,
      contentUrl: null,
      externalId: null,
      source: 'OCR',
      imageUrl: null,
      categories: ['shopping'],
      tags: itemNames.length > 5 ? itemNames.sublist(0, 5) : itemNames,
      metadata: {
        'receipt_data': receiptData,
        'store_name': storeName,
        'date': date,
        'total_amount': totalAmount,
        'items_count': items.length,
      },
      consumedAt: date != null ? _parseDate(date) : DateTime.now(),
      publishedAt: null,
      privacyLevel: PrivacyLevel.private,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 日付文字列をDateTimeに変換
  DateTime _parseDate(String dateStr) {
    try {
      // 「2023年3月15日」形式
      final yearMonthDayRegex = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日');
      final yearMonthDayMatch = yearMonthDayRegex.firstMatch(dateStr);
      if (yearMonthDayMatch != null) {
        final year = int.parse(yearMonthDayMatch.group(1)!);
        final month = int.parse(yearMonthDayMatch.group(2)!);
        final day = int.parse(yearMonthDayMatch.group(3)!);
        return DateTime(year, month, day);
      }
      
      // 「2023/3/15」形式
      final slashRegex = RegExp(r'(\d{4})/(\d{1,2})/(\d{1,2})');
      final slashMatch = slashRegex.firstMatch(dateStr);
      if (slashMatch != null) {
        final year = int.parse(slashMatch.group(1)!);
        final month = int.parse(slashMatch.group(2)!);
        final day = int.parse(slashMatch.group(3)!);
        return DateTime(year, month, day);
      }
      
      // 「2023-3-15」形式
      final dashRegex = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})');
      final dashMatch = dashRegex.firstMatch(dateStr);
      if (dashMatch != null) {
        final year = int.parse(dashMatch.group(1)!);
        final month = int.parse(dashMatch.group(2)!);
        final day = int.parse(dashMatch.group(3)!);
        return DateTime(year, month, day);
      }
      
      // パースできない場合は現在の日時を返す
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// 最小値を取得
  int min(int a, int b) {
    return a < b ? a : b;
  }
}

/// OCR例外クラス
class OcrException implements Exception {
  final String message;
  final dynamic details;

  OcrException(this.message, {this.details});

  @override
  String toString() => 'OcrException: $message';
}

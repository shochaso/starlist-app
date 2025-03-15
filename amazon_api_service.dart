import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/content_consumption_model.dart';

/// Amazon API連携サービスクラス
class AmazonApiService {
  final ApiClient _apiClient;
  final AppConfig _appConfig;
  final Dio _dio;

  /// コンストラクタ
  AmazonApiService({
    ApiClient? apiClient,
    AppConfig? appConfig,
    Dio? dio,
  })  : _apiClient = apiClient ?? ApiClient(),
        _appConfig = appConfig ?? AppConfig(),
        _dio = dio ?? Dio();

  /// Amazon Product Advertising APIのベースURL
  static const String _baseUrl = 'https://webservices.amazon.co.jp/paapi5/';

  /// 商品情報を取得
  Future<Map<String, dynamic>> getProductDetails(String asin) async {
    try {
      final response = await _dio.post(
        '${_baseUrl}getitems',
        data: {
          'ItemIds': [asin],
          'Resources': [
            'ItemInfo.Title',
            'ItemInfo.ByLineInfo',
            'ItemInfo.ContentInfo',
            'ItemInfo.ProductInfo',
            'ItemInfo.Features',
            'Images.Primary',
            'Images.Variants',
            'Offers.Listings.Price',
            'Offers.Listings.DeliveryInfo.IsPrimeEligible',
            'Offers.Summaries.LowestPrice',
          ],
          'PartnerTag': _appConfig.amazonPartnerTag,
          'PartnerType': 'Associates',
          'Marketplace': 'www.amazon.co.jp',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Amz-Target': 'com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetItems',
            'Host': 'webservices.amazon.co.jp',
            'X-Amz-Date': _getAmzDate(),
            'Authorization': _generateAuthHeader('GetItems'),
          },
        ),
      );

      if (response.statusCode == 200) {
        final itemsResponse = response.data['ItemsResult']['Items'];
        if (itemsResponse != null && itemsResponse.isNotEmpty) {
          return itemsResponse[0];
        } else {
          throw NotFoundException('指定されたASINの商品が見つかりませんでした');
        }
      } else {
        throw ApiException(
          'Amazon APIから商品情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Amazon APIから商品情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 商品検索を実行
  Future<List<Map<String, dynamic>>> searchProducts(
    String keywords, {
    String searchIndex = 'All',
    int itemCount = 10,
  }) async {
    try {
      final response = await _dio.post(
        '${_baseUrl}searchitems',
        data: {
          'Keywords': keywords,
          'SearchIndex': searchIndex,
          'ItemCount': itemCount,
          'Resources': [
            'ItemInfo.Title',
            'ItemInfo.ByLineInfo',
            'Images.Primary',
            'Offers.Listings.Price',
            'Offers.Listings.DeliveryInfo.IsPrimeEligible',
          ],
          'PartnerTag': _appConfig.amazonPartnerTag,
          'PartnerType': 'Associates',
          'Marketplace': 'www.amazon.co.jp',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Amz-Target': 'com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems',
            'Host': 'webservices.amazon.co.jp',
            'X-Amz-Date': _getAmzDate(),
            'Authorization': _generateAuthHeader('SearchItems'),
          },
        ),
      );

      if (response.statusCode == 200) {
        final searchResults = response.data['SearchResult']['Items'] as List;
        return searchResults.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'Amazon APIでの商品検索に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Amazon APIでの商品検索に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 購入履歴を取得（注：実際のAmazon APIでは購入履歴を直接取得できないため、モック実装）
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String accessToken) async {
    // 実際のAmazon APIでは購入履歴を直接取得できないため、
    // この機能はアプリ内でユーザーが手動で追加するか、
    // 別の方法（メールの解析など）で実装する必要があります。
    throw UnimplementedError('Amazon APIでは購入履歴を直接取得できません');
  }

  /// Amazon商品をContentConsumptionModelに変換
  ContentConsumptionModel convertProductToContentConsumption(
    Map<String, dynamic> productData,
    String userId,
  ) {
    final itemInfo = productData['ItemInfo'];
    final title = itemInfo['Title']['DisplayValue'];
    final byLineInfo = itemInfo['ByLineInfo'];
    final image = productData['Images']['Primary'];
    final offers = productData['Offers'];
    
    List<String>? authors;
    if (byLineInfo != null && byLineInfo['Contributors'] != null) {
      authors = (byLineInfo['Contributors'] as List)
          .map((contributor) => contributor['Name'] as String)
          .toList();
    }
    
    String? price;
    if (offers != null && offers['Listings'] != null && offers['Listings'].isNotEmpty) {
      price = offers['Listings'][0]['Price']['DisplayAmount'];
    }
    
    return ContentConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentType: ContentType.purchase,
      title: title,
      description: authors != null ? '著者/ブランド: ${authors.join(', ')}' : null,
      contentUrl: productData['DetailPageURL'],
      externalId: productData['ASIN'],
      source: 'Amazon',
      imageUrl: image['URL'],
      categories: ['shopping'],
      tags: authors,
      metadata: {
        'asin': productData['ASIN'],
        'price': price,
        'authors': authors,
        'isPrime': offers?['Listings']?[0]?['DeliveryInfo']?['IsPrimeEligible'],
      },
      consumedAt: DateTime.now(),
      publishedAt: null, // 商品の発売日情報がない場合はnull
      privacyLevel: PrivacyLevel.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Amazon認証URLを取得
  String getAuthUrl(String redirectUri, String clientId, List<String> scopes) {
    return 'https://www.amazon.co.jp/ap/oa?'
        'client_id=$clientId'
        '&scope=${scopes.join('%20')}'
        '&response_type=code'
        '&redirect_uri=$redirectUri';
  }

  /// 認証コードからアクセストークンを取得
  Future<Map<String, dynamic>> getAccessToken(
    String code,
    String redirectUri,
    String clientId,
    String clientSecret,
  ) async {
    try {
      final response = await _dio.post(
        'https://api.amazon.co.jp/auth/o2/token',
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          'アクセストークンの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'アクセストークンの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// リフレッシュトークンからアクセストークンを更新
  Future<Map<String, dynamic>> refreshAccessToken(
    String refreshToken,
    String clientId,
    String clientSecret,
  ) async {
    try {
      final response = await _dio.post(
        'https://api.amazon.co.jp/auth/o2/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          'アクセストークンの更新に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'アクセストークンの更新に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Amazon Product Advertising API用のAMZ日付を取得
  String _getAmzDate() {
    final now = DateTime.now().toUtc();
    final date = now.toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
    return date;
  }

  /// Amazon Product Advertising API用の認証ヘッダーを生成
  String _generateAuthHeader(String operation) {
    // 実際の実装では、AWS Signature Version 4の署名プロセスを実装する必要があります
    // これは複雑なプロセスであり、実際のアプリケーションでは専用のライブラリを使用することをお勧めします
    return 'AWS4-HMAC-SHA256 '
        'Credential=${_appConfig.amazonAccessKey}/${_getDateStamp()}/us-east-1/ProductAdvertisingAPI/aws4_request, '
        'SignedHeaders=content-type;host;x-amz-date;x-amz-target, '
        'Signature=dummy_signature_for_example';
  }

  /// 日付スタンプを取得
  String _getDateStamp() {
    final now = DateTime.now().toUtc();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }
}

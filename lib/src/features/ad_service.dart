import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/ad_model.dart';

/// 広告の管理と表示を行うサービスクラス
class AdService {
  final Dio _dio;
  final String _baseUrl;
  
  /// コンストラクタ
  AdService({
    Dio? dio,
    String baseUrl = 'https://api.starlist.com/ads',
  }) : _dio = dio ?? Dio(),
       _baseUrl = baseUrl;

  /// ユーザータイプに基づいて表示すべき広告を取得する
  /// [userType] ユーザータイプ（無料、スタンダードなど）
  /// [limit] 取得する広告数の上限
  /// [adType] 広告タイプ（バナー、インタースティシャルなど）
  Future<List<AdModel>> getAdsByUserType(
    String userType, {
    int limit = 5,
    AdType? adType,
  }) async {
    try {
      final queryParams = {
        'userType': userType,
        'limit': limit,
      };
      
      if (adType != null) {
        queryParams['adType'] = adType.toString().split('.').last;
      }
      
      final response = await _dio.get(
        '$_baseUrl/byUserType',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['ads'];
        return data.map((json) => AdModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ads: ${response.statusCode}');
      }
    } catch (e) {
      // 実際のAPIが存在しない場合のモックデータ
      return _getMockAdsByUserType(userType, limit: limit, adType: adType);
    }
  }

  /// 広告のインプレッションを記録する
  /// [adId] 広告ID
  /// [userId] ユーザーID
  Future<bool> recordImpression(String adId, String userId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/impressions',
        data: {
          'adId': adId,
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // 開発環境では成功したと仮定
      print('Ad impression recorded (mock): $adId by $userId');
      return true;
    }
  }

  /// 広告のクリックを記録する
  /// [adId] 広告ID
  /// [userId] ユーザーID
  Future<bool> recordClick(String adId, String userId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/clicks',
        data: {
          'adId': adId,
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // 開発環境では成功したと仮定
      print('Ad click recorded (mock): $adId by $userId');
      return true;
    }
  }

  /// 広告収益を計算する
  /// [startDate] 期間の開始日
  /// [endDate] 期間の終了日
  Future<Map<String, double>> calculateAdRevenue({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    try {
      final response = await _dio.get(
        '$_baseUrl/revenue',
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'impressionRevenue': data['impressionRevenue'],
          'clickRevenue': data['clickRevenue'],
          'totalRevenue': data['totalRevenue'],
        };
      } else {
        throw Exception('Failed to calculate ad revenue: ${response.statusCode}');
      }
    } catch (e) {
      // モックデータを返す
      final impressionRevenue = 50000.0;
      final clickRevenue = 30000.0;
      return {
        'impressionRevenue': impressionRevenue,
        'clickRevenue': clickRevenue,
        'totalRevenue': impressionRevenue + clickRevenue,
      };
    }
  }

  /// モックの広告データを生成する（開発用）
  List<AdModel> _getMockAdsByUserType(
    String userType, {
    int limit = 5,
    AdType? adType,
  }) {
    final ads = <AdModel>[];
    
    // 無料ユーザー向けの広告は多め、スタンダード会員向けは少なめ
    final count = userType == UserType.free ? limit : (limit ~/ 2);
    
    for (int i = 0; i < count; i++) {
      // 広告タイプの決定
      final type = adType ?? _getRandomAdType(i);
      
      // 広告サイズの決定
      final size = _getAdSizeForType(type, i);
      
      // ターゲットユーザータイプの決定
      final targetUserTypes = _getTargetUserTypes(userType);
      
      ads.add(
        AdModel(
          id: 'ad_${type.toString().split('.').last}_$i',
          title: '広告タイトル $i',
          description: 'これは${type.toString().split('.').last}広告の説明文です。',
          imageUrl: 'https://example.com/ads/${type.toString().split('.').last}_$i.jpg',
          targetUrl: 'https://example.com/landing/ad_$i',
          advertiserName: 'サンプル広告主 $i',
          type: type,
          size: size,
          targetUserTypes: targetUserTypes,
          cpmRate: 300.0 + (i * 50.0), // CPM単価（1000インプレッションあたり）
          cpcRate: 50.0 + (i * 10.0),  // CPC単価（クリックあたり）
        ),
      );
    }
    
    return ads;
  }

  /// ランダムな広告タイプを取得する
  AdType _getRandomAdType(int seed) {
    final types = [
      AdType.banner,
      AdType.native,
      AdType.interstitial,
      AdType.video,
    ];
    return types[seed % types.length];
  }

  /// 広告タイプに適したサイズを取得する
  AdSize _getAdSizeForType(AdType type, int seed) {
    switch (type) {
      case AdType.banner:
        final sizes = [AdSize.small, AdSize.medium, AdSize.large];
        return sizes[seed % sizes.length];
      case AdType.interstitial:
        return AdSize.fullScreen;
      case AdType.native:
        return AdSize.medium;
      case AdType.video:
        final sizes = [AdSize.medium, AdSize.large, AdSize.fullScreen];
        return sizes[seed % sizes.length];
    }
  }

  /// ターゲットユーザータイプを取得する
  List<String> _getTargetUserTypes(String userType) {
    if (userType == UserType.free) {
      return [UserType.free];
    } else if (userType == UserType.standard) {
      return [UserType.free, UserType.standard];
    } else {
      return [UserType.free, UserType.standard, UserType.premium];
    }
  }
}

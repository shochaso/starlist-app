import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';

/// NetflixのAPIサービスクラス
/// Netflixのデータ取得と処理を担当する
class NetflixApiService {
  final ApiClient _apiClient;
  final String _apiKey;

  static const String _baseUrl = 'https://api.example.com/netflix'; // 実際のエンドポイントに置き換える

  NetflixApiService({
    required String apiKey,
    ApiClient? apiClient,
  }) : _apiKey = apiKey,
       _apiClient = apiClient ?? ApiClient(baseUrl: _baseUrl);

  /// ユーザーの視聴履歴を取得する
  Future<Map<String, dynamic>> getViewingHistory({
    required String accessToken,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _apiClient.get(
        '/viewing-activity',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleNetflixError(e);
    }
  }

  /// コンテンツの詳細情報を取得する
  Future<Map<String, dynamic>> getContentDetails({
    required String accessToken,
    required String contentId,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _apiClient.get(
        '/content/$contentId',
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleNetflixError(e);
    }
  }

  /// ユーザーのプロフィール情報を取得する
  Future<Map<String, dynamic>> getUserProfile({
    required String accessToken,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _apiClient.get(
        '/profile',
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleNetflixError(e);
    }
  }

  /// ユーザーのリストを取得する
  Future<Map<String, dynamic>> getUserLists({
    required String accessToken,
    String listType = 'my-list',
  }) async {
    try {
      final queryParams = {
        'list_type': listType,
      };

      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _apiClient.get(
        '/lists',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleNetflixError(e);
    }
  }

  /// Netflix APIのエラーを処理する
  Exception _handleNetflixError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        message: 'Netflix API error: ${error.toString()}',
        statusCode: error is http.Response ? error.statusCode : null,
        details: error.toString(),
      );
    }
  }
}

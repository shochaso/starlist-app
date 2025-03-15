import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';

/// InstagramのAPIサービスクラス
/// Instagramのデータ取得と処理を担当する
class InstagramApiService {
  final ApiClient _apiClient;
  final String _accessToken;

  static const String _baseUrl = 'https://graph.instagram.com';

  InstagramApiService({
    required String accessToken,
    ApiClient? apiClient,
  }) : _accessToken = accessToken,
       _apiClient = apiClient ?? ApiClient(baseUrl: _baseUrl);

  /// ユーザープロフィールを取得する
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final queryParams = {
        'fields': 'id,username,account_type,media_count',
        'access_token': _accessToken,
      };

      final response = await _apiClient.get(
        '/me',
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleInstagramError(e);
    }
  }

  /// ユーザーのメディアを取得する
  Future<Map<String, dynamic>> getUserMedia({
    int limit = 25,
    String? after,
  }) async {
    try {
      final queryParams = {
        'fields': 'id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username',
        'access_token': _accessToken,
        'limit': limit.toString(),
      };

      if (after != null) {
        queryParams['after'] = after;
      }

      final response = await _apiClient.get(
        '/me/media',
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleInstagramError(e);
    }
  }

  /// メディアの詳細情報を取得する
  Future<Map<String, dynamic>> getMediaDetails({
    required String mediaId,
  }) async {
    try {
      final queryParams = {
        'fields': 'id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username,like_count,comments_count',
        'access_token': _accessToken,
      };

      final response = await _apiClient.get(
        '/$mediaId',
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleInstagramError(e);
    }
  }

  /// Instagram APIのエラーを処理する
  Exception _handleInstagramError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        message: 'Instagram API error: ${error.toString()}',
        statusCode: error is http.Response ? error.statusCode : null,
        details: error.toString(),
      );
    }
  }
}

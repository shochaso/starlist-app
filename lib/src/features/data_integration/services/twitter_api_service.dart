import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';

/// TwitterのAPIサービスクラス
/// Twitterのデータ取得と処理を担当する
class TwitterApiService {
  final ApiClient _apiClient;
  final String _apiKey;
  final String _apiKeySecret;
  final String _bearerToken;

  static const String _baseUrl = 'https://api.twitter.com/2';

  TwitterApiService({
    required String apiKey,
    required String apiKeySecret,
    required String bearerToken,
    ApiClient? apiClient,
  }) : _apiKey = apiKey,
       _apiKeySecret = apiKeySecret,
       _bearerToken = bearerToken,
       _apiClient = apiClient ?? ApiClient(baseUrl: _baseUrl);

  /// ユーザー情報を取得する
  Future<Map<String, dynamic>> getUserInfo({
    required String username,
    List<String> userFields = const ['id', 'name', 'username', 'profile_image_url', 'description', 'public_metrics'],
  }) async {
    try {
      final queryParams = {
        'usernames': username,
        'user.fields': userFields.join(','),
      };

      final headers = {
        'Authorization': 'Bearer $_bearerToken',
      };

      final response = await _apiClient.get(
        '/users/by',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleTwitterError(e);
    }
  }

  /// ユーザーのツイートを取得する
  Future<Map<String, dynamic>> getUserTweets({
    required String userId,
    int maxResults = 100,
    List<String> tweetFields = const ['id', 'text', 'created_at', 'public_metrics', 'attachments'],
    String? paginationToken,
  }) async {
    try {
      final queryParams = {
        'max_results': maxResults.toString(),
        'tweet.fields': tweetFields.join(','),
      };

      if (paginationToken != null) {
        queryParams['pagination_token'] = paginationToken;
      }

      final headers = {
        'Authorization': 'Bearer $_bearerToken',
      };

      final response = await _apiClient.get(
        '/users/$userId/tweets',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleTwitterError(e);
    }
  }

  /// ユーザーのフォロワーを取得する
  Future<Map<String, dynamic>> getUserFollowers({
    required String userId,
    int maxResults = 100,
    List<String> userFields = const ['id', 'name', 'username', 'profile_image_url'],
    String? paginationToken,
  }) async {
    try {
      final queryParams = {
        'max_results': maxResults.toString(),
        'user.fields': userFields.join(','),
      };

      if (paginationToken != null) {
        queryParams['pagination_token'] = paginationToken;
      }

      final headers = {
        'Authorization': 'Bearer $_bearerToken',
      };

      final response = await _apiClient.get(
        '/users/$userId/followers',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleTwitterError(e);
    }
  }

  /// ユーザーのフォロー中アカウントを取得する
  Future<Map<String, dynamic>> getUserFollowing({
    required String userId,
    int maxResults = 100,
    List<String> userFields = const ['id', 'name', 'username', 'profile_image_url'],
    String? paginationToken,
  }) async {
    try {
      final queryParams = {
        'max_results': maxResults.toString(),
        'user.fields': userFields.join(','),
      };

      if (paginationToken != null) {
        queryParams['pagination_token'] = paginationToken;
      }

      final headers = {
        'Authorization': 'Bearer $_bearerToken',
      };

      final response = await _apiClient.get(
        '/users/$userId/following',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleTwitterError(e);
    }
  }

  /// ツイートの詳細を取得する
  Future<Map<String, dynamic>> getTweetDetails({
    required String tweetId,
    List<String> tweetFields = const ['id', 'text', 'created_at', 'public_metrics', 'attachments', 'author_id'],
  }) async {
    try {
      final queryParams = {
        'tweet.fields': tweetFields.join(','),
      };

      final headers = {
        'Authorization': 'Bearer $_bearerToken',
      };

      final response = await _apiClient.get(
        '/tweets/$tweetId',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw _handleTwitterError(e);
    }
  }

  /// Twitter APIのエラーを処理する
  Exception _handleTwitterError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        message: 'Twitter API error: ${error.toString()}',
        statusCode: error is http.Response ? error.statusCode : null,
        details: error.toString(),
      );
    }
  }
}

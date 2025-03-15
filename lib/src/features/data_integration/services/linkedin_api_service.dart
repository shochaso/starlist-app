import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/content_consumption_model.dart';

/// LinkedIn API連携サービスクラス
class LinkedInApiService {
  final ApiClient _apiClient;
  final AppConfig _appConfig;
  final Dio _dio;

  /// コンストラクタ
  LinkedInApiService({
    ApiClient? apiClient,
    AppConfig? appConfig,
    Dio? dio,
  })  : _apiClient = apiClient ?? ApiClient(),
        _appConfig = appConfig ?? AppConfig(),
        _dio = dio ?? Dio();

  /// LinkedIn APIのベースURL
  static const String _baseUrl = 'https://api.linkedin.com/v2';

  /// ユーザープロフィールを取得
  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me',
        queryParameters: {
          'projection': '(id,firstName,lastName,profilePicture(displayImage~:playableStreams),headline,vanityName,publicProfileUrl)',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          'LinkedIn APIからユーザープロフィールの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザープロフィールの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーの投稿を取得
  Future<List<Map<String, dynamic>>> getUserPosts(
    String accessToken,
    String userId, {
    int count = 10,
    String? start,
  }) async {
    try {
      final queryParams = {
        'q': 'author',
        'author': userId,
        'count': count,
      };

      if (start != null) {
        queryParams['start'] = start;
      }

      final response = await _dio.get(
        '$_baseUrl/posts',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'LinkedIn APIからユーザーの投稿の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザーの投稿の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーのつながりを取得
  Future<List<Map<String, dynamic>>> getUserConnections(
    String accessToken, {
    int count = 50,
    String? start,
  }) async {
    try {
      final queryParams = {
        'q': 'viewer',
        'count': count,
      };

      if (start != null) {
        queryParams['start'] = start;
      }

      final response = await _dio.get(
        '$_baseUrl/connections',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'LinkedIn APIからユーザーのつながりの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザーのつながりの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーのスキルを取得
  Future<List<Map<String, dynamic>>> getUserSkills(
    String accessToken,
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/people/$userId/skills',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'LinkedIn APIからユーザーのスキルの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザーのスキルの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーの職歴を取得
  Future<List<Map<String, dynamic>>> getUserPositions(
    String accessToken,
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/people/$userId/positions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'LinkedIn APIからユーザーの職歴の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザーの職歴の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーの学歴を取得
  Future<List<Map<String, dynamic>>> getUserEducations(
    String accessToken,
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/people/$userId/educations',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'LinkedIn APIからユーザーの学歴の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'LinkedIn APIからユーザーの学歴の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザープロフィールをデータソースAPIから取得
  Future<Map<String, dynamic>> getUserProfileFromDataSource(String username) async {
    try {
      final response = await _apiClient.get(
        'LinkedIn/get_user_profile_by_username',
        queryParameters: {
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw ApiException(
            'LinkedIn プロフィールの取得に失敗しました: ${data['message']}',
          );
        }
      } else {
        throw ApiException(
          'LinkedIn プロフィールの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザー検索をデータソースAPIから実行
  Future<List<Map<String, dynamic>>> searchPeopleFromDataSource({
    required String keywords,
    String? firstName,
    String? lastName,
    String? keywordSchool,
    String? keywordTitle,
    String? company,
    String? start,
  }) async {
    try {
      final queryParams = {
        'keywords': keywords,
      };

      if (firstName != null) {
        queryParams['firstName'] = firstName;
      }

      if (lastName != null) {
        queryParams['lastName'] = lastName;
      }

      if (keywordSchool != null) {
        queryParams['keywordSchool'] = keywordSchool;
      }

      if (keywordTitle != null) {
        queryParams['keywordTitle'] = keywordTitle;
      }

      if (company != null) {
        queryParams['company'] = company;
      }

      if (start != null) {
        queryParams['start'] = start;
      }

      final response = await _apiClient.get(
        'LinkedIn/search_people',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return (data['data']['items'] as List).cast<Map<String, dynamic>>();
        } else {
          throw ApiException(
            'LinkedIn ユーザー検索に失敗しました: ${data['message']}',
          );
        }
      } else {
        throw ApiException(
          'LinkedIn ユーザー検索に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// LinkedIn投稿をContentConsumptionModelに変換
  ContentConsumptionModel convertPostToContentConsumption(
    Map<String, dynamic> postData,
    String userId,
  ) {
    final author = postData['author'];
    final authorName = '${author['firstName']} ${author['lastName']}';
    
    String? imageUrl;
    if (postData['content'] != null && 
        postData['content']['contentEntities'] != null && 
        postData['content']['contentEntities'].isNotEmpty) {
      final entity = postData['content']['contentEntities'][0];
      if (entity['thumbnails'] != null && entity['thumbnails'].isNotEmpty) {
        imageUrl = entity['thumbnails'][0]['resolvedUrl'];
      }
    }

    return ContentConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentType: ContentType.other,
      title: 'LinkedIn投稿: $authorName',
      description: postData['commentary'] != null ? postData['commentary']['text'] : null,
      contentUrl: postData['updateUrl'],
      externalId: postData['id'],
      source: 'LinkedIn',
      imageUrl: imageUrl,
      categories: ['social'],
      tags: ['linkedin', 'post'],
      metadata: {
        'author': authorName,
        'authorId': author['id'],
        'likeCount': postData['likeCount'],
        'commentCount': postData['commentCount'],
      },
      consumedAt: DateTime.now(),
      publishedAt: postData['created'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(postData['created']['time'])
          : null,
      privacyLevel: PrivacyLevel.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// LinkedIn APIの認証URLを取得
  String getAuthUrl(String redirectUri, String clientId, List<String> scopes) {
    return 'https://www.linkedin.com/oauth/v2/authorization?'
        'response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=${scopes.join('%20')}';
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
        'https://www.linkedin.com/oauth/v2/accessToken',
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
        'https://www.linkedin.com/oauth/v2/accessToken',
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
}

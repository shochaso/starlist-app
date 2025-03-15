import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/content_consumption_model.dart';

/// YouTube API連携サービスクラス
class YouTubeApiService {
  final ApiClient _apiClient;
  final AppConfig _appConfig;
  final Dio _dio;

  /// コンストラクタ
  YouTubeApiService({
    ApiClient? apiClient,
    AppConfig? appConfig,
    Dio? dio,
  })  : _apiClient = apiClient ?? ApiClient(),
        _appConfig = appConfig ?? AppConfig(),
        _dio = dio ?? Dio();

  /// YouTube APIのベースURL
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// ユーザーのチャンネル情報を取得
  Future<Map<String, dynamic>> getUserChannel(String accessToken) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/channels',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'mine': true,
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
          'YouTube APIからチャンネル情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIからチャンネル情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーのサブスクリプションチャンネルを取得
  Future<List<Map<String, dynamic>>> getSubscriptions(
    String accessToken, {
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      final List<Map<String, dynamic>> allResults = [];
      String? nextPageToken = pageToken;

      do {
        final response = await _dio.get(
          '$_baseUrl/subscriptions',
          queryParameters: {
            'part': 'snippet,contentDetails',
            'mine': true,
            'maxResults': maxResults,
            'pageToken': nextPageToken,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          final items = response.data['items'] as List;
          allResults.addAll(items.cast<Map<String, dynamic>>());
          nextPageToken = response.data['nextPageToken'];
        } else {
          throw ApiException(
            'YouTube APIからサブスクリプション情報の取得に失敗しました',
            statusCode: response.statusCode,
          );
        }
      } while (nextPageToken != null);

      return allResults;
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIからサブスクリプション情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザーの視聴履歴を取得
  Future<List<Map<String, dynamic>>> getWatchHistory(
    String accessToken, {
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      final List<Map<String, dynamic>> allResults = [];
      String? nextPageToken = pageToken;

      do {
        final response = await _dio.get(
          '$_baseUrl/activities',
          queryParameters: {
            'part': 'snippet,contentDetails',
            'mine': true,
            'maxResults': maxResults,
            'pageToken': nextPageToken,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          final items = response.data['items'] as List;
          allResults.addAll(items.cast<Map<String, dynamic>>());
          nextPageToken = response.data['nextPageToken'];
        } else {
          throw ApiException(
            'YouTube APIから視聴履歴の取得に失敗しました',
            statusCode: response.statusCode,
          );
        }
      } while (nextPageToken != null);

      return allResults;
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIから視聴履歴の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 動画情報を取得
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoId,
          'key': _appConfig.youtubeApiKey,
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        if (items.isNotEmpty) {
          return items.first as Map<String, dynamic>;
        } else {
          throw NotFoundException('指定されたIDの動画が見つかりませんでした');
        }
      } else {
        throw ApiException(
          'YouTube APIから動画情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIから動画情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// チャンネル情報を取得
  Future<Map<String, dynamic>> getChannelDetails(String channelId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/channels',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': channelId,
          'key': _appConfig.youtubeApiKey,
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        if (items.isNotEmpty) {
          return items.first as Map<String, dynamic>;
        } else {
          throw NotFoundException('指定されたIDのチャンネルが見つかりませんでした');
        }
      } else {
        throw ApiException(
          'YouTube APIからチャンネル情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIからチャンネル情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 検索を実行
  Future<List<Map<String, dynamic>>> searchVideos(
    String query, {
    int maxResults = 25,
    String? pageToken,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults,
          'pageToken': pageToken,
          'key': _appConfig.youtubeApiKey,
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'YouTube APIでの検索に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'YouTube APIでの検索に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// YouTube動画をContentConsumptionModelに変換
  ContentConsumptionModel convertVideoToContentConsumption(
    Map<String, dynamic> videoData,
    String userId,
  ) {
    final snippet = videoData['snippet'];
    final contentDetails = videoData['contentDetails'];
    final statistics = videoData['statistics'];

    return ContentConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentType: ContentType.youtubeVideo,
      title: snippet['title'],
      description: snippet['description'],
      contentUrl: 'https://www.youtube.com/watch?v=${videoData['id']}',
      externalId: videoData['id'],
      source: 'YouTube',
      imageUrl: snippet['thumbnails']['high']['url'],
      categories: [snippet['categoryId']],
      tags: snippet['tags'] != null ? List<String>.from(snippet['tags']) : null,
      metadata: {
        'channelId': snippet['channelId'],
        'channelTitle': snippet['channelTitle'],
        'duration': contentDetails?['duration'],
        'viewCount': statistics?['viewCount'],
        'likeCount': statistics?['likeCount'],
        'commentCount': statistics?['commentCount'],
      },
      consumedAt: DateTime.now(),
      publishedAt: DateTime.parse(snippet['publishedAt']),
      privacyLevel: PrivacyLevel.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// YouTube APIの認証URLを取得
  String getAuthUrl(String redirectUri, String clientId) {
    return 'https://accounts.google.com/o/oauth2/auth?'
        'client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=https://www.googleapis.com/auth/youtube.readonly'
        '&response_type=code'
        '&access_type=offline'
        '&prompt=consent';
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
        'https://oauth2.googleapis.com/token',
        data: {
          'code': code,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
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
        'https://oauth2.googleapis.com/token',
        data: {
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'refresh_token',
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

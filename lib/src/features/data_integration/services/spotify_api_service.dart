import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/content_consumption_model.dart';

/// Spotify API連携サービスクラス
class SpotifyApiService {
  final ApiClient _apiClient;
  final AppConfig _appConfig;
  final Dio _dio;

  /// コンストラクタ
  SpotifyApiService({
    ApiClient? apiClient,
    AppConfig? appConfig,
    Dio? dio,
  })  : _apiClient = apiClient ?? ApiClient(),
        _appConfig = appConfig ?? AppConfig(),
        _dio = dio ?? Dio();

  /// Spotify APIのベースURL
  static const String _baseUrl = 'https://api.spotify.com/v1';

  /// ユーザープロフィールを取得
  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me',
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
          'Spotify APIからユーザープロフィールの取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからユーザープロフィールの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 最近再生した曲を取得
  Future<List<Map<String, dynamic>>> getRecentlyPlayed(
    String accessToken, {
    int limit = 50,
    String? before,
    String? after,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
      };

      if (before != null) {
        queryParams['before'] = before;
      }

      if (after != null) {
        queryParams['after'] = after;
      }

      final response = await _dio.get(
        '$_baseUrl/me/player/recently-played',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'Spotify APIから最近再生した曲の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIから最近再生した曲の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// お気に入りのトラックを取得
  Future<List<Map<String, dynamic>>> getSavedTracks(
    String accessToken, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final List<Map<String, dynamic>> allResults = [];
      int currentOffset = offset;
      bool hasMore = true;

      while (hasMore) {
        final response = await _dio.get(
          '$_baseUrl/me/tracks',
          queryParameters: {
            'limit': limit,
            'offset': currentOffset,
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
          
          currentOffset += items.length;
          hasMore = items.length == limit && response.data['next'] != null;
        } else {
          throw ApiException(
            'Spotify APIからお気に入りのトラックの取得に失敗しました',
            statusCode: response.statusCode,
          );
        }
      }

      return allResults;
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからお気に入りのトラックの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// お気に入りのアルバムを取得
  Future<List<Map<String, dynamic>>> getSavedAlbums(
    String accessToken, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final List<Map<String, dynamic>> allResults = [];
      int currentOffset = offset;
      bool hasMore = true;

      while (hasMore) {
        final response = await _dio.get(
          '$_baseUrl/me/albums',
          queryParameters: {
            'limit': limit,
            'offset': currentOffset,
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
          
          currentOffset += items.length;
          hasMore = items.length == limit && response.data['next'] != null;
        } else {
          throw ApiException(
            'Spotify APIからお気に入りのアルバムの取得に失敗しました',
            statusCode: response.statusCode,
          );
        }
      }

      return allResults;
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからお気に入りのアルバムの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// フォロー中のアーティストを取得
  Future<List<Map<String, dynamic>>> getFollowedArtists(
    String accessToken, {
    int limit = 50,
    String? after,
  }) async {
    try {
      final List<Map<String, dynamic>> allResults = [];
      String? currentAfter = after;
      bool hasMore = true;

      while (hasMore) {
        final queryParams = {
          'type': 'artist',
          'limit': limit,
        };

        if (currentAfter != null) {
          queryParams['after'] = currentAfter;
        }

        final response = await _dio.get(
          '$_baseUrl/me/following',
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          final artists = response.data['artists'];
          final items = artists['items'] as List;
          allResults.addAll(items.cast<Map<String, dynamic>>());
          
          currentAfter = artists['cursors']?['after'];
          hasMore = items.length == limit && currentAfter != null;
        } else {
          throw ApiException(
            'Spotify APIからフォロー中のアーティストの取得に失敗しました',
            statusCode: response.statusCode,
          );
        }
      }

      return allResults;
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからフォロー中のアーティストの取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// トラック情報を取得
  Future<Map<String, dynamic>> getTrackDetails(
    String trackId,
    String accessToken,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tracks/$trackId',
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
          'Spotify APIからトラック情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからトラック情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// アルバム情報を取得
  Future<Map<String, dynamic>> getAlbumDetails(
    String albumId,
    String accessToken,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/albums/$albumId',
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
          'Spotify APIからアルバム情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからアルバム情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// アーティスト情報を取得
  Future<Map<String, dynamic>> getArtistDetails(
    String artistId,
    String accessToken,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/artists/$artistId',
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
          'Spotify APIからアーティスト情報の取得に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIからアーティスト情報の取得に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 検索を実行
  Future<Map<String, List<Map<String, dynamic>>>> search(
    String query,
    List<String> types,
    String accessToken, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'type': types.join(','),
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, List<Map<String, dynamic>>> results = {};
        
        for (final type in types) {
          final typeKey = '${type}s'; // tracks, albums, artists, etc.
          if (response.data.containsKey(typeKey)) {
            final items = response.data[typeKey]['items'] as List;
            results[typeKey] = items.cast<Map<String, dynamic>>();
          }
        }
        
        return results;
      } else {
        throw ApiException(
          'Spotify APIでの検索に失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException(
          'Spotify APIでの検索に失敗しました: ${e.message}',
          statusCode: e.response?.statusCode,
          details: e,
        );
      }
      throw UnexpectedException('予期せぬエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Spotify楽曲をContentConsumptionModelに変換
  ContentConsumptionModel convertTrackToContentConsumption(
    Map<String, dynamic> trackData,
    String userId,
  ) {
    final artists = (trackData['artists'] as List)
        .map((artist) => artist['name'] as String)
        .toList();
    
    final album = trackData['album'];
    final images = album['images'] as List;
    String? imageUrl;
    if (images.isNotEmpty) {
      imageUrl = images.first['url'];
    }

    return ContentConsumptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentType: ContentType.music,
      title: trackData['name'],
      description: 'アーティスト: ${artists.join(', ')}、アルバム: ${album['name']}',
      contentUrl: trackData['external_urls']['spotify'],
      externalId: trackData['id'],
      source: 'Spotify',
      imageUrl: imageUrl,
      categories: ['music'],
      tags: artists,
      metadata: {
        'artists': artists,
        'album': album['name'],
        'albumId': album['id'],
        'releaseDate': album['release_date'],
        'duration': trackData['duration_ms'],
        'popularity': trackData['popularity'],
        'isExplicit': trackData['explicit'],
      },
      consumedAt: DateTime.now(),
      publishedAt: album['release_date'] != null
          ? DateTime.parse(album['release_date'])
          : null,
      privacyLevel: PrivacyLevel.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Spotify APIの認証URLを取得
  String getAuthUrl(String redirectUri, String clientId, List<String> scopes) {
    return 'https://accounts.spotify.com/authorize?'
        'client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=${scopes.join('%20')}'
        '&response_type=code'
        '&show_dialog=true';
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
        'https://accounts.spotify.com/api/token',
        data: {
          'code': code,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          },
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
        'https://accounts.spotify.com/api/token',
        data: {
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          },
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

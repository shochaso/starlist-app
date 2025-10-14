import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:googleapis/youtube/v3.dart' as youtube_api;
import 'package:googleapis_auth/auth_io.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/youtube_video.dart';

/// YouTubeのAPIと連携するサービスクラス
class YouTubeApiService {
  // Dioインスタンス
  final Dio _dio;
  
  // YouTube Explodeインスタンス（API制限のないデータ取得用）
  final YoutubeExplode _youtubeExplode;
  
  // YouTube Data API v3のAPIキー
  final String _apiKey;
  
  // OAuth2クライアントID（認証が必要な場合）
  final String? _clientId;
  
  // OAuth2クライアントシークレット（認証が必要な場合）
  final String? _clientSecret;
  
  // 認証済みのYouTube APIクライアント
  youtube_api.YouTubeApi? _youtubeApi;

  /// コンストラクタ
  YouTubeApiService({
    required String apiKey,
    String? clientId,
    String? clientSecret,
    Dio? dio,
  }) : _apiKey = apiKey,
       _clientId = clientId,
       _clientSecret = clientSecret,
       _dio = dio ?? Dio(),
       _youtubeExplode = YoutubeExplode();

  /// リソースの解放
  void dispose() {
    _youtubeExplode.close();
    _dio.close();
  }

  /// YouTube Data API v3を使用して動画を検索する
  /// [query] 検索クエリ
  /// [maxResults] 取得する最大結果数
  Future<List<YouTubeVideo>> searchVideos(String query, {int maxResults = 10}) async {
    try {
      final response = await _dio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults,
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List<dynamic>;
        
        // 検索結果から動画IDのリストを抽出
        final videoIds = items.map((item) => item['id']['videoId'] as String).toList();
        
        // 動画の詳細情報を取得
        return await getVideoDetails(videoIds);
      } else {
        throw Exception('Failed to search videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }

  /// 指定された動画IDのリストに対応する動画の詳細情報を取得する
  /// [videoIds] 動画IDのリスト
  Future<List<YouTubeVideo>> getVideoDetails(List<String> videoIds) async {
    if (videoIds.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds.join(','),
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get video details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting video details: $e');
    }
  }

  /// チャンネルIDに基づいて、そのチャンネルの最新動画を取得する
  /// [channelId] YouTubeチャンネルID
  /// [maxResults] 取得する最大結果数
  Future<List<YouTubeVideo>> getChannelVideos(String channelId, {int maxResults = 10}) async {
    try {
      final response = await _dio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'order': 'date',
          'type': 'video',
          'maxResults': maxResults,
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List<dynamic>;
        
        // 検索結果から動画IDのリストを抽出
        final videoIds = items.map((item) => item['id']['videoId'] as String).toList();
        
        // 動画の詳細情報を取得
        return await getVideoDetails(videoIds);
      } else {
        throw Exception('Failed to get channel videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting channel videos: $e');
    }
  }

  /// ユーザーの視聴履歴を取得する（OAuth2認証が必要）
  /// 注意: この機能を使用するには、ユーザーの認証が必要です
  Future<List<YouTubeVideo>> getWatchHistory() async {
    // OAuth2クライアントの初期化
    if (_clientId == null || _clientSecret == null) {
      throw Exception('OAuth2 credentials are required for this operation');
    }

    if (_youtubeApi == null) {
      await _authenticateWithOAuth2();
    }

    try {
      // 視聴履歴を取得（マイアクティビティAPIを使用）
      final activities = await _youtubeApi!.activities.list(
        ['snippet', 'contentDetails'],
        mine: true,
      );

      final videoIds = <String>[];
      
      // 視聴アクティビティから動画IDを抽出
      if (activities.items != null) {
        for (var activity in activities.items!) {
          if (activity.snippet?.type == 'watch' && 
              activity.contentDetails?.watch?.videoId != null) {
            videoIds.add(activity.contentDetails!.watch!.videoId!);
          }
        }
      }
      
      // 動画の詳細情報を取得
      return await getVideoDetails(videoIds);
    } catch (e) {
      throw Exception('Error getting watch history: $e');
    }
  }

  /// YouTube Explodeを使用して動画の詳細情報を取得する（API制限なし）
  /// [videoId] 動画ID
  Future<YouTubeVideo?> getVideoInfoWithoutApiKey(String videoId) async {
    try {
      final video = await _youtubeExplode.videos.get(videoId);
      
      // 統計情報を取得
      final engagement = await _youtubeExplode.videos.getEngagementStatistics(videoId);
      
      return YouTubeVideo(
        id: video.id.value,
        title: video.title,
        channelId: video.channelId.value,
        channelTitle: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        description: video.description,
        publishedAt: video.uploadDate ?? DateTime.now(),
        viewCount: engagement.viewCount ?? 0,
        likeCount: engagement.likeCount ?? 0,
        duration: video.duration ?? Duration.zero,
      );
    } catch (e) {
      print('Error getting video info without API key: $e');
      return null;
    }
  }

  /// OAuth2認証を使用してYouTube APIクライアントを初期化する
  Future<void> _authenticateWithOAuth2() async {
    if (_clientId == null || _clientSecret == null) {
      throw Exception('OAuth2 credentials are required for authentication');
    }

    final credentials = ClientId(_clientId, _clientSecret);
    
    // 必要なスコープを指定
    const scopes = [
      youtube_api.YouTubeApi.youtubeReadonlyScope,
    ];

    try {
      // 認証クライアントを取得
      final client = await clientViaUserConsent(credentials, scopes, (url) {
        print('Please go to the following URL and grant access:');
        print(url);
        // 注意: 実際のアプリでは、WebViewやブラウザを開いてユーザーに認証を促す必要があります
      });
      
      // YouTube APIクライアントを初期化
      _youtubeApi = youtube_api.YouTubeApi(client);
    } catch (e) {
      throw Exception('Failed to authenticate with OAuth2: $e');
    }
  }
}

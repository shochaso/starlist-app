import 'dart:convert';
import 'package:http/http.dart' as http;

/// 中学生でも使える超簡単YouTube API
class SimpleYouTubeService {
  // APIキーを入れる場所（後で設定ファイルから読み込み）
  static String apiKey = 'YOUR_API_KEY_HERE';
  
  /// YouTubeチャンネルの情報を取得（超簡単版）
  static Future<YouTubeChannel?> getChannel(String channelId) async {
    try {
      // 1. URLを作る
      final url = 'https://www.googleapis.com/youtube/v3/channels'
          '?part=snippet,statistics'
          '&id=$channelId'
          '&key=$apiKey';
      
      // 2. インターネットからデータを取得
      final response = await http.get(Uri.parse(url));
      
      // 3. データが正常に取得できたかチェック
      if (response.statusCode != 200) {
        print('エラー: ${response.statusCode}');
        return null;
      }
      
      // 4. JSONデータを解析
      final data = json.decode(response.body);
      final items = data['items'] as List;
      
      if (items.isEmpty) {
        print('チャンネルが見つかりません');
        return null;
      }
      
      // 5. 必要な情報だけ取り出す
      final channelData = items[0];
      return YouTubeChannel.fromSimpleData(channelData);
      
    } catch (e) {
      print('エラーが発生しました: $e');
      return null;
    }
  }
  
  /// YouTubeチャンネルの動画一覧を取得（超簡単版）
  static Future<List<YouTubeVideo>> getChannelVideos(String channelId) async {
    try {
      // 1. まずチャンネル情報を取得してアップロードプレイリストIDを取得
      final channelUrl = 'https://www.googleapis.com/youtube/v3/channels'
          '?part=contentDetails'
          '&id=$channelId'
          '&key=$apiKey';
      
      final channelResponse = await http.get(Uri.parse(channelUrl));
      
      if (channelResponse.statusCode != 200) {
        print('チャンネル取得エラー: ${channelResponse.statusCode}');
        return [];
      }
      
      final channelData = json.decode(channelResponse.body);
      final channelItems = channelData['items'] as List;
      
      if (channelItems.isEmpty) return [];
      
      // アップロードプレイリストIDを取得
      final uploadsPlaylistId = channelItems[0]['contentDetails']['relatedPlaylists']['uploads'];
      
      // 2. プレイリストから動画一覧を取得
      final playlistUrl = 'https://www.googleapis.com/youtube/v3/playlistItems'
          '?part=snippet'
          '&playlistId=$uploadsPlaylistId'
          '&maxResults=10'
          '&key=$apiKey';
      
      final playlistResponse = await http.get(Uri.parse(playlistUrl));
      
      if (playlistResponse.statusCode != 200) {
        print('プレイリスト取得エラー: ${playlistResponse.statusCode}');
        return [];
      }
      
      final playlistData = json.decode(playlistResponse.body);
      final playlistItems = playlistData['items'] as List;
      
      // 3. 動画IDを集める
      final videoIds = <String>[];
      for (final item in playlistItems) {
        final videoId = item['snippet']['resourceId']['videoId'];
        if (videoId != null) {
          videoIds.add(videoId);
        }
      }
      
      if (videoIds.isEmpty) return [];
      
      // 4. 動画の詳細情報を取得
      final videosUrl = 'https://www.googleapis.com/youtube/v3/videos'
          '?part=snippet,statistics'
          '&id=${videoIds.join(',')}'
          '&key=$apiKey';
      
      final videosResponse = await http.get(Uri.parse(videosUrl));
      
      if (videosResponse.statusCode != 200) {
        print('動画詳細取得エラー: ${videosResponse.statusCode}');
        return [];
      }
      
      final videosData = json.decode(videosResponse.body);
      final videoItems = videosData['items'] as List;
      
      // 5. 動画リストを作成
      final videos = <YouTubeVideo>[];
      for (final videoData in videoItems) {
        videos.add(YouTubeVideo.fromSimpleData(videoData));
      }
      
      return videos;
      
    } catch (e) {
      print('動画取得エラー: $e');
      return [];
    }
  }
  
  /// 動画を検索（簡単版）
  static Future<List<YouTubeVideo>> searchVideos(String searchWord) async {
    try {
      // 1. 検索用URLを作る
      final url = 'https://www.googleapis.com/youtube/v3/search'
          '?part=snippet'
          '?q=${Uri.encodeComponent(searchWord)}'
          '&type=video'
          '&maxResults=10'
          '&key=$apiKey';
      
      // 2. 検索実行
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        print('検索エラー: ${response.statusCode}');
        return [];
      }
      
      final data = json.decode(response.body);
      final items = data['items'] as List;
      
      // 3. 検索結果を動画リストに変換
      final videos = <YouTubeVideo>[];
      for (final item in items) {
        videos.add(YouTubeVideo.fromSearchData(item));
      }
      
      return videos;
      
    } catch (e) {
      print('検索処理エラー: $e');
      return [];
    }
  }
}

/// YouTubeチャンネル情報（簡単版）
class YouTubeChannel {
  final String id;           // チャンネルID
  final String name;         // チャンネル名
  final String description;  // 説明文
  final String imageUrl;     // アイコン画像URL
  final int subscriberCount; // 登録者数
  final int videoCount;      // 動画数
  final int viewCount;       // 総再生回数
  
  YouTubeChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
  });
  
  /// JSONデータから作成（簡単版）
  factory YouTubeChannel.fromSimpleData(Map<String, dynamic> data) {
    final snippet = data['snippet'];
    final statistics = data['statistics'];
    
    return YouTubeChannel(
      id: data['id'] ?? '',
      name: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      imageUrl: snippet['thumbnails']['high']['url'] ?? '',
      subscriberCount: int.tryParse(statistics['subscriberCount'] ?? '0') ?? 0,
      videoCount: int.tryParse(statistics['videoCount'] ?? '0') ?? 0,
      viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
    );
  }
  
  /// 登録者数を見やすい形で表示
  String get subscriberCountText {
    if (subscriberCount >= 1000000) {
      return '${(subscriberCount / 1000000).toStringAsFixed(1)}M人';
    } else if (subscriberCount >= 1000) {
      return '${(subscriberCount / 1000).toStringAsFixed(1)}K人';
    } else {
      return '$subscriberCount人';
    }
  }
}

/// YouTube動画情報（簡単版）
class YouTubeVideo {
  final String id;          // 動画ID
  final String title;       // タイトル
  final String description; // 説明文
  final String imageUrl;    // サムネイル画像URL
  final String channelName; // チャンネル名
  final int viewCount;      // 再生回数
  final int likeCount;      // いいね数
  final DateTime publishedAt; // 公開日
  
  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.channelName,
    required this.viewCount,
    required this.likeCount,
    required this.publishedAt,
  });
  
  /// JSONデータから作成（動画詳細版）
  factory YouTubeVideo.fromSimpleData(Map<String, dynamic> data) {
    final snippet = data['snippet'];
    final statistics = data['statistics'] ?? {};
    
    return YouTubeVideo(
      id: data['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      imageUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelName: snippet['channelTitle'] ?? '',
      viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
      likeCount: int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
  
  /// JSONデータから作成（検索結果版）
  factory YouTubeVideo.fromSearchData(Map<String, dynamic> data) {
    final snippet = data['snippet'];
    
    return YouTubeVideo(
      id: data['id']['videoId'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      imageUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelName: snippet['channelTitle'] ?? '',
      viewCount: 0, // 検索結果では取得できない
      likeCount: 0, // 検索結果では取得できない
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
  
  /// 再生回数を見やすい形で表示
  String get viewCountText {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M回再生';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K回再生';
    } else {
      return '$viewCount回再生';
    }
  }
  
  /// 公開日を見やすい形で表示
  String get publishedText {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}日前';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inMinutes}分前';
    }
  }
  
  /// YouTubeの動画URLを取得
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';
}
import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_improved/src/features/data_integration/models/youtube_video.dart';

void main() {
  group('YouTubeVideo', () {
    test('fromJson should correctly parse YouTube API response', () {
      // テスト用のモックデータ
      final json = {
        'id': 'testVideoId',
        'snippet': {
          'title': 'Test Video Title',
          'channelId': 'testChannelId',
          'channelTitle': 'Test Channel',
          'description': 'This is a test video description',
          'publishedAt': '2023-01-01T12:00:00Z',
          'thumbnails': {
            'high': {
              'url': 'https://example.com/high.jpg',
            },
          },
        },
        'statistics': {
          'viewCount': '1000',
          'likeCount': '100',
        },
        'contentDetails': {
          'duration': 'PT1H2M3S',
        },
      };

      // モデルに変換
      final video = YouTubeVideo.fromJson(json);

      // 各フィールドが正しく変換されているか検証
      expect(video.id, 'testVideoId');
      expect(video.title, 'Test Video Title');
      expect(video.channelId, 'testChannelId');
      expect(video.channelTitle, 'Test Channel');
      expect(video.description, 'This is a test video description');
      expect(video.thumbnailUrl, 'https://example.com/high.jpg');
      expect(video.publishedAt, DateTime(2023, 1, 1, 12));
      expect(video.viewCount, 1000);
      expect(video.likeCount, 100);
      expect(video.duration, const Duration(hours: 1, minutes: 2, seconds: 3));
    });

    test('toJson should correctly convert to JSON format', () {
      // テスト用のYouTubeVideoインスタンス
      final video = YouTubeVideo(
        id: 'testVideoId',
        title: 'Test Video Title',
        channelId: 'testChannelId',
        channelTitle: 'Test Channel',
        thumbnailUrl: 'https://example.com/high.jpg',
        description: 'This is a test video description',
        publishedAt: DateTime(2023, 1, 1, 12),
        viewCount: 1000,
        likeCount: 100,
        duration: const Duration(hours: 1, minutes: 2, seconds: 3),
      );

      // JSONに変換
      final json = video.toJson();

      // 各フィールドが正しく変換されているか検証
      expect(json['id'], 'testVideoId');
      expect(json['title'], 'Test Video Title');
      expect(json['channelId'], 'testChannelId');
      expect(json['channelTitle'], 'Test Channel');
      expect(json['thumbnailUrl'], 'https://example.com/high.jpg');
      expect(json['description'], 'This is a test video description');
      expect(json['publishedAt'], '2023-01-01T12:00:00.000');
      expect(json['viewCount'], 1000);
      expect(json['likeCount'], 100);
      expect(json['duration'], 3723); // 1時間2分3秒 = 3723秒
    });

    test('_parseDuration should correctly parse ISO 8601 duration format', () {
      // PT1H2M3S形式の期間文字列をパースするテスト
      final duration1 = YouTubeVideo._parseDuration('PT1H2M3S');
      expect(duration1, const Duration(hours: 1, minutes: 2, seconds: 3));

      // PT5M30S形式の期間文字列をパースするテスト
      final duration2 = YouTubeVideo._parseDuration('PT5M30S');
      expect(duration2, const Duration(minutes: 5, seconds: 30));

      // PT30S形式の期間文字列をパースするテスト
      final duration3 = YouTubeVideo._parseDuration('PT30S');
      expect(duration3, const Duration(seconds: 30));

      // PT2H形式の期間文字列をパースするテスト
      final duration4 = YouTubeVideo._parseDuration('PT2H');
      expect(duration4, const Duration(hours: 2));
    });
  });
}

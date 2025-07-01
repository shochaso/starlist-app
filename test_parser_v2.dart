import 'lib/src/services/youtube_ocr_parser_v2.dart';

void main() {
  // 手動で構造化されたテストデータ
  final videos = [
    VideoData(
      title: 'FF7 リバースの世界へ...（まってた）【FF7R-part1】',
      channel: '跳兎',
      viewCount: '5万 回視聴',
    ),
    VideoData(
      title: '【FF7リバース】セフィロスの正体と目的がヤバイ',
      channel: 'てつお／ゲーム考察＆ストーリー解説',
      viewCount: '30万回視聴',
    ),
    VideoData(
      title: '【FF8】25年経ってもリメイクの噂すらない残酷な理由',
      channel: 'てつお／ゲーム考察＆ストーリー解説',
      viewCount: '81万 回視聴',
    ),
    VideoData(
      title: 'FF8 世界一わかりやすいリノアル説',
      channel: 'てつお/ゲーム考察＆ストーリー解説',
      viewCount: '498万回視聴',
    ),
    VideoData(
      title: '【クラロワ】第2回新システムの試運転スイスドロー大会に参加する！',
      channel: 'ラッシュ CR',
      viewCount: '1.1万回視聴',
    ),
    VideoData(
      title: '【クラロワ】ルーカス激ヤバデッキ連発でアルデンブチギレwww ルーカス VS アルデン',
      channel: 'ラッシュ CR',
      viewCount: '7.3万 回視聴',
    ),
    VideoData(
      title: '【やかんの麦茶】もうひとつのクレヨンしんちゃん 第6話「お久しぶりの春日部だゾ！」篇',
      channel: 'コカ・コーラ',
      viewCount: '190万 回視聴',
    ),
  ];

  print('=== 期待される出力結果 ===');
  for (int i = 0; i < videos.length; i++) {
    final video = videos[i];
    print('${i + 1}.');
    print('題名：${video.title}');
    print('投稿者：${video.channel}');
    if (video.viewCount != null) {
      print('視聴回数：${video.viewCount}');
    }
    print('');
  }
  
  // パーサーのテスト
  const testData = '''
FF7 リバースの世界へ...（まってた）【FF7R-part1】
跳兎・5万 回視聴
【FF7リバース】セフィロスの正体と目的がヤバイ
てつお／ゲーム考察＆ストーリー解説
30万回視聴
【FF8】25年経ってもリメイクの噂すらない残酷な理由
てつお／ゲーム考察＆ストーリー解説
81万 回視聴
：
FF8 世界一わかりやすいリノ
アル説
てつお/ゲーム考察＆ストーリー解説
498万回視聴
【クラロワ】第2回新システムの試運転スイスドロー大会に参加する！ #ClashRoyale
ラッシュ CR・1.1万回視聴
【クラロワ】ルーカス激ヤバデッキ連発でアルデンブチギレ
www ルーカス VS アルデン・.
ラッシュ CR・7.3万 回視聴
【やかんの麦茶】もうひとつのクレヨンしんちゃん 第6話「お久しぶりの春日部だゾ！」篇・・コカ・コーラ・190万 回視聴
+
：
登録チャンネル
マイペ
''';

  print('\n${'='*50}');
  print('パーサーテスト実行');
  print('='*50);
  
  final parsedVideos = YouTubeOCRParserV2.parseOCRText(testData);
  
  print('\n${'='*50}');
  print('実際の解析結果:');
  print('='*50);
  
  for (int i = 0; i < parsedVideos.length; i++) {
    final video = parsedVideos[i];
    print('${i + 1}.');
    print('題名：${video.title}');
    print('投稿者：${video.channel}');
    if (video.viewCount != null) {
      print('視聴回数：${video.viewCount}');
    }
    print('');
  }
  
  print('Total extracted videos: ${parsedVideos.length}');
}
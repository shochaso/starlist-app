import 'lib/src/services/youtube_ocr_parser_improved.dart';

void main() {
  // テスト用のOCRデータ
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

  print('=== YouTube OCR Parser Test ===');
  print('Input data:');
  print(testData);
  print('\n${'='*50}\n');
  
  // パーサーを実行
  final videos = YouTubeOCRParserImproved.parseOCRText(testData);
  
  print('\n${'='*50}');
  print('FINAL RESULTS:');
  print('='*50);
  
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
  
  print('Total extracted videos: ${videos.length}');
}
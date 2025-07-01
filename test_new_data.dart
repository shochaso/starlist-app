import 'lib/src/services/youtube_ocr_parser_v2.dart';

void main() {
  // 第1データセット（問題のあるデータ）
  const testData1 = '''【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY
しても良いよね
1 ？
午前0時のプリンセス【ぜろぷり」
31万 回視聴
【爆食】食欲の秋に高カロリーコンビニスイーツ大食いして血糖
値爆上げさせたら
午前0時のプリンセス【ぜろぷり】
12万回視聴
加藤純一のマインクラフトダイジェスト 2025ハードコアソロ
(2025/05/20)
加藤純ーロードショー・37万 回視聴
加藤純一雑談ダイジェスト
[2025/03/30) 'ZATUDANNI
加藤純ーロードショー・21万回視聴
加藤純一雑談ダイジェスト
[2025/05/21] 'ohaj
加藤純ーロードショー・19万回視聴
：
自律神経を整える習慣
【528Hz+396Hz】心も体も楽になる
Relax TV・191万回視聴
【クラロワ】勝率100%で天界
に行ける新環境最強デッキ達を特別に教えます！
むぎ・4.7万回視聴
+
：
登録チャンネル
マイページ''';

  // 期待される結果
  final expectedVideos1 = [
    {'title': '【暴飲暴食】ダイエット終わったからさすがに爆食チート DAYしても良いよね', 'channel': '午前0時のプリンセス【ぜろぷり」', 'viewCount': '31万 回視聴'},
    {'title': '【爆食】食欲の秋に高カロリーコンビニスイーツ大食いして血糖値爆上げさせたら', 'channel': '午前0時のプリンセス【ぜろぷり】', 'viewCount': '12万回視聴'},
    {'title': '加藤純一のマインクラフトダイジェスト 2025ハードコアソロ(2025/05/20)', 'channel': '加藤純ーロードショー', 'viewCount': '37万 回視聴'},
    {'title': '加藤純一雑談ダイジェスト[2025/03/30)', 'channel': 'ZATUDANNI', 'viewCount': '21万回視聴'},
    {'title': '加藤純一雑談ダイジェスト[2025/05/21]', 'channel': '加藤純ーロードショー', 'viewCount': '19万回視聴'},
    {'title': '自律神経を整える習慣', 'channel': 'Relax TV', 'viewCount': '191万回視聴'},
    {'title': '【528Hz+396Hz】心も体も楽になる', 'channel': 'Relax TV', 'viewCount': '191万回視聴'},
    {'title': '【クラロワ】勝率100%で天界に行ける新環境最強デッキ達を特別に教えます！', 'channel': 'むぎ', 'viewCount': '4.7万回視聴'},
  ];

  print('=== 第1データセットのテスト ===');
  print('期待される動画数: ${expectedVideos1.length}');
  
  final parsedVideos1 = YouTubeOCRParserV2.parseOCRText(testData1);
  print('実際に抽出された動画数: ${parsedVideos1.length}');
  
  print('\n--- 期待される結果 ---');
  for (int i = 0; i < expectedVideos1.length; i++) {
    final video = expectedVideos1[i];
    print('${i + 1}. ${video['title']} | ${video['channel']} | ${video['viewCount']}');
  }
  
  print('\n--- 実際の抽出結果 ---');
  for (int i = 0; i < parsedVideos1.length; i++) {
    final video = parsedVideos1[i];
    print('${i + 1}. ${video.title} | ${video.channel} | ${video.viewCount}');
  }
  
  final accuracy1 = (parsedVideos1.length / expectedVideos1.length * 100).toStringAsFixed(1);
  print('\n精度: $accuracy1% (${parsedVideos1.length}/${expectedVideos1.length})');
}
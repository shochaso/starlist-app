import 'lib/src/services/youtube_ocr_parser_v3.dart';

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

  // 第2データセット（既に成功しているデータ）
  const testData2 = '''FF7 リバースの世界へ...（まってた）【FF7R-part1】
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
マイペ''';

  // 期待される結果
  const expectedCount1 = 8;
  const expectedCount2 = 7;

  print('=== 第1データセット（問題のあるデータ）のテスト ===');
  final parsedVideos1 = YouTubeOCRParserV3.parseOCRText(testData1);
  final accuracy1 = (parsedVideos1.length / expectedCount1 * 100).toStringAsFixed(1);
  print('抽出結果: ${parsedVideos1.length}/$expectedCount1 動画 (精度: $accuracy1%)');
  
  print('\n--- 抽出された動画 ---');
  for (int i = 0; i < parsedVideos1.length; i++) {
    final video = parsedVideos1[i];
    print('${i + 1}. ${video.title}');
    print('   投稿者: ${video.channel}');
    if (video.viewCount != null) print('   視聴回数: ${video.viewCount}');
    print('');
  }

  print('\n${'='*60}');
  print('=== 第2データセット（既存成功データ）のテスト ===');
  final parsedVideos2 = YouTubeOCRParserV3.parseOCRText(testData2);
  final accuracy2 = (parsedVideos2.length / expectedCount2 * 100).toStringAsFixed(1);
  print('抽出結果: ${parsedVideos2.length}/$expectedCount2 動画 (精度: $accuracy2%)');
  
  print('\n--- 抽出された動画 ---');
  for (int i = 0; i < parsedVideos2.length; i++) {
    final video = parsedVideos2[i];
    print('${i + 1}. ${video.title}');
    print('   投稿者: ${video.channel}');
    if (video.viewCount != null) print('   視聴回数: ${video.viewCount}');
    print('');
  }

  print('\n${'='*60}');
  print('=== 総合結果 ===');
  const totalExpected = expectedCount1 + expectedCount2;
  final totalExtracted = parsedVideos1.length + parsedVideos2.length;
  final overallAccuracy = (totalExtracted / totalExpected * 100).toStringAsFixed(1);
  
  print('データセット1: $accuracy1% (${parsedVideos1.length}/$expectedCount1)');
  print('データセット2: $accuracy2% (${parsedVideos2.length}/$expectedCount2)');
  print('総合精度: $overallAccuracy% ($totalExtracted/$totalExpected)');
  
  if (double.parse(accuracy1) >= 90 && double.parse(accuracy2) >= 90) {
    print('✅ 目標達成: 両方のデータセットで90%以上の精度を達成！');
  } else {
    print('❌ 目標未達成: 90%精度の達成が必要です');
  }
}
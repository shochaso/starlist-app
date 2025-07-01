import 'lib/src/services/youtube_ocr_parser_v5.dart';

void main() {
  // アプリ内で使用されているサンプルデータ
  const sampleOCRText = '''
①
題名：【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY しても良いよね
投稿者；午前0時のプリンセス【ぜろぷり】

②
題名【爆食】食欲の秋に高カロリーコンビニスイーツ大食いして血糖値爆上げさせたら
投稿者：午前0時のプリンセス【ぜろぷり】

③
題名：加藤純一のマインクラフトダイジェスト 2025ハードコアソロ(2025/05/20)
投稿者；加藤純ーロードショー

④
題名：加藤純一雑談ダイジェスト[2025/03/30) 
投稿者：ZATUDANNI

⑤
題名：加藤純ーロードショー
投稿者；加藤純一雑談ダイジェスト[2025/05/21]

⑥
題名：加藤純ーロードショー
投稿者；自律神経を整える習慣

⑦
題名：【528Hz+396Hz】心も体も楽になる
投稿者；Relax TV・191万回視聴

⑧
題名：【クラロワ】勝率100%で天界に行ける新環境最強デッキ達を特別に教えます！
投稿者；むぎ・4.7万回視聴
''';

  print('=== Testing App Sample Data with Parser V5 ===\n');
  
  final videos = YouTubeOCRParserV5.parseOCRText(sampleOCRText);
  
  print('\n=== Results ===');
  print('Total videos found: ${videos.length}');
  
  for (int i = 0; i < videos.length; i++) {
    final video = videos[i];
    print('Video ${i + 1}:');
    print('  Title: ${video.title}');
    print('  Channel: ${video.channel}');
    print('  Views: ${video.viewCount ?? "N/A"}');
    print('');
  }
}
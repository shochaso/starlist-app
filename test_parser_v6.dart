import 'lib/src/services/youtube_ocr_parser_v6.dart';

void main() {
  // アプリ内で使用されているサンプルデータ
  const appSampleData = '''
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

  // ユーザー提供データ
  const userSampleData = '''
すき家を超える！3種ならぬ
100種のチーズ牛丼作ってみたらとんでもない大きさになっ...
はじめしゃちょー（hajime）
19万 回視聴
生まれて初めての日本旅行で日本食の美味しさに出会ってしま
う
Momoka Japan・ 130万回視聴
：
日本食ってこんなに美味しかった！？観光客が驚き
Momoka Japan・ 258万回視聴
''';

  print('=== Testing Parser V6 with App Sample Data ===\n');
  final appVideos = YouTubeOCRParserV6.parseOCRText(appSampleData);
  
  print('\n=== App Sample Results ===');
  print('Total videos found: ${appVideos.length}');
  
  for (int i = 0; i < appVideos.length; i++) {
    final video = appVideos[i];
    print('Video ${i + 1}: ${video.title} | ${video.channel}');
  }
  
  print('\n=== Testing Parser V6 with User Sample Data ===\n');
  final userVideos = YouTubeOCRParserV6.parseOCRText(userSampleData);
  
  print('\n=== User Sample Results ===');
  print('Total videos found: ${userVideos.length}');
  
  for (int i = 0; i < userVideos.length; i++) {
    final video = userVideos[i];
    print('Video ${i + 1}: ${video.title} | ${video.channel}');
  }
  
  final totalAppSuccess = appVideos.length >= 5;
  final totalUserSuccess = userVideos.length >= 3;
  
  print('\n=== Summary ===');
  print('App Sample: ${appVideos.length} videos ${totalAppSuccess ? "✅" : "❌"}');
  print('User Sample: ${userVideos.length} videos ${totalUserSuccess ? "✅" : "❌"}');
}
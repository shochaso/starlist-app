import 'lib/src/services/youtube_ocr_parser_v5.dart';

void main() {
  // ユーザーが提供したサンプルデータ
  const testData = '''
すき家を超える！3種ならぬ
100種のチーズ牛丼作ってみたらとんでもない大きさになっ...
はじめしゃちょー（hajime）
19万 回視聴
生まれて初めての日本旅行で日本食の美味しさに出会ってしま
う
Momoka Japan・ 130万回視聴
：

ゆうちゃみさん、私服があまり

にも叡智すぎるに対する 2chの

反応まとめ【なんJ2chまと・
585 回視聴
エンタメキング 【大人向け芸能エンタメ】
：
日本食ってこんなに美味しかった！？観光客が驚き
Momoka Japan・ 258万回視聴
：
初めての日本で初めての日本食
デビュー【日本食すげえ】
Momoka Japan・93万 回視聴
【来日して初めての】憧れだった
日本食！
Momoka Japan・ 11万回視聴
【神回】歌い手グループの『食わず嫌い王選手権』したらまさかの結果にwww【Knight A-…
騎士X-Knight X -・30万 回視聴
''';

  print('=== Testing YouTube OCR Parser V5 with User Sample Data ===\n');
  
  final videos = YouTubeOCRParserV5.parseOCRText(testData);
  
  print('\n=== Parsing Results ===');
  print('Total videos found: ${videos.length}');
  print('Required minimum: 5 videos\n');
  
  for (int i = 0; i < videos.length; i++) {
    final video = videos[i];
    print('Video ${i + 1}:');
    print('  Title: ${video.title}');
    print('  Channel: ${video.channel}');
    print('  Views: ${video.viewCount ?? "N/A"}');
    print('  Confidence: ${video.confidence}');
    print('');
  }
  
  if (videos.length >= 5) {
    print('✅ Success: Found ${videos.length} videos (>= 5 required)');
  } else {
    print('❌ Failed: Found only ${videos.length} videos (< 5 required)');
  }
}
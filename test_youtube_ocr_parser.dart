import 'lib/src/services/youtube_ocr_parser.dart';

void main() {
  // Test case 1: Multi-line title with continuation
  print('=== Test Case 1: Multi-line title ===');
  const testCase1 = '''
【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY
しても良いよね
午前0時のプリンセス【ぜろぷり】
191万回視聴
''';
  
  final videos1 = YouTubeOCRParser.parseOCRText(testCase1);
  print('Expected: Title="【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY しても良いよね", Channel="午前0時のプリンセス【ぜろぷり】"');
  if (videos1.isNotEmpty) {
    print('Actual:   Title="${videos1[0].title}", Channel="${videos1[0].channel}"');
    print('Match: ${videos1[0].title.contains('【暴飲暴食】') && videos1[0].title.contains('しても良いよね') && videos1[0].channel == '午前0時のプリンセス【ぜろぷり】'}');
  }
  print('');
  
  // Test case 2: Channel with view count pattern
  print('=== Test Case 2: Channel・View count pattern ===');
  const testCase2 = '''
【528Hz+396Hz】心も体も楽になる
自律神経を整える習慣
Relax TV・191万回視聴
''';
  
  final videos2 = YouTubeOCRParser.parseOCRText(testCase2);
  print('Expected: Title="【528Hz+396Hz】心も体も楽になる", Channel="Relax TV"');
  if (videos2.isNotEmpty) {
    print('Actual:   Title="${videos2[0].title}", Channel="${videos2[0].channel}"');
    print('Match: ${videos2[0].title == '【528Hz+396Hz】心も体も楽になる' && videos2[0].channel == 'Relax TV'}');
  }
  print('');
  
  // Test case 3: Date pattern with channel
  print('=== Test Case 3: Date pattern ===');
  const testCase3 = '''
加藤純一雑談ダイジェスト[2025/03/30]
ZATUDANNI
21万回視聴
''';
  
  final videos3 = YouTubeOCRParser.parseOCRText(testCase3);
  print('Expected: Title="加藤純一雑談ダイジェスト[2025/03/30]", Channel="ZATUDANNI"');
  if (videos3.isNotEmpty) {
    print('Actual:   Title="${videos3[0].title}", Channel="${videos3[0].channel}"');
    print('Match: ${videos3[0].title == '加藤純一雑談ダイジェスト[2025/03/30]' && videos3[0].channel == 'ZATUDANNI'}');
  }
  print('');
  
  // Test case 4: Simple title-channel-viewcount
  print('=== Test Case 4: Simple pattern ===');
  const testCase4 = '''
加藤純一のマインクラフトダイジェスト 2025ハードコアソロ
加藤純一ロードショー
37万回視聴
''';
  
  final videos4 = YouTubeOCRParser.parseOCRText(testCase4);
  print('Expected: Title="加藤純一のマインクラフトダイジェスト 2025ハードコアソロ", Channel="加藤純一ロードショー"');
  if (videos4.isNotEmpty) {
    print('Actual:   Title="${videos4[0].title}", Channel="${videos4[0].channel}"');
    print('Match: ${videos4[0].title == '加藤純一のマインクラフトダイジェスト 2025ハードコアソロ' && videos4[0].channel == '加藤純一ロードショー'}');
  }
  print('');
  
  // Full test with all cases
  print('=== Full Test ===');
  const fullTest = '''
【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY
しても良いよね
午前0時のプリンセス【ぜろぷり】
191万回視聴

【爆食】食欲の秋に高カロリーコンビニスイーツ大食いして血糖
値爆上げさせたら
午前0時のプリンセス【ぜろぷり】
4.7万回視聴

加藤純一のマインクラフトダイジェスト 2025ハードコアソロ
加藤純一ロードショー
37万回視聴

加藤純一雑談ダイジェスト[2025/03/30]
ZATUDANNI
21万回視聴

【528Hz+396Hz】心も体も楽になる
自律神経を整える習慣
Relax TV・191万回視聴

【クラロワ】勝率100%で天界に行ける新環境最強デッキ
むぎ・4.7万回視聴
''';
  
  final allVideos = YouTubeOCRParser.parseOCRText(fullTest);
  print('Found ${allVideos.length} videos total');
  
  for (var i = 0; i < allVideos.length; i++) {
    print('Video ${i + 1}: "${allVideos[i].title}" → "${allVideos[i].channel}"');
  }
}
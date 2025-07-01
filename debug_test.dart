import 'lib/src/services/youtube_ocr_parser_clean.dart';

void main() {
  print('=== Debug Test Case 1 ===');
  const testCase1 = '''
【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY
しても良いよね
午前0時のプリンセス【ぜろぷり】
191万回視聴
''';
  
  // Split into lines to debug
  final lines = testCase1.split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  
  print('Lines: $lines');
  
  // Check channel detection for each line
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    print('Line $i: "$line"');
    print('  Is channel: ${YouTubeOCRParser.isChannelName(line)}');
    print('  Is view count: ${YouTubeOCRParser.isViewCount(line)}');
  }
  
  // Test the block splitting
  final blocks = YouTubeOCRParser.splitIntoVideoBlocks(lines);
  print('\nBlocks: $blocks');
  
  // Test the full parser
  final videos = YouTubeOCRParser.parseOCRText(testCase1);
  print('\nParsed videos:');
  for (var video in videos) {
    print('  Title: "${video.title}"');
    print('  Channel: "${video.channel}"');
    print('  Confidence: ${video.confidence}');
  }
}
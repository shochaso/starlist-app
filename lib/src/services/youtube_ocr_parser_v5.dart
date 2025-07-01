class VideoData {
  final String title;
  final String channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;

  VideoData({
    required this.title,
    required this.channel,
    this.duration,
    this.viewedAt,
    this.viewCount,
    this.confidence = 1.0,
  });

  @override
  String toString() {
    return 'VideoData(title: $title, channel: $channel, viewCount: $viewCount, confidence: $confidence)';
  }
}

class YouTubeOCRParserV5 {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser V5 ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    final List<bool> processedLines = List.filled(lines.length, false);
    
    // ステップ1: チャンネル名と視聴回数のペアを先に検出
    final channelViewPairs = <int, Map<String, String>>{};
    
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      print('Analyzing line $i: "$line"');
      
      // パターン1: "チャンネル名・視聴回数" (・でつながっている)
      final pattern1 = RegExp(r'^(.+?)・\s*([\d\.]+万?\s*回視聴)$');
      final match1 = pattern1.firstMatch(line);
      if (match1 != null) {
        channelViewPairs[i] = {
          'channel': match1.group(1)!.trim(),
          'viewCount': match1.group(2)!.trim(),
        };
        print('  -> Found channel-view pair: ${channelViewPairs[i]}');
        continue;
      }
      
      // パターン2: "チャンネル名・" のみ (次の行に視聴回数がある可能性)
      if (line.endsWith('・') && i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        if (_isViewCountOnly(nextLine)) {
          channelViewPairs[i] = {
            'channel': line.substring(0, line.length - 1).trim(),
            'viewCount': nextLine.trim(),
          };
          processedLines[i + 1] = true;
          print('  -> Found split channel-view: ${channelViewPairs[i]}');
          continue;
        }
      }
      
      // パターン3: 視聴回数のみの行 (前の行がチャンネル名の可能性)
      if (_isViewCountOnly(line) && i > 0) {
        final prevLine = lines[i - 1];
        if (!processedLines[i - 1] && _isPossibleChannelName(prevLine)) {
          channelViewPairs[i - 1] = {
            'channel': prevLine.trim(),
            'viewCount': line.trim(),
          };
          processedLines[i] = true;
          print('  -> Found separate channel-view: ${channelViewPairs[i - 1]}');
        }
      }
    }
    
    // ステップ2: 各チャンネル・視聴回数ペアに対してタイトルを探す
    for (final entry in channelViewPairs.entries) {
      final lineIndex = entry.key;
      final channelView = entry.value;
      
      print('\nSearching title for channel "${channelView['channel']}" at line $lineIndex');
      
      // タイトルを前方から探す（複数行対応）
      String title = '';
      final List<int> titleLines = [];
      
      // 最大10行前まで探索
      for (int i = lineIndex - 1; i >= 0 && i >= lineIndex - 10; i--) {
        if (processedLines[i]) continue;
        
        final line = lines[i];
        
        // スキップすべき行
        if (_shouldSkipLine(line)) continue;
        
        // タイトルの可能性がある行
        if (_isPossibleTitle(line)) {
          // 連続したタイトル行を結合
          if (titleLines.isEmpty || titleLines.first == i + 1) {
            title = line + (title.isEmpty ? '' : title);
            titleLines.insert(0, i);
            print('  -> Adding title line $i: "$line"');
          } else {
            // 連続していない場合は最後のタイトルとして確定
            if (title.isNotEmpty) break;
          }
        }
      }
      
      // タイトルが見つかった場合、動画データを作成
      if (title.isNotEmpty) {
        final video = VideoData(
          title: title,
          channel: channelView['channel']!,
          viewCount: channelView['viewCount'],
          confidence: 0.9,
        );
        videos.add(video);
        print('  -> Created video: $video');
        
        // 処理済みとしてマーク
        processedLines[lineIndex] = true;
        for (final idx in titleLines) {
          processedLines[idx] = true;
        }
      }
    }
    
    // ステップ3: 特殊パターンの処理 (Knight A-騎士A-など)
    for (int i = 0; i < lines.length - 1; i++) {
      if (processedLines[i] || processedLines[i + 1]) continue;
      
      final line1 = lines[i];
      final line2 = lines[i + 1];
      
      // "Knight A-騎士A-" のようなパターン
      if (_isSpecialChannelPattern(line1, line2)) {
        // タイトルを前方から探す
        String title = '';
        for (int j = i - 1; j >= 0 && j >= i - 5; j--) {
          if (processedLines[j] || _shouldSkipLine(lines[j])) continue;
          if (_isPossibleTitle(lines[j])) {
            title = lines[j] + title;
            processedLines[j] = true;
          }
        }
        
        if (title.isNotEmpty) {
          final video = VideoData(
            title: title,
            channel: line1 + line2,
            viewCount: '不明',
            confidence: 0.8,
          );
          videos.add(video);
          print('  -> Created special pattern video: $video');
          processedLines[i] = true;
          processedLines[i + 1] = true;
        }
      }
    }
    
    print('\nTotal videos parsed: ${videos.length}');
    return videos;
  }
  
  static bool _isViewCountOnly(String line) {
    // 視聴回数のパターン
    return RegExp(r'^\d+[\d\.,]*\s*万?\s*回視聴$').hasMatch(line) ||
           RegExp(r'^\d+\s*回視聴$').hasMatch(line);
  }
  
  static bool _isPossibleChannelName(String line) {
    // チャンネル名の可能性がある行
    // 記号のみ、短すぎる、視聴回数を含むものは除外
    if (line.length < 2) return false;
    if (line == '：' || line == '・') return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false; // 時間表記
    
    // 日本語、英語、記号を含む可能性
    return true;
  }
  
  static bool _isPossibleTitle(String line) {
    // タイトルの可能性がある行
    if (line.length < 2) return false;
    if (line == '：' || line == '・') return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false; // 時間表記
    
    // タイトルらしいパターン
    // 【】を含む、疑問符で終わる、長めの文字列など
    if (line.contains('【') || line.contains('】')) return true;
    if (line.endsWith('？') || line.endsWith('?')) return true;
    if (line.endsWith('！') || line.endsWith('!')) return true;
    if (line.length > 10) return true;
    
    return true;
  }
  
  static bool _shouldSkipLine(String line) {
    // スキップすべき行
    return line == '：' || 
           line == '・' || 
           line.isEmpty ||
           RegExp(r'^\d+:\d+$').hasMatch(line); // 時間表記のみ
  }
  
  static bool _isSpecialChannelPattern(String line1, String line2) {
    // "Knight A-騎士A-" のような特殊パターン
    return (line1.contains('Knight') && line2.contains('騎士')) ||
           (line1.endsWith('-') && line2.endsWith('-'));
  }
}
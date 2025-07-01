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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'channel': channel,
      'duration': duration ?? '',
      'viewedAt': viewedAt ?? '',
      'viewCount': viewCount ?? '',
      'confidence': confidence,
    };
  }

  @override
  String toString() {
    return 'VideoData(title: $title, channel: $channel, viewCount: $viewCount, confidence: $confidence)';
  }
}

class YouTubeOCRParserV6 {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser V6 ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    
    // パターン1: 構造化データの処理（アプリ内サンプル）
    final structuredVideos = _parseStructuredFormat(lines);
    videos.addAll(structuredVideos);
    
    // パターン2: 自然なOCRデータの処理（ユーザー提供データ）
    if (videos.isEmpty) {
      final naturalVideos = _parseNaturalFormat(lines);
      videos.addAll(naturalVideos);
    }
    
    print('Total videos parsed: ${videos.length}');
    return videos;
  }
  
  // 構造化フォーマットの処理（アプリ内サンプル用）
  static List<VideoData> _parseStructuredFormat(List<String> lines) {
    final videos = <VideoData>[];
    print('Trying structured format parsing...');
    
    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i];
      
      // 題名を探す
      if (line.startsWith('題名：') || line.startsWith('題名【')) {
        String title = line;
        if (title.startsWith('題名：')) {
          title = title.substring(3); // "題名："を除去
        } else if (title.startsWith('題名【')) {
          title = title.substring(2); // "題名"を除去
        }
        
        // 次の行で投稿者を探す
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (nextLine.startsWith('投稿者：') || nextLine.startsWith('投稿者；')) {
            String channelInfo = nextLine.substring(3); // "投稿者："または"投稿者；"を除去
            
            String channel;
            String? viewCount;
            
            // 視聴回数が含まれているかチェック
            final viewPattern = RegExp(r'(.+?)・([\d\.]+万?\s*回視聴)$');
            final viewMatch = viewPattern.firstMatch(channelInfo);
            if (viewMatch != null) {
              channel = viewMatch.group(1)!.trim();
              viewCount = viewMatch.group(2)!.trim();
            } else {
              channel = channelInfo.trim();
            }
            
            final video = VideoData(
              title: title,
              channel: channel,
              viewCount: viewCount,
              confidence: 0.95,
            );
            videos.add(video);
            print('  -> Structured video: $video');
          }
        }
      }
    }
    
    return videos;
  }
  
  // 自然なOCRフォーマットの処理（ユーザー提供データ用）
  static List<VideoData> _parseNaturalFormat(List<String> lines) {
    final videos = <VideoData>[];
    final processedLines = List.filled(lines.length, false);
    
    print('Trying natural format parsing...');
    
    // ステップ1: チャンネル名と視聴回数のペアを先に検出
    final channelViewPairs = <int, Map<String, String>>{};
    
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      
      // パターン1: "チャンネル名・視聴回数" (・でつながっている)
      final pattern1 = RegExp(r'^(.+?)・\s*([\d\.]+万?\s*回視聴)$');
      final match1 = pattern1.firstMatch(line);
      if (match1 != null) {
        channelViewPairs[i] = {
          'channel': match1.group(1)!.trim(),
          'viewCount': match1.group(2)!.trim(),
        };
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
        }
      }
    }
    
    // ステップ2: 各チャンネル・視聴回数ペアに対してタイトルを探す
    for (final entry in channelViewPairs.entries) {
      final lineIndex = entry.key;
      final channelView = entry.value;
      
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
        
        // 処理済みとしてマーク
        processedLines[lineIndex] = true;
        for (final idx in titleLines) {
          processedLines[idx] = true;
        }
      }
    }
    
    return videos;
  }
  
  static bool _isViewCountOnly(String line) {
    // 視聴回数のパターン
    return RegExp(r'^\d+[\d\.,]*\s*万?\s*回視聴$').hasMatch(line) ||
           RegExp(r'^\d+\s*回視聴$').hasMatch(line);
  }
  
  static bool _isPossibleChannelName(String line) {
    // チャンネル名の可能性がある行
    if (line.length < 2) return false;
    if (line == '：' || line == '・') return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false; // 時間表記
    
    return true;
  }
  
  static bool _isPossibleTitle(String line) {
    // タイトルの可能性がある行
    if (line.length < 2) return false;
    if (line == '：' || line == '・') return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false; // 時間表記
    
    // タイトルらしいパターン
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
           RegExp(r'^\d+:\d+$').hasMatch(line) || // 時間表記のみ
           RegExp(r'^[①②③④⑤⑥⑦⑧⑨⑩]$').hasMatch(line); // 番号のみ
  }
}
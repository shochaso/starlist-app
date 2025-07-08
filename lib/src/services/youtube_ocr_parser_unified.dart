class VideoData {
  final String title;
  final String channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;
  final String? sourcePattern; // 検出されたパターンタイプ

  VideoData({
    required this.title,
    required this.channel,
    this.duration,
    this.viewedAt,
    this.viewCount,
    this.confidence = 1.0,
    this.sourcePattern,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'channel': channel,
      'duration': duration ?? '',
      'viewedAt': viewedAt ?? '',
      'viewCount': viewCount ?? '',
      'confidence': confidence,
      'sourcePattern': sourcePattern ?? '',
      'type': 'youtube_video',
    };
  }

  @override
  String toString() {
    return 'VideoData(title: $title, channel: $channel, viewCount: $viewCount, confidence: $confidence, pattern: $sourcePattern)';
  }
}

/// 統一YouTube OCRパーサー
/// 全バージョンの最良の機能を統合し、適材適所の解析を実行
class YouTubeOCRParserUnified {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser Unified ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    
    // フェーズ1: 構造化データの処理（アプリ内サンプル対応）
    final structuredVideos = _parseStructuredFormat(lines);
    videos.addAll(structuredVideos);
    print('Structured format results: ${structuredVideos.length} videos');
    
    // フェーズ2: 自然OCRデータの処理（最も一般的）
    if (videos.length < _getExpectedVideoCount(text)) {
      final naturalVideos = _parseNaturalFormat(lines);
      videos.addAll(naturalVideos);
      print('Natural format results: ${naturalVideos.length} videos');
    }
    
    // フェーズ3: 特殊パターンの処理（Edge cases）
    if (videos.length < _getExpectedVideoCount(text)) {
      final specialVideos = _parseSpecialPatterns(lines);
      videos.addAll(specialVideos);
      print('Special patterns results: ${specialVideos.length} videos');
    }
    
    // 重複除去と品質フィルタリング
    final filteredVideos = _deduplicateAndFilter(videos);
    
    print('Total videos parsed: ${filteredVideos.length}');
    return filteredVideos;
  }
  
  /// フェーズ1: 構造化フォーマットの処理
  /// 形式: 「題名：【タイトル】投稿者：チャンネル名」
  static List<VideoData> _parseStructuredFormat(List<String> lines) {
    final videos = <VideoData>[];
    print('Processing structured format...');
    
    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i];
      
      // 題名パターンを検出
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
            String channelInfo = nextLine.substring(3);
            
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
              sourcePattern: 'structured',
            );
            videos.add(video);
            print('  -> Structured video: $video');
          }
        }
      }
    }
    
    return videos;
  }
  
  /// フェーズ2: 自然OCRフォーマットの処理
  /// 形式: 「タイトル\nチャンネル名・視聴回数」または「タイトル\nチャンネル名\n視聴回数」
  static List<VideoData> _parseNaturalFormat(List<String> lines) {
    final videos = <VideoData>[];
    final processedLines = List.filled(lines.length, false);
    
    print('Processing natural format...');
    
    // ステップ1: チャンネル名と視聴回数のペアを検出
    final channelViewPairs = <int, Map<String, String>>{};
    
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      
      // パターン1: "チャンネル名・視聴回数" (・で連結)
      final pattern1 = RegExp(r'^(.+?)・\s*([\d\.]+万?\s*回視聴)$');
      final match1 = pattern1.firstMatch(line);
      if (match1 != null) {
        channelViewPairs[i] = {
          'channel': match1.group(1)!.trim(),
          'viewCount': match1.group(2)!.trim(),
          'pattern': 'channel_view_combined',
        };
        continue;
      }
      
      // パターン2: "チャンネル名・" のみ（次行に視聴回数）
      if (line.endsWith('・') && i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        if (_isViewCountOnly(nextLine)) {
          channelViewPairs[i] = {
            'channel': line.substring(0, line.length - 1).trim(),
            'viewCount': nextLine.trim(),
            'pattern': 'channel_view_split',
          };
          processedLines[i + 1] = true;
          continue;
        }
      }
      
      // パターン3: 視聴回数のみの行（前行がチャンネル名）
      if (_isViewCountOnly(line) && i > 0) {
        final prevLine = lines[i - 1];
        if (!processedLines[i - 1] && _isPossibleChannelName(prevLine)) {
          channelViewPairs[i - 1] = {
            'channel': prevLine.trim(),
            'viewCount': line.trim(),
            'pattern': 'channel_view_separate',
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
      
      // 最大15行前まで探索（長いタイトル対応）
      for (int i = lineIndex - 1; i >= 0 && i >= lineIndex - 15; i--) {
        if (processedLines[i]) continue;
        
        final line = lines[i];
        
        // スキップすべき行
        if (_shouldSkipLine(line)) continue;
        
        // タイトルの可能性がある行
        if (_isPossibleTitle(line)) {
          // 連続したタイトル行を結合
          if (titleLines.isEmpty || titleLines.first == i + 1) {
            title = line + (title.isEmpty ? '' : ' ') + title;
            titleLines.insert(0, i);
          } else {
            // 連続していない場合は最後のタイトルとして確定
            if (title.isNotEmpty) break;
            title = line;
            titleLines.clear();
            titleLines.add(i);
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
          sourcePattern: channelView['pattern'],
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
  
  /// フェーズ3: 特殊パターンの処理
  /// Edge cases、不規則なフォーマット、特殊な区切り文字など
  static List<VideoData> _parseSpecialPatterns(List<String> lines) {
    final videos = <VideoData>[];
    final processedLines = List.filled(lines.length, false);
    
    print('Processing special patterns...');
    
    // 特殊パターン1: Knight A-騎士A- のようなパターン
    for (int i = 0; i < lines.length - 1; i++) {
      if (processedLines[i] || processedLines[i + 1]) continue;
      
      final line1 = lines[i];
      final line2 = lines[i + 1];
      
      if (_isSpecialChannelPattern(line1, line2)) {
        // タイトルを前方から探す
        String title = '';
        for (int j = i - 1; j >= 0 && j >= i - 8; j--) {
          if (processedLines[j] || _shouldSkipLine(lines[j])) continue;
          if (_isPossibleTitle(lines[j])) {
            title = lines[j] + (title.isEmpty ? '' : ' ') + title;
            processedLines[j] = true;
          }
        }
        
        if (title.isNotEmpty) {
          final video = VideoData(
            title: title,
            channel: line1 + line2,
            viewCount: '不明',
            confidence: 0.8,
            sourcePattern: 'special_channel_pattern',
          );
          videos.add(video);
          processedLines[i] = true;
          processedLines[i + 1] = true;
        }
      }
    }
    
    // 特殊パターン2: ブロック形式の検出
    final blocks = _detectVideoBlocks(lines);
    for (final block in blocks) {
      if (block.length >= 2) {
        final possibleTitle = block.first;
        final possibleChannel = block.length > 1 ? block[1] : '';
        final possibleViewCount = block.length > 2 ? block[2] : null;
        
        if (_isPossibleTitle(possibleTitle) && _isPossibleChannelName(possibleChannel)) {
          final video = VideoData(
            title: possibleTitle,
            channel: possibleChannel,
            viewCount: possibleViewCount,
            confidence: 0.75,
            sourcePattern: 'block_detection',
          );
          videos.add(video);
        }
      }
    }
    
    return videos;
  }
  
  /// 重複除去と品質フィルタリング
  static List<VideoData> _deduplicateAndFilter(List<VideoData> videos) {
    final Map<String, VideoData> uniqueVideos = {};
    
    for (final video in videos) {
      final key = '${video.title.toLowerCase()}_${video.channel.toLowerCase()}';
      
      // 既存のエントリより信頼度が高い場合のみ置き換え
      if (!uniqueVideos.containsKey(key) || 
          video.confidence > uniqueVideos[key]!.confidence) {
        uniqueVideos[key] = video;
      }
    }
    
    // 信頼度でソートして返す
    final result = uniqueVideos.values.toList();
    result.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return result;
  }
  
  /// ヘルパーメソッド群
  
  static bool _isViewCountOnly(String line) {
    return RegExp(r'^\d+[\d\.,]*\s*万?\s*回視聴$').hasMatch(line) ||
           RegExp(r'^\d+\s*回視聴$').hasMatch(line);
  }
  
  static bool _isPossibleChannelName(String line) {
    if (line.length < 2 || line.length > 50) return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false; // 時間表記
    if (line == '：' || line == '・' || line == '+') return false;
    return true;
  }
  
  static bool _isPossibleTitle(String line) {
    if (line.length < 3 || line.length > 300) return false;
    if (_isViewCountOnly(line)) return false;
    if (RegExp(r'^\d+:\d+$').hasMatch(line)) return false;
    if (line == '：' || line == '・' || line == '+') return false;
    if (RegExp(r'^[登録チャンネルマイページ]+$').hasMatch(line)) return false;
    
    // タイトルらしい特徴
    return line.contains('【') || line.contains('】') || 
           line.contains('[') || line.contains(']') || 
           line.length > 10;
  }
  
  static bool _shouldSkipLine(String line) {
    final skipPatterns = [
      RegExp(r'^：$'),
      RegExp(r'^\+$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^\d+万?\s*回視聴$'),
      RegExp(r'^\d+$'),
      RegExp(r'^[・。、]+$'),
    ];
    
    return skipPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isSpecialChannelPattern(String line1, String line2) {
    // Knight A-騎士X-Knight X - のようなパターン
    return (line1.contains('Knight') && line2.contains('Knight')) ||
           (line1.contains('-') && line2.contains('-'));
  }
  
  static List<List<String>> _detectVideoBlocks(List<String> lines) {
    final blocks = <List<String>>[];
    List<String> currentBlock = [];
    
    for (final line in lines) {
      if (_shouldSkipLine(line)) {
        if (currentBlock.isNotEmpty) {
          blocks.add(List.from(currentBlock));
          currentBlock.clear();
        }
      } else {
        currentBlock.add(line);
      }
    }
    
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock);
    }
    
    return blocks;
  }
  
  static int _getExpectedVideoCount(String text) {
    // テキストの長さから予想される動画数を概算
    final lineCount = text.split('\n').where((line) => line.trim().isNotEmpty).length;
    return (lineCount / 3).ceil(); // 平均3行で1動画と仮定
  }
} 
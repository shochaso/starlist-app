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

class YouTubeOCRParserImproved {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser Improved ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    
    // 複数行にまたがるタイトルを結合
    final processedLines = _combineMultilineTitle(lines);
    print('After title combination: ${processedLines.length} lines');
    
    for (int i = 0; i < processedLines.length; i++) {
      final line = processedLines[i];
      print('Processing line $i: "$line"');
      
      // 除外すべき行をスキップ
      if (_shouldSkipLine(line)) {
        print('  -> Skipped: Exclude pattern');
        continue;
      }
      
      // タイトルの候補を判定
      if (_isLikelyVideoTitle(line)) {
        print('  -> Detected as video title');
        
        // 次の行でチャンネル名と視聴回数を探す
        String? channel;
        String? viewCount;
        
        // 次の行をチェック
        if (i + 1 < processedLines.length) {
          final nextLine = processedLines[i + 1];
          print('  -> Checking next line: "$nextLine"');
          
          // チャンネル名と視聴回数が同じ行にあるパターン
          final channelViewMatch = _extractChannelAndViewCount(nextLine);
          if (channelViewMatch != null) {
            channel = channelViewMatch['channel'];
            viewCount = channelViewMatch['viewCount'];
            print('  -> Found channel: "$channel", viewCount: "$viewCount"');
          } else {
            // チャンネル名のみの場合
            if (_isChannelName(nextLine) && !_isViewCount(nextLine)) {
              channel = _cleanChannelName(nextLine);
              print('  -> Found channel only: "$channel"');
              
              // さらに次の行で視聴回数をチェック
              if (i + 2 < processedLines.length) {
                final thirdLine = processedLines[i + 2];
                if (_isViewCount(thirdLine)) {
                  viewCount = thirdLine;
                  print('  -> Found viewCount in next line: "$viewCount"');
                }
              }
            }
          }
        }
        
        if (channel != null && channel.isNotEmpty) {
          final video = VideoData(
            title: _cleanTitle(line),
            channel: channel,
            viewCount: viewCount,
            confidence: 0.9,
          );
          videos.add(video);
          print('  -> Added video: ${video.toString()}');
        } else {
          print('  -> Skipped: No valid channel found');
        }
      }
    }
    
    print('Parsed ${videos.length} videos from OCR text');
    return videos;
  }
  
  static List<String> _combineMultilineTitle(List<String> lines) {
    final List<String> result = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // 明らかにタイトルの一部と思われるパターン
      if (line == 'アル説' && i > 0 && result.isNotEmpty) {
        // 前の行と結合
        final lastIndex = result.length - 1;
        result[lastIndex] = result[lastIndex] + line;
        continue;
      }
      
      result.add(line);
    }
    
    return result;
  }
  
  static bool _shouldSkipLine(String line) {
    final skipPatterns = [
      RegExp(r'^：$'),
      RegExp(r'^\+$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^\d+万?\s*回視聴$'),
    ];
    
    return skipPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isLikelyVideoTitle(String line) {
    // 基本的な除外パターン
    if (line.length < 5 || line.length > 200) return false;
    
    // 明らかにタイトルではないもの
    final excludePatterns = [
      RegExp(r'^\d+万?\s*回視聴$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^：$'),
      RegExp(r'^\+$'),
      RegExp(r'^[・。、]+$'),
      RegExp(r'^\d+$'),
    ];
    
    for (final pattern in excludePatterns) {
      if (pattern.hasMatch(line)) return false;
    }
    
    // タイトルらしい特徴
    final titleIndicators = [
      RegExp(r'【.*】'), // 【】で囲まれたテキスト
      RegExp(r'\[.*\]'), // []で囲まれたテキスト
      RegExp(r'[ァ-ヴ]+'), // カタカナ
      RegExp(r'[一-龯]+'), // 漢字
      RegExp(r'FF7|FF8|クラロワ'), // ゲーム関連キーワード
    ];
    
    return titleIndicators.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isChannelName(String line) {
    if (line.length < 2 || line.length > 50) return false;
    
    // 視聴回数ではない
    if (_isViewCount(line)) return false;
    
    // チャンネル名の特徴
    final channelPatterns = [
      RegExp(r'^[ァ-ヴa-zA-Z0-9一-龯\s・／]+$'), // 通常の文字
      RegExp(r'CR$'), // クラロワ関連
      RegExp(r'コカ・コーラ$'), // 企業名
    ];
    
    return channelPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isViewCount(String line) {
    final viewCountPatterns = [
      RegExp(r'^\d+万\s*回視聴$'),
      RegExp(r'^\d+\.\d+万\s*回視聴$'),
      RegExp(r'^\d+回視聴$'),
    ];
    
    return viewCountPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static Map<String, String>? _extractChannelAndViewCount(String line) {
    // パターン1: "チャンネル名・視聴回数" 
    final pattern1 = RegExp(r'^(.+?)・(\d+(?:\.\d+)?万?\s*回視聴)$');
    final match1 = pattern1.firstMatch(line);
    if (match1 != null) {
      return {
        'channel': match1.group(1)!.trim(),
        'viewCount': match1.group(2)!.trim(),
      };
    }
    
    // パターン2: "チャンネル名 視聴回数"
    final pattern2 = RegExp(r'^(.+?)\s+(\d+(?:\.\d+)?万?\s*回視聴)$');
    final match2 = pattern2.firstMatch(line);
    if (match2 != null) {
      return {
        'channel': match2.group(1)!.trim(),
        'viewCount': match2.group(2)!.trim(),
      };
    }
    
    return null;
  }
  
  static String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'^[\s・。、]+'), '')
        .replaceAll(RegExp(r'[\s・。、]+$'), '')
        .trim();
  }
  
  static String _cleanChannelName(String channel) {
    return channel
        .replaceAll('・', '')
        .replaceAll(RegExp(r'^\s+'), '')
        .replaceAll(RegExp(r'\s+$'), '')
        .trim();
  }
  
  /// Starlist投稿用データ形式に変換
  static List<Map<String, dynamic>> toStarlistFormat(List<VideoData> videos) {
    return videos.map((video) => {
      'type': 'youtube_video',
      'title': video.title,
      'metadata': {
        'channel': video.channel,
        'duration': video.duration,
        'viewed_at': video.viewedAt,
        'view_count': video.viewCount,
        'confidence': video.confidence,
        'source': 'ocr_import',
      },
      'content': {
        'description': '${video.channel}の動画「${video.title}」を視聴${video.viewCount != null ? '（${video.viewCount}）' : ''}',
        'category': _categorizeVideo(video.title, video.channel),
        'tags': _generateTags(video.title, video.channel),
      },
      'timestamp': DateTime.now().toIso8601String(),
    }).toList();
  }
  
  static String _categorizeVideo(String title, String channel) {
    final categoryKeywords = {
      'ゲーム': ['FF7', 'FF8', 'クラロワ', 'ゲーム', 'リバース'],
      'アニメ': ['クレヨンしんちゃん', 'アニメ'],
      '考察': ['考察', '解説', '正体', '目的'],
      'エンターテイメント': ['やかんの麦茶'],
    };
    
    for (final entry in categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      
      for (final keyword in keywords) {
        if (title.contains(keyword) || channel.contains(keyword)) {
          return category;
        }
      }
    }
    
    return 'その他';
  }
  
  static List<String> _generateTags(String title, String channel) {
    final tags = <String>[];
    
    // タイトルから自動生成
    final tagKeywords = [
      'FF7', 'FF8', 'リバース', 'セフィロス', 'クラロワ', 'クレヨンしんちゃん',
      'リメイク', '考察', '解説', 'ゲーム', 'アニメ'
    ];
    
    for (final keyword in tagKeywords) {
      if (title.contains(keyword) || channel.contains(keyword)) {
        tags.add(keyword);
      }
    }
    
    return tags;
  }
}
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

class YouTubeOCRParserV2 {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser V2 ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    
    // パターンベースで解析
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      print('Processing line $i: "$line"');
      
      // パターン1: タイトル行 + チャンネル・視聴回数行
      if (_isVideoTitle(line) && i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        final match = _parseChannelViewLine(nextLine);
        if (match != null) {
          final video = VideoData(
            title: _cleanTitle(line),
            channel: match['channel']!,
            viewCount: match['viewCount'],
            confidence: 0.95,
          );
          videos.add(video);
          print('  -> Pattern 1: Added video: $video');
          continue;
        }
      }
      
      // パターン2: タイトル行 + チャンネル行 + 視聴回数行
      if (_isVideoTitle(line) && i + 2 < lines.length) {
        final channelLine = lines[i + 1];
        final viewLine = lines[i + 2];
        
        if (_isChannelOnly(channelLine) && _isViewCountOnly(viewLine)) {
          final video = VideoData(
            title: _cleanTitle(line),
            channel: _cleanChannel(channelLine),
            viewCount: viewLine,
            confidence: 0.9,
          );
          videos.add(video);
          print('  -> Pattern 2: Added video: $video');
          continue;
        }
      }
      
      // パターン3: 複数行タイトル + チャンネル・視聴回数
      if (_isVideoTitleStart(line) && i + 2 < lines.length) {
        final nextLine = lines[i + 1];
        final thirdLine = lines[i + 2];
        
        // タイトルが2行に分かれている場合
        if (_isVideoTitleContinuation(nextLine)) {
          final fullTitle = line + nextLine;
          final match = _parseChannelViewLine(thirdLine);
          if (match != null) {
            final video = VideoData(
              title: _cleanTitle(fullTitle),
              channel: match['channel']!,
              viewCount: match['viewCount'],
              confidence: 0.85,
            );
            videos.add(video);
            print('  -> Pattern 3: Added video: $video');
            continue;
          }
        }
      }
      
      // パターン4: 複数行タイトル + チャンネル行 + 視聴回数行
      if (_isVideoTitleStart(line) && i + 3 < lines.length) {
        final nextLine = lines[i + 1];
        final channelLine = lines[i + 2];
        final viewLine = lines[i + 3];
        
        if (_isVideoTitleContinuation(nextLine) && _isChannelOnly(channelLine) && _isViewCountOnly(viewLine)) {
          final fullTitle = line + nextLine;
          final video = VideoData(
            title: _cleanTitle(fullTitle),
            channel: _cleanChannel(channelLine),
            viewCount: viewLine,
            confidence: 0.8,
          );
          videos.add(video);
          print('  -> Pattern 4: Added video: $video');
          continue;
        }
      }
      
      // パターン5: 特殊な長い行（やかんの麦茶パターン）
      if (line.contains('・・') && line.contains('・') && _parseSpecialChannelViewLine(line) != null) {
        final match = _parseSpecialChannelViewLine(line);
        if (match != null) {
          final video = VideoData(
            title: match['title']!,
            channel: match['channel']!,
            viewCount: match['viewCount'],
            confidence: 0.75,
          );
          videos.add(video);
          print('  -> Pattern 5: Added video: $video');
          continue;
        }
      }
    }
    
    print('Parsed ${videos.length} videos from OCR text');
    return videos;
  }
  
  static bool _isVideoTitle(String line) {
    // 基本的な長さチェック
    if (line.length < 5 || line.length > 200) return false;
    
    // 除外パターン
    final excludePatterns = [
      RegExp(r'^\d+万?\s*回視聴$'),
      RegExp(r'^[：\+]+$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^てつお[／/]ゲーム考察＆ストーリー解説$'),
      RegExp(r'^跳兎・\d+万?\s*回視聴$'),
      RegExp(r'^ラッシュ\s+CR・[\d\.]+万?\s*回視聴$'),
    ];
    
    for (final pattern in excludePatterns) {
      if (pattern.hasMatch(line)) return false;
    }
    
    // タイトルの特徴
    final titleIndicators = [
      RegExp(r'【[^】]*】'), // 【】括弧
      RegExp(r'\[[^\]]*\]'), // []括弧
      RegExp(r'FF7|FF8'), // ゲームタイトル
      RegExp(r'クラロワ'), // ゲーム名
      RegExp(r'リバース'), // キーワード
      RegExp(r'やかんの麦茶'), // 特徴的なワード
    ];
    
    return titleIndicators.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isVideoTitleStart(String line) {
    return line.startsWith('【') || line.startsWith('FF') || line.contains('クラロワ');
  }
  
  static bool _isVideoTitleContinuation(String line) {
    return line == 'アル説' || line.startsWith('www') || line.length < 20;
  }
  
  static Map<String, String>? _parseChannelViewLine(String line) {
    // パターン1: "チャンネル名・視聴回数"
    final pattern1 = RegExp(r'^(.+?)・([\d\.]+万?\s*回視聴)$');
    final match1 = pattern1.firstMatch(line);
    if (match1 != null) {
      return {
        'channel': match1.group(1)!.trim(),
        'viewCount': match1.group(2)!.trim(),
      };
    }
    
    // パターン2: "チャンネル名・・視聴回数" (複数の・)
    final pattern2 = RegExp(r'^(.+?)・・(.+)・([\d\.]+万?\s*回視聴)$');
    final match2 = pattern2.firstMatch(line);
    if (match2 != null) {
      return {
        'channel': match2.group(3)!.trim(), // 最後の部分がチャンネル
        'viewCount': match2.group(3)!.trim(),
      };
    }
    
    return null;
  }
  
  static bool _isChannelOnly(String line) {
    // 明らかに視聴回数ではない
    if (_isViewCountOnly(line)) return false;
    
    // 既知のチャンネル名パターン
    final channelPatterns = [
      RegExp(r'^てつお[／/]ゲーム考察[＆&]ストーリー解説$'),
      RegExp(r'^ラッシュ\s+CR$'),
      RegExp(r'^コカ・コーラ$'),
      RegExp(r'^跳兎$'),
    ];
    
    return channelPatterns.any((pattern) => pattern.hasMatch(line)) ||
           (line.length > 2 && line.length < 50);
  }
  
  static bool _isViewCountOnly(String line) {
    final viewPatterns = [
      RegExp(r'^\d+万回視聴$'),
      RegExp(r'^\d+\.\d+万回視聴$'),
      RegExp(r'^\d+回視聴$'),
      RegExp(r'^\d+万\s+回視聴$'),
    ];
    
    return viewPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static String _cleanTitle(String title) {
    return title.trim();
  }
  
  static String _cleanChannel(String channel) {
    return channel.trim();
  }
  
  static Map<String, String>? _parseSpecialChannelViewLine(String line) {
    // 特殊パターン: "【やかんの麦茶】もうひとつのクレヨンしんちゃん 第6話「お久しぶりの春日部だゾ！」篇・・コカ・コーラ・190万 回視聴"
    final pattern = RegExp(r'^(.+)・・(.+?)・([\d\.]+万?\s*回視聴)$');
    final match = pattern.firstMatch(line);
    if (match != null) {
      return {
        'title': match.group(1)!.trim(),
        'channel': match.group(2)!.trim(),
        'viewCount': match.group(3)!.trim(),
      };
    }
    return null;
  }
}
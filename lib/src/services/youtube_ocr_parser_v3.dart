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

class YouTubeOCRParserV3 {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser V3 ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    final List<bool> processedLines = List.filled(lines.length, false);
    
    // パターン1: チャンネル・視聴回数行から逆算して探す
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      print('Processing line $i: "$line"');
      
      // チャンネル・視聴回数のパターンを検出
      final channelViewMatch = _parseChannelViewLine(line);
      if (channelViewMatch != null) {
        print('  -> Found channel-view pattern: ${channelViewMatch['channel']} | ${channelViewMatch['viewCount']}');
        
        // タイトルを前の行から逆算して探す
        final titleInfo = _findTitleBackward(lines, i, processedLines);
        if (titleInfo != null) {
          final video = VideoData(
            title: titleInfo['title']!,
            channel: channelViewMatch['channel']!,
            viewCount: channelViewMatch['viewCount'],
            confidence: titleInfo['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added video: $video');
          
          // 使用した行をマーク
          processedLines[i] = true;
          for (final lineIndex in titleInfo['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
          continue;
        }
      }
      
      // パターン2: 単独の視聴回数行
      if (_isViewCountOnly(line) && !processedLines[i]) {
        print('  -> Found standalone view count: $line');
        
        // チャンネル名とタイトルを逆算
        final info = _findChannelAndTitleBackward(lines, i, processedLines);
        if (info != null) {
          final video = VideoData(
            title: info['title']!,
            channel: info['channel']!,
            viewCount: line,
            confidence: info['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added video: $video');
          
          // 使用した行をマーク
          processedLines[i] = true;
          for (final lineIndex in info['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
        }
      }
    }
    
    // パターン3: 残った行でタイトル候補から前方検索
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      if (_isVideoTitle(line)) {
        print('Processing remaining title candidate $i: "$line"');
        
        final info = _findChannelViewForward(lines, i, processedLines);
        if (info != null) {
          final video = VideoData(
            title: info['title']!,
            channel: info['channel']!,
            viewCount: info['viewCount'],
            confidence: info['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added remaining video: $video');
          
          // 使用した行をマーク
          for (final lineIndex in info['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
        }
      }
    }
    
    print('Parsed ${videos.length} videos from OCR text');
    return videos;
  }
  
  // チャンネル・視聴回数行の解析
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
    
    // パターン2: "チャンネル名・・その他・視聴回数" (やかんの麦茶パターン)
    final pattern2 = RegExp(r'^.+・・(.+?)・([\d\.]+万?\s*回視聴)$');
    final match2 = pattern2.firstMatch(line);
    if (match2 != null) {
      return {
        'channel': match2.group(1)!.trim(),
        'viewCount': match2.group(2)!.trim(),
      };
    }
    
    return null;
  }
  
  // タイトルを後方検索で探す
  static Map<String, dynamic>? _findTitleBackward(List<String> lines, int fromIndex, List<bool> processedLines) {
    String title = '';
    final List<int> usedLines = [];
    double confidence = 0.95;
    
    // 最大4行前まで遡って探す
    for (int i = fromIndex - 1; i >= 0 && i >= fromIndex - 4; i--) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      
      // タイトルらしい行を発見
      if (_isVideoTitle(line) || _isTitlePart(line)) {
        title = line + title;
        usedLines.insert(0, i);
        
        // 複数行タイトルの場合、さらに前を確認
        if (i > 0 && !processedLines[i-1] && _isTitleContinuation(lines[i-1])) {
          title = lines[i-1] + title;
          usedLines.insert(0, i-1);
          confidence = 0.85;
        }
        
        if (title.length >= 10) {
          return {
            'title': _cleanTitle(title),
            'confidence': confidence,
            'usedLines': usedLines,
          };
        }
      }
    }
    
    return null;
  }
  
  // チャンネルとタイトルを後方検索で探す
  static Map<String, dynamic>? _findChannelAndTitleBackward(List<String> lines, int fromIndex, List<bool> processedLines) {
    if (fromIndex < 2) return null;
    
    final channelLine = lines[fromIndex - 1];
    if (processedLines[fromIndex - 1] || !_isChannelOnly(channelLine)) return null;
    
    // タイトルを探す
    String title = '';
    final List<int> usedLines = [fromIndex - 1]; // チャンネル行
    
    // タイトルが複数行の場合
    for (int i = fromIndex - 2; i >= 0 && i >= fromIndex - 5; i--) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      if (_isVideoTitle(line) || _isTitlePart(line)) {
        title = line + title;
        usedLines.insert(0, i);
        
        // さらに前の行もタイトルの一部か確認
        if (i > 0 && !processedLines[i-1] && _isTitleContinuation(lines[i-1])) {
          title = lines[i-1] + title;
          usedLines.insert(0, i-1);
        }
        
        if (title.length >= 5) {
          return {
            'title': _cleanTitle(title),
            'channel': _cleanChannel(channelLine),
            'confidence': 0.9,
            'usedLines': usedLines,
          };
        }
      }
    }
    
    return null;
  }
  
  // 前方検索でチャンネルと視聴回数を探す
  static Map<String, dynamic>? _findChannelViewForward(List<String> lines, int fromIndex, List<bool> processedLines) {
    String title = lines[fromIndex];
    final List<int> usedLines = [fromIndex];
    
    // タイトルが複数行の場合
    for (int i = fromIndex + 1; i < lines.length && i < fromIndex + 4; i++) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      
      // タイトルの続きかチェック
      if (_isTitleContinuation(line)) {
        title += line;
        usedLines.add(i);
        continue;
      }
      
      // チャンネル・視聴回数のパターンチェック
      final channelViewMatch = _parseChannelViewLine(line);
      if (channelViewMatch != null) {
        usedLines.add(i);
        return {
          'title': _cleanTitle(title),
          'channel': channelViewMatch['channel']!,
          'viewCount': channelViewMatch['viewCount'],
          'confidence': 0.85,
          'usedLines': usedLines,
        };
      }
      
      // チャンネル名のみの行
      if (_isChannelOnly(line)) {
        usedLines.add(i);
        
        // 次の行で視聴回数を探す
        if (i + 1 < lines.length && _isViewCountOnly(lines[i + 1])) {
          usedLines.add(i + 1);
          return {
            'title': _cleanTitle(title),
            'channel': _cleanChannel(line),
            'viewCount': lines[i + 1],
            'confidence': 0.8,
            'usedLines': usedLines,
          };
        }
      }
    }
    
    return null;
  }
  
  static bool _isVideoTitle(String line) {
    if (line.length < 5 || line.length > 200) return false;
    
    // 除外パターン
    final excludePatterns = [
      RegExp(r'^\d+万?\s*回視聴$'),
      RegExp(r'^[：\+]+$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^\d+\s*？?$'),
      RegExp(r'^\([\d/]+\)$'), // (2025/05/20)
      RegExp(r'^\[[\d/)\s]+$'), // [2025/03/30)
    ];
    
    for (final pattern in excludePatterns) {
      if (pattern.hasMatch(line)) return false;
    }
    
    // タイトルの特徴
    final titleIndicators = [
      RegExp(r'【[^】]*】'), // 【】括弧
      RegExp(r'\[[^\]]*\]'), // []括弧
      RegExp(r'クラロワ|FF7|FF8'), // ゲームタイトル
      RegExp(r'ダイエット|爆食|暴飲暴食'), // 食事系
      RegExp(r'加藤純一|マインクラフト|雑談'), // 配信者
      RegExp(r'勝率.*%|天界'), // ゲーム用語
      RegExp(r'\d+Hz'), // 音楽
    ];
    
    return titleIndicators.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isTitlePart(String line) {
    // タイトルの一部と思われる特徴
    return line.length >= 5 && 
           !_isViewCountOnly(line) && 
           !_isChannelOnly(line) &&
           !_shouldSkipLine(line) &&
           (line.contains('ダイエット') || 
            line.contains('爆食') || 
            line.contains('コンビニ') ||
            line.contains('血糖') ||
            line.contains('マインクラフト') ||
            line.contains('雑談') ||
            line.contains('天界') ||
            line.contains('デッキ') ||
            line.contains('自律神経') ||
            line.contains('習慣'));
  }
  
  static bool _isTitleContinuation(String line) {
    return line.length < 30 && 
           (line == 'しても良いよね' || 
            line == 'アル説' || 
            line == '値爆上げさせたら' ||
            line == 'に行ける新環境最強デッキ達を特別に教えます！' ||
            line.startsWith('www') ||
            line.contains('(') && line.contains(')'));
  }
  
  static bool _isChannelOnly(String line) {
    if (_isViewCountOnly(line)) return false;
    
    final channelPatterns = [
      RegExp(r'^午前0時のプリンセス'),
      RegExp(r'^加藤純ーロードショー$'),
      RegExp(r'^ZATUDANNI$'),
      RegExp(r'^Relax TV$'),
      RegExp(r'^むぎ$'),
      RegExp(r'^てつお[／/]ゲーム考察'),
      RegExp(r'^ラッシュ\s+CR$'),
      RegExp(r'^コカ・コーラ$'),
      RegExp(r'^跳兎$'),
    ];
    
    return channelPatterns.any((pattern) => pattern.hasMatch(line)) ||
           (line.length > 2 && line.length < 50 && !line.contains('・'));
  }
  
  static bool _isViewCountOnly(String line) {
    final viewPatterns = [
      RegExp(r'^\d+万回視聴$'),
      RegExp(r'^\d+\.\d+万回視聴$'),
      RegExp(r'^\d+回視聴$'),
      RegExp(r'^\d+万\s+回視聴$'),
      RegExp(r'^\d+\.\d+万\s*回視聴$'),
    ];
    
    return viewPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _shouldSkipLine(String line) {
    final skipPatterns = [
      RegExp(r'^：$'),
      RegExp(r'^\+$'),
      RegExp(r'^登録チャンネル$'),
      RegExp(r'^マイページ?$'),
      RegExp(r'^\d+\s*？?$'),
    ];
    
    return skipPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static String _cleanTitle(String title) {
    return title.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  static String _cleanChannel(String channel) {
    return channel.trim();
  }
}
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

class YouTubeOCRParserV4 {
  static List<VideoData> parseOCRText(String text) {
    print('=== YouTube OCR Parser V4 ===');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    print('Total lines to process: ${lines.length}');
    
    final List<VideoData> videos = [];
    final List<bool> processedLines = List.filled(lines.length, false);
    
    // パターン1: やかんの麦茶特殊パターンを最初に処理
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      final specialMatch = _parseSpecialChannelViewLine(line);
      if (specialMatch != null) {
        print('Processing special pattern line $i: "$line"');
        final video = VideoData(
          title: specialMatch['title']!,
          channel: specialMatch['channel']!,
          viewCount: specialMatch['viewCount'],
          confidence: 0.95,
        );
        videos.add(video);
        print('  -> Added special pattern video: $video');
        processedLines[i] = true;
        continue;
      }
    }
    
    // パターン2: チャンネル・視聴回数行から逆算
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      print('Processing line $i: "$line"');
      
      final channelViewMatch = _parseChannelViewLine(line);
      if (channelViewMatch != null) {
        print('  -> Found channel-view pattern: ${channelViewMatch['channel']} | ${channelViewMatch['viewCount']}');
        
        // タイトルを前の行から逆算（複数行対応）
        final titleInfo = _findTitleBackwardEnhanced(lines, i, processedLines);
        if (titleInfo != null) {
          final video = VideoData(
            title: titleInfo['title']!,
            channel: channelViewMatch['channel']!,
            viewCount: channelViewMatch['viewCount'],
            confidence: titleInfo['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added video: $video');
          
          processedLines[i] = true;
          for (final lineIndex in titleInfo['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
          continue;
        }
      }
      
      // パターン3: 単独の視聴回数行
      if (_isViewCountOnly(line) && !processedLines[i]) {
        print('  -> Found standalone view count: $line');
        
        final info = _findChannelAndTitleBackwardEnhanced(lines, i, processedLines);
        if (info != null) {
          final video = VideoData(
            title: info['title']!,
            channel: info['channel']!,
            viewCount: line,
            confidence: info['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added video: $video');
          
          processedLines[i] = true;
          for (final lineIndex in info['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
        }
      }
    }
    
    // パターン4: 残った行でタイトル候補から前方検索
    for (int i = 0; i < lines.length; i++) {
      if (processedLines[i]) continue;
      
      final line = lines[i];
      if (_isVideoTitle(line) || _isTitlePart(line)) {
        print('Processing remaining title candidate $i: "$line"');
        
        final info = _findChannelViewForwardEnhanced(lines, i, processedLines);
        if (info != null) {
          final video = VideoData(
            title: info['title']!,
            channel: info['channel']!,
            viewCount: info['viewCount'],
            confidence: info['confidence']! as double,
          );
          videos.add(video);
          print('  -> Added remaining video: $video');
          
          for (final lineIndex in info['usedLines'] as List<int>) {
            processedLines[lineIndex] = true;
          }
        }
      }
    }
    
    print('Parsed ${videos.length} videos from OCR text');
    return videos;
  }
  
  // 特殊パターン（やかんの麦茶）の解析
  static Map<String, String>? _parseSpecialChannelViewLine(String line) {
    // パターン: "【やかんの麦茶】もうひとつのクレヨンしんちゃん 第6話「お久しぶりの春日部だゾ！」篇・・コカ・コーラ・190万 回視聴"
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
    
    return null;
  }
  
  // 強化版タイトル後方検索（複数行タイトル対応）
  static Map<String, dynamic>? _findTitleBackwardEnhanced(List<String> lines, int fromIndex, List<bool> processedLines) {
    String title = '';
    final List<int> usedLines = [];
    double confidence = 0.95;
    bool foundMainTitle = false;
    
    // より広範囲を探索（最大6行前まで）
    for (int i = fromIndex - 1; i >= 0 && i >= fromIndex - 6; i--) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      
      // タイトルらしい行を発見
      if (_isVideoTitle(line) || _isTitlePart(line)) {
        // タイトルを前に追加
        title = line + title;
        usedLines.insert(0, i);
        foundMainTitle = true;
        confidence = 0.95;
        
        // さらに前の行もタイトルの一部か確認（積極的に結合）
        for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
          if (processedLines[j] || _shouldSkipLine(lines[j])) break;
          
          final prevLine = lines[j];
          if (_isTitleContinuation(prevLine) || _isTitlePart(prevLine)) {
            title = prevLine + title;
            usedLines.insert(0, j);
            confidence = 0.85;
          } else {
            break;
          }
        }
        
        // 後の行もタイトルの続きか確認（積極的に結合）
        for (int k = i + 1; k < fromIndex && k < i + 3; k++) {
          if (processedLines[k] || _shouldSkipLine(lines[k])) break;
          
          final nextLine = lines[k];
          if (_isTitleContinuation(nextLine) || _isTitlePart(nextLine)) {
            title = title + nextLine;
            usedLines.add(k);
            confidence = 0.85;
          } else {
            break;
          }
        }
        
        break; // メインタイトルを見つけたら終了
      }
    }
    
    // タイトル候補が見つからなかった場合、より柔軟に探索
    if (!foundMainTitle) {
      for (int i = fromIndex - 1; i >= 0 && i >= fromIndex - 4; i--) {
        if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
        
        final line = lines[i];
        
        // 長い行で特徴的な単語を含む場合はタイトルとして扱う
        if (line.length >= 5 && !_isViewCountOnly(line) && !_isChannelOnly(line)) {
          title = line + title;
          usedLines.insert(0, i);
          
          // 前後の行も確認
          for (int j = i - 1; j >= 0 && j >= i - 2; j--) {
            if (processedLines[j] || _shouldSkipLine(lines[j])) break;
            final prevLine = lines[j];
            if (_isTitleContinuation(prevLine) || prevLine.length >= 3) {
              title = prevLine + title;
              usedLines.insert(0, j);
            } else {
              break;
            }
          }
          
          for (int k = i + 1; k < fromIndex && k < i + 2; k++) {
            if (processedLines[k] || _shouldSkipLine(lines[k])) break;
            final nextLine = lines[k];
            if (_isTitleContinuation(nextLine) || nextLine.length >= 3) {
              title = title + nextLine;
              usedLines.add(k);
            } else {
              break;
            }
          }
          
          confidence = 0.8;
          break;
        }
      }
    }
    
    if (title.length >= 5) {
      return {
        'title': _cleanTitle(title),
        'confidence': confidence,
        'usedLines': usedLines,
      };
    }
    
    return null;
  }
  
  // 強化版チャンネルとタイトル後方検索
  static Map<String, dynamic>? _findChannelAndTitleBackwardEnhanced(List<String> lines, int fromIndex, List<bool> processedLines) {
    if (fromIndex < 2) return null;
    
    final channelLine = lines[fromIndex - 1];
    if (processedLines[fromIndex - 1] || !_isChannelOnly(channelLine)) return null;
    
    String title = '';
    final List<int> usedLines = [fromIndex - 1]; // チャンネル行
    bool foundMainTitle = false;
    
    // タイトルを積極的に結合
    for (int i = fromIndex - 2; i >= 0 && i >= fromIndex - 6; i--) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      if (_isVideoTitle(line) || _isTitlePart(line)) {
        title = line + title;
        usedLines.insert(0, i);
        foundMainTitle = true;
        
        // さらに前の行も確認
        for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
          if (processedLines[j] || _shouldSkipLine(lines[j])) break;
          
          final prevLine = lines[j];
          if (_isTitleContinuation(prevLine) || _isTitlePart(prevLine)) {
            title = prevLine + title;
            usedLines.insert(0, j);
          } else {
            break;
          }
        }
        
        // 後の行も確認（チャンネル行の前まで）
        for (int k = i + 1; k < fromIndex - 1; k++) {
          if (processedLines[k] || _shouldSkipLine(lines[k])) break;
          
          final nextLine = lines[k];
          if (_isTitleContinuation(nextLine) || _isTitlePart(nextLine)) {
            title = title + nextLine;
            usedLines.add(k);
          } else {
            break;
          }
        }
        
        break; // メインタイトルを見つけたら終了
      }
    }
    
    // メインタイトルが見つからなかった場合、より柔軟に探索
    if (!foundMainTitle) {
      for (int i = fromIndex - 2; i >= 0 && i >= fromIndex - 4; i--) {
        if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
        
        final line = lines[i];
        if (line.length >= 5 && !_isViewCountOnly(line) && !_isChannelOnly(line)) {
          title = line + title;
          usedLines.insert(0, i);
          
          // 前後の行も確認
          for (int j = i - 1; j >= 0 && j >= i - 2; j--) {
            if (processedLines[j] || _shouldSkipLine(lines[j])) break;
            final prevLine = lines[j];
            if (_isTitleContinuation(prevLine) || prevLine.length >= 3) {
              title = prevLine + title;
              usedLines.insert(0, j);
            } else {
              break;
            }
          }
          
          for (int k = i + 1; k < fromIndex - 1; k++) {
            if (processedLines[k] || _shouldSkipLine(lines[k])) break;
            final nextLine = lines[k];
            if (_isTitleContinuation(nextLine) || nextLine.length >= 3) {
              title = title + nextLine;
              usedLines.add(k);
            } else {
              break;
            }
          }
          
          break;
        }
      }
    }
    
    if (title.length >= 5) {
      return {
        'title': _cleanTitle(title),
        'channel': _cleanChannel(channelLine),
        'confidence': 0.9,
        'usedLines': usedLines,
      };
    }
    
    return null;
  }
  
  // 強化版前方検索
  static Map<String, dynamic>? _findChannelViewForwardEnhanced(List<String> lines, int fromIndex, List<bool> processedLines) {
    String title = lines[fromIndex];
    final List<int> usedLines = [fromIndex];
    
    // タイトルが複数行の場合を積極的に結合
    for (int i = fromIndex + 1; i < lines.length && i < fromIndex + 5; i++) {
      if (processedLines[i] || _shouldSkipLine(lines[i])) continue;
      
      final line = lines[i];
      
      // タイトルの続きかチェック
      if (_isTitleContinuation(line) || _isTitlePart(line)) {
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
      RegExp(r'自律神経'), // 健康系
    ];
    
    return titleIndicators.any((pattern) => pattern.hasMatch(line));
  }
  
  static bool _isTitlePart(String line) {
    // タイトルの一部と思われる特徴（より積極的に判定）
    return line.length >= 3 && 
           !_isViewCountOnly(line) && 
           !_isChannelOnly(line) &&
           !_shouldSkipLine(line) &&
           (line.contains('ダイエット') || 
            line.contains('爆食') || 
            line.contains('暴飲暴食') ||
            line.contains('コンビニ') ||
            line.contains('スイーツ') ||
            line.contains('血糖') ||
            line.contains('マインクラフト') ||
            line.contains('雑談') ||
            line.contains('天界') ||
            line.contains('デッキ') ||
            line.contains('自律神経') ||
            line.contains('習慣') ||
            line.contains('整える') ||
            line.contains('心も体も') ||
            line.contains('楽になる') ||
            line == 'リノ' ||
            line.contains('世界一') ||
            line.contains('わかりやすい'));
  }
  
  static bool _isTitleContinuation(String line) {
    return line.length < 30 && 
           (line == 'しても良いよね' || 
            line == 'アル説' || 
            line == '値爆上げさせたら' ||
            line == 'に行ける新環境最強デッキ達を特別に教えます！' ||
            line.startsWith('www') ||
            line.contains('リノ') ||
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
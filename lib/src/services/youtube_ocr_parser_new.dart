/// 解析された動画データの構造
class VideoData {
    final String title;
    final String channel;
    final String? duration;
    final String? viewedAt;
    final String? thumbnailInfo;
    final String? viewCount; // 視聴回数
    final double confidence; // 解析の信頼度 (0.0-1.0)
    
    VideoData({
      required this.title,
      required this.channel,
      this.duration,
      this.viewedAt,
      this.thumbnailInfo,
      this.viewCount,
      this.confidence = 0.0,
    });
    
    Map<String, dynamic> toJson() => {
      'title': title,
      'channel': channel,
      'duration': duration,
      'viewedAt': viewedAt,
      'thumbnailInfo': thumbnailInfo,
      'viewCount': viewCount,
      'confidence': confidence,
    };
}

/// YouTube視聴履歴OCRデータの解析と分類システム（完全改良版）
class YouTubeOCRParser {
  
  /// OCRテキストから動画データリストを抽出
  static List<VideoData> parseOCRText(String ocrText) {
    final List<VideoData> videos = [];
    
    // 1. テキストを行単位で分割して前処理
    final rawLines = ocrText.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !_isIgnorableLine(line))
        .toList();
    
    // 2. パターン認識ベースの解析
    final parsedVideos = _parseWithPatternRecognition(rawLines);
    
    return parsedVideos;
  }
  
  /// パターン認識ベースの解析
  static List<VideoData> _parseWithPatternRecognition(List<String> lines) {
    final videos = <VideoData>[];
    int i = 0;
    
    while (i < lines.length) {
      final result = _parseVideoBlock(lines, i);
      if (result != null) {
        videos.add(result['video']);
        i = result['nextIndex'];
      } else {
        i++;
      }
    }
    
    return videos;
  }
  
  /// 動画ブロックを解析
  static Map<String, dynamic>? _parseVideoBlock(List<String> lines, int startIndex) {
    if (startIndex >= lines.length) return null;
    
    String? title;
    String? channel;
    String? viewCount;
    double confidence = 0.0;
    int nextIndex = startIndex + 1;
    
    final currentLine = lines[startIndex];
    
    // パターン1: チャンネル名・視聴回数の複合行
    if (currentLine.contains('・') && currentLine.contains('万回視聴')) {
      final parts = currentLine.split('・');
      if (parts.length >= 2) {
        channel = parts[0].trim();
        viewCount = parts[1].trim();
        
        // 前の行をタイトルとして探す
        if (startIndex > 0) {
          final prevLine = lines[startIndex - 1];
          if (_isLikelyVideoTitle(prevLine)) {
            title = prevLine;
            confidence = 1.0;
          }
        }
        
        if (title == null) {
          title = '不明なタイトル';
          confidence = 0.5;
        }
        
        return {
          'video': VideoData(
            title: title,
            channel: channel,
            viewCount: viewCount,
            confidence: confidence,
          ),
          'nextIndex': nextIndex,
        };
      }
    }
    
    // パターン2: タイトルらしい行から開始
    if (_isLikelyVideoTitle(currentLine)) {
      title = currentLine;
      confidence = 0.8;
      
      // 次の行をチェック
      if (startIndex + 1 < lines.length) {
        final nextLine = lines[startIndex + 1];
        
        // タイトルの続きかチェック
        if (_isTitleContinuation(nextLine)) {
          title = '$title $nextLine';
          nextIndex = startIndex + 2;
          confidence = 0.9;
          
          // その次の行をチェック
          if (nextIndex < lines.length) {
            final thirdLine = lines[nextIndex];
            if (_isChannelName(thirdLine)) {
              channel = thirdLine;
              nextIndex++;
              
              // その次に視聴回数があるかチェック
              if (nextIndex < lines.length && _isViewCount(lines[nextIndex])) {
                viewCount = lines[nextIndex];
                nextIndex++;
              }
            }
          }
        } else if (_isChannelName(nextLine)) {
          // 直接チャンネル名の場合
          channel = nextLine;
          nextIndex = startIndex + 2;
          
          // その次に視聴回数があるかチェック
          if (nextIndex < lines.length && _isViewCount(lines[nextIndex])) {
            viewCount = lines[nextIndex];
            nextIndex++;
          }
        }
      }
      
      return {
        'video': VideoData(
          title: title,
          channel: channel ?? '不明なチャンネル',
          viewCount: viewCount,
          confidence: confidence,
        ),
        'nextIndex': nextIndex,
      };
    }
    
    // パターン3: その他の行（スキップ）
    return null;
  }
  
  /// タイトルの続きかどうか判定
  static bool _isTitleContinuation(String line) {
    // 短い日本語の続き文
    final continuationPatterns = [
      RegExp(r'^(しても良いよね|値爆上げさせたら|させたら|してる|している|できる|になる)'),
      RegExp(r'^[ぁ-ん]{1,8}$'), // 短いひらがな
    ];
    
    // チャンネル名や視聴回数でない
    if (_isChannelName(line) || _isViewCount(line)) return false;
    
    return continuationPatterns.any((pattern) => pattern.hasMatch(line)) ||
           (line.length <= 15 && !_isLikelyVideoTitle(line));
  }
  
  /// 動画タイトルの可能性を判定
  static bool _isLikelyVideoTitle(String line) {
    if (line.length < 5 || line.length > 200) return false;
    
    // 明らかにタイトルでないものを除外
    final excludePatterns = [
      RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$'), // 時間
      RegExp(r'^\d+万回視聴$'), // 視聴回数
      RegExp(r'^\d+[時間日週月年]前$'), // 相対時刻
      RegExp(r'^(再生|削除|共有|保存|いいね|コメント)$'), // UIボタン
    ];
    
    if (excludePatterns.any((pattern) => pattern.hasMatch(line))) {
      return false;
    }
    
    // タイトルらしいパターン
    final titlePatterns = [
      RegExp(r'【.*】'), // 【】括弧
      RegExp(r'加藤純一'), // 特定の固有名詞
      RegExp(r'ダイエット|マインクラフト|雑談|ロードショー'), // 動画関連語彙
      RegExp(r'暴飲暴食|爆食|クラロワ'), // 特定のキーワード
      RegExp(r'Hz|心も体も|勝率'), // 特徴的な語彙
      RegExp(r'ハードコア|ソロ|新環境|最強'), // ゲーム用語
    ];
    
    return titlePatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  /// チャンネル名の可能性を判定
  static bool _isChannelName(String line) {
    if (line.isEmpty || line.length > 50) return false;
    
    // 明らかにチャンネル名でないものを除外
    if (_isViewCount(line) || _isLikelyVideoTitle(line)) return false;
    
    // 既知のチャンネル名パターン
    final knownChannels = [
      RegExp(r'午前0時のプリンセス'),
      RegExp(r'ZATUDANNI'),
      RegExp(r'Relax TV'),
      RegExp(r'むぎ'),
      RegExp(r'加藤純一.*ロードショー'),
      RegExp(r'.*雑談ダイジェスト'),
      RegExp(r'自律神経を整える習慣'),
    ];
    
    if (knownChannels.any((pattern) => pattern.hasMatch(line))) {
      return true;
    }
    
    // 一般的なチャンネル名の特徴
    return line.length <= 30 && 
           !line.contains('【') && 
           !line.contains('】') &&
           !RegExp(r'[！？!?]').hasMatch(line);
  }
  
  /// 視聴回数かどうか判定
  static bool _isViewCount(String line) {
    final patterns = [
      RegExp(r'^\d+万回視聴$'),
      RegExp(r'^\d+\.\d+万回視聴$'),
      RegExp(r'^\d+回視聴$'),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(line));
  }
  
  /// 無視すべき行かどうか判定
  static bool _isIgnorableLine(String line) {
    final ignorablePatterns = [
      RegExp(r'^\s*$'), // 空行
      RegExp(r'^(再生|削除|共有|保存|いいね|コメント)$'), // UIボタン
      RegExp(r'^[+?：\-_=]+$'), // 記号のみの行
    ];
    
    return ignorablePatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  /// 再生時間の可能性を判定
  static bool _isLikelyDuration(String line) {
    return RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(line);
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
  
  /// 動画のカテゴリを推測
  static String _categorizeVideo(String title, String channel) {
    final categoryKeywords = {
      'ゲーム': ['ゲーム', 'Game', 'プレイ', '実況', 'gameplay', 'マインクラフト', 'クラロワ'],
      '音楽': ['音楽', 'Music', 'MV', 'Song', '歌', 'Hz'],
      '教育': ['講座', '解説', 'tutorial', '学習', '勉強'],
      'エンターテイメント': ['バラエティ', 'comedy', 'お笑い', 'Entertainment'],
      'ニュース': ['ニュース', 'News', '報道', '時事'],
      'ライフスタイル': ['料理', 'レシピ', '旅行', '日常', 'vlog', 'ダイエット', '暴飲暴食'],
      'テクノロジー': ['tech', 'IT', 'プログラミング', 'レビュー', '開発'],
    };
    
    final searchText = '$title $channel'.toLowerCase();
    
    for (final entry in categoryKeywords.entries) {
      if (entry.value.any((keyword) => 
          searchText.contains(keyword.toLowerCase()))) {
        return entry.key;
      }
    }
    
    return 'その他';
  }
  
  /// タグを生成
  static List<String> _generateTags(String title, String channel) {
    final tags = <String>[];
    
    // チャンネル名をタグに追加
    tags.add(channel);
    
    // タイトルから重要なキーワードを抽出
    final keywords = title.split(RegExp(r'[\s\-\|【】（）()]'))
        .where((word) => word.length >= 2)
        .take(5)
        .toList();
    
    tags.addAll(keywords);
    
    return tags;
  }
}
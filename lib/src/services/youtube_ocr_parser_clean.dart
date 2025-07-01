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

/// YouTube視聴履歴OCRデータの解析と分類システム
class YouTubeOCRParser {
  
  /// OCRテキストから動画データリストを抽出
  static List<VideoData> parseOCRText(String ocrText) {
    final List<VideoData> videos = [];
    
    // 1. テキストを行単位で分割
    final lines = ocrText.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    
    // 2. 空行で区切られた動画ブロックに分割
    final videoBlocks = splitIntoVideoBlocks(lines);
    
    // 3. 各ブロックを解析
    for (final block in videoBlocks) {
      final video = _parseVideoBlock(block);
      if (video != null) {
        videos.add(video);
      }
    }
    
    return videos;
  }
  
  /// 空行で区切られた動画ブロックに分割
  static List<List<String>> splitIntoVideoBlocks(List<String> lines) {
    final blocks = <List<String>>[];
    List<String> currentBlock = [];
    
    for (final line in lines) {
      if (line.trim().isEmpty) {
        if (currentBlock.isNotEmpty) {
          blocks.add(List.from(currentBlock));
          currentBlock.clear();
        }
      } else {
        currentBlock.add(line);
      }
    }
    
    // 最後のブロックを追加
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock);
    }
    
    return blocks;
  }
  
  /// 動画ブロックを解析
  static VideoData? _parseVideoBlock(List<String> block) {
    if (block.isEmpty) return null;
    
    String? title;
    String? channel;
    String? viewCount;
    double confidence = 0.0;
    
    // 特殊パターン1: 最後の行が「チャンネル名・視聴回数」形式
    final lastLine = block.last;
    if (lastLine.contains('・') && lastLine.contains('万回視聴')) {
      final parts = lastLine.split('・');
      if (parts.length >= 2) {
        channel = parts[0].trim();
        viewCount = parts[1].trim();
        
        // タイトルを構築
        final titleParts = block.sublist(0, block.length - 1);
        if (titleParts.isNotEmpty) {
          title = _buildTitle(titleParts);
          confidence = 1.0;
        }
      }
    } else {
      // 通常パターン: タイトル、チャンネル、視聴回数の順
      // タイトルを最初から順番に構築
      List<String> titleLines = [];
      int channelStartIndex = 0;
      
      for (int i = 0; i < block.length; i++) {
        final line = block[i];
        
        // 視聴回数が見つかったら処理終了
        if (isViewCount(line)) {
          viewCount = line;
          // 前の行がチャンネル名の可能性
          if (i > 0 && channel == null) {
            channel = block[i - 1];
          }
          break;
        }
        // チャンネル名らしい行が見つかった
        else if (isChannelName(line)) {
          channel = line;
          channelStartIndex = i;
          break;
        }
        // まだチャンネル名が見つからない場合、タイトルの一部として追加
        else {
          titleLines.add(line);
        }
      }
      
      if (titleLines.isNotEmpty) {
        title = _buildTitle(titleLines);
      }
      
      confidence = 0.8;
    }
    
    // タイトルがない場合、最初の適切な行をタイトルとする
    if (title == null && block.isNotEmpty) {
      title = block[0];
      confidence = 0.5;
    }
    
    if (title != null) {
      return VideoData(
        title: title,
        channel: channel ?? '不明なチャンネル',
        viewCount: viewCount,
        confidence: confidence,
      );
    }
    
    return null;
  }
  
  /// 複数行からタイトルを構築
  static String _buildTitle(List<String> titleLines) {
    if (titleLines.isEmpty) return '';
    
    String title = titleLines[0];
    
    // 2行目がタイトルの続きかチェック
    if (titleLines.length > 1) {
      final secondLine = titleLines[1];
      
      // 明らかにタイトルの続きのパターン
      final continuationPatterns = [
        'しても良いよね',
        '値爆上げさせたら',
        'させたら',
        'になる',
        'できる',
        'する',
      ];
      
      final isChannelLike = isChannelName(secondLine);
      final isContinuation = continuationPatterns.any((pattern) => 
          secondLine.contains(pattern)) || 
          (secondLine.length <= 15 && !isChannelLike && !isViewCount(secondLine));
      
      if (isContinuation) {
        title = '$title $secondLine';
      }
    }
    
    return title;
  }
  
  /// チャンネル名の可能性を判定
  static bool isChannelName(String line) {
    if (line.isEmpty || line.length > 50) return false;
    
    // 既知のチャンネル名
    final knownChannels = [
      '午前0時のプリンセス【ぜろぷり】',
      'ZATUDANNI',
      'Relax TV',
      'むぎ',
      '自律神経を整える習慣',
    ];
    
    if (knownChannels.contains(line)) return true;
    
    // パターンマッチング（より厳密に）
    final channelPatterns = [
      RegExp(r'^加藤純一.*ロードショー$'), // 完全一致パターン
      RegExp(r'^午前0時の.*'), // 開始パターン
    ];
    
    if (channelPatterns.any((pattern) => pattern.hasMatch(line))) return true;
    
    // 雑談ダイジェストパターンは日付を含まない場合のみ
    if (line.contains('雑談ダイジェスト') && !line.contains('[') && !line.contains(']')) {
      return true;
    }
    
    // 明らかにチャンネル名でないもの
    if (isViewCount(line) || 
        line.contains('【') || 
        line.contains('】') ||
        line.contains('?') ||
        line.contains('!') ||
        line.contains('％') ||
        line.contains('Hz')) {
      return false;
    }
    
    // 短い日本語・英語・数字の組み合わせ
    return line.length <= 30 && 
           RegExp(r'^[a-zA-Z0-9ひらがなカタカナ一-龯\s\-_（）()【】]+$').hasMatch(line);
  }
  
  /// 視聴回数かどうか判定
  static bool isViewCount(String line) {
    final patterns = [
      RegExp(r'^\d+万回視聴$'),
      RegExp(r'^\d+\.\d+万回視聴$'),
      RegExp(r'^\d+回視聴$'),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(line));
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
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
            
            // 題名と投稿者が逆になっている可能性をチェック
            // 題名がチャンネル名のように見える場合（短い、またはチャンネル名のパターン）
            // 投稿者がタイトルのように見える場合（長い、または【】を含む）
            bool shouldSwap = false;
            
            // 題名がチャンネル名のように見える場合
            if (title.length < 20 && 
                !title.contains('【') && 
                !title.contains('】') &&
                channel.length > 20) {
              shouldSwap = true;
            }
            
            // 投稿者がタイトルのように見える場合（【】を含む、または日付を含む）
            if (channel.contains('【') || 
                channel.contains('】') ||
                RegExp(r'\d{4}[/-]\d{1,2}[/-]\d{1,2}').hasMatch(channel)) {
              shouldSwap = true;
            }
            
            // 題名がチャンネル名のパターンに一致する場合（「〇〇ロードショー」「〇〇TV」など）
            if (RegExp(r'.+(?:ロードショー|TV|チャンネル)').hasMatch(title) &&
                channel.length > title.length) {
              shouldSwap = true;
            }
            
            final finalTitle = shouldSwap ? channel : title;
            final finalChannel = shouldSwap ? title : channel;
            
            final video = VideoData(
              title: finalTitle.trim(),
              channel: finalChannel.trim(),
              viewCount: viewCount,
              confidence: shouldSwap ? 0.85 : 0.95, // 入れ替えた場合は信頼度を下げる
            );
            videos.add(video);
            print('  -> Structured video: $video (swapped: $shouldSwap)');
          }
        }
      }
    }
    
    return videos;
  }
  
  // 自然なOCRフォーマットの処理（ユーザー提供データ用） - GAI Studio Logic Integrated
  static List<VideoData> _parseNaturalFormat(List<String> allLines) {
    print('Trying natural format parsing (Enhanced with GAI Studio Logic)...');
    
    // Filter out empty lines
    final lines = allLines.where((line) => line.trim().isNotEmpty).toList();

    // Find the index of the first plausible video title. This helps skip preambles.
    // Logic from GAI Studio's parserService.ts
    int startIndex = lines.indexWhere((line) {
      final isPreamble = RegExp(r'^(here are|sure, here|Sure, |Here are|以下に|はい、)', caseSensitive: false).hasMatch(line);
      final isHeaderLike = line.endsWith(':');
      // A plausible title is not a preamble, not a header, and has some length.
      return !isPreamble && !isHeaderLike && line.length > 5;
    });

    if (startIndex == -1) {
      // If no clear start found, check if it's because the list is very short
      // and doesn't contain preamble. If so, process from start.
      final hasPreamble = lines.any((line) => RegExp(r'^(here are|sure, here|Sure, |Here are|以下に|はい、)', caseSensitive: false).hasMatch(line));
      if (hasPreamble) return []; // Contains preamble but no clear start, likely junk.
      startIndex = 0;
    }

    final videos = <VideoData>[];
    final relevantLines = lines.sublist(startIndex);

    for (int i = 0; i < relevantLines.length; i++) {
      // Clean the line from any leading list markers.
      String currentLine = relevantLines[i].replaceFirst(RegExp(r'^[\*\-\d\.]+\s*'), '').trim();
      if (currentLine.isEmpty) continue;

      // Pattern A: Title and Channel on the same line, separated by ' - '
      // GAI Studio Logic
      final dashIndex = currentLine.lastIndexOf(' - ');
      if (dashIndex > 0 && dashIndex < currentLine.length - 3) {
        final title = currentLine.substring(0, dashIndex).trim();
        final channel = currentLine.substring(dashIndex + 3).trim();
        
        videos.add(VideoData(
          title: title,
          channel: channel,
          confidence: 0.95,
        ));
        continue;
      }

      // Pattern B: Title is the current line, channel might be the next.
      // GAI Studio Logic
      String title = currentLine;
      String channel = '';

      // Check if next line exists and could be a channel name.
      if (i + 1 < relevantLines.length) {
        final nextLine = relevantLines[i + 1];
        // A channel line should NOT look like a new video title (i.e., not start with a list marker, and not contain ' - ').
        final isNextLineAnotherTitle = RegExp(r'^[\*\-\d\.]+\s*').hasMatch(nextLine) || nextLine.lastIndexOf(' - ') > 0;

        if (!isNextLineAnotherTitle) {
          // We'll assume this is the channel line.
          channel = nextLine;

          // Clean up common channel line artifacts.
          final splitters = ['・', '•', '—', '視聴回数', '回視聴'];
          for (final s in splitters) {
            if (channel.contains(s)) {
              channel = channel.split(s).first.trim();
              break;
            }
          }
          
          // Clean leading markers from channel if any (rare but possible)
          channel = channel.replaceFirst(RegExp(r'^[\*\-\d\.]+\s*'), '').trim();
          
          i++; // Consume the channel line, so we skip it in the next iteration.
        }
      }
      
      // Add only if we have at least a title
      videos.add(VideoData(
        title: title,
        channel: channel, // Channel might be empty if not found
        confidence: 0.9,
      ));
    }

    // A final cleanup step: if an item looks like a preamble that slipped through, remove it.
    return videos.where((v) => !RegExp(r'^(here are|sure, here|Sure, |Here are|以下に|はい、)', caseSensitive: false).hasMatch(v.title)).toList();
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
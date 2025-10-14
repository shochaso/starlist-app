import '../services/spotify_playlist_parser.dart';

class SpotifyHistoryItem extends SpotifyTrack {
  final String? playedAt;
  final int? playCount;

  SpotifyHistoryItem({
    required super.title,
    required super.artist,
    super.album,
    super.duration,
    this.playedAt,
    this.playCount,
    required super.confidence,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['playedAt'] = playedAt ?? '';
    map['playCount'] = playCount;
    return map;
  }
}

class SpotifyHistoryParser {
  static List<SpotifyHistoryItem> parseHistoryText(String text) {
    if (text.trim().isEmpty) return [];

    final List<SpotifyHistoryItem> items = [];
    
    // 複数のパース戦略
    items.addAll(_parseScreenshotFormat(text));
    items.addAll(_parseListFormat(text));
    items.addAll(_parseTimeBasedFormat(text));
    items.addAll(_parseGenericHistoryFormat(text));

    // 重複除去と信頼度によるソート
    final uniqueItems = _removeDuplicates(items);
    uniqueItems.sort((a, b) => b.confidence.compareTo(a.confidence));

    return uniqueItems;
  }

  // スクリーンショット形式（画像のような形式）
  static List<SpotifyHistoryItem> _parseScreenshotFormat(String text) {
    final items = <SpotifyHistoryItem>[];
    final lines = text.split('\n');
    
    String? currentTitle;
    String? currentDuration;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // 次の行がプレイリスト情報の場合、現在の行はプレイリスト名なのでスキップ
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1].trim();
        if (nextLine.contains('再生済み') && nextLine.contains('プレイリスト')) {
          continue;
        }
      }
      
      // 時間形式の検出（例：2:48）
      final durationMatch = RegExp(r'^\d+:\d{2}$').firstMatch(line);
      if (durationMatch != null) {
        currentDuration = line;
        continue;
      }
      
      // アーティスト・2曲を再生済み のパターン
      final artistPattern = RegExp(r'^(.+?)\s*・\s*(\d+)曲を再生済み');
      final artistMatch = artistPattern.firstMatch(line);
      if (artistMatch != null) {
        if (currentTitle != null) {
          items.add(SpotifyHistoryItem(
            title: currentTitle,
            artist: artistMatch.group(1)!.trim(),
            duration: currentDuration,
            playCount: int.tryParse(artistMatch.group(2)!),
            confidence: 0.9,
          ));
          currentTitle = null;
          currentDuration = null;
        }
        continue;
      }
      
      // プレイリスト・Spotify のパターンや再生済み情報をスキップ
      if (line.contains('プレイリスト') || 
          line.contains('Spotify') ||
          line.contains('再生済み') ||
          line.contains('曲を再生')) {
        continue;
      }
      
      // 単独のアーティスト名
      if (i + 1 < lines.length && _isLikelyArtist(line)) {
        if (currentTitle != null) {
          items.add(SpotifyHistoryItem(
            title: currentTitle,
            artist: line,
            duration: currentDuration,
            confidence: 0.85,
          ));
          currentTitle = null;
          currentDuration = null;
        }
        continue;
      }
      
      // タイトルの可能性（プレイリスト名を除外）
      if (_isLikelyTitle(line) && !_isSystemText(line) && !_isPlaylistName(line)) {
        currentTitle = line;
      }
    }
    
    return items;
  }

  // リスト形式（箇条書き）
  static List<SpotifyHistoryItem> _parseListFormat(String text) {
    final items = <SpotifyHistoryItem>[];
    
    // 様々なリスト形式のパターン
    final patterns = [
      // 番号付き: 1. タイトル - アーティスト (時間)
      RegExp(r'^\d+\.?\s*(.+?)\s*[-–—]\s*(.+?)(?:\s*\((\d+:\d+)\))?$', multiLine: true),
      // 記号付き: ・タイトル / アーティスト
      RegExp(r'^[・▪▸•]\s*(.+?)\s*[/／]\s*(.+?)$', multiLine: true),
      // タイトル by アーティスト
      RegExp(r'^(.+?)\s+by\s+(.+?)$', multiLine: true, caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final title = match.group(1)!.trim();
        final artist = match.group(2)!.trim();
        final duration = match.groupCount >= 3 ? match.group(3) : null;
        
        if (title.isNotEmpty && artist.isNotEmpty) {
          items.add(SpotifyHistoryItem(
            title: title,
            artist: artist,
            duration: duration,
            confidence: 0.8,
          ));
        }
      }
    }
    
    return items;
  }

  // 時刻ベース形式（再生時刻付き）
  static List<SpotifyHistoryItem> _parseTimeBasedFormat(String text) {
    final items = <SpotifyHistoryItem>[];
    
    // 時刻パターン（例：14:30, 2:30 PM）
    final timePattern = RegExp(r'(\d{1,2}:\d{2}(?:\s*[AP]M)?)', caseSensitive: false);
    final lines = text.split('\n');
    
    String? currentTime;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 時刻の検出
      final timeMatch = timePattern.firstMatch(trimmedLine);
      if (timeMatch != null && trimmedLine.length < 10) {
        currentTime = timeMatch.group(1);
        continue;
      }
      
      // 曲情報の検出
      final dashPattern = RegExp(r'^(.+?)\s*[-–—]\s*(.+?)$');
      final match = dashPattern.firstMatch(trimmedLine);
      
      if (match != null) {
        items.add(SpotifyHistoryItem(
          title: match.group(1)!.trim(),
          artist: match.group(2)!.trim(),
          playedAt: currentTime,
          confidence: 0.75,
        ));
      }
    }
    
    return items;
  }

  // 汎用履歴形式
  static List<SpotifyHistoryItem> _parseGenericHistoryFormat(String text) {
    final items = <SpotifyHistoryItem>[];
    final lines = text.split('\n');
    
    String? currentTitle;
    String? currentArtist;
    String? currentInfo;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || _isSystemText(trimmedLine)) continue;
      
      // 再生回数情報
      if (trimmedLine.contains('再生') || trimmedLine.contains('回')) {
        currentInfo = trimmedLine;
        if (currentTitle != null && currentArtist != null) {
          final playCountMatch = RegExp(r'(\d+)[回曲]').firstMatch(trimmedLine);
          items.add(SpotifyHistoryItem(
            title: currentTitle,
            artist: currentArtist,
            playCount: playCountMatch != null ? int.tryParse(playCountMatch.group(1)!) : null,
            confidence: 0.7,
          ));
          currentTitle = null;
          currentArtist = null;
        }
        continue;
      }
      
      // アーティストらしい行
      if (_isLikelyArtist(trimmedLine) && currentTitle != null) {
        currentArtist = trimmedLine;
        if (currentInfo == null) {
          items.add(SpotifyHistoryItem(
            title: currentTitle,
            artist: currentArtist,
            confidence: 0.65,
          ));
          currentTitle = null;
          currentArtist = null;
        }
      }
      // タイトルらしい行（プレイリスト名を除外）
      else if (_isLikelyTitle(trimmedLine) && !_isPlaylistName(trimmedLine)) {
        if (currentTitle != null && currentArtist == null) {
          // 前のタイトルだけの場合はスキップ
        }
        currentTitle = trimmedLine;
        currentInfo = null;
      }
    }
    
    return items;
  }

  // ユーティリティメソッド
  static bool _isLikelyTitle(String text) {
    if (text.length < 2 || text.length > 100) return false;
    if (RegExp(r'^[\d\s\-:#.]+$').hasMatch(text)) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isLikelyArtist(String text) {
    if (text.length < 2 || text.length > 50) return false;
    if (text.contains('feat.') || text.contains('ft.')) return true;
    if (text.toUpperCase() == text && text.length > 2) return true; // 全て大文字
    if (RegExp(r'^[A-Za-z\s&,.\-]+$').hasMatch(text)) return true; // 英語名
    if (RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF\s]+$').hasMatch(text)) return true; // 日本語名
    return false;
  }

  static bool _isSystemText(String text) {
    final systemKeywords = [
      '音楽', '今日', '最近', 'ホーム', '検索', 'ライブラリ', 
      'Premium', 'プレミアム', '制作する', 'マイライブラリ',
      'Spotify', '履歴', '再生中'
    ];
    
    final lowerText = text.toLowerCase();
    return systemKeywords.any((keyword) => 
      lowerText.contains(keyword.toLowerCase()) || text == keyword
    );
  }

  static bool _isPlaylistName(String text) {
    // プレイリスト名の特徴をチェック
    final playlistIndicators = [
      'Mix', 'mix', 'Collection', 'Playlist', 'playlist', 'プレイリスト',
      'Radio', 'radio', 'Station', 'station', 'Daily', 'daily',
      'Weekly', 'weekly', 'Discover', 'discover'
    ];
    
    return playlistIndicators.any((indicator) => text.contains(indicator)) ||
           (text.length > 20 && text.contains(' ')); // 長いスペース区切り文字列はプレイリスト名の可能性
  }

  static List<SpotifyHistoryItem> _removeDuplicates(List<SpotifyHistoryItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.title.toLowerCase()}_${item.artist.toLowerCase()}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
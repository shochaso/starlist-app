class SpotifyTrack {
  final String title;
  final String artist;
  final String? album;
  final String? duration;
  final String? addedAt;
  final int? trackNumber;
  final double confidence;

  SpotifyTrack({
    required this.title,
    required this.artist,
    this.album,
    this.duration,
    this.addedAt,
    this.trackNumber,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album ?? '',
      'duration': duration ?? '',
      'addedAt': addedAt ?? '',
      'trackNumber': trackNumber,
      'confidence': confidence,
    };
  }
}

class SpotifyPlaylistParser {
  static List<SpotifyTrack> parsePlaylistText(String text) {
    if (text.trim().isEmpty) return [];

    final List<SpotifyTrack> tracks = [];
    
    // 複数のパース戦略を試行
    tracks.addAll(_parseNumberedList(text));
    tracks.addAll(_parseTabSeparated(text));
    tracks.addAll(_parseDashSeparated(text));
    tracks.addAll(_parseSpotifyShareFormat(text));
    tracks.addAll(_parseGenericFormat(text));

    // 重複除去
    final uniqueTracks = _removeDuplicates(tracks);
    
    // 信頼度でソート
    uniqueTracks.sort((a, b) => b.confidence.compareTo(a.confidence));

    return uniqueTracks;
  }

  // 番号付きリスト形式（例：1. 曲名 - アーティスト）
  static List<SpotifyTrack> _parseNumberedList(String text) {
    final tracks = <SpotifyTrack>[];
    final pattern = RegExp(
      r'^\s*(\d+)\.?\s*(.+?)\s*[-–—]\s*(.+?)(?:\s*\((\d+:\d+)\))?$',
      multiLine: true,
    );

    final matches = pattern.allMatches(text);
    for (final match in matches) {
      final trackNumber = int.tryParse(match.group(1)!);
      final title = match.group(2)!.trim();
      final artist = match.group(3)!.trim();
      final duration = match.group(4);

      tracks.add(SpotifyTrack(
        title: title,
        artist: artist,
        duration: duration,
        trackNumber: trackNumber,
        confidence: 0.9,
      ));
    }

    return tracks;
  }

  // タブ区切り形式
  static List<SpotifyTrack> _parseTabSeparated(String text) {
    final tracks = <SpotifyTrack>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      final parts = line.split('\t');
      if (parts.length >= 2) {
        final title = parts[0].trim();
        final artist = parts[1].trim();
        final album = parts.length > 2 ? parts[2].trim() : null;
        final duration = parts.length > 3 ? parts[3].trim() : null;

        if (title.isNotEmpty && artist.isNotEmpty) {
          tracks.add(SpotifyTrack(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            confidence: 0.85,
          ));
        }
      }
    }

    return tracks;
  }

  // ダッシュ区切り形式（曲名 - アーティスト）
  static List<SpotifyTrack> _parseDashSeparated(String text) {
    final tracks = <SpotifyTrack>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      // 様々なダッシュ文字に対応
      final dashPattern = RegExp(r'^(.+?)\s*[-–—]\s*(.+?)(?:\s*\[(.+?)\])?(?:\s*\((\d+:\d+)\))?$');
      final match = dashPattern.firstMatch(line);
      
      if (match != null) {
        final title = match.group(1)!.trim();
        final artist = match.group(2)!.trim();
        final album = match.group(3)?.trim();
        final duration = match.group(4)?.trim();

        if (title.isNotEmpty && artist.isNotEmpty && !_isHeaderLine(title)) {
          tracks.add(SpotifyTrack(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            confidence: 0.8,
          ));
        }
      }
    }

    return tracks;
  }

  // Spotify共有フォーマット
  static List<SpotifyTrack> _parseSpotifyShareFormat(String text) {
    final tracks = <SpotifyTrack>[];
    
    // 楽曲パターン
    final trackPatterns = [
      RegExp(r'楽曲\d*[：:]\s*(.+?)\s*[-–—]\s*(.+)', caseSensitive: false),
      RegExp(r'曲[：:]\s*(.+?)\s*[-–—]\s*(.+)', caseSensitive: false),
      RegExp(r'Track\s*\d*[：:]\s*(.+?)\s*[-–—]\s*(.+)', caseSensitive: false),
    ];

    final lines = text.split('\n');
    for (final line in lines) {
      for (final pattern in trackPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          tracks.add(SpotifyTrack(
            title: match.group(1)!.trim(),
            artist: match.group(2)!.trim(),
            confidence: 0.85,
          ));
          break;
        }
      }
    }

    return tracks;
  }

  // 汎用フォーマット（柔軟なパース）
  static List<SpotifyTrack> _parseGenericFormat(String text) {
    final tracks = <SpotifyTrack>[];
    final lines = text.split('\n');
    
    String? currentTitle;
    String? currentArtist;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // アーティスト名の可能性をチェック
      if (_isLikelyArtist(trimmedLine) && currentTitle != null) {
        currentArtist = trimmedLine;
        
        tracks.add(SpotifyTrack(
          title: currentTitle,
          artist: currentArtist,
          confidence: 0.6,
        ));
        
        currentTitle = null;
        currentArtist = null;
      }
      // 曲名の可能性をチェック
      else if (_isLikelyTitle(trimmedLine)) {
        if (currentTitle != null && currentArtist == null) {
          // 前の曲名だけの場合はスキップ
          currentTitle = trimmedLine;
        } else {
          currentTitle = trimmedLine;
        }
      }
    }

    return tracks;
  }

  // ユーティリティメソッド
  static bool _isHeaderLine(String text) {
    final headers = ['プレイリスト', 'playlist', 'tracklist', '曲リスト', 'songs'];
    final lowerText = text.toLowerCase();
    return headers.any((header) => lowerText.contains(header));
  }

  static bool _isLikelyTitle(String text) {
    // 数字のみ、記号のみ、短すぎる文字列を除外
    if (text.length < 2) return false;
    if (RegExp(r'^[\d\s\-:#.]+$').hasMatch(text)) return false;
    if (_isHeaderLine(text)) return false;
    return true;
  }

  static bool _isLikelyArtist(String text) {
    // アーティスト名の特徴をチェック
    if (text.length < 2 || text.length > 50) return false;
    if (text.contains('feat.') || text.contains('ft.')) return true;
    if (RegExp(r'^[A-Za-z\s&,]+$').hasMatch(text)) return true; // 英語名
    if (RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$').hasMatch(text)) return true; // 日本語名
    return false;
  }

  static List<SpotifyTrack> _removeDuplicates(List<SpotifyTrack> tracks) {
    final seen = <String>{};
    return tracks.where((track) {
      final key = '${track.title.toLowerCase()}_${track.artist.toLowerCase()}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
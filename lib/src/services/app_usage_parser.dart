class AppUsageItem {
  final String appName;
  final String category;
  final String usageDuration;
  final String? screenTime;
  final String? openCount;
  final String date;
  final double confidence;
  final String rawText;

  AppUsageItem({
    required this.appName,
    required this.category,
    required this.usageDuration,
    this.screenTime,
    this.openCount,
    required this.date,
    required this.confidence,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'category': category,
      'usageDuration': usageDuration,
      'screenTime': screenTime,
      'openCount': openCount,
      'date': date,
      'confidence': confidence,
      'rawText': rawText,
    };
  }
}

class AppUsageParser {
  static const double minConfidenceThreshold = 0.6;

  static List<AppUsageItem> parseUsageText(String text) {
    if (text.trim().isEmpty) return [];

    final List<AppUsageItem> items = [];
    
    // 複数のパース戦略を順番に試行
    items.addAll(_parseScreenTimeFormat(text));
    items.addAll(_parseAndroidUsageFormat(text));
    items.addAll(_parseAppStoreFormat(text));
    items.addAll(_parseGenericUsageFormat(text));

    // 重複除去と信頼度によるフィルタリング
    final uniqueItems = _removeDuplicates(items);
    final filteredItems = uniqueItems
        .where((item) => item.confidence >= minConfidenceThreshold)
        .toList();

    // 使用時間でソート（長い順）
    filteredItems.sort((a, b) => _parseTimeMinutes(b.usageDuration).compareTo(_parseTimeMinutes(a.usageDuration)));

    return filteredItems;
  }

  // iOSスクリーンタイム形式のパース
  static List<AppUsageItem> _parseScreenTimeFormat(String text) {
    final items = <AppUsageItem>[];
    
    if (!text.contains('スクリーンタイム') && !text.contains('Screen Time')) {
      return items;
    }

    // 日付の検出
    final datePattern = RegExp(r'(\d{1,2})月(\d{1,2})日|(\d{4})/(\d{1,2})/(\d{1,2})');
    final dateMatch = datePattern.firstMatch(text);
    String date = 'N/A';
    if (dateMatch != null) {
      if (dateMatch.group(1) != null) {
        date = '2024/${dateMatch.group(1)!.padLeft(2, '0')}/${dateMatch.group(2)!.padLeft(2, '0')}';
      } else {
        date = '${dateMatch.group(3)}/${dateMatch.group(4)!.padLeft(2, '0')}/${dateMatch.group(5)!.padLeft(2, '0')}';
      }
    }

    // アプリ使用時間パターン
    final usagePatterns = [
      // アプリ名 カテゴリ 時間分
      RegExp(r'^([^\n\d]{2,30})\s+([^\n\d]{2,15})\s+(\d+時間?\s*\d*分?|\d+分)', multiLine: true),
      // アプリ名 時間分
      RegExp(r'^([^\n\d]{2,30})\s+(\d+時間?\s*\d*分?|\d+分)', multiLine: true),
    ];

    for (final pattern in usagePatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final appName = match.group(1)!.trim();
        String category = 'その他';
        String usageDuration;
        
        if (match.groupCount >= 3) {
          category = match.group(2)!.trim();
          usageDuration = match.group(3)!.trim();
        } else {
          usageDuration = match.group(2)!.trim();
        }

        if (_isValidAppName(appName) && _isValidDuration(usageDuration)) {
          final confidence = _calculateConfidence({
            'hasValidName': appName.length > 2,
            'hasDuration': true,
            'hasCategory': category != 'その他',
            'hasDate': date != 'N/A',
            'iosFormat': true,
          });

          items.add(AppUsageItem(
            appName: appName,
            category: _normalizeCategory(category),
            usageDuration: _normalizeDuration(usageDuration),
            date: date,
            confidence: confidence,
            rawText: match.group(0)!,
          ));
        }
      }
    }

    return items;
  }

  // Android使用状況形式のパース
  static List<AppUsageItem> _parseAndroidUsageFormat(String text) {
    final items = <AppUsageItem>[];
    
    if (!text.contains('使用時間') && !text.contains('アプリ使用状況')) {
      return items;
    }

    final lines = text.split('\n');
    String date = 'N/A';
    
    // 日付の検出
    for (final line in lines) {
      final dateMatch = RegExp(r'(\d{4})[年/](\d{1,2})[月/](\d{1,2})日?').firstMatch(line);
      if (dateMatch != null) {
        date = '${dateMatch.group(1)}/${dateMatch.group(2)!.padLeft(2, '0')}/${dateMatch.group(3)!.padLeft(2, '0')}';
        break;
      }
    }

    // Androidアプリ使用パターン
    final androidPattern = RegExp(
      r'^([^\n\d]{2,30})\s+(\d+時間?\s*\d*分?|\d+分)\s*(\d+回)?',
      multiLine: true,
    );

    final matches = androidPattern.allMatches(text);
    for (final match in matches) {
      final appName = match.group(1)!.trim();
      final usageDuration = match.group(2)!.trim();
      final openCount = match.group(3)?.replaceAll('回', '');

      if (_isValidAppName(appName) && _isValidDuration(usageDuration)) {
        final confidence = _calculateConfidence({
          'hasValidName': appName.length > 2,
          'hasDuration': true,
          'hasOpenCount': openCount != null,
          'hasDate': date != 'N/A',
          'androidFormat': true,
        });

        items.add(AppUsageItem(
          appName: appName,
          category: _categorizeApp(appName),
          usageDuration: _normalizeDuration(usageDuration),
          openCount: openCount,
          date: date,
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // App Store形式のパース
  static List<AppUsageItem> _parseAppStoreFormat(String text) {
    final items = <AppUsageItem>[];
    
    if (!text.contains('週間レポート') && !text.contains('App Store')) {
      return items;
    }

    // 週間レポートのパターン
    final weeklyPattern = RegExp(
      r'^([^\n\d]{2,30})\s+(\d+時間?\s*\d*分?|\d+分)\s+([+\-]\d+%)?',
      multiLine: true,
    );

    final matches = weeklyPattern.allMatches(text);
    for (final match in matches) {
      final appName = match.group(1)!.trim();
      final usageDuration = match.group(2)!.trim();
      final changePercent = match.group(3);

      if (_isValidAppName(appName) && _isValidDuration(usageDuration)) {
        final confidence = _calculateConfidence({
          'hasValidName': appName.length > 2,
          'hasDuration': true,
          'hasChange': changePercent != null,
          'appStoreFormat': true,
        });

        items.add(AppUsageItem(
          appName: appName,
          category: _categorizeApp(appName),
          usageDuration: _normalizeDuration(usageDuration),
          screenTime: changePercent,
          date: 'N/A',
          confidence: confidence,
          rawText: match.group(0)!,
        ));
      }
    }

    return items;
  }

  // 汎用使用状況形式のパース
  static List<AppUsageItem> _parseGenericUsageFormat(String text) {
    final items = <AppUsageItem>[];
    final lines = text.split('\n');
    
    String? currentApp;
    String? currentTime;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 時間パターンの検出
      final timeMatch = RegExp(r'(\d+時間?\s*\d*分?|\d+分)').firstMatch(trimmedLine);
      if (timeMatch != null) {
        currentTime = timeMatch.group(1)!;
        
        // 同じ行にアプリ名がある場合
        final beforeTime = trimmedLine.substring(0, timeMatch.start).trim();
        if (beforeTime.isNotEmpty && _isValidAppName(beforeTime)) {
          currentApp = beforeTime;
        }
        
        if (currentApp != null && currentTime != null) {
          final confidence = _calculateConfidence({
            'hasValidName': currentApp.length > 2,
            'hasDuration': true,
            'generic': true,
          });

          items.add(AppUsageItem(
            appName: currentApp,
            category: _categorizeApp(currentApp),
            usageDuration: _normalizeDuration(currentTime),
            date: 'N/A',
            confidence: confidence,
            rawText: trimmedLine,
          ));
          
          currentApp = null;
          currentTime = null;
        }
      }
      // アプリ名候補の検出
      else if (_isValidAppName(trimmedLine)) {
        currentApp = trimmedLine;
      }
    }

    return items;
  }

  // ユーティリティメソッド
  static bool _isValidAppName(String text) {
    if (text.length < 2 || text.length > 30) return false;
    if (RegExp(r'^[\d\s時間分回%+-]+$').hasMatch(text)) return false;
    if (_isSystemText(text)) return false;
    return true;
  }

  static bool _isValidDuration(String duration) {
    return RegExp(r'\d+(時間|分)').hasMatch(duration);
  }

  static bool _isSystemText(String text) {
    final systemKeywords = [
      'スクリーンタイム', 'Screen Time', '使用時間', '合計',
      '平均', '今日', '昨日', '今週', '先週', 'レポート'
    ];
    return systemKeywords.any((keyword) => text.contains(keyword));
  }

  static String _normalizeCategory(String category) {
    final categoryMap = {
      'ソーシャルネットワーキング': 'SNS',
      'エンターテインメント': 'エンタメ',
      'ゲーム': 'ゲーム',
      'ユーティリティ': 'ツール',
      'プロダクティビティ': '仕事',
      'ファイナンス': '金融',
      '写真/ビデオ': '写真・動画',
    };
    
    return categoryMap[category] ?? category;
  }

  static String _normalizeDuration(String duration) {
    // 「1時間30分」→「1時間30分」、「90分」→「1時間30分」に正規化
    final minutesMatch = RegExp(r'^(\d+)分$').firstMatch(duration);
    if (minutesMatch != null) {
      final minutes = int.parse(minutesMatch.group(1)!);
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        return remainingMinutes > 0 ? '$hours時間$remainingMinutes分' : '$hours時間';
      }
    }
    
    return duration;
  }

  static String _categorizeApp(String appName) {
    final categories = {
      'SNS': ['Instagram', 'Twitter', 'Facebook', 'TikTok', 'LINE', 'Discord'],
      'ゲーム': ['ゲーム', 'Game', 'パズドラ', 'モンスト', 'ポケモン'],
      'エンタメ': ['YouTube', 'Netflix', 'Amazon Prime', 'Disney+', 'Spotify', 'Apple Music'],
      '仕事': ['Slack', 'Teams', 'Zoom', 'Gmail', 'Outlook', 'Excel', 'Word'],
      'ツール': ['設定', 'カメラ', 'メモ', 'カレンダー', '天気'],
    };
    
    for (final entry in categories.entries) {
      if (entry.value.any((keyword) => appName.contains(keyword))) {
        return entry.key;
      }
    }
    
    return 'その他';
  }

  static int _parseTimeMinutes(String duration) {
    int totalMinutes = 0;
    
    final hourMatch = RegExp(r'(\d+)時間').firstMatch(duration);
    if (hourMatch != null) {
      totalMinutes += int.parse(hourMatch.group(1)!) * 60;
    }
    
    final minuteMatch = RegExp(r'(\d+)分').firstMatch(duration);
    if (minuteMatch != null) {
      totalMinutes += int.parse(minuteMatch.group(1)!);
    }
    
    return totalMinutes;
  }

  static double _calculateConfidence(Map<String, dynamic> factors) {
    double score = 0.0;
    
    if (factors['hasValidName'] == true) score += 0.3;
    if (factors['hasDuration'] == true) score += 0.25;
    if (factors['hasCategory'] == true) score += 0.15;
    if (factors['hasOpenCount'] == true) score += 0.1;
    if (factors['hasDate'] == true) score += 0.1;
    if (factors['hasChange'] == true) score += 0.05;
    if (factors['iosFormat'] == true) score += 0.15;
    if (factors['androidFormat'] == true) score += 0.15;
    if (factors['appStoreFormat'] == true) score += 0.1;
    if (factors['generic'] == true) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  static List<AppUsageItem> _removeDuplicates(List<AppUsageItem> items) {
    final seen = <String>{};
    return items.where((item) {
      final key = '${item.appName}_${item.date}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}
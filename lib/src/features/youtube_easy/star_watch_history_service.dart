import 'package:flutter/foundation.dart';

/// スターの視聴履歴管理サービス
class StarWatchHistoryService {
  
  /// スターの視聴履歴をインポート
  static Future<List<WatchHistoryItem>> importWatchHistory({
    required String starId,
    required WatchHistorySource source,
    Map<String, dynamic>? data,
  }) async {
    try {
      switch (source) {
        case WatchHistorySource.file:
          return _importFromFile(starId, data?['filePath']);
        case WatchHistorySource.url:
          return _importFromUrl(starId, data?['url']);
        case WatchHistorySource.manual:
          return _importManual(starId, data);
      }
    } catch (e) {
      debugPrint('視聴履歴インポートエラー: $e');
      rethrow;
    }
  }
  
  /// ファイルから視聴履歴をインポート
  static Future<List<WatchHistoryItem>> _importFromFile(String starId, String? filePath) async {
    // TODO: YouTubeデータファイル（JSON）の解析を実装
    await Future.delayed(const Duration(seconds: 1)); // 仮の処理時間
    
    // 仮のサンプルデータ
    return [
      WatchHistoryItem(
        id: 'file_${DateTime.now().millisecondsSinceEpoch}',
        title: 'ファイルからインポート: プログラミング入門',
        channelName: 'Tech Channel',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        watchedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WatchHistoryItem(
        id: 'file_${DateTime.now().millisecondsSinceEpoch + 1}',
        title: 'ファイルからインポート: Flutter入門講座',
        channelName: 'Flutter Official',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        watchedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
  
  /// URLから視聴履歴をインポート
  static Future<List<WatchHistoryItem>> _importFromUrl(String starId, String? url) async {
    if (url == null || url.isEmpty) {
      throw Exception('URLが指定されていません');
    }
    
    // TODO: YouTube URLの解析とメタデータ取得を実装
    await Future.delayed(const Duration(seconds: 1)); // 仮の処理時間
    
    return [
      WatchHistoryItem(
        id: 'url_${DateTime.now().millisecondsSinceEpoch}',
        title: 'URLからインポート: $url',
        channelName: 'YouTube Channel',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        videoUrl: url,
        watchedAt: DateTime.now(),
      ),
    ];
  }
  
  /// 手動で視聴履歴を追加
  static Future<List<WatchHistoryItem>> _importManual(String starId, Map<String, dynamic>? data) async {
    if (data == null) {
      throw Exception('手動入力データが指定されていません');
    }
    
    return [
      WatchHistoryItem(
        id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
        title: data['title'] ?? '手動追加動画',
        channelName: data['channelName'] ?? '不明なチャンネル',
        thumbnailUrl: data['thumbnailUrl'] ?? 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        videoUrl: data['videoUrl'] ?? '',
        watchedAt: DateTime.now(),
      ),
    ];
  }
  
  /// スターの共有設定を更新
  static Future<void> updateSharingSettings({
    required String starId,
    required List<String> sharedHistoryIds,
    required bool isPublic,
  }) async {
    try {
      // TODO: Supabaseでの共有設定更新を実装
      debugPrint('共有設定更新: $starId, 共有数: ${sharedHistoryIds.length}, 公開: $isPublic');
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('共有設定更新エラー: $e');
      rethrow;
    }
  }
  
  /// ファンが閲覧可能なスターの視聴履歴を取得
  static Future<List<WatchHistoryItem>> getSharedWatchHistory(String starId) async {
    try {
      // TODO: Supabaseから共有された視聴履歴を取得
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 仮のサンプルデータ
      return [
        WatchHistoryItem(
          id: 'shared_1',
          title: '【共有中】最新のプログラミング技術トレンド',
          channelName: 'Tech Trends',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          watchedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        WatchHistoryItem(
          id: 'shared_2',
          title: '【共有中】Flutter 3.0の新機能解説',
          channelName: 'Flutter Community',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          watchedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } catch (e) {
      debugPrint('共有視聴履歴取得エラー: $e');
      rethrow;
    }
  }
}

/// 視聴履歴アイテム
class WatchHistoryItem {
  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String videoUrl;
  final DateTime watchedAt;
  final bool isShared;
  
  const WatchHistoryItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.watchedAt,
    this.isShared = false,
  });
  
  /// 共有状態を更新したコピーを作成
  WatchHistoryItem copyWith({
    String? id,
    String? title,
    String? channelName,
    String? thumbnailUrl,
    String? videoUrl,
    DateTime? watchedAt,
    bool? isShared,
  }) {
    return WatchHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      channelName: channelName ?? this.channelName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      watchedAt: watchedAt ?? this.watchedAt,
      isShared: isShared ?? this.isShared,
    );
  }
  
  /// JSONからインスタンスを作成
  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      channelName: json['channelName'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      watchedAt: DateTime.parse(json['watchedAt'] ?? DateTime.now().toIso8601String()),
      isShared: json['isShared'] ?? false,
    );
  }
  
  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'watchedAt': watchedAt.toIso8601String(),
      'isShared': isShared,
    };
  }
}

/// 視聴履歴のインポート元
enum WatchHistorySource {
  /// ファイルから（YouTubeデータエクスポート）
  file,
  /// URLから（個別動画URL）
  url,
  /// 手動入力
  manual,
}
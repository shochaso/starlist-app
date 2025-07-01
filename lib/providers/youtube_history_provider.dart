import 'package:flutter_riverpod/flutter_riverpod.dart';

// YouTube履歴データのモデル
class YouTubeHistoryItem {
  final String title;
  final String channel;
  final String? duration;
  final String? uploadTime;
  final String? views;
  final String? viewCount;
  final DateTime addedAt;
  final String? sessionId; // 同じインポートセッションを識別するID
  final String? starName; // スター名
  final String? starGenre; // スターのジャンル

  YouTubeHistoryItem({
    required this.title,
    required this.channel,
    this.duration,
    this.uploadTime,
    this.views,
    this.viewCount,
    required this.addedAt,
    this.sessionId,
    this.starName,
    this.starGenre,
  });

  // 表示用の視聴回数を取得
  String get displayViews {
    return viewCount ?? views ?? '不明';
  }
}

// インポートセッションのグループ
class YouTubeHistoryGroup {
  final String sessionId;
  final DateTime importedAt;
  final List<YouTubeHistoryItem> items;

  YouTubeHistoryGroup({
    required this.sessionId,
    required this.importedAt,
    required this.items,
  });

  // グループ内のアイテム数
  int get itemCount => items.length;
}

// YouTube履歴データを管理するStateNotifier
class YouTubeHistoryNotifier extends StateNotifier<List<YouTubeHistoryItem>> {
  YouTubeHistoryNotifier() : super([]);

  // 新しいYouTube履歴データを追加（スターごとに異なるセッションIDを生成）
  void addHistory(List<YouTubeHistoryItem> newItems) {
    final baseTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // スターごとにグループ化してセッションIDを生成
    final Map<String, List<YouTubeHistoryItem>> starGroups = {};
    for (final item in newItems) {
      final starKey = item.starName ?? item.channel;
      starGroups.putIfAbsent(starKey, () => []).add(item);
    }
    
    final List<YouTubeHistoryItem> itemsWithSession = [];
    
    for (final entry in starGroups.entries) {
      final starKey = entry.key;
      final items = entry.value;
      
      // スター名をベースにしたセッションIDを生成
      final sessionId = '${starKey}_$baseTimestamp';
      
      final starItems = items.map((item) => YouTubeHistoryItem(
        title: item.title,
        channel: item.channel,
        duration: item.duration,
        uploadTime: item.uploadTime,
        views: item.views,
        viewCount: item.viewCount,
        addedAt: item.addedAt,
        sessionId: sessionId,
        starName: item.starName,
        starGenre: item.starGenre,
      )).toList();
      
      itemsWithSession.addAll(starItems);
    }
    
    final updatedList = [...itemsWithSession, ...state];
    // 最新20件まで保持
    state = updatedList.take(20).toList();
    
    // デバッグ出力
    print('YouTube履歴を追加: ${newItems.length}件、合計: ${state.length}件');
    print('スターグループ数: ${starGroups.length}');
    starGroups.forEach((starKey, items) {
      final sessionId = '${starKey}_$baseTimestamp';
      print('  スター$starKey: ${items.length}件 (セッションID: $sessionId)');
    });
    print('追加されたアイテム: ${itemsWithSession.map((item) => '${item.starName ?? item.channel}: ${item.title}').join(', ')}');
  }

  // 履歴をクリア
  void clearHistory() {
    state = [];
  }
  
  // 最新の履歴アイテムを取得（最大4件）
  List<YouTubeHistoryItem> getLatestHistory() {
    return state.take(4).toList();
  }
  
  // セッションIDでグループ化した履歴を取得
  List<YouTubeHistoryGroup> getGroupedHistory() {
    print('getGroupedHistory - 現在の状態: ${state.length}件');
    
    final Map<String, List<YouTubeHistoryItem>> grouped = {};
    
    for (final item in state) {
      // セッションIDでグループ化（セッションIDがない場合はスター名またはチャンネル名を使用）
      final groupKey = item.sessionId ?? (item.starName ?? item.channel);
      grouped.putIfAbsent(groupKey, () => []).add(item);
    }
    
    print('グループ化結果: ${grouped.keys.length}グループ');
    grouped.forEach((groupKey, items) {
      final starName = items.first.starName ?? items.first.channel;
      print('  グループ$groupKey (スター: $starName): ${items.length}件');
    });
    
    final groups = grouped.entries.map((entry) {
      final items = entry.value;
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      
      return YouTubeHistoryGroup(
        sessionId: entry.key,
        importedAt: items.first.addedAt,
        items: items,
      );
    }).toList();
    
    // 最新のインポート順にソート
    groups.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    
    print('最終グループ数: ${groups.length}');
    
    return groups;
  }
}

// YouTube履歴プロバイダー
final youtubeHistoryProvider = StateNotifierProvider<YouTubeHistoryNotifier, List<YouTubeHistoryItem>>((ref) {
  return YouTubeHistoryNotifier();
});

// グループ化されたYouTube履歴プロバイダー
final groupedYoutubeHistoryProvider = Provider<List<YouTubeHistoryGroup>>((ref) {
  final historyList = ref.watch(youtubeHistoryProvider);
  final historyNotifier = ref.read(youtubeHistoryProvider.notifier);
  final groups = historyNotifier.getGroupedHistory();
  
  // デバッグ出力
  print('グループ化プロバイダー - 履歴アイテム数: ${historyList.length}, グループ数: ${groups.length}');
  
  return groups;
});
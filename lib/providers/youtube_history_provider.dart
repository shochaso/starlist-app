import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/data_integration/support_matrix.dart';
import '../features/data_integration/tag_only_saver.dart';

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
  final String? url; // 動画URL（オプション）
  final String? thumbnailUrl; // サムネイルURL（オプション）

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
    this.url,
    this.thumbnailUrl,
  });

  // 表示用の視聴回数を取得
  String get displayViews {
    return viewCount ?? views ?? '不明';
  }

  // JSONシリアライズ
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'channel': channel,
      'duration': duration,
      'uploadTime': uploadTime,
      'views': views,
      'viewCount': viewCount,
      'addedAt': addedAt.toIso8601String(),
      'sessionId': sessionId,
      'starName': starName,
      'starGenre': starGenre,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
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
  
  final _supabase = Supabase.instance.client;

  // 新しいYouTube履歴データを追加（スターごとに異なるセッションIDを生成）
  // 🆕 対応/非対応サービスで分岐処理
  Future<void> addHistory(List<YouTubeHistoryItem> newItems) async {
    if (newItems.isEmpty) {
      return;
    }
    
    // 🆕 Supabaseへの永続化処理を追加
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _persistItems(newItems, userId);
    }

    final allHaveSessionId = newItems.every(
      (item) => item.sessionId != null && item.sessionId!.isNotEmpty,
    );

    final List<YouTubeHistoryItem> itemsWithSession;

    if (allHaveSessionId) {
      // 既にセッションIDが付与されている場合はそのまま利用
      itemsWithSession = List<YouTubeHistoryItem>.from(newItems);
    } else {
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // スター（またはチャンネル）ごとにグループ化し、セッションIDを生成
      final Map<String, List<YouTubeHistoryItem>> starGroups = {};
      for (final item in newItems) {
        final starKey = item.starName ?? item.channel;
        starGroups.putIfAbsent(starKey, () => []).add(item);
      }

      final generatedItems = <YouTubeHistoryItem>[];
      starGroups.forEach((starKey, items) {
        final sessionId = '${starKey}_$baseTimestamp';
        generatedItems.addAll(
          items.map(
            (item) => YouTubeHistoryItem(
              title: item.title,
              channel: item.channel,
              duration: item.duration,
              uploadTime: item.uploadTime,
              views: item.views,
              viewCount: item.viewCount,
              addedAt: item.addedAt,
              sessionId: item.sessionId ?? sessionId,
              starName: item.starName,
              starGenre: item.starGenre,
            ),
          ),
        );
      });

      itemsWithSession = generatedItems;

      print('YouTube履歴を追加: ${newItems.length}件、スターグループ数: ${starGroups.length}');
      starGroups.forEach((starKey, items) {
        final sessionId = '${starKey}_$baseTimestamp';
        print(
            '  スター$starKey: ${items.length}件 (セッションID: ${items.first.sessionId ?? sessionId})');
      });
    }

    final updatedList = [...itemsWithSession, ...state];
    state = updatedList.take(20).toList();

    print('YouTube履歴を追加: ${newItems.length}件、合計: ${state.length}件');
    print(
        '追加されたアイテム: ${itemsWithSession.map((item) => '${item.sessionId}: ${item.title}').join(', ')}');
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
  
  // 🆕 対応/非対応サービスで分岐して永続化
  Future<void> _persistItems(List<YouTubeHistoryItem> items, String userId) async {
    for (final item in items) {
      const category = 'video';
      const service = 'youtube';
      
      // YouTubeは現在MVPで対応済み
      final isSupported = SupportMatrix.isMvpImplemented(service);
      
      if (isSupported) {
        // フルモードで保存（既存の完全処理フロー）
        await _persistFullMode(item, userId);
      } else {
        // タグのみモードで保存
        await _persistTagOnlyMode(item, userId, category, service);
      }
    }
  }
  
  // フルモード保存（既存処理を維持）
  Future<void> _persistFullMode(YouTubeHistoryItem item, String userId) async {
    try {
      // TODO: エンリッチメント（サムネイル取得）
      // TODO: マッチスコア計算
      // TODO: コンテンツモデレーション
      
      await _supabase.from('contents').insert({
        'author_id': userId,
        'title': item.title,
        'description': '${item.channel} - ${item.displayViews}',
        'type': 'video',
        'url': item.url,
        'metadata': {
          'channel': item.channel,
          'duration': item.duration,
          'uploadTime': item.uploadTime,
          'views': item.displayViews,
          'sessionId': item.sessionId,
          'starName': item.starName,
          'starGenre': item.starGenre,
          'thumbnailUrl': item.thumbnailUrl,
        },
        'ingest_mode': 'full',
        'confidence': 1.0, // TODO: 実際のマッチスコア
        'tags': _buildTags(item),
        'occurred_at': item.addedAt.toIso8601String(),
        'category': 'video',
        'service': 'youtube',
        'is_published': false, // デフォルト非公開
      });
      
      print('✅ フルモードで保存: ${item.title}');
    } catch (e) {
      print('❌ 保存エラー: $e');
    }
  }
  
  // タグのみモード保存
  Future<void> _persistTagOnlyMode(
    YouTubeHistoryItem item,
    String userId,
    String category,
    String service,
  ) async {
    try {
      final tags = TagOnlySaver.buildTags(
        category: category,
        service: service,
        brandOrStore: null,
        freeText: '${item.title} ${item.channel}',
      );
      
      await TagOnlySaver().save(
        authorId: userId,
        sourceId: TagOnlySaver.generateSourceId(item.url ?? item.title),
        category: category,
        service: service,
        brandOrStore: null,
        freeTextKeywords: tags,
        occurredAt: item.addedAt,
        rawMetadata: item.toJson(),
      );
      
      print('✅ タグのみモードで保存: ${item.title}');
    } catch (e) {
      print('❌ タグのみ保存エラー: $e');
    }
  }
  
  // タグ配列生成
  List<String> _buildTags(YouTubeHistoryItem item) {
    final tags = <String>{};
    tags.add('video');
    tags.add('youtube');
    tags.add(item.channel);
    
    // タイトルから単語抽出
    final titleWords = item.title
        .split(RegExp(r'[\s　、。・,/|「」【】\(\)（）]+'))
        .where((w) => w.trim().length >= 2)
        .take(20);
    tags.addAll(titleWords);
    
    return tags.toList();
  }
}

// YouTube履歴プロバイダー
final youtubeHistoryProvider =
    StateNotifierProvider<YouTubeHistoryNotifier, List<YouTubeHistoryItem>>(
        (ref) {
  return YouTubeHistoryNotifier();
});

// グループ化されたYouTube履歴プロバイダー
final groupedYoutubeHistoryProvider =
    Provider<List<YouTubeHistoryGroup>>((ref) {
  final historyList = ref.watch(youtubeHistoryProvider);
  final historyNotifier = ref.read(youtubeHistoryProvider.notifier);
  final groups = historyNotifier.getGroupedHistory();

  // デバッグ出力
  print(
      'グループ化プロバイダー - 履歴アイテム数: ${historyList.length}, グループ数: ${groups.length}');

  return groups;
});

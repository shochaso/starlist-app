import 'package:flutter/material.dart';
import '../models/star_activity.dart';

/// スターのアクティビティを管理するリポジトリ
class StarActivityRepository {
  /// 指定したスターIDのアクティビティを取得
  Future<List<StarActivity>> getActivitiesByStarId(String starId) async {
    // TODO: 実際にはSupabaseなどから取得する
    // モックデータを返す
    return _getMockActivities(starId);
  }

  /// 特定のアクティビティを取得
  Future<StarActivity?> getActivityById(String id) async {
    // TODO: 実際にはSupabaseなどから取得する
    // モックデータから指定IDのアクティビティを検索
    final activities = _getMockActivities('mock-star-id');
    try {
      return activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// アクティビティを作成
  Future<void> createActivity(StarActivity activity) async {
    // TODO: 実際にはSupabaseなどに保存する
    debugPrint('アクティビティを作成: ${activity.title}');
  }

  /// アクティビティを更新
  Future<void> updateActivity(StarActivity activity) async {
    // TODO: 実際にはSupabaseなどを更新する
    debugPrint('アクティビティを更新: ${activity.id}');
  }

  /// アクティビティを削除
  Future<void> deleteActivity(String id) async {
    // TODO: 実際にはSupabaseなどから削除する
    debugPrint('アクティビティを削除: $id');
  }

  /// モックアクティビティを取得
  List<StarActivity> _getMockActivities(String starId) {
    final DateTime now = DateTime.now();
    
    return [
      StarActivity(
        id: 'activity-1',
        starId: starId,
        type: ActivityType.youtube,
        title: 'シンガーソングライターインタビュー動画を視聴しました',
        description: 'シンガーソングライターとしての創作プロセスや音楽活動についての独占インタビュー映像です。',
        timestamp: now.subtract(const Duration(hours: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?q=80&w=1740&auto=format&fit=crop',
        actionUrl: 'https://www.youtube.com/watch?v=example1',
        details: {
          'チャンネル': 'ミュージックトーク',
          '動画時間': '15:42',
          'カテゴリ': 'インタビュー',
        },
      ),
      StarActivity(
        id: 'activity-2',
        starId: starId,
        type: ActivityType.shopping,
        title: '新しいマーチャンダイズを購入しました',
        description: '公式ストアでリリース記念Tシャツとトートバッグを購入しました。',
        timestamp: now.subtract(const Duration(hours: 7)),
        imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=1740&auto=format&fit=crop',
        actionUrl: 'https://example.com/official-store',
        details: {
          'ストア': '公式オンラインショップ',
          '購入アイテム': 'リリース記念Tシャツ、トートバッグ',
          '価格': '¥5,800',
        },
      ),
      StarActivity(
        id: 'activity-3',
        starId: starId,
        type: ActivityType.spotify,
        title: '新曲をプレイリストに追加しました',
        description: '最新リリース「Starlight」をお気に入りプレイリストに追加しました。',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1598387993441-a364f854c3e1?q=80&w=1976&auto=format&fit=crop',
        actionUrl: 'https://open.spotify.com/track/example',
        details: {
          'トラック': 'Starlight',
          'アーティスト': 'スターライト',
          'アルバム': 'New Horizon',
          '再生時間': '3:45',
        },
      ),
      StarActivity(
        id: 'activity-4',
        starId: starId,
        type: ActivityType.instagram,
        title: '最新投稿にいいねしました',
        description: 'ニューヨークでの撮影オフショット投稿にいいねしました。',
        timestamp: now.subtract(const Duration(days: 1, hours: 12)),
        imageUrl: 'https://images.unsplash.com/photo-1554921027-e68346972aac?q=80&w=1976&auto=format&fit=crop',
        actionUrl: 'https://instagram.com/p/example',
        details: {
          'ユーザー': '@starshine',
          'いいね数': '25.4K',
          'コメント数': '1.2K',
        },
      ),
      StarActivity(
        id: 'activity-5',
        starId: starId,
        type: ActivityType.youtube,
        title: 'ライブパフォーマンス映像を視聴しました',
        description: '渋谷での特別ライブパフォーマンスの映像です。新曲も披露されています。',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=1740&auto=format&fit=crop',
        actionUrl: 'https://www.youtube.com/watch?v=example2',
        details: {
          'チャンネル': 'MusicLive',
          '視聴回数': '342K',
          '動画時間': '24:18',
        },
      ),
      StarActivity(
        id: 'activity-6',
        starId: starId,
        type: ActivityType.tiktok,
        title: 'ダンスチャレンジ動画を視聴しました',
        description: '新曲に合わせたダンスチャレンジの人気動画を視聴しました。',
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        imageUrl: 'https://images.unsplash.com/photo-1530026186672-2cd00ffc50fe?q=80&w=1974&auto=format&fit=crop',
        actionUrl: 'https://tiktok.com/@example/video/123456',
        details: {
          'クリエイター': '@dancechallenge',
          'いいね数': '1.7M',
          '音楽': 'New Single - Remix',
        },
      ),
    ];
  }
} 
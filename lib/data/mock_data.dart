import '../models/star.dart';
import '../models/activity.dart';

class MockData {
  static List<Star> getStars() {
    return [
      Star(
        id: 'star1',
        name: 'ゆきりぬ',
        category: 'YouTuber',
        rank: 'プラチナ',
        followers: 56000,
        imageUrl: 'https://placehold.jp/150x150.png?text=ゆきりぬ',
      ),
      Star(
        id: 'star2',
        name: '水溜りボンド',
        category: 'YouTuber',
        rank: 'スーパー',
        followers: 235000,
        imageUrl: 'https://placehold.jp/150x150.png?text=水溜りボンド',
      ),
      Star(
        id: 'star3',
        name: '板倉の健ちゃん',
        category: 'ストリーマー',
        rank: 'レギュラー',
        followers: 8700,
        imageUrl: 'https://placehold.jp/150x150.png?text=板倉の健ちゃん',
      ),
      Star(
        id: 'star4',
        name: 'ぺいんと',
        category: 'イラストレーター',
        rank: 'プラチナ',
        followers: 78000,
        imageUrl: 'https://placehold.jp/150x150.png?text=ぺいんと',
      ),
      Star(
        id: 'star5',
        name: 'コムドット',
        category: 'YouTuber',
        rank: 'スーパー',
        followers: 420000,
        imageUrl: 'https://placehold.jp/150x150.png?text=コムドット',
      ),
      Star(
        id: 'star6',
        name: '古川優香',
        category: 'モデル',
        rank: 'プラチナ',
        followers: 198000,
        imageUrl: 'https://placehold.jp/150x150.png?text=古川優香',
      ),
    ];
  }

  static List<Activity> getActivities() {
    return [
      Activity(
        id: 'activity1',
        starId: 'star1',
        type: 'youtube',
        title: '最近ハマっている料理動画',
        content: 'Joshua Weissman「Perfect Fried Chicken」',
        timestamp: DateTime.parse('2023-04-01T10:23:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=料理動画',
      ),
      Activity(
        id: 'activity2',
        starId: 'star2',
        type: 'purchase',
        title: 'Amazonで購入しました',
        content: 'Apple AirPods Pro 第2世代',
        price: 32800,
        timestamp: DateTime.parse('2023-03-28T15:40:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=AirPods',
      ),
      Activity(
        id: 'activity3',
        starId: 'star3',
        type: 'music',
        title: '今日のプレイリスト',
        content: 'King Gnu - Vinyl',
        timestamp: DateTime.parse('2023-04-02T09:15:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=King Gnu',
      ),
      Activity(
        id: 'activity4',
        starId: 'star4',
        type: 'app',
        title: '最近ハマっているアプリ',
        content: 'Procreate Pocket',
        timestamp: DateTime.parse('2023-03-30T14:20:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=Procreate',
      ),
      Activity(
        id: 'activity5',
        starId: 'star5',
        type: 'food',
        title: '今日のランチ',
        content: '渋谷「THE GREAT BURGER」のチーズバーガー',
        timestamp: DateTime.parse('2023-04-03T12:45:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=バーガー',
      ),
      Activity(
        id: 'activity6',
        starId: 'star6',
        type: 'purchase',
        title: '最近のお気に入りコスメ',
        content: 'NARS ナチュラルラディアント ロングウェア ファンデーション',
        price: 6380,
        timestamp: DateTime.parse('2023-03-29T18:30:00Z'),
        imageUrl: 'https://placehold.jp/300x200.png?text=NARS',
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'YouTuber',
      'ミュージシャン',
      'アーティスト',
      'モデル',
      'ストリーマー',
      'イラストレーター',
      'ゲーマー',
      'コメディアン',
      'インフルエンサー',
    ];
  }
} 
import 'package:flutter/material.dart';
import '../models/post_model.dart';

/// ふじわらのみいの投稿データ
class FujiwaraNoMiiPosts {
  // ふじわらのみいの基本情報
  static const String authorId = 'fujiwara_nomii_official';
  static const String authorName = 'ふじわらのみい';
  static const String authorAvatar = 'FM';
  static const Color authorColor = Color(0xFFFF69B4);

  /// ふじわらのみいの投稿一覧
  static List<PostModel> get posts => [
    _createYouTubePost1(),
    _createYouTubePost2(),
    _createAmazonShoppingPost(),
  ];

  /// YouTube閲覧投稿1（公開）
  static PostModel _createYouTubePost1() {
    return PostModel.youtubePost(
      id: 'fujiwara_youtube_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '今日観たYouTube動画まとめ🎥',
      description: 'グルメ系とVlog系の動画をたくさん観ました！美味しそうな料理動画が最高でした〜✨',
      videos: [
        {
          'title': '【大食い】話題の高級焼肉食べ放題に行ってきた！',
          'channel': 'グルメチャンネル',
          'duration': '18:30',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
          'url': 'https://youtube.com/watch?v=yakiniku123',
          'viewedAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
        {
          'title': '【Vlog】朝から夜まで密着！1日の過ごし方',
          'channel': 'みいVlog',
          'duration': '22:15',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
          'url': 'https://youtube.com/watch?v=vlog456',
          'viewedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'title': '【簡単レシピ】10分でできる絶品パスタの作り方',
          'channel': '料理研究家まい',
          'duration': '10:45',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
          'url': 'https://youtube.com/watch?v=pasta789',
          'viewedAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
      ],
      tags: ['YouTube', 'グルメ', 'Vlog', '料理', '大食い'],
    );
  }

  /// YouTube閲覧投稿2（公開）
  static PostModel _createYouTubePost2() {
    return PostModel.youtubePost(
      id: 'fujiwara_youtube_002',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '最近ハマってる YouTuber紹介✨',
      description: 'おすすめのYouTuberを紹介！エンタメ系とライフスタイル系が多めです',
      videos: [
        {
          'title': '【衝撃】○○の真実を暴露します！',
          'channel': 'トレンドウォッチャー',
          'duration': '15:20',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
          'url': 'https://youtube.com/watch?v=truth001',
          'viewedAt': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        },
        {
          'title': '【ルームツアー】念願の新居を大公開！',
          'channel': 'ライフスタイルChannel',
          'duration': '12:30',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
          'url': 'https://youtube.com/watch?v=room002',
          'viewedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        },
      ],
      tags: ['YouTube', 'エンタメ', 'ライフスタイル', 'ルームツアー'],
    );
  }

  /// Amazon購入履歴投稿（公開）
  static PostModel _createAmazonShoppingPost() {
    return PostModel.shoppingPost(
      id: 'fujiwara_amazon_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '【Amazon購入品】今月買ってよかったものベスト5🛍️',
      description: 'Amazonで購入したおすすめ商品を紹介！どれも本当に買ってよかったです💕',
      items: [
        {
          'name': 'ワイヤレスイヤホン Pro Max',
          'brand': 'SoundTech',
          'price': 12800,
          'color': 'ホワイト',
          'category': '家電・カメラ',
          'image': 'https://m.media-amazon.com/images/I/placeholder.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'store': 'Amazon.co.jp',
          'rating': 5,
          'review': 'ノイズキャンセリングが最高！音質もクリアで通勤が快適になりました',
          'asin': 'B0XXXXXXXX',
          'url': 'https://amazon.co.jp/dp/B0XXXXXXXX',
        },
        {
          'name': 'LEDリングライト 撮影用',
          'brand': 'PhotoPro',
          'price': 4980,
          'color': 'ブラック',
          'category': 'カメラ',
          'image': 'https://m.media-amazon.com/images/I/placeholder.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'store': 'Amazon.co.jp',
          'rating': 4,
          'review': '動画撮影の光が綺麗に！明るさ調整も簡単で使いやすいです',
          'asin': 'B0YYYYYYYY',
          'url': 'https://amazon.co.jp/dp/B0YYYYYYYY',
        },
        {
          'name': 'スキンケアセット（化粧水・乳液・美容液）',
          'brand': 'BeautyLab',
          'price': 8900,
          'category': 'ビューティー',
          'image': 'https://m.media-amazon.com/images/I/placeholder.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'store': 'Amazon.co.jp',
          'rating': 5,
          'review': '肌が潤って調子がいい感じ！コスパも良くてリピ確定です',
          'asin': 'B0ZZZZZZZZ',
          'url': 'https://amazon.co.jp/dp/B0ZZZZZZZZ',
        },
        {
          'name': 'プロテインシェイカー ボトル 700ml',
          'brand': 'FitnessGear',
          'price': 1580,
          'color': 'ピンク',
          'category': 'スポーツ＆アウトドア',
          'image': 'https://m.media-amazon.com/images/I/placeholder.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'store': 'Amazon.co.jp',
          'rating': 4,
          'review': '漏れないし洗いやすい！ジム通いに最適なシェイカーです',
          'asin': 'B0AAAAAAAA',
          'url': 'https://amazon.co.jp/dp/B0AAAAAAAA',
        },
        {
          'name': 'Bluetoothスピーカー 防水',
          'brand': 'SoundWave',
          'price': 5980,
          'color': 'ネイビー',
          'category': '家電・カメラ',
          'image': 'https://m.media-amazon.com/images/I/placeholder.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
          'store': 'Amazon.co.jp',
          'rating': 5,
          'review': 'お風呂で音楽聴くのに最高！防水だから安心して使えます🎵',
          'asin': 'B0BBBBBBBB',
          'url': 'https://amazon.co.jp/dp/B0BBBBBBBB',
        },
      ],
      tags: ['Amazon', 'ショッピング', '購入品', 'おすすめ', '家電', '美容'],
      accessLevel: AccessLevel.public,
    );
  }

  /// 全投稿
  static List<PostModel> get allPosts => posts;
}


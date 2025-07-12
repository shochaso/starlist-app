import 'package:flutter/material.dart';
import '../models/post_model.dart';

/// 花山瑞樹の投稿データ
class HanayamaMizukiPosts {
  // 花山瑞樹の基本情報
  static const String authorId = 'hanayama_mizuki_official';
  static const String authorName = '花山瑞樹';
  static const String authorAvatar = 'HM';
  static const Color authorColor = Color(0xFFFFB6C1);

  /// 花山瑞樹の投稿一覧
  static List<PostModel> get posts => [
    _createYouTubePost(),
    _createShoppingPost(),
  ];

  /// YouTube閲覧投稿（公開）
  static PostModel _createYouTubePost() {
    return PostModel.youtubePost(
      id: 'hanayama_youtube_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '今日のYouTube視聴まとめ✨',
      description: '今日見た動画をシェア！美容系とファッション系の動画をたくさん見ました💄👗',
      videos: [
        {
          'title': '【冬コーデ】大人可愛いニットの着回し7選',
          'channel': 'Fashion Channel Tokyo',
          'duration': '12:34',
          'thumbnail': 'https://example.com/thumb1.jpg',
          'url': 'https://youtube.com/watch?v=abc123',
          'viewedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'title': '2024年冬トレンドメイク💄完全版',
          'channel': 'Beauty Guru Yuki',
          'duration': '8:45',
          'thumbnail': 'https://example.com/thumb2.jpg',
          'url': 'https://youtube.com/watch?v=def456',
          'viewedAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'title': 'プチプラコスメで作る上品メイク',
          'channel': 'コスメマニア',
          'duration': '15:22',
          'thumbnail': 'https://example.com/thumb3.jpg',
          'url': 'https://youtube.com/watch?v=ghi789',
          'viewedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        },
      ],
      tags: ['YouTube', 'ファッション', '美容', 'メイク', 'コーデ'],
    );
  }

  /// 服購入投稿（有料会員限定）
  static PostModel _createShoppingPost() {
    return PostModel.shoppingPost(
      id: 'hanayama_shopping_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '【限定公開】冬のお買い物レポ🛍️',
      description: '今日のお買い物の詳細をプレミアム会員さんだけに特別公開！どのブランドで何を買ったか、お値段も含めて全部シェアします💕',
      items: [
        {
          'name': 'ケーブルニット オーバーサイズ',
          'brand': 'ZARA',
          'price': 5990,
          'color': 'ベージュ',
          'size': 'M',
          'category': 'トップス',
          'image': 'https://example.com/item1.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          'store': 'ZARA 渋谷店',
          'rating': 5,
          'review': 'とても暖かくて着心地が良い！オーバーサイズなのでゆったり着れます💕',
        },
        {
          'name': 'ハイウエストストレートデニム',
          'brand': 'UNIQLO',
          'price': 3990,
          'color': 'インディゴブルー',
          'size': '25',
          'category': 'ボトムス',
          'image': 'https://example.com/item2.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          'store': 'ユニクロ 原宿店',
          'rating': 4,
          'review': 'シルエットがとても綺麗！少し丈が長めなので裾上げしました✂️',
        },
        {
          'name': 'レザーショルダーバッグ',
          'brand': 'Michael Kors',
          'price': 24800,
          'color': 'ブラック',
          'size': 'Medium',
          'category': 'バッグ',
          'image': 'https://example.com/item3.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'store': 'マイケル・コース 銀座店',
          'rating': 5,
          'review': '憧れのマイケルコース🤍質感がとても良くて長く使えそう！',
        },
        {
          'name': 'ウールコート ロング丈',
          'brand': 'Mila Owen',
          'price': 28600,
          'color': 'キャメル',
          'size': 'S',
          'category': 'アウター',
          'image': 'https://example.com/item4.jpg',
          'purchaseDate': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'store': 'Mila Owen ルミネ新宿店',
          'rating': 5,
          'review': '今年の冬のメインコート！色味がとても上品で気に入ってます☺️',
        },
      ],
      accessLevel: AccessLevel.standard, // スタンダード会員以上限定
      tags: ['ショッピング', 'ファッション', 'ZARA', 'UNIQLO', 'MichaelKors', 'MilaOwen', '限定公開'],
    );
  }

  /// 追加の投稿（デモ用）
  static List<PostModel> get additionalPosts => [
    _createMorningRoutinePost(),
    _createCafePost(),
    _createBeautyPost(),
  ];

  /// モーニングルーティン投稿
  static PostModel _createMorningRoutinePost() {
    return PostModel(
      id: 'hanayama_morning_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '朝のルーティン☀️',
      description: 'プレミアム会員さん限定！私の朝のルーティンを詳しく公開します💫',
      type: PostType.lifestyle,
      accessLevel: AccessLevel.premium,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      content: {
        'routine': [
          {'time': '6:30', 'activity': '起床・白湯を飲む', 'description': '体を内側から温めます🔥'},
          {'time': '6:45', 'activity': 'ストレッチ・ヨガ', 'description': '15分間の軽いヨガで体をほぐします🧘‍♀️'},
          {'time': '7:00', 'activity': 'スキンケア', 'description': 'お気に入りのスキンケアルーティン✨'},
          {'time': '7:30', 'activity': '朝食', 'description': 'プロテインスムージーとフルーツ🥤🍓'},
          {'time': '8:00', 'activity': 'メイク', 'description': '今日のメイクを決めます💄'},
        ],
      },
      tags: ['モーニングルーティン', 'ライフスタイル', 'ヨガ', 'スキンケア', 'プレミアム限定'],
      likesCount: 156,
      commentsCount: 23,
    );
  }

  /// カフェ投稿
  static PostModel _createCafePost() {
    return PostModel(
      id: 'hanayama_cafe_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '新しいカフェ発見☕️',
      description: '今日見つけた素敵なカフェをご紹介！',
      type: PostType.food,
      accessLevel: AccessLevel.public,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      content: {
        'cafe': {
          'name': 'Blue Bottle Coffee 表参道カフェ',
          'location': '表参道',
          'rating': 4.8,
          'price_range': '¥500-1000',
          'atmosphere': 'おしゃれで落ち着いた雰囲気',
          'recommended': 'New Orleans Iced Coffee',
        },
        'photos': ['cafe1.jpg', 'cafe2.jpg', 'coffee.jpg'],
      },
      tags: ['カフェ', 'コーヒー', '表参道', 'BlueBottle'],
      likesCount: 89,
      commentsCount: 12,
    );
  }

  /// 美容投稿
  static PostModel _createBeautyPost() {
    return PostModel(
      id: 'hanayama_beauty_001',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: '【ライト会員限定】新作コスメレビュー💄',
      description: '今月購入したコスメの詳細レビューです！',
      type: PostType.lifestyle,
      accessLevel: AccessLevel.light,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      content: {
        'products': [
          {
            'name': 'Dior アディクト リップ グロウ',
            'brand': 'Dior',
            'price': 4400,
            'rating': 5,
            'review': '色持ちが良くて唇が荒れない！リピート確定です💕',
          },
          {
            'name': 'NARS ブラッシュ',
            'brand': 'NARS',
            'price': 4180,
            'rating': 4,
            'review': '発色が綺麗で使いやすい色味でした🌸',
          },
        ],
      },
      tags: ['美容', 'コスメ', 'Dior', 'NARS', 'レビュー', 'ライト会員限定'],
      likesCount: 234,
      commentsCount: 45,
    );
  }

  /// 投稿の総数
  static int get totalPostsCount => posts.length + additionalPosts.length;

  /// 公開投稿の数
  static int get publicPostsCount => posts
      .where((post) => post.accessLevel == AccessLevel.public)
      .length;

  /// 有料投稿の数
  static int get premiumPostsCount => posts
      .where((post) => post.accessLevel != AccessLevel.public)
      .length;

  /// 全ての投稿を取得
  static List<PostModel> get allPosts => [...posts, ...additionalPosts];

  /// アクセスレベル別に投稿をフィルタリング
  static List<PostModel> getPostsByAccessLevel(AccessLevel userLevel) {
    return allPosts.where((post) => post.canAccess(userLevel)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 投稿タイプ別に投稿を取得
  static List<PostModel> getPostsByType(PostType type) {
    return allPosts.where((post) => post.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
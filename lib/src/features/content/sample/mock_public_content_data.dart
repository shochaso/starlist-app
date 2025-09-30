import '../models/content_consumption_model.dart';

class MockPublicContentData {
  MockPublicContentData._();

  static final List<ContentConsumption> _contents = _generate();

  static List<ContentConsumption> get contents => List.unmodifiable(_contents);

  static List<ContentConsumption> _generate() {
    final now = DateTime.now();
    var counter = 0;
    String nextId() => 'public-content-${counter++}';

    ContentConsumption create({
      required String title,
      String? description,
      required ContentCategory category,
      required DateTime createdAt,
      Map<String, dynamic> data = const {},
      List<String>? tags,
      int viewCount = 0,
      int likeCount = 0,
    }) {
      return ContentConsumption(
        id: nextId(),
        userId: 'public-user',
        title: title,
        description: description,
        category: category,
        contentData: data,
        privacyLevel: PrivacyLevel.public,
        tags: tags,
        createdAt: createdAt,
        updatedAt: createdAt,
        viewCount: viewCount,
        likeCount: likeCount,
        commentCount: (likeCount / 4).round(),
      );
    }

    return [
      create(
        title: 'スターが選ぶ最新YouTubeプレイリスト',
        description: 'ライブ前にチェックしている動画をまとめました。',
        category: ContentCategory.youtube,
        createdAt: now.subtract(const Duration(hours: 4)),
        data: {
          'video_count': 6,
          'duration': 58 * 60,
        },
        tags: const ['ライブ準備', 'Vlog'],
        viewCount: 2480,
        likeCount: 612,
      ),
      create(
        title: '朝ランニングのときに聴いている楽曲メモ',
        category: ContentCategory.music,
        createdAt: now.subtract(const Duration(hours: 12)),
        data: {
          'platform': 'Spotify',
          'mood': 'upbeat',
        },
        tags: const ['モーニングルーティン'],
        viewCount: 1940,
        likeCount: 488,
      ),
      create(
        title: '撮影現場で差し入れたスイーツ',
        description: 'ピスタチオタルトが好評でした。',
        category: ContentCategory.food,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        data: {
          'store': '表参道カフェ',
          'price': 1800,
        },
        tags: const ['撮影裏側'],
        viewCount: 1520,
        likeCount: 402,
      ),
      create(
        title: '最近読んだビジネス書ベスト3',
        description: '特に第2章のタイムマネジメント術が参考になりました。',
        category: ContentCategory.book,
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        tags: const ['インプット', 'ライフハック'],
        viewCount: 1760,
        likeCount: 520,
      ),
      create(
        title: 'ツアー遠征で訪れたご当地グルメ',
        category: ContentCategory.location,
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
        data: {
          'place_name': '札幌市内',
          'category': 'レストラン',
        },
        tags: const ['ツアー', '旅ログ'],
        viewCount: 980,
        likeCount: 210,
      ),
      create(
        title: '制作期間中の集中プレイリスト',
        category: ContentCategory.music,
        createdAt: now.subtract(const Duration(days: 4, hours: 6)),
        data: {
          'platform': 'Apple Music',
          'genre': 'Lo-fi',
        },
        viewCount: 2250,
        likeCount: 640,
      ),
      create(
        title: 'お気に入りのデジタルガジェット',
        description: 'ライブ配信の音質向上に役立ちました。',
        category: ContentCategory.purchase,
        createdAt: now.subtract(const Duration(days: 5, hours: 4)),
        data: {
          'price': 24800,
          'brand': 'SoundCore',
        },
        tags: const ['機材アップデート'],
        viewCount: 1350,
        likeCount: 350,
      ),
      create(
        title: '夜のクールダウン・ヨガルーティン',
        category: ContentCategory.other,
        createdAt: now.subtract(const Duration(days: 6, hours: 1)),
        data: {
          'duration': 25,
          'focus': 'リラックス',
        },
        tags: const ['セルフケア'],
        viewCount: 1190,
        likeCount: 312,
      ),
    ];
  }
}

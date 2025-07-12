/// 花山瑞樹の投稿データ
class HanayamaPostsData {
  static final Map<String, Map<String, dynamic>> posts = {
    'post_hanayama_001': {
      'id': 'post_hanayama_001',
      'type': 'video',
      'title': '【2024年冬】最新コート購入品紹介！ZARA、ユニクロ、GUで見つけたお気に入り💕',
      'description': '''
今年の冬に向けて購入したコートを詳しく紹介します！
プチプラから少し高めまで、様々な価格帯のアイテムをレビューしました🧥

📝今回紹介するアイテム
• ZARA オーバーサイズウールコート（¥9,990）
• ユニクロ ライトウォームパデッドコート（¥7,990）
• GU フェイクムートンコート（¥4,990）

それぞれの着心地、サイズ感、コーデのポイントも詳しく解説しています✨

#ファッション #コート #ZARA #ユニクロ #GU #購入品紹介
      ''',
      'starName': '花山瑞樹',
      'starId': 'hanayama_mizuki_official',
      'publishedAt': '2024-07-11T14:30:00Z',
      'views': 24500,
      'likes': 1820,
      'comments': 156,
      'shares': 89,
      'duration': '12:34',
      'thumbnail': 'https://example.com/thumbnails/hanayama_winter_coat_2024.jpg',
      'isPremium': false,
      'memberLevel': 'free', // free, basic, premium
      'category': 'ファッション',
      'tags': ['ファッション', 'コート', 'ZARA', 'ユニクロ', 'GU', '購入品紹介'],
      
      // 関連する購入データ
      'relatedPurchases': [
        {
          'store': 'ZARA',
          'item': 'オーバーサイズウールコート',
          'price': 9990,
          'color': 'ベージュ',
          'size': 'M',
          'rating': 4.5,
          'purchaseDate': '2024-07-10',
          'review': 'シルエットが綺麗で、どんなコーデにも合わせやすい！生地もしっかりしていて長く使えそうです🧥'
        },
        {
          'store': 'ユニクロ',
          'item': 'ライトウォームパデッドコート',
          'price': 7990,
          'color': 'ブラック',
          'size': 'S',
          'rating': 4.0,
          'purchaseDate': '2024-07-10',
          'review': '軽くて暖かい！普段使いにぴったりです'
        },
        {
          'store': 'GU',
          'item': 'フェイクムートンコート',
          'price': 4990,
          'color': 'キャメル',
          'size': 'M',
          'rating': 3.5,
          'purchaseDate': '2024-07-10',
          'review': 'この価格でこのクオリティは十分！カジュアルコーデに活躍します'
        },
      ],
      
      // コメント
      'topComments': [
        {
          'userId': 'fan_001',
          'userName': 'まい',
          'comment': 'ZARAのコート本当に可愛い！サイズ感参考になりました💕',
          'likes': 23,
          'timestamp': '2024-07-11T15:00:00Z',
        },
        {
          'userId': 'fan_002', 
          'userName': 'あゆ',
          'comment': 'ユニクロのコートも気になってたので助かります！',
          'likes': 18,
          'timestamp': '2024-07-11T15:15:00Z',
        },
        {
          'userId': 'fan_003',
          'userName': 'りさ',
          'comment': 'みずきちゃんのコーデいつも参考にしてます✨次の動画も楽しみ！',
          'likes': 31,
          'timestamp': '2024-07-11T16:00:00Z',
        },
      ],
    },
    
    'post_hanayama_002': {
      'id': 'post_hanayama_002',
      'type': 'vlog',
      'title': '【日常Vlog】カフェ巡り＆お気に入りスキンケア購入｜のんびり休日の過ごし方🌸',
      'description': '''
久しぶりのゆったり休日！
新しくオープンしたカフェに行って、ずっと気になっていたスキンケアアイテムもお迎えしました☕

📍今回行ったカフェ
表参道の新しいカフェ「Bloom Coffee」
ラテアートが本当に綺麗で、店内もとてもおしゃれでした✨

🧴購入したスキンケア
• エトヴォス ナチュラル美容液（¥3,800）
• アクセーヌ フェイシャルミスト（¥2,200）

使用感も詳しくレビューしています💄

#日常Vlog #カフェ #スキンケア #休日 #のんびり
      ''',
      'starName': '花山瑞樹',
      'starId': 'hanayama_mizuki_official',
      'publishedAt': '2024-07-08T12:00:00Z',
      'views': 18700,
      'likes': 1340,
      'comments': 89,
      'shares': 45,
      'duration': '15:42',
      'thumbnail': 'https://example.com/thumbnails/hanayama_weekend_vlog_cafe.jpg',
      'isPremium': true, // プレミアム限定コンテンツ
      'memberLevel': 'premium',
      'category': '日常Blog',
      'tags': ['日常Vlog', 'カフェ', 'スキンケア', '休日', 'のんびり'],
      
      'relatedPurchases': [
        {
          'store': 'コスメキッチン',
          'item': 'エトヴォス ナチュラル美容液',
          'price': 3800,
          'brand': 'エトヴォス',
          'rating': 5.0,
          'purchaseDate': '2024-07-08',
          'review': 'ずっと気になっていたアイテム！使用感がとても良くて、肌がもちもちになります✨'
        },
        {
          'store': 'コスメキッチン',
          'item': 'アクセーヌ フェイシャルミスト',
          'price': 2200,
          'brand': 'アクセーヌ',
          'rating': 4.0,
          'purchaseDate': '2024-07-08',
          'review': '保湿力が高くて、メイクの上からでもシュッと使えて便利です'
        },
      ],
    },
    
    'post_hanayama_003': {
      'id': 'post_hanayama_003',
      'type': 'haul',
      'title': '【購入品】無印良品で見つけた生活を豊かにするアイテム7選📝✨',
      'description': '''
無印良品で購入した日用品を紹介！
どれも実用的で、生活の質を上げてくれるアイテムばかりです🏠

📦今回購入したアイテム
• アロマディフューザー（¥6,990）
• オーガニックコットンタオル（¥1,990）
• 収納ボックス 3個セット（¥2,990）
• ステンレス保温ボトル（¥2,490）
• その他3アイテム

それぞれの使用感や、なぜ選んだのかも詳しく説明しています！

#購入品 #無印良品 #日用品 #ライフスタイル #インテリア
      ''',
      'starName': '花山瑞樹',
      'starId': 'hanayama_mizuki_official',
      'publishedAt': '2024-07-05T18:00:00Z',
      'views': 31200,
      'likes': 2150,
      'comments': 203,
      'shares': 124,
      'duration': '10:15',
      'thumbnail': 'https://example.com/thumbnails/hanayama_muji_haul_2024.jpg',
      'isPremium': false,
      'memberLevel': 'free',
      'category': '日用品',
      'tags': ['購入品', '無印良品', '日用品', 'ライフスタイル', 'インテリア'],
      
      'relatedPurchases': [
        {
          'store': '無印良品',
          'item': 'アロマディフューザー',
          'price': 6990,
          'rating': 4.5,
          'purchaseDate': '2024-07-05',
          'review': 'デザインがシンプルで部屋に馴染みます。香りの拡散力も申し分なし！'
        },
        {
          'store': '無印良品',
          'item': 'オーガニックコットンタオル',
          'price': 1990,
          'color': 'ナチュラル',
          'rating': 4.0,
          'purchaseDate': '2024-07-05',
          'review': '肌に優しくて吸水性も良い。毎日使うものだからこだわりたいアイテム'
        },
        {
          'store': '無印良品',
          'item': '収納ボックス（3個セット）',
          'price': 2990,
          'rating': 5.0,
          'purchaseDate': '2024-07-05',
          'review': 'クローゼットの整理に大活躍！サイズ感も絶妙で使いやすいです📦'
        },
      ],
    },
  };
}
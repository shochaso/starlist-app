import '../models/user.dart';

class TestAccountsData {
  // 花山瑞樹のフォロー情報
  static final Map<String, dynamic> hanayamaMizukiFollowData = {
    'id': 'hanayama_mizuki',
    'name': '花山瑞樹',
    'category': '日常Blog・ファッション',
    'followers': '127K',
    'avatar': null,
    'isVerified': true,
    'followedDate': '2024/01/01',
    'description': 'ファッション・ライフスタイル・お買い物記録',
    'specialties': ['ファッション', 'コスメ', '日用品', 'カフェ'],
  };

  // 共通フォローリスト（全プランに花山瑞樹を含める）
  static final List<Map<String, dynamic>> commonFollowingList = [
    hanayamaMizukiFollowData,
    {
      'id': '2',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'followers': '24.5K',
      'avatar': null,
      'isVerified': true,
      'followedDate': '2024/01/15',
    },
    {
      'id': '3',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': '18.3K',
      'avatar': null,
      'isVerified': false,
      'followedDate': '2024/01/10',
    },
  ];

  static final User freeFan = User(
    id: 'test_free_fan',
    name: '田中太郎',
    email: 'shomafree@gmail.com',
    type: UserType.fan,
    fanPlanType: FanPlanType.free,
    createdAt: DateTime.now(),
  );

  static final User lightPlan = User(
    id: 'test_light_fan',
    name: '佐藤花子',
    email: 'shomalight@gmail.com',
    type: UserType.fan,
    fanPlanType: FanPlanType.light,
    createdAt: DateTime.now(),
  );

  static final User standardPlan = User(
    id: 'test_standard_fan',
    name: '山田次郎',
    email: 'yamada.jiro@example.com',
    type: UserType.fan,
    fanPlanType: FanPlanType.standard,
    createdAt: DateTime.now(),
  );

  static final User premiumPlan = User(
    id: 'test_premium_fan',
    name: '鈴木美咲',
    email: 'suzuki.misaki@example.com',
    type: UserType.fan,
    fanPlanType: FanPlanType.premium,
    createdAt: DateTime.now(),
  );

  static final User starUser = User(
    id: 'test_star_creator',
    name: '花山瑞樹',
    email: 'hanayama@gmail.com',
    type: UserType.star,
    fanPlanType: null,
    createdAt: DateTime.now(),
  );

  static List<User> get allTestUsers => [
    freeFan,
    lightPlan,
    standardPlan,
    premiumPlan,
    starUser,
  ];

  // プラン別フォローリストを取得するメソッド
  static List<Map<String, dynamic>> getFollowingListForPlan(FanPlanType? planType) {
    // 全プランに花山瑞樹を含める
    List<Map<String, dynamic>> followingList = List.from(commonFollowingList);
    
    // プランに応じて追加のフォロー対象を設定
    switch (planType) {
      case FanPlanType.free:
        // 無料プランは基本の3人（花山瑞樹含む）
        break;
      case FanPlanType.light:
        // ライトプランは+1人
        followingList.add({
          'id': '4',
          'name': 'フィットネス山田',
          'category': 'フィットネス',
          'followers': '12.1K',
          'avatar': null,
          'isVerified': true,
          'followedDate': '2024/01/08',
        });
        break;
      case FanPlanType.standard:
        // スタンダードプランは+2人
        followingList.addAll([
          {
            'id': '4',
            'name': 'フィットネス山田',
            'category': 'フィットネス',
            'followers': '12.1K',
            'avatar': null,
            'isVerified': true,
            'followedDate': '2024/01/08',
          },
          {
            'id': '5',
            'name': '旅行ブロガー鈴木',
            'category': '旅行・観光',
            'followers': '35.2K',
            'avatar': null,
            'isVerified': true,
            'followedDate': '2024/01/05',
          },
        ]);
        break;
      case FanPlanType.premium:
        // プレミアムプランは+3人
        followingList.addAll([
          {
            'id': '4',
            'name': 'フィットネス山田',
            'category': 'フィットネス',
            'followers': '12.1K',
            'avatar': null,
            'isVerified': true,
            'followedDate': '2024/01/08',
          },
          {
            'id': '5',
            'name': '旅行ブロガー鈴木',
            'category': '旅行・観光',
            'followers': '35.2K',
            'avatar': null,
            'isVerified': true,
            'followedDate': '2024/01/05',
          },
          {
            'id': '6',
            'name': 'ビジネス系YouTuber',
            'category': 'ビジネス・自己啓発',
            'followers': '68.7K',
            'avatar': null,
            'isVerified': true,
            'followedDate': '2024/01/03',
          },
        ]);
        break;
      default:
        // スターユーザーの場合は空のリスト
        return [];
    }
    
    return followingList;
  }

  // テストアカウントのフォローデータを取得
  static Map<String, List<Map<String, dynamic>>> getContentDataForUser(User user) {
    return {
      'following': getFollowingListForPlan(user.fanPlanType),
      'favorites': [], // 必要に応じて後で実装
      'playlists': [], // 必要に応じて後で実装
      'saved': [], // 必要に応じて後で実装
    };
  }
}

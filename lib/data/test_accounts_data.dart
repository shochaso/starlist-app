import '../models/user.dart';

class TestAccountsData {
  static final User freeFan = User(
    id: 'test_free_fan',
    name: '田中太郎',
    email: 'tanaka.taro@example.com',
    type: UserType.fan,
    fanPlanType: FanPlanType.free,
    createdAt: DateTime.now(),
  );

  static final User lightPlan = User(
    id: 'test_light_fan',
    name: '佐藤花子',
    email: 'sato.hanako@example.com',
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
    email: 'hanayama@example.com',
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
}

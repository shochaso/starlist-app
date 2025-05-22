import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_implementation/src/features/user_experience/engagement/models/badge_models.dart';
import 'package:starlist_implementation/src/features/user_experience/engagement/services/badge_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

class MockBadgeService extends Mock implements BadgeService {}

void main() {
  group('バッジシステムのテスト', () {
    late BadgeService badgeService;
    
    setUp(() {
      badgeService = BadgeService();
    });
    
    test('バッジモデルが正しく作成されること', () {
      final badge = Badge(
        id: 'badge_1',
        title: 'ブロンズファン',
        description: '10回以上いいねを押したファン',
        level: BadgeLevel.bronze,
        iconName: 'bronze_fan',
        criteria: BadgeCriteria.likes,
        threshold: 10,
        earnedAt: DateTime.now(),
      );
      
      expect(badge.id, 'badge_1');
      expect(badge.title, 'ブロンズファン');
      expect(badge.level, BadgeLevel.bronze);
      expect(badge.criteria, BadgeCriteria.likes);
      expect(badge.threshold, 10);
    });
    
    test('バッジレベルが正しく判定されること', () {
      expect(BadgeService.determineBadgeLevel(5), BadgeLevel.bronze);
      expect(BadgeService.determineBadgeLevel(15), BadgeLevel.silver);
      expect(BadgeService.determineBadgeLevel(30), BadgeLevel.gold);
    });
    
    test('ユーザーのバッジが正しく取得できること', () async {
      final badges = await badgeService.getUserBadges('user_1');
      
      expect(badges, isNotEmpty);
      expect(badges.length, greaterThanOrEqualTo(1));
      expect(badges.first.id, isNotEmpty);
    });
    
    test('スターのバッジが正しく取得できること', () async {
      final badges = await badgeService.getStarBadges('star_1');
      
      expect(badges, isNotEmpty);
      expect(badges.length, greaterThanOrEqualTo(1));
      expect(badges.first.id, isNotEmpty);
    });
    
    test('ロイヤルファンバッジが正しく取得できること', () async {
      final badges = await badgeService.getLoyalFanBadges('user_1', 'star_1');
      
      expect(badges, isNotEmpty);
      expect(badges.where((badge) => badge.criteria == BadgeCriteria.loyalty).length, greaterThanOrEqualTo(1));
    });
  });
}
